"""Compile Hoenn authoring choices into exact per-game map signatures."""
import json
from pathlib import Path
from build_gen2_catalog import lua
ROOT = Path(__file__).resolve().parents[1]
plan = json.loads((ROOT / 'metadata/rse-art-plan.json').read_text())
if plan['unclassified_battle_maps']:
    raise ValueError('Unclassified Hoenn battle areas remain')
games = {game: {} for game in ('ruby', 'sapphire', 'emerald')}
for row in plan['maps']:
    maps = games[row['game']]
    if row['id'] in maps:
        raise ValueError('Duplicate map signature: ' + row['id'])
    if any(key in row['wild_rates'] for key in ('water', 'fishing')) and not row['water']:
        raise ValueError('Unmapped water encounters: ' + row['id'])
    maps[row['id']] = {'mapType': row['mapType'], 'battleType': row['battleType'],
                       'environment': row['land'], 'water': row['water'],
                       'terrain_overrides': row['terrain_overrides']}
(ROOT / 'metadata/maps/rse.lua').write_text(
    '-- Hoenn integration candidate; exact IDs from native cache; visual review pending.\nreturn ' + lua(games) + '\n')
print(json.dumps({game: len(maps) for game, maps in games.items()}))
