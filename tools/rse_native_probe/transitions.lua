-- Native presentation sequences, deliberately separate from full-turn coverage.
return function(project,game,Battle,mod,values,start,render,w,h)
 local Anim=require('src.core.game3.battle.anim')
 local Task=require('src.core.game3.task')
 local Json=require('src.link.Json')
 start('ROUTE101');values.environment='auto';values.enabled=true;values.timeMode='day'
 render(w,h,nil)
 local composition=assert(mod.exports.diagnostics().composition)
 local results={}
 local function snapshot(id)
  local p=assert(Anim.present(id))
  return Json.encode({visible=p.visible,ox=p.ox,oy=p.oy,scale=p.scale})
 end
 local function check(id,label)
  local native=snapshot(id)
  values.enabled=false;local before=render(w,h,nil)
  values.enabled=true;local after=render(w,h,'transition-'..label)
  assert(before==after,'Scenery changed native chrome during '..label)
  assert(snapshot(id)==native,'Scenery mutated native sprite presentation during '..label)
  assert(mod.exports.diagnostics().composition==composition,'Composition changed during '..label)
  results[#results+1]={stage=label,battler=id,native_presentation_unchanged=true,native_ui_calls_unchanged=true,composition=composition}
 end
 for _,id in ipairs({1,0})do
  local side=id==1 and'opponent'or'player'
  local done=false
  Anim.faintMon(id,{playSe=false,onComplete=function()done=true end})
  for frame=1,80 do
   Task.update(1/60);Anim.update(1/60)
   if frame==8 then check(id,side..'-faint-mid')end
   if done then break end
  end
  assert(done and Anim.present(id).visible==false,'Native faint did not hide '..side)
  check(id,side..'-fainted')
  done=false
  Anim.sendOutMon(id,{onComplete=function()done=true end})
  for frame=1,100 do
   Task.update(1/60);Anim.update(1/60)
   if frame==20 then check(id,side..'-sendout-mid')end
   if done then break end
  end
  local p=Anim.present(id)
  assert(done and p.visible and p.oy==0 and p.scale==1,'Native send-out did not settle '..side)
  -- Ball-open particles/palette can outlive the body tween callback.
  for _=1,40 do Task.update(1/60);Anim.update(1/60)end
  check(id,side..'-sendout-complete')
 end
 return {checks=results,scope='Native faint/send-out presentation APIs and shared task ticks; no battle turn, switch mechanics, move execution or outcome coverage.'}
end
