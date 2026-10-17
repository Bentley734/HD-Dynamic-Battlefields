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
files={}
for path in sorted(root.rglob('*')):
 if not path.is_file():continue
 rel=path.relative_to(root);name=rel.as_posix()
 if any(v.startswith('.')or v in ['__pycache__','dist'] for v in rel.parts):continue
 if rel.parts[:2]==('art','source')and name not in art:continue
 if rel.parts[:2]==('art','prompts'):continue
 if rel.parts[:2]==('docs','evidence')and path.suffix=='.png':continue
 if path.suffix not in ['.lua','.json','.md','.txt','.py','.png']:continue
 files[name]=path
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
