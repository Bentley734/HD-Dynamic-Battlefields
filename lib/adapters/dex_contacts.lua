-- Read the same stable slots as the native renderer. Only scenery consumes
-- these contacts; no picture call, animation offset or mon is changed here.
return function(mod,identity,lookup,Contact,generation)
 local M={}
 local function find(id)return type(mod.find)=='function'and mod.find(id)or nil end
 local function cloud(mon,battler)
  local peer=find('battle_forms')
  local describe=peer and peer.exports and peer.exports.describe
  if type(describe)~='function'then return false end
  local ok,value=pcall(describe,mon,battler)
  return ok and type(value)=='table'and type(value.dynamax)=='table'or false
 end
 function M.resolve(battle,presentation,profile,screen)
  local result,report={},{slots={},errors={}}
  if not find('1025dex')then return nil,report end
  local groups={player={},opponent={}}
  if generation==3 then
   local Ui=require('src.core.game3.battle.ui')
   local Pokemon=require('src.core.game3.pokemon')
   local Anim=require('src.core.game3.battle.anim')
   local Coords=require('src.core.game3.battle.pic_coords')
   for id=0,battle.double and 3 or 1 do
    local back=id%2==0;local side=back and'player'or'opponent'
    local key=battle.double and id or(back and'player'or'enemy')
    local b=id==0 and battle.player or id==1 and battle.enemy or battle.battlers and battle.battlers[id]
    b=Anim.shownBattler(key,b)or b
    local p=Anim.present(key)
    if b and not(battle.absent and battle.absent[id])and not(p and p.substitute)and not(Ui.showsGhost and Ui.showsGhost(back and'player'or'enemy',battle))then
     local mon=b.mon
     local species=b.species or mon and Pokemon.speciesOf(mon)
     if b.expTransform then
      species=p and p.transformSpecies or not(p and p.pendingTransform)and b.expTransform.species or species
     end
     local picSpecies,shiny=species,false
     if Ui.picArgs then picSpecies,shiny=Ui.picArgs(b,species)end
     local picture=Ui.battlerPic and Ui.battlerPic(key,b,species)
     local ready=picture and picture.__completeDexBattleLift~=nil
     local bake,why=lookup:bake(picSpecies,back,mon,3,{shiny=shiny,cloud=false,ready=not not ready,image=picture and picture.image})
     local base=battle.double and Anim.coords(battle,id)or Coords.battlerCoords(false,id)
     if bake and base then
      local target=Contact.resolve(bake,{x=base.x,y=back and math.min(base.y,80)or base.y,ox=32,oy=32})
      if target then groups[side][#groups[side]+1]={id=id,x=target.x,y=target.y,bake=bake};report.slots[tostring(id)]=target end
     else report.errors[tostring(id)]=why or'Missing native slot'end
    end
   end
  else
   for _,side in ipairs({'player','opponent'})do
    local back=side=='player';local b=back and battle.player or battle.enemy
    local mon=generation==2 and b or b and b.mon
    if generation==2 and screen and screen.activeMon then mon=screen:activeMon(back and'player'or'enemy')end
    -- Gen 2's sides are mons; some native versions expose them as battlers.
    if generation==2 and mon and mon.mon then mon=mon.mon end
    if mon then
     local ready,nativeImage
     if generation==1 then nativeImage=b.sprite;ready=b.__g9bsFrame~=nil and b.sprite==b.__g9bsFrame
     elseif screen and screen.pic then
      local image,trueColor,path=screen:pic(mon,back)
      nativeImage=image;ready=image~=nil and trueColor==true and path==nil
     end
     local bake,why=lookup:bake(identity(mon.species),back,mon,generation,{cloud=cloud(mon,generation==2 and mon or b),ready=not not ready,image=nativeImage})
     if bake then
      local x,y
      if generation==1 then
       x=back and 8 or 96;y=back and 96-bake.box.h or 0
       if presentation=='wide'then x=x+(back and 20 or 136);y=y+(back and 8 or 0)end
      else
       x=back and 16 or 96;y=back and 96-bake.box.h or 0
       if presentation=='wide'then x=x+72 end
      end
      local target=Contact.resolve(bake,{x=x,y=y,ox=0,oy=0})
      if target then groups[side][1]={id=back and 0 or 1,x=target.x,y=target.y,bake=bake};report.slots[side]=target end
     else report.errors[side]=why end
    end
   end
  end
  for side,slots in pairs(groups)do
   if #slots==1 then
    result[side]=Contact.correction(slots[1],profile[side])
   elseif #slots>1 then
    -- A PACK offset may differ for each ally. Each gets its own copy of the
    -- same painted mound, instead of compromising between two ground rows.
    local positions={}
    for _,slot in ipairs(slots)do positions[#positions+1]={id=slot.id,x=slot.x,y=slot.y,width=128,height=32}end
    result[side]={slots=positions}
   end
  end
  return result,report
 end
 return M
end
