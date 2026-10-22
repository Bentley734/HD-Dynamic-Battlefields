-- Latest runtime JSON plus a graphics spy: scenery must never acquire UI hooks.
package.path=engine..'/?.lua;'..package.path
local Battle={StatBox={},newWild=function()return nil end}
package.loaded['src.battle.BattleState']=Battle
package.loaded['src.core.GameVersion']={generation=function()return 1 end,get=function()return 'red'end}
local draws=0
love={graphics={push=function()end,pop=function()end,intersectScissor=function()end,setColor=function()end,
 draw=function()draws=draws+1 end,newQuad=function()return{release=function()end}end,
 newImage=function(path)
  local mound=path:find('mound')
  return{setFilter=function()end,getWidth=function()return mound and 900 or 1920 end,
   getHeight=function()return mound and 300 or 1080 end,release=function()end}
 end}}
local battle=setmetatable({kind='wild'},Battle)
local states={battle}
local values={enabled=true,environment='grassland',selection='random',mounds=true,timeMode='day',weatherMode='clear',animation='off'}
local mod={id='hd-dynamic-battlefields',cache={read=function()end,write=function()return true end},path=root,exports={},assets={path=function(_,p)return p end},
 options={define=function()end,get=function(_,k)return values[k]end},
 storage={read=function()end,write=function()return true end},events={on=function()end},
 hooks={wrap=function()error('Scenery must not install compositor/UI hooks')end},
 game={data={maps={ROUTE_1={tileset='OVERWORLD'}}},save={player={map='ROUTE_1'}},stack={states=states,top=function()return states[#states]end}}}
function mod:read(path)if path=='lib/settings.lua'then return 'return function()end'end;if path=='lib/adapters/gen1_scenery.lua'then return 'return {install=function()end}'end;local f=assert(io.open(root..'/'..path));local s=f:read('*a');f:close();return s end
function mod:info()return true end
assert(loadfile(root..'/main.lua'))()(mod)
local provider=assert(mod.exports.battlefieldScenery)
assert(provider.apiVersion==1 and provider.enabled())
assert(provider.draw(0,0,1920,1080));assert(draws==3,'Only one background and two mounds may be drawn')
local composition=mod.exports.diagnostics().composition
local statBox=setmetatable({},Battle.StatBox)
states[2]=statBox
values.aspect='16:9' -- the one bundled family can uniformly cover any viewport
for _,viewport in ipairs({{640,480},{1024,768},{1280,800},{1536,1024},{1279,799},{1281,801},{1920,1080},{5120,1440},{900,1600}})do
 for _,period in ipairs({'day','night'})do
  values.timeMode=period;draws=0
  assert(provider.draw(0,0,viewport[1],viewport[2]),'stat box must preserve underlying scenery')
  assert(draws==3,'stats overlay does not remove or duplicate background/mounds')
  assert(mod.exports.diagnostics().composition==composition,'level-up retains the active battle variation')
  assert(mod.exports.diagnostics().period==period,'level-up retains artwork period')
 end
end
states[2]={};draws=0;assert(not provider.draw(0,0,1920,1080)and draws==0,'unrelated child screens retain native fallback')
states[2]=statBox;statBox.isOpaque=true;assert(not provider.draw(0,0,1920,1080),'opaque overlays retain native fallback');statBox.isOpaque=nil
states[2]={isOpaque=true};states[3]=statBox;assert(not provider.draw(0,0,1920,1080),'stats cannot expose scenery through an opaque child');states[3]=nil
states[2]=statBox;assert(provider.draw(0,0,1920,1080),'returning from child screens restores the battle scene')
states[2]=nil
values.mounds=false;draws=0;assert(provider.draw(0,0,1920,1080));assert(draws==1)
values.enabled=false;draws=0;assert(not provider.draw(0,0,1920,1080));assert(draws==0)
assert(next(battle)== 'kind','Battle state must remain unchanged')
print('PASS scenery-only contract: level-up scene retention across periods/viewports; opaque/unrelated fallback; no UI/compositor ownership; optional mounds and disabled fallback')
