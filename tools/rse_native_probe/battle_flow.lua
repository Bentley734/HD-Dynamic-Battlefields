-- Isolated native trainer battle, with automatic native action selection.
return function(project,game,Battle,cache,mod,values,render,w,h,double)
 local Pokemon=require('src.core.game3.pokemon')
 local Task=require('src.core.game3.task')
 local Anim=require('src.core.game3.battle.anim')
 local Ui=require('src.core.game3.battle.ui')
 local Message=require('src.ui.game3.message')
 local Json=require('src.link.Json')
 Battle.reset();Task.clear();Message.reset()
 local prefix=({ruby='RU_',sapphire='SA_',emerald='EM_',firered='FR_',leafgreen='FR_'})[game.session.version]
 game.session.map=prefix..((game.session.version=='firered'or game.session.version=='leafgreen')and'ROUTE_1'or'ROUTE101')
 for _,mon in ipairs(game.session.party)do
  mon.hp=mon.maxHp;mon.status=nil;mon.status1=0
  for i,pp in ipairs(mon.maxPp or{})do mon.pp[i]=pp end
 end
 local party={}
 for _,species in ipairs({'POOCHYENA','ZIGZAGOON','WURMPLE'})do
  party[#party+1]={species=assert(Pokemon.speciesFromName(species)),level=3}
 end
 local result,final
 assert(Battle.start{playerParty=game.session.party,foe={party=party},wild=false,double=double,
  trainerClass=1,trainerClassName='TRAINER',trainerName='FLOW',autoFight=true,headless=false,
  session=game.session,cache=cache,mapType=3,mapKind='outdoor',terrain=0,fade=false,
  onDone=function(outcome,state)result=outcome;final=state end})
 local state=Battle.getState()
 local initialHp=state.enemy.mon.hp
 local phases,seen,checkpoints={},{},{}
 local previousSpecies,changed,damage,vmFrames=Pokemon.speciesOf(state.enemy.mon),false,false,0
 local previousBySlot={}
 if double then for _,id in ipairs({1,3})do previousBySlot[id]=Pokemon.speciesOf(state.battlers[id].mon)end end
 local savedInput=game.input
 game.input={wasPressed=function(_,key)return key=='a'end,isDown=function(_,key)return key=='a'end}
 values.environment='auto';values.timeMode='day';values.weatherMode='clear';values.enabled=true
 local frames=0
 for frame=1,18000 do
  frames=frame
  Task.update(1/60);Battle.update(1/60,game);Message.tick();Ui.tick()
  if Message.isTyping()then Message.skipReveal()elseif Message.isWaiting()then Message.advance()end
  if Anim.vm().active then vmFrames=vmFrames+1 end
  if state.enemy.mon.hp<initialHp then damage=true end
  -- A doubles replacement can occupy either foe slot. The legacy enemy
  -- alias only follows slot 1 and cannot prove slot 3's replacement.
  if double then
   for _,id in ipairs({1,3})do
    local battler=state.battlers[id]
    if battler and battler.mon then
     local mon=battler.mon
     if mon.hp<mon.maxHp then damage=true end
     local current=Pokemon.speciesOf(mon)
     if previousBySlot[id]and current~=previousBySlot[id]then changed=true end
     previousBySlot[id]=current
    end
   end
  end
  local species=Pokemon.speciesOf(state.enemy.mon)
  if species~=previousSpecies then changed=true;previousSpecies=species end
  local phase=Battle._phase
  if phase and not seen[phase]then
   seen[phase]=true;phases[#phases+1]=phase
   values.enabled=false;local before=render(w,h,nil)
   values.enabled=true;local after=render(w,h,'flow-'..phase)
   assert(before==after,'Scenery changed native UI during battle phase '..phase)
   local d=mod.exports.diagnostics()
   assert(d.status=='active','Scenery failed during battle phase '..phase..': '..Json.encode(d))
   checkpoints[#checkpoints+1]={phase=phase,composition=d.composition,native_ui_calls_unchanged=true}
  end
  if not Battle.isActive()then break end
 end
 game.input=savedInput
 local intro=require('src.core.game3.battle.intro_seq')
 local monAnimations={}
 for _,sprite in pairs(require('src.core.game3.battle.mon_anim_battle')._active)do
  monAnimations[#monAnimations+1]={species=sprite.species,data_species=sprite.data and sprite.data[2],anim=sprite.animId,frames=sprite.frames}
 end
 assert(result=='win'and final and final.over,'Native trainer battle did not win: '..Json.encode({result=result,phase=Battle._phase,frames=frames,phases=phases,
  enemy_species=state.enemy.species,enemy_mon_species=state.enemy.mon.species,foe_species={party[1].species,party[2].species,party[3].species},mon_animations=monAnimations,task_count=Task.count(),anim_busy=Anim.busy(),intro_step=intro._i,intro_waiting=intro._waiting,intro_mon_waiting=intro._waitingMonAnim,message_open=Message.isOpen(),message_typing=Message.isTyping(),message_waiting=Message.isWaiting()}))
 assert(damage and changed,'Trainer flow did not include damage and opponent replacement')
 assert(vmFrames>0,'Full-flow fixture skipped move animation VM')
 return {result=result,frames=frames,turns=final.turn,damage_verified=damage,opponent_replacement_verified=changed,
  animation_vm_frames=vmFrames,phases=phases,checks=checkpoints,
  scope='Native autoFight trainer battle against three low-level foes; real intro, damage, animations, faint/replacement and win. Not player input/menu selection, voluntary player switch, all species/moves or save integration.'}
end
