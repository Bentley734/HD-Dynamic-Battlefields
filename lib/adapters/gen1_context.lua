-- v0.3.88 passes opts.hooked to newWild, but does not retain that flag.
-- Keep scenery-only encounter context separately from the native battle state.
local M={}
function M.install(Battle)
 local fishing=setmetatable({},{__mode='k'})
 local newWild=assert(Battle.newWild,'Missing native wild battle constructor')
 Battle.newWild=function(game,species,level,options,...)
  local battle=newWild(game,species,level,options,...)
  if type(battle)=='table'and options and options.hooked==true then fishing[battle]=true end
  return battle
 end
 return function(battle)return fishing[battle]==true end
end
return M
