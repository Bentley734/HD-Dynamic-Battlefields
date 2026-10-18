"""Fill omitted draft fields in early Gen 2 widescreen authoring records.

Keeps every authored value and every image unchanged. Defaults are explicitly
uncalibrated; this is metadata authoring, not runtime validation.
"""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def main():
    changed = []
    for path in sorted((ROOT / 'art/gen2/16x9').glob('*/*.authoring.json')):
        entry = json.loads(path.read_text(encoding='utf-8'))
        before = json.dumps(entry, sort_keys=True)
        entry.setdefault('time_of_day', 'night' if path.stem.endswith('-night.authoring')
                         else 'day' if path.parent.name == 'tin_tower_roof' else 'indoor')
        entry.setdefault('depth', {'player': 1, 'opponent': .75})
        entry.setdefault('safe_area', {'left': .06, 'top': .07, 'right': .94, 'bottom': .76})
        for side, scale, layer in [('player', 1, 20), ('opponent', .75, 10)]:
            # Never synthesize missing ground coordinates: those require a
            # visual review of the actual painting, as for Sprout Tower.
            side_entry = entry.get(side)
            if side_entry is not None:
                side_entry.setdefault('mound_scale', scale)
                side_entry.setdefault('shadow_offset', [0, .008])
                side_entry.setdefault('layer', layer)
        if json.dumps(entry, sort_keys=True) != before:
            entry.setdefault('limitations', []).append(
                'Omitted depth, safe area or side defaults completed during authoring; all values remain pending gameplay calibration.')
            path.write_text(json.dumps(entry, indent=2) + '\n', encoding='utf-8')
            changed.append(path.relative_to(ROOT).as_posix())
    print(json.dumps({'updated_authoring_records': changed}))


if __name__ == '__main__':
    main()
