"""Build and verify a self-contained beta without runtime/ROM/save dependencies."""
import argparse
import hashlib
import json
import sys
from pathlib import Path
import zipfile

project = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(project.parent / '.work/hd-beta-deps'))
parser = argparse.ArgumentParser()
parser.add_argument('--output', required=True, type=Path)
args = parser.parse_args()
args.output.mkdir(parents=True, exist_ok=True)
version = json.loads((project / 'manifest.json').read_text())['version']
target = args.output / f'HD-Dynamic-Battlefields-{version}.zip'
if target.exists():
    parser.error('archive already exists; use a fresh output directory')
# Source-art storage also contains rejected studies and future-generation
# paintings. Ship only artwork actually referenced by the runtime catalog.
from lupa.luajit21 import LuaRuntime
catalog = LuaRuntime().execute((project / 'metadata/prototype.lua').read_text(encoding='utf-8'))
artwork = set()
for _, entry in catalog['compositions'].items():
    artwork.add(entry['background'])
    for field in ('backgrounds', 'mounds', 'night_mounds'):
        if entry[field] is not None:
            artwork.update(value for _, value in entry[field].items())
for relative in artwork:
    path = (project / relative).resolve()
    path.relative_to(project)
    if not path.is_file():
        parser.error(f'Catalog artwork is missing: {relative}')
prompts = {'art/prompts/' + Path(path).stem + '.txt' for path in artwork}
derivatives_path = project / 'art/derivatives.json'
if derivatives_path.is_file():
    sources = {item['file']: item['source'] for item in json.loads(derivatives_path.read_text(encoding='utf-8'))}
    for relative in artwork:
        seen = set()
        while relative in sources:
            if relative in seen:
                parser.error(f'Cyclic artwork provenance: {relative}')
            seen.add(relative)
            relative = sources[relative]
            prompts.add('art/prompts/' + Path(relative).stem + '.txt')
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
    if rel.parts[:2] == ('art', 'source') and rel.as_posix() not in artwork:
        continue
    if rel.parts[:2] == ('art', 'prompts') and rel.as_posix() not in prompts:
        continue
    data = path.read_bytes()
    files.append((rel.as_posix(), path, len(data), hashlib.sha256(data).hexdigest()))

def write(archive, name, data):
    info = zipfile.ZipInfo('hd-dynamic-battlefields/' + name, (1980, 1, 1, 0, 0, 0))
    info.compress_type = zipfile.ZIP_DEFLATED
    info.create_system = 3
    info.external_attr = 0o100644 << 16
    archive.writestr(info, data)

inventory = json.dumps({'version': version, 'files': [
    {'path': name, 'size': size, 'sha256': digest} for name, path, size, digest in files
]}, indent=2).encode()
with zipfile.ZipFile(target, 'w', compression=zipfile.ZIP_DEFLATED, compresslevel=6) as archive:
    for name, path, size, digest in files:
        write(archive, name, path.read_bytes())
    write(archive, 'RELEASE-FILES.json', inventory)
with zipfile.ZipFile(target) as archive:
    assert archive.testzip() is None
    for name, path, size, digest in files:
        actual = archive.read('hd-dynamic-battlefields/' + name)
        assert len(actual) == size and hashlib.sha256(actual).hexdigest() == digest, name
digest = hashlib.sha256(target.read_bytes()).hexdigest()
(args.output / 'SHA256SUMS.txt').write_text(f'{digest}  {target.name}\n', encoding='utf-8')
print(json.dumps({'archive': str(target.resolve()), 'files': len(files) + 1,
                  'bytes': target.stat().st_size, 'sha256': digest}))
