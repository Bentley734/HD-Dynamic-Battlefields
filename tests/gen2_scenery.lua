local depth,paints,paperCalls,nativeCalls,picCalls=0,0,0,0,0
local enabled,prepared,failed=true,true,false
local canvas
local G={getStackDepth=function()return depth end,push=function()depth=depth+1 end,pop=function()depth=depth-1 end,
 getCanvas=function()return canvas end,getDimensions=function()return 1280,720 end,
 transformPoint=function(x,y)return x,y end,origin=function()end,setShader=function()end,setScissor=function()end,
 setBlendMode=function()end,setColor=function()end,rectangle=function()end,translate=function()end,
 clear=function()end,draw=function()end}
local Chrome={paletteFill=function()paperCalls=paperCalls+1 end}
package.loaded['src.ui.gen2.Chrome']=Chrome
local Screen={wideLayout=function(self)return self.wide end}
Screen.drawScene=function(self)
 nativeCalls=nativeCalls+1
 Chrome.paletteFill(0,0,self.wide and 304 or 160,144)
 Chrome.paletteFill(0,0,96,32) -- HUD paper must survive.
 Chrome.paletteFill(0,0,160,144,{1,2,3}) -- Explicit effect palette survives.
 if failed then error('native failure')end
end
Screen.drawPic=function()picCalls=picCalls+1;if failed then error('pic failure')end end
local provider={enabled=function()return enabled end,prepare=function()return prepared end,
 draw=function()paints=paints+1;return true end,spriteOffset=function()return 2,-1 end}
local mod={exports={},find=function()end}
function mod:read(path)local f=assert(io.open(root..'/'..path));local s=f:read('*a');f:close();return s end
assert(loadfile(root..'/lib/adapters/gen2_scenery.lua'))().install(mod,Screen,G,provider)
local screen=setmetatable({}, {__index=Screen})
screen:drawScene();assert(nativeCalls==1 and paints==1 and paperCalls==2 and depth==0)
screen.wide=true;screen:drawScene();assert(nativeCalls==2 and paints==2 and paperCalls==4)
enabled=false;screen:drawScene();assert(nativeCalls==3 and paints==2 and paperCalls==7)
enabled=true;prepared=false;screen:drawScene();assert(nativeCalls==4 and paints==2 and paperCalls==10)
prepared=true;failed=true;assert(not pcall(screen.drawScene,screen));assert(depth==0)
failed=false;local before=paperCalls;Chrome.paletteFill(0,0,160,144);assert(paperCalls==before+1)
screen:drawPic({species='TOTODILE'},true);assert(picCalls==1 and depth==0)
failed=true;assert(not pcall(screen.drawPic,screen,{},true));assert(depth==0)
print('PASS Gen2 scenery scope: classic/wide paper only, explicit effects/HUD retained, native fallback and graphics/error cleanup')
