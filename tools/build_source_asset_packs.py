"""Prepare commit-pinned source-file downloads, without release image assets.

Run once to prepare compositions.json files for the artwork source commit, then
again with --source-commit after committing those files and their referenced art.
Only descriptors and the small index need accompany the main mod release.
"""
import argparse
import hashlib
import json
import re
import sys
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT.parent / '.work/hd-beta-deps'))
from lupa.luajit21 import LuaRuntime


def plain(value):
    if not hasattr(value, 'items'):
        return value
    items = dict(value.items())
    if items and all(isinstance(k, int) for k in items):
        return [plain(items[i]) for i in range(1, len(items) + 1)]
    return {k: plain(v) for k, v in items.items()}


def save(path, data):
    path.parent.mkdir(parents=True, exist_ok=True)
    if path.exists() and path.read_bytes() != data:
        raise ValueError('Refusing to overwrite different immutable source data: ' + str(path))
    path.write_bytes(data)


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--repository', required=True)
    p.add_argument('--version', required=True)
    p.add_argument('--catalog', default='metadata/distribution.lua')
    p.add_argument('--source-commit')
    p.add_argument('--catalog-version', help='Existing source catalog directory, independently versioned from the release')
    p.add_argument('--game-version', default='>=0.3.89 <0.4.0', help='Runtime compatibility range written to pack descriptors')
    p.add_argument('--output', required=True, type=Path)
    args = p.parse_args()
    if not re.fullmatch(r'[\w.-]+/[\w.-]+', args.repository):
        p.error('Expected OWNER/REPOSITORY')
    if not re.fullmatch(r'[\w.-]+', args.version):
        p.error('Invalid version token')
    if args.catalog_version and not re.fullmatch(r'[\w.-]+', args.catalog_version):
        p.error('Invalid catalog directory token')
    if args.source_commit and not re.fullmatch(r'[a-f0-9]{40}', args.source_commit):
        p.error('Source commit must be a full immutable Git SHA')
    tree = None
    if args.source_commit:
        raw = subprocess.check_output(['git', 'ls-tree', '-r', '-z', args.source_commit], cwd=ROOT)
        tree = {}
        for line in raw.split(b'\0'):
            if line:
                info, name = line.split(b'\t', 1)
                tree[name.decode('utf-8')] = info.split()[2].decode('ascii')
    path = (ROOT / args.catalog).resolve();path.relative_to(ROOT)
    catalog = plain(LuaRuntime().execute(path.read_text(encoding='utf-8')))
    groups = {}
    for entry in catalog['compositions']:
        groups.setdefault((entry['aspect_ratio'], entry['quality'], 'all'), []).append(entry)
    for (aspect, quality, _), entries in list(groups.items()):
        first = {}
        for entry in sorted(entries, key=lambda e: (e.get('variation', 1), e['id'])):
            first.setdefault(entry['environment'], entry)
        groups[(aspect, quality, 'one')] = list(first.values())
    index = {'schema_version': 1, 'repository': args.repository, 'version': args.version, 'packs': []}
    prepared, digests = [], {}
    for (aspect, quality, profile), entries in sorted(groups.items()):
        identifier = 'battlefields-' + re.sub(r'[^a-z0-9]+', '-', aspect.lower() + '-' + quality.lower()) + '-' + profile
        selected = {}

        def include(key):
            if key in selected:
                return
            value = catalog['metadata'][key];selected[key] = value
            if value.get('inherits'):
                include(value['inherits'])

        paths = set()
        for entry in entries:
            include(entry['metadata'])
            if entry.get('night_metadata'):
                include(entry['night_metadata'])
            paths.add(entry['background'])
            for field in ('backgrounds', 'mounds', 'night_mounds'):
                paths.update(entry.get(field, {}).values())
        relative = f'asset-packs/{args.catalog_version or args.version}/{identifier}/compositions.json'
        payload = (json.dumps({'metadata': selected, 'compositions': entries},
                             sort_keys=True, separators=(',', ':')) + '\n').encode()
        save(ROOT / relative, payload)
        sources = {name: name for name in paths}
        sources['compositions.json'] = relative
        files = []
        for installed, source in sorted(sources.items()):
            source_path = (ROOT / source).resolve();source_path.relative_to(ROOT)
            if source not in digests:
                data = source_path.read_bytes()
                if tree is not None:
                    blob = hashlib.sha1(b'blob ' + str(len(data)).encode() + b'\0' + data).hexdigest()
                    if tree.get(source) != blob:
                        raise ValueError('Pinned commit lacks exact source bytes: ' + source)
                digests[source] = (len(data), hashlib.sha256(data).hexdigest())
            size, digest = digests[source]
            item = {'path': installed, 'size': size, 'sha256': digest}
            if args.source_commit:
                item['url'] = f'https://raw.githubusercontent.com/{args.repository}/{args.source_commit}/{source}'
            files.append(item)
        pack = {'schema_version': 1, 'metadata_schema': 1, 'id': identifier, 'version': args.version,
                'game_version': args.game_version, 'aspects': [aspect], 'quality': quality,
                'variation_profile': profile, 'label': f'{aspect} {quality} - ' +
                ('One variation per area' if profile == 'one' else 'All variations'),
                'environments': sorted({e['environment'] for e in entries}),
                'optional_dependencies': [], 'files': files,
                'installed_size': sum(f['size'] for f in files)}
        prepared.append({'id': identifier, 'source_catalog': relative, 'compositions': len(entries)})
        if args.source_commit:
            index['packs'].append(pack)
            save(args.output / (identifier + '.pack.json'), (json.dumps(pack, indent=2) + '\n').encode())
    args.output.mkdir(parents=True, exist_ok=True)
    save(args.output / 'source-inventory.json', (json.dumps({'packs': prepared, 'files': sorted(digests)}, indent=2) + '\n').encode())
    if args.source_commit:
        save(args.output / 'asset-index.json', (json.dumps(index, indent=2) + '\n').encode())
    print(json.dumps({'packs': len(prepared), 'unique_source_files': len(digests),
                      'unique_bytes': sum(size for size, _ in digests.values()),
                      'source_commit': args.source_commit, 'uploaded': False}))


if __name__ == '__main__':
    main()
