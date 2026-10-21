"""Render all revised ultrawide sources in bounded native GPU processes.

Produces diagnostic sheets, not edited artwork or automatic visual approval.
"""
import hashlib
import json
import shutil
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT.parent / '.work/hd-beta-deps'))
from PIL import Image, ImageDraw

source = json.loads((ROOT / 'docs/evidence/rse/ultrawide-horizon-clearance-crops.json').read_text())
families = sorted({Path(row['result']).parent.name for row in source['crops']})
expected = {row['composition'] for row in source['crops']}
output = ROOT / 'docs/evidence/rse/reviewed/horizon-clearance-v3-batches'
output.mkdir(parents=True, exist_ok=True)
(output / 'results.json').unlink(missing_ok=True)
native = ROOT / 'docs/evidence/rse/loader/native/runtime-v0.3.95/doubles'
observed, checks = set(), []
for start in range(0, len(families), 8):
    batch = families[start:start + 8]
    args = [sys.executable, str(ROOT / 'tools/run_rse_probe.py'), '--game', 'emerald',
            '--size', '5120x1440', '--double', '--all-areas', '--report-name', 'focused-review-summary.json']
    for family in batch:
        args += ['--family', family]
    process = subprocess.run(args, cwd=ROOT, capture_output=True, text=True,
                             creationflags=getattr(subprocess, 'CREATE_NO_WINDOW', 0))
    (output / f'batch-{start // 8 + 1}.log').write_text(process.stdout + process.stderr, encoding='utf-8')
    if process.returncode:
        raise RuntimeError(f'Horizon review batch {start // 8 + 1} failed; see saved log')
    report_path = native / 'emerald-5120x1440-render.json'
    report = json.loads(report_path.read_text())
    shutil.copy2(report_path, output / f'batch-{start // 8 + 1}.json')
    for check in report['checks']:
        if check['metadata'] not in expected:
            continue
        observed.add(check['metadata'])
        image_path = native / f"emerald-5120x1440-{check['environment']}-{check['period']}-current.png"
        assert image_path.is_file()
        target = output / image_path.name
        shutil.copy2(image_path, target)
        checks.append({**check, 'capture': target.name})
    print(f'Batch {start // 8 + 1}: {len(report["checks"])} native scenes passed', flush=True)
assert observed == expected, f'Missing revised sources: {sorted(expected - observed)}'
pages = []
for start in range(0, len(checks), 8):
    sheet = Image.new('RGB', (1920, 1160), (24, 24, 24))
    draw = ImageDraw.Draw(sheet)
    for i, check in enumerate(checks[start:start + 8]):
        x, y = (i % 2) * 960, (i // 2) * 290
        draw.text((x + 8, y + 5), check['metadata'], fill='white')
        with Image.open(output / check['capture']) as im:
            im.thumbnail((960, 270))
            sheet.paste(im, (x, y + 20))
    path = output / f'review-{start // 8 + 1:02}.png'
    sheet.save(path)
    pages.append(path.name)
result = {'runtime': '0.3.95', 'revised_source_count': len(expected), 'checks': checks, 'sheets': pages,
          'source_hashes': {str(p.relative_to(ROOT)): hashlib.sha256(p.read_bytes()).hexdigest()
                            for p in (ROOT / 'metadata/rse.lua', ROOT / 'metadata/mound_materials.lua', ROOT / 'lib/grounding.lua')},
          'scope': 'One representative native map per revised family/period, Emerald doubles at 5120x1440; visual review pending. No exhaustive species, every-map or mobile claim.'}
(output / 'results.json').write_text(json.dumps(result, indent=2) + '\n')
print(f'All {len(expected)} revised sources rendered; {len(pages)} visual sheets ready.')
