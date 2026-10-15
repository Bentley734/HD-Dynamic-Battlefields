import os, subprocess
from pathlib import Path
project=Path(__file__).resolve().parents[1]
workspace=project.parent
error=project/'docs/evidence/standalone-runtime-error.txt'
error.unlink(missing_ok=True)
result=subprocess.run([str(workspace/'.tools/love-audio-runtime/love-probe.exe'),str(project/'tools/standalone_probe')],env={**os.environ,'HDB_WORKSPACE':str(workspace)},timeout=45,capture_output=True,text=True)
print(result.stdout,result.stderr)
if result.returncode:
 if error.exists(): print(error.read_text())
 raise SystemExit(result.returncode)
print((project/'docs/evidence/standalone-runtime-probe.txt').read_text())
