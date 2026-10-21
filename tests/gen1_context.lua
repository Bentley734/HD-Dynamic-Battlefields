local M=assert(loadfile(root..'/lib/adapters/gen1_context.lua'))()
local calls=0
local game,options={}, {hooked=true}
local marker={native=true}
local Battle={newWild=function(g,species,level,opts,tail)
 assert(g==game and species=='MAGIKARP'and level==5 and tail=='unchanged')
 calls=calls+1;return marker
end}
local fishing=M.install(Battle)
assert(Battle.newWild(game,'MAGIKARP',5,options,'unchanged')==marker)
assert(fishing(marker)and marker.native and marker.hooked==nil)
options.hooked=false;assert(fishing(marker),'Capture must survive later options mutation')
local previous=marker;marker={native=true}
assert(Battle.newWild(game,'MAGIKARP',5,nil,'unchanged')==marker)
assert(not fishing(marker)and fishing(previous)and calls==2)
marker=nil;assert(Battle.newWild(game,'MAGIKARP',5,nil,'unchanged')==nil)
assert(not fishing({}))
print('PASS fishing encounter capture preserves native battle identity/arguments and leaves native state untouched')

local maps=assert(loadfile(root..'/metadata/maps/gen1.lua'))()
local classify=assert(loadfile(root..'/lib/environments.lua'))().new(maps)
for _,version in ipairs({'red','blue','yellow'})do
 for _,lastSave in ipairs({'PALLET_TOWN','VIRIDIAN_CITY','CELADON_MART_1F'})do
  local game={save={player={map=lastSave}},overworld={map={id='ROUTE_1'}}}
  local battle={game=game}
  local engine={currentMapId=function(self)return self.game.overworld.map.id end}
  local id=M.map(engine,battle,game)
  local result=assert(classify:detect{game=version,map=id,tileset='OVERWORLD',kind='wild'})
  assert(id=='ROUTE_1'and result.environment=='grassland','Route 1 must not inherit the saved location')
  assert(game.save.player.map==lastSave,'no save mutation')
  assert(M.map({},battle,game)=='ROUTE_1','live map works without native helper')
 end
end
assert(M.map({},nil,{save={player={map='VIRIDIAN_CITY'}}})=='VIRIDIAN_CITY','headless/no-overworld fallback')
assert(M.map({},nil,{overworld={map={id='CELADON_MART_1F'}},save={player={map='ROUTE_1'}}})=='CELADON_MART_1F','current interiors remain interiors')
print('PASS Red/Blue/Yellow live Route 1 classification despite stale town/shop saves; fallback and save preservation')
