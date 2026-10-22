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

local Screen={StatBox={}}
local native=setmetatable({kind='trainer',enemy={fainted=true}},Screen)
local stack={states={native}}
function stack:top()return self.states[#self.states]end
local sceneGame={stack=stack}
assert(M.battle(Screen,sceneGame)==native,'normal battle identity')
local box=setmetatable({},Screen.StatBox)
stack.states={native,box}
assert(M.battle(Screen,sceneGame)==native,'transparent level-up box retains its underlying battle')
assert(native.enemy.fainted==true,'scenery context never revives fainted battlers')
stack.states={native,setmetatable({},Screen.StatBox),box}
assert(M.battle(Screen,sceneGame)==native,'recognized transparent stat overlays retain battle identity')
box.isOpaque=true;assert(M.battle(Screen,sceneGame)==nil,'opaque stat overlay remains authoritative');box.isOpaque=nil
for _,intervening in ipairs({{}, {isOpaque=true}, setmetatable({isOpaque=true},Screen.StatBox)})do
 stack.states={native,intervening,box}
 assert(M.battle(Screen,sceneGame)==nil,'do not cross opaque or unrelated child screens')
end
stack.states={native,{}}
assert(M.battle(Screen,sceneGame)==nil,'unrelated transparent child is not a stats overlay')
stack.states={native,{isOpaque=true}}
assert(M.battle(Screen,sceneGame)==nil,'opaque party or bag does not expose scenery')
stack.states={box};assert(M.battle(Screen,sceneGame)==nil,'orphan stats box has no battle scenery')
stack.states={};assert(M.battle(Screen,sceneGame)==nil,'empty stack')
assert(M.battle(Screen,{})==nil and M.battle(Screen,nil)==nil,'missing game or stack')
print('PASS battle scene survives native level-up stats without crossing opaque/unrelated screens or changing battler state')

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
