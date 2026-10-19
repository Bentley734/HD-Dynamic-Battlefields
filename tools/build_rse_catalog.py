"""Build the Hoenn integration catalog from complete source/reuse families.

Incomplete families remain absent so the renderer retains native scenery.
This catalog is not automatically added to the release download index.
"""
import copy
import hashlib
import json
import sys
from collections import defaultdict
from pathlib import Path
from build_gen2_catalog import lua
from build_gen2_reuse_plan import plain
ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT.parent / '.work/hd-beta-deps'))
from lupa.luajit21 import LuaRuntime

plan = json.loads((ROOT / 'metadata/rse-art-plan.json').read_text())
source = plain(LuaRuntime().execute((ROOT / 'metadata/distribution.lua').read_text()))
metadata, entries = {}, []
aspects = set(plan['aspects'])
groups = defaultdict(lambda: defaultdict(dict))
for entry in source['compositions']:
    if entry['environment'] in plan['reuse_candidates']:
        groups[entry['environment']][entry['variation']][entry['aspect_ratio']] = entry

def include(key):
    if key in metadata:
        return
    metadata[key] = copy.deepcopy(source['metadata'][key])
    if metadata[key].get('inherits'):
        include(metadata[key]['inherits'])

for family, variants in sorted(groups.items()):
    complete = [number for number, values in variants.items() if set(values) == aspects]
    if not complete:
        raise ValueError('No complete reuse variation: ' + family)
    for entry in variants[min(complete)].values():
        include(entry['metadata'])
        if entry.get('night_metadata'):
            include(entry['night_metadata'])
        entries.append(copy.deepcopy(entry))

bindings = json.loads((ROOT / 'metadata/rse-mound-bindings.json').read_text())['families']
records = {}
for path in sorted((ROOT / 'art/gen3').glob('*/*/*.authoring.json')):
    record = json.loads(path.read_text())
    assert hashlib.sha256((ROOT / record['background']).read_bytes()).hexdigest() == record['sha256']
    if record['composition_id'] in records:
        raise ValueError('Duplicate source composition: ' + record['composition_id'])
    records[record['composition_id']] = record

def geometry(record):
    aspect = record['aspect_ratio']
    template = ('meadow-perspective-32x9' if aspect == '32:9' else
                'meadow-perspective-9x16' if aspect.startswith('9:') else 'meadow-perspective-16x9')
    include(template)
    result = {key: copy.deepcopy(record[key]) for key in ('schema_version', 'composition_id',
              'reference_size', 'aspect_ratio', 'horizon_y', 'depth', 'safe_area', 'player', 'opponent')}
    result['inherits'] = template
    return result

for family in plan['complete_day_night_source_families']:
    # Source coverage alone does not enable a family: mound review opts it in.
    if family not in bindings:
        continue
    binding = bindings[family]
    for record in sorted(records.values(), key=lambda r: r['composition_id']):
        if Path(record['background']).parent.name != family or record['time_of_day'] != 'day':
            continue
        identifier = record['composition_id']
        night = records[identifier + '-night']
        metadata[identifier], metadata[night['composition_id']] = geometry(record), geometry(night)
        entries.append({'id': identifier, 'environment': family, 'variation': 1,
                        'aspect_ratio': record['aspect_ratio'], 'quality': 'HD', 'metadata': identifier,
                        'night_metadata': night['composition_id'], 'background': record['background'],
                        'backgrounds': {'day': record['background'], 'night': night['background']},
                        'mounds': {side: binding['day'] for side in ('player', 'opponent')},
                        'night_mounds': {side: binding['night'] for side in ('player', 'opponent')}})
# Ambient artwork is protected from outdoor weather by explicit climate policy.
for family in plan.get('complete_ambient_source_families', []):
    if family not in bindings:
        continue
    binding = bindings[family]
    for record in sorted(records.values(), key=lambda r: r['composition_id']):
        if Path(record['background']).parent.name != family or record['time_of_day'] != 'indoor':
            continue
        identifier = record['composition_id']
        metadata[identifier] = geometry(record)
        entries.append({'id': identifier, 'environment': family, 'variation': 1,
                        'aspect_ratio': record['aspect_ratio'], 'quality': 'HD', 'metadata': identifier,
                        'background': record['background'],
                        'mounds': {side: binding['ambient'] for side in ('player', 'opponent')}})
for entry in entries:
    paths = [entry['background']]
    for field in ('backgrounds', 'mounds', 'night_mounds'):
        paths.extend(entry.get(field, {}).values())
    assert all((ROOT / path).is_file() for path in paths), entry['id']
families = {e['environment'] for e in entries}
for family in families:
    assert {e['aspect_ratio'] for e in entries if e['environment'] == family} == aspects
result = {'stage': 'Hoenn integration candidate; remaining environments and gameplay calibration pending',
          'metadata': metadata, 'compositions': sorted(entries, key=lambda e: e['id'])}
(ROOT / 'metadata/rse.lua').write_text('-- Generated by tools/build_rse_catalog.py.\nreturn ' + lua(result) + '\n')
print(json.dumps({'families': len(families), 'compositions': len(entries), 'gameplay_validated': False}))
