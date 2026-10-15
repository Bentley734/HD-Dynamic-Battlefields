"""Build and verify a self-contained alpha without runtime/ROM/save dependencies."""
import argparse
import hashlib
import json
from pathlib import Path
import zipfile

project = Path(__file__).resolve().parents[1]
parser = argparse.ArgumentParser()
parser.add_argument('--output', required=True, type=Path)
args = parser.parse_args()
args.output.mkdir(parents=True, exist_ok=True)
version = json.loads((project / 'manifest.json').read_text())['version']
target = args.output / f'HD-Dynamic-Battlefields-{version}.zip'
if target.exists():
    parser.error('archive already exists; use a fresh output directory')
files = []
for path in sorted(project.rglob('*')):
    if not path.is_file():
        continue
    rel = path.relative_to(project)
    if any(part.startswith('.') or part in ('__pycache__', 'dist') for part in rel.parts):
        continue
    if path.suffix.lower() not in ('.lua', '.json', '.md', '.txt', '.py', '.png'):
        continue
    if rel.parts[:2] == ('docs', 'evidence') and path.suffix == '.png':
        continue
    data = path.read_bytes()
    files.append((rel.as_posix(), data, hashlib.sha256(data).hexdigest()))

def write(archive, name, data):
    info = zipfile.ZipInfo('hd-dynamic-battlefields/' + name, (1980, 1, 1, 0, 0, 0))
    info.compress_type = zipfile.ZIP_DEFLATED
    info.create_system = 3
    info.external_attr = 0o100644 << 16
    archive.writestr(info, data)

inventory = json.dumps({'version': version, 'files': [
    {'path': name, 'size': len(data), 'sha256': digest} for name, data, digest in files
]}, indent=2).encode()
with zipfile.ZipFile(target, 'w', compression=zipfile.ZIP_DEFLATED, compresslevel=6) as archive:
    for name, data, _ in files:
        write(archive, name, data)
    write(archive, 'RELEASE-FILES.json', inventory)
with zipfile.ZipFile(target) as archive:
    assert archive.testzip() is None
    for name, data, digest in files:
        actual = archive.read('hd-dynamic-battlefields/' + name)
        assert len(actual) == len(data) and hashlib.sha256(actual).hexdigest() == digest, name
digest = hashlib.sha256(target.read_bytes()).hexdigest()
(args.output / 'SHA256SUMS.txt').write_text(f'{digest}  {target.name}\n', encoding='utf-8')
print(json.dumps({'archive': str(target.resolve()), 'files': len(files) + 1,
                  'bytes': target.stat().st_size, 'sha256': digest}))
