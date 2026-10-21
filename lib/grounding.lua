-- Anchor scenery to an existing native presentation without moving it.
local M={}
local function finite(n)return type(n)=='number'and n==n and n~=math.huge and n~=-math.huge end
function M.apply(layout,baseline,profile,frame,materials,paths)
 local v=layout.viewport
 if not frame then
  local fit=math.min(v.width/profile.width,v.height/profile.height)
  local scale=fit>=1 and math.floor(fit)or fit
  frame={x=(v.x or 0)+(v.width-profile.width*scale)/2,y=(v.y or 0)+(v.height-profile.height*scale)/2,
   width=profile.width*scale,height=profile.height*scale}
 end
 if not finite(frame.x)or not finite(frame.y)or not finite(frame.width)or not finite(frame.height)or frame.width<=0 or frame.height<=0 then return nil,'Invalid native frame'end
 local sx,sy=frame.width/profile.width,frame.height/profile.height
 for _,side in ipairs({'player','opponent'})do
  local mound,base,slot=layout[side].mound,baseline[side].mound,profile[side]
  local dx,dy=mound.x-base.x,mound.y-base.y
  local material=materials and paths and materials[paths[side]]
  local materialScale=material and material.scale or 1
  if not finite(materialScale)or materialScale<=0 then return nil,'Invalid mound material scale'end
  if material and material.origin then
   local o=material.origin
   if type(o)~='table'or not finite(o[1])or not finite(o[2])or o[1]<0 or o[1]>1 or o[2]<0 or o[2]>1 then return nil,'Invalid mound material origin'end
  end
  local materialY=material and material.offset_y or 0
  if not finite(materialY)then return nil,'Invalid mound material offset'end
  local userScale=mound.scale/base.scale
  mound.x,mound.y=frame.x+slot.x*sx+dx,frame.y+(slot.y+materialY)*sy+dy
  mound.bounds,mound.scale={slot.width*sx*materialScale,slot.height*sy*materialScale},userScale
  if material and material.origin then mound.origin={material.origin[1],material.origin[2]}end
 end
 return layout
end
return M
