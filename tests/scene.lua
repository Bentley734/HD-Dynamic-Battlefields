local P=assert(loadfile(root..'/lib/perspective.lua'))()
local S=assert(loadfile(root..'/lib/scene.lua'))()
local draft=assert(loadfile(root..'/metadata/prototype.lua'))()
local draw,pushes,pops,released,quadReleases={},0,0,0,0
local G={push=function()pushes=pushes+1 end,pop=function()pops=pops+1 end,
 intersectScissor=function()end,setColor=function()end,rectangle=function()end,
 draw=function(img,x,y,r,sx,sy,...)
  if type(x)=='table'and x.region then x,y,r,sx,sy=y,r,sx,sy,... end
  draw[#draw+1]={img=img,x=x,y=y,sx=sx,sy=sy}
 end,
 newQuad=function()return{region=true,release=function()quadReleases=quadReleases+1 end}end}
local function image(path)
 if path=='bad' then error('corrupt image') end
 return {getWidth=function()return path:find('mound') and 900 or 1920 end,
 getHeight=function()return path:find('mound') and 300 or 1080 end,
 release=function()released=released+1 end}
end
local scene=S.new(G,P,image);local entry=draft.compositions[1]
assert(scene:prepare(entry,draft.metadata))
local layout=assert(scene:layout({x=7,y=11,width=1800,height=1080}))
assert(layout.canvas.x==-53 and layout.canvas.y==11 and layout.canvas.width==1920)
assert(layout.player.pokemon.x==-53+.28*1920)
assert(scene:draw(layout,nil,{}));assert(#draw==3)
for _,d in ipairs(draw)do assert(math.abs(d.sx-d.sy)<1e-10)end
-- Mound anchoring can correct an asset's contact surface without moving sprites.
local originalY,playerY=draw[2].y,draw[3].y
layout.opponent.mound.origin={.5,.62}
draw={};assert(scene:draw(layout,nil,{}))
local moundDraw=draw[2]
assert(math.abs(moundDraw.y-(originalY-300*moundDraw.sy*.12))<1e-8)
assert(draw[3].y==playerY,'Unrelated mound must retain its original placement')
local bad={metadata=entry.metadata,aspect_ratio=entry.aspect_ratio,background='bad'}
assert(not scene:prepare(bad,draft.metadata));assert(scene.entry==entry)
-- Sprite failure must restore the caller's graphics state and retain diagnosis.
local pusher=pushes
assert(not scene:draw(layout,{player={width=20,height=20,contact={.5,1},draw=function()error('sprite error')end}},{}))
assert(pushes==pusher+1 and pops==pushes and scene.diagnostics.error:find('sprite error'))
scene:release();assert(released==2 and not scene.entry)
local region={id='panorama-fixture',metadata='meadow-perspective-32x9',aspect_ratio='32:9',background='painting',source_rect={x=0,y=270,width=1920,height=540}}
assert(scene:prepare(region,draft.metadata));local wide=assert(scene:layout({width=5120,height=1440}))
draw={};assert(scene:draw(wide,nil,{}));assert(#draw==1 and math.abs(draw[1].sx-draw[1].sy)<1e-10)
region.source_rect={x=-1,y=0,width=1920,height=540};assert(not scene:prepare(region,draft.metadata))
scene:release();assert(quadReleases==2)
print('PASS uniform intermediate-aspect cover, shared art/anchor transform, uniform mound scaling, failed-load retention, graphics-state restoration and texture release')
