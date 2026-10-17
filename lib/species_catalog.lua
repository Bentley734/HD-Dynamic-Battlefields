-- Read the effective content registry, including native Gen 3 species and forms.
-- Rebuilt when the chooser opens, so this mod's load priority cannot freeze out
-- species registered later by content or sprite mods.
local M={}
function M.collect(registry,data)
 local rows,seen,slots={},{},{}
 local function add(id,record,fallback)
  if type(id)~='string'or type(record)~='table'or seen[id]then return end
  if type(record.name)~='string'and not record.baseStats and not record.dex and not record.gen3Species then return end
  local slot=tonumber(record.gen3Species or record.index)
  if fallback and slot and slots[slot]then return end
  seen[id]=true
  local row={id=id,name=record.name or id,slot=slot,dex=tonumber(record.dex or record.national)}
  rows[#rows+1]=row;if slot then slots[slot]=id end
 end
 if registry and type(registry.each)=='function'then
  local iterator,state,first=registry:each()
  if type(iterator)=='function'then
   for id,record in iterator,state,first do add(id,record or registry:get(id))end
  elseif type(iterator)=='table'then
   for _,id in ipairs(iterator)do add(id,registry:get(id))end
  end
 end
 for id,record in pairs(data or{})do add(id,record,true)end
 local labels={};for _,row in ipairs(rows)do labels[row.name]=(labels[row.name]or 0)+1 end
 -- Several mods give every regional/cosmetic form the base display name.
 -- Keep those independently selectable and visibly distinguishable.
 for _,row in ipairs(rows)do if labels[row.name]>1 then row.name=row.id:gsub('_',' ')end end
 table.sort(rows,function(a,b)if a.name==b.name then return a.id<b.id end;return a.name<b.name end)
 return rows,slots
end
function M.new(mod)
 local self={rows={},slots={}}
 function self:refresh(game)
  self.rows,self.slots=M.collect(mod.content and mod.content.pokemon,game and game.data and game.data.pokemon)
  return self.rows
 end
 function self:identity(ref)
  if type(ref)=='number'then return self.slots[ref]end
  return type(ref)=='string'and ref or nil
 end
 return self
end
return M
