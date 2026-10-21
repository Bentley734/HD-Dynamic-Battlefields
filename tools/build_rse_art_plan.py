"""Author a Hoenn battle-only asset queue from inspected native map evidence.

This is an authoring plan, not a claim of runtime or visual validation.
"""
import json
import re
import sys
from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT.parent / '.work/hd-beta-deps'))
from lupa.luajit21 import LuaRuntime
catalog = LuaRuntime().execute((ROOT / 'metadata/distribution.lua').read_text())
aspects = ['4:3', '16:9', '16:10', '3:2', '21:9', '32:9', '9:16', '9:19.5', '9:20']
available = {}
for _, entry in catalog['compositions'].items():
    paths = [entry['background']]
    for field in ('backgrounds', 'mounds', 'night_mounds'):
        if entry[field]:
            paths.extend(v for _, v in entry[field].items())
    if all((ROOT / path).is_file() for path in paths):
        available.setdefault(entry['environment'], set()).add(entry['aspect_ratio'])

def family(name):
    # Specific Hoenn identity wins over broad land/sea/cave categories.
    if name == 'MagmaHideout_4F':
        return 'magma_core'
    if '_Gym' in name:
        return name.split('_Gym')[0].replace('City', '').replace('Town', '').lower() + '_gym'
    for token, env in [('SidneysRoom', 'sidney_chamber'), ('PhoebesRoom', 'phoebe_chamber'),
                       ('GlaciasRoom', 'glacia_chamber'), ('DrakesRoom', 'drake_chamber'),
                       ('ChampionsRoom', 'hoenn_champion'), ('BattlePyramid', 'battle_pyramid'),
                       ('BattlePike', 'battle_pike'), ('BattlePalace', 'battle_palace'),
                       ('BattleArena', 'battle_arena'), ('BattleFactory', 'battle_factory'),
                       ('BattleDome', 'battle_dome'), ('BattleTower', 'hoenn_battle_tower'),
                       ('WeatherInstitute', 'weather_institute'), ('SpaceCenter', 'space_center'),
                       ('OceanicMuseum', 'oceanic_museum'), ('TrickHousePuzzle', 'trick_house'),
                       ('SeashoreHouse', 'seashore_house'), ('MagmaHideout', 'magma_hideout'),
                       ('AquaHideout', 'aqua_hideout'), ('NewMauville', 'new_mauville'),
                       ('AbandonedShip', 'abandoned_ship'), ('SSTidal', 'ship_cabin'),
                       ('MirageTower', 'desert_ruin'), ('DesertRuins', 'regi_desert_ruins'),
                       ('IslandCave', 'regi_island_cave'), ('AncientTomb', 'regi_ancient_tomb'),
                       ('DesertUnderpass', 'desert_underpass'), ('MeteorFalls', 'meteor_falls'),
                       ('GraniteCave', 'granite_cave'), ('RusturfTunnel', 'cave'),
                       ('VictoryRoad', 'cave'), ('SeafloorCavern', 'seafloor_cavern'),
                       ('CaveOfOrigin', 'cave_of_origin'), ('TerraCave', 'terra_cave'),
                       ('MarineCave', 'marine_cave'), ('FieryPath', 'volcanic_cave'),
                       ('MtChimney', 'volcanic_crater'), ('JaggedPass', 'volcanic_slope'),
                       ('SkyPillar_Top', 'sky_pillar_summit'), ('SkyPillar', 'sky_pillar'), ('PetalburgWoods', 'forest'),
                       ('AlteringCave', 'cave'), ('ArtisanCave', 'artisan_cave')]:
        if token in name:
            return env
    if name.startswith('Underwater'):
        return 'underwater_ocean'
    if name == 'SouthernIsland_Interior':
        return 'southern_island'
    if name == 'FarawayIsland_Interior':
        return 'faraway_island'
    if name == 'BirthIsland_Exterior':
        return 'birth_island'
    if name in ('NavelRock_Top', 'NavelRock_Bottom'):
        return 'navel_rock_summit' if name.endswith('Top') else 'navel_rock_depths'
    if name in ('BattleFrontier_OutsideEast', 'BattleFrontier_OutsideWest'):
        return 'frontier_gardens'
    if name.startswith('ShoalCave'):
        return 'seafoam_cave' if 'IceRoom' in name else 'shoal_cave'
    if name.startswith('MtPyre'):
        if name == 'MtPyre_Summit':
            return 'mt_pyre_summit'
        return 'mt_pyre_exterior' if 'Exterior' in name else 'mt_pyre_interior'
    if name.startswith('SafariZone'):
        return 'hoenn_safari'
    route = re.fullmatch(r'Route(\d+)', name)
    if route:
        number = int(route[1])
        if number == 113:
            return 'ashfield'
        if number in (119, 120):
            return 'rainforest'
        if number in (105, 106, 107, 108, 122) or 124 <= number <= 134:
            return 'ocean'
        if number == 109:
            return 'beach'
        return 'grassland'
    if name == 'PacifidlogTown':
        return 'pacifidlog_water'
    if name.endswith(('City', 'Town')):
        return 'city'
    return None

rows, unresolved, excluded = [], [], []
for game in ('ruby', 'sapphire', 'emerald'):
    report = json.loads((ROOT / f'docs/evidence/rse/{game}-battle-maps.json').read_text())
    for row in report['maps']:
        name = row['native_name']
        if 'Prototype' in name or 'UnusedRubySapphire' in name:
            excluded.append({'game': game, 'map': row['id'], 'reason': 'Unused/prototype native map; no artwork queued'})
            continue
        # These battles use specials/generated facility maps rather than a
        # direct trainerbattle operation in an object script.
        special = ('ChampionsRoom' in name or
                   ('BattleFrontier_' in name and any(v in name for v in
                    ('BattleRoom', 'PyramidFloor', 'PyramidTop', 'PikeRoomNormal', 'PikeRoomFinal', 'PikeRoomWildMons'))) or
                   name in ('SouthernIsland_Interior', 'FarawayIsland_Interior', 'BirthIsland_Exterior',
                            'NavelRock_Top', 'NavelRock_Bottom', 'BattleFrontier_OutsideEast'))
        if not row['positive_battle_evidence'] and not special:
            continue
        land = family(name)
        if not land:
            unresolved.append({'game': game, 'map': row['id'], 'native_name': name})
            continue
        water = None
        if any(k in row['wild_rates'] for k in ('water', 'fishing')):
            # Preserve the visible floating-town identity for its actual
            # surf/fishing battles instead of bypassing its authored scenery.
            if name == 'PacifidlogTown':
                water = 'pacifidlog_water'
            elif name.startswith('AbandonedShip'):
                # Water encounters stay inside the flooded hull, not a cave.
                water = 'abandoned_ship_flooded'
            elif row['mapType'] == 5:
                water = 'underwater_ocean'
            elif row['mapType'] == 4:
                water = 'cave_water'
            elif land in ('ocean', 'beach', 'pacifidlog_water') or name in ('SlateportCity', 'LilycoveCity', 'MossdeepCity', 'DewfordTown', 'EverGrandeCity'):
                water = 'ocean'
            elif name in ('Route118', 'Route119'):
                water = 'river'
            else:
                water = 'pond'
        overrides = {}
        # Scripted Kyogre encounter has no random water encounter rate.
        # Its water terrain still belongs to the authored Marine Cave room.
        if name == 'MarineCave_End' and row['positive_battle_evidence']:
            water = 'marine_cave'
        if name == 'Route111':
            overrides['SAND'] = 'desert'
        if name == 'Route130' and row['wild_rates'].get('land', 0) > 0:
            # Mirage Island shares the ocean route signature. Resolve its
            # actual grass terrain independently from surrounding surf.
            overrides['GRASS'] = 'grassland'
            overrides['LONG_GRASS'] = 'grassland'
        entry = {key: row[key] for key in ('game', 'id', 'native_name', 'mapType', 'battleType', 'wild_rates')}
        entry.update(land=land, water=water, terrain_overrides=overrides,
                     evidence='native battle-special location' if special else 'positive encounter/event evidence')
        rows.append(entry)

families = sorted({env for row in rows for env in [row['land'], row['water'], *row['terrain_overrides'].values()] if env})
reuse = {env: {'available_aspects': sorted(available[env]), 'complete': set(aspects) <= available[env]}
         for env in families if env in available}
new = [env for env in families if env not in available or not set(aspects) <= available[env]]
plan = {'schema_version': 1, 'stage': 'authoring candidate; map/context and visual calibration pending',
        'initial_variations': 1, 'aspects': aspects, 'maps': rows, 'reuse_candidates': reuse,
        'new_or_incomplete_families': new, 'unclassified_battle_maps': unresolved,
        'excluded_unused_maps': excluded,
        'minimum_new_aspect_compositions': sum(len(set(aspects) - available.get(env, set())) for env in new),
        'limitations': ['Source and mound coverage are authoring candidates; native calibration remains required.',
                        'Review mixed-terrain routes, story/legendary specials and generated Frontier battles before enabling.',
                        'Existing scenery is a reuse candidate, not proof of matching Hoenn interiors or sprite contact.']}
sources = []
for path in sorted((ROOT / 'art/gen3').glob('*/*/*.authoring.json')):
    # Preserved drafts are not canonical compositions or coverage evidence.
    if path.relative_to(ROOT / 'art/gen3').parts[0] == 'drafts':
        continue
    data = json.loads(path.read_text())
    sources.append({'family': path.parent.name, 'aspect_ratio': data['aspect_ratio'],
                    'time_of_day': data['time_of_day'], 'background': data['background'],
                    'status': data['status']})
plan['generated_sources'] = sources
authored_base = {(s['family'], s['aspect_ratio']) for s in sources if s['time_of_day'] in ('day', 'indoor')}
plan['minimum_missing_base_sources'] = sum(
    1 for env in new for aspect in set(aspects) - available.get(env, set())
    if (env, aspect) not in authored_base)
plan['complete_day_night_source_families'] = sorted(
    family for family in {s['family'] for s in sources}
    if all(any(s['family'] == family and s['aspect_ratio'] == aspect and s['time_of_day'] == period
               for s in sources) for aspect in aspects for period in ('day', 'night')))
plan['complete_ambient_source_families'] = sorted(
    family for family in {s['family'] for s in sources}
    if all(any(s['family'] == family and s['aspect_ratio'] == aspect and s['time_of_day'] == 'indoor'
               for s in sources) for aspect in aspects))
(ROOT / 'metadata/rse-art-plan.json').write_text(json.dumps(plan, indent=2) + '\n')
print(json.dumps({'battle_map_candidates': len(rows), 'reuse_families': len(reuse),
                  'new_or_incomplete_families': len(new), 'minimum_new_aspect_compositions': plan['minimum_new_aspect_compositions'],
                  'unclassified_maps': unresolved}))
