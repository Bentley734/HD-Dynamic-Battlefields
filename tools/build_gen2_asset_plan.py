"""Audit imported Gold/Silver/Crystal map coverage and prioritize new art.
Author-time planning only: does not assign runtime habitats or change game data.
"""
import json, os, sys, hashlib
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT.parent/'.work/hd-beta-deps'))
from lupa.luajit21 import LuaRuntime
ASPECTS=['4x3','16x9','16x10','3x2','21x9','32x9','9x16','9x19_5','9x20']
NIGHT_FAMILIES=['tin_tower_roof','harbor_water','cinnabar_coast']
# Explicit distinctive locations take priority over broad material reuse.
UNIQUE={
 'AZALEA_GYM':'azalea_gym','VIOLET_GYM':'violet_gym',
 'GOLDENROD_GYM':'goldenrod_gym','ECRUTEAK_GYM':'ecruteak_gym',
 'OLIVINE_GYM':'olivine_gym',
 'MAHOGANY_GYM':'mahogany_gym','BLACKTHORN_GYM_1F':'blackthorn_gym',
 'BLACKTHORN_GYM_2F':'blackthorn_gym','DANCE_THEATER':'dance_theater',
 'RUINS_OF_ALPH_INNER_CHAMBER':'ruins_of_alph',
 'DRAGONS_DEN_B1F':'dragons_den','TIN_TOWER_ROOF':'tin_tower_roof',
 'WHIRL_ISLAND_LUGIA_CHAMBER':'lugia_chamber',
 'KARENS_ROOM':'elite_four_karen',
 'OLIVINE_LIGHTHOUSE_6F':'olivine_lighthouse',
 'BATTLE_TOWER_BATTLE_ROOM':'battle_tower'}
PREFIX_NEW={'SPROUT_TOWER_':'sprout_tower','TIN_TOWER_':'tin_tower',
 'BURNED_TOWER_':'burned_tower','OLIVINE_LIGHTHOUSE_':'olivine_lighthouse',
 'RADIO_TOWER_':'radio_tower'}
# Shared Kanto environments already have a curated map taxonomy.
def candidate(name,gen1,map_environment):
 if name in UNIQUE:return 'new',UNIQUE[name]
 # These imported port candidates carry positive water encounter rates. The
 # existing harbor illustration is a dry dock, not the surf battle surface.
 if name in {'OLIVINE_PORT','VERMILION_PORT','VERMILION_CITY'}:return 'new','harbor_water'
 # Cinnabar's post-eruption coastline differs from the intact Gen 1 town.
 if name=='CINNABAR_ISLAND':return 'new','cinnabar_coast'
 for prefix,env in PREFIX_NEW.items():
  if name.startswith(prefix):return 'new',env
 if name in gen1:return 'reuse',gen1[name].environment
 for prefix,env in [('ICE_PATH_','seafoam_cave'),('WHIRL_ISLAND_','cave'),
 ('SLOWPOKE_WELL_','cave'),('UNION_CAVE_','cave'),('DARK_CAVE_','cave'),
 ('MOUNT_MORTAR_','cave'),('SILVER_CAVE_ROOM_','deep_cave'),
 ('SILVER_CAVE_ITEM_','deep_cave'),('FAST_SHIP_CABINS_','ship_cabin'),
 ('TEAM_ROCKET_BASE_','rocket_hideout')]:
  if name.startswith(prefix):return 'reuse',env
 explicit={'ILEX_FOREST':'forest','NATIONAL_PARK':'safari_woodland',
 'LAKE_OF_RAGE':'pond','TOHJO_FALLS':'cave_water','VICTORY_ROAD':'cave',
 'MOUNT_MOON':'cave','FAST_SHIP_B1F':'ship_corridor',
 'GOLDENROD_UNDERGROUND':'underground_tunnel',
 'GOLDENROD_UNDERGROUND_WAREHOUSE':'warehouse',
 'GOLDENROD_UNDERGROUND_SWITCH_ROOM_ENTRANCES':'underground_tunnel',
 'KOGAS_ROOM':'gym_poison','BRUNOS_ROOM':'dojo','LANCES_ROOM':'elite_four_dragon',
 'SILVER_CAVE_ROOM_3':'deep_cave','SILVER_CAVE_OUTSIDE':'mountain',
 'CIANWOOD_GYM':'dojo','WILLS_ROOM':'gym_psychic','ELMS_LAB':'laboratory',
 'RUINS_OF_ALPH_OUTSIDE':'rocky_terrain','WISE_TRIOS_ROOM':'dojo'}
 if name in explicit:return 'reuse',explicit[name]
 if name.startswith('ROUTE_') and map_environment=='ROUTE':return 'reuse','grassland'
 if name.endswith('_PORT'):return 'reuse','harbor'
 if map_environment in ['TOWN','ROUTE'] and name.endswith(('_TOWN','_CITY','_ISLAND')):return 'reuse','village'
 return 'review',None

def rates_for(enc,name):
 """Record actual imported trigger rates; table membership alone is weaker."""
 result={}
 for field in ['grass','water','swarmGrass','swarmWater']:
  table=enc[field];entry=table[name] if table is not None else None
  if entry is None:continue
  rates=entry.rates
  if rates is not None:
   result[field]={str(k):v for k,v in rates.items()}
  elif entry.rate is not None:
   result[field]={'all':entry.rate}
 return result

WATER_AREAS={
 'BLACKTHORN_CITY':'pond','CHERRYGROVE_CITY':'ocean','CIANWOOD_CITY':'ocean',
 'ECRUTEAK_CITY':'pond','VIOLET_CITY':'pond','NEW_BARK_TOWN':'ocean',
 'OLIVINE_CITY':'ocean','ILEX_FOREST':'pond','LAKE_OF_RAGE':'pond',
 'DRAGONS_DEN_B1F':'dragons_den','WHIRL_ISLAND_LUGIA_CHAMBER':'cave_water',
 'ROUTE_10_NORTH':'river','ROUTE_9':'river','RUINS_OF_ALPH_OUTSIDE':'pond',
 'TOHJO_FALLS':'cave_water',
 'ROUTE_21':'ocean','ROUTE_26':'ocean','ROUTE_27':'ocean','ROUTE_28':'pond',
 'ROUTE_30':'pond','ROUTE_31':'pond','ROUTE_32':'ocean','ROUTE_34':'ocean',
 'ROUTE_35':'pond','ROUTE_40':'ocean','ROUTE_41':'ocean','ROUTE_42':'pond',
 'ROUTE_43':'pond','ROUTE_44':'pond','ROUTE_45':'pond','SILVER_CAVE_OUTSIDE':'pond'}

def encounter_art_candidates(environment,rates,name=None,gen1=None):
 # A dry trainer/grass encounter in a cave must not inherit the water floor
 # merely because the same map also contains a surf encounter table.
 if environment in {'harbor_water','cinnabar_coast'}:return {'surf':environment,'fishing':environment}
 result={'land':environment}
 if any(rate>0 for field,entries in rates.items() if field in {'water','swarmWater'}
        for rate in entries.values()):
  old=gen1[name] if gen1 is not None and name is not None else None
  water=WATER_AREAS.get(name) or (old.water if old is not None else None)
  if water:
   result['surf']=water
   result['fishing']=water
 if environment in {'cave','deep_cave'} and any(
  rate>0 for field,entries in rates.items() if field in {'water','swarmWater'}
  for rate in entries.values()):
  result['surf']='cave_water'
  result['fishing']='cave_water'
 return result

def source_record(path,family,variation,aspect):
 """Inventory artwork and its required authoring companions together."""
 companions={'painting':path,'authoring_metadata':path.with_suffix('.authoring.json'),
  'exact_prompt':path.parent/'prompts'/(path.stem+'.txt')}
 missing=[key for key,target in companions.items() if not target.is_file()]
 status='missing' if not path.is_file() else 'source_candidate_incomplete' if missing else 'source_candidate'
 return {'family':family,'variation':variation,'aspect':aspect,
  'path':path.relative_to(ROOT).as_posix(),'status':status,'missing_deliverables':missing}

def main():
 lua=LuaRuntime();gen1=lua.execute((ROOT/'metadata/maps/gen1.lua').read_text())
 catalog=lua.execute((ROOT/'metadata/prototype.lua').read_text())
 existing={};missing_catalog_paths=[]
 relocations={e['old']:e['new'] for e in json.loads((ROOT/'art/RELOCATIONS.json').read_text())}
 for _,entry in catalog.compositions.items():
  relative=entry.background
  if not relative or not (ROOT/relocations.get(relative,relative)).is_file():
   missing_catalog_paths.append(relative);continue
  existing.setdefault(entry.environment,set()).add(entry.aspect_ratio.replace(':','x').replace('.','_'))
 rows=[]
 # Include known scripted encounters not represented as trainer object type2.
 scripted=set(UNIQUE)|{'WILLS_ROOM','KOGAS_ROOM','BRUNOS_ROOM','LANCES_ROOM','SPROUT_TOWER_3F',
 'BURNED_TOWER_B1F','BURNED_TOWER_1F','CIANWOOD_CITY','ECRUTEAK_CITY',
 'TEAM_ROCKET_BASE_B2F','TEAM_ROCKET_BASE_B3F','MOUNT_MOON','VICTORY_ROAD',
 'SILVER_CAVE_ROOM_3','ELMS_LAB','GOLDENROD_UNDERGROUND_WAREHOUSE'}
 for game in ['gold','silver','crystal']:
  base=Path(os.environ['APPDATA'])/'pokemon-love2d'/game/'data/generated'
  maps=lua.execute((base/'maps.lua').read_text());enc=lua.execute((base/'encounters.lua').read_text())
  for name,m in sorted(maps.items()):
   evidence=[]
   for field in ['grass','water','rocks','trees','treeSets','swarmGrass','swarmWater']:
    table=enc[field]
    if table is not None and table[name] is not None:evidence.append('encounter_table:'+field)
   if any(o.type==2 for _,o in m.objects.items()):evidence.append('trainer_object')
   if name in scripted:evidence.append('scripted_candidate_requires_review')
   if not evidence:continue
   action,environment=candidate(name,gen1,m.environment)
   rates=rates_for(enc,name)
   rows.append({'game':game,'map':name,'environment_type':m.environment,
     'tileset':m.tileset,'evidence':evidence,'asset_action':action,
     'candidate_art_family':environment,
     'encounter_rates':rates,
     'candidate_art_by_encounter':encounter_art_candidates(environment,rates,name,gen1),
     'existing_aspects':sorted(existing.get(environment,set())) if action=='reuse' else []})
 families=sorted(set(v['candidate_art_family'] for v in rows if v['asset_action']=='new'))
 work=[]
 for family in families:
  # First Gen 2 release: one variation; additional variants are deferred.
  for variation in range(1,2):
   for aspect in ASPECTS:
    name=f'{family}-{variation:02d}-{aspect}.png'
    path=ROOT/'art/gen2'/aspect/family/name
    work.append(source_record(path,family,variation,aspect))
 summary={'mapped_game_locations':len(rows),'reuse_candidates':sum(v['asset_action']=='reuse' for v in rows),
 'unclassified_locations':sum(v['asset_action']=='review' for v in rows),
 'context_dependent_cave_locations':sum('surf' in v['candidate_art_by_encounter'] and v['candidate_art_family'] in {'cave','deep_cave'} for v in rows),
 'water_context_locations':sum('surf' in v['candidate_art_by_encounter'] for v in rows),
 'new_families':families,'new_compositions':len(work),'remaining_compositions':sum(v['status']!='source_candidate' for v in work),
 'source_candidates':sum(v['status']=='source_candidate' for v in work),
 'initial_16x9_candidates':[family for family in families if (ROOT/'art/gen2/16x9'/family/f'{family}-01-16x9.png').is_file()],
 'missing_catalog_paths':missing_catalog_paths}
 nights=sorted(p.relative_to(ROOT).as_posix() for p in (ROOT/'art/gen2').rglob('*-night.png'))
 summary['night_source_candidates']=len(nights)
 night_work=[]
 # Outdoor originals need separately painted night compositions; indoor
 # families do not acquire artificial day/night copies.
 for family in NIGHT_FAMILIES:
  for aspect in ASPECTS:
   path=ROOT/'art/gen2'/aspect/family/f'{family}-01-{aspect}-night.png'
   night_work.append(source_record(path,family,1,aspect))
 summary['remaining_night_compositions']=sum(v['status']!='source_candidate' for v in night_work)
 supplemental=[]
 for path in sorted((ROOT/'art/gen2').glob('*/*/*.authoring.json')):
  if path.parent.name in families:continue
  entry=json.loads(path.read_text(encoding='utf-8'))
  supplemental.append({'family':path.parent.name,'composition_id':entry['composition_id'],
   'background':entry['background'],'status':entry['status'],
   'authoring_metadata':path.relative_to(ROOT).as_posix()})
 summary['supplemental_source_candidates']=len(supplemental)
 summary['source_candidates_by_aspect']={aspect:sum(v['aspect']==aspect and v['status']=='source_candidate' for v in work) for aspect in ASPECTS}
 summary['complete_first_variation_aspects']=[aspect for aspect in ASPECTS if summary['source_candidates_by_aspect'][aspect]==len(families)]
 result={'schema':1,'stage':'art planning; not runtime coverage or gameplay verification',
 'release_scope':{'variations_per_environment':1,'extra_variations':'deferred until after initial Gen 2 support'},
 'reuse_policy':'Reference existing Gen 1 files directly; do not duplicate or regenerate suitable art.',
 'limitations':['Encounter-table membership is a candidate signal, not proof of positive encounter rate.',
 'Scripted candidates and fish/headbutt/rock-smash conditions require individual review.',
 'This composition worklist still needs outdoor day/night and mound pairing review.',
 'Encounter-specific art candidates are planning data; surf/fishing context and terrain must be verified in runtime.'],
 'summary':summary,'locations':rows,'new_art_worklist':work,
 'night_art_worklist':night_work,'night_art_sources':nights,
 'supplemental_sources':supplemental}
 target=ROOT/'metadata/gen2-art-plan.json';target.write_text(json.dumps(result,indent=2)+'\n')
 print(json.dumps(summary))
if __name__=='__main__':main()
