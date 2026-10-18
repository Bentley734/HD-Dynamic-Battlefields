local maps=assert(loadfile(root..'/metadata/maps/rse.lua'))()
local adapter=assert(loadfile(root..'/lib/environments_rse.lua'))()(maps)
local total=0
for game,entries in pairs(maps)do
 for id,signature in pairs(entries)do
  total=total+1
  local c={game=game,map=id,mapType=signature.mapType,mapBattleType=signature.battleType,terrainName='GRASS'}
  assert(adapter:detect(c).environment==signature.environment)
  if signature.water then c.terrainName='WATER';assert(adapter:detect(c).environment==signature.water)end
  c.mapType=999;assert(not adapter:detect(c),'Modified map signature must not inherit native scenery')
 end
end
assert(total==478)
local function detect(game,id,terrain)
 local signature=assert(maps[game][id])
 return adapter:detect{game=game,map=id,mapType=signature.mapType,mapBattleType=signature.battleType,terrainName=terrain}
end
for game,prefix in pairs({ruby='RU_',sapphire='SA_',emerald='EM_'})do
 assert(detect(game,prefix..'ROUTE111','GRASS').environment=='grassland')
 assert(detect(game,prefix..'ROUTE111','SAND').environment=='desert')
 assert(detect(game,prefix..'ROUTE113','GRASS').environment=='ashfield')
 assert(detect(game,prefix..'ROUTE119','WATER').environment=='river')
 assert(detect(game,prefix..'RUSTBORO_CITY_GYM','BUILDING').environment=='rustboro_gym')
 assert(not detect(game,prefix..'RUSTBORO_CITY_GYM','WATER'))
end
assert(detect('emerald','EM_UNDERWATER_ROUTE124','UNDERWATER').environment=='underwater_ocean')
assert(detect('emerald','EM_SKY_PILLAR_TOP','MOUNTAIN').environment=='sky_pillar_summit')
assert(detect('emerald','EM_BATTLE_FRONTIER_BATTLE_PYRAMID_FLOOR','FRONTIER').environment=='battle_pyramid')
assert(not adapter:detect{game='firered',map='FR_ROUTE1',mapType=3})
assert(not adapter:detect{game='ruby',map='EM_ROUTE111',mapType=3})
assert(not adapter:detect{game='emerald',map='EM_ROUTE111',mapType=3,mapBattleType=999})
print('PASS Hoenn 478 exact map signatures, mixed desert/grass route, rivers, underwater, gym/summit/facility identity and unknown/modified fallback')
