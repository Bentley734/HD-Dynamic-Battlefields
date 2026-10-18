"""Publish a tested base and unified index, verifying every byte before latest."""
import argparse, hashlib, json, subprocess, zipfile
from pathlib import Path

root = Path(__file__).resolve().parents[1]
p = argparse.ArgumentParser()
p.add_argument('--base', type=Path, required=True)
p.add_argument('--index', type=Path, required=True)
p.add_argument('--target', required=True)
a = p.parse_args()
repo = 'Bentley734/HD-Dynamic-Battlefields'
version = json.loads((root/'manifest.json').read_text())['version']
tag = 'v'+version
index = json.loads(a.index.read_text())
proof = json.loads((root/'docs/evidence/source-artwork-verification.json').read_text())
assert proof['verified'] and proof['index_sha256'] == hashlib.sha256(a.index.read_bytes()).hexdigest()
assert proof['repository'] == repo and proof['remote_commit_verified']
assert index['repository'] == repo and len(index['packs']) == 18
seed = (root/'metadata/asset_index.lua').read_bytes()
assert json.dumps(index, separators=(',', ':')).encode() in seed
with zipfile.ZipFile(a.base) as z:
    assert z.testzip() is None
    assert z.read('hd-dynamic-battlefields/metadata/asset_index.lua') == seed
    assert z.read('hd-dynamic-battlefields/manifest.json') == (root/'manifest.json').read_bytes()
assert a.base.stat().st_size < 100*1024*1024

def gh(*args):
    r = subprocess.run(['gh', *map(str, args)], capture_output=True, text=True)
    if r.returncode:
        raise RuntimeError(r.stderr)
    return json.loads(r.stdout) if r.stdout.strip() else None

files = [a.base.resolve(), a.index.resolve()]
sums = a.base.parent/'SHA256SUMS.txt'
sums.write_text(''.join(hashlib.sha256(f.read_bytes()).hexdigest()+'  '+f.name+'\n' for f in files))
files.append(sums)
expected = {f.name: (f.stat().st_size, 'sha256:'+hashlib.sha256(f.read_bytes()).hexdigest()) for f in files}
releases = gh('api', f'repos/{repo}/releases?per_page=100', '--paginate', '--slurp')
release = next((r for page in releases for r in page if r['tag_name'] == tag), None)
if release:
    assert release['draft'], 'Refusing to overwrite a published base release'
else:
    release = gh('api', f'repos/{repo}/releases', '--method', 'POST',
                 '-f', 'tag_name='+tag, '-f', 'target_commitish='+a.target,
                 '-F', 'draft=true', '-f', 'name=HD Dynamic Battlefields — '+version,
                 '-f', 'body='+(root/'docs/BETA-RELEASE-NOTES.md').read_text(encoding='utf-8'))
identity = release['id']
pages = gh('api', f'repos/{repo}/releases/{identity}/assets?per_page=100', '--paginate', '--slurp')
remote = {v['name']: v for page in pages for v in page}
assert set(remote) <= set(expected), 'Unexpected existing release assets'
for f in files:
    old = remote.get(f.name)
    if old and old['state'] == 'uploaded' and (old['size'], old.get('digest')) == expected[f.name]:
        continue
    if old:
        gh('api', f'repos/{repo}/releases/assets/{old["id"]}', '--method', 'DELETE')
    gh('api', f'https://uploads.github.com/repos/{repo}/releases/{identity}/assets?name={f.name}',
       '--method', 'POST', '--input', f, '-H', 'Content-Type: application/octet-stream')
pages = gh('api', f'repos/{repo}/releases/{identity}/assets?per_page=100', '--paginate', '--slurp')
remote = {v['name']: v for page in pages for v in page}
assert set(remote) == set(expected)
for name, details in expected.items():
    assert remote[name]['state'] == 'uploaded' and (remote[name]['size'], remote[name]['digest']) == details, name
gh('api', f'repos/{repo}/releases/{identity}', '--method', 'PATCH', '-F', 'draft=false', '-f', 'make_latest=true')
latest = gh('api', f'repos/{repo}/releases/latest')
assert latest['id'] == identity and not latest['draft']
report = {'release': latest['html_url'], 'latest': True, 'assets': expected,
          'verification': 'Exact remote file set, byte lengths and server SHA-256; latest release identity confirmed'}
(a.base.parent/'published-verification.json').write_text(json.dumps(report, indent=2)+'\n')
print(json.dumps(report))
