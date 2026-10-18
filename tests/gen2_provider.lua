package.path=engine..'/?.lua;'..package.path
local Screen={Battle={BATTLETYPE_FISH=4}}
package.loaded['src.ui.gen2.BattleState']=Screen
package.loaded['src.core.GameVersion']={generation=function()return 2 end,get=function()return 'crystal'end}
local draws=0
love={graphics={push=function()end,pop=function()end,intersectScissor=function()end,setColor=function()end,
 draw=function()draws=draws+1 end,newQuad=function()return{release=function()end}end,
 newImage=function(path)
  local file=assert(io.open(root..'/'..path,'rb'));local header=file:read(24);file:close()
  local function n(offset)local a,b,c,d=header:byte(offset,offset+3);return((a*256+b)*256+c)*256+d end
  local w,h=n(17),n(21)
  return{setFilter=function()end,getWidth=function()return w end,getHeight=function()return h end,release=function()end}
 end}}
local battle={wild=true,battleType=4,player={species='TOTODILE'},enemy={species='MAGIKARP'}}
local screen=setmetatable({battle=battle},Screen)
local top=screen
local maps=assert(loadfile(root..'/metadata/maps/gen2.lua'))()
local spec=maps.crystal.VIOLET_CITY
local world={map={id='VIOLET_CITY',def={tileset=spec.tileset,environment=spec.environment_type}},
 playerState='walk',hour=function()return 23 end,timeOfDay=function()return 'NITE'end}
local values={enabled=true,environment='auto',selection='random',mounds=true,timeMode='auto',weatherMode='clear',animation='off'}
local mod={id='hd-dynamic-battlefields',path=root,exports={},assets={path=function(_,p)return p end},
 cache={read=function()end,write=function()return true end},storage={read=function()end,write=function()return true end},
 events={on=function()end},options={define=function()end,get=function(_,k)return values[k]end},
 hooks={wrap=function()error('Must not claim battle UI composition')end},
 game={data={},save={},world=world,stack={top=function()return top end}}}
function mod:read(path)
 if path=='lib/settings.lua'then return'return function()end'end
 if path=='lib/adapters/gen2_scenery.lua'then return'return {install=function()end}'end
 local f=assert(io.open(root..'/'..path));local s=f:read('*a');f:close();return s
end
function mod:info()return true end
assert(loadfile(root..'/main.lua'))()(mod)
local provider=assert(mod.exports.battlefieldScenery)
assert(provider.draw(0,0,1920,1080));assert(draws==3)
local diagnostics=mod.exports.diagnostics()
assert(diagnostics.period=='night'and diagnostics.timeSource=='game')
assert(diagnostics.environment=='pond')
top={};draws=0;assert(not provider.draw(0,0,1920,1080));assert(draws==0)
top=screen;world.map.def.tileset='modified';assert(not provider.draw(0,0,1920,1080))
print('PASS Gen2 provider integration: real source image dimensions, fishing habitat, native clock/night art, overlay and modified-map fallback')
