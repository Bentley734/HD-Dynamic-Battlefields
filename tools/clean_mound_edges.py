"""Save a sibling copy with generated cutout-edge contamination removed.

Authorized by the user on 2026-10-15 for transparent mound edges only.
Never overwrites an original. Painted opaque interior RGB stays unchanged.
"""
import argparse
import json
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFilter


def clean(source, destination, trim, rounded=False):
    if destination.exists():
        raise ValueError(f'Refusing to overwrite {destination}')
    with Image.open(source) as original:
        if original.mode != 'RGBA':
            raise ValueError(f'Expected a transparent RGBA cutout: {source}')
        pixels = np.array(original)
    alpha = pixels[:, :, 3]
    if not np.any(alpha == 0) or not np.any(alpha >= 250):
        raise ValueError(f'Expected both transparent surroundings and opaque paint: {source}')
    # Work in original source pixels. At the current 2172px source width a
    # 12px trim is under one native rendered mound pixel. It removes the
    # generator's ragged white/chromatic matte without repainting the body.
    # Follow the outer silhouette, not tiny alpha differences in painted
    # texture. Fill enclosed holes only in this working boundary mask; the
    # original interior alpha below is preserved in the saved image.
    # Copy to detach NumPy's read-only backing before Pillow flood-fill.
    boundary = Image.fromarray(np.where(alpha > 32, 255, 0).astype(np.uint8)).copy()
    if boundary.getpixel((0, 0)) != 0:
        raise ValueError(f'Expected transparent corner around the oval: {source}')
    ImageDraw.floodfill(boundary, (0, 0), 128)
    core = Image.fromarray(np.where(np.array(boundary) == 128, 0, 255).astype(np.uint8))
    if rounded:
        # A square minimum filter makes square notches in highly ragged
        # paint silhouettes. A high-density Gaussian inset keeps that
        # perimeter smooth without touching the original interior paint.
        density = core.filter(ImageFilter.GaussianBlur(trim / 2))
        eroded = density.point(lambda value: 255 if value >= 250 else 0)
    else:
        eroded = core.filter(ImageFilter.MinFilter(trim * 2 + 1))
    clean_alpha = np.minimum(alpha, np.array(eroded.filter(ImageFilter.GaussianBlur(.7))))
    opaque = np.array(eroded) == 255
    if not np.any(opaque):
        raise ValueError(f'Trim would remove the painted interior: {source}')
    # Extend the nearest retained paint through the new antialiased edge.
    # Removing alpha alone leaves hidden colored matte RGB for texture
    # filtering to sample. Fully opaque interior pixels are never recolored.
    output = pixels.copy()
    known = opaque.copy()
    # Simultaneous four-neighbor expansion gives the nearest retained color
    # in source-pixel Manhattan distance without an extra image dependency.
    for _ in range(trim + 8):
        filled = np.zeros_like(known)
        colors = output[:, :, :3].copy()
        for dy, dx in ((-1, 0), (1, 0), (0, -1), (0, 1)):
            neighbor = np.roll(known, (dy, dx), (0, 1))
            if dy < 0:
                neighbor[dy:, :] = False
            elif dy > 0:
                neighbor[:dy, :] = False
            if dx < 0:
                neighbor[:, dx:] = False
            elif dx > 0:
                neighbor[:, :dx] = False
            target = ~known & ~filled & neighbor
            colors[target] = np.roll(output[:, :, :3], (dy, dx), (0, 1))[target]
            filled |= target
        output[:, :, :3] = colors
        known |= filled
    output[:, :, 3] = clean_alpha
    output[(clean_alpha == 0) & ~known, :3] = 0
    Image.fromarray(output).save(destination)
    return {'source': str(source), 'output': str(destination), 'source_pixel_trim': trim,
            'width': pixels.shape[1], 'height': pixels.shape[0],
            'operation': ('rounded perimeter alpha inset' if rounded else 'perimeter alpha trim')
                         + ' and nearest interior color extension; original preserved'}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('sources', type=Path, nargs='+')
    parser.add_argument('--trim', type=int, default=12)
    parser.add_argument('--suffix', default='-clean')
    parser.add_argument('--rounded', action='store_true',
                        help='Smooth inset for ragged silhouettes; trim is an approximate source-pixel depth')
    args = parser.parse_args()
    if args.trim < 1 or args.trim > 32:
        parser.error('Trim must be 1 to 32 source pixels')
    if not args.suffix or any(c not in '-_abcdefghijklmnopqrstuvwxyz0123456789' for c in args.suffix):
        parser.error('Suffix must contain only lowercase letters, digits, hyphens or underscores')
    for source in args.sources:
        destination = source.with_stem(source.stem + args.suffix)
        print(json.dumps(clean(source, destination, args.trim, args.rounded)))


if __name__ == '__main__':
    main()
