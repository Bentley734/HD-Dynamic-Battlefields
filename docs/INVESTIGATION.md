# Runtime investigation — in progress

Testing target: latest official release v0.3.88, checked 2026-10-15 through the GitHub releases API. Downloaded the official .love payload, verified its published SHA-256, and extracted its source to `.work/hd-battlefields-latest/v0.3.88/engine`. Exact provenance is in TEST-RUNTIME.json. Earlier 0.3.85 research findings must be rechecked against this target. The user-installed executable embeds 0.3.51; it was left untouched.

## Verified seams

- `src/mods/Loader.lua`: sandboxed `mod.fetch` is gated by the manifest network permission; owned asynchronous HTTP jobs are implemented in `src/mods/Net.lua`. Four concurrent requests and a 30-second timeout cap are documented there. Do not use blocking socket calls.
- `src/mods/AssetPacks.lua`: declared required/optional importer packs expose metadata, dimensions and entries; its facade is read-only. `mod.packs`, installation cache and per-playthrough storage are separate Loader interfaces.
- `src/mods/ImportAccess.lua`: cache reads/writes/deletes are namespaced to the mod, with a 64 MiB limit per write. No public archive-extraction operation was found. The chosen downloader design uses individual release files rather than mounting archives.
- `src/mods/Loader.lua`: `mod.assets:image` resolves paths within the mod. The v0.3.88 Sandbox/ImportAccess GPU probe also confirmed `love.graphics.newImage('mod_cache/<mod-id>/<relative>')` loads an image written by `mod.cache`. This avoids raw filesystem access and does not rely on the legacy compatibility facade.
- Gen 1 `src/battle/BattleState.lua`: native classic uses a palette-zone scratch layer, separate picture/animation layers and HUD. `drawPicsLayer` and `backPlacement` exist. `battle.overlay` occurs after the scene and is unsuitable for painting an opaque background beneath sprites.
- Gen 1 `src/battle/WideBattle.lua` has a separate render path; wrapping only classic is incomplete.
- Gen 2 `src/ui/gen2/BattleState.lua` has its own scene and battle.overlay hook. Gen 1 compatibility facades must not be mistaken for equivalent rendering semantics.
- Gen 3 `src/core/game3/battle/bg.lua` owns terrain background selection. UI and sprites are separate modules. `src/core/Game3.lua` dispatches `render.hud` after drawing, so it is not by itself a safe background injection point.
- KIM reference: its installed main.lua contains separate arena and HUD capture/render passes, viewport-derived geometry, and a custom-background provider lookup. It is reference only; no source or artwork has been copied into this project.

## Architecture decisions awaiting prototype proof

Use explicit generation adapters and a shared composition resolver. A composition identifies original artwork, ratio family, reference size and inherited anchor metadata. The renderer receives resolved coordinates, never per-background hardcoded corrections. User corrections live separately from immutable templates.

Use three prototype environments (grassland, forest, cave), each with independently composed landscape, 32:9 and portrait assets before expanding production. Independent mound assets are mandatory; no composited placeholder artwork will count as finished art.

No compatibility, rendered alignment, downloader recovery, mobile behavior, or completed artwork is claimed yet. Required next evidence: actual installed runtime version/API parity, full pack lifecycle inspection, generation rendering contracts, and viewport/sprite-contact calibration.

## Prototype progress

The pure metadata resolver is implemented in `lib/perspective.lua`. Synthetic-fixture checks pass for inheritance, missing/cyclic metadata, schema rejection, immutable user adjustments, 5120×1440 coordinate calculation, resizing and sprite contact-point positioning. These checks do not establish rendered calibration or game compatibility. Production art and calibrated metadata remain outstanding.

### Current evidence (2026-10-15)

- `tools/run_unit_tests.py`: perspective, selection, pack storage and scene checks pass. Fixed assignments can be exported/imported independently of random selection. Pack checks cover checksum failure, incomplete/torn commit preservation, restart/resume, invalid metadata, compatibility, paths, cancellation and removal, using an in-memory fault-injection backend. They do **not** prove real network reliability.
- `tools/run_gpu_probe.py`: loads actual v0.3.88 modules in an isolated LÖVE process. Confirms cache write/read, SHA-256, sandboxed texture loading and raw-filesystem denial. Renders all nine original grassland/forest/cave and aspect combinations, with independent matching mounds. Native Loader entry fixtures cover 1920×1080, 5120×1440 and 900×1600. Evidence is under `docs/evidence/`.
- Shared `lib/scene.lua` preserves artwork proportions and transforms anchors through the same cover geometry for intermediate ratios. Failed scene preparation retains the working scene; rendering failures restore caller graphics state.
- Art is generated with the built-in image tool, independently of KIM assets. Prompt provenance is in `art/PROMPTS.md`. The KIM grass-day image was subsequently inspected as a visual reference only; it is not an input image or a redistributed asset.
- Metadata remains a calibration draft. Native Red rendering fixtures pass at the three prototype aspect families as described below; no gameplay traversal, actual mobile device, weather behavior, production settings menu, public pack download or mod compatibility has passed yet. Do not infer these from the compositor probes.

Next integration gate: complete native UI/animation/overlay coverage and improve HUD legibility in the current adapter, then extend sprite/scenario calibration and generation adapters. The nine prototype composition renders are evidence for the shared architecture, not approval to skip those gates while scaling the collection.

### Gen 1 development integration

`lib/adapters/gen1_capture.lua` captures native pictures, UI and OAM effects independently. It calls v0.3.88's own picture drawing methods and observes native placement helpers instead of reimplementing send-out, fainting or sprite effects. Temporary instance/helper overrides and graphics functions are restored after capture, including the injected error case. Captured pictures and native HUD glyphs use integer scales; the illustrated scene and mounds use proportional continuous scaling.

`lib/projection.lua` maps the native effect plane between battler anchors with a similarity transform. Unit checks prove endpoint registration and uniform effect scaling. A native Water Gun OAM step is captured and rendered in the GPU fixture. This does not establish correct appearance of every frame or every animation.

`tools/gpu_probe/native.lua` loads locally imported Red data and sprites into the actual v0.3.88 BattleState. It renders the grassland scene, checks native send-out stages, confirms both fainted sprite layers and the fainted player's HUD/name clear, and verifies override rollback. The user's save is not read or modified. Evidence includes `native-red-command-prototype.png`, `native-red-enemy-fainted.png` and `native-red-watergun-prototype.png`.

`tools/gpu_probe/entry.lua` loads the new `main.lua` and `manifest.json` through the actual Loader/Sandbox using an isolated injected filesystem. It verifies composition ownership, exact Route 1 map lookup, persistent adjustment writes/rejection/reset, native fallbacks for unknown maps/wide layouts/overlay states, downstream compositor ownership, and disabling. `native-red-entry.txt` records the result. The source tree is a development mod; it has not been installed into the live game.

The development classifier recognizes Route 1, Viridian Forest and Mt. Moon 1F; broader map coverage remains required. Manual Grassland/Forest/Cave controls work in the prototype. The native flat options schema is explicitly temporary and does not fulfill the required grouped OPTIONS menu. The development manifest targets Gen 1 only until other generation adapters exist; final scope remains all eleven named games.

Outstanding adapter concerns: full battle traversal, native wide layout, wavy-screen projection, full-screen palette/flash behavior, overlays above an active battle, trainer/capture/substitute/minimize cases, all attack animation paths, high-DPI/orientation behavior and third-party sprite/HUD integrations. The current fallback gates avoid claiming support for those paths, but their visual transitions and production integration still require work.

### Aspect artwork and physical pixel grid

All three prototype environments now have separately generated landscape, panoramic and portrait illustrations plus independent RGBA mound assets. Their exact prompts and checksum/dimension inventory are in `art/`. Panoramic source outputs contain composition bleed; explicit `source_rect` definitions select calibrated 32:9 regions without stretching. Source files remain intact. A shared sampling path also handles one-pixel ratio rounding proportionally.

The same real Loader entry fixture switches among all three environments at 1920×1080, 5120×1440 and 900×1600. Composition IDs and metadata change appropriately. Native sprite/mound positions and bottom-panel/HUD placement come from their aspect templates. Cave-specific horizon and opponent anchors are metadata overrides, with no renderer branches for that background.

`lib/pixel_grid.lua` chooses integer physical pixel scales and snaps native sprite/UI positions. The presentation canvas follows the requested device density, then the layout uses the canvas's actual rounded density. This distinction matters: nominal 2.75 at a 390×693 logical viewport produced an actual staging density of about 2.75036. The GPU trace checks all three native HUD/panel draws against that actual density and passes; `native-red-portrait-density-2_75.png` records the output. This is an emulated high-DPI buffer, not an Android device test.

Failure injection now includes a native callback that pushes graphics state before throwing and a HUD draw failure inside staged composition. Checks prove temporary overrides/stack depth and destination canvas are restored, and a failed staged frame never paints partial scenery onto live output.

Prototype UI limitations are explicit: move-selection PP/type regions and other phase-specific UI are not yet completely composed, and native black HUD text needs improved contrast on detailed art while retaining interface-mod ownership. Full battle traversal, native WIDE mode, physical orientation and other game generations remain open.

## Gen 2/3 layer contracts inspected (implementation ongoing)

Gen 2 drawSceneBody delegates to drawPanel or animation scanline presenters; drawPanel clears through Chrome and renders drawHud/drawBottom. Native wide presentation uses a separate WideBattle path. A safe scenery adapter must preserve scanline presentation, lifted sprite rows and GBC palette handling; no Gen 2 renderer is enabled yet.

Gen 3 exposes BattleBg.draw as its terrain renderer. FRLG and RSE resolve terrain via distinct env modules, and scene integer IDs overlap with different meanings. Added a read-only gen3_context adapter and named family taxonomy resolving against the actual runtime TERRAIN table. It distinguishes tall grass, underwater/ocean/pond, scene-specific interiors, Elite Four and legendary/team locations. This is not yet wired into the entry or claimed game-tested. No tests run in this stage.
