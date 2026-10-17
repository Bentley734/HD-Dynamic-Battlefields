import os, subprocess
from pathlib import Path
project=Path(__file__).resolve().parents[1]
workspace=project.parent
tested_project=Path(os.environ.get('HDB_PROJECT',str(project))).resolve()
game_version=os.environ.get('HDB_GAME_VERSION','red')
assert game_version in ('red','blue','yellow')
evidence=tested_project/'docs/evidence'
if game_version != 'red': evidence=evidence/game_version
error=evidence/'standalone-runtime-error.txt'
report=evidence/'standalone-runtime-probe.txt'
report.parent.mkdir(parents=True,exist_ok=True)
error.unlink(missing_ok=True)
report.unlink(missing_ok=True)
result=subprocess.run([str(workspace/'.tools/love-audio-runtime/love-probe.exe'),str(project/'tools/standalone_probe')],env={**os.environ,'HDB_WORKSPACE':str(workspace)},timeout=45,capture_output=True,text=True)
print(result.stdout,result.stderr)
if result.returncode:
 if error.exists(): print(error.read_text())
 raise SystemExit(result.returncode)
if error.exists():
 print(error.read_text())
 raise SystemExit(1)
assert report.exists(),'Runtime produced no fresh report for '+str(tested_project)
print(report.read_text())
