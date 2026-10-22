-- Standalone Gen 1 scenery insertion. Native methods still draw every sprite,
-- animation and UI element once, in their original coordinate system.
local M={}
function M.install(mod,Battle,G,provider)
 local Frame=assert(loadstring(assert(mod:read('lib/native_frame.lua'))))()
 local layers=setmetatable({},{__mode='k'})
 local replay=false
 local function kimStage()
  if not mod.find('kim1025')then return false end
  local loader=mod.game and mod.game.mods
  local bucket=loader and loader.modOptions and loader.modOptions.kim1025
  if not bucket then
   local options=require('src.core.SaveData').loadOptions()
   bucket=options and options.modOptions and options.modOptions.kim1025
  end
  -- KIM's public sprite provider also works with its battle stage disabled.
  -- Its source pack alone must not turn our native scenery insertion off.
  return not bucket or bucket.battleSystem~=false
 end
 local function owns()
  if not provider.enabled()then return false end
  -- A compatible Menu Customizer consumes the provider itself. KIM remains
  -- an explicit unsupported coexistence path until its provider is tested.
  return not mod.find('gen3transparency')and not kimStage()
 end
 local clear,draw=G.clear,G.draw
 G.clear=function(...)
  local target=G.getCanvas();if target then layers[target]=nil end
  return clear(...)
 end
 G.draw=function(source,...)
  if not replay and layers[source]and owns()then
   local marker=layers[source]
   local target=G.getCanvas()
   local w,h;if target then w,h=target:getDimensions()else w,h=G.getDimensions()end
   local frame=Frame.drawRect(G,source,marker,...)
   -- Relay transparent native canvases without baking the painting into
   -- their small pixel grid. Paint once at the final presentation size.
   if target and w==marker.nativeWidth and h==marker.nativeHeight then
    layers[target]={nativeWidth=marker.nativeWidth,nativeHeight=marker.nativeHeight,presentation=marker.presentation,frame=frame}
    return draw(source,...)
   end
   local depth=G.getStackDepth();G.push('all');G.origin();G.setShader();G.setScissor()
   replay=true;local ok,painted=pcall(provider.draw,0,0,w,h,frame,{presentation=marker.presentation});replay=false
   while G.getStackDepth()>depth do G.pop()end
   if not ok then mod.exports.sceneryAdapterError=tostring(painted)end
   if ok and painted and target then layers[target]={nativeWidth=marker.nativeWidth,nativeHeight=marker.nativeHeight,presentation=marker.presentation,frame=frame}end
  end
  return draw(source,...)
 end
 local function prepareSurface(width,height,presentation)
  local target=G.getCanvas()
  local w,h;if target then w,h=target:getDimensions()else w,h=G.getDimensions()end
  local viewW,viewH=G.getDimensions()
  if not provider.prepare(0,0,viewW,viewH,nil,presentation)then return false end
  local source={getWidth=function()return width end,getHeight=function()return height end}
  local frame=Frame.drawRect(G,source,nil,0,0)
  if target then
   G.push('all');G.setShader();G.setBlendMode('replace','premultiplied');G.setColor(0,0,0,0)
   G.rectangle('fill',0,0,width,height);G.pop()
  end
  if not target or w~=width or h~=height then
   local depth=G.getStackDepth();G.push('all');G.origin();G.setShader();G.setScissor()
   local ok,painted=pcall(provider.draw,0,0,w,h,frame,{presentation=presentation})
   while G.getStackDepth()>depth do G.pop()end
   if not ok then mod.exports.sceneryAdapterError=tostring(painted)end
   if not ok or not painted then return false end
  end
  if target then layers[target]={nativeWidth=width,nativeHeight=height,presentation=presentation,frame=frame}end
  return true
 end
 local classic,zone=Battle.drawClassic,Battle.drawZonePass
 Battle.drawZonePass=function(self,...)
  if not self._hdSceneryPaper then return zone(self,...)end
  -- These fills are the native shake pass's exposed white edges only.
  local rectangle=G.rectangle
  G.rectangle=function(mode,...)if mode~='fill'then return rectangle(mode,...)end end
  local result={pcall(zone,self,...)};G.rectangle=rectangle
  if not result[1]then error(result[2],0)end
  return(unpack or table.unpack)(result,2)
 end
 Battle.drawClassic=function(self,...)
  if not owns()or self.blankForAskName or self.blackoutBlank or self:wideLayout()then return classic(self,...)end
  if not prepareSurface(160,144)then return classic(self,...)end
  local rectangle=G.rectangle;local replaced=false
  G.rectangle=function(mode,x,y,w,h,...)
   local r,g,b,a=G.getColor()
   if not replaced and mode=='fill'and x==0 and y==0 and w==160 and h==144 and r==1 and g==1 and b==1 and a==1 then
    replaced=true
    if G.getCanvas()==self.bgCanvas then G.clear(0,0,0,0)end
    return
   end
   return rectangle(mode,x,y,w,h,...)
  end
  local previous=self._hdSceneryPaper;self._hdSceneryPaper=true
  local result={pcall(classic,self,...)}
  self._hdSceneryPaper=previous;G.rectangle=rectangle
  require('src.render.PaletteFX').markTrueColor(0,0,160,144)
  if not result[1]then error(result[2],0)end
  return(unpack or table.unpack)(result,2)
 end
 local Wide=require('src.battle.WideBattle')
 local wide=Wide.draw
 Wide.draw=function(self,...)
  if not owns()or self.blankForAskName or self.blackoutBlank then return wide(self,...)end
  if not prepareSurface(Wide.WIDTH,Wide.HEIGHT,'wide')then return wide(self,...)end
  local renderer=self.game and self.game.renderer
  local paper=not(self:extendedHUD()and renderer and renderer.beginBattleHUDPass and renderer.endBattleHUDPass and self:extendedWorldHUD())
  local rectangle=G.rectangle;local replaced=false
  G.rectangle=function(mode,x,y,w,h,...)
   local _,_,_,alpha=G.getColor()
   if paper and not replaced and mode=='fill'and x==0 and y==0 and w==Wide.WIDTH and h==Wide.HEIGHT and alpha==1 then
    replaced=true;return
   end
   return rectangle(mode,x,y,w,h,...)
  end
  local result={pcall(wide,self,...)};G.rectangle=rectangle
  if not result[1]then error(result[2],0)end
  return(unpack or table.unpack)(result,2)
 end
 return M
end
return M
