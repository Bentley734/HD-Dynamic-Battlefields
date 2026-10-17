"""Enable the unified download catalog only after all remote shard assets verify."""
import argparse,hashlib,json,subprocess
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--build',type=Path,required=True);a=p.parse_args()
root=Path(__file__).resolve().parents[1];build=a.build.resolve();index=json.loads((build/'asset-index.json').read_text());repo=index['repository']
reports=[]
for folder in sorted(x for x in build.iterdir()if x.is_dir()):
 proof=folder/'published-verification.json';assert proof.is_file(),'Unpublished shard: '+folder.name
 report=json.loads(proof.read_text());tag=report['release'].rsplit('/',1)[1]
 def gh(*args):return json.loads(subprocess.check_output(['gh',*args],text=True))
 release=gh('api',f'repos/{repo}/releases/tags/{tag}');assert not release['draft']
 pages=gh('api',f'repos/{repo}/releases/{release["id"]}/assets?per_page=100','--paginate','--slurp')
 actual={entry['name']:entry for page in pages for entry in page};expected={}
 for line in(folder/'SHA256SUMS.txt').read_text().splitlines():
  digest,relative=line.split('  ',1);file=(folder/relative).resolve();file.relative_to(folder)
  assert hashlib.sha256(file.read_bytes()).hexdigest()==digest
  if file.name=='pack.json':continue
  expected[file.name]=(file.stat().st_size,digest)
 sums=folder/'SHA256SUMS.txt';expected[sums.name]=(sums.stat().st_size,hashlib.sha256(sums.read_bytes()).hexdigest())
 assert set(actual)==set(expected)
 for name,(size,digest)in expected.items():assert actual[name]['state']=='uploaded'and actual[name]['size']==size and actual[name]['digest']=='sha256:'+digest,name
 reports.append({'tag':tag,'assets':len(actual),'verified':True})
assert len(reports)==9
body=json.dumps(index,separators=(',',':'));assert len(body.encode())<4*1024*1024 and ']===]'not in body
(root/'metadata/asset_index.lua').write_text("-- Published assets verified by tools/activate_published_index.py.\nreturn require('src.link.Json').decode([===["+body+"]===])\n",encoding='utf-8')
(root/'docs/evidence/published-artwork-verification.json').write_text(json.dumps(reports,indent=2)+'\n')
print('Enabled verified unified catalog for all 18 packs across nine published aspect releases.')
