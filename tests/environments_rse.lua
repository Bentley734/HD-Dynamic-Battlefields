local maps=assert(loadfile(root..'/metadata/maps/rse.lua'))()
local adapter=assert(loadfile(root..'/lib/environments_rse.lua'))()(maps)
local total=0
for game,entries in pairs(maps)do
 for id,signature in pairs(entries)do
  total=total+1
  local c={game=game,map=id,mapType=signature.mapType,mapBattleType=signature.battleType,terrainName='GRASS'}
  local grass=signature.terrain_overrides and signature.terrain_overrides.GRASS or signature.environment
  assert(adapter:detect(c).environment==grass)
  for terrain,environment in pairs(signature.terrain_overrides or{})do
   c.terrainName=terrain
   assert(adapter:detect(c).environment==environment)
  end
  if signature.water then c.terrainName='WATER';assert(adapter:detect(c).environment==signature.water)end
  c.mapType=999;assert(not adapter:detect(c),'Modified map signature must not inherit native scenery')
 end
end
assert(total==479)
local function detect(game,id,terrain)
 local signature=assert(maps[game][id])
 return adapter:detect{game=game,map=id,mapType=signature.mapType,mapBattleType=signature.battleType,terrainName=terrain}
end
for game,prefix in pairs({ruby='RU_',sapphire='SA_',emerald='EM_'})do
 assert(detect(game,prefix..'ROUTE111','GRASS').environment=='grassland')
 assert(detect(game,prefix..'ROUTE111','SAND').environment=='desert')
 assert(detect(game,prefix..'ROUTE113','GRASS').environment=='ashfield')
 assert(detect(game,prefix..'MT_PYRE_SUMMIT','GRASS').environment=='mt_pyre_summit')
 assert(detect(game,prefix..'MT_PYRE_EXTERIOR','GRASS').environment=='mt_pyre_exterior')
 assert(detect(game,prefix..'ROUTE119','WATER').environment=='river')
 assert(detect(game,prefix..'PACIFIDLOG_TOWN','WATER').environment=='pacifidlog_water')
 for _,room in ipairs({'ABANDONED_SHIP_ROOMS_B1F','ABANDONED_SHIP_HIDDEN_FLOOR_CORRIDORS'})do
  assert(detect(game,prefix..room,'WATER').environment=='abandoned_ship_flooded')
  assert(detect(game,prefix..room,'BUILDING').environment=='abandoned_ship')
 end
 assert(detect(game,prefix..'ROUTE130','GRASS').environment=='grassland')
 assert(detect(game,prefix..'ROUTE130','LONG_GRASS').environment=='grassland')
 assert(detect(game,prefix..'ROUTE130','WATER').environment=='ocean')
 assert(detect(game,prefix..'RUSTBORO_CITY_GYM','BUILDING').environment=='rustboro_gym')
 assert(not detect(game,prefix..'RUSTBORO_CITY_GYM','WATER'))
end
assert(detect('emerald','EM_MOSSDEEP_CITY_SPACE_CENTER_2F','BUILDING').environment=='space_center')
assert(detect('emerald','EM_UNDERWATER_ROUTE124','UNDERWATER').environment=='underwater_ocean')
assert(detect('emerald','EM_SKY_PILLAR_TOP','MOUNTAIN').environment=='sky_pillar_summit')
for _,terrain in ipairs({'CAVE','POND','WATER','KYOGRE'})do
 assert(detect('emerald','EM_MARINE_CAVE_END',terrain).environment=='marine_cave')
end
assert(detect('emerald','EM_TERRA_CAVE_END','GROUDON').environment=='terra_cave')
assert(detect('emerald','EM_MAGMA_HIDEOUT_4F','CAVE').environment=='magma_core')
for game,prefix in pairs({ruby='RU_',sapphire='SA_',emerald='EM_'})do
 assert(detect(game,prefix..'SKY_PILLAR_TOP','RAYQUAZA').environment=='sky_pillar_summit')
end
assert(detect('emerald','EM_BATTLE_FRONTIER_BATTLE_PYRAMID_FLOOR','FRONTIER').environment=='battle_pyramid')
assert(not adapter:detect{game='firered',map='FR_ROUTE1',mapType=3})
assert(not adapter:detect{game='ruby',map='EM_ROUTE111',mapType=3})
assert(not adapter:detect{game='emerald',map='EM_ROUTE111',mapType=3,mapBattleType=999})
print('PASS Hoenn 479 exact map signatures, mixed desert/grass route, rivers, underwater, gym/summit/facility identity and unknown/modified fallback')
