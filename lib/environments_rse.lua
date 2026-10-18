-- Exact Hoenn signatures; mixed land/water terrain is resolved per battle.
return function(games)
 local self={}
 function self:detect(context)
  local maps=games[context.game]
  if not maps then return nil,'No Hoenn map adapter for this game'end
  local map=maps[context.map]
  if not map then return nil,'Unmapped Hoenn battle area: '..tostring(context.map)end
  if map.mapType~=context.mapType then return nil,'Hoenn map type changed'end
  if context.mapBattleType~=nil and map.battleType~=context.mapBattleType then return nil,'Hoenn battle-scene signature changed'end
  local name=context.terrainName
  local water=context.water==true or name=='WATER'or name=='POND'or name=='UNDERWATER'
  local environment=map.environment
  if water then
   if not map.water then return nil,'No inspected Hoenn water mapping'end
   environment=map.water
  elseif name and map.terrain_overrides and map.terrain_overrides[name]then
   environment=map.terrain_overrides[name]
  end
  return{environment=environment,map=context.map,water=water,terrain=name}
 end
 return self
end
