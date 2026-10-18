"""Build a verified offline archive from a repository checkout and pack descriptor.

Pass the resulting archive and descriptor to install_offline_pack.py.
"""
import argparse
import hashlib
import json
import zipfile
from pathlib import Path
from urllib.parse import urlsplit

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--source', type=Path, required=True)
p.add_argument('--manifest', type=Path, required=True)
p.add_argument('--output', type=Path, required=True)
a = p.parse_args()
root = a.source.resolve()
pack = json.loads(a.manifest.read_text())
a.output.mkdir(parents=True, exist_ok=True)
archive = a.output / (pack['id'] + '.zip')
if archive.exists():
    p.error('Output archive already exists')
verified = []
for item in pack['files']:
    url = urlsplit(item['url'])
    parts = url.path.strip('/').split('/')
    if url.hostname != 'raw.githubusercontent.com' or len(parts) < 4:
        p.error('Expected commit-pinned repository source URLs')
    source = (root / '/'.join(parts[3:])).resolve()
    source.relative_to(root)
    data = source.read_bytes()
    if len(data) != item['size'] or hashlib.sha256(data).hexdigest() != item['sha256']:
        p.error('Source checksum mismatch: ' + str(source))
    verified.append((item['path'], source))
with zipfile.ZipFile(archive, 'x', zipfile.ZIP_DEFLATED) as z:
    for name, source in verified:
        z.write(source, name)
pack['offline_archive'] = {'size': archive.stat().st_size,
                           'sha256': hashlib.sha256(archive.read_bytes()).hexdigest()}
descriptor = a.output / (pack['id'] + '.pack.json')
descriptor.write_text(json.dumps(pack, indent=2) + '\n')
print(json.dumps({'archive': str(archive), 'manifest': str(descriptor)}))
