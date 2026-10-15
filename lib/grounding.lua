-- Anchor scenery to an existing native presentation without moving it.
local M={}
local function finite(n)return type(n)=='number'and n==n and n~=math.huge and n~=-math.huge end
function M.apply(layout,baseline,profile,frame)
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
  local userScale=mound.scale/base.scale
  mound.x,mound.y=frame.x+slot.x*sx+dx,frame.y+slot.y*sy+dy
  mound.bounds,mound.scale={slot.width*sx,slot.height*sy},userScale
 end
 return layout
end
return M
