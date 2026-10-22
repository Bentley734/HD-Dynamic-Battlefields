"""Isolated actual Gen1/2 GPU sprite-placement regression; never writes real saves."""
import argparse,json,os,subprocess
from pathlib import Path
PROJECT=Path(__file__).resolve().parents[1];WORKSPACE=PROJECT.parent
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--game',choices=['red','crystal'],default='red')
p.add_argument('--output',type=Path,default=WORKSPACE/'.work/1025-footing-audit/native-gb')
a=p.parse_args();out=a.output/a.game;out.mkdir(parents=True,exist_ok=True)
roots={'hd-dynamic-battlefields':PROJECT,'1025dex':WORKSPACE/'.work/1025dex-double-fix'};inventory={}
for name,folder in roots.items():
 for base,dirs,files in os.walk(folder):
  dirs[:]=[d for d in dirs if not d.startswith('.')and d not in('dist','docs','__pycache__')]
  rel=Path(base).relative_to(folder).as_posix();inventory['mods/'+name+('/'+rel if rel!='.'else'')]=sorted(dirs+files)
(out/'directory-index.json').write_text(json.dumps(inventory))
for name in('error.txt','report.json','progress.json'):(out/name).unlink(missing_ok=True)
env={**os.environ,'HDB_WORKSPACE':str(WORKSPACE),'HDB_MOD_ROOT':str(PROJECT),'HDB_GB_OUTPUT':str(out),
 'HDB_GAME_VERSION':a.game,'HDB_ENGINE_ROOT':str(WORKSPACE/'.work/hd-battlefields-latest/v0.3.95/engine'),
 'HDB_DEX_ROOT':str(roots['1025dex']),'HDB_INVENTORY_PATH':str(out/'directory-index.json')}
with(out/'process.log').open('w')as log:
 result=subprocess.run([str(WORKSPACE/'.tools/love-audio-runtime/love-probe.exe'),str(PROJECT/'tools/dex_gb_footing_probe')],
  env=env,stdout=log,stderr=subprocess.STDOUT,timeout=1200,creationflags=getattr(subprocess,'CREATE_NO_WINDOW',0))
if result.returncode or(out/'error.txt').exists():raise RuntimeError((out/'error.txt').read_text()if(out/'error.txt').exists()else(out/'process.log').read_text()[-5000:])
r=json.loads((out/'report.json').read_text());assert r['caseCount']==216
print(json.dumps({'game':a.game,'cases':r['caseCount'],'manager':r['assetManager'],'report':str(out/'report.json')},indent=2))
