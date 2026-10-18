"""Index original Gen 2 source paintings and exact prompts; not runtime coverage."""
import argparse
import json
import struct
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('aspect', choices=['4x3', '16x9', '16x10', '3x2', '21x9', '32x9', '9x16', '9x19_5', '9x20'])
    args = parser.parse_args()
    aspect = args.aspect
    label = aspect.replace('x', ':').replace('_', '.')
    lines = [f'# Gen 2 first-variation {label} source paintings', '',
             'Original built-in ImageGen paintings, recomposed from the first-variation location references. Extra variations are deferred for the initial Gen 2 release. This index describes saved artwork, not runtime support.', '',
             '| Location | Original painting | Exact prompt | Dimensions | Rear scenery junction |',
             '|---|---|---|---|---|']
    missing_metadata = []
    for original in sorted((ROOT / 'art/gen2' / aspect).glob('*/*.png')):
        path = original.with_suffix('.authoring.json')
        entry = json.loads(path.read_text(encoding='utf-8')) if path.is_file() else {}
        image = original.relative_to(ROOT)
        prompt = image.parent / 'prompts' / (image.stem + '.txt')
        width, height = struct.unpack('>II', original.read_bytes()[16:24])
        name = image.parent.name + (' (night)' if image.stem.endswith('-night') else '')
        horizon = f"approximately {entry['horizon_y'] * 100:g}%" if 'horizon_y' in entry else 'authoring metadata pending'
        if not entry:
            missing_metadata.append(image.as_posix())
        lines.append(f"| {name} | [PNG](../{image.as_posix()}) | [Prompt](../{prompt.as_posix()}) | {width} x {height} | {horizon} |")
    if missing_metadata:
        lines.extend(['', f'{len(missing_metadata)} original paintings still need sibling authoring metadata; these rows are explicitly marked above.'])
    lines.extend(['', 'Sibling authoring metadata, where present, records checksums, dimensions and candidate existing mound materials. Perspective anchors are drafts pending runtime calibration. Visual source review does not establish mound fit, safe bounds, runtime registration or gameplay correctness. No gameplay tests are performed by this indexing tool.', '',
                  "Dragon's Den uses a water foreground for separate island mounds. Lugia's chamber uses a dry limestone shelf before its distant pool. Composition corrections, when needed, retain their exact prompts beside the source painting."])
    target = ROOT / 'docs' / ('GEN2-' + aspect.upper() + '-SOURCE-PAINTINGS.md')
    target.write_text('\n'.join(lines) + '\n', encoding='utf-8')
    print(target.relative_to(ROOT).as_posix())

if __name__ == '__main__':
    main()
