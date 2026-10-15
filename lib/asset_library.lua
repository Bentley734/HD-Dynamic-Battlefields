-- Installed pack catalog: artwork and metadata enter selection together.
-- Immutable shipped prototypes remain available when cached packs are absent.
return function(mod,store,Json,selection,catalog,scene)
 local self={packs={},sources={},health={},error=nil,revision=0}
 local baseEntries,baseMetadata={},{}
 for i,entry in ipairs(catalog.compositions)do baseEntries[i]=entry end
 for id,data in pairs(catalog.metadata)do baseMetadata[id]=data end
 local function copy(value)return Json.decode(Json.encode(value))end
 function self:refresh(ids)
  local entries,metadata,sources={}, {},{}
  self.error=nil;local health={}
  for i,entry in ipairs(baseEntries)do entries[i]=entry end
  for id,data in pairs(baseMetadata)do metadata[id]=data end
  local seen={};for _,entry in ipairs(entries)do seen[entry.id]=true end
  local installed={}
  for _,id in ipairs(ids or{})do
   local pack=store:installed(id)
   if pack then
    installed[#installed+1]=pack
    local valid,why=store:verify(pack)
    health[id]={valid=valid==true,error=why}
    if valid then
     local ok,data=pcall(Json.decode,store:read(pack,'compositions.json'))
     if ok and type(data)=='table'then
      local prefix='pack:'..pack.id..':'..pack.version..':'
      local function texture(path)
       local key=prefix..path;sources[key]=store:imagePath(pack,path);return key
      end
      for key,value in pairs(data.metadata)do
       local item=copy(value);item.composition_id=prefix..item.composition_id
       if item.inherits then item.inherits=prefix..item.inherits end
       metadata[prefix..key]=item
      end
      for _,original in ipairs(data.compositions)do
       local entry=copy(original);entry.id=prefix..entry.id;entry.metadata=prefix..entry.metadata
       if not seen[entry.id]then
        entry.background=texture(entry.background)
        if entry.backgrounds then for period,path in pairs(entry.backgrounds)do entry.backgrounds[period]=texture(path)end end
        for _,field in ipairs({'mounds','night_mounds'})do
         if entry[field]then for side,path in pairs(entry[field])do entry[field][side]=texture(path)end end
        end
        entry.pack_id=pack.id;entries[#entries+1]=entry;seen[entry.id]=true
       end
      end
     else self.error='Installed pack catalog could not be decoded: '..id;health[id]={valid=false,error=self.error}end
    else self.error=why end
   end
  end
  -- selection holds the original catalog table by reference.
  for i=#catalog.compositions,1,-1 do catalog.compositions[i]=nil end
  for i,entry in ipairs(entries)do catalog.compositions[i]=entry end
  catalog.metadata=metadata;self.sources,self.packs,self.health=sources,installed,health
  scene:release();selection.active=setmetatable({},{__mode='k'})
  self.revision=self.revision+1
  return true
 end
 function self:path(path)return self.sources[path]or mod.assets:path(path)end
 function self:available(entry)return self.sources[entry.background]~=nil or mod:info(entry.background)~=nil end
 return self
end
