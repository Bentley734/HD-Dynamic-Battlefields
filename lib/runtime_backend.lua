-- v0.3.88 public cache/network facade. No raw filesystem or archive mounting.
return function(mod, perspective)
 local Json = require('src.link.Json')
 local Semver = require('src.mods.Semver')
 local Version = require('src.core.Version')
 local b = {encode=Json.encode,decode=Json.decode}
 function b.hash(bytes) return love.data.encode('string','hex',love.data.hash('sha256',bytes)) end
 function b.read(path) return mod.cache:read(path) end
 function b.write(path,bytes) return mod.cache:write(path,bytes) end
 function b.delete(path) return mod.cache:delete(path) end
 function b.get(url) return mod.fetch:get(url,{maxSeconds=30}) end
 function b.poll(handle) return mod.fetch:poll(handle) end
 function b.cancel(handle) return mod.fetch:cancel(handle) end
 function b.release(handle) return mod.fetch:release(handle) end
 function b.imagePath(path) return 'mod_cache/'..mod.id..'/'..path end
 function b.compatible(pack)
  if type(pack.game_version) ~= 'string' then return nil,'Missing runtime compatibility range' end
  if not Semver.satisfies(Version.engine,pack.game_version) then return nil,'Pack requires gen1recomp '..pack.game_version end
  return true
 end
 function b.validate(pack,read)
  local bytes = read('compositions.json')
  if not bytes then return nil,'Missing compositions.json' end
  local ok, data = pcall(Json.decode,bytes)
  if not ok or type(data)~='table' or type(data.metadata)~='table' or type(data.compositions)~='table' or #data.compositions==0 then return nil,'Invalid composition catalog' end
  local files={};for _,file in ipairs(pack.files)do files[file.path]=true end
  local seen,coverage,aspectCoverage={},{},{}
  local declaredEnvironments,declaredAspects={},{}
  for _,name in ipairs(pack.environments)do declaredEnvironments[name]=true end
  for _,name in ipairs(pack.aspects)do declaredAspects[name]=true end
  local function integer(n)return type(n)=='number'and n==n and n>0 and n%1==0 end
  local function finite(n)return type(n)=='number'and n==n and n~=math.huge and n~=-math.huge end
  local function region(value)
   return value==nil or type(value)=='table'and finite(value.x)and finite(value.y)and finite(value.width)and finite(value.height)
    and value.x>=0 and value.y>=0 and value.width>0 and value.height>0
  end
  local imageHeaders={}
  local function png(path,transparent)
   local header=imageHeaders[path]
   if not header then
    local bytes=read(path)
    if type(bytes)~='string'or #bytes<33 or bytes:sub(1,8)~='\137PNG\13\10\26\10'or bytes:sub(13,16)~='IHDR'then return nil,'Invalid PNG header: '..tostring(path)end
    local function u32(offset)local a,b,c,d=bytes:byte(offset,offset+3);return((a*256+b)*256+c)*256+d end
    local w,h=u32(17),u32(21);local color=bytes:byte(26)
    if w<1 or h<1 or w>16384 or h>16384 or w*h>33554432 then return nil,'Texture dimensions exceed safety budget: '..path end
    if bytes:byte(25)~=8 or(color~=2 and color~=6)then return nil,'Pack textures must use 8-bit RGB/RGBA PNG: '..path end
    header={width=w,height=h,alpha=color==6};imageHeaders[path]=header
   end
   if transparent and not header.alpha then return nil,'Mound texture lacks an alpha channel: '..path end
   return header
  end
  local function artwork(path,crop,meta)
   local header,err=png(path,false);if not header then return nil,err end
   local w,h=header.width,header.height
   if crop then
    if crop.x+crop.width>w or crop.y+crop.height>h then return nil,'Artwork crop exceeds PNG bounds: '..path end
    w,h=crop.width,crop.height
   end
   local expected=meta.reference_size.width/meta.reference_size.height
   if math.abs((w/h)/expected-1)>.01 then return nil,'Artwork aspect differs from perspective reference: '..path end
   return true
  end
  for _,entry in ipairs(data.compositions)do
   if type(entry)~='table' or type(entry.id)~='string' or seen[entry.id] then return nil,'Invalid/duplicate composition ID' end
   seen[entry.id]=true
   if not declaredEnvironments[entry.environment]or not declaredAspects[entry.aspect_ratio]then return nil,'Composition is outside declared pack coverage'end
   if entry.quality~=pack.quality then return nil,'Composition quality differs from pack tier'end
   if not integer(entry.variation)then return nil,'Invalid background variation'end
   if not region(entry.source_rect)or not region(entry.night_source_rect)then return nil,'Invalid artwork sampling region'end
   coverage[entry.environment],aspectCoverage[entry.aspect_ratio]=true,true
   local meta,err=perspective.resolve(data.metadata,entry.metadata)
   if not meta then return nil,err end
   if meta.composition_id~=entry.id then return nil,'Composition metadata identity mismatch'end
   if meta.aspect_ratio~=entry.aspect_ratio then return nil,'Composition aspect metadata mismatch' end
   local nightMeta=meta
   if entry.night_metadata~=nil then
    if type(entry.night_metadata)~='string'or not entry.backgrounds then return nil,'Invalid night perspective reference'end
    nightMeta,err=perspective.resolve(data.metadata,entry.night_metadata)
    if not nightMeta then return nil,err end
    if nightMeta.composition_id~=entry.night_metadata or nightMeta.aspect_ratio~=entry.aspect_ratio then return nil,'Night perspective identity/aspect mismatch'end
   end
   if not files[entry.background] then return nil,'Undeclared background texture' end
   if type(entry.mounds)~='table' or not files[entry.mounds.player] or not files[entry.mounds.opponent] then return nil,'Missing independent mound assets' end
   if entry.backgrounds then
    if type(entry.backgrounds)~='table'or entry.backgrounds.day~=entry.background or not files[entry.backgrounds.day]or not files[entry.backgrounds.night]or entry.backgrounds.day==entry.backgrounds.night then return nil,'Missing separate day/night artwork'end
    if type(entry.night_mounds)~='table'or not files[entry.night_mounds.player]or not files[entry.night_mounds.opponent]then return nil,'Missing independent night mounds'end
   end
   local matches,why=artwork(entry.background,entry.source_rect,meta);if not matches then return nil,why end
   if entry.backgrounds then
    matches,why=artwork(entry.backgrounds.night,entry.night_source_rect or entry.source_rect,nightMeta)
    if not matches then return nil,why end
   end
   for _,field in ipairs({'mounds','night_mounds'})do
    for _,path in pairs(entry[field]or{})do local header,why=png(path,true);if not header then return nil,why end end
   end
  end
  for name in pairs(declaredEnvironments)do if not coverage[name]then return nil,'Declared environment has no composition'end end
  for name in pairs(declaredAspects)do if not aspectCoverage[name]then return nil,'Declared aspect has no composition'end end
  return true
 end
 return b
end
