"""Run isolated Hoenn native fixtures without reading/writing real game saves.

Loader modes add the current game to a virtual candidate manifest only. They
do not change the published game's eligibility declaration on disk.
"""
import argparse
import json
import os
import subprocess
from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]
WORKSPACE = ROOT.parent
p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--require-manifest-game', action='store_true', help='Reject fixtures needing a virtual game allowlist override')
p.add_argument('--mod-root', type=Path, help='Test an extracted base package instead of development sources')
p.add_argument('--installed-pack-fixture', type=Path, help='Isolated offline pack fixture root')
p.add_argument('--mode', choices=['direct', 'loader', 'menu-customizer'], default='loader')
p.add_argument('--runtime-version', default='0.3.95', help='Verified isolated engine release to exercise')
p.add_argument('--engine', type=Path, help='Override isolated engine directory')
p.add_argument('--game', action='append', choices=['ruby', 'sapphire', 'emerald'])
p.add_argument('--size', action='append', choices=['1280x720', '5120x1440', '900x1600', '1024x768', '1440x900', '1200x800', '2100x900', '900x1950', '900x2000'])
p.add_argument('--report-name',default='runner-summary.json',choices=['runner-summary.json','additional-aspects-summary.json','focused-review-summary.json'])
p.add_argument('--love', type=Path, default=WORKSPACE / '.tools/love-audio-runtime/love-probe.exe')
p.add_argument('--menu-root', type=Path, default=WORKSPACE / '.work/menu-gen3-font-fix')
p.add_argument('--wildfollowers', action='store_true', help='Load the published WildFollowers compatibility fixture')
p.add_argument('--wildfollowers-root', type=Path, default=WORKSPACE / '.work/hd-rse-compat-latest/wildfollowers-3.4.5/extracted')
p.add_argument('--content', choices=['none', 'national', '1025'], default='none')
p.add_argument('--compat-root', type=Path, default=WORKSPACE / '.work/hd-rse-compat-latest/national-suite-2026-10-21')
p.add_argument('--dex-root', type=Path, default=WORKSPACE / '.work/1025dex-double-fix')
p.add_argument('--all-areas', action='store_true', help='Render every mapped catalog family, including its night artwork')
p.add_argument('--double', action='store_true', help='Use an isolated four-battler trainer fixture')
p.add_argument('--resize-method', choices=['mode','desktop'], default='mode', help='Graphics-mode recreation or existing SDL window resize')
p.add_argument('--resize', action='store_true', help='Resize the actual GPU window through seven viewports in one battle')
p.add_argument('--transitions', action='store_true', help='Exercise native faint/send-out presentation sequences, not full battle turns')
p.add_argument('--move-effects', action='store_true', help='Exercise five native ROM animation scripts without move mechanics')
p.add_argument('--battle-flow', action='store_true', help='Run an isolated native automatic trainer battle to a win')
p.add_argument('--prepare-dex-assets', action='store_true', help='Run the real 1025Dex manager local migration against the isolated downloaded pack')
p.add_argument('--family', action='append', help='Limit an all-area review batch to selected environment identifiers')
a = p.parse_args()
engine_root = (a.engine or WORKSPACE / ('.work/hd-battlefields-latest/v' + a.runtime_version + '/engine')).resolve()
if not (engine_root / 'src/core/Version.lua').is_file():
    p.error('Missing isolated engine: ' + str(engine_root))
if a.family and not a.all_areas:
    p.error('--family requires --all-areas')
manifest_data=json.loads(((a.mod_root or ROOT)/'manifest.json').read_text())
requested_games=a.game or ['ruby','sapphire','emerald']
if a.require_manifest_game and any(game not in manifest_data['games'] for game in requested_games):
    p.error('Requested game is absent from the actual tested manifest')
loader = a.mode != 'direct'
menu = a.mode == 'menu-customizer'
if a.installed_pack_fixture and (not loader or not (a.installed_pack_fixture / 'fixture.json').is_file()):
    p.error('Installed pack fixture requires real loader and prepared fixture.json')
if a.content != 'none' and not loader:
    p.error('Content mods require a real-loader mode')
if menu and not (a.menu_root / 'manifest.json').is_file():
    p.error('Menu Customizer source is required for this mode')
if a.prepare_dex_assets and a.content != '1025':
    p.error('--prepare-dex-assets requires --content 1025')
receipt_root = WORKSPACE / '.work/hd-rse-compat-latest/dex-manager-fixture'
(receipt_root / 'dex_assets').mkdir(parents=True, exist_ok=True)
if loader:
    inventory = {}
    roots = {'hd-dynamic-battlefields': (a.mod_root or ROOT).resolve()}
    if a.wildfollowers:
        roots['wildfollowers'] = a.wildfollowers_root.resolve()
    if menu:
        roots['gen3transparency'] = a.menu_root.resolve()
    if a.content == 'national':
        roots.update({name: a.compat_root / name / 'extracted' for name in
                      ('national_dex_gen3', 'g9-battle-sprites-gen3', 'gen3-hd-sprites')})
    elif a.content == '1025':
        roots['1025dex'] = a.dex_root.resolve()
    for name, folder in roots.items():
        if not (folder / 'manifest.json').is_file():
            p.error('Missing source manifest: ' + name)
    for name, folder in roots.items():
        for base, dirs, files in os.walk(folder):
            dirs[:] = [d for d in dirs if not d.startswith('.') and d not in ('dist', '__pycache__')]
            relative = Path(base).relative_to(folder).as_posix()
            key = 'mods/' + name + ('/' + relative if relative != '.' else '')
            inventory[key] = sorted(dirs + files)
    inventory_path = WORKSPACE / f'.work/hd-rse-loader-directory-index-{a.mode}-{a.content}.json'
    inventory_path.write_text(json.dumps(inventory))
output = ROOT / 'docs/evidence/rse'
if loader:
    output /= 'loader/' + ('menu-customizer' if menu else 'native')
output /= 'runtime-v' + a.runtime_version
if a.mod_root:
    output /= 'packaged-base'
if a.content != 'none':
    output /= a.content
if a.wildfollowers:
    output /= 'wildfollowers'
if a.installed_pack_fixture:
    output /= 'installed-pack'
if a.double:
    output /= 'doubles'
if a.resize:
    output /= 'resize' if a.resize_method == 'mode' else 'resize-desktop'
if a.transitions:
    output /= 'transitions'
if a.move_effects:
    output /= 'move-effects'
if a.battle_flow:
    output /= 'battle-flow'
output.mkdir(parents=True, exist_ok=True)
# A failed rerun must never leave an earlier success summary authoritative.
(output / a.report_name).unlink(missing_ok=True)
reports = []
for game in a.game or ['ruby', 'sapphire', 'emerald']:
    for size in a.size or ['1280x720', '5120x1440', '900x1600']:
        error = output / (game + '-native-error.txt')
        error.unlink(missing_ok=True)
        (output / f'{game}-{size}-render.json').unlink(missing_ok=True)
        env = {**os.environ, 'HDB_WORKSPACE': str(WORKSPACE), 'HDB_GAME_VERSION': game,
               'HDB_SIZE': size, 'HDB_RENDER': '1', 'HDB_LOADER': '1' if loader else '0',
               'HDB_ALL_AREAS': '1' if a.all_areas else '0', 'HDB_MENU_CUSTOMIZER': '1' if menu else '0', 'HDB_MENU_ROOT': str(a.menu_root.resolve())}
        if loader:
            env['HDB_INVENTORY_PATH'] = str(inventory_path)
        env.update(HDB_CONTENT_MODE=a.content, HDB_COMPAT_ROOT=str(a.compat_root.resolve()),HDB_DEX_ROOT=str(a.dex_root.resolve()))
        env['HDB_MOD_ROOT'] = str((a.mod_root or ROOT).resolve())
        env['HDB_REQUIRE_MANIFEST_GAME'] = '1' if a.require_manifest_game else '0'
        env['HDB_PACKAGED_BASE'] = '1' if a.mod_root else '0'
        env['HDB_REVIEW_FAMILIES'] = ','.join(a.family or [])
        env['HDB_WILDFOLLOWERS'] = '1' if a.wildfollowers else '0'
        env['HDB_WILDFOLLOWERS_ROOT'] = str(a.wildfollowers_root.resolve())
        if a.installed_pack_fixture:
            env['HDB_PACK_FIXTURE'] = str(a.installed_pack_fixture.resolve())
        else:
            env.pop('HDB_PACK_FIXTURE', None)
        env['HDB_DOUBLE'] = '1' if a.double else '0'
        env['HDB_RESIZE_METHOD'] = a.resize_method
        env['HDB_RESIZE'] = '1' if a.resize else '0'
        env['HDB_TRANSITIONS'] = '1' if a.transitions else '0'
        env['HDB_MOVE_EFFECTS'] = '1' if a.move_effects else '0'
        env['HDB_BATTLE_FLOW'] = '1' if a.battle_flow else '0'
        env['HDB_PREPARE_DEX_ASSETS'] = '1' if a.prepare_dex_assets else '0'
        env['HDB_DEX_RECEIPT_ROOT'] = str(receipt_root)
        env['HDB_ENGINE_ROOT'] = str(engine_root)
        env['HDB_RUNTIME_VERSION'] = a.runtime_version
        process = subprocess.run([str(a.love.resolve()), str(ROOT / 'tools/rse_native_probe')],
                                 env=env, capture_output=True, text=True, timeout=600 if a.all_areas else 120,
                                 creationflags=getattr(subprocess, 'CREATE_NO_WINDOW', 0))
        if process.returncode or error.exists():
            error.with_suffix('.process.log').write_text(f'Process exit code: {process.returncode}\n' + process.stdout + process.stderr, encoding='utf-8')
            detail = error.read_text() if error.exists() else ''
            raise RuntimeError(f'Native process exit code: {process.returncode}\n' + detail + '\n' + (process.stdout + process.stderr)[-6000:])
        report = json.loads((output / f'{game}-{size}-render.json').read_text())
        assert report.get('double_fixture', False) == a.double
        assert report.get('native_field_weather_verified'), 'Field fog/battle-weather precedence not verified'
        if a.installed_pack_fixture:
            assert any(c.get('installed_pack', {}).get('verified') for c in report['checks']), 'Installed pack was not exercised'
        if a.resize:
            assert len(report.get('resize', {}).get('checks', [])) == 7
        if a.transitions:
            assert len(report.get('presentation_transitions', {}).get('checks', [])) == 8
        if a.move_effects:
            assert len(report.get('move_effects', {}).get('moves', [])) == 5
        if a.battle_flow:
            assert report.get('battle_flow', {}).get('result') == 'win'
        assert len(report['checks']) == report.get('expected_scene_checks', (10 if a.content == 'none' else 11)) and report['native_clock_verified'] and report['missing_family_native_fallback']
        assert all(c['native_ui_calls_unchanged'] for c in report['checks'])
        if loader:
            assert report['real_loader'] and report['native_options_verified'] and report['species_choices'] >= 386
        reports.append({'game': game, 'size': size, 'scene_checks': len(report['checks']),
                        'installed_pack_checks': sum(bool(c.get('installed_pack', {}).get('verified')) for c in report['checks']),
                        'resize_checks': len(report.get('resize', {}).get('checks', [])),
                        'presentation_transition_checks': len(report.get('presentation_transitions', {}).get('checks', []))})
        print(a.mode, game, size, 'PASS', flush=True)
summary = {'runtime_version': a.runtime_version, 'engine': str(engine_root), 'mode': a.mode, 'content': a.content, 'wildfollowers': a.wildfollowers, 'installed_pack_fixture': bool(a.installed_pack_fixture), 'resize': a.resize, 'resize_method': a.resize_method if a.resize else None, 'double_fixture': a.double, 'processes': len(reports), 'scene_cases': sum(r['scene_checks'] for r in reports),
           'tested_mod_root': str((a.mod_root or ROOT).resolve()), 'extracted_base_package': bool(a.mod_root),
           'candidate_manifest_only': loader and any(game not in manifest_data['games'] for game in requested_games), 'require_manifest_game': a.require_manifest_game, 'tested_mod_version': manifest_data['version'], 'all_areas': a.all_areas, 'review_families': a.family or [], 'reports': reports,
           'limitations': ('One representative native map per reachable catalog family, with day/night sources; ' if a.all_areas else 'Limited original scenery fixtures; ') + ('Four-battler trainer fixture only; ' if a.double else 'Doubles not covered; ') + ('Native automatic trainer battle completed; ' if a.battle_flow else 'Full battle flow not exercised; ') + ('Five native move animation scripts exercised; ' if a.move_effects else '') + 'No full playthrough, every-map coverage, custom UI profiles, overworld follower behavior or exhaustive sprite coverage. Successful loading/UI trace checks do not prove visual grounding.'}
(output / a.report_name).write_text(json.dumps(summary, indent=2) + '\n')
print(json.dumps(summary))
