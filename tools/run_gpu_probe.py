import os
import subprocess
from pathlib import Path

project = Path(__file__).resolve().parents[1]
workspace = project.parent
(project / 'docs/evidence').mkdir(exist_ok=True)
error = project / 'docs/evidence/runtime-gpu-error.txt'
error.unlink(missing_ok=True)
result = subprocess.run([
    str(workspace / '.tools/love-audio-runtime/love-probe.exe'),
    str(project / 'tools/gpu_probe'),
], env={**os.environ, 'HDB_WORKSPACE': str(workspace)}, timeout=45, capture_output=True, text=True)
print(result.stdout, result.stderr)
if result.returncode:
    if error.exists():
        print(error.read_text())
    raise SystemExit(result.returncode)
print((project / 'docs/evidence/runtime-gpu-probe.txt').read_text())
