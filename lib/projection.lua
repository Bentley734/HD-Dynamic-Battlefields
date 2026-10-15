-- Similarity projection for a native animation plane between two battlers.
-- Matches both endpoints without stretching individual effect pixels.
local M={}
function M.between(a,b,targetA,targetB)
 local sx,sy=b.x-a.x,b.y-a.y
 local tx,ty=targetB.x-targetA.x,targetB.y-targetA.y
 local denominator=sx*sx+sy*sy
 if denominator<1e-12 or tx*tx+ty*ty<1e-12 then return nil,'Coincident animation anchors'end
 local real,imaginary=(tx*sx+ty*sy)/denominator,(ty*sx-tx*sy)/denominator
 local out={scale=math.sqrt(real*real+imaginary*imaginary),rotation=math.atan2(imaginary,real),source=a,target=targetA}
 function out:point(x,y)
  x,y=x-a.x,y-a.y
  return targetA.x+real*x-imaginary*y,targetA.y+imaginary*x+real*y
 end
 return out
end
return M
