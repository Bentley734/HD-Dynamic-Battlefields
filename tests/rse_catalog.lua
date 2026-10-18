local catalog=assert(loadfile(root..'/metadata/rse.lua'))()
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
local paths,environments,aspects,envSeen,aspectSeen={},{},{},{},{}
local ashNight
for _,entry in ipairs(catalog.compositions)do
 assert(P.resolve(catalog.metadata,entry.metadata))
 if entry.night_metadata then assert(P.resolve(catalog.metadata,entry.night_metadata))end
 if not envSeen[entry.environment]then environments[#environments+1]=entry.environment;envSeen[entry.environment]=true end
 if not aspectSeen[entry.aspect_ratio]then aspects[#aspects+1]=entry.aspect_ratio;aspectSeen[entry.aspect_ratio]=true end
 paths[entry.background]=true
 for _,field in ipairs({'backgrounds','mounds','night_mounds'})do
  for _,path in pairs(entry[field]or{})do paths[path]=true end
 end
 if entry.environment=='ashfield'and entry.aspect_ratio=='32:9'then ashNight=entry end
end
assert(#catalog.compositions==126 and #environments==14 and #aspects==9)
assert(not envSeen.underwater_ocean,'Unfinished Hoenn art must not silently reuse a different environment')
assert(ashNight.backgrounds.night:find('night%-v2%.png$'))
local day=P.resolve(catalog.metadata,ashNight.metadata)
local night=P.resolve(catalog.metadata,ashNight.night_metadata)
assert(day.horizon_y~=night.horizon_y and night.horizon_y<.2,'Corrected night geometry must remain separate')
local files={};for path in pairs(paths)do files[#files+1]={path=path}end
local function read(path)
 if path=='compositions.json'then return Json.encode(catalog)end
 local f=assert(io.open(root..'/'..path,'rb'));local b=f:read(33);f:close();return b
end
assert(backend.validate({files=files,environments=environments,aspects=aspects,quality='HD'},read))
print('PASS Hoenn candidate catalog: 126 compositions, 14 families, nine aspects, PNG/geometry validation, distinct corrected night and absent unfinished families')
