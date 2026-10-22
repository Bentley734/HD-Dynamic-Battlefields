local G=assert(loadfile(root..'/lib/grounding.lua'))()
local function layout()
 return{viewport={width=1280,height=720},player={mound={x=300,y=500,bounds={1,1},scale=1}},opponent={mound={x=900,y=300,bounds={1,1},scale=1}}}
end
local base,moved=layout(),layout()
moved.player.mound.x=310;moved.player.mound.y=497;moved.player.mound.scale=2
local profile={width=240,height=160,player={x=61,y=121,width=160,height=40},opponent={x=176,y=62,width=160,height=48}}
local corrections={player={slots={{id=0,x=32,y=112,width=128,height=32},{id=2,x=90,y=100,width=128,height=32}}},opponent={x=2,y=-3}}
local material={water={scale=1.6,offset_y=6,origin={.5,.58}}}
assert(G.apply(moved,base,profile,{x=20,y=30,width=480,height=320},material,{player='water'},corrections))
local pads=moved.player.mounds
assert(#pads==2 and pads[1].id==0 and pads[2].id==2)
assert(pads[1].x==94 and pads[1].y==263 and pads[2].y==239)
assert(pads[1].scale==2 and pads[1].bounds[1]==409.6 and pads[1].origin[2]==.58)
assert(moved.opponent.mound.x==376 and moved.opponent.mound.y==148)
assert(not base.player.mounds and base.player.mound.x==300)
corrections.player.slots[2].y=0/0
assert(not G.apply(layout(),base,profile,nil,nil,nil,corrections))
print('PASS independent mound slots, additive manual calibration/materials, native scaling and invalid contact rejection')
