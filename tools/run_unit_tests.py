"""Pure Lua checks using the downloaded, hash-verified runtime's JSON module."""
import hashlib
import sys
from pathlib import Path

workspace = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(workspace / '.work/menu-3253-deps'))
sys.path.insert(0, str(Path(__file__).resolve().parents[2] / '.work/hd-beta-deps'))
from lupa.luajit21 import LuaRuntime

project = Path(__file__).resolve().parents[1]
runtime = workspace / '.work/hd-battlefields-latest/v0.3.88/engine'
for test in sorted((project / 'tests').glob('*.lua')):
    lua = LuaRuntime()
    lua.globals().root = project.as_posix()
    lua.globals().engine = runtime.as_posix()
    lua.globals().sha256 = lambda value: hashlib.sha256(value.encode()).hexdigest()
    lua.execute(test.read_text(encoding='utf-8'))
