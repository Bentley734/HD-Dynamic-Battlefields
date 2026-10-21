-- v0.3.88 passes opts.hooked to newWild, but does not retain that flag.
-- Keep scenery-only encounter context separately from the native battle state.
local M={}
-- Match BattleState.currentMapId: the running overworld is authoritative.
-- save.player.map can still name the last saved town/interior after walking.
function M.map(Battle,battle,game)
 if Battle and type(Battle.currentMapId)=='function'and battle and battle.game then
  local id=Battle.currentMapId(battle);if id then return id end
 end
 local map=game and game.overworld and game.overworld.map
 if map and map.id then return map.id end
 local player=game and game.save and game.save.player
 return player and player.map
end

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
