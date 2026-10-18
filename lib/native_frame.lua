-- Follow the native canvas's actual axis-aligned draw, including screen
-- positioning, fractional fit and intermediate presentation canvases.
local M={}
function M.drawRect(G,source,marker,...)
 local x,y,r,sx,sy,ox,oy,kx,ky=...
 if type(x)~='number'or type(y)~='number'or(r or 0)~=0 or(kx or 0)~=0 or(ky or 0)~=0 then return nil end
 sx,sy,ox,oy=sx or 1,sy or sx or 1,ox or 0,oy or 0
 if sx<=0 or sy<=0 then return nil end
 local f=marker and marker.frame or{x=0,y=0,width=source:getWidth(),height=source:getHeight()}
 local px,py=x+(f.x-ox)*sx,y+(f.y-oy)*sy
 local x0,y0=G.transformPoint(px,py)
 local x1,y1=G.transformPoint(px+f.width*sx,py)
 local x2,y2=G.transformPoint(px,py+f.height*sy)
 if math.abs(y1-y0)>1e-6 or math.abs(x2-x0)>1e-6 or x1<=x0 or y2<=y0 then return nil end
 return{x=x0,y=y0,width=x1-x0,height=y2-y0}
end
return M
