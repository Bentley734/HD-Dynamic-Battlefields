"""Derive per-aspect release sets without modifying verified pack payloads."""
import argparse,copy,hashlib,json,os,re
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--build',type=Path,required=True);p.add_argument('--output',type=Path,required=True);p.add_argument('--tag-prefix',required=True);a=p.parse_args()
assert re.fullmatch(r'[\w.-]+',a.tag_prefix)
source=a.build.resolve();out=a.output.resolve();out.mkdir(parents=True,exist_ok=True);assert not any(out.iterdir())
index=json.loads((source/'asset-index.json').read_text());merged=copy.deepcopy(index);merged['packs']=[]
groups={}
for original in index['packs']:
 pack=copy.deepcopy(original);slug=re.sub(r'[^a-z0-9]+','-',pack['aspects'][0].lower());tag=a.tag_prefix+'-'+slug
 prefix='https://github.com/'+index['repository']+'/releases/download/'+tag+'/'
 for entry in pack['files']+[pack['offline_archive']]:entry['url']=prefix+entry['url'].rsplit('/',1)[1]
 groups.setdefault((slug,tag),[]).append(pack);merged['packs'].append(pack)
for (slug,tag),packs in groups.items():
 dest=out/slug;dest.mkdir();checks={}
 def record(path):checks[path.relative_to(dest).as_posix()]=hashlib.sha256(path.read_bytes()).hexdigest()
 for pack in packs:
  folder=dest/pack['id'];folder.mkdir()
  for entry in pack['files']:
   name=entry['url'].rsplit('/',1)[1];original=source/pack['id']/name
   assert original.stat().st_size==entry['size'] and hashlib.sha256(original.read_bytes()).hexdigest()==entry['sha256']
   target=folder/name;os.link(original,target);record(target)
  name=pack['offline_archive']['url'].rsplit('/',1)[1];original=source/name
  assert hashlib.sha256(original.read_bytes()).hexdigest()==pack['offline_archive']['sha256']
  os.link(original,dest/name);record(dest/name)
  body=json.dumps(pack,indent=2)+'\n'
  for path in [folder/'pack.json',dest/(pack['id']+'-'+pack['version']+'.pack.json')]:path.write_text(body);record(path)
 sub={**index,'packs':packs};(dest/'asset-index.json').write_text(json.dumps(sub,indent=2)+'\n');record(dest/'asset-index.json')
 (dest/'SHA256SUMS.txt').write_text(''.join(v+'  '+k+'\n'for k,v in sorted(checks.items())))
 count=sum(1 for n in checks if not n.endswith('/pack.json'))+1
 assert count<=1000
 print(json.dumps({'aspect':slug,'tag':tag,'assets':count}))
(out/'asset-index.json').write_text(json.dumps(merged,indent=2)+'\n')
