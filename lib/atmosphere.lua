-- Fixed particle pool and analytic positions: no per-frame particle allocation,
-- image decoding, simulation stepping, or calls to the game's random generator.
local M={}
function M.new(G,clock)
 local particles={}
 for i=1,144 do particles[i]={x=((i*73)%149)/149,y=((i*47)%151)/151,phase=i*2.3999632297,size=.7+(i%5)*.19}end
 local self={}
 function self:draw(viewport,state)
  if state.level==0 or state.weather=='clear'or state.weather=='sun'then return 0 end
  local t=clock();local count=({24,64,144})[state.level]
  local x,y,w,h=viewport.x or 0,viewport.y or 0,viewport.width,viewport.height
  local unit=math.max(.5,math.min(w/1920,h/1080))
  G.push('all');G.setShader();G.setBlendMode('alpha','alphamultiply')
  local ok,err=xpcall(function()
   G.setLineWidth(math.max(.6,unit))
   if state.weather=='fog'then
    count=({3,5,8})[state.level]
    for i=1,count do
     local p=particles[i];local cx=x+((p.x+t*.012)%1)*w;local cy=y+(.2+p.y*.75)*h
     for ring=3,1,-1 do
      G.setColor(.78,.85,.91,.018);G.ellipse('fill',cx,cy,w*(.18+ring*.035),h*(.025+ring*.012))
     end
    end
   else
    for i=1,count do
     local p=particles[i]
     if state.weather=='rain'then
      local px=x+((p.x-t*.045)%1)*w;local py=y+((p.y+t*.65)%1)*h
      G.setColor(.72,.84,.98,.18);G.line(px,py,px-3*unit,py+12*unit*p.size)
     elseif state.weather=='snow'then
      local px=x+((p.x+math.sin(t*.45+p.phase)*.015)%1)*w;local py=y+((p.y+t*.065*p.size)%1)*h
      G.setColor(.94,.97,1,.38);G.circle('fill',px,py,math.max(.7,p.size*unit))
     elseif state.weather=='sandstorm'then
      local px=x+((p.x+t*.16*p.size)%1)*w;local py=y+((p.y+math.sin(t*.8+p.phase)*.02)%1)*h
      G.setColor(.72,.56,.31,.22);G.line(px,py,px+8*unit*p.size,py-unit)
     end
    end
   end
  end,tostring)
  G.pop();if not ok then error(err,0)end
  return count
 end
 return self
end
return M
