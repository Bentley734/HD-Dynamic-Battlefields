-- Shared classification dispatcher. No runtime map-name guessing.
local M={}
function M.new(gen1Maps)
 local self={}
 function self:detect(context)
  if context.game~='red'and context.game~='blue'and context.game~='yellow'then return nil,'No verified generation map adapter'end
  local map=gen1Maps[context.map]
  if not map then return nil,'Unknown map: '..tostring(context.map)end
  if not context.tileset or context.tileset~=map.tileset then return nil,'Map tileset differs from inspected metadata'end
  local environment=map.environment
  if context.surfing or context.fishing then
   if not map.water then return nil,'Water terrain has no explicit mapping for this map'end
   environment=map.water
  end
  if context.kind=='wild'then
   local species=context.enemySpecies
   if species=='MEWTWO'and context.map=='CERULEAN_CAVE_B1F'then environment='legendary_mewtwo'
   elseif species=='ARTICUNO'and context.map=='SEAFOAM_ISLANDS_B4F'then environment='legendary_articuno'
   elseif species=='ZAPDOS'and context.map=='POWER_PLANT'then environment='legendary_zapdos'
   elseif species=='MOLTRES'and context.map=='VICTORY_ROAD_2F'then environment='legendary_moltres'end
  end
  return {environment=environment,map=context.map,tileset=map.tileset,water=context.surfing==true or context.fishing==true}
 end
 return self
end
return M
