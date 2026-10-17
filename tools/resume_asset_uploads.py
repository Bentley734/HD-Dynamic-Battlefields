"""Resume immutable release shards with explicit bounded rate-limit backoff."""
import argparse,subprocess,sys,time
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--build',type=Path,required=True);p.add_argument('--target',required=True);p.add_argument('--initial-delay',type=int,default=300);a=p.parse_args()
root=Path(__file__).resolve().parents[1]
print('Waiting before resuming remaining GitHub uploads',flush=True);time.sleep(a.initial_delay)
for folder in sorted(x for x in a.build.iterdir()if x.is_dir()):
 if(folder/'published-verification.json').exists():continue
 for attempt in range(7):
  result=subprocess.run([sys.executable,str(root/'tools/publish_asset_packs.py'),'--build',str(folder),'--repository','Bentley734/HD-Dynamic-Battlefields','--tag','v0.1.0-beta.1-assets-'+folder.name,'--target',a.target],capture_output=True,text=True)
  print(result.stdout,flush=True)
  if result.returncode==0:break
  print(result.stderr,flush=True)
  if 'rate limit'not in result.stderr.lower()or attempt==6:raise SystemExit(result.returncode)
  delay=min(900,300*(attempt+1));print('GitHub rate limit; retry in '+str(delay)+' seconds',flush=True);time.sleep(delay)
print('All nine artwork releases verified',flush=True)
