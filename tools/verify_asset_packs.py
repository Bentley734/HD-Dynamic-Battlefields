"""Exercise built packs and offline imports against the real Lua store/backend.

Uses an explicitly named fresh cache under the workspace .work directory.
Never contacts GitHub or reads/writes the user's game cache.
"""
import argparse
import hashlib
import json
import subprocess
import sys
import tempfile
import zipfile
from pathlib import Path

from install_offline_pack import atomic

PROJECT = Path(__file__).resolve().parents[1]
WORKSPACE = PROJECT.parent
sys.path.insert(0, str(WORKSPACE / '.work/menu-3253-deps'))
from lupa.luajit21 import LuaRuntime


def run(arguments, success=True):
    result = subprocess.run([sys.executable, *map(str, arguments)], capture_output=True, text=True)
    assert (result.returncode == 0) == success, result.stdout + result.stderr
    return result


def require(result):
    ok, error = result if isinstance(result, tuple) else (result, None)
    assert ok, error


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--build', type=Path, required=True)
    parser.add_argument('--cache', type=Path, required=True)
    args = parser.parse_args()
    build, cache = args.build.resolve(), args.cache.resolve()
    cache.relative_to((WORKSPACE / '.work').resolve())
    assert cache.name == 'hd-dynamic-battlefields' and cache.parent.name == 'mod_cache'
    assert not cache.exists(), 'Use a fresh isolated cache'
    index = json.loads((build / 'asset-index.json').read_text(encoding='utf-8'))
    packs = index['packs']
    assert packs
    for line in (build / 'SHA256SUMS.txt').read_text().splitlines():
        digest, relative = line.split('  ', 1)
        file = (build / relative).resolve()
        file.relative_to(build)
        assert hashlib.sha256(file.read_bytes()).hexdigest() == digest, relative

    def target(relative):
        file = (cache / relative.decode()).resolve()
        file.relative_to(cache)
        return file

    def read(relative):
        file = target(relative)
        return file.read_bytes() if file.exists() else None

    def write(relative, data):
        atomic(target(relative), data)
        return True

    def delete(relative):
        target(relative).unlink(missing_ok=True)
        return True

    lua = LuaRuntime(encoding=None, unpack_returned_tuples=True)
    lua.globals().root = PROJECT.as_posix().encode()
    lua.globals().engine = (WORKSPACE / '.work/hd-battlefields-latest/v0.3.88/engine').as_posix().encode()
    lua.globals().py_read, lua.globals().py_write, lua.globals().py_delete = read, write, delete
    lua.globals().py_digest = lambda data: hashlib.sha256(data).digest()
    lua.globals().py_hex = lambda data: data.hex().encode()
    store, backend, decode = lua.execute("""
      package.path=engine..'/?.lua;'..package.path
      love={data={hash=function(_,data)return py_digest(data)end,
       encode=function(_,_,data)return py_hex(data)end}}
      local mod={id='hd-dynamic-battlefields',fetch={},cache={
       read=function(_,p)return py_read(p)end,write=function(_,p,b)return py_write(p,b)end,
       delete=function(_,p)return py_delete(p)end}}
      local perspective=assert(loadfile(root..'/lib/perspective.lua'))()
      local backend=assert(loadfile(root..'/lib/runtime_backend.lua'))()(mod,perspective)
      local schema=assert(loadfile(root..'/lib/pack_store.lua'))()
      return schema.new(backend),backend,require('src.link.Json').decode
    """)
    imported = []
    installer = PROJECT / 'tools/install_offline_pack.py'
    for pack in packs:
        descriptor = build / pack['id'] / 'pack.json'
        flat = build / f"{pack['id']}-{pack['version']}.pack.json"
        assert flat.read_bytes() == descriptor.read_bytes(), 'Missing flat offline descriptor'
        archive = build / Path(pack['offline_archive']['url']).name
        native = decode(descriptor.read_bytes())
        require(backend.compatible(native))
        with zipfile.ZipFile(archive) as package:
            require(backend.validate(native, lambda path: package.read(path.decode())))
        run([installer, '--archive', archive, '--manifest', flat, '--cache', cache])
        installed = store.installed(store, pack['id'].encode())
        assert installed and installed[b'version'].decode() == pack['version']
        require(store.verify(store, installed))
        imported.append({'id': pack['id'], 'files': len(pack['files']),
                         'installed_size': pack['installed_size'], 'archive_sha256': pack['offline_archive']['sha256']})
    assert set(json.loads((cache / 'installed-pack-ids.json').read_text())) == {p['id'] for p in packs}

    # Real cache slots: reimport, tear newest commit, and recover the older slot.
    smallest = min(packs, key=lambda pack: pack['installed_size'])
    manifest = build / f"{smallest['id']}-{smallest['version']}.pack.json"
    archive = build / Path(smallest['offline_archive']['url']).name
    run([installer, '--archive', archive, '--manifest', manifest, '--cache', cache])
    newest = cache / 'packs' / smallest['id'] / 'commit-1.json'
    newest.write_bytes(b'torn')
    assert store.installed(store, smallest['id'].encode())
    require(store.verify(store, store.installed(store, smallest['id'].encode())))
    require(store.remove(store, smallest['id'].encode()))
    assert not store.installed(store, smallest['id'].encode())
    run([installer, '--archive', archive, '--manifest', manifest, '--cache', cache])
    require(store.verify(store, store.installed(store, smallest['id'].encode())))

    with tempfile.TemporaryDirectory(prefix='pack-faults-', dir=WORKSPACE / '.work') as temporary:
        cases = Path(temporary)
        def isolated(name):
            return cases / name / 'mod_cache/hd-dynamic-battlefields'
        bad_archive = cases / 'truncated.zip'
        bad_archive.write_bytes(b'not a ZIP')
        run([installer, '--archive', bad_archive, '--manifest', manifest, '--cache', isolated('corrupt')], False)
        assert not isolated('corrupt').exists()
        invalid_index = isolated('index')
        invalid_index.mkdir(parents=True)
        (invalid_index / 'installed-pack-ids.json').write_text('{broken')
        run([installer, '--archive', archive, '--manifest', manifest, '--cache', invalid_index], False)
        assert not (invalid_index / 'packs').exists(), 'Corrupt discovery index must fail before staging/commit'
        unsafe = json.loads(manifest.read_text())
        unsafe['files'][0]['path'] = '../escape'
        unsafe_manifest = cases / 'unsafe.json'
        unsafe_manifest.write_text(json.dumps(unsafe))
        run([installer, '--archive', archive, '--manifest', unsafe_manifest, '--cache', isolated('unsafe')], False)
        assert not isolated('unsafe').exists()

    # A real small source subset proves deterministic archive/descriptor builds.
    with tempfile.TemporaryDirectory(prefix='.pack-repro-', dir=PROJECT) as temporary:
        fixture = Path(temporary)
        catalog = fixture / 'catalog.lua'
        source = json.dumps((PROJECT / 'metadata/prototype.lua').as_posix())
        catalog.write_text('local c=assert(loadfile(' + source + '))(); c.compositions={c.compositions[1]}; return c')
        outputs = [fixture / 'first', fixture / 'second']
        for output in outputs:
            run([PROJECT / 'tools/build_asset_packs.py', '--repository', index['repository'],
                 '--tag', 'qa-repro', '--version', '0.1.0-qa', '--catalog', catalog.relative_to(PROJECT), '--output', output])
        assert (outputs[0] / 'SHA256SUMS.txt').read_bytes() == (outputs[1] / 'SHA256SUMS.txt').read_bytes()
        run([PROJECT / 'tools/build_asset_packs.py', '--repository', index['repository'],
             '--tag', 'qa-repro', '--version', '0.1.0-qa', '--catalog', catalog.relative_to(PROJECT), '--output', outputs[0]], False)

    report = {'scope': 'Unpublished local packs; no network or user game cache', 'packs': imported,
              'checks': ['all release checksums', 'flat offline descriptors', 'runtime compatibility and metadata validation',
                         'fresh multiple-aspect offline imports', 'runtime content verification', 'torn-slot recovery',
                         'removal and reimport', 'corrupt archive rejection', 'corrupt-index preflight',
                         'unsafe path rejection', 'deterministic rebuild', 'stale output rejection'],
              'isolated_cache': str(cache)}
    (PROJECT / 'docs/evidence/pack-roundtrip-qa.json').write_text(json.dumps(report, indent=2) + '\n')
    print(f'PASS {len(imported)} aspect packs imported and verified; fault/rebuild checks passed')


if __name__ == '__main__':
    main()
