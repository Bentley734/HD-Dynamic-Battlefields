-- FR/LG scenery only. Native/UI-mod layers and HD Sprites' camera stay owned
-- by their existing renderers; only the terrain's art is replaced.
local M={}
function M.install(mod,G,provider)
 local Battle=require('src.core.game3.battle')
 local Ui=require('src.core.game3.battle.ui')
 local Chrome=require('src.ui.game3.battle_chrome')
 local Bg=require('src.core.game3.battle.bg')
 local Renderer=require('src.render.Renderer')
 local Display=require('src.core.game3.display')
 local marked=setmetatable({},{__mode='k'})
 local pictures=setmetatable({},{__mode='k'})
 local entries=setmetatable({},{__mode='k'})
 local inBattle,painting,adjusting=false,false,false
 local blank=G.newImage(love.image.newImageData(256,160))
 local battleWrapper,drawWrapper,blitWrapper
 local function hd()
  local found=mod.find('gen3-hd-sprites');local api=found and found.exports
  return api and api.isActive and api.isActive()and api.enabled('battle')and not Display.planesBroken and api or nil
 end
 local function prepare()
  if not provider.enabled()or Display.planesBroken then return false end
  local w,h=G.getDimensions();return provider.prepare(0,0,w,h)
 end
 local function mark(entry,side,species)
  if inBattle and entry and entry.image then pictures[entry.image]={side=side,species=species}end
  return entry
 end
 local sidePic=Ui.sidePic
 Ui.sidePic=function(back,ignore,species,...)
  return mark(sidePic(back,ignore,species,...),back and'player'or'opponent',species)
 end
 local centre=Ui.battlerSpriteCenter
 Ui.battlerSpriteCenter=function(side,species,...)
  local x,y=centre(side,species,...)
  if inBattle then
   local player=side=='player'or type(side)=='number'and side%2==0
   local dx,dy=provider.spriteOffset(player and'player'or'opponent',species);return x+dx,y+dy
  end
  return x,y
 end
 local okAnim,MonAnim=pcall(require,'src.core.game3.mon_anim')
 if okAnim and type(MonAnim.framePic)=='function'then
  local frame=MonAnim.framePic
  MonAnim.framePic=function(species,...)return mark(frame(species,...),'opponent',species)end
 end
 local terrain=Bg.draw
 Bg.draw=function(...)
  if not inBattle or not prepare()then return terrain(...)end
  local library=hd()
  if library then
   -- Let HD Sprites retain its own prefit, camera and side shifts. Give its
   -- wallpaper/pad pass transparent terrain, then tag our original HD mounds.
   local original=Chrome.terrain
   Chrome.terrain=function(key)
    local entry=original(key);if not entry then return end
    local transparent=entries[entry]
    if not transparent then
     transparent={};for k,v in pairs(entry)do transparent[k]=v end
     transparent.image,transparent.bgImage,transparent.enemyPlat,transparent.playerPlat=blank,blank,blank,blank
     entries[entry]=transparent
    end
    return transparent
   end
   local result={pcall(terrain,...)};Chrome.terrain=original
   if not result[1]then error(result[2],0)end
   local args={...};local stats=library.stats()
   for _,side in ipairs({'opponent','player'})do
    local image,x,y,scale,origin=provider.nativeMound(side)
    if image then
     local nativeSide=side=='player'and'player'or'enemy'
     library.tag(image,{side=nativeSide,trainer=true,filter='linear',lowPivot={0,0},pivot={0,0}})
     x=x+(tonumber(args[side=='player'and 3 or 2])or 0)
     if side=='player'and library.fitEnabled()then y=y+(stats.dropPlayer or 0)end
     G.setColor(1,1,1,1)
     G.draw(image,x-image:getWidth()*scale*origin[1],y-image:getHeight()*scale*origin[2],0,scale,scale)
    end
   end
  end
  -- Without the HD library, the scenery and mounds are drawn at the final
  -- frame blit rather than being reduced into the native 240x160 canvas.
  return true
 end
 local function install()
  if Battle.draw~=battleWrapper then
   local original=Battle.draw
   battleWrapper=function(...)
    if inBattle then return original(...)end
    local target=G.getCanvas();local active=prepare()
    if not active then if target then marked[target]=nil end;return original(...)end
    if target then G.clear(0,0,0,0);marked[target]={stage=hd()~=nil}end
    pictures=setmetatable({},{__mode='k'});inBattle=true
    local result={pcall(original,...)};inBattle=false
    if not result[1]then error(result[2],0)end
    return(unpack or table.unpack)(result,2)
   end
   Battle.draw=battleWrapper
  end
  if G.draw~=drawWrapper then
   local original=G.draw
   drawWrapper=function(image,...)
    local picture=inBattle and not painting and not adjusting and pictures[image]
    if not picture then return original(image,...)end
    local dx,dy=provider.spriteOffset(picture.side,picture.species)
    if dx==0 and dy==0 then return original(image,...)end
    local args={...};local n=select('#',...);local first=type(args[1])=='number'and 1 or 2
    if type(args[first])~='number'or type(args[first+1])~='number'then return original(image,...)end
    args[first],args[first+1]=args[first]+dx,args[first+1]+dy
    adjusting=true;local result={pcall(original,image,(unpack or table.unpack)(args,1,n))};adjusting=false
    if not result[1]then error(result[2],0)end
    return(unpack or table.unpack)(result,2)
   end
   G.draw=drawWrapper
  end
  if Renderer.blitCanvas~=blitWrapper then
   local original=Renderer.blitCanvas
   blitWrapper=function(self,canvas,...)
    local state=marked[canvas]
    if state and not painting and provider.enabled()and Battle.isActive()then
     local w,h=G.getDimensions();local depth=G.getStackDepth()
     G.push('all');G.origin();G.setShader();G.setScissor();painting=true
     local args={...}
     local frame={x=args[6],y=args[7],width=240*args[1],height=160*args[2]}
     local ok,why=pcall(provider.draw,0,0,w,h,frame,{mounds=not state.stage})
     while G.getStackDepth()>depth do G.pop()end
     if not ok then mod.exports.sceneryAdapterError=tostring(why)end
     -- HD Sprites may call an older blit wrapper while composing this one.
     -- Keep the guard through the whole composite so scenery cannot repaint
     -- between its captured Pokemon and UI layers.
     local result={pcall(original,self,canvas,...)};painting=false
     if not result[1]then error(result[2],0)end
     return(unpack or table.unpack)(result,2)
    end
    return original(self,canvas,...)
   end
   Renderer.blitCanvas=blitWrapper
  end
 end
 install()
 mod.events:on('mods.loaded',install,-2000)
 mod.events:on('game.ready',install,-2000)
 return M
end
return M
