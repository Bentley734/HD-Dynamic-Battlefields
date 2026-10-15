-- Read-only translation of the runtime's resolved terrain. This does not
-- replace scene selection, battle logic, sprites, UI or native terrain IDs.
return function(Bg,catalog)
 local self={}
 function self:read()
  local env=Bg.env();local family=env and env.family
  local names=catalog[family]
  if not names then return nil,'Unsupported Gen 3 environment family'end
  local terrain=Bg.terrainId();local selected
  for name,id in pairs(env.TERRAIN or{})do
   if id==terrain and names[name]then
    if selected and selected~=names[name]then return nil,'Ambiguous runtime terrain mapping'end
    selected=names[name]
   end
  end
  if not selected then return nil,'Unmapped native terrain '..tostring(terrain)end
  return {environment=selected,terrain=terrain,family=family}
 end
 return self
end
