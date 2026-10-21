"""Build a lightweight install with one original wide fallback environment."""
import argparse,hashlib,json,sys,zipfile
from pathlib import Path
root=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(root.parent/'.work/hd-beta-deps'))
from lupa.luajit21 import LuaRuntime
p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);args=p.parse_args()
version=json.loads((root/'manifest.json').read_text())['version']
cat=LuaRuntime().execute((root/'metadata/prototype.lua').read_text())
art=set()
for _,entry in cat.compositions.items():
 if entry.environment=='grassland'and entry.variation==1 and entry.aspect_ratio=='16:9':
  art.add(entry.background)
  for field in ['backgrounds','mounds','night_mounds']:
   if entry[field]:art.update(v for _,v in entry[field].items())
assert len(art)>=4
args.output.mkdir(parents=True,exist_ok=True)
target=args.output/f'HD-Dynamic-Battlefields-{version}-base.zip'
assert not target.exists()
# Explicit shipping boundaries keep authoring records, evidence and pack catalogs
# in the source repository without copying them into the base installation.
shipping_docs={
 'COMPATIBILITY.md','OFFLINE-ASSET-INSTALL.md','SOURCE-ASSET-DISTRIBUTION.md',
 'ASSET-PACK-CHOICES.md','SPRITE-POSITION-CONTROLS.md','TIME-OF-DAY.md','HOENN-BETA.md',
}
files={name:root/name for name in ['main.lua','manifest.json','README.md','tools/install_offline_pack.py']}
for directory in ['lib','metadata']:
 for path in sorted((root/directory).rglob('*.lua')):
  if not any(part.startswith('.') for part in path.relative_to(root).parts):
   files[path.relative_to(root).as_posix()]=path
for name in sorted(shipping_docs):
 files['docs/'+name]=root/'docs'/name
for name in sorted(art):
 files[name]=root/name
for name,path in files.items():
 assert path.is_file(),f'Missing shipping file: {name}'
inventory=[]
with zipfile.ZipFile(target,'w',zipfile.ZIP_DEFLATED,compresslevel=6)as z:
 for name,path in files.items():
  data=path.read_bytes();inventory.append({'path':name,'size':len(data),'sha256':hashlib.sha256(data).hexdigest()})
  z.writestr('hd-dynamic-battlefields/'+name,data)
 z.writestr('hd-dynamic-battlefields/RELEASE-FILES.json',json.dumps(inventory,indent=2))
with zipfile.ZipFile(target)as z:
 assert z.testzip()is None
 for item in inventory:assert hashlib.sha256(z.read('hd-dynamic-battlefields/'+item['path'])).hexdigest()==item['sha256']
print(json.dumps({'file':str(target),'bytes':target.stat().st_size,'sha256':hashlib.sha256(target.read_bytes()).hexdigest(),'fallback_assets':sorted(art)}))
