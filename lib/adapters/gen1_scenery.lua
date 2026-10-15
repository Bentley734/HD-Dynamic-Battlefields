-- Standalone Gen 1 scenery insertion. Native methods still draw every sprite,
-- animation and UI element once, in their original coordinate system.
local M={}
function M.install(mod,Battle,G,provider)
 local layers=setmetatable({},{__mode='k'})
 local replay=false
 local function owns()
  if not provider.enabled()then return false end
  -- A compatible Menu Customizer consumes the provider itself. KIM remains
  -- an explicit unsupported coexistence path until its provider is tested.
  return not mod.find('gen3transparency')and not mod.find('kim1025')
 end
 local clear,draw=G.clear,G.draw
 G.clear=function(...)
  local target=G.getCanvas();if target then layers[target]=nil end
  return clear(...)
 end
 G.draw=function(source,...)
  if not replay and layers[source]and owns()then
   local target=G.getCanvas()
   local w,h;if target then w,h=target:getDimensions()else w,h=G.getDimensions()end
   local depth=G.getStackDepth();G.push('all');G.origin();G.setShader();G.setScissor()
   replay=true;local ok,painted=pcall(provider.draw,0,0,w,h);replay=false
   while G.getStackDepth()>depth do G.pop()end
   if not ok then mod.exports.sceneryAdapterError=tostring(painted)end
   if ok and painted and target then layers[target]=true end
  end
  return draw(source,...)
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
  local target=G.getCanvas()
  local w,h;if target then w,h=target:getDimensions()else w,h=G.getDimensions()end
  local viewW,viewH=G.getDimensions()
  if not provider.prepare(0,0,viewW,viewH)then return classic(self,...)end
  if target then
   -- Clear only native paper; retain white pixels inside all UI and sprites.
   G.push('all');G.setShader();G.setBlendMode('replace','premultiplied');G.setColor(0,0,0,0)
   G.rectangle('fill',0,0,160,144);G.pop();layers[target]=true
  else
   G.push('all');G.origin();G.setShader();G.setScissor()
   local ok,painted=pcall(provider.draw,0,0,w,h);G.pop()
   if not ok or not painted then return classic(self,...)end
  end
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
 return M
end
return M
