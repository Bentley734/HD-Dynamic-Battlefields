-- Exact game/map/tileset signatures; unknown or modified maps retain native art.
local M={}
function M.new(maps)
 local self={}
 function self:detect(context)
  local game=maps[context.game]
  if not game then return nil,'Unsupported Gen 2 game'end
  local map=game[context.map]
  if not map then return nil,'Unknown Gen 2 map: '..tostring(context.map)end
  if context.tileset~=map.tileset or context.mapType~=map.environment_type then
   return nil,'Gen 2 map signature differs from inspected metadata'
  end
  local trigger=context.fishing and'fishing'or context.surfing and'surf'or'land'
  local environment=map.encounters[trigger]
  -- Natural water maps share a water painting for both kinds of water encounter.
  -- Dry-only interiors cannot acquire water art from a generic fallback.
  if not environment and trigger~='land'and map.encounters.land then
   local family=map.encounters.land
   if family=='ocean'or family=='pond'or family=='river'or family=='cave_water'then environment=family end
  end
  if not environment then return nil,'No inspected '..trigger..' habitat for this map'end
  return{environment=environment,map=context.map,tileset=map.tileset,water=trigger~='land',trigger=trigger}
 end
 return self
end
return M
