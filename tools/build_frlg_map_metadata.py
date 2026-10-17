"""Resolve curated Kanto aliases against inspected native FR/LG map IDs.

This authors an explicit table; runtime classification never guesses names.
Unmatched areas remain native until their own scenery mapping is inspected.
"""
import json,re,sys
from pathlib import Path
root=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(root.parent/'.work/hd-beta-deps'))
from lupa.luajit21 import LuaRuntime
gen1=LuaRuntime().execute((root/'metadata/maps/gen1.lua').read_text())
native=json.loads((root/'docs/evidence/frlg/firered-national/maps.json').read_text())
aliases={
 'ROUTE_21_NORTH':'ROUTE_21','ROUTE_21_SOUTH':'ROUTE_21',
 'SAFFRON_CITY_DOJO':'FIGHTING_DOJO',
 'POKEMON_LEAGUE_LORELEIS_ROOM':'LORELEIS_ROOM','POKEMON_LEAGUE_BRUNOS_ROOM':'BRUNOS_ROOM',
 'POKEMON_LEAGUE_AGATHAS_ROOM':'AGATHAS_ROOM','POKEMON_LEAGUE_LANCES_ROOM':'LANCES_ROOM',
 'POKEMON_LEAGUE_CHAMPIONS_ROOM':'CHAMPIONS_ROOM',
 'SSANNE_CAPTAINS_OFFICE':'SS_ANNE_CAPTAINS_ROOM','SSANNE_DECK':'SS_ANNE_BOW',
 'SSANNE_KITCHEN':'SS_ANNE_KITCHEN','SSANNE_EXTERIOR':'SS_ANNE_EXTERIOR',
 'INDIGO_PLATEAU_EXTERIOR':'INDIGO_PLATEAU',
 'DIGLETTS_CAVE_B1F':'DIGLETTS_CAVE',
 'DIGLETTS_CAVE_NORTH_ENTRANCE':'DIGLETTS_CAVE_ROUTE_2',
 'DIGLETTS_CAVE_SOUTH_ENTRANCE':'DIGLETTS_CAVE_ROUTE_11',
 'CELADON_CITY_GAME_CORNER':'GAME_CORNER',
 'SSANNE_EXTERIOR':'VERMILION_DOCK',
}
# Sevii uses existing habitat paintings, not falsely-labelled Gen 1 locations.
# These author-time rules produce exact IDs and signatures in the shipped table.
habitats={
 'FR_BIRTH_ISLAND_EXTERIOR':('beach',None),
 'FR_FIVE_ISLAND':('island_town','ocean'),
 'FR_FIVE_ISLAND_MEADOW':('grassland','ocean'),
 'FR_FIVE_ISLAND_MEMORIAL_PILLAR':('grassland','ocean'),
 'FR_FIVE_ISLAND_RESORT_GORGEOUS':('beach','ocean'),
 'FR_FIVE_ISLAND_WATER_LABYRINTH':('ocean','ocean'),
 'FR_FIVE_ISLAND_ROCKET_WAREHOUSE':('rocket_hideout',None),
 'FR_FOUR_ISLAND':('island_town','ocean'),
 'FR_MT_EMBER_EXTERIOR':('rocky_terrain','ocean'),
 'FR_MT_EMBER_SUMMIT':('rocky_terrain',None),
 'FR_SEVEN_ISLAND_SEVAULT_CANYON':('rocky_terrain',None),
 'FR_SEVEN_ISLAND_SEVAULT_CANYON_ENTRANCE':('grassland','ocean'),
 'FR_SEVEN_ISLAND_TANOBY_RUINS':('rocky_terrain','ocean'),
 'FR_SEVEN_ISLAND_TRAINER_TOWER':('grassland','ocean'),
 'FR_SIX_ISLAND_ALTERING_CAVE':('cave',None),
 'FR_SIX_ISLAND_GREEN_PATH':('grassland','ocean'),
 'FR_SIX_ISLAND_OUTCAST_ISLAND':('beach','ocean'),
 'FR_SIX_ISLAND_PATTERN_BUSH':('forest',None),
 'FR_SIX_ISLAND_RUIN_VALLEY':('rocky_terrain','pond'),
 'FR_SIX_ISLAND_WATER_PATH':('grassland','ocean'),
 'FR_THREE_ISLAND':('island_town',None),
 'FR_THREE_ISLAND_PORT':('harbor','ocean'),
 'FR_THREE_ISLAND_BERRY_FOREST':('forest','pond'),
 'FR_THREE_ISLAND_BOND_BRIDGE':('grassland','ocean'),
 'FR_THREE_ISLAND_DUNSPARCE_TUNNEL':('cave',None),
 'FR_TWO_ISLAND_CAPE_BRINK':('grassland','pond'),
 'SEVII_ONE_ISLAND':('island_town','ocean'),
 'SEVII_ONE_ISLAND_KINDLE_ROAD':('beach','ocean'),
 'SEVII_ONE_ISLAND_TREASURE_BEACH':('beach','ocean'),
}
for row in native:
    id=row['id']
    if id.startswith(('FR_FIVE_ISLAND_LOST_CAVE_','FR_MT_EMBER_RUBY_PATH_','FR_MT_EMBER_SUMMIT_PATH_','FR_NAVEL_ROCK_')):
        habitats[id]=('cave',None)
    elif id.startswith('FR_FOUR_ISLAND_ICEFALL_CAVE_'):
        habitats[id]=('seafoam_cave','cave_water')
    elif id.startswith('FR_SEVEN_ISLAND_TANOBY_RUINS_'):
        habitats[id]=('cave',None)
    elif re.fullmatch('FR_TRAINER_TOWER_[1-8]F',id):
        habitats[id]=('corporate_interior',None)
mapped=[];unmapped=[]
for row in native:
    name=row['id'].removeprefix('FR_')
    candidate=aliases.get(name,name)
    if gen1[candidate] is None:
        candidate=re.sub(r'_(CITY|TOWN|ISLAND)_','_',candidate)
    if name.startswith('SSANNE_'):
        room=re.fullmatch(r'SSANNE_(1F|2F|B1F)_ROOM\d+',name)
        corridor=re.fullmatch(r'SSANNE_(1F|2F|3F|B1F)_CORRIDOR',name)
        if room:candidate='SS_ANNE_'+room[1]+'_ROOMS'
        elif corridor:candidate='SS_ANNE_'+corridor[1]
    source=gen1[candidate]
    if source is None and row['id'] in habitats:
        environment,water=habitats[row['id']]
        mapped.append({'id':row['id'],'mapType':row['mapType'],'environment':environment,'water':water,'shared_gen1_map':None})
        continue
    if source is None:
        unmapped.append(row['id']);continue
    mapped.append({'id':row['id'],'mapType':row['mapType'],'environment':source.environment,
                   'water':source.water,'shared_gen1_map':candidate})
lines=['-- Explicit native FR/LG signatures; authored by tools/build_frlg_map_metadata.py.','return {']
for row in mapped:
    fields=[f"environment='{row['environment']}'",f"mapType={row['mapType']}"]
    if row['shared_gen1_map']:fields.append(f"shared_gen1_map='{row['shared_gen1_map']}'")
    if row['water']:fields.append(f"water='{row['water']}'")
    lines.append(" ['"+row['id']+"']={"+','.join(fields)+'},')
lines.append('}')
(root/'metadata/maps/frlg.lua').write_text('\n'.join(lines)+'\n')
inspection=json.loads((root.parent/'.work/hd-frlg-compat/native-inspection-firered.json').read_text())
ids={r['id']for r in native}
wild={k for k,v in inspection['encounters'].items()if k in ids and any(isinstance(x,dict)and x.get('rate',0)>0 for x in v.values())}
trainers={k for k,v in inspection['events'].items()if k in ids and any(o.get('trainerType',0)>0 for o in v.get('objects',[]))}
missing=sorted((wild|trainers)&set(unmapped))
assert not missing,missing
(root/'docs/evidence/frlg/mapping-coverage.json').write_text(json.dumps({'mapped':len(mapped),'inspected':len(native),'positive_wild_or_trainer_maps':len(wild|trainers),'unmapped_positive_maps':missing,'native_fallbacks':unmapped},indent=2)+'\n')
print('Mapped',len(mapped),'of',len(native),'inspected FR/LG IDs; remaining IDs retain native scenery.')
