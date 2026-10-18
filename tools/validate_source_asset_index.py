"""Validate every source-backed pack through the actual runtime validators."""
import argparse
import json
import sys
from pathlib import Path
root = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(root.parent / '.work/hd-beta-deps'))
from lupa.luajit21 import LuaRuntime
p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--index', type=Path, required=True)
a = p.parse_args()
lua = LuaRuntime()
lua.globals().root = root.as_posix()
lua.globals().engine = (root.parent / '.work/hd-battlefields-latest/v0.3.89/engine').as_posix()
lua.globals().index_bytes = a.index.read_text()
lua.execute('''
local Json=assert(loadfile(engine..'/src/link/Json.lua'))()
local P=assert(loadfile(root..'/lib/perspective.lua'))()
local schema=assert(loadfile(root..'/lib/pack_store.lua'))()
local originalRequire=require
require=function(name)
 if name=='src.link.Json'then return Json end
 if name=='src.mods.Semver'then return{satisfies=function()return true end}end
 if name=='src.core.Version'then return{engine='0.3.89'}end
 return originalRequire(name)
end
local backend=assert(loadfile(root..'/lib/runtime_backend.lua'))()({},P)
require=originalRequire
local index=Json.decode(index_bytes)
assert(#index.packs==18)
for _,pack in ipairs(index.packs)do
 assert(schema.validate(pack))
 local paths={}
 for _,f in ipairs(pack.files)do
  assert(schema.assetUrl(f.url,index.repository))
  paths[f.path]=assert(f.url:match('^https://raw%.githubusercontent%.com/[^/]+/[^/]+/[^/]+/(.+)$'))
 end
 local function read(path)
  local file=assert(io.open(root..'/'..assert(paths[path]),'rb'))
  local bytes=file:read(path=='compositions.json'and'*a'or 33);file:close();return bytes
 end
 local ok,why=backend.validate(pack,read);assert(ok,pack.id..': '..tostring(why))
end
print('PASS all 18 published source pack schemas, PNG headers, metadata and night geometry')
''')
