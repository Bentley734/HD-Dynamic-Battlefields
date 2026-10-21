"""Validate unpublished source catalogs with the real runtime pack validator.
No GitHub upload or claim of pinned download availability is made here.
"""
import argparse, json, sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT.parent/'.work/hd-beta-deps'))
from lupa.luajit21 import LuaRuntime
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--catalogs',type=Path,required=True)
p.add_argument('--engine',type=Path,default=ROOT.parent/'.work/hd-battlefields-latest/v0.3.95/engine')
p.add_argument('--output',type=Path,required=True)
a=p.parse_args()
lua=LuaRuntime(unpack_returned_tuples=True)
lua.globals().project_root=ROOT.as_posix();lua.globals().engine_root=a.engine.resolve().as_posix()
validate=lua.execute('''
package.path=engine_root..'/?.lua;'..package.path
local Json=require('src.link.Json')
local P=assert(loadfile(project_root..'/lib/perspective.lua'))()
local schema=assert(loadfile(project_root..'/lib/pack_store.lua'))()
local backend=assert(loadfile(project_root..'/lib/runtime_backend.lua'))()({},P)
return function(catalogFile,id)
 local function read(path,whole)
  local f=assert(io.open(path,'rb'));local bytes=f:read(whole and '*a'or 33);f:close();return bytes
 end
 local bytes=read(catalogFile,true);local data=Json.decode(bytes)
 local paths,aspects,environments={['compositions.json']=true},{},{}
 for _,e in ipairs(data.compositions)do
  aspects[e.aspect_ratio]=true;environments[e.environment]=true;paths[e.background]=true
  for _,field in ipairs({'backgrounds','mounds','night_mounds'})do for _,v in pairs(e[field]or{})do paths[v]=true end end
 end
 local pack={schema_version=1,metadata_schema=1,id=id,version='local-candidate',quality='HD',game_version='>=0.3.95 <0.4.0',aspects={},environments={},files={},installed_size=0}
 for v in pairs(aspects)do table.insert(pack.aspects,v)end
 for v in pairs(environments)do table.insert(pack.environments,v)end
 for path in pairs(paths)do
  local f=assert(io.open(path=='compositions.json'and catalogFile or project_root..'/'..path,'rb'))
  local size=f:seek('end');f:close()
  table.insert(pack.files,{path=path,size=size,sha256=string.rep('a',64),url='https://raw.githubusercontent.com/local/candidate/'..string.rep('a',40)..'/'..path})
  pack.installed_size=pack.installed_size+size
 end
 assert(schema.validate(pack));assert(backend.compatible(pack))
 local ok,err=backend.validate(pack,function(path)return path=='compositions.json'and bytes or read(project_root..'/'..path,false)end)
 assert(ok,id..': '..tostring(err))
 return #data.compositions,#pack.files,pack.installed_size
end
''')
rows=[]
for catalog in sorted(a.catalogs.glob('*/compositions.json')):
 count,files,size=validate(catalog.resolve().as_posix(),catalog.parent.name)
 rows.append({'pack':catalog.parent.name,'compositions':count,'files':files,'installed_bytes':size})
 print(catalog.parent.name+' PASS',flush=True)
assert len(rows)==18
result={'packs':rows,'count':len(rows),'scope':'Local candidate catalogs and actual source PNG headers through runtime schema, compatibility and geometry validators. Placeholder URLs/checksums are schema-only; no source commit pinning, file hash verification, HTTP or gameplay claim.'}
a.output.parent.mkdir(parents=True,exist_ok=True);a.output.write_text(json.dumps(result,indent=2))
