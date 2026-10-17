local maps=dofile(root..'/metadata/maps/frlg.lua')
local classifier=dofile(root..'/lib/environments_frlg.lua')(maps)
local catalog=dofile(root..'/metadata/prototype.lua')
local available={};for _,entry in ipairs(catalog.compositions)do available[entry.environment]=true end
for id,map in pairs(maps)do
 assert(available[map.environment],id..': missing habitat '..map.environment)
 if map.water then assert(available[map.water],id..': missing water habitat')end
 for _,game in ipairs({'firered','leafgreen'})do
  assert(classifier:detect{game=game,map=id,mapType=map.mapType}.environment==map.environment)
  assert(not classifier:detect{game=game,map=id,mapType=-1})
 end
end
assert(classifier:detect{game='firered',map='FR_MT_EMBER_SUMMIT',mapType=maps.FR_MT_EMBER_SUMMIT.mapType,kind='wild',enemySpecies='MOLTRES'}.environment=='legendary_moltres')
assert(classifier:detect{game='leafgreen',map='FR_ROUTE_21_NORTH',mapType=maps.FR_ROUTE_21_NORTH.mapType,water=true}.environment=='ocean')
assert(not classifier:detect{game='emerald',map='FR_ROUTE_1',mapType=maps.FR_ROUTE_1.mapType})
assert(not classifier:detect{game='firered',map='UNKNOWN_MAP',mapType=1})
print('PASS explicit FR/LG habitat signatures, installed art coverage, water and Moltres location')
