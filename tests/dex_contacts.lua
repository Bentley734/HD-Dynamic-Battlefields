local Contact=assert(loadfile(root..'/lib/mound_contact.lua'))()
local make=assert(loadfile(root..'/lib/adapters/dex_contacts.lua'))()
local profile={player={x=64,y=117},opponent={x=176,y=70}}
local source={box={w=64,h=64},ox=0,oy=10,dw=40,dh=48,anchor=1}
local lookup={bake=function(_,species,back,mon,gen,extra)
 if extra.ready==false then return nil,'Sprite sheet is pending'end
 assert(species=='TEST'and gen>=1 and gen<=3)
 if gen==3 then return source end
 local h=back and(gen==1 and 64 or 48)or 56
 return{box={w=h,h=h},ox=0,oy=0,dw=h,dh=h-6,anchor=1}
end}
local mon={species='TEST'}
local frame={}
local battle={player={mon=mon,__g9bsFrame=frame,sprite=frame},enemy={mon=mon,__g9bsFrame=frame,sprite=frame},battlers={[2]={mon=mon},[3]={mon=mon}}}
local mod={find=function(id)return id=='1025dex'and{version='1.5.2'}or nil end}
local centres={[0]={x=32,y=80},[1]={x=200,y=40},[2]={x=90,y=88},[3]={x=152,y=32}}
local ui={picArgs=function(_,species)return species,false end,battlerPic=function()return{__completeDexBattleLift=0}end}
package.loaded['src.core.game3.battle.ui']=ui
package.loaded['src.core.game3.pokemon']={speciesOf=function(m)return m.species end}
package.loaded['src.core.game3.battle.anim']={shownBattler=function(_,b)return b end,present=function()return{}end,coords=function(_,id)return centres[id]end}
package.loaded['src.core.game3.battle.pic_coords']={battlerCoords=function(_,id)return id==0 and{x=72,y=80}or{x=176,y=40}end}
local api=make(mod,function(id)return id end,lookup,Contact,3)
local single,report=api.resolve(battle,nil,profile)
assert(single.player.x==8 and single.player.y==-11)
assert(single.opponent.x==0 and single.opponent.y==-4)
assert(report.slots['0'].y==106 and report.slots['1'].y==66)
assert(battle.player.mon==mon and centres[2].y==88,'Renderer state changed')
battle.double=true
local double=api.resolve(battle,nil,profile)
assert(#double.player.slots==2 and #double.opponent.slots==2)
assert(double.player.slots[1].y==106 and double.player.slots[2].y==106,'Lower ally did not follow actual 1025 clamp')
assert(double.opponent.slots[1].y==66 and double.opponent.slots[2].y==58)
assert(double.player.slots[1].x==32 and double.player.slots[2].x==90)
assert(not single.player.slots,'Doubles mutation leaked')
battle.absent={[2]=true}
local absent,ar=api.resolve(battle,nil,profile)
assert(not absent.player.slots and not ar.slots['2'],'Absent partner retained a mound')
battle.absent=nil
for gen=1,2 do
 local api=make(mod,function(id)return id end,lookup,Contact,gen)
 local b=gen==1 and battle or{player=mon,enemy=mon}
 local screen={activeMon=function()return mon end,pic=function()return frame,true,nil end}
 if gen==2 then b.player={species='OUTGOING_LOGIC_DIFFERENCE'}end
 local c=api.resolve(b,nil,profile,screen)
 assert(c.player.y==90-profile.player.y and c.opponent.y==50-profile.opponent.y)
 local wide=api.resolve(b,'wide',profile,screen)
 assert(wide.player.x-c.player.x==(gen==1 and 20 or 72))
 assert(wide.opponent.x-c.opponent.x==(gen==1 and 136 or 72))
 assert(wide.player.y-c.player.y==(gen==1 and 8 or 0))
end
ui.battlerPic=function()return{}end
local pending,pr=api.resolve(battle,nil,profile)
assert(not pending.player and not pending.opponent and pr.errors['0']=='Sprite sheet is pending','Native fallback was treated as replacement')
mod.find=function()end
assert(api.resolve(battle,nil,profile)==nil,'Disabled peer should retain existing scenery')
print('PASS native 1025 contacts, all four doubles slots, GB classic/wide translations and untouched sprite state')
