import os,subprocess
from pathlib import Path
root=Path(__file__).resolve().parents[1]
error=root/'docs/evidence/network-runtime-error.txt';error.unlink(missing_ok=True)
(root/'docs/evidence/network-runtime-probe.json').unlink(missing_ok=True)
result=subprocess.run([str(root.parent/'.tools/love-audio-runtime/love-probe.exe'),str(root/'tools/network_probe')],env={**os.environ,'HDB_WORKSPACE':str(root.parent),'HDB_RUNTIME_VERSION':os.environ.get('HDB_RUNTIME_VERSION','0.3.95')},timeout=650,capture_output=True,text=True)
print(result.stdout,result.stderr)
if error.exists():print(error.read_text());raise SystemExit(1)
assert result.returncode==0
print((root/'docs/evidence/network-runtime-probe.json').read_text())
