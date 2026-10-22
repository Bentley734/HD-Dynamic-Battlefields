# 1025Dex mound contact audit

These read-only tools reproduce the source census, original-body alpha inventory,
production bake geometry and HD runtime lookup checks used for native 1025Dex
1.5.2 compatibility. They do not edit sprite art, 1025Dex source, game saves or
the installed game's options.

Run commands from the repository root. Use Python with `lupa`, `numpy` and
`Pillow` installed. Lupa must include `lupa.luajit21` and `lupa.lua53`; the native
renderer checks use LuaJIT. The existing workspace dependency directory can be
used through `HDB_AUDIT_DEPS`. Its Python version must match its compiled modules
(the original audit environment used Python 3.12).

## Paths and inputs

`audit_paths.py` derives the repository from its own location, and the workspace
from the repository's parent. All generated JSON, Lua data, contact sheets and
reports go to the workspace's `.work/1025-footing-audit`, outside the repository.
Every path below can be overridden with an environment variable.

| Variable | Default |
| --- | --- |
| `HDB_AUDIT_OUT` | Workspace `.work/1025-footing-audit` |
| `HDB_AUDIT_DEPS` | Workspace `.work/hd-beta-deps` |
| `HDB_DEX_SOURCE` | Workspace `.work/1025dex-double-fix` |
| `HDB_DEX_ART` | Workspace `.work/hd-rse-compat-latest/dex-artwork/assets/sprites/assets` |
| `HDB_GAME_SAVE` | Windows `APPDATA/pokemon-love2d`; otherwise `XDG_DATA_HOME/love/pokemon-love2d` with `.local/share` as the fallback data root |
| `HDB_BW_SOURCE` | Game save `mods/1025dex-bw-sprites` |
| `HDB_KIM_SOURCE` | Game save `mods/kim1025` |
| `HDB_KIM_CACHE` | Game save `mod_cache/kim1025/kim_assets/files` |

Provide the unmodified 1025Dex 1.5.2 source, its downloaded DBK/EE/static artwork,
the installed BW import and inventory, and KIM 1.7.46 source plus downloaded
artwork. Download the assets through their normal in-game managers first. The
tools inspect local inputs and never download assets. Private BW ROM imports
and original sprite artwork must remain local.

For example, set a custom input in PowerShell with
`$env:HDB_DEX_SOURCE = 'D:/ModAudit/1025Dex'`. For a normal Python installation,
replace `py -3.12` below with `python`.

## Rebuild the audit

```powershell
py -3.12 tools/dex_footing_audit/species_resolution.py
py -3.12 tools/dex_footing_audit/species_resolution.py luajit
py -3.12 tools/dex_footing_audit/kim_candidates.py
py -3.12 tools/dex_footing_audit/dex_catalog.py
py -3.12 tools/dex_footing_audit/audit_assets.py --workers 6
py -3.12 tools/dex_footing_audit/export_pack_gaps.py
```

`species_resolution.py` executes the production stem/source selector and records
the actual raw KIM requests, selected sources and matching-art fallbacks. Peer
callback objects are retained for the whole census so Python's collector cannot
invalidate a Lua callback. The default and LuaJIT censuses should agree.

`audit_assets.py` scans original, uncomposited PNG alpha for every frame, then
executes the extracted production `setupFrames` function across the native
canvas, size, anchor, hover and cloud matrix. It also audits logical player-back
alignment when the player sources front or mirrored-front artwork. Use
`--resume` to reuse a completed alpha scan; `--limit` is a development aid and
must not be used as evidence of complete coverage.

`export_pack_gaps.py` includes every scanned physical source, both full-loop and
first-frame unions, and logical `@back` variants. Zero is an explicitly audited
zero gap; a missing key means unknown geometry. Large Lua key tables are split
into function chunks to stay within LuaJIT's constant limit.

Generated release-data candidates are:

| Audit output | Repository metadata target |
| --- | --- |
| `dex_source_catalog.lua` | `metadata/dex_source_catalog.lua` |
| `kim_source_catalog.lua` | `metadata/dex_kim_sources.lua` |
| `runtime-pack-gaps.lua` | `metadata/dex_pack_gaps.lua` |

Inspect and deliberately promote these files only after reviewing the reports.
No tool automatically replaces tracked mod data or publishes a release.

## Validation and optional review sheets

The lightweight runtime check compares the repository's current helper and
metadata with all production census plans:

```powershell
py -3.12 tools/dex_footing_audit/validate_runtime_lookup.py
```

The following checks are more expensive and read the original artwork:

```powershell
py -3.12 tools/dex_footing_audit/validate_bake.py
py -3.12 tools/dex_footing_audit/render_visual_qa.py
```

`validate_bake.py` exercises the unmodified production scan, setup and pixel bake
for representative sources, preserving their original alpha. The optional
visual QA script renders colored review sheets and ranks ambiguous low tails,
appendages and support shapes for human inspection. It loads its production
support code from the adjacent tracked validation script; reports and PNGs stay
in the external audit output directory.

Alpha unions are stable silhouette contact proxies, not anatomical foot
recognition. Intentional floating, cropped back views and animation poses need
their original ground origin preserved. These tools supplement native GPU
fixtures; they do not claim that every species and animation frame was manually
viewed in a running game. Natural/fill/zoom custom battle renderers require
their own actual draw geometry and are outside this native-box calibration.
