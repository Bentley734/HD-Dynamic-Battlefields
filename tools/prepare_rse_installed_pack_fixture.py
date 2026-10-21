"""Prepare and import a small isolated offline water pack; no remote requests."""
import hashlib
import json
import subprocess
import sys
import zipfile
from pathlib import Path
from build_source_asset_packs import plain

ROOT = Path(__file__).resolve().parents[1]
from lupa.luajit21 import LuaRuntime

folder = ROOT.parent / '.work/hdb-pack'
folder.mkdir(parents=True, exist_ok=True)
assert not (folder / 'fixture.json').exists(), 'Fixture already prepared; reuse it'
catalog = plain(LuaRuntime().execute((ROOT / 'metadata/rse.lua').read_text()))
entry = next(e for e in catalog['compositions'] if e['environment'] == 'ocean' and e['aspect_ratio'] == '16:9')
metadata = {}
def include(key):
    if key in metadata:
        return
    metadata[key] = catalog['metadata'][key]
    if metadata[key].get('inherits'):
        include(metadata[key]['inherits'])
include(entry['metadata'])
if entry.get('night_metadata'):
    include(entry['night_metadata'])
paths = {entry['background']}
for field in ('backgrounds', 'mounds', 'night_mounds'):
    paths.update(entry.get(field, {}).values())
payload = {path: (ROOT / path).read_bytes() for path in paths}
payload['compositions.json'] = json.dumps({'metadata': metadata, 'compositions': [entry]}, separators=(',', ':')).encode()
archive = folder / 'water-fixture.zip'
with zipfile.ZipFile(archive, 'w', zipfile.ZIP_DEFLATED) as z:
    for path, data in sorted(payload.items()):
        z.writestr(path, data)
sha = lambda data: hashlib.sha256(data).hexdigest()
pack = {'schema_version': 1, 'metadata_schema': 1, 'id': 'water-offline-fixture',
        'version': '0.3.0-candidate.2', 'game_version': '>=0.3.95 <0.4.0',
        'quality': 'HD', 'aspects': ['16:9'], 'environments': ['ocean'], 'variation_profile': 'one',
        'files': [{'path': path, 'size': len(data), 'sha256': sha(data),
                   'url': 'https://github.com/Bentley734/HD-Dynamic-Battlefields/releases/download/fixture/' + Path(path).name}
                  for path, data in sorted(payload.items())],
        'installed_size': sum(map(len, payload.values())),
        'offline_archive': {'size': archive.stat().st_size, 'sha256': sha(archive.read_bytes())}}
manifest = folder / 'pack.json'
manifest.write_text(json.dumps(pack, indent=2) + '\n')
cache = folder / 'mod_cache/hd-dynamic-battlefields'
subprocess.run([sys.executable, str(ROOT / 'tools/install_offline_pack.py'), '--archive', str(archive),
                '--manifest', str(manifest), '--cache', str(cache)], check=True)
fixture = {'pack_id': pack['id'], 'cache': str(cache.resolve()),
           'hidden_bundled_backgrounds': sorted({entry['background'], *entry.get('backgrounds', {}).values()}),
           'mounds': entry['mounds'], 'night_mounds': entry.get('night_mounds', {}),
           'scope': 'Isolated offline fixture only. Placeholder download URLs are never requested. No real user cache or remote release modified.'}
(folder / 'fixture.json').write_text(json.dumps(fixture, indent=2) + '\n')
print(json.dumps({'fixture': str(folder), 'files': len(payload), 'bytes': pack['installed_size'], 'uploaded': False}))

