"""Copy a visually reviewed original PNG into a Gen 2/3 authoring collection.

This registers a source candidate, not a runtime composition. It never edits
pixels or overwrites a prior painting. Runtime calibration remains explicit.
"""
import argparse
import hashlib
import json
import re
import shutil
import struct
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ASPECTS = {'4x3', '16x9', '16x10', '3x2', '21x9', '32x9', '9x16', '9x19_5', '9x20'}

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--source', required=True, type=Path)
    parser.add_argument('--generation', default=2, type=int, choices=[2, 3],
                        help='Authoring folder; existing Gen 2 imports retain their default')
    parser.add_argument('--metadata-only', action='store_true',
                        help='Register an existing original in its final path without touching its pixels')
    parser.add_argument('--family', required=True)
    parser.add_argument('--aspect', default='16x9', choices=sorted(ASPECTS))
    parser.add_argument('--variation', default=1, type=int)
    parser.add_argument('--time-of-day', default='indoor', choices=['indoor', 'day', 'night'])
    parser.add_argument('--horizon', required=True, type=float)
    parser.add_argument('--mound', action='append', required=True)
    args = parser.parse_args()
    if not re.fullmatch(r'[a-z][a-z0-9_]*', args.family):
        parser.error('Family must be a lowercase asset identifier')
    if args.variation < 1 or not 0 < args.horizon < 1:
        parser.error('Variation and normalized horizon must be positive')
    data = args.source.read_bytes()
    if data[:8] != b'\x89PNG\r\n\x1a\n' or data[12:16] != b'IHDR':
        parser.error('Expected an original PNG source')
    width, height = struct.unpack('>II', data[16:24])
    aw, ah = [float(v.replace('_', '.')) for v in args.aspect.split('x')]
    if height == 0 or abs((width / height) / (aw / ah) - 1) > .02:
        parser.error(f'PNG dimensions {width}x{height} do not match {args.aspect}; recompose rather than stretch')
    for material in args.mound:
        if not re.fullmatch(r'[a-z0-9-]+', material) or not (ROOT / 'art/mounds' / material).is_dir():
            parser.error('Unknown existing mound material: ' + material)
    name = f'{args.family}-{args.variation:02d}-{args.aspect}'
    if args.time_of_day == 'night':
        name += '-night'
    folder = ROOT / f'art/gen{args.generation}' / args.aspect / args.family
    target = folder / (name + '.png')
    metadata_path = folder / (name + '.authoring.json')
    prompt = folder / 'prompts' / (name + '.txt')
    if args.metadata_only and (not target.is_file() or args.source.resolve() != target.resolve()):
        parser.error('Metadata-only mode requires the original already at its exact final path')
    if (target.exists() and not args.metadata_only) or metadata_path.exists():
        parser.error('Candidate already exists; preserve it and choose a new variation')
    if not prompt.is_file() or not prompt.read_text(encoding='utf-8').strip():
        parser.error('Persist the exact generation prompt before importing')
    draft = {
        'schema_version': 1, 'composition_id': name,
        'status': 'source_candidate_not_runtime_calibrated',
        'reference_size': {'width': width, 'height': height},
        'aspect_ratio': args.aspect.replace('x', ':').replace('_', '.'),
        'time_of_day': args.time_of_day,
        'horizon_y': args.horizon,
        'background': target.relative_to(ROOT).as_posix(),
        'sha256': hashlib.sha256(data).hexdigest(),
        'mound_material_candidates': args.mound,
        'limitations': ['Visual authoring review only; not registered in runtime catalog.',
                        'Mound fit, safe regions, depths and anchors are draft values pending gameplay calibration.'],
    }
    # Shared starting perspective; never presented as verified placement.
    # All anchors remain draft values requiring gameplay calibration.
    if args.aspect in {'16x9', '4x3', '16x10', '3x2'}:
        draft.update(depth={'player': 1, 'opponent': .75},
                     safe_area={'left': .06, 'top': .07, 'right': .94, 'bottom': .76},
                     player={'mound_anchor': [.28, .66], 'pokemon_ground_anchor': [.28, .64],
                             'mound_scale': 1, 'shadow_offset': [0, .008], 'layer': 20},
                     opponent={'mound_anchor': [.72, .45], 'pokemon_ground_anchor': [.72, .43],
                               'mound_scale': .75, 'shadow_offset': [0, .008], 'layer': 10})
    elif args.aspect == '32x9':
        draft.update(depth={'player': 1, 'opponent': .75},
                     safe_area={'left': .04, 'top': .06, 'right': .96, 'bottom': .76},
                     player={'mound_anchor': [.35, .66], 'pokemon_ground_anchor': [.35, .64],
                             'mound_scale': 1, 'shadow_offset': [0, .008], 'layer': 20},
                     opponent={'mound_anchor': [.65, .45], 'pokemon_ground_anchor': [.65, .43],
                               'mound_scale': .75, 'shadow_offset': [0, .008], 'layer': 10})
    elif args.aspect == '21x9':
        draft.update(depth={'player': 1, 'opponent': .75},
                     safe_area={'left': .05, 'top': .06, 'right': .95, 'bottom': .76},
                     player={'mound_anchor': [.30, .66], 'pokemon_ground_anchor': [.30, .64],
                             'mound_scale': 1, 'shadow_offset': [0, .008], 'layer': 20},
                     opponent={'mound_anchor': [.70, .45], 'pokemon_ground_anchor': [.70, .43],
                               'mound_scale': .75, 'shadow_offset': [0, .008], 'layer': 10})
    elif args.aspect in {'9x16', '9x19_5', '9x20'}:
        draft.update(depth={'player': 1, 'opponent': .75},
                     safe_area={'left': .06, 'top': .06, 'right': .94, 'bottom': .76},
                     player={'mound_anchor': [.32, .67], 'pokemon_ground_anchor': [.32, .65],
                             'mound_scale': 1, 'shadow_offset': [0, .008], 'layer': 20},
                     opponent={'mound_anchor': [.68, .45], 'pokemon_ground_anchor': [.68, .43],
                               'mound_scale': .75, 'shadow_offset': [0, .008], 'layer': 10})
    else:
        draft['limitations'].append('Aspect-specific anchor metadata has not been authored yet.')
    if not args.metadata_only:
        shutil.copy2(args.source, target)
    metadata_path.write_text(json.dumps(draft, indent=2) + '\n', encoding='utf-8')
    print(target.relative_to(ROOT).as_posix())

if __name__ == '__main__':
    main()
