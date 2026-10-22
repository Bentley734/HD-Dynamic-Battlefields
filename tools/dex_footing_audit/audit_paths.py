"""Shared paths for read-only sprite audits; generated output stays untracked."""
from pathlib import Path
import json
import os
import sys

REPO = Path(__file__).resolve().parents[2]
WORKSPACE = REPO.parent

def configured(name, default):
    return Path(os.environ.get(name, str(default))).expanduser().resolve()

OUT = configured('HDB_AUDIT_OUT', WORKSPACE / '.work/1025-footing-audit')
DEPS = configured('HDB_AUDIT_DEPS', WORKSPACE / '.work/hd-beta-deps')
DEX = configured('HDB_DEX_SOURCE', WORKSPACE / '.work/1025dex-double-fix')
ART = configured('HDB_DEX_ART', WORKSPACE / '.work/hd-rse-compat-latest/dex-artwork/assets/sprites/assets')
app_data = Path(os.environ['APPDATA']) if os.environ.get('APPDATA') else Path(os.environ.get('XDG_DATA_HOME', Path.home() / '.local/share')) / 'love'
SAVE = configured('HDB_GAME_SAVE', app_data / 'pokemon-love2d')
BW = configured('HDB_BW_SOURCE', SAVE / 'mods/1025dex-bw-sprites')
KIM = configured('HDB_KIM_SOURCE', SAVE / 'mods/kim1025')
KIM_CACHE = configured('HDB_KIM_CACHE', SAVE / 'mod_cache/kim1025/kim_assets/files')
sys.path.insert(0, str(DEPS))
OUT.mkdir(parents=True, exist_ok=True)

def require_dex_version():
    """The extraction and generated runtime contract are version-specific."""
    manifest = json.loads((DEX / 'manifest.json').read_text(encoding='utf-8-sig'))
    if manifest.get('version') != '1.5.2':
        raise RuntimeError('This audit targets unmodified 1025Dex 1.5.2; review the extraction and version contract before using another release.')
