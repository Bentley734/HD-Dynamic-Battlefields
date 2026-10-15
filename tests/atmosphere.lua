local A=assert(loadfile(root..'/lib/atmosphere.lua'))()
local calls,clock,push,pop=0,0,0,0
local G={push=function()push=push+1 end,pop=function()pop=pop+1 end,setShader=function()end,setBlendMode=function()end,
 setLineWidth=function()end,setColor=function()end,line=function()calls=calls+1 end,
 circle=function()calls=calls+1 end,ellipse=function()calls=calls+1 end}
local atmosphere=A.new(G,function()clock=clock+1;return 1.25 end)
local viewport={x=3,y=7,width=1920,height=1080}
assert(atmosphere:draw(viewport,{level=0,weather='rain'})==0 and clock==0 and push==0)
assert(atmosphere:draw(viewport,{level=3,weather='clear'})==0 and clock==0)
assert(atmosphere:draw(viewport,{level=3,weather='sun'})==0 and clock==0)
for level,count in ipairs({24,64,144})do
 calls=0;assert(atmosphere:draw(viewport,{level=level,weather='rain'})==count and calls==count)
end
for _,weather in ipairs({'snow','sandstorm'})do
 calls=0;assert(atmosphere:draw(viewport,{level=1,weather=weather})==24 and calls==24)
end
calls=0;assert(atmosphere:draw(viewport,{level=1,weather='fog'})==3 and calls==9)
G.line=function()error('injected draw failure')end
assert(not pcall(atmosphere.draw,atmosphere,viewport,{level=1,weather='rain'}))
assert(push==pop,'Atmosphere draw leaked graphics state')
print('PASS bounded atmosphere quality budgets, zero animation clock/processing when off, rain/snow/sand/fog draws and error-state restoration')
