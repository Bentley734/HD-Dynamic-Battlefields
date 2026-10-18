"""Verify the published immutable source tree and sample HTTP bytes for every pack."""
import argparse
import concurrent.futures
import hashlib
import json
import subprocess
import time
import urllib.request
from pathlib import Path

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--index', type=Path, required=True)
a = p.parse_args()
root = Path(__file__).resolve().parents[1]
index = json.loads(a.index.read_text())
repo = index['repository']
files = {f['url']: f for pack in index['packs'] for f in pack['files']}
commits = {url.split('/')[5] for url in files}
assert len(commits) == 1
commit = commits.pop()
remote = json.loads(subprocess.check_output(
    ['gh', 'api', f'repos/{repo}/git/trees/{commit}?recursive=1'], text=True))
assert not remote['truncated']
tree = {v['path']: v for v in remote['tree'] if v['type'] == 'blob'}
for url, item in files.items():
    relative = '/'.join(url.split('/')[6:])
    data = (root / relative).read_bytes()
    assert len(data) == item['size'] and hashlib.sha256(data).hexdigest() == item['sha256']
    assert tree[relative]['sha'] == hashlib.sha1(b'blob ' + str(len(data)).encode() + b'\0' + data).hexdigest()
samples = {}
for pack in index['packs']:
    for item in [next(f for f in pack['files'] if f['path'] == 'compositions.json'),
                 next(f for f in pack['files'] if f['path'].endswith('.png'))]:
        samples[item['url']] = item

def check(pair):
    url, item = pair
    for attempt in range(4):
        try:
            with urllib.request.urlopen(url, timeout=60) as response:
                data = response.read()
            assert len(data) == item['size'] and hashlib.sha256(data).hexdigest() == item['sha256'], url
            return url
        except Exception:
            if attempt == 3:
                raise
            time.sleep(2)

with concurrent.futures.ThreadPoolExecutor(max_workers=6) as pool:
    checked = list(pool.map(check, samples.items()))
report = {'verified': True, 'repository': repo, 'source_commit': commit,
          'remote_commit_verified': True, 'files_verified_against_remote_git_tree': len(files),
          'http_samples_verified': len(checked), 'packs': len(index['packs']),
          'index_sha256': hashlib.sha256(a.index.read_bytes()).hexdigest()}
(root / 'docs/evidence/source-artwork-verification.json').write_text(json.dumps(report, indent=2) + '\n')
print(json.dumps(report))
