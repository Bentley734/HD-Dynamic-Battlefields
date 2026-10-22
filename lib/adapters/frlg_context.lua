return function(mod,identity)
 local Battle=require('src.core.game3.battle')
 local Pokemon=require('src.core.game3.pokemon')
 local Background=require('src.core.game3.battle.bg')
 return function()
  if not Battle.isActive()then return nil,'No native FR/LG battle'end
  local state=Battle.getState();local game=mod.game
  if not state or not game or not game.session then return nil,'Missing FR/LG battle context'end
  local session=game.session;local map=game.data and game.data.maps and game.data.maps[session.map]
  local function species(battler)
   local mon=battler and battler.mon
   return mon and identity(Pokemon.speciesOf(mon))or nil
  end
  local terrain=Background.env().TERRAIN
  return{battle=state,kind=state.wild and'wild'or'trainer',map=session.map,mapType=map and map.mapType,
   double=state.double==true,
   playerSpecies=species(state.player),enemySpecies=species(state.enemy),
   water=state.terrain==terrain.WATER or state.terrain==terrain.POND or state.terrain==terrain.UNDERWATER,
   weather=state.weather,link=state.link or state.multi}
 end
end
