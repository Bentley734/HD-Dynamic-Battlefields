local image,canvas={},{}
local depth,draws,paints=0,{},0
local G={newImage=function()return{}end,getCanvas=function()return canvas end,getDimensions=function()return 1280,720 end,
 clear=function()end,getStackDepth=function()return depth end,push=function()depth=depth+1 end,pop=function()depth=depth-1 end,
 origin=function()end,setShader=function()end,setScissor=function()end,setColor=function()end,
 draw=function(img,...)draws[#draws+1]={img,...}end}
love={image={newImageData=function()return{}end}}
local Ui={sidePic=function()return{image=image}end,battlerSpriteCenter=function()return 176,40 end}
local fail=false
local Battle={isActive=function()return true end,draw=function()
 local entry=Ui.sidePic(false,false,1089)
 G.draw(entry.image,176,40,0,1,1,32,32)
 if fail then error('native failure')end
end}
local throwBlit=false
local Renderer={blitCanvas=function()if throwBlit then error('blit failure')end end}
package.loaded['src.core.game3.battle']=Battle
package.loaded['src.core.game3.battle.ui']=Ui
package.loaded['src.ui.game3.battle_chrome']={}
package.loaded['src.core.game3.battle.bg']={draw=function()return true end}
package.loaded['src.render.Renderer']=Renderer
package.loaded['src.core.game3.display']={}
package.loaded['src.core.game3.mon_anim']={}
local enabled=true
local provider={enabled=function()return enabled end,prepare=function()return true end,
 spriteOffset=function(side,species)assert(side=='opponent'and species==1089);return 3,-2 end,
 draw=function(_,_,w,h,frame)assert(w==1280 and h==720 and frame.x==160 and frame.width==960);paints=paints+1 end}
local mod={find=function()end,exports={},events={on=function()end}}
dofile(root..'/lib/adapters/frlg_scenery.lua').install(mod,G,provider)
Battle.draw();assert(draws[1][2]==179 and draws[1][3]==38 and draws[1][8]==32 and depth==0)
enabled=false;Battle.draw();assert(draws[2][2]==176 and draws[2][3]==40)
enabled=true;fail=true;assert(not pcall(Battle.draw));fail=false
Battle.draw();assert(draws[#draws][2]==179)
local function blit()Renderer:blitCanvas(canvas,4,4,nil,4,4,160,40,160,40,960,640)end
throwBlit=true;assert(not pcall(blit));assert(depth==0)
throwBlit=false;blit();assert(paints==2 and depth==0,'Composite guard remained stuck after error')
print('PASS FR/LG adapter: actual picture coordinates, unchanged origin/scale, disabled passthrough, exact renderer frame and error recovery')
