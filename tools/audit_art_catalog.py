"""Decode registered artwork and exercise Scene.prepare against real dimensions.

This checks shipped catalog integrity, not visual approval or complete coverage.
It never changes source images or metadata.
"""
import json
import sys
from collections import defaultdict
from pathlib import Path

PROJECT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(Path(__file__).resolve().parents[2] / '.work/hd-beta-deps'))
from lupa.luajit21 import LuaRuntime
from PIL import Image


def main():
    lua = LuaRuntime(unpack_returned_tuples=True)
    lua.globals().root = PROJECT.as_posix()
    scene_factory, perspective, catalog = lua.execute("""
      return assert(loadfile(root..'/lib/scene.lua'))(),
       assert(loadfile(root..'/lib/perspective.lua'))(),
       assert(loadfile(root..'/metadata/prototype.lua'))()
    """)
    graphics = lua.eval("{newQuad=function()return{release=function()end}end}")
    inspected = {}

    def load_image(relative):
        file = (PROJECT / relative).resolve()
        file.relative_to(PROJECT)
        if relative not in inspected:
            with Image.open(file) as image:
                image.load()  # Decode pixel data; a valid PNG header is insufficient.
                width, height = image.size
                if '/mound-' in relative:
                    assert image.mode == 'RGBA', f'Missing mound alpha: {relative}'
                    low, high = image.getchannel('A').getextrema()
                    assert low == 0 and high >= 250, relative
                inspected[relative] = (width, height)
        width, height = inspected[relative]
        return lua.table_from({'getWidth': lambda *_: width,
                               'getHeight': lambda *_: height,
                               'release': lambda *_: None})

    scene = scene_factory.new(graphics, perspective, load_image)
    coverage = defaultdict(lambda: defaultdict(list))
    prepared = 0
    failures = []
    for _, entry in catalog.compositions.items():
        periods = ['day', 'night'] if entry.backgrounds else ['day']
        for period in periods:
            result = scene.prepare(scene, entry, catalog.metadata, period)
            ok, error = result if isinstance(result, tuple) else (result, None)
            if not ok:
                failures.append({'id': entry.id, 'period': period, 'error': str(error)})
            else:
                prepared += 1
        coverage[entry.environment][entry.aspect_ratio].append(entry.id)
    scene.release(scene)
    report = {'scope': 'Catalog decode/metadata integrity only; not art or release approval',
              'registered_compositions': sum(len(ids) for aspects in coverage.values()
                                             for ids in aspects.values()),
              'prepared_periods': prepared, 'decoded_files': len(inspected),
              'failures': failures,
              'coverage': {env: dict(aspects) for env, aspects in coverage.items()}}
    destination = PROJECT / 'docs/evidence/art-catalog-audit.json'
    destination.write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8')
    if failures:
        print(json.dumps(failures, indent=2))
        raise SystemExit(f'{len(failures)} catalog failures')
    print(f'PASS {prepared} composition periods; {len(inspected)} source PNGs decoded')


if __name__ == '__main__':
    main()
