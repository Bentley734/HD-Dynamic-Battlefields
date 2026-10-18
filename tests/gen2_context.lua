local Screen={Battle={BATTLETYPE_FISH=4}}
local battle={wild=true,battleType=4,player={species='TOTODILE'},enemy={species='MAGIKARP'},weather='rain'}
local screen=setmetatable({battle=battle},Screen)
local top=screen
local clock='NITE'
local world={map={id='VIOLET_CITY',def={tileset='JOHTO',environment='TOWN'}},playerState='walk',
 hour=function()return 23 end,timeOfDay=function(self,hour)assert(hour==23);return clock end}
local mod={game={stack={top=function()return top end},world=world}}
local read=assert(loadfile(root..'/lib/adapters/gen2_context.lua'))()(mod,Screen,function(s)return s end)
local ctx=assert(read())
assert(ctx.screen==screen and ctx.battle==battle and ctx.fishing and not ctx.surfing)
assert(ctx.timeOfDay=='night'and ctx.weather=='rain'and ctx.enemySpecies=='MAGIKARP')
battle.battleType=0;clock='MORN';world.playerState='surf_pika'
ctx=assert(read());assert(ctx.surfing and not ctx.fishing and ctx.timeOfDay=='day')
screen.link=true;assert(read().link)
top={};assert(not read())
top=screen;world.map=nil;assert(not read())
assert(battle.player.species=='TOTODILE'and battle.weather=='rain')
print('PASS Gen2 read-only context: actual screen/model separation, native fishing type, surf states, clock, weather and overlay fallback')
