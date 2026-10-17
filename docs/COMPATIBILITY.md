# Gen 1 Beta 1 current evidence

The current test runtime is official gen1recomp v0.3.89 (TEST-RUNTIME-0.3.89.json). BETA-1.md records the current scope and evidence. Native Red rendering and Menu Customizer 3.35.4 isolated fixtures pass; full gameplay traversal, Blue/Yellow playthroughs, physical mobile devices and expanded/animated sprite combinations remain unverified. Gen 2/3 and link presentation are not integrated.

Battle HUD, fonts, commands and dialogue remain controlled by the runtime or UI mod. Optional native Pokemon X/Y corrections now exist under Mounds > Player/Opponent and use integer native pixels. Custom sprite renderers that bypass drawBattlerPic require explicit provider integration; nonzero offsets with those renderers are not validated. KIM coexistence remains unverified.

The sections below preserve historical development evidence. Older runtime versions, removed compositor designs, distribution status and statements that positioning controls do not exist are historical and do not supersede the current beta evidence.

## Consolidated day/night aspect batch

The v0.3.88 full Menu Customizer fixture rendered 18 cases: day and night at 640x480, 1024x768, 1280x800, 1536x1024, 1279x799, 1281x801, 1920x1080, 5120x1440 and 900x1600. The fixture asserts active scenery and selected artwork period; output composition IDs are recorded in evidence/alignment-batch.json. The 4:3 day, 16:10 night and 3:2 day outputs were visually inspected for opponent foot/mound contact and horizon placement. The remaining images were generated but not all visually audited. Nearby window sizes exercise resize selection; these are isolated render fixtures, not a live gameplay traversal or physical device test.

The current unit suite passes after updating its scenery-entry mock for the asset cache and settings integration. This does not validate all newly added asset publishing, offline install or settings flows. Native battle UI remains unchanged; nighttime readability of the user's own UI palette remains controlled by Menu Customizer.

## Standalone renderer and map evidence (2026-10-15)

`tools/run_standalone_probe.py` now exercises a scenery-only Gen 1 adapter without Menu Customizer or any other consumer. It preserves native sprite/HUD/text/effect method calls and transforms, fills final screen margins at 1920x1080, 5120x1440 and 900x1600, retains native rendering for unknown maps and disabled settings, and restores its temporary paper override after an injected native HUD exception. The full Menu Customizer v3.35.4 fixture also passes with the standalone adapter installed but inactive: only one component owns scenery insertion. KIM coexistence is still unverified; the standalone adapter defers when KIM is present.

Scenery contact slots are separate generation metadata (`metadata/native_gen1.lua`). `lib/grounding.lua` fits those slots to the native integer-scaled game frame, optionally accepts exact consumer frame geometry, and applies saved global/aspect mound offsets/scales relative to immutable authored metadata. It never changes Pokémon or UI positions. Exact geometry from custom sprite-placement mods is a remaining integration requirement.

`metadata/maps/gen1.lua` explicitly classifies all 224 inspected Red map IDs and tileset signatures. The current runtime probe validates every signature against its imported map table. Categories distinguish gyms by theme, Elite Four rooms, Champion/Hall of Fame, laboratories, urban/interior/ship/cave/coastal and water contexts. Legendary rules are location/species-specific. These are classification and asset requirements, not claims that corresponding art exists or gameplay was tested. Unknown maps, altered tilesets and unmapped water contexts fail safely. Blue/Yellow map coverage is not yet validated.

Current required checks: `run_unit_tests.py`, `run_standalone_probe.py`, `run_compatibility_probe.py`. Historical capture-adapter/GPU-compositor fixtures below are not release evidence for the current entry.

## Current scenery integration evidence (2026-10-15)

`tools/run_compatibility_probe.py` loads the complete Menu Customizer v3.35.4 and HD provider through the official v0.3.88 Loader/Sandbox, with isolated native Red data. Native picture/HUD/text/effect method calls and their transforms match with HD scenery disabled/enabled. Final backbuffer screenshots (including deferred Menu Customizer names and command panels) were captured and inspected at 1920x1080, 5120x1440 and 900x1600. This proves those fixtures, not general gameplay or all sprite mods.

Grassland's 16:9 and 32:9 authored sample windows now raise distant terrain above the native opponent's ground plane. Samples retain their exact aspect ratio and horizon metadata is converted to the new frame. Portrait framing remains as authored. No battle UI or Pokémon position was changed. Evidence: compatibility-native-logical-1920x1080.png, compatibility-native-logical-5120x1440.png and compatibility-native-logical-900x1600.png.

An initial final-screen capture incorrectly changed window mode after drawing its logical canvas, invalidating graphics contents. The harness now resizes before drawing. This was a fixture error, not a verified production layering defect.

The obsolete compositor harness below is historical; current authoritative commands are run_unit_tests.py, run_scenery_probe.py and run_compatibility_probe.py.

# Current scope: scenery only

The entry exports battlefieldScenery API v1 and installs no render.compose hook. Menu Customizer consumes this provider in its existing background pass. The HD mod draws backgrounds and optional mounds only. It does not capture, resize, relocate or redraw sprites, effects, HUDs, fonts, menus or panels. HUD metadata was removed from the scenery catalog. Earlier capture-adapter evidence below describes an abandoned compositor prototype.

Focused scenery-only and dispatch/fallback checks pass using LuaJIT and official v0.3.88 JSON. Full gameplay coexistence remains pending. Previous GPU entry-compositor assertions are obsolete and must be replaced before HD release. The HD asset collection remains incomplete and unpublished.

# Development compatibility and test matrix

Target runtime: official gen1recomp **v0.3.88**. Provenance is in TEST-RUNTIME.json. The GPU harness runs extracted official runtime modules in a separate LÖVE process with locally imported game data. It does not traverse the live game or modify a user save.

| Game | Native renderer fixture | Full gameplay | Other mods | Status |
|---|---|---|---|---|
| Red | Grassland/forest/cave scenes; native pictures/UI; send-out stages; both fainted sprite layers; player faint HUD/name clearing; Water Gun OAM step; real Loader/Sandbox entry; all three prototype ratios | Not run | Not run | Development prototype only |
| Blue | Not run | Not run | Not run | Required |
| Yellow | Not run | Not run | Not run | Required |
| Gold | Not run | Not run | Not run | Adapter required |
| Silver | Not run | Not run | Not run | Adapter required |
| Crystal | Not run | Not run | Not run | Adapter required |
| FireRed | Not run | Not run | Not run | Adapter required |
| LeafGreen | Not run | Not run | Not run | Adapter required |
| Ruby | Not run | Not run | Not run | Adapter required |
| Sapphire | Not run | Not run | Not run | Adapter required |
| Emerald | Not run | Not run | Not run | Adapter required |

The offscreen GPU rendering fixture has native Red sprite/HUD evidence for all three prototype environments at 1920×1080 (16:9), 5120×1440 (32:9) and 900×1600 (9:16). The same loaded mod and battle fixture switch among these viewports, and diagnostics confirm the corresponding composition/metadata IDs. A further portrait render uses a nominal 2.75 pixel density; draw traces assert integer physical scale and physical-grid positions for all three native HUD/panel draws using the actual rounded canvas density. These are real rendered buffers, not coordinate-only checks.

All remaining ratio families, actual iPhone/Android devices, OS orientation events, native resize events, frame-time/memory budgets, sprite replacements and complete battle scenarios remain unverified. Offscreen viewport changes are not a claim of physical-device testing. Native game WIDE battle mode is distinct from displaying the adapted classic battle on a 32:9 viewport; the former remains gated off.

The development classifier recognizes Route 1, Viridian Forest and Mt. Moon 1F, checked against actual imported map IDs. The entry falls back to native rendering for unsupported maps/aspects, native wide mode, wavy-screen effects, battle overlay states and link battles. KIM1025 and Menu Customizer coexistence is gated off pending actual integration; this is not a claim of tested simultaneous compatibility. The hook respects an existing downstream composition owner. Final compatibility policy must preserve unrelated mod features where feasible.

Native UI coverage is not yet complete: command-screen fixtures are covered, while move-selection PP/type regions, overlay panels, trainer/capture-specific UI and full-screen effects still need integration and visual checks. The native black HUD glyphs also need better contrast on detailed backgrounds while preserving interface-mod ownership. These limitations prevent a production release.

No public asset downloads, pack update/remove UI, offline launch scenario or production installation archive is validated yet. The fault-injection pack-storage tests cover the backend algorithm, not public-network operation.

Reproduce current checks from the workspace root:

```powershell
python HD-Dynamic-Battlefields/tools/run_unit_tests.py
python HD-Dynamic-Battlefields/tools/run_gpu_probe.py
```

The current helper scripts depend on this workspace's Lupa dependency directory, isolated LÖVE executable, verified v0.3.88 payload/source and imported Red cache. A portable release validation harness remains required.
