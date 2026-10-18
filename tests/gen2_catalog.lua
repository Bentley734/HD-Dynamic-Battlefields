local catalog=assert(loadfile(root..'/metadata/gen2.lua'))()
local P=assert(loadfile(root..'/lib/perspective.lua'))()
local Json=assert(loadfile(engine..'/src/link/Json.lua'))()
local originalRequire=require
require=function(name)
 if name=='src.link.Json'then return Json end
 if name=='src.mods.Semver'then return{satisfies=function()return true end}end
 if name=='src.core.Version'then return{engine='0.3.89'}end
 return originalRequire(name)
end
local backend=assert(loadfile(root..'/lib/runtime_backend.lua'))()({},P)
require=originalRequire
local files,environments,aspects,paths,envSet,aspectSet={},{},{},{},{},{}
for _,entry in ipairs(catalog.compositions)do
 assert(P.resolve(catalog.metadata,entry.metadata))
 if entry.night_metadata then assert(P.resolve(catalog.metadata,entry.night_metadata))end
 if not envSet[entry.environment]then environments[#environments+1]=entry.environment;envSet[entry.environment]=true end
 if not aspectSet[entry.aspect_ratio]then aspects[#aspects+1]=entry.aspect_ratio;aspectSet[entry.aspect_ratio]=true end
 paths[entry.background]=true
 for _,field in ipairs({'backgrounds','mounds','night_mounds'})do
  for _,path in pairs(entry[field]or{})do paths[path]=true end
 end
end
for path in pairs(paths)do files[#files+1]={path=path}end
local encoded=Json.encode(catalog)
local function read(path)
 if path=='compositions.json'then return encoded end
 local file=assert(io.open(root..'/'..path,'rb'));local bytes=file:read(33);file:close();return bytes
end
local pack={files=files,environments=environments,aspects=aspects,quality='HD'}
assert(backend.validate(pack,read))
assert(#catalog.compositions==477 and #environments==53 and #aspects==9)
local entry
for _,item in ipairs(catalog.compositions)do if item.night_metadata then entry=item;break end end
local nightId=entry.night_metadata
entry.night_metadata='missing-night-geometry';encoded=Json.encode(catalog)
assert(not backend.validate(pack,read),'Missing night geometry must reject pack')
entry.night_metadata=nightId
local night=catalog.metadata[nightId]
local previous=night.aspect_ratio;night.aspect_ratio='invalid';encoded=Json.encode(catalog)
assert(not backend.validate(pack,read),'Night aspect mismatch must reject pack')
night.aspect_ratio=previous
print('PASS Gen2 draft catalog: 477 compositions, 53 families, nine aspects, actual PNG headers, independent night geometry and invalid-night rejection')
