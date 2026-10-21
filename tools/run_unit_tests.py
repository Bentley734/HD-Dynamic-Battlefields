"""Pure Lua checks using the downloaded, hash-verified runtime's JSON module."""
import hashlib
import argparse
import sys
from pathlib import Path

workspace = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(workspace / '.work/menu-3253-deps'))
sys.path.insert(0, str(Path(__file__).resolve().parents[2] / '.work/hd-beta-deps'))
from lupa.luajit21 import LuaRuntime

project = Path(__file__).resolve().parents[1]
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--engine', type=Path,
                    default=workspace / '.work/hd-battlefields-latest/v0.3.95/engine')
args = parser.parse_args()
runtime = args.engine.resolve()
if not (runtime / 'src/link/Json.lua').is_file():
    parser.error('Engine must contain src/link/Json.lua')
for test in sorted((project / 'tests').glob('*.lua')):
    lua = LuaRuntime()
    lua.globals().root = project.as_posix()
    lua.globals().engine = runtime.as_posix()
    lua.globals().sha256 = lambda value: hashlib.sha256(value.encode()).hexdigest()
    lua.execute(test.read_text(encoding='utf-8'))
