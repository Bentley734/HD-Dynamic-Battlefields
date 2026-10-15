import os, subprocess
from pathlib import Path
project=Path(__file__).resolve().parents[1]
workspace=project.parent
error=project/'docs/evidence/compatibility-runtime-error.txt'
error.unlink(missing_ok=True)
result=subprocess.run([str(workspace/'.tools/love-audio-runtime/love-probe.exe'),str(project/'tools/compatibility_probe')],env={**os.environ,'HDB_WORKSPACE':str(workspace)},timeout=180,capture_output=True,text=True)
print(result.stdout,result.stderr)
if result.returncode or error.exists():
 if error.exists(): print(error.read_text())
 raise SystemExit(result.returncode or 1)
print((project/'docs/evidence/compatibility-runtime-probe.txt').read_text())
