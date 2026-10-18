"""Prepare catalog-verified 1025Dex artwork for the isolated Hoenn fixture."""
import argparse,hashlib,json,re,zipfile
from pathlib import Path
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--zip',type=Path,required=True)
p.add_argument('--dex-root',type=Path,required=True)
p.add_argument('--output',type=Path,required=True)
a=p.parse_args();a.output.mkdir(parents=True,exist_ok=True)
rows=re.findall(r'\["([^"\n]+)"\] = \{size=(\d+),sha256="([a-f0-9]+)"\}',(a.dex_root/'compat/asset_catalog.lua').read_text())
assert rows,'Empty catalog'
with zipfile.ZipFile(a.zip) as z:
 for name,size,digest in rows:
  dest=(a.output/name).resolve();assert dest.is_relative_to(a.output.resolve())
  b=z.read(name);assert len(b)==int(size) and hashlib.sha256(b).hexdigest()==digest,name
  dest.parent.mkdir(parents=True,exist_ok=True)
  if dest.exists():assert dest.read_bytes()==b,name
  else:dest.write_bytes(b)
receipt={'catalog_files_verified':len(rows),'archive_sha256':hashlib.sha256(a.zip.read_bytes()).hexdigest(),'scope':'Every catalog entry verified; isolated test files only, no user cache modified'}
(a.output/'verification.json').write_text(json.dumps(receipt,indent=2)+'\n');print(json.dumps(receipt))
