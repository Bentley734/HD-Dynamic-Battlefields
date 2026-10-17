-- User-only corrections in native Gen 1 pixels; authored geometry is immutable.
local M={}
function M.resolve(data,aspect,composition,side)
 local x,y=0,0
 local function apply(group)
  local u=group and group[side]
  if u then
   if u.pokemon_x~=nil then x=u.pokemon_x end
   if u.pokemon_y~=nil then y=u.pokemon_y end
  end
 end
 data=data or{}
 apply(data.global);apply(data.aspects and data.aspects[aspect]);apply(data.compositions and data.compositions[composition])
 return math.floor(x*160+.5),math.floor(y*144+.5)
end
function M.install(Battle,G,offset)
 local original=Battle.drawBattlerPic
 if type(original)~='function'then return false end
 Battle.drawBattlerPic=function(self,battler,...)
  local x,y=offset(battler and battler.isPlayer and'player'or'opponent')
  if not x or x==0 and y==0 then return original(self,battler,...)end
  local depth=G.getStackDepth();G.push('all');G.translate(x,y)
  local result={pcall(original,self,battler,...)}
  while G.getStackDepth()>depth do G.pop()end
  if not result[1]then error(result[2],0)end
  return(unpack or table.unpack)(result,2)
 end
 return true
end
return M
