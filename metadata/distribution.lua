-- Author-time union for downloads. Runtime game catalogs stay independent.
local base=assert(loadfile('metadata/prototype.lua'))()
local gen2=assert(loadfile('metadata/gen2.lua'))()
local ids={}
for _,entry in ipairs(base.compositions)do ids[entry.id]=true end
for _,entry in ipairs(gen2.compositions)do
 if not ids[entry.id]then base.compositions[#base.compositions+1]=entry;ids[entry.id]=true end
end
for key,value in pairs(gen2.metadata)do
 if not base.metadata[key]then base.metadata[key]=value end
end
return base
