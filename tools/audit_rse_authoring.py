"""Inventory source integrity and remaining Hoenn authoring decisions.

This is not gameplay, visual pairing or compatibility certification. Candidate
materials are reported without automatically opting them into the catalog.
"""
import hashlib
import json
import struct
from collections import defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def main():
    plan = json.loads((ROOT / 'metadata/rse-art-plan.json').read_text())
    bindings = json.loads((ROOT / 'metadata/rse-mound-bindings.json').read_text())['families']
    records = defaultdict(list)
    errors, identifiers, ignored = [], set(), 0
    for family, binding in bindings.items():
        for period, asset in binding.items():
            if not (ROOT / asset).is_file():
                errors.append({'family': family, 'period': period,
                               'error': 'missing bound mound', 'asset': asset})
    for path in sorted((ROOT / 'art/gen3').glob('*/*/*.authoring.json')):
        if path.relative_to(ROOT / 'art/gen3').parts[0] == 'drafts':
            ignored += 1
            continue
        record = json.loads(path.read_text())
        identifier = record['composition_id']
        if identifier in identifiers:
            errors.append({'source': str(path.relative_to(ROOT)), 'error': 'duplicate identifier'})
        identifiers.add(identifier)
        image = ROOT / record['background']
        prompt = path.parent / 'prompts' / (identifier + '.txt')
        if not image.is_file():
            errors.append({'source': identifier, 'error': 'missing image'})
            continue
        data = image.read_bytes()
        if data[:8] != b'\x89PNG\r\n\x1a\n':
            errors.append({'source': identifier, 'error': 'invalid PNG header'})
            continue
        width, height = struct.unpack('>II', data[16:24])
        if {'width': width, 'height': height} != record['reference_size']:
            errors.append({'source': identifier, 'error': 'reference dimensions mismatch'})
        if hashlib.sha256(data).hexdigest() != record['sha256']:
            errors.append({'source': identifier, 'error': 'image checksum mismatch'})
        aw, ah = map(float, record['aspect_ratio'].split(':'))
        if abs((width / height) / (aw / ah) - 1) > .02:
            errors.append({'source': identifier, 'error': 'aspect mismatch'})
        if not prompt.is_file() or not prompt.read_text(encoding='utf-8').strip():
            errors.append({'source': identifier, 'error': 'missing exact prompt'})
        records[path.parent.name].append(record)

    families = {}
    for family in sorted(plan['new_or_incomplete_families']):
        sources = records[family]
        periods = sorted({r['time_of_day'] for r in sources})
        materials = sorted({m for r in sources for m in r['mound_material_candidates']})
        candidates = {}
        for material in materials:
            folder = ROOT / 'art/mounds' / material
            candidates[material] = {
                'all_assets': [p.relative_to(ROOT).as_posix() for p in sorted(folder.glob('*.png'))],
                'clean_assets': [p.relative_to(ROOT).as_posix() for p in sorted(folder.glob('*clean*.png'))],
                'night_assets': [p.relative_to(ROOT).as_posix() for p in sorted(folder.glob('*night*.png'))],
            }
            if not folder.is_dir():
                errors.append({'family': family, 'error': 'missing material directory', 'material': material})
        coverage = {period: sorted({r['aspect_ratio'] for r in sources if r['time_of_day'] == period}) for period in periods}
        clearance = [{'composition': r['composition_id'], 'horizon_y': r['horizon_y'],
                      'opponent_ground_y': r['opponent']['pokemon_ground_anchor'][1]}
                     for r in sources if r['opponent']['pokemon_ground_anchor'][1] - r['horizon_y'] < .10]
        families[family] = {
            'source_count': len(sources), 'coverage': coverage,
            'binding': bindings.get(family),
            'candidate_materials': candidates,
            'review_close_rear_boundary': clearance,
            'maps': [{'game': row['game'], 'map': row['native_name'],
                      'land': row['land'], 'water': row['water']}
                     for row in plan['maps'] if family in [row['land'], row['water'], *row['terrain_overrides'].values()]],
            'status': 'candidate pairing and native calibration pending',
        }
    report = {
        'schema_version': 1,
        'scope': 'Source integrity and authoring queue only; no visual, gameplay or compatibility certification.',
        'source_count': sum(len(v) for v in records.values()),
        'ignored_draft_metadata': ignored,
        'missing_base_sources': plan['minimum_missing_base_sources'],
        'unbound_families': sorted(f for f in families if f not in bindings),
        'outdoor_families_without_candidate_night_mound': sorted(
            f for f, value in families.items() if 'night' in value['coverage']
            and not any(c['night_assets'] for c in value['candidate_materials'].values())),
        'errors': errors, 'families': families,
    }
    target = ROOT / 'docs/evidence/rse/authoring-readiness.json'
    target.write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps({key: report[key] for key in ('source_count', 'ignored_draft_metadata',
          'missing_base_sources', 'unbound_families', 'outdoor_families_without_candidate_night_mound', 'errors')}))


if __name__ == '__main__':
    main()
