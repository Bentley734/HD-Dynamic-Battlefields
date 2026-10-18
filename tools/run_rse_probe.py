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
p.add_argument('--mode', choices=['direct', 'loader', 'menu-customizer'], default='loader')
p.add_argument('--game', action='append', choices=['ruby', 'sapphire', 'emerald'])
p.add_argument('--size', action='append', choices=['1280x720', '5120x1440', '900x1600'])
p.add_argument('--love', type=Path, default=WORKSPACE / '.tools/love-audio-runtime/love-probe.exe')
p.add_argument('--menu-root', type=Path, default=WORKSPACE / '.work/menu-gen3-font-fix')
p.add_argument('--content', choices=['none', 'national', '1025'], default='none')
p.add_argument('--compat-root', type=Path, default=WORKSPACE / '.work/hd-frlg-compat')
p.add_argument('--dex-root', type=Path, default=WORKSPACE / '.work/hd-rse-compat-latest/1025dex-1.5.1/extracted/1025dex')
a = p.parse_args()
loader = a.mode != 'direct'
menu = a.mode == 'menu-customizer'
if a.content != 'none' and not loader:
    p.error('Content mods require a real-loader mode')
if menu and not (a.menu_root / 'manifest.json').is_file():
    p.error('Menu Customizer source is required for this mode')
if loader:
    inventory = {}
    roots = {'hd-dynamic-battlefields': ROOT}
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
if a.content != 'none':
    output /= a.content
output.mkdir(parents=True, exist_ok=True)
reports = []
for game in a.game or ['ruby', 'sapphire', 'emerald']:
    for size in a.size or ['1280x720', '5120x1440', '900x1600']:
        error = output / (game + '-native-error.txt')
        error.unlink(missing_ok=True)
        env = {**os.environ, 'HDB_WORKSPACE': str(WORKSPACE), 'HDB_GAME_VERSION': game,
               'HDB_SIZE': size, 'HDB_RENDER': '1', 'HDB_LOADER': '1' if loader else '0',
               'HDB_MENU_CUSTOMIZER': '1' if menu else '0', 'HDB_MENU_ROOT': str(a.menu_root.resolve())}
        if loader:
            env['HDB_INVENTORY_PATH'] = str(inventory_path)
        env.update(HDB_CONTENT_MODE=a.content, HDB_COMPAT_ROOT=str(a.compat_root.resolve()),HDB_DEX_ROOT=str(a.dex_root.resolve()))
        process = subprocess.run([str(a.love.resolve()), str(ROOT / 'tools/rse_native_probe')],
                                 env=env, capture_output=True, text=True, timeout=120,
                                 creationflags=getattr(subprocess, 'CREATE_NO_WINDOW', 0))
        if process.returncode or error.exists():
            raise RuntimeError(error.read_text() if error.exists() else process.stdout + process.stderr)
        report = json.loads((output / f'{game}-{size}-render.json').read_text())
        assert len(report['checks']) == (3 if a.content == 'none' else 4) and report['native_clock_verified'] and report['missing_family_native_fallback']
        assert all(c['native_ui_calls_unchanged'] for c in report['checks'])
        if loader:
            assert report['real_loader'] and report['native_options_verified'] and report['species_choices'] >= 386
        reports.append({'game': game, 'size': size, 'scene_checks': len(report['checks'])})
        print(a.mode, game, size, 'PASS', flush=True)
summary = {'mode': a.mode, 'content': a.content, 'processes': len(reports), 'scene_cases': sum(r['scene_checks'] for r in reports),
           'candidate_manifest_only': loader, 'reports': reports,
           'limitations': 'Limited grassland/ashfield and selected native/added species fixtures. No full playthrough, doubles, animations, custom UI profiles or exhaustive sprite coverage.'}
(output / 'runner-summary.json').write_text(json.dumps(summary, indent=2) + '\n')
print(json.dumps(summary))
