-- Isolated native constructors and rendered states; no live save traversal.
return function(c)
 local game,Battle=c.game,c.Battle
 local original=game.battle
 local cases={
  {'wild','ROUTE_1','grassland','RATTATA',7},
  {'forest','VIRIDIAN_FOREST','forest','CATERPIE',5},
  {'cave','MT_MOON_1F','cave','ZUBAT',10},
  {'trainer','ROUTE_3','mountain','OPP_YOUNGSTER',1,true},
  {'rival','SS_ANNE_2F','ship_corridor','OPP_RIVAL2',1,true},
  {'cabin','SS_ANNE_1F_ROOMS','ship_cabin','OPP_SAILOR',1,true},
  {'brock','PEWTER_GYM','gym_rock','OPP_BROCK',1,true},
  {'misty','CERULEAN_GYM','gym_water','OPP_MISTY',1,true},
  {'surge','VERMILION_GYM','gym_electric','OPP_LT_SURGE',1,true},
  {'erika','CELADON_GYM','gym_grass','OPP_ERIKA',1,true},
  {'koga','FUCHSIA_GYM','gym_poison','OPP_KOGA',1,true},
  {'sabrina','SAFFRON_GYM','gym_psychic','OPP_SABRINA',1,true},
  {'blaine','CINNABAR_GYM','gym_fire','OPP_BLAINE',1,true},
  {'giovanni','VIRIDIAN_GYM','gym_ground','OPP_GIOVANNI',1,true},
  {'lorelei','LORELEIS_ROOM','elite_four_ice','OPP_LORELEI',1,true},
  {'bruno','BRUNOS_ROOM','elite_four_rock','OPP_BRUNO',1,true},
  {'agatha','AGATHAS_ROOM','elite_four_ghost','OPP_AGATHA',1,true},
  {'lance','LANCES_ROOM','elite_four_dragon','OPP_LANCE',1,true},
  {'champion','CHAMPIONS_ROOM','champion','OPP_RIVAL3',1,true},
  {'mewtwo','CERULEAN_CAVE_B1F','legendary_mewtwo','MEWTWO',70},
  {'articuno','SEAFOAM_ISLANDS_B4F','legendary_articuno','ARTICUNO',50},
  {'zapdos','POWER_PLANT','legendary_zapdos','ZAPDOS',50},
  {'moltres','VICTORY_ROAD_2F','legendary_moltres','MOLTRES',50},
  {'surf-ocean','ROUTE_19','ocean','TENTACOOL',15,false,'surfing'},
  {'surf-river','ROUTE_10','river','TENTACOOL',15,false,'surfing'},
  {'fish-ocean','ROUTE_19','ocean','MAGIKARP',5,false,'fishing'},
  {'fish-river','ROUTE_10','river','MAGIKARP',5,false,'fishing'},
  {'fish-pond','ROUTE_6','pond','MAGIKARP',5,false,'fishing'},
 }
 local results={}
 for _,row in ipairs(cases)do
  game.save.player.map=row[2];game.save.player.surfing=row[7]=='surfing'
  local battle
  if row[6]then battle=Battle.newTrainer(game,row[4],row[5])
  else battle=Battle.newWild(game,row[4],row[5],{hooked=row[7]=='fishing'})end
  c.setBattle(battle)
  battle.phase='menu';battle.introSlide=0;battle.introBalls=false
  battle.enemy.fainted=false;battle.player.fainted=false
  c.options.environment='auto';c.options.timeMode='day';c.options.animation='off'
  for _,size in ipairs({{1920,1080},{5120,1440},{900,1600}})do
   c.options.enabled=false
   local baseline=c.render(size[1],size[2],nil,false)
   c.options.enabled=true
   local name=size[1]==1920 and('scenario-'..row[1]..'.png')or nil
   local scenic=c.render(size[1],size[2],name,true)
   assert(scenic==baseline,'Native UI/sprite/effect trace changed: '..row[1])
   local d=c.exports.diagnostics()
   assert(d.status=='active'and d.environment==row[3],c.Json.encode(d))
   if row[7]then assert(d.waterSource==row[7],c.Json.encode(d))end
   results[#results+1]={scenario=row[1],kind=battle.kind,map=row[2],enemy=battle.enemy.mon.species,
    environment=d.environment,composition=d.composition,width=size[1],height=size[2],native_trace_unchanged=true}
  end
 end
 c.setBattle(original);game.save.player.map='ROUTE_1';game.save.player.surfing=false
 c.options.enabled=true
 c.write('battle-scenario-rendering.json',c.Json.encode({game=game.save.version,checks=results,
  scope='Native constructors and staged menu renders. No overworld traversal, battle simulation, physical devices or other mods.'}))
end
