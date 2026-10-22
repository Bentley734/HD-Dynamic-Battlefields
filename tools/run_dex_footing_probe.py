"""Native 0.3.95 GPU fixture: actual 1025Dex providers; HD mounds only."""
import argparse
import json
import os
from pathlib import Path
import subprocess
ROOT=Path(__file__).resolve().parents[1]
WORKSPACE=ROOT.parent
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--engine',type=Path,default=WORKSPACE/'.work/hd-battlefields-latest/v0.3.95/engine')
p.add_argument('--love',type=Path,default=WORKSPACE/'.tools/love-audio-runtime/love-probe.exe')
p.add_argument('--dex-root',type=Path,default=WORKSPACE/'.work/1025dex-double-fix')
p.add_argument('--mod-root',type=Path,default=ROOT,help='Test an extracted release through the same native fixture')
p.add_argument('--output',type=Path,default=ROOT/'docs/evidence/dex-footing/native-0.3.95')
p.add_argument('--start-index',type=int,default=1,help='Resume after a fixture-only failure using preserved partial evidence')
p.add_argument('--case-limit',type=int,default=100,help='Limit cases; 54 covers all six styles with bundled grass scenery')
a=p.parse_args()
if not 1<=a.case_limit<=100:p.error('--case-limit must be1..100')
if not 1<=a.start_index<=a.case_limit:p.error('--start-index must be within the selected case limit')
save=Path(os.environ['APPDATA'])/'pokemon-love2d'
roots={'hd-dynamic-battlefields':a.mod_root.resolve(),'1025dex':a.dex_root.resolve(),
       '1025dex-bw-sprites':save/'mods/1025dex-bw-sprites','kim1025':save/'mods/kim1025'}
inventory={}
for name,folder in roots.items():
 if not(folder/'manifest.json').is_file():p.error('Missing actual provider: '+str(folder))
 for base,dirs,files in os.walk(folder):
  dirs[:]=[d for d in dirs if not d.startswith('.') and d not in ('dist','docs','__pycache__')]
  rel=Path(base).relative_to(folder).as_posix()
  inventory['mods/'+name+('/'+rel if rel!='.'else'')]=sorted(dirs+files)
inventory['mods/kim1025'].append('dex_footing_provider.lua')
a.output.mkdir(parents=True,exist_ok=True)
inventory_path=a.output/'directory-index.json'
inventory_path.write_text(json.dumps(inventory))
for name in ['footing-report.json','progress.json','emerald-native-error.txt','surface-failure.json']:(a.output/name).unlink(missing_ok=True)
if a.start_index==1:(a.output/'partial-report.json').unlink(missing_ok=True)
env={**os.environ,'HDB_WORKSPACE':str(WORKSPACE),'HDB_GAME_VERSION':'emerald','HDB_RUNTIME_VERSION':'0.3.95',
 'HDB_ENGINE_ROOT':str(a.engine.resolve()),'HDB_SIZE':'1280x720','HDB_RENDER':'1','HDB_LOADER':'1',
 'HDB_CONTENT_MODE':'1025','HDB_MOD_ROOT':str(a.mod_root.resolve()),'HDB_DEX_ROOT':str(a.dex_root.resolve()),
 'HDB_FOOTING_OUTPUT':str(a.output.resolve()),'HDB_INVENTORY_PATH':str(inventory_path.resolve()),
 'HDB_FOOTING_START':str(a.start_index),
 'HDB_FOOTING_LIMIT':str(a.case_limit),
 'HDB_BW_ROOT':str(roots['1025dex-bw-sprites']),'HDB_KIM_ROOT':str(roots['kim1025']),
 'HDB_KIM_CACHE':str(save/'mod_cache/kim1025'),
 'HDB_DEX_RECEIPT_ROOT':str(save/'mod_cache/1025dex'),
 'HDB_DEX_ASSET_ROOT':str(save/'mod_cache/1025dex/dex_assets/files'),
 'HDB_MENU_CUSTOMIZER':'0','HDB_WILDFOLLOWERS':'0','HDB_PREPARE_DEX_ASSETS':'0'}
log=a.output/'process.log'
with log.open('w',encoding='utf-8')as stream:
 process=subprocess.run([str(a.love.resolve()),str(ROOT/'tools/dex_footing_probe')],env=env,
  stdout=stream,stderr=subprocess.STDOUT,timeout=1800,creationflags=getattr(subprocess,'CREATE_NO_WINDOW',0))
error=a.output/'emerald-native-error.txt'
if process.returncode or error.exists():
 raise RuntimeError((error.read_text()if error.exists()else'')+'\n'+log.read_text()[-5000:])
report=json.loads((a.output/'footing-report.json').read_text())
assert report['case_count']==a.case_limit and report['native_sprite_arguments_unchanged']
assert all(r['native_sprite_draws_unchanged']for r in report['cases'])
screenshots={r['screenshot']for r in report['cases']if'screenshot'in r}
screenshots.update(x['screenshot']for r in report['cases']for x in r.get('aspectTransitions',[]))
print(json.dumps({'cases':report['case_count'],'screenshots':len(screenshots),
 'report':str(a.output/'footing-report.json'),'scope':report['limitations']},indent=2))
