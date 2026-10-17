"""Upload a built pack set as a non-latest release, verifying GitHub digests.

Leaves a draft on failure. Never enables a mod catalog or changes game caches.
"""
import argparse
from concurrent.futures import ThreadPoolExecutor
import hashlib
import json
from pathlib import Path
import subprocess

def gh(*args):
    result = subprocess.run(['gh', *map(str, args)], capture_output=True, text=True)
    if result.returncode:
        raise RuntimeError(result.stderr or result.stdout)
    return result.stdout

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--build', type=Path, required=True)
    parser.add_argument('--repository', required=True)
    parser.add_argument('--tag', required=True)
    parser.add_argument('--target', required=True)
    args = parser.parse_args()
    build = args.build.resolve()
    index = json.loads((build / 'asset-index.json').read_text())
    assert index['repository'] == args.repository
    expected = {}
    files = []
    for line in (build / 'SHA256SUMS.txt').read_text().splitlines():
        digest, relative = line.split('  ', 1)
        path = (build / relative).resolve()
        path.relative_to(build)
        assert hashlib.sha256(path.read_bytes()).hexdigest() == digest, relative
        if path.name == 'pack.json':
            continue  # Unique root descriptors are the published offline manifests.
        assert path.name not in expected, path.name
        expected[path.name] = (path.stat().st_size, digest)
        files.append(path)
    sums = build / 'SHA256SUMS.txt'
    expected[sums.name] = (sums.stat().st_size, hashlib.sha256(sums.read_bytes()).hexdigest())
    files.append(sums)
    allowed = set(expected)
    prefix = f'https://github.com/{args.repository}/releases/download/{args.tag}/'
    for pack in index['packs']:
        for entry in pack['files'] + [pack['offline_archive']]:
            assert entry['url'].startswith(prefix) and entry['url'][len(prefix):] in allowed
    existing = subprocess.run(['gh','release','view',args.tag,'--repo',args.repository,'--json','isDraft'], capture_output=True,text=True)
    if existing.returncode == 0:
        assert json.loads(existing.stdout)['isDraft'], 'Refusing to overwrite a published pack release'
    else:
        if '403' in existing.stderr or 'rate limit' in existing.stderr.lower():
            raise RuntimeError(existing.stderr)
        gh('release','create',args.tag,'--repo',args.repository,'--target',args.target,'--draft',
           '--title','HD battlefield artwork packs '+index['version'],
           '--notes','Original HD per-aspect scenery packs. Use the latest mod release for installation instructions. Each pack ZIP needs its matching .pack.json for offline import. Missing environments and other quality tiers remain in development.')
    identity=json.loads(gh('release','view',args.tag,'--repo',args.repository,'--json','databaseId'))
    release_id=identity['databaseId']
    pages=json.loads(gh('api',f'repos/{args.repository}/releases/{release_id}/assets?per_page=100','--paginate','--slurp'))
    uploaded={asset['name']:asset for page in pages for asset in page}
    files=[file for file in files if not(file.name in uploaded and uploaded[file.name]['state']=='uploaded'and uploaded[file.name]['size']==expected[file.name][0]and uploaded[file.name].get('digest')=='sha256:'+expected[file.name][1])]
    batches = [files[i:i+12] for i in range(0,len(files),12)]
    def upload(batch):
        gh('release','upload',args.tag,*batch,'--repo',args.repository,'--clobber')
        print(f'Uploaded {len(batch)} files', flush=True)
    with ThreadPoolExecutor(max_workers=1) as executor:
        list(executor.map(upload,batches))
    release = json.loads(gh('api',f'repos/{args.repository}/releases/{release_id}'))
    assets = json.loads(gh('api',f'repos/{args.repository}/releases/{release["id"]}/assets?per_page=100','--paginate','--slurp'))
    remote = {asset['name']:asset for page in assets for asset in page}
    assert set(remote) == set(expected), 'Remote release file set differs'
    for name,(size,digest) in expected.items():
        asset = remote[name]
        assert asset['state']=='uploaded' and asset['size']==size and asset['digest']=='sha256:'+digest,name
    gh('release','edit',args.tag,'--repo',args.repository,'--draft=false','--latest=false')
    report = {'release':'https://github.com/'+args.repository+'/releases/tag/'+args.tag,'files':len(expected),'bytes':sum(v[0] for v in expected.values()),
              'verification':'GitHub uploaded asset set, sizes and server SHA-256 digests match local files'}
    (build/'published-verification.json').write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps(report),flush=True)

if __name__=='__main__':
    main()
