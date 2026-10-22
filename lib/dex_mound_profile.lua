-- HD-only contact lookup for the audited 1025Dex 1.5.2 native sprite provider.
-- Sources and PACK gaps were measured before shadows, crystals and clouds.
local M={}
local unpack=unpack or table.unpack
local function pack(...)return{n=select('#',...),...}end
local function finite(n)return type(n)=='number'and n==n and n~=math.huge and n~=-math.huge end
local function find(mod,id)
 if type(mod.find)~='function'then return end
 local ok,value=pcall(mod.find,mod,id)
 if ok and type(value)=='table'then return value end
end
local function api(handle)return handle and type(handle.exports)=='table'and handle.exports end
local function callable(handle,name)return api(handle)and type(handle.exports[name])=='function'end
local function module(name)
 local ok,value=pcall(require,name)
 return ok and type(value)=='table'and value or nil
end
local function female(mon)
 if type(mon)~='table'then return false end
 if type(mon.isFemale)=='boolean'then return mon.isFemale end
 local gender=mon.gender or mon.sex
 return type(gender)=='string'and(gender:lower()=='female'or gender:lower()=='f')or false
end
local function shiny(mon)
 if type(mon)~='table'then return false end
 if mon.shiny~=nil then return not not mon.shiny end
 if type(mon.dvs)=='table'then
  local stats=module('src.pokemon.Stats')
  if stats and type(stats.isShiny)=='function'then
   local ok,value=pcall(stats.isShiny,mon.dvs);if ok then return not not value end
  end
 end
 return false
end
local function normalize(s)return type(s)=='string'and s:upper():gsub('[^A-Z0-9]','')or nil end

function M.new(mod,loadModule)
 assert(type(mod)=='table'and type(loadModule)=='function','Mound profile needs mod and metadata loader')
 local self={}
 local catalog,gaps,kimCatalog,collapsed
 local kimApi,kimWrapper,observed=nil,nil,{}
 local function validated()
  local peer=find(mod,'1025dex')
  if not peer then return nil,'1025Dex is not enabled'end
  -- Future releases can change private bake math. Do not reuse an old gap
  -- matrix merely because the public sprite-style export still exists.
  if callable(peer,'pictureBake')and peer.exports.pictureBakeVersion==1 then return peer end
  if peer.version~='1.5.2'then return nil,'1025Dex version has not been calibrated'end
  return peer
 end
 local function load(which)
  local ok,value=pcall(loadModule,'metadata/'..which..'.lua')
  return ok and type(value)=='table'and value or nil
 end
 local function sources()
  if not catalog then catalog=load('dex_source_catalog')end
  if not catalog or catalog.peerVersion~='1.5.2'or catalog.schema~=1 then return nil,'Invalid sprite source catalog'end
  for _,field in ipairs({'species','female','eeFemale','eeMissing','staticMissing','staticRemap'})do
   if type(catalog[field])~='table'then return nil,'Invalid sprite source catalog'end
  end
  return catalog
 end
 local function options()
  local live=mod.game and mod.game.mods and mod.game.mods.modOptions
  if type(live)=='table'and type(live['1025dex'])=='table'then return live['1025dex']end
  local save=module('src.core.SaveData')
  if save and type(save.loadOptions)=='function'then
   local ok,value=pcall(save.loadOptions)
   if ok and type(value)=='table'and type(value.modOptions)=='table'then return value.modOptions['1025dex']or{}end
  end
  return{}
 end
 local function opt(opts,key,default)local value=opts[key];if value==nil then return default end;return value end
 local function kimPeer()
  local peer=find(mod,'kim1025')
  return callable(peer,'getDexSpriteSheet')and peer or nil
 end
 local function style(peer,opts,back)
  if callable(peer,'spriteStyleFor')then
   local ok,value=pcall(peer.exports.spriteStyleFor,back and'back'or'front',true)
   if ok and type(value)=='number'and value>=0 and value<=5 and value==math.floor(value)then return value end
  end
  local value=tonumber(opt(opts,back and'player_sprite_style'or'enemy_sprite_style',-1))
  if value==5 and not kimPeer()then return 3 end
  if value and value>=0 and value<=5 and value==math.floor(value)then return value end
  value=tonumber(opt(opts,'sprite_style',3))
  return(value==1 or value==2 or value==3 or value==4 or value==5)and value or 0
 end
 local function view(opts,back)
  if not back then return false,false end
  local value=tonumber(opt(opts,'player_sprite_view',-1))
  if value==0 then return false,false elseif value==1 then return true,false elseif value==2 then return true,true end
  local front=opt(opts,'battle_frontal',false)~=false
  return front,front and opt(opts,'battle_front_flip',false)~=false
 end
 local function identity(species,generation)
  if generation==3 and type(species)=='number'then
   if species==201 then return'UNOWN'end
   if species>=413 and species<=439 then return'UNOWN_'..tostring(species-412)end
  end
  if type(species)=='number'then
   local compat=module('src.mods.Gen3Compat')
   if compat and type(compat.speciesName)=='function'then
    local ok,name=pcall(compat.speciesName,species);if ok then species=name end
   end
  end
  if type(species)~='string'then return end
  if catalog.species[species]then return species end
  if not collapsed then
   collapsed={}
   for id in pairs(catalog.species)do
    local key=normalize(id)
    if collapsed[key]and collapsed[key]~=id then collapsed[key]=false
    elseif collapsed[key]==nil then collapsed[key]=id end
   end
  end
  return collapsed[normalize(species)]or nil
 end
 local function capture(species,side,isShiny,dex,data,record)
  local key=tostring(species)..'|'..tostring(dex or'')
  local request=kimCatalog.requests and kimCatalog.requests[key]
  local stem=request and request.stem
  if not stem then
   local raw=tostring(species);local isFemale=raw:match('_FEMALE$')~=nil
   stem=kimCatalog.speciesToStem and kimCatalog.speciesToStem[raw:gsub('_FEMALE$','')]
   if stem and isFemale then stem=stem..'_female'end
  end
  if not stem then return end
  local folder=(side=='back'and'back'or'front')..(isShiny and'_shiny'or'')
  local value={status='fallback',request=key}
  if data and record then
   local path=request and request.sources and request.sources[folder]
   local expected=path and kimCatalog.records and kimCatalog.records[path]
   if expected and type(record)=='table'and record.width==expected.width
    and record.height==expected.height and record.count==expected.frames then
    value={status='ready',request=key,source='kim/'..path}
   else value={status='unknown',request=key}end
  end
  observed[folder..'/'..stem]=value
 end
 function self:observeKIM()
  if not validated()then return false end
  local peer=kimPeer();local exports=api(peer)
  if not exports then return false end
  if not kimCatalog then kimCatalog=load('dex_kim_sources')end
  if not kimCatalog or peer.version~=kimCatalog.kimVersion or type(kimCatalog.requests)~='table'
   or type(kimCatalog.records)~='table'or type(kimCatalog.speciesToStem)~='table'then return false end
  if exports==kimApi and exports.getDexSpriteSheet==kimWrapper then return true end
  local original=exports.getDexSpriteSheet
  observed={};kimApi=exports
  kimWrapper=function(species,side,isShiny,dex,...)
   -- Observe exactly the public request the sprite provider made. Do not make
   -- an extra decode request, alter its arguments, pixels, metadata or returns.
   local values=pack(pcall(original,species,side,isShiny,dex,...))
   if not values[1]then
    -- 1025Dex catches provider errors and selects its matching-art fallback.
    -- Record that outcome while rethrowing the very same error to its caller.
    capture(species,side,isShiny,dex,nil,nil)
    error(values[2],0)
   end
   capture(species,side,isShiny,dex,values[2],values[3])
   return unpack(values,2,values.n)
  end
  exports.getDexSpriteSheet=kimWrapper
  return true
 end
 function self:bake(species,back,mon,generation,extra)
  local peer,why=validated();if not peer then return nil,why end
  if callable(peer,'pictureBake')and peer.exports.pictureBakeVersion==1 then
   if not extra or extra.ready==false or not extra.image then return nil,'Sprite sheet is pending'end
   local ok,bake=pcall(peer.exports.pictureBake,extra.image)
   if ok and type(bake)=='table'then return bake end
   return nil,'Picture has no live bake geometry'
  end
  local cat;cat,why=sources();if not cat then return nil,why end
  generation=tonumber(generation)
  if generation~=1 and generation~=2 and generation~=3 then return nil,'Unsupported sprite generation'end
  extra=type(extra)=='table'and extra or{}
  if extra.ready==false then return nil,'Sprite sheet is pending'end
  local opts=options();local selected=style(peer,opts,back)
  local id=identity(species,generation);local row=id and cat.species[id]
  -- The Gen3 provider has direct Unown picture slots, independently of the
  -- registered form ID used by native menus.
  local stem=row and((selected==3 or selected==4)and row.ee or row.base)
  if not stem and generation==3 and type(species)=='number'and species>=413 and species<=439 then stem='UNOWN_'..tostring(species-412)end
  if not stem then return nil,'Species is outside the calibrated source catalog'end
  local isFemale=generation~=3 and opt(opts,'sprite_female',true)~=false and female(mon)
  if isFemale then stem=((selected==3 or selected==4)and cat.eeFemale or cat.female)[stem]or stem end
  local isShiny
  if generation==3 then isShiny=not not extra.shiny
  else
   if extra.shiny~=nil then isShiny=not not extra.shiny else isShiny=shiny(mon)end
   isShiny=opt(opts,'sprite_shiny',true)~=false and isShiny
  end
  local front,flip=view(opts,back)
  local folder=(back and not front and'back'or'front')..(isShiny and'_shiny'or'')
  local source,provider='dbk/'..folder..'/'..stem,'dbk'
  if selected==5 then
   if kimPeer()then
    if not self:observeKIM()then return nil,'KIM version has not been calibrated'end
    local seen=observed[folder..'/'..stem]
    if not seen then return nil,'KIM source request is pending'end
    if seen.status=='unknown'then return nil,'KIM source geometry has not been calibrated'end
    if seen.status=='ready'then source,provider=seen.source,'kim'end
   end
   if provider~='kim'and not(cat.eeMissing[folder]or{})[stem]then source,provider='ee/'..folder..'/'..stem,'ee'end
  elseif selected==3 or selected==4 then
   if not(cat.eeMissing[folder]or{})[stem]then source,provider='ee/'..folder..'/'..stem,'ee'end
  elseif selected==1 then
   if not(cat.staticMissing[folder]or{})[stem]then
    local mapped=(cat.staticRemap[folder]or{})[stem]or stem
    source,provider='static/'..folder..'/'..mapped,'static'
   end
  elseif selected==2 then
   local bw=find(mod,'1025dex-bw-sprites')
   if callable(bw,'sprite')and callable(bw,'decodeSprite')then
    local ok,timing=pcall(bw.exports.sprite,folder,stem)
    if ok and type(timing)=='table'then
     if bw.version~='1.0.0'then return nil,'BW sprite version has not been calibrated'end
     source,provider='bw/'..folder..'/'..stem,'bw'
    end
   end
  end
  local mode=tonumber(opt(opts,'sprite_size',1))or 1
  if not finite(mode)then return nil,'Invalid sprite size'end
  if mode>=8 then mode=math.floor(mode/56+.5)end
  if mode<1 then mode=1 end
  if mode~=1 and mode~=2 and mode~=3 then return nil,'Sprite size has not been calibrated'end
  local anchor=tonumber(opt(opts,'sprite_anchor',0))or 0
  if not finite(anchor)then return nil,'Invalid sprite anchor'end
  anchor=math.floor(anchor)
  anchor=math.max(0,math.min(2,anchor))
  local cloud=extra.cloud and opt(opts,'dynamax_cloud',true)~=false and true or false
  local box=not back and generation~=3 and 56 or generation==2 and 48 or 64
  local gap=0
  local union=selected==4 and'first'or'all'
  if anchor==1 then
   if not gaps then gaps=load('dex_pack_gaps')end
   if not gaps or gaps.schema~=1 or type(gaps.sources)~='table'or type(gaps.profiles)~='table'then return nil,'Invalid sprite contact geometry'end
   -- Sourcing the player's front art does not change the logical back slot:
   -- production PACK alignment still uses BACK_SCALE and bx/by metrics.
   local geometryKey=source..'#'..union..(back and front and'@back'or'')
   local profile=gaps.sources[geometryKey]
   if profile==nil then return nil,'Sprite source geometry has not been calibrated'end
   local column=(box==56 and 0 or box==64 and 6 or 12)+(mode-1)*2+(cloud and 2 or 1)
   if profile~=0 then
    gap=gaps.profiles[profile]and gaps.profiles[profile][column]
    if not finite(gap)or gap<0 or gap>=box then return nil,'Invalid sprite contact profile'end
   end
  end
  -- This compact bake represents only the stable vertical contact. Its full
  -- canvas width deliberately retains the renderer's horizontal ground origin.
  return{box={w=box,h=box},ox=0,oy=0,dw=box,dh=box-gap,floatLift=0,
   anchor=anchor,flip=flip,source=source,provider=provider,style=selected,
   species=id or species,stem=stem,folder=folder,shiny=isShiny,female=isFemale,
   front=front,union=union,size=mode,cloud=cloud,contactGap=gap,peerVersion=peer.version}
 end
 self:observeKIM()
 if mod.events and type(mod.events.on)=='function'then
  mod.events:on('mods.loaded',function()self:observeKIM()end,-2100)
  mod.events:on('game.ready',function()self:observeKIM()end,-2100)
 end
 return self
end
return M
