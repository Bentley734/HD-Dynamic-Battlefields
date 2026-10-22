-- v0.3.88 passes opts.hooked to newWild, but does not retain that flag.
-- Keep scenery-only encounter context separately from the native battle state.
local M={}
-- Native StatBox is a transparent battle overlay. Keep the same battle and
-- scenery identity while it is open, without treating arbitrary child screens
-- (party, bag, summary, etc.) as part of the battlefield.
function M.battle(Battle,game)
 local stack=game and game.stack
 local top=stack and stack:top()
 if not top then return end
 if getmetatable(top)==Battle then return top end
 if top.isOpaque or getmetatable(top)~=Battle.StatBox then return end
 local states=stack.states
 if not states or states[#states]~=top then return end
 for i=#states-1,1,-1 do
  local state=states[i]
  if getmetatable(state)==Battle then return state end
  if state.isOpaque or getmetatable(state)~=Battle.StatBox then return end
 end
end

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
