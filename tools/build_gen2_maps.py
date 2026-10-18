"""Export explicit per-game map signatures from the inspected Gen 2 worklist."""
import json
from pathlib import Path
from build_gen2_catalog import lua

ROOT = Path(__file__).resolve().parents[1]


def main():
    plan = json.loads((ROOT / 'metadata/gen2-art-plan.json').read_text())
    games = {}
    for row in plan['locations']:
        if row['asset_action'] == 'review' or not row['candidate_art_family']:
            raise ValueError('Unclassified map: ' + row['map'])
        game = games.setdefault(row['game'], {})
        if row['map'] in game:
            raise ValueError('Duplicate game/map')
        water = any(rate > 0 for field, rates in row['encounter_rates'].items()
                    if field in ('water', 'swarmWater') for rate in rates.values())
        if water and not all(trigger in row['candidate_art_by_encounter']
                             for trigger in ('surf', 'fishing')):
            raise ValueError('Positive water encounter rate without water art: ' + row['map'])
        game[row['map']] = {'tileset': row['tileset'], 'environment_type': row['environment_type'],
                            'encounters': row['candidate_art_by_encounter']}
    (ROOT / 'metadata/maps/gen2.lua').write_text(
        '-- Generated from inspected imported map signatures; gameplay review pending.\nreturn ' +
        lua(games) + '\n', encoding='utf-8')
    print(json.dumps({game: len(maps) for game, maps in games.items()}))


if __name__ == '__main__':
    main()
