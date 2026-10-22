-- Scenery insertion only. Gen 2 retains its own pictures, effects and panels.
local M={}
function M.install(mod,Screen,G,provider)
 local Frame=assert(loadstring(assert(mod:read('lib/native_frame.lua'))))()
 local Chrome=require('src.ui.gen2.Chrome')
 local layers=setmetatable({},{__mode='k'})
 local replay,active=false,0
 -- KIM has no Gen 2 battle stage; its optional sprite source is compatible.
 local function enabled()return provider.enabled()end
 local function paint(w,h,frame,presentation)
  local depth=G.getStackDepth();G.push('all');G.origin();G.setShader();G.setScissor()
  replay=true
  local ok,result=pcall(provider.draw,0,0,w,h,frame,{presentation=presentation})
  replay=false
  while G.getStackDepth()>depth do G.pop()end
  if not ok then mod.exports.sceneryAdapterError=tostring(result)end
  return ok and result
 end
 local clear,draw=G.clear,G.draw
 G.clear=function(...)
  local target=G.getCanvas();if target then layers[target]=nil end
  return clear(...)
 end
 G.draw=function(source,...)
  local marker=layers[source]
  if marker and not replay and enabled()then
   local target=G.getCanvas()
   local w,h;if target then w,h=target:getDimensions()else w,h=G.getDimensions()end
   local frame=Frame.drawRect(G,source,marker,...)
   if target and w==marker.nativeWidth and h==marker.nativeHeight then
    layers[target]={nativeWidth=marker.nativeWidth,nativeHeight=marker.nativeHeight,
     presentation=marker.presentation,frame=frame}
   elseif paint(w,h,frame,marker.presentation)and target then
    layers[target]={nativeWidth=marker.nativeWidth,nativeHeight=marker.nativeHeight,
     presentation=marker.presentation,frame=frame}
   end
  end
  return draw(source,...)
 end
 local paper=Chrome.paletteFill
 Chrome.paletteFill=function(x,y,w,h,palette,...)
  -- Only the screen paper is transparent. Explicit palette fills, HUD panels
  -- and animation objects remain owned by their existing renderers.
  if active>0 and palette==nil and x==0 and y==0 and h==144 and(w==160 or w==304)then return end
  return paper(x,y,w,h,palette,...)
 end
 local scene=Screen.drawScene
 Screen.drawScene=function(self,...)
  if not enabled()then return scene(self,...)end
  local presentation=self:wideLayout()and'wide'or nil
  local width=presentation and 304 or 160
  local viewW,viewH=G.getDimensions()
  local frame=Frame.drawRect(G,{getWidth=function()return width end,getHeight=function()return 144 end},nil,0,0)
  if not provider.prepare(0,0,viewW,viewH,frame,presentation)then return scene(self,...)end
  local target=G.getCanvas()
  local w,h;if target then w,h=target:getDimensions()else w,h=viewW,viewH end
  if target then
   G.push('all');G.setShader();G.setBlendMode('replace','premultiplied');G.setColor(0,0,0,0)
   G.rectangle('fill',0,0,width,144);G.pop()
  end
  if not target or w~=width or h~=144 then
   if not paint(w,h,frame,presentation)then return scene(self,...)end
  end
  if target then layers[target]={nativeWidth=width,nativeHeight=144,presentation=presentation,frame=frame}end
  active=active+1
  local result={pcall(scene,self,...)}
  active=active-1
  if not result[1]then error(result[2],0)end
  return(unpack or table.unpack)(result,2)
 end
 local pic=Screen.drawPic
 Screen.drawPic=function(self,mon,back,...)
  if not enabled()then return pic(self,mon,back,...)end
  local dx,dy=provider.spriteOffset(back and'player'or'opponent',mon and mon.species)
  if dx==0 and dy==0 then return pic(self,mon,back,...)end
  local depth=G.getStackDepth();G.push('all');G.translate(dx,dy)
  local result={pcall(pic,self,mon,back,...)}
  while G.getStackDepth()>depth do G.pop()end
  if not result[1]then error(result[2],0)end
  return(unpack or table.unpack)(result,2)
 end
 return M
end
return M
