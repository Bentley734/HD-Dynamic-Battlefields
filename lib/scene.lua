-- Shared scene compositor. Generation adapters provide sprite draw callbacks;
-- all composition-specific geometry comes from resolved perspective metadata.
local M = {}
function M.new(graphics, perspective, loadImage, sourceIdentity)
 local self = {textures = {}, diagnostics = {}}
 function self:release()
  if self.backgroundQuad then self.backgroundQuad:release();self.backgroundQuad=nil end
  self.sourceRegion=nil
  for _, image in pairs(self.textures) do if image.release then image:release() end end
  self.textures, self.entry, self.metadata = {}, nil, nil
  self.backgroundPath,self.period,self.moundPaths,self.moundSourcePaths=nil,nil,nil,nil
 end
 function self:prepare(entry, catalog, period)
  if type(entry)~='table'or type(entry.background)~='string'or type(entry.metadata)~='string'then return nil,'Invalid composition entry'end
  period=period or'day'
  if period~='day'and period~='night'then return nil,'Invalid artwork period'end
  local metadataId=period=='night'and entry.night_metadata or entry.metadata
  local metadata, err = perspective.resolve(catalog, metadataId)
  if not metadata then self.diagnostics.error = err; return nil, err end
  if metadata.aspect_ratio ~= entry.aspect_ratio then return nil, 'Artwork and perspective aspect families differ' end
  local backgroundPath=entry.backgrounds and entry.backgrounds[period]or(period=='day'and entry.background)
  if not backgroundPath then return nil,'No '..period..' artwork installed for '..entry.id end
  local moundPaths=period=='night'and entry.night_mounds or entry.mounds
  if period=='night'and entry.mounds and not moundPaths then return nil,'No matching night mound artwork installed'end
  local pending = {}
  local function load(path)
   if pending[path] then return pending[path] end
   if self.textures[path]then pending[path]=self.textures[path];return pending[path]end
   local ok, image = pcall(loadImage, path)
   if not ok or not image then return nil, 'Unable to load texture: '..tostring(path) end
   pending[path] = image; return image
  end
  local background,quad,region; background, err = load(backgroundPath)
  if background then
   local width,height=background:getWidth(),background:getHeight()
   local r=period=='night'and(entry.night_source_rect or entry.source_rect)or entry.source_rect
   if r then
    local function finite(n)return type(n)=='number'and n==n and n~=math.huge and n~=-math.huge end
    if type(r)~='table'or not finite(r.x)or not finite(r.y)or not finite(r.width)or not finite(r.height)or r.x<0 or r.y<0 or r.width<=0 or r.height<=0 or r.x+r.width>width or r.y+r.height>height then
     err='Invalid authored artwork region';background=nil
    else width,height=r.width,r.height end
   end
   local imageRatio = width/height
   local referenceRatio = metadata.reference_size.width/metadata.reference_size.height
   if math.abs(imageRatio/referenceRatio-1) > .01 then err = 'Artwork dimensions do not match perspective reference';background = nil end
   if background and not r and math.abs(imageRatio/referenceRatio-1)>1e-9 then
    -- Integer source dimensions can differ by a pixel from the exact ratio.
    -- Sample a centered subpixel region rather than stretching either axis.
    local rw,rh=width,height
    if imageRatio>referenceRatio then rw=height*referenceRatio else rh=width/referenceRatio end
    r={x=(width-rw)/2,y=(height-rh)/2,width=rw,height=rh}
   end
   if background and r then
    local ok,value=pcall(graphics.newQuad,r.x,r.y,r.width,r.height,background:getWidth(),background:getHeight())
    if ok then quad=value;region=r else background=nil;err='Unable to create artwork region'end
   end
  end
  if background then
   for _, side in ipairs({'player','opponent'}) do
    local spec = moundPaths and moundPaths[side]
    if spec then local image;image,err = load(spec);if not image then background = nil;break end end
   end
  end
  if not background then
   if quad then quad:release()end
   for path, image in pairs(pending) do if self.textures[path]~=image and image.release then image:release() end end
   self.diagnostics.error = err; return nil, err
  end
  -- Retain shared current textures across a successful scene transition.
  -- On failure above, borrowed textures remain owned by the previous scene.
  local sourcePaths={}
  for side,path in pairs(moundPaths or{})do sourcePaths[side]=sourceIdentity and sourceIdentity(path)or path end
  if self.backgroundQuad then self.backgroundQuad:release()end
  for path,image in pairs(self.textures)do if pending[path]~=image and image.release then image:release()end end
  self.textures, self.entry, self.metadata = pending, entry, metadata
  self.moundSourcePaths=sourcePaths
  self.backgroundPath,self.period,self.moundPaths=backgroundPath,period,moundPaths
  self.backgroundQuad=quad
  self.sourceRegion=region
  self.diagnostics = {composition=entry.id, metadata=metadata.composition_id}
  return true
 end
 function self:layout(viewport, adjustments, corrections)
  if not self.metadata then return nil, 'No scene prepared' end
  if type(viewport)~='table'or type(viewport.width)~='number'or type(viewport.height)~='number'or viewport.width<=0 or viewport.height<=0 or viewport.width~=viewport.width or viewport.height~=viewport.height or viewport.width==math.huge or viewport.height==math.huge then return nil,'Invalid viewport'end
  local ref = self.metadata.reference_size
  local scale = math.max(viewport.width/ref.width,viewport.height/ref.height)
  -- Use the same uniform cover transform for art and anchors. Intermediate
  -- window ratios must never stretch the painting or detach its grounding.
  local canvas = {x=(viewport.x or 0)+(viewport.width-ref.width*scale)/2,
   y=(viewport.y or 0)+(viewport.height-ref.height*scale)/2,
   width=ref.width*scale,height=ref.height*scale}
  local layout, err = perspective.layout(self.metadata,canvas,adjustments,corrections)
  if not layout then return nil,err end
  layout.canvas, layout.viewport, layout.referenceScale = canvas, viewport, scale
  return layout
 end
 function self:draw(layout, sprites, options)
  options = options or {};local g = graphics
  if not self.entry then return nil, 'No scene prepared' end
  local depth=g.getStackDepth and g.getStackDepth()
  g.push('all')
  local ok, err = xpcall(function()
   local v,c = layout.viewport,layout.canvas
   g.intersectScissor(v.x or 0,v.y or 0,v.width,v.height)
   local tint=options.tint
   if tint then g.setColor(tint[1],tint[2],tint[3],tint[4]or 1)else g.setColor(1,1,1,1)end
   local bg = self.textures[self.backgroundPath]
   local region=self.sourceRegion
   if self.backgroundQuad then
    g.draw(bg,self.backgroundQuad,c.x,c.y,0,c.width/region.width,c.height/region.height)
   else g.draw(bg,c.x,c.y,0,c.width/bg:getWidth(),c.height/bg:getHeight())end
   if options.atmosphere and options.climate then options.atmosphere:draw(v,options.climate)end
   local sides = {'player','opponent'}
   table.sort(sides,function(a,b)return layout[a].layer < layout[b].layer end)
   for _, side in ipairs(sides) do
    local p = layout[side]
    local mound = self.moundPaths and self.moundPaths[side]
    if mound and options.mounds ~= false then
     local image = self.textures[mound]
     local width, height = p.mound.bounds[1]*p.mound.scale,p.mound.bounds[2]*p.mound.scale
     local fit = math.min(width/image:getWidth(),height/image:getHeight())
     width,height = image:getWidth()*fit,image:getHeight()*fit
     if tint then g.setColor(tint[1],tint[2],tint[3],tint[4]or 1)else g.setColor(1,1,1,1)end
     local origin=p.mound.origin
     g.draw(image,p.mound.x-width*(origin and origin[1]or .5),p.mound.y-height*(origin and origin[2]or .5),0,width/image:getWidth(),height/image:getHeight())
    end
    local sprite = sprites and sprites[side]
    if sprite and sprite.visible ~= false then
     local scale = layout.referenceScale*p.pokemon.scale*(sprite.scale or 1)
     local position, why = perspective.spriteOrigin(p.pokemon,sprite.width,sprite.height,sprite.contact,scale)
     if not position then error(why) end
     if sprite.shadow then
      g.setColor(0,0,0,.18)
      g.ellipse('fill',p.pokemon.x+p.shadow.x,p.pokemon.y+p.shadow.y,
       sprite.width*scale*.32,math.max(1,sprite.height*scale*.045))
     end
     g.setColor(1,1,1,1);sprite.draw(position.x,position.y,scale)
    end
   end
   if options.calibration then self:calibration(layout) end
  end,tostring)
  if depth then while g.getStackDepth()>depth do g.pop()end else g.pop()end
  if not ok then self.diagnostics.error = err;return nil,err end
  return true
 end
 function self:calibration(layout)
  local g,c = graphics,layout.canvas
  g.setLineWidth(1)
  g.setColor(1,.8,0,.9);g.line(c.x,layout.horizon,c.x+c.width,layout.horizon)
  local safe = layout.safe_area
  g.setColor(0,1,1,.9);g.rectangle('line',safe.x,safe.y,safe.w,safe.h)
  for _,side in ipairs({'player','opponent'}) do
   local p = layout[side];local m = p.mound
   g.setColor(side=='player' and 1 or .2,side=='player' and .3 or 1,.4,1)
   g.rectangle('line',m.x-m.bounds[1]*m.scale/2,m.y-m.bounds[2]*m.scale/2,m.bounds[1]*m.scale,m.bounds[2]*m.scale)
   g.line(p.pokemon.x-10,p.pokemon.y,p.pokemon.x+10,p.pokemon.y)
   g.line(p.pokemon.x,p.pokemon.y-10,p.pokemon.x,p.pokemon.y+10)
   g.line(m.x,m.y,c.x+c.width/2,layout.horizon)
   g.print(string.format('%s ground %.4f, %.4f',side,(p.pokemon.x-c.x)/c.width,(p.pokemon.y-c.y)/c.height),m.x+12,m.y+12)
  end
  g.setColor(1,1,1,1)
 end
 return self
end
return M
