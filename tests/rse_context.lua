local originalRequire=require
local version='emerald'
local active=true
local session={map='EM_ROUTE119'}
local state={wild=true,terrain=4,weather='rain',double=true,
 player={mon={species='TREECKO'}},enemy={mon={species='KECLEON'}}}
local env={family='rse',TERRAIN={GRASS=0,WATER=4,POND=5,UNDERWATER=3,GROUDON=11}}
local rtc={localTime={hours=22},enabled=function(s)assert(s==session);return true end}
require=function(name)
 if name=='src.core.game3.battle'then return{isActive=function()return active end,getState=function()return state end}end
 if name=='src.core.game3.pokemon'then return{speciesOf=function(mon)return mon.species end}end
 if name=='src.core.game3.battle.bg'then return{env=function()return env end,terrainId=function()return 3 end}end
 if name=='src.core.GameVersion'then return{get=function()return version end}end
 if name=='src.core.game3.rtc'then return rtc end
 if name=='src.core.game3.weather'then return{translate=function(id,s)assert(s==session);return id==20 and 3 or id end}end
 return originalRequire(name)
end
local mod={game={session=session,data={maps={EM_ROUTE119={mapType=3,battleType=0}}}}}
local read=assert(loadfile(root..'/lib/adapters/rse_context.lua'))()(mod,function(id)return id end)
require=originalRequire
local c=assert(read())
assert(c.game=='emerald'and c.mapType==3 and c.terrainName=='WATER'and c.water)
assert(c.double and not c.link,'Native doubles must not be mistaken for link battles')
assert(c.timeOfDay=='night'and c.weather=='rain'and c.enemySpecies=='KECLEON')
assert(state.terrain==4 and session.map=='EM_ROUTE119'and rtc.localTime.hours==22)
mod.game.data.maps.EM_ROUTE119.weather=6
assert(read().mapWeather=='fog'and session.savedWeather==nil)
session.savedWeather=0;assert(read().mapWeather=='clear')
session.savedWeather=8;assert(read().mapWeather=='sandstorm')
session.savedWeather=nil;mod.game.data.maps.EM_ROUTE119.weather=20
assert(read().mapWeather=='rain'and session.savedWeather==nil,'Field cycle read changed saved weather')
mod.game.data.maps.EM_ROUTE119.weather=nil
for _,game in ipairs({'ruby','sapphire','emerald'})do version=game;assert(read().game==game)end
state.terrain=nil;c=assert(read());assert(c.underwater and c.terrainName=='UNDERWATER')
state.terrain=11;c=assert(read());assert(c.terrainName=='GROUDON'and not c.water)
state.terrain=0;rtc.localTime.hours=10;assert(read().timeOfDay=='day')
rtc.localTime.hours=25;assert(read().timeOfDay==nil)
state.link=true;assert(read().link)
active=false;assert(not read());active=true
version='firered';assert(not read());version='emerald'
env.family='frlg';assert(not read());env.family='rse'
mod.game=nil;assert(not read())
print('PASS Hoenn read-only context: three versions, terrain/water/underwater, native RTC, doubles separate from link, no state writes and safe fallback')
