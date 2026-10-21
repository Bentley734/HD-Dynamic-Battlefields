-- Read-only Hoenn context. Battle presentation and mechanics stay native.
return function(mod,identity)
 local Battle=require('src.core.game3.battle')
 local Pokemon=require('src.core.game3.pokemon')
 local Background=require('src.core.game3.battle.bg')
 local Version=require('src.core.GameVersion')
 local Rtc=require('src.core.game3.rtc')
 local Weather=require('src.core.game3.weather')
 -- Native field weather IDs; unsupported ash/underwater visuals stay clear.
 local fieldWeather={[0]='clear',[1]='clear',[2]='clear',[3]='rain',[4]='snow',
  [5]='rain',[6]='fog',[8]='sandstorm',[9]='fog',[11]='clear',[12]='sun',[13]='rain'}
 return function()
  local gameId=Version.get()
  if gameId~='ruby'and gameId~='sapphire'and gameId~='emerald'then return nil,'Not a Hoenn game'end
  if not Battle.isActive()then return nil,'No native Hoenn battle'end
  local state,game=Battle.getState(),mod.game
  if not state or not game or not game.session then return nil,'Missing Hoenn battle context'end
  local env=Background.env()
  if not env or env.family~='rse'then return nil,'Unexpected Hoenn terrain provider'end
  local session=game.session
  local map=game.data and game.data.maps and game.data.maps[session.map]
  -- savedWeather already contains the runtime's resolved scripted/cycle value.
  -- Fall back to translated map metadata only before field initialization.
  local fieldId=tonumber(session.savedWeather)
  if fieldId==nil and map and map.weather~=nil then fieldId=Weather.translate(map.weather,session)end
  local terrain=state.terrain
  if terrain==nil then terrain=Background.terrainId()end
  local terrainName
  for name,id in pairs(env.TERRAIN)do
   if id==terrain then
    if terrainName and terrainName~=name then return nil,'Ambiguous Hoenn terrain'end
    terrainName=name
   end
  end
  local function species(battler)
   return battler and battler.mon and identity(Pokemon.speciesOf(battler.mon))or nil
  end
  local hour=Rtc.enabled(session)and Rtc.localTime and tonumber(Rtc.localTime.hours)or nil
  local clockPeriod
  if hour and hour>=0 and hour<24 then clockPeriod=hour>=6 and hour<18 and'day'or'night'end
  return{game=gameId,battle=state,kind=state.wild and'wild'or'trainer',map=session.map,
   mapType=map and map.mapType,mapBattleType=map and map.battleType,
   terrain=terrain,terrainName=terrainName,
   water=terrainName=='WATER'or terrainName=='POND'or terrainName=='UNDERWATER',
   underwater=terrainName=='UNDERWATER',double=state.double==true,
   playerSpecies=species(state.player),enemySpecies=species(state.enemy),
   weather=state.weather,mapWeather=fieldWeather[fieldId],timeOfDay=clockPeriod,link=state.link==true}
 end
end
