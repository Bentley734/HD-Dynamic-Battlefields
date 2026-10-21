-- Window/graphics-mode resize regression in one native battle; no restart or
-- manual display-cache release between viewports.
return function(game,Battle,mod,values,start,render,originalW,originalH,resizeWindow,warmPictures)
 local desktop=resizeWindow~=nil
 resizeWindow=resizeWindow or function(w,h)assert(love.window.updateMode(w,h,{resizable=true,vsync=0}))end
 start('ROUTE101');values.enabled=true;values.timeMode='day';values.selection='fixed'
 local state=Battle.getState()
 local map=game.session.map
 local hp=game.session.party[1].hp
 local rows={}
 local Pokemon=require('src.core.game3.pokemon')
 local Ui=require('src.core.game3.battle.ui')
 local function visiblePicture(back,mon)
  local pic=assert(Ui.sidePic(back,false,Pokemon.speciesOf(mon)))
  -- 1025Dex keeps separate asynchronous sheets for battle and menu previews.
  -- This readback asks for a preview; let that requested sheet finish baking.
  if warmPictures then warmPictures();pic=assert(Ui.sidePic(back,false,Pokemon.speciesOf(mon)))end
  local g=love.graphics
  local canvas=g.newCanvas(pic.image:getWidth(),pic.image:getHeight())
  g.push('all');g.setCanvas(canvas);g.origin();g.setShader();g.clear(0,0,0,0);g.setColor(1,1,1,1);g.draw(pic.image);g.pop()
  local pixels=canvas:newImageData();local visible=false
  for y=0,pixels:getHeight()-1 do
   for x=0,pixels:getWidth()-1 do
    local _,_,_,a=pixels:getPixel(x,y);if a>0 then visible=true;break end
   end
   if visible then break end
  end
  pixels:release();canvas:release()
  assert(visible,'Sprite provider returned transparent art: '..tostring(Pokemon.speciesOf(mon))..' back='..tostring(back))
 end
 render(originalW,originalH,'resize-baseline')
 if state.double then for id=0,3 do visiblePicture(id%2==0,state.battlers[id].mon)end
 else visiblePicture(true,game.session.party[1]);visiblePicture(false,state.enemy.mon)end
 local sizes={{1280,720,'16:9'},{5120,1440,'32:9'},{900,1600,'9:16'},
  {1600,900,'16:9'},{900,2000,'9:20'},{1024,768,'4:3'},{1280,720,'16:9'}}
 for index,size in ipairs(sizes)do
  local w,h,aspect=unpack(size)
  love.graphics.setCanvas()
  resizeWindow(w,h)
  assert(love.graphics.getWidth()==w and love.graphics.getHeight()==h,'Window resize failed')
  values.enabled=false;local before=render(w,h,nil)
  values.enabled=true;local after=render(w,h,'resize-'..index)
  assert(before==after,'Resizing scenery displaced native UI')
  local d=mod.exports.diagnostics()
  assert(d.status=='active'and d.environment=='grassland'and d.aspect==aspect,'Wrong resized composition')
  assert(d.viewport.width==w and d.viewport.height==h,'Stale scenery viewport')
  assert(Battle.getState()==state and game.session.map==map and game.session.party[1].hp==hp,'Resize mutated battle')
  if state.double then
   for id=0,3 do visiblePicture(id%2==0,assert(state.battlers[id]).mon)end
  else visiblePicture(true,game.session.party[1]);visiblePicture(false,state.enemy.mon)end
  rows[#rows+1]={width=w,height=h,aspect=d.aspect,composition=d.composition,metadata=d.metadata,native_ui_calls_unchanged=true,sprite_art_nontransparent=true}
 end
 assert(rows[1].composition==rows[#rows].composition,'Fixed assignment changed after resize roundtrip')
 love.graphics.setCanvas()
 resizeWindow(originalW,originalH)
 return{checks=rows,battle_identity_preserved=true,method=desktop and'desktop-window'or'graphics-mode',scope=(desktop and'Existing desktop SDL window-size changes with normal resize event handling; 'or'Desktop graphics-mode recreation; ')..'Same native battle, no manual cache release. Mobile OS orientation and exhaustive visual grounding are not certified.'}
end


