-- Native map type + explicit ID mapping. Shared art does not imply shared IDs.
return function(maps)
 local self={}
 function self:detect(context)
  if context.game~='firered'and context.game~='leafgreen'then return nil,'No verified FR/LG adapter'end
  local map=maps[context.map]
  if not map then return nil,'Unmapped FR/LG area: '..tostring(context.map)end
  if map.mapType~=context.mapType then return nil,'FR/LG map signature changed'end
  local environment=map.environment
  if context.water then
   if not map.water then return nil,'No inspected water mapping for this FR/LG area'end
   environment=map.water
  end
  if context.kind=='wild'then
   local species=context.enemySpecies
   if species=='MEWTWO'and context.map=='FR_CERULEAN_CAVE_B1F'then environment='legendary_mewtwo'
   elseif species=='ARTICUNO'and context.map=='FR_SEAFOAM_ISLANDS_B4F'then environment='legendary_articuno'
   elseif species=='ZAPDOS'and context.map=='FR_POWER_PLANT'then environment='legendary_zapdos'
   elseif species=='MOLTRES'and context.map=='FR_MT_EMBER_SUMMIT'then environment='legendary_moltres'end
  end
  return{environment=environment,map=context.map,water=context.water==true}
 end
 return self
end
