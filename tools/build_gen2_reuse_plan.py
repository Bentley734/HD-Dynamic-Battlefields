"""Select one existing Gen 1 variation per Gen 2 reuse family.

Authoring inventory only. References originals, metadata and mound paths without
copying pixels or registering unverified Gen 2 runtime support.
"""
import json
import sys
from collections import defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT.parent / '.work/hd-beta-deps'))
from lupa.luajit21 import LuaRuntime, lua_type

ASPECTS = ['4x3', '16x9', '16x10', '3x2', '21x9', '32x9', '9x16', '9x19_5', '9x20']


def plain(value):
    if lua_type(value) != 'table':
        return value
    keys = list(value.keys())
    if keys and all(isinstance(k, int) for k in keys) and sorted(keys) == list(range(1, len(keys) + 1)):
        return [plain(value[k]) for k in sorted(keys)]
    return {str(k): plain(v) for k, v in value.items()}


def main():
    plan = json.loads((ROOT / 'metadata/gen2-art-plan.json').read_text())
    catalog = plain(LuaRuntime().execute((ROOT / 'metadata/prototype.lua').read_text()))
    families = {row['candidate_art_family'] for row in plan['locations'] if row['asset_action'] == 'reuse'}
    # Include extra surf/fishing families, not just the primary map assignment.
    families.update(family for row in plan['locations'] for family in row['candidate_art_by_encounter'].values()
                    if family not in plan['summary']['new_families'])
    by_family = defaultdict(lambda: defaultdict(dict))
    for entry in catalog['compositions']:
        if entry['environment'] in families:
            aspect = entry['aspect_ratio'].replace(':', 'x').replace('.', '_')
            by_family[entry['environment']][entry['variation']][aspect] = entry
    output = []
    for family in sorted(families):
        variants = by_family[family]
        # Prefer one coherent variation with every aspect, then lowest number.
        ordered = sorted(variants, key=lambda v: (-len(set(variants[v]) & set(ASPECTS)), v))
        variation = ordered[0] if ordered else None
        entries = variants.get(variation, {})
        compositions = []
        missing_files = []
        for aspect in ASPECTS:
            entry = entries.get(aspect)
            if entry is None:
                continue
            paths = [entry['background']]
            for field in ['backgrounds', 'mounds', 'night_mounds']:
                paths.extend(entry.get(field, {}).values())
            missing_files.extend(path for path in paths if not (ROOT / path).is_file())
            compositions.append(entry)
        source_candidates = []
        for aspect in ASPECTS:
            if aspect in entries:
                continue
            # Artwork preserved from the earlier all-location collection can
            # exist without a runtime catalog entry (notably the warehouse).
            sources = []
            for game in ['gen2', 'gen1']:
                folder = ROOT / 'art' / game / aspect / family
                sources.extend(sorted(p for p in folder.glob(f'{family}-*-{aspect}.png')
                                      if '-night' not in p.stem))
            if sources:
                source = sources[0]
                source_candidates.append({'aspect': aspect,
                    'background': source.relative_to(ROOT).as_posix(),
                    'night_background': source.with_stem(source.stem + '-night').relative_to(ROOT).as_posix()
                    if source.with_stem(source.stem + '-night').is_file() else None,
                    'status': 'unregistered_original_pending_location_and_geometry_review'})
        output.append({'family': family, 'variation': variation,
                       'status': 'existing_reference_pending_gen2_calibration',
                       'missing_aspects': [a for a in ASPECTS if a not in entries],
                       'missing_files': sorted(set(missing_files)), 'compositions': compositions,
                       'unregistered_source_candidates': source_candidates})
    metadata_ids = {entry['metadata'] for row in output for entry in row['compositions']}
    # Preserve inheritance so a pack builder cannot detach references from their
    # original calibrated source geometry.
    pending = list(metadata_ids)
    while pending:
        ident = pending.pop()
        parent = catalog['metadata'].get(ident, {}).get('inherits')
        if parent and parent not in metadata_ids:
            metadata_ids.add(parent)
            pending.append(parent)
    result = {'schema': 1, 'stage': 'authoring reuse plan; not runtime integration',
              'policy': 'One coherent existing variation per family; reference originals without duplicate artwork.',
              'summary': {'families': len(output),
                          'compositions': sum(len(row['compositions']) for row in output),
                          'families_missing_aspects': sum(bool(row['missing_aspects']) for row in output),
                          'families_missing_files': sum(bool(row['missing_files']) for row in output),
                          'unregistered_source_candidates': sum(len(row['unregistered_source_candidates']) for row in output),
                          'missing_source_compositions': sum(len(row['missing_aspects']) - len(row['unregistered_source_candidates']) for row in output)},
              'families': output,
              'metadata': {key: catalog['metadata'][key] for key in sorted(metadata_ids)}}
    target = ROOT / 'metadata/gen2-reuse-plan.json'
    target.write_text(json.dumps(result, indent=2) + '\n', encoding='utf-8')
    lines = ['# Gen 2 single-variation reuse inventory', '',
             'References existing Gen 1 artwork and geometry. This inventory establishes file availability, not Gen 2 gameplay correctness. No images are duplicated or altered.', '',
             '| Existing family | Selected variation | Registered compositions | Missing catalog aspects | Saved unregistered originals | Missing referenced files |',
             '|---|---|---|---|---|---|']
    for row in output:
        lines.append(f"| {row['family']} | {row['variation']} | {len(row['compositions'])} | {', '.join(row['missing_aspects']) or 'none'} | {len(row['unregistered_source_candidates'])} | {len(row['missing_files'])} |")
    lines.extend(['', 'The [reference plan](../metadata/gen2-reuse-plan.json) retains composition IDs, original paths, day/night references, mound paths, source rectangles and inherited perspective metadata. Final location assignments and mound grounding remain pending Gen 2 integration and batch gameplay validation.'])
    (ROOT / 'docs/GEN2-REUSE-INVENTORY.md').write_text('\n'.join(lines) + '\n', encoding='utf-8')
    print(json.dumps(result['summary']))


if __name__ == '__main__':
    main()
