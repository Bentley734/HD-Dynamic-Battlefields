"""Import a published offline pack into the HD mod cache while the game is closed.

Requires the separately published pack.json descriptor. Stages immutable objects
and writes the runtime's checksummed commit only after every file is verified.
"""
import argparse
import hashlib
import json
import os
import re
import tempfile
import zipfile
from pathlib import Path, PurePosixPath


def encode(value):
    return json.dumps(value, sort_keys=True, separators=(',', ':'))


def sha(value):
    return hashlib.sha256(value).hexdigest()


def atomic(path, data):
    path.parent.mkdir(parents=True, exist_ok=True)
    handle, name = tempfile.mkstemp(prefix='.hd-import-', dir=path.parent)
    try:
        with os.fdopen(handle, 'wb') as target:
            target.write(data)
            target.flush()
            os.fsync(target.fileno())
        os.replace(name, path)
    finally:
        if os.path.exists(name):
            os.unlink(name)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--archive', required=True, type=Path)
    parser.add_argument('--manifest', required=True, type=Path)
    parser.add_argument('--cache', required=True, type=Path,
                        help='Exact mod_cache/hd-dynamic-battlefields directory')
    args = parser.parse_args()
    cache = args.cache.resolve()
    if cache.name != 'hd-dynamic-battlefields' or cache.parent.name != 'mod_cache':
        parser.error('Cache must name mod_cache/hd-dynamic-battlefields')
    pack = json.loads(args.manifest.read_text(encoding='utf-8'))
    if pack.get('schema_version') != 1 or pack.get('metadata_schema') != 1:
        parser.error('Unsupported pack schema')
    for key in ('id', 'version'):
        if not re.fullmatch(r'[\w-][\w.-]{0,99}', pack.get(key, '')) or '..' in pack[key]:
            parser.error('Invalid pack identity')
    files = pack.get('files', [])
    if not 1 <= len(files) <= 4096:
        parser.error('Invalid file count')
    expected = {}
    for item in files:
        path = item.get('path', '')
        parts = PurePosixPath(path)
        if not path or '\\' in path or parts.is_absolute() or '..' in parts.parts or path in expected:
            parser.error('Unsafe or duplicate pack path')
        if not re.fullmatch(r'[A-Za-z0-9_./-]+', path) or any(part in ('', '.') for part in path.split('/')):
            parser.error('Unsafe pack path')
        if not re.fullmatch(r'[a-f0-9]{64}', item.get('sha256', '')):
            parser.error('Invalid checksum')
        if not isinstance(item.get('size'), int) or not 1 <= item['size'] <= 64 * 1024 * 1024:
            parser.error('Invalid asset size')
        expected[path] = item
    if sum(item['size'] for item in files) != pack.get('installed_size'):
        parser.error('Installed size mismatch')
    # Read mutable discovery state before staging objects or activating a commit.
    index_path = cache / 'installed-pack-ids.json'
    try:
        ids = json.loads(index_path.read_text(encoding='utf-8'))
        if not isinstance(ids, list) or any(not isinstance(item, str) or
                not re.fullmatch(r'[\w-][\w.-]{0,99}', item) or '..' in item for item in ids):
            raise ValueError('Invalid installed pack index')
    except FileNotFoundError:
        ids = []
    except (ValueError, OSError) as error:
        parser.error('Cannot read installed pack index: ' + str(error))
    archive = pack.get('offline_archive', {})
    raw_archive = args.archive.read_bytes()
    if sha(raw_archive) != archive.get('sha256') or len(raw_archive) != archive.get('size'):
        parser.error('Archive checksum or size mismatch')
    # Verify every member before writing any cache state. No extractall.
    with zipfile.ZipFile(args.archive) as source:
        members = source.infolist()
        if len(members) != len(expected) or {member.filename for member in members} != set(expected):
            parser.error('Archive members differ from manifest')
        for member in members:
            item = expected[member.filename]
            if member.file_size != item['size']:
                parser.error('Archive member size mismatch')
            data = source.read(member)
            if sha(data) != item['sha256']:
                parser.error('Asset checksum mismatch: ' + member.filename)
        for member in members:
            item = expected[member.filename]
            target = cache / 'packs' / pack['id'] / pack['version'] / item['sha256'] / item['path']
            target.resolve().relative_to(cache)
            atomic(target, source.read(member))
    sequences = []
    for slot in (1, 2):
        try:
            envelope = json.loads((cache / 'packs' / pack['id'] / f'commit-{slot}.json').read_text())
            if sha(envelope['body'].encode()) == envelope['sha256']:
                sequence = json.loads(envelope['body'])['sequence']
                if isinstance(sequence, int) and sequence >= 1:
                    sequences.append(sequence)
        except (OSError, ValueError, KeyError, TypeError):
            pass
    sequence = max(sequences, default=0) + 1
    body = encode({'sequence': sequence, 'pack': pack})
    atomic(cache / 'packs' / pack['id'] / f'commit-{sequence % 2 + 1}.json',
           encode({'body': body, 'sha256': sha(body.encode())}).encode())
    if pack['id'] not in ids:
        ids.append(pack['id'])
    atomic(index_path, encode(ids).encode())
    print('Imported', pack['id'], pack['version'], '- restart the game, then verify from Asset Manager.')


if __name__ == '__main__':
    main()
