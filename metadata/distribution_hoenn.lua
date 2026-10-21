-- Author-time release candidate union; not the shipped download index.
-- Keep distribution.lua independent: Hoenn reuse authoring consumes that union.
local result=assert(loadfile('metadata/distribution.lua'))()
local hoenn=assert(loadfile('metadata/rse.lua'))()
local ids={}
local function same(a,b)
 if type(a)~=type(b)then return false end
 if type(a)~='table'then return a==b end
 for k,v in pairs(a)do if not same(v,b[k])then return false end end
 for k in pairs(b)do if a[k]==nil then return false end end
 return true
end
for _,entry in ipairs(result.compositions)do ids[entry.id]=entry end
for _,entry in ipairs(hoenn.compositions)do
 if ids[entry.id]then
  assert(same(ids[entry.id],entry),'Conflicting composition '..entry.id)
 else
  result.compositions[#result.compositions+1]=entry;ids[entry.id]=entry
 end
end
for key,value in pairs(hoenn.metadata)do
 if result.metadata[key]then assert(same(result.metadata[key],value),'Conflicting metadata '..key)
 else result.metadata[key]=value end
end
return result
