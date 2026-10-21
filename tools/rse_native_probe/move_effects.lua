-- ROM-backed animation scripts only; does not execute move mechanics.
return function(project,game,Battle,mod,values,start,render,w,h)
 local Anim=require('src.core.game3.battle.anim')
 local Ctx=require('src.core.game3.battle.anim_ctx')
 local Task=require('src.core.game3.task')
 local Moves=require('src.core.game3.battle.moves')
 local Pokemon=require('src.core.game3.pokemon')
 local Json=require('src.link.Json')
 local results={}
 for _,name in ipairs({'TACKLE','WATER_GUN','THUNDERBOLT','SURF','EARTHQUAKE'})do
  start('ROUTE101');values.environment='auto';values.enabled=true;values.timeMode='day'
  render(w,h,nil)
  local composition=assert(mod.exports.diagnostics().composition)
  Anim.vm().headless=false
  local id=assert(Moves.numForName(name),'Missing native move '..name)
  local script=Anim.scriptForMove(id)
  local pack=assert(Anim._pack,'Native animation pack not loaded')
  assert(pack.moves and (pack.moves[id]or pack.moves[tostring(id)])==script,'Generic animation fallback for '..name)
  local done=false
  assert(Anim.launchMove(id,{attackerId=0,targetId=1,attackerSide='player',targetSide='enemy',
   attackerSpecies=Pokemon.speciesOf(game.session.party[1]),targetSpecies=Pokemon.speciesOf(Battle.getState().enemy.mon),
   ctx=Ctx.build(0,1,{moveId=id,moveDmg=5}),onEnd=function()done=true end}),'Native move launch failed')
  assert(Anim.vm().active and not done,'Animation runner skipped native frames')
  local frames,checks=0,{}
  local function checkpoint(label)
   local beforeState=Json.encode({player=Anim.present(0),opponent=Anim.present(1)})
   values.enabled=false;local before=render(w,h,nil)
   values.enabled=true;local after=render(w,h,'effect-'..name:lower()..'-'..label)
   assert(before==after,'Scenery changed native chrome during '..name)
   assert(Json.encode({player=Anim.present(0),opponent=Anim.present(1)})==beforeState,'Scenery mutated native animation presentation')
   assert(mod.exports.diagnostics().composition==composition,'Composition changed during '..name)
   checks[#checks+1]={stage=label,native_presentation_unchanged=true,native_ui_calls_unchanged=true}
  end
  for frame=1,1200 do
   frames=frame;Task.update(1/60);Anim.update(1/60)
   if frame==12 or frame==30 then checkpoint('frame-'..frame)end
   if done then break end
  end
  assert(done and not Anim.vm().active,'Native move animation did not complete: '..name)
  assert(frames>1 and #checks>0,'Native animation skipped frame progression: '..name)
  checkpoint('complete')
  results[#results+1]={move=name,id=id,frames=frames,script_ops=#script,checks=checks,composition=composition}
 end
 return {moves=results,scope='Five ROM-backed native move animation scripts, not damage, turn execution, switching, outcomes or every move.'}
end
