"""Check original source integrity/geometry; does not certify gameplay alignment."""
import argparse
import hashlib
import json
import math
import re
from pathlib import Path
from PIL import Image, ImageChops
ROOT = Path(__file__).resolve().parents[1]
ASPECTS = {'4:3', '16:9', '16:10', '3:2', '21:9', '32:9', '9:16', '9:19.5', '9:20'}
p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--generation', type=int, choices=[2, 3], required=True)
p.add_argument('--family', required=True)
p.add_argument('--period', action='append', required=True, choices=['day', 'night', 'indoor'])
p.add_argument('--output', type=Path, required=True)
a = p.parse_args()
if not re.fullmatch('[a-z][a-z0-9_]*', a.family):
    p.error('Expected an asset family identifier')
rows, seen = [], set()
for path in sorted((ROOT / f'art/gen{a.generation}').glob(f'*/{a.family}/*.authoring.json')):
    m = json.loads(path.read_text())
    period, aspect = m['time_of_day'], m['aspect_ratio']
    if period not in a.period:
        continue
    assert (aspect, period) not in seen, 'Multiple variations require separate verification'
    seen.add((aspect, period))
    image = (ROOT / m['background']).resolve(); image.relative_to(ROOT)
    digest = hashlib.sha256(image.read_bytes()).hexdigest()
    assert digest == m['sha256'], image
    with Image.open(image) as im:
        width, height = im.size
        assert (width, height) == (m['reference_size']['width'], m['reference_size']['height'])
        aw, ah = map(float, aspect.split(':'))
        assert abs((width / height) / (aw / ah) - 1) <= .02, image
        for side in ('player', 'opponent'):
            for field in ('pokemon_ground_anchor', 'mound_anchor'):
                x, y = m[side][field]
                assert all(isinstance(v, (float, int)) and math.isfinite(v) for v in (x, y))
                assert .03 <= x <= .97 and m['horizon_y'] < y <= .76, (image, side, field)
        processing = m.get('source_processing')
        if processing:
            assert processing['operation'] == 'crop_only_no_resampling'
            original = (ROOT / processing['original']).resolve();original.relative_to(ROOT)
            assert hashlib.sha256(original.read_bytes()).hexdigest() == processing['original_sha256']
            with Image.open(original) as source:
                crop = source.crop(processing['crop_pixels'])
                assert crop.size == im.size and crop.mode == im.mode
                assert ImageChops.difference(crop, im).getbbox() is None, 'Cropped pixels differ from original'
    with Image.open(image) as checksum_image:
        checksum_image.verify()
    rows.append({'path': m['background'], 'aspect_ratio': aspect, 'period': period,
                 'width': width, 'height': height, 'sha256': digest, 'crop_only': bool(processing)})
assert seen == {(aspect, period) for aspect in ASPECTS for period in a.period}, 'Incomplete aspect/period coverage'
report = {'family': a.family, 'generation': a.generation, 'source_files': len(rows),
          'aspects': len(ASPECTS), 'periods': a.period, 'verified': True,
          'scope': 'Source integrity, dimensions, draft anchor bounds and crop-only pixel provenance. Gameplay/mound contact remains unverified.',
          'files': rows}
a.output.parent.mkdir(parents=True, exist_ok=True)
a.output.write_text(json.dumps(report, indent=2) + '\n')
print(json.dumps({k: v for k, v in report.items() if k != 'files'}))
