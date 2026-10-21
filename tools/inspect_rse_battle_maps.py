"""Read imported R/S/E maps and reachable event scripts without loading saves.

Exports battle-area evidence, not ROM graphics, dialogue or executable scripts.
Special/native-generated battles still require explicit follow-up inspection.
"""
import argparse
import collections
import hashlib
import json
import os
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT.parent / '.work/hd-beta-deps'))
from lupa.luajit21 import LuaRuntime

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--cache', type=Path, default=Path(os.environ['APPDATA']) / 'pokemon-love2d')
p.add_argument('--engine', type=Path, default=ROOT.parent / '.work/hd-battlefields-latest/v0.3.95/engine')
a = p.parse_args()
output = ROOT / 'docs/evidence/rse'
output.mkdir(parents=True, exist_ok=True)
summary = {}
for game in ('ruby', 'sapphire', 'emerald'):
    lua = LuaRuntime()
    data = a.cache / game / 'data/generated/gba'
    scripts_path = data / 'scripts/scripts.lua'
    scripts = lua.execute(scripts_path.read_text())
    events_path = data / 'scripts/events.lua'
    compiled_events = lua.execute(events_path.read_text())
    engine_version = lua.execute((a.engine / 'src/core/Version.lua').read_text())['engine']
    encounters = lua.execute((data / 'encounters.lua').read_text())
    constants_path = a.engine / ('src/core/game3/constants/' + ('emerald' if game == 'emerald' else 'ruby') + '/map_groups.lua')
    constants = lua.execute(constants_path.read_text())
    names = {(int(v['group']), int(v['num'])): k.removeprefix('MAP_') for k, v in constants['byName'].items()}
    graph, direct = {}, {}
    for key, script in scripts.items():
        targets, evidence = set(), set()
        for _, row in script.items():
            op = row['op']
            if op in ('trainerbattle', 'dotrainerbattle', 'setwildbattle', 'dowildbattle'):
                evidence.add(op)
            if op in ('call', 'goto', 'call_if', 'goto_if'):
                target = row['target']
                if isinstance(target, str):
                    targets.add(target)
        graph[key], direct[key] = targets, evidence

    def reachable(key):
        seen, found, pending = set(), set(), [key]
        while pending:
            current = pending.pop()
            if current in seen or current not in graph:
                continue
            seen.add(current)
            found.update(direct[current])
            pending.extend(graph[current] - seen)
        return sorted(found)

    rows = []
    for path in sorted((data / 'map_tree/maps').glob('*/header.json')):
        header = json.loads(path.read_text())
        events = json.loads((path.parent / 'events.json').read_text())
        identity = (header['group'], header['num'])
        if identity not in names:
            raise ValueError(f'{game}: imported map lacks native identity: {identity}')
        wild = encounters[f'{identity[0]}:{identity[1]}']
        habitats = {key: int(value['rate']) for key, value in wild.items()
                    if hasattr(value, 'items') and isinstance(value['rate'], (int, float)) and value['rate'] > 0} if wild else {}
        event_evidence = []
        for category in ('objects', 'coordEvents', 'bgEvents'):
            for event in events.get(category, []):
                key = event.get('scriptKey')
                battle_ops = reachable(key) if key else []
                if battle_ops:
                    event_evidence.append({'category': category, 'x': event.get('x'), 'y': event.get('y'),
                                           'battle_operations': battle_ops})
        prefix = {'ruby': 'RU_', 'sapphire': 'SA_', 'emerald': 'EM_'}[game]
        # Compiled map lifecycle scripts can launch battles without objects.
        prefix_id = prefix + names[identity]
        compiled = compiled_events[prefix_id]
        def script_roots(value):
            if isinstance(value, str):
                yield value
            elif hasattr(value, 'items'):
                for _, child in value.items():
                    yield from script_roots(child)
        if compiled and compiled['mapScripts']:
            for key in sorted(set(script_roots(compiled['mapScripts']))):
                battle_ops = reachable(key)
                if battle_ops:
                    event_evidence.append({'category': 'mapScripts', 'script_key': key,
                                           'battle_operations': battle_ops})
        rows.append({'game': game, 'id': prefix + names[identity],
                     'native_name': header['id'], 'mapGroup': identity[0], 'mapNum': identity[1],
                     'mapType': header['mapType'], 'battleType': header.get('battleType'),
                     'weather': header.get('weather'), 'primaryTileset': header.get('primaryTileset'),
                     'secondaryTileset': header.get('secondaryTileset'), 'wild_rates': habitats,
                     'battle_event_evidence': event_evidence,
                     'positive_battle_evidence': bool(habitats or event_evidence)})
    report = {'game': game, 'engine_version': engine_version, 'maps': rows,
              'source_sha256': {p.name: hashlib.sha256(p.read_bytes()).hexdigest()
                                for p in (scripts_path, events_path, data / 'encounters.lua', constants_path)},
              'limitations': 'Positive wild rates and reachable object/coordinate/background/map lifecycle battle operations. Dynamic specials and generated facility encounters require separate inspection.'}
    (output / (game + '-battle-maps.json')).write_text(json.dumps(report, indent=2) + '\n')
    summary[game] = {'imported_maps': len(rows), 'positive_battle_maps': sum(r['positive_battle_evidence'] for r in rows),
                     'wild_maps': sum(bool(r['wild_rates']) for r in rows),
                     'event_battle_maps': sum(bool(r['battle_event_evidence']) for r in rows)}
(output / 'inspection-summary.json').write_text(json.dumps(summary, indent=2) + '\n')
print(json.dumps(summary))
