return function(ctx)
 local G,game,battle,exports=ctx.G,ctx.game,ctx.battle,ctx.exports
 local Json,write=ctx.Json,ctx.write
 local options=ctx.options
 local Font=require('src.render.Font');local Hud=require('src.render.HudTiles')
 local wide=require('src.battle.WideBattle')
 local traces,original={},{Font.drawCode,Font.drawBox,Hud.tile,battle.drawPicsLayer}
 local function note(name,...)
  local a,b=G.transformPoint(0,0);local c,d=G.transformPoint(1,1)
  local r,g,blue,alpha=G.getColor()
  traces[#traces+1]=Json.encode({name=name,args={...},transform={a,b,c,d},color={r,g,blue,alpha},clip={G.getScissor()}})
 end
 Font.drawCode=function(...)note('glyph',...);return original[1](...)end
 Font.drawBox=function(...)note('box',...);return original[2](...)end
 Hud.tile=function(...)note('tile',...);return original[3](...)end
 battle.drawPicsLayer=function(self,...)note('pictures',...);return original[4](self,...)end
 game.save.options.battleLayout='wide';assert(battle:wideLayout())
 local checks={}
 local function render(w,h,fit,enabled,name)
  assert(love.window.setMode(w,h,{resizable=true}))
  options.enabled=enabled;game.save.options.battleFit=fit
  local logical=G.newCanvas(wide.WIDTH,wide.HEIGHT,{dpiscale=1})
  G.setCanvas(logical);G.origin();G.clear(0,0,0,0);traces={}
  battle:draw()
  local trace=table.concat(traces,'\n')
  G.setCanvas()
  if enabled then
   local pixels=logical:newImageData();local _,_,_,alpha=pixels:getPixel(152,50)
   assert(alpha==0,'Scenery was baked into the native WIDE canvas');pixels:release()
  end
  G.setCanvas();G.origin();G.clear(.04,.04,.04,1)
  local scale=math.min(w/wide.WIDTH,h/wide.HEIGHT)
  if fit=='fixed'and scale>=1 then scale=math.floor(scale)end
  -- Off-center placement verifies the actual draw origin is respected.
  local x,y=math.floor((w-wide.WIDTH*scale)/3),math.floor((h-wide.HEIGHT*scale)/3)
  G.setColor(1,1,1,1);G.draw(logical,x,y,0,scale,scale)
  local captured=false
  G.captureScreenshot(function(pixels)
   if name then write(name,pixels:encode('png'):getString())end
   if enabled then
    local r,g,b=pixels:getPixel(w-1,h-1)
    assert(math.abs(r-.04)>.01 or math.abs(g-.04)>.01 or math.abs(b-.04)>.01,'WIDE scenery did not fill the window')
   end
   pixels:release();captured=true
  end)
  G.present();assert(captured);logical:release()
  return trace,{x=x,y=y,width=304*scale,height=144*scale}
 end
 for _,size in ipairs({{1920,1080},{5120,1440},{900,1600},{1279,799}})do
  for _,fit in ipairs({'fixed','fill'})do
   local before=render(size[1],size[2],fit,false)
   local name='wide-'..size[1]..'x'..size[2]..'-'..fit..'.png'
   local after,frame=render(size[1],size[2],fit,true,name)
   assert(before==after,'WIDE native picture/UI/color/scissor trace changed')
   local d=exports.diagnostics();assert(d.status=='active')
   checks[#checks+1]={width=size[1],height=size[2],fit=fit,native_trace_unchanged=true,native_frame=frame,composition=d.composition}
  end
 end
 local rectangle=G.rectangle;local pic=battle.drawPicsLayer
 battle.drawPicsLayer=function()error('injected WIDE picture failure')end
 assert(not pcall(battle.draw,battle));assert(G.rectangle==rectangle,'WIDE paper override leaked')
 battle.drawPicsLayer=pic
 Font.drawCode,Font.drawBox,Hud.tile,battle.drawPicsLayer=unpack(original)
 game.save.options.battleLayout='classic';game.save.options.battleFit='fixed';options.enabled=true
 write('wide-rendering.json',Json.encode({game=ctx.gameVersion,runtime=ctx.runtime,checks=checks,
  scope='Native WIDE rendering and unmodified UI/picture traces; constructed command screen, not gameplay traversal.'}))
end
