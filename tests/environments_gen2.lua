local maps=assert(loadfile(root..'/metadata/maps/gen2.lua'))()
local detector=assert(loadfile(root..'/lib/environments_gen2.lua'))().new(maps)
local catalog=assert(loadfile(root..'/metadata/gen2.lua'))()
local families={};for _,entry in ipairs(catalog.compositions)do families[entry.environment]=true end
local count=0
for game,locations in pairs(maps)do for name,spec in pairs(locations)do
 count=count+1
 for trigger,environment in pairs(spec.encounters)do
  local result=assert(detector:detect({game=game,map=name,tileset=spec.tileset,mapType=spec.environment_type,
   fishing=trigger=='fishing',surfing=trigger=='surf'}))
  assert(result.environment==environment and families[environment])
 end
 assert(not detector:detect({game=game,map=name,tileset='modified',mapType=spec.environment_type}))
end end
assert(count==485)
local function habitat(map,trigger)
 local spec=assert(maps.crystal[map])
 return detector:detect({game='crystal',map=map,tileset=spec.tileset,mapType=spec.environment_type,
  fishing=trigger=='fishing',surfing=trigger=='surf'})
end
assert(habitat('UNION_CAVE_1F','land').environment=='cave')
assert(habitat('UNION_CAVE_1F','surf').environment=='cave_water')
assert(habitat('ROUTE_40','surf').environment=='ocean')
assert(habitat('VIOLET_CITY','fishing').environment=='pond')
assert(habitat('OLIVINE_PORT','surf').environment=='harbor_water')
assert(not habitat('AZALEA_GYM','fishing'))
assert(not habitat('OLIVINE_PORT','land'))
assert(not detector:detect({game='red',map='VIOLET_CITY'}))
print('PASS Gen2 exact map signatures: 485 game/maps, every mapped trigger has catalog art, dry/water separation and modified-map fallback')
