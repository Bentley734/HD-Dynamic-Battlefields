"""Inspect original artwork and refresh its checksum/provenance inventory.

Reads pixel headers/alpha only. Never resizes, recolors or edits artwork.
"""
import hashlib
import json
import sys
from pathlib import Path

project = Path(__file__).resolve().parents[1]
from PIL import Image

art = project / 'art'
previous = {row['file']:row for row in json.loads((art/'SOURCES.json').read_text())} if (art/'SOURCES.json').exists() else {}
records = []
for file in sorted(art.rglob('*.png')):
    with Image.open(file) as image:
        record = {
            'file': file.relative_to(art).as_posix(),
            'sha256': hashlib.sha256(file.read_bytes()).hexdigest(),
            'size': file.stat().st_size,
            'width': image.width,
            'height': image.height,
            'mode': image.mode,
            'generator': 'built-in image_gen.imagegen',
            'date': previous.get(file.relative_to(art).as_posix(), {}).get('date', '2026-10-17'),
            'status': 'prototype candidate',
        }
        if file.stem.startswith('mound-'):
            assert image.mode == 'RGBA', f'Mound lacks alpha: {file.name}'
            low, high = image.getchannel('A').getextrema()
            assert low == 0 and high >= 250, f'Mound is not transparent: {file.name}'
            record['alpha_range'] = [low, high]
        prompt = file.parent / 'prompts' / (file.stem + '.txt')
        record['prompt'] = prompt.relative_to(art).as_posix() if prompt.exists() else 'PROMPTS.md'
        records.append(record)
(art / 'SOURCES.json').write_text(json.dumps(records, indent=2) + '\n', encoding='utf-8')
print(f'Inspected {len(records)} source assets; recorded dimensions, checksums and alpha coverage')

