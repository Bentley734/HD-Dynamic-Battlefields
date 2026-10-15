-- Native pixel art scales in physical framebuffer pixels, including devices
-- whose logical-to-physical density is fractional (for example Android 2.75).
local M={}
local function finite(n)return type(n)=='number'and n==n and n~=math.huge and n~=-math.huge end
function M.density(viewport)
 local dpi=viewport.dpiY or viewport.dpiX or 1
 if not finite(dpi)or dpi<=0 then return nil,'Invalid pixel density'end
 return dpi
end
function M.zoom(desired,dpi)
 if not finite(desired)or desired<=0 or not finite(dpi)or dpi<=0 then return nil,'Invalid pixel scale'end
 local pixels=math.max(1,math.floor(desired*dpi+.5))
 return pixels,pixels/dpi
end
function M.snap(position,dpi)return math.floor(position*dpi+.5)/dpi end
return M
