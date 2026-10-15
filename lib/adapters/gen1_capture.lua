-- Gen 1 native-layer adapter, initially exercised by the isolated runtime probe.
-- Calls existing picture methods so send-out/faint/visibility effects stay native.
-- No game simulation state is advanced here and no permanent patches are made.
local M = {}
function M.new(g, BattleState, newCanvas, projection, grid)
 local self = {pictures={},anchors={},diagnostics={}}
 local function target(old,w,h)
  if old and (old:getWidth()~=w or old:getHeight()~=h)then old:release();old=nil end
  return old or newCanvas(w,h,'nearest')
 end
 local function scope(battle, changes, fn)
  local saved={}
  for key,value in pairs(changes)do saved[key]={rawget(battle,key)};battle[key]=value end
  local ok,err=xpcall(fn,tostring)
  for key,value in pairs(saved)do battle[key]=value[1] end
  if not ok then error(err,0)end
 end
 function self:release()
  for _,pic in pairs(self.pictures)do pic:release()end
  if self.ui then self.ui:release()end
  if self.effects then self.effects:release()end
  if self.hudRaw then self.hudRaw:release()end
  if self.hud then self.hud:release()end
  if self.quads then for _,quad in pairs(self.quads)do quad:release()end end
  self.pictures,self.anchors,self.ui,self.effects={},{},nil,nil
  self.quads=nil
  self.hudRaw,self.hud=nil,nil
 end
 function self:capture(battle,layout)
  if battle:wideLayout()then return nil,'Gen 1 wide adapter is not integrated yet' end
  if battle.blankForAskName or battle.blackoutBlank then return nil,'Native blank-screen transition' end
  if battle.fx and battle.fx.wavy then return nil,'Native wavy-screen projection is not integrated yet' end
  local slide=(battle.introSlide or 0)*2
  local oldBack,oldFront=BattleState.backPlacement,BattleState.frontPlacement
  local oldRect=g.rectangle
  local oldDraw=g.draw
  local previousCanvas=g.getCanvas()
  local previousDepth=g.getStackDepth and g.getStackDepth()
  local sprites={}
  local hudTouched={}
  local dpi=1;if grid then dpi=grid.density(layout.viewport)end
  if not dpi then return nil,'Invalid pixel density'end
  g.push('all')
  local ok,err=xpcall(function()
   for _,side in ipairs({'player','opponent'})do
    local nativeSide=side=='player'and'player'or'enemy'
    local desired=layout.referenceScale*layout[side].pokemon.scale
    local zoom,unitZoom
    if grid then zoom,unitZoom=grid.zoom(desired,dpi)else zoom=math.max(1,math.floor(desired+.5));unitZoom=zoom end
    local canvas=target(self.pictures[side],160*zoom,144*zoom);self.pictures[side]=canvas
    local anchor
    BattleState.backPlacement=function(w,h,pad,padL,scale)
     local x,y,s=oldBack(w,h,pad,padL,scale)
     if side=='player'then anchor={x=x+w*scale/2,y=y+(h-pad)*scale}end
     return x,y,s
    end
    BattleState.frontPlacement=function(ex,ey,w,h,scale)
     local x,y,s=oldFront(ex,ey,w,h,scale)
     if side=='opponent'then anchor={x=ex+w/2+slide,y=ey+h}end
     return x,y,s
    end
    g.setCanvas(canvas);g.origin();g.setShader();g.setScissor();g.setBlendMode('alpha');g.clear(0,0,0,0);g.scale(zoom)
    scope(battle,{wideRegion=true},function()battle:drawPicsLayer(slide,0,0,nativeSide,true)end)
    BattleState.backPlacement,BattleState.frontPlacement=oldBack,oldFront
    if not anchor then
     -- Direct trainer draws do not use frontPlacement. Derive their same
     -- native slot from the actual image dimensions, not the background.
     if side=='opponent'and battle.showEnemyTrainer and battle.trainerPic then
      local image=battle:picImage(battle.trainerPic);local w,h=image:getDimensions()
      local tw=math.max(1,math.min(7,math.floor(w/8)));local th=math.max(1,math.min(7,math.floor(h/8)))
      anchor={x=96+8*math.floor((8-tw)/2)+w/2,y=8*(7-th)+h}
     else anchor={x=side=='player'and 36 or 128,y=side=='player'and 96 or 56}end
    end
    self.anchors[side]=anchor
    sprites[side]={width=160,height=144,contact={anchor.x/160,anchor.y/144},scale=unitZoom/desired,
     draw=function(x,y,scale)
      local mode,alpha=g.getBlendMode();g.setBlendMode('alpha','premultiplied')
      local px,py=grid and grid.snap(x,dpi)or math.floor(x+.5),grid and grid.snap(y,dpi)or math.floor(y+.5)
      g.draw(canvas,px,py,0,scale/zoom,scale/zoom)
      g.setBlendMode(mode,alpha)
     end}
   end
   -- Capture UI independently. Remove only the native full-screen paper
   -- initialization; white pixels in fonts, balls, borders and sprites survive.
   self.ui=target(self.ui,160,144)
   self.hudRaw=target(self.hudRaw,160,144)
   self.hud=target(self.hud,160,144)
   g.setCanvas(self.hudRaw);g.origin();g.setShader();g.setScissor();g.clear(0,0,0,0)
   g.setCanvas(self.ui);g.origin();g.setShader();g.setScissor();g.setBlendMode('alpha');g.clear(0,0,0,0)
   local zonePaper=false
   g.rectangle=function(mode,x,y,w,h,...)
    if zonePaper and mode=='fill'then return end
    local r,gg,b,a=g.getColor()
    if mode=='fill'and x==0 and y==0 and w==160 and h==144 and r==1 and gg==1 and b==1 and a==1 then
     g.clear(0,0,0,0);return
    end
    if mode=='fill'and x==0 and y==0 and w==160 and h==144 and r==1 and gg==1 and b==1 and math.abs(a-.85)<.001 then return end
    return oldRect(mode,x,y,w,h,...)
   end
   local originalZone=battle.drawZonePass
   local originalHUD=battle.drawHUDs
   scope(battle,{drawPicsLayer=function()end,drawAnimLayer=function()end,
    drawHUDs=function(state,...)
     local destination=g.getCanvas();g.push('all');g.setCanvas(self.hudRaw)
     g.draw=function(image,a,b,c,...)
      local x,y;if type(a)=='number'then x,y=a,b else x,y=b,c end
      if type(x)=='number'and type(y)=='number'then
       x,y=g.transformPoint(x,y)
       if x<88 and y<32 then hudTouched.opponent=true end
       if x>=72 and y>=56 and y<96 then hudTouched.player=true end
      end
      return oldDraw(image,a,b,c,...)
     end
     originalHUD(state,...);g.draw=oldDraw;g.setCanvas(destination);g.pop()
    end,
    drawZonePass=function(state,...)
     zonePaper=true;originalZone(state,...);zonePaper=false
    end},function()battle:drawClassic()end)
   -- HUD and text are independent native layers. Palette-map the former
   -- through the same native zone function, without re-running battle draw.
   g.setCanvas(self.hud);g.origin();g.setShader();g.setScissor();g.setColor(1,1,1,1);g.setBlendMode('alpha');g.clear(0,0,0,0)
   if battle:colorMode()then
    local fx=battle.fx;local sx,sy=fx and fx.shakeX or 0,fx and fx.shakeY or 0
    if sx==0 and sy==0 and fx and fx.shake and fx.shake>0 then sx=battle.frame%4<2 and 2 or -2 end
    zonePaper=true;originalZone(battle,self.hudRaw,sx,sy);zonePaper=false
   else
    g.setBlendMode('alpha','premultiplied');oldDraw(self.hudRaw,0,0)
   end
   g.rectangle=oldRect
   self.effects=target(self.effects,160,144)
   g.setCanvas(self.effects);g.origin();g.setShader();g.setScissor();g.setBlendMode('alpha');g.clear(0,0,0,0)
   battle:drawAnimLayer(battle:colorMode())
  end,tostring)
  BattleState.backPlacement,BattleState.frontPlacement=oldBack,oldFront
  g.rectangle,g.draw=oldRect,oldDraw
  g.setCanvas(previousCanvas)
  if previousDepth then while g.getStackDepth()>previousDepth do g.pop()end else g.pop()end
  if not ok then self.diagnostics.error=err;return nil,err end
  self.diagnostics.error=nil
  local key=battle.phase=='moveSelect'and'moveSelect'or battle.phase=='mimicSelect'and'mimicSelect'or'bottom'
  local bounds=key=='moveSelect'and{0,64,160,80}or key=='mimicSelect'and{0,56,160,88}or{0,96,160,48}
  local flash=battle.fx and battle.fx.flash and battle.fx.flash>0 and battle.frame%4<2 and .85 or nil
  return {sprites=sprites,ui=self.ui,hud=self.hud,hudTouched=hudTouched,effects=self.effects,anchors=self.anchors,uiBounds=bounds,uiLayoutKey=key,flash=flash}
 end
 function self:drawEffects(frame,layout)
  if not projection then return nil,'Animation projection service is missing'end
  local half=BattleState.PIC_SLOT_SIZE/2
  local function centers(side)
   local native=frame.anchors[side]
   local desired=layout.referenceScale*layout[side].pokemon.scale
   local zoom=math.max(1,math.floor(desired+.5))
   if grid then local _,logical=grid.zoom(desired,assert(grid.density(layout.viewport)));zoom=logical end
   local target=layout[side].pokemon
   return{x=native.x,y=native.y-half},{x=target.x,y=target.y-half*zoom}
  end
  local a,ta=centers('player');local b,tb=centers('opponent')
  local transform,err=projection.between(a,b,ta,tb);if not transform then return nil,err end
  g.push('all');g.setShader();g.setColor(1,1,1,1);g.setBlendMode('alpha','premultiplied')
  local v=layout.viewport;g.intersectScissor(v.x or 0,v.y or 0,v.width,v.height)
  g.draw(frame.effects,transform.target.x,transform.target.y,transform.rotation,transform.scale,transform.scale,transform.source.x,transform.source.y)
  g.pop();return true
 end
 function self:drawUI(frame,layout,metadata,x,y,scale)
  if not metadata.hud then return nil,'Missing native HUD placement metadata'end
  if not self.quads then self.quads={
   player=g.newQuad(72,56,88,40,160,144),opponent=g.newQuad(0,0,88,32,160,144),bottom=g.newQuad(0,96,160,48,160,144)}end
  g.push('all');g.setShader();g.setColor(1,1,1,1);g.setBlendMode('alpha','premultiplied')
  local c=layout.canvas
  local dpi=grid and assert(grid.density(layout.viewport))or 1
  local function zoomFor(desired)
   if grid then local _,logical=grid.zoom(desired,dpi);return logical end
   return math.max(1,math.floor(desired+.5))
  end
  local function snap(value)return grid and grid.snap(value,dpi)or math.floor(value+.5)end
  local activeUI=metadata.hud[frame.uiLayoutKey]or metadata.hud.bottom
  for _,side in ipairs({'opponent','player'})do
   local hud=activeUI and activeUI.hud_overrides and activeUI.hud_overrides[side]or metadata.hud[side]
   local zoom=zoomFor(hud.pixel_scale*layout.referenceScale)
   local hx,hy=snap(c.x+hud.anchor[1]*c.width),snap(c.y+hud.anchor[2]*c.height)
   local paper=metadata.hud.paper
   if paper and frame.hudTouched[side]then
    g.setBlendMode('alpha');g.setColor(paper)
    g.rectangle('fill',hx,hy,88*zoom,(side=='player'and 40 or 32)*zoom)
    g.setColor(1,1,1,1);g.setBlendMode('alpha','premultiplied')
   end
   g.draw(frame.hud,self.quads[side],hx,hy,0,zoom,zoom)
  end
  local bounds=frame.uiBounds
  self.quads.bottom:setViewport(bounds[1],bounds[2],bounds[3],bounds[4],160,144)
  local bottom=activeUI
  if bottom then
   local zoom=zoomFor(bottom.pixel_scale*layout.referenceScale)
   local bx=c.x+bottom.anchor[1]*c.width-80*zoom
   local by=c.y+bottom.anchor[2]*c.height-bounds[4]*zoom
   g.draw(frame.ui,self.quads.bottom,snap(bx),snap(by),0,zoom,zoom)
  else
   g.draw(frame.ui,self.quads.bottom,math.floor(x+.5),math.floor(y+96*scale+.5),0,scale,scale)
  end
  if frame.flash then
   local v=layout.viewport;g.setBlendMode('alpha');g.setColor(1,1,1,frame.flash)
   g.rectangle('fill',v.x or 0,v.y or 0,v.width,v.height)
  end
  g.pop()
  return true
 end
 return self
end
return M
