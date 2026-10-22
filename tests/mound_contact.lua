local C=assert(loadfile(root..'/lib/mound_contact.lua'))()
local checks=0
local function eq(actual,wanted,why)
 checks=checks+1;assert(actual==wanted,why..': '..tostring(actual)..' ~= '..tostring(wanted))
end
local function copy(t)
 local out={};for k,v in pairs(t)do out[k]=v end;return out
end
local grounded={box={w=64,h=64},ox=14,oy=24,dw=36,dh=40,floatLift=0,anchor=0}
local placed={x=176,y=40,ox=32,oy=32}
local contact=assert(C.resolve(grounded,placed))
eq(contact.x,176,'Canvas-centred contact ignores asymmetric art/tails')
eq(contact.y,72,'Grounded contact uses bottom pixel edge')
eq(contact.hovering,false,'Grounded classification')
local delta=assert(C.correction(contact,{x=176,y=70}))
eq(delta.x,0,'No unwanted tail-driven horizontal correction')
eq(delta.y,2,'Only mound correction is returned')
eq(grounded.oy,24,'Bake is immutable');eq(placed.y,40,'Sprite placement is immutable')

local packed=copy(grounded);packed.anchor=1;packed.oy=20
contact=assert(C.resolve(packed,placed))
eq(contact.y,68,'PACK content lift is preserved in mound target')
eq(contact.gap,4,'PACK gap is from uncomposited art, never shadow alpha')
local boxed=copy(packed);boxed.anchor=2
eq(assert(C.resolve(boxed,placed)).y,68,'Actual production BOX bake is used directly')

local hovering=copy(packed);hovering.anchor=0;hovering.floatLift=8
contact=assert(C.resolve(hovering,placed))
eq(contact.y,72,'Intentional hover keeps mound on canvas ground')
eq(contact.hovering,true,'Intentional hover is distinguished from PACK padding')
local off=copy(hovering);off.floatLift=0
eq(assert(C.resolve(off,placed)).y,68,'Disabled floating follows actual baked art')
local packIgnoresFloat=copy(hovering);packIgnoresFloat.anchor=1
eq(assert(C.resolve(packIgnoresFloat,placed)).y,68,'PACK never inherits FEET float logic')

-- Per-frame pose extrema and composited shadow/cloud diagnostics do not move
-- a mound. Only the stable production bake and intentional ground are inputs.
local bob=copy(grounded);bob.frameBottom=57;bob.shadowBottom=63;bob.cloudTop=0
eq(assert(C.resolve(bob,placed)).y,72,'Per-frame bob/decorations are not ground anchors')

local landmark=copy(grounded);landmark.footX=22.5;landmark.footY=61
contact=assert(C.resolve(landmark,placed));eq(contact.x,166.5,'Audited foot landmark')
eq(contact.y,69,'Audited feet can exclude a low tail')
landmark.flip=true
contact=assert(C.resolve(landmark,placed));eq(contact.x,185.5,'Mirrored front reflects landmark about canvas centre')
local mirrored=copy(grounded);mirrored.flip=true
eq(assert(C.resolve(mirrored,placed)).x,176,'Mirror never changes default canvas centre')
eq(assert(C.resolve(landmark,{x=176,y=40,ox=32,oy=32,sx=-1})).x,166.5,'Actual negative draw scale is respected')
local natural={box={w=40,h=48},ox=0,oy=2,dw=40,dh=42,floatLift=5,anchor=0}
contact=assert(C.resolve(natural,{x=80,y=90,ox=20,oy=48,sx=2}))
eq(contact.x,80,'Natural explicit ground pivot');eq(contact.y,90,'Natural padding preserves ground at any scale')

-- Independent doubles pads align both slots rather than finding a compromise.
local slots={
 [0]={bake=grounded,placement={x=48,y=72},reference={x=48,y=104}},
 [2]={bake=packed,placement={x=80,y=80},reference={x=80,y=112}},
 [1]={bake=grounded,placement=placed,reference={x=176,y=70}},
 [3]={bake=nil,placement=placed,reference={x=152,y=62}}}
local resolved,errors=C.resolveSlots(slots)
eq(resolved[0].correction.y,0,'Doubles first player slot')
eq(resolved[2].correction.y,-4,'Doubles second player slot independently uses PACK contact')
eq(resolved[1].correction.y,2,'Doubles enemy slot independently resolves')
eq(resolved[3],nil,'Pending slot retains existing mound through absent correction')
checks=checks+1;assert(type(errors[3])=='string'and not errors[0],'Pending slot reports a useful reason')

for _,bad in ipairs({{}, {box={w=64,h=64}}, {box={w=64,h=64},ox=0,oy=0,dw=65,dh=10},
 {box={w=64,h=64},ox=0,oy=0,dw=10,dh=10,floatLift=-1}})do
 checks=checks+1;assert(not C.resolve(bad,placed),'Invalid bake must safely fall back')
end
checks=checks+1;assert(not C.resolve(nil,placed),'Missing bake must safely fall back')
checks=checks+1;assert(not C.resolve(grounded,{x=0/0,y=1}),'Invalid placement must safely fall back')
checks=checks+1;assert(not C.resolve(grounded,{x=1,y=1,sx=0}),'Zero scale must safely fall back')
checks=checks+1;assert(not C.resolve(grounded,{x=1,y=1,r=.1}),'Transient rotation must not drag mound')
checks=checks+1;assert(not C.correction(contact,{x=1}),'Missing surface reference must safely fall back')
checks=checks+1;assert(not C.correction({x=1e308,y=1},{x=-1e308,y=1}),'Overflowing correction must safely fall back')
print(('PASS %d mound contact assertions: production bake anchors, PACK gaps, intentional hover, immutable sprites, audited/ mirrored feet, natural pivots, independent doubles and safe fallback'):format(checks))
