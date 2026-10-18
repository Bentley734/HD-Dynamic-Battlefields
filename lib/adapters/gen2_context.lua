-- Read-only adapter for v0.3.89 src/ui/gen2/BattleState.lua and World.lua.
-- Gen 2's screen wraps a logic battle; its party mons are not Gen 1 battlers.
return function(mod,Screen,identity)
 return function()
  local game=mod.game
  local screen=game and game.stack and game.stack:top()
  if not screen or getmetatable(screen)~=Screen then return nil,'No native Gen 2 battle screen'end
  local battle=screen.battle
  local world=game.world
  local map=world and world.map
  local def=map and map.def
  if not battle or not def then return nil,'Missing Gen 2 battle/map context'end
  local tod
  if world.timeOfDay and world.hour then tod=world:timeOfDay(world:hour())end
  local period=({MORN='day',DAY='day',NITE='night',DARK='night'})[tod]
  local function species(mon)return mon and identity(mon.species)or nil end
  local constants=Screen.Battle or{}
  return{screen=screen,battle=battle,map=map.id,tileset=def.tileset,mapType=def.environment,
   kind=battle.wild and'wild'or'trainer',playerSpecies=species(battle.player),
   enemySpecies=species(battle.enemy),weather=battle.weather,timeOfDay=period,
   fishing=constants.BATTLETYPE_FISH~=nil and battle.battleType==constants.BATTLETYPE_FISH,
   surfing=world.playerState=='surf'or world.playerState=='surf_pika',
   link=screen.link or battle.link,tutorial=screen.tutorial}
 end
end
