"""Apply a reviewed, user-authorized crop without resampling or overwriting originals.

Plan entries provide an explicit pixel rectangle and source-space draft geometry.
The resulting authoring record preserves provenance and transforms all anchors.
This is asset preparation, not runtime calibration.
"""
import hashlib
import json
import subprocess
import sys
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]


def main():
    plan = json.loads(Path(sys.argv[1]).read_text(encoding='utf-8'))
    for row in plan:
        source = ROOT / row['source']
        family, aspect = row['family'], row['aspect']
        night = row.get('time_of_day', 'indoor') == 'night'
        stem = f'{family}-01-{aspect}' + ('-night' if night else '')
        generation = row.get('generation', 2)
        if generation not in (2, 3):
            raise ValueError('Unsupported authoring generation')
        folder = ROOT / f'art/gen{generation}' / aspect / family
        target = folder / (stem + '.png')
        metadata = folder / (stem + '.authoring.json')
        prompt = folder / 'prompts' / (stem + '.txt')
        prompt_bytes = (ROOT / row['prompt_source']).read_text(encoding='utf-8')
        if target.exists() or metadata.exists() or (prompt.exists() and prompt.read_text(encoding='utf-8') != prompt_bytes):
            raise ValueError('Refusing to overwrite ' + stem)
        left, top, right, bottom = row['crop_pixels']
        aw, ah = map(float, aspect.replace('_', '.').split('x'))
        with Image.open(source) as original:
            width, height = original.size
            if not (0 <= left < right <= width and 0 <= top < bottom <= height):
                raise ValueError('Crop outside original')
            cw, ch = right-left, bottom-top
            if abs((cw/ch)/(aw/ah)-1) > .002:
                raise ValueError('Crop does not match target ratio')
            def point(p):
                return [(p[0]*width-left)/cw, (p[1]*height-top)/ch]
            geometry = row['source_geometry']
            anchors = {side: {field: point(geometry[side][field])
                       for field in ('mound_anchor', 'pokemon_ground_anchor')}
                       for side in ('player', 'opponent')}
            if any(not (.03 <= p[0] <= .97 and .03 <= p[1] <= .76)
                   for side in anchors.values() for p in side.values()):
                raise ValueError('Crop would remove or crowd a standing anchor')
            horizon = (geometry['horizon_y']*height-top)/ch
            if not 0 < horizon < min(side['pokemon_ground_anchor'][1] for side in anchors.values()):
                raise ValueError('Standing anchor would be behind horizon')
            folder.mkdir(parents=True, exist_ok=True)
            prompt.parent.mkdir(exist_ok=True)
            if not prompt.exists():
                prompt.write_text(prompt_bytes, encoding='utf-8')
            original.crop((left, top, right, bottom)).save(target)
        command = [sys.executable, str(ROOT/'tools/import_gen2_source.py'),
                   '--source', str(target), '--generation', str(generation), '--metadata-only', '--family', family,
                   '--aspect', aspect, '--horizon', str(horizon),
                   '--time-of-day', row.get('time_of_day', 'indoor')]
        for mound in row['mounds']:
            command.extend(['--mound', mound])
        subprocess.run(command, check=True, cwd=ROOT)
        record = json.loads(metadata.read_text())
        for side in anchors:
            record[side].update(anchors[side])
        record['source_processing'] = {
            'operation': 'crop_only_no_resampling',
            'authorization': 'User explicitly approved trimming excess canvas without stretching.',
            'original': row['source'],
            'original_sha256': hashlib.sha256(source.read_bytes()).hexdigest(),
            'original_size': {'width': width, 'height': height},
            'crop_pixels': row['crop_pixels'],
            'source_geometry': geometry,
        }
        metadata.write_text(json.dumps(record, indent=2)+'\n', encoding='utf-8')


if __name__ == '__main__':
    main()
