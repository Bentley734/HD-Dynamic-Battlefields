"""Prepare immutable GitHub file-pack assets and an offline ZIP per aspect/tier.

Does not upload, generate/recolor/rescale art, run tests, or alter source assets.
The caller must provide the intended repository and release tag explicitly.
"""
import argparse
import hashlib
import json
import re
import sys
import zipfile
from pathlib import Path

PROJECT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(PROJECT.parent / '.work/hd-beta-deps'))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--repository', required=True, help='OWNER/REPOSITORY')
    parser.add_argument('--tag', required=True)
    parser.add_argument('--version', required=True)
    parser.add_argument('--catalog', default='metadata/prototype.lua')
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    if not re.fullmatch(r'[\w.-]+/[\w.-]+', args.repository):
        parser.error('Repository must be OWNER/REPOSITORY')
    if not re.fullmatch(r'[\w.-]+', args.tag) or not re.fullmatch(r'[\w.-]+', args.version):
        parser.error('Tag/version must be a simple release identifier')
    from lupa.luajit21 import LuaRuntime
    lua = LuaRuntime()
    catalog_path = (PROJECT / args.catalog).resolve()
    catalog_path.relative_to(PROJECT)
    raw = lua.execute(catalog_path.read_text(encoding='utf-8'))

    def convert(value):
        if hasattr(value, 'items'):
            items = dict(value.items())
            if items and all(isinstance(key, int) for key in items):
                return [convert(items[i]) for i in range(1, len(items) + 1)]
            return {key: convert(item) for key, item in items.items()}
        return value

    catalog = convert(raw)
    groups = {}
    for entry in catalog['compositions']:
        groups.setdefault((entry['aspect_ratio'], entry['quality'], 'all'), []).append(entry)
    # Select one stable variation independently for every environment/aspect.
    for (aspect, quality, profile), entries in list(groups.items()):
        first = {}
        for entry in sorted(entries, key=lambda item: (item.get('variation', 1), item['id'])):
            first.setdefault(entry['environment'], entry)
        groups[(aspect, quality, 'one')] = list(first.values())
    output = args.output.resolve()
    output.mkdir(parents=True, exist_ok=True)
    if any(output.iterdir()):
        parser.error('Output must be empty so stale assets cannot enter a release')
    index = {'schema_version': 1, 'repository': args.repository, 'version': args.version, 'packs': []}
    checksums = {}
    release_url = f'https://github.com/{args.repository}/releases/download/{args.tag}/'
    for (aspect, quality, profile), entries in sorted(groups.items()):
        identifier = 'battlefields-' + re.sub(r'[^a-z0-9]+', '-', aspect.lower() + '-' + quality.lower()) + '-' + profile
        directory = output / identifier
        directory.mkdir(exist_ok=True)
        used_metadata = {}

        def include_metadata(key):
            if key in used_metadata:
                return
            value = catalog['metadata'][key]
            used_metadata[key] = value
            if value.get('inherits'):
                include_metadata(value['inherits'])

        paths = set()
        for entry in entries:
            include_metadata(entry['metadata'])
            paths.add(entry['background'])
            paths.update(entry.get('backgrounds', {}).values())
            paths.update(entry.get('mounds', {}).values())
            paths.update(entry.get('night_mounds', {}).values())
        composition_bytes = (json.dumps({'metadata': used_metadata, 'compositions': entries},
                                       sort_keys=True, separators=(',', ':')) + '\n').encode()
        payload = {'compositions.json': composition_bytes}
        for relative in sorted(paths):
            source = (PROJECT / relative).resolve()
            source.relative_to(PROJECT)
            payload[relative] = source.read_bytes()
        files = []
        for relative, data in sorted(payload.items()):
            digest = hashlib.sha256(data).hexdigest()
            # Every uploaded asset has a flat, collision-free release name.
            name = identifier + '-' + digest + '-' + Path(relative).name
            target = directory / name
            target.write_bytes(data)
            checksums[f'{identifier}/{name}'] = digest
            files.append({'path': relative, 'sha256': digest, 'size': len(data), 'url': release_url + name})
        archive = output / f'{identifier}-{args.version}.zip'
        with zipfile.ZipFile(archive, 'w', zipfile.ZIP_DEFLATED) as package:
            for relative, data in sorted(payload.items()):
                info = zipfile.ZipInfo(relative, date_time=(1980, 1, 1, 0, 0, 0))
                info.compress_type = zipfile.ZIP_DEFLATED
                info.create_system = 3
                info.external_attr = 0o100644 << 16
                package.writestr(info, data)
        pack = {'schema_version': 1, 'metadata_schema': 1, 'id': identifier,
                'version': args.version, 'game_version': '>=0.3.88 <0.4.0',
                'aspects': [aspect], 'quality': quality, 'variation_profile': profile,
                'label': f'{aspect} {quality} - ' + ('One variation per area' if profile == 'one' else 'All variations'),
                'environments': sorted({item['environment'] for item in entries}),
                'optional_dependencies': [], 'files': files,
                'installed_size': sum(item['size'] for item in files),
                'compressed_size': archive.stat().st_size,
                'offline_archive': {'url': release_url + archive.name,
                                    'size': archive.stat().st_size,
                                    'sha256': hashlib.sha256(archive.read_bytes()).hexdigest()}}
        descriptor = json.dumps(pack, indent=2) + '\n'
        (directory / 'pack.json').write_text(descriptor, encoding='utf-8')
        flat_descriptor = output / f'{identifier}-{args.version}.pack.json'
        flat_descriptor.write_text(descriptor, encoding='utf-8')
        checksums[flat_descriptor.name] = hashlib.sha256(flat_descriptor.read_bytes()).hexdigest()
        checksums[f'{identifier}/pack.json'] = hashlib.sha256((directory / 'pack.json').read_bytes()).hexdigest()
        index['packs'].append(pack)
        checksums[archive.name] = pack['offline_archive']['sha256']
    (output / 'asset-index.json').write_text(json.dumps(index, indent=2) + '\n', encoding='utf-8')
    checksums['asset-index.json'] = hashlib.sha256((output / 'asset-index.json').read_bytes()).hexdigest()
    (output / 'SHA256SUMS.txt').write_text(''.join(f'{digest}  {name}\n' for name, digest in sorted(checksums.items())), encoding='utf-8')
    print(f'Prepared {len(index["packs"])} pack descriptors. Nothing uploaded; final validation is still required.')


if __name__ == '__main__':
    main()
