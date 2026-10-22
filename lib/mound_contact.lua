-- Resolve mound contacts from a sprite bake's stable, uncomposited geometry.
-- This module never edits pictures, sprite placements, options or saved offsets.
local M={}
local function finite(n)return type(n)=='number'and n==n and n~=math.huge and n~=-math.huge end
local function number(n,default)
 if n==nil then return default end
 if finite(n)then return n end
end
local function point(p)
 return type(p)=='table'and finite(p.x)and finite(p.y)
end

-- Coordinates are pixel edges (a pixel centre is x+.5), not pixel indices.
-- box/ox/oy/dw/dh are the production setupFrames values, before decorations.
-- floatLift is the production source-pixel lift, already zero outside FEET.
-- Optional audited footX/footY replace a union landmark, not the sprite anchor.
function M.localContact(bake)
 if type(bake)~='table'or type(bake.box)~='table'then return nil,'Missing sprite bake'end
 local box=bake.box
 local w,h=box.w,box.h
 local ox,oy,dw,dh=bake.ox,bake.oy,bake.dw,bake.dh
 if not finite(w)or not finite(h)or w<=0 or h<=0
  or not finite(ox)or not finite(oy)or not finite(dw)or not finite(dh)
  or dw<=0 or dh<=0 or ox<0 or oy<0 or ox+dw>w+1e-7 or oy+dh>h+1e-7 then
  return nil,'Invalid sprite bake geometry'
 end
 local lift=number(bake.floatLift,0)
 if not lift or lift<0 then return nil,'Invalid intentional hover lift'end
 local anchor=number(bake.anchor,0)
 if anchor~=0 and anchor~=1 and anchor~=2 then return nil,'Invalid sprite anchor'end
 local x=number(bake.footX,w/2)
 local artBottom=oy+dh
 local footY=number(bake.footY,artBottom)
 if not x or not footY or x<0 or x>w or footY<0 or footY>h then
  return nil,'Invalid audited foot landmark'
 end
 -- A tail can make the content's midpoint differ from its ground origin.
 -- Keep the renderer's canvas centre unless a foot landmark was audited.
 if bake.flip then x=w-x end
 local hovering=anchor==0 and lift>0
 -- Hover padding is deliberate. Moving its mound up to the art would erase
 -- the pose even though the sprite itself had not moved. Animation bobbing is
 -- likewise absent: these values come from the entire sheet's stable bake.
 local y=hovering and h or footY
 return{x=x,y=y,boxWidth=w,boxHeight=h,artBottom=artBottom,
  gap=h-artBottom,hovering=hovering,basis=hovering and'hover-ground'or'baked-art'}
end

-- Project through the stable renderer placement, in native presentation pixels.
-- Defaults match a centre-pivot picture. Pass explicit ox/oy for a natural bake.
-- Transient attack rotations/shears must not drag scenery with the creature.
function M.project(contact,placement)
 if not point(contact)then return nil,'Missing local contact'end
 if not point(placement)then return nil,'Missing sprite placement'end
 local sx=number(placement.sx,1)
 local sy=number(placement.sy,sx)
 local ox=number(placement.ox,contact.boxWidth and contact.boxWidth/2 or 0)
 local oy=number(placement.oy,contact.boxHeight and contact.boxHeight/2 or 0)
 local r,kx,ky=number(placement.r,0),number(placement.kx,0),number(placement.ky,0)
 if not sx or not sy or sx==0 or sy==0 or not ox or not oy then return nil,'Invalid sprite placement'end
 if r~=0 or kx~=0 or ky~=0 then return nil,'Use stable unrotated sprite placement'end
 local x=placement.x+(contact.x-ox)*sx
 local y=placement.y+(contact.y-oy)*sy
 if not finite(x)or not finite(y)then return nil,'Invalid projected contact'end
 return{x=x,y=y,localX=contact.x,localY=contact.y,hovering=contact.hovering,
  gap=contact.gap,basis=contact.basis}
end

function M.resolve(bake,placement)
 local contact,why=M.localContact(bake)
 if not contact then return nil,why end
 return M.project(contact,placement)
end

-- reference is the calibrated mound SURFACE contact, not its PNG bottom or
-- draw origin. Material origins/offsets and manual offsets remain caller-owned.
-- Add the returned delta to the mound only; never apply it to its Pokemon.
function M.correction(target,reference)
 if not point(target)or not point(reference)then return nil,'Missing mound surface reference'end
 local x,y=target.x-reference.x,target.y-reference.y
 if not finite(x)or not finite(y)then return nil,'Invalid mound correction'end
 return{x=x,y=y}
end

-- Each active slot keeps its own pad correction, including slots 0 and 2.
-- Do not average doubles contacts: that can leave both Pokemon ungrounded.
-- Invalid/pending slots are reported separately so existing pads can be kept.
function M.resolveSlots(slots)
 if type(slots)~='table'then return nil,'Missing battler slots'end
 local resolved,errors={},{}
 for id,slot in pairs(slots)do
  local target,why
  if type(slot)=='table'then target,why=M.resolve(slot.bake,slot.placement)
  else why='Invalid battler slot'end
  if target then
   local delta
   delta,why=M.correction(target,slot.reference)
   if delta then resolved[id]={contact=target,correction=delta}end
  end
  if why then errors[id]=why end
 end
 return resolved,errors
end
return M
