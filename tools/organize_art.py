"""Organize Gen 1 source images and their prompts without editing any pixels.

Run without --apply to preview; --apply verifies every byte after each move.
The relocation inventory preserves historical paths and checksums.
"""
import argparse, hashlib, json, re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ART = ROOT / 'art'

def destination(filename):
    if filename.startswith('mound-'):
        material = re.match(r'mound-(.+?)-[0-9]+', filename)
        if not material:
            raise ValueError('Unclassified mound: ' + filename)
        return Path('art/mounds') / material[1] / filename
    location = re.match(r'(.+?)-[0-9]+-', filename)
    aspect = re.search(r'-([0-9]+x[0-9]+(?:_[0-9]+)?)', filename)
    if not location or not aspect:
        raise ValueError('Unclassified artwork: ' + filename)
    return Path('art/gen1') / aspect[1] / location[1] / filename

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--apply', action='store_true')
    args = parser.parse_args()
    moves = []
    for source in sorted((ART / 'source').glob('*.png')):
        moves.append((source, ROOT / destination(source.name)))
    for source in sorted((ART / 'prompts').glob('*.txt')):
        target = destination(source.name)
        moves.append((source, ROOT / target.parent / 'prompts' / target.name))
    for source in sorted(ART.glob('*-preview.jpg')):
        moves.append((source, ART / 'previews/mounds' / source.name))
    records = []
    for source, target in moves:
        # Resolve both endpoints before moving any file. All stay in this repo.
        source.resolve().relative_to(ROOT)
        target.resolve().relative_to(ROOT)
        assert source.is_file() and not target.exists(), str(target)
        records.append({'old':source.relative_to(ROOT).as_posix(),
                        'new':target.relative_to(ROOT).as_posix(),
                        'bytes':source.stat().st_size,
                        'sha256':hashlib.sha256(source.read_bytes()).hexdigest()})
    if args.apply and records:
        inventory = ART / 'RELOCATIONS.json'
        assert not inventory.exists(), 'Relocation inventory already exists'
        inventory.write_text(json.dumps(records, indent=2) + '\n')
        for row in records:
            source, target = ROOT / row['old'], ROOT / row['new']
            target.parent.mkdir(parents=True, exist_ok=True)
            source.rename(target)
            assert target.stat().st_size == row['bytes']
            assert hashlib.sha256(target.read_bytes()).hexdigest() == row['sha256']
        for folder in (ART / 'source', ART / 'prompts'):
            if folder.exists() and not any(folder.iterdir()):
                folder.rmdir()
    print(json.dumps({'apply':args.apply, 'files':len(records),
                      'bytes':sum(row['bytes'] for row in records)}))

if __name__ == '__main__':
    main()
