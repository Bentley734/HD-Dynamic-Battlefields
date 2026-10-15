# Scope and evidence ledger

The complete specification remains authoritative. This ledger tracks progress; it does not narrow release criteria.

| Specification area | Current authoritative evidence | Remaining release gate |
|---|---|---|
| 1. Runtime investigation | Exact v0.3.88 artifact/provenance, source inspection, sandbox/cache GPU probe, Gen 1 capture and real Loader entry fixture | Complete generation adapters, full actual game/map contracts, compatibility policy |
| 2. Original artwork | Nine original grassland/forest/cave compositions across 16:9, 32:9 and 9:16, rendered with native sprites | Further calibration; 3–5 distinct variations for **every** natural, interior and special environment listed in the specification; all special location refinements |
| 3. Aspect/resolution support | All nine ratio families recognized in selection tests; uniform transforms; actual offscreen 5120×1440 and 900×1600 native Red renders; fractional-density native text checks | Remaining ratio compositions; Mobile/HD/Ultra-HD tiers; physical devices, orientation/window events and broad resizing/scenario evidence |
| 4. Independent mounds/grounding | Three original transparent grass/forest/cave mounds; separate rendering; native placement/contact math; global/aspect adjustment resolution | All remaining mound types, sprite/species corrections, live calibration, real sprite sets, shadows/hovering and independent controls |
| 5. Shared perspective metadata | Versioned validation/inheritance, shared scene geometry, fault fallback, calibration guides | All production compositions calibrated; complete lighting/correction validation, visual editing/export UI, native rendering fallback integration |
| 6. Time/weather | None | Actual in-game/system/manual day/night, weather source adapters, reusable lighting and atmospheric effects |
| 7. Animation | None | Illustrated optional environment layers and OFF/LOW/MEDIUM/HIGH processing budgets |
| 8. Asset distribution | Transactional individual-file storage; actual runtime cache/image support; simulated failure/recovery checks | Real published GitHub files and manifest, full version/coverage/schema checks, asset-manager UI, real progress/download/recovery/offline/update/remove/restore tests; offline packages |
| 9. Environment/selection | Random/fixed selection and assignment persistence; Route 1/Forest/Mt. Moon 1F lookups; working manual prototype overrides; fallback results | Complete per-game map/terrain/context classification, assignment editing/reset UI, special encounter rules |
| 10. Mod compatibility | Inspected KIM architecture as reference; no copied code/art; native Red sprite/send-out/faint/OAM fixture | Actual tests with 1025Dex, WildFollowers, Menu Customizer, vanilla/alternate/animated sprites; tested KIM coexistence policy |
| 11. Configuration | Temporary native development controls; validated persistent anchor adjustment API | Production OPTIONS → HD BATTLEFIELDS: Backgrounds, Animation, Mounds, Display, Asset Manager, Diagnostics; persistence/live application |
| 12. Performance | Scene releases unused textures; no per-frame image decode; graphics-state restoration | Actual transition/resize/load/memory/frame-time tests, desktop and mobile, preload/cache policy |
| 13. QA | Pure Lua tests plus actual-runtime sandbox/GPU compositor evidence | All supported games, scenarios, sprites, displays, perspective cases and asset faults explicitly listed in specification |
| 14. Roadmap/release | Phase 1 research and partial Phase 2 prototype | Complete all eight phases, installable archive, source, art/packs/metadata/manifests/docs/matrix/results/limitations, published latest release and verified assets |
| 15. Invariants | Shared code has no per-background positions; source art original; mounds independent; adjustments immutable | Prove all fifteen non-negotiable requirements against final installed release |

Supported game scope: Red, Blue, Yellow, Gold, Silver, Crystal, FireRed, LeafGreen, Ruby, Sapphire, Emerald wherever the target runtime supports them. Red has isolated native-renderer/Loader evidence; none is yet marked gameplay-tested.

Unit checks involving 5120×1440 coordinates are **not** the required rendered 5120×1440 test. A 16:9 picture cropped into a tall or ultrawide probe would **not** count as dedicated artwork.

## Scope correction and current integration evidence

Battle UI is explicitly outside this mod's ownership. The active entry exports scenery only; native/custom sprites, effects, fonts, HUDs and panels remain with the runtime and Menu Customizer. Legacy capture-adapter evidence is historical. Current v0.3.88 Loader fixture with complete Menu Customizer v3.35.4 confirms identical native render calls/transforms and final-window scenery at 16:9, 32:9 (5120x1440), and portrait. Grassland horizon framing was raised and visually checked beneath native Rattata. Full gameplay, alternate sprite contact calibration, standalone-without-Menu-Customizer integration, other generations, the complete artwork collection and all remaining gates above are still required.

## Additional current-state evidence

- Standalone Gen 1 scenery insertion is implemented and fixture-tested on official v0.3.88 without replacing battle composition or redrawing UI/sprites. Complete Menu Customizer coexistence fixture still passes. Native unknown-map/disabled fallbacks and error restoration pass.
- Native mound grounding now preserves global/aspect adjustments and scale; metadata remains immutable. Exact custom placement-mod contracts and alternate sprite sets remain required.
- All 224 native Red map IDs/tileset signatures are classified explicitly and checked against actual imported runtime data. Water/land and special arenas/legendary encounters are distinguished; missing environment art retains native scenery. This does not complete classification/QA for the other ten games or create absent artwork.
- Official latest release was checked again and remains v0.3.88.

## In-progress settings integration (tests deferred by user)

Added native OPTIONS → HD BATTLEFIELDS subpages for Backgrounds, Animation, Mounds and Diagnostics. Multi-choice activation opens an explicit selection list; row step callbacks retain cycling for consumers that support it. Settings write to the runtime's namespaced options bucket and existing persistence. Display controls, mound adjustment UI and the Asset Manager are still incomplete. No tests were run for this change, per the user's instruction to defer tests until implementation is finished.

## Display and calibration implementation (unvalidated)

Added DISPLAY aspect-family override and viewport readout, global/per-aspect mound horizontal/vertical offsets and independent scales, per-scope/all-position resets, and persisted fixed-assignment reset. Calibration edits use copied storage data and the existing validation API; authored metadata is retained. Only scenery moves: the later user instruction forbids modifying Pokémon placement or battle UI. HD texture tier is shown as information until downloadable resolution packs exist. Own settings pages handle Left/Right cycling before native activation and A opens option lists. Tests remain deferred until the end as requested; these changes are not claimed validated.

## Asset catalog integration (unvalidated; tests deferred)

Added installed-pack catalog loading with content-addressed cache texture paths, namespaced metadata inheritance, and atomic artwork/metadata admission after full pack verification. Bundled prototypes remain the fallback. Pack downloads advance from the game update path; verified completion persists the installed-pack index and refreshes scene selection. Removal refreshes selection and releases old scene resources. Outdoor packs now require separate day/night artwork and matching independent night mounds. Public download index, production pack publishing, asset-manager UI and final fault/runtime tests remain required. No tests run in this stage.

## Asset Manager page implementation (unvalidated)

Added OPTIONS → HD BATTLEFIELDS → ASSET MANAGER with aspect/quality browsing filters, display recommendation, available/installed pack pages, download/restore, verification, removal, progress/error display, cancellation and refresh. It uses the existing transactional store. The published-pack index is deliberately empty until real release assets exist; the page reports NOT PUBLISHED YET instead of offering fake download links. Remote update-index fetching and actual published packs remain required. Tests remain deferred.

## Release preparation implementation (unvalidated)

Implemented a source-catalog pack builder that groups existing assets by aspect/quality, includes separate period art and mounds, resolves metadata dependencies, produces versioned file descriptors with SHA-256 and compatibility/size fields, and stages offline ZIPs plus an aggregate index/checksum list. No build or tests were run, no download URLs were shipped, and no partial HD release was published. Full artwork scope and final validation remain unchanged.

## Release-index refresh implementation (unvalidated)

Added asynchronous GitHub latest-release index fetching with repository-pinned asset URLs, schema/compatibility checks, bounded index size, duplicate-pack rejection and two checksummed offline cache slots. The Asset Manager reads refreshed descriptors and exposes update checks only when a real repository is configured. The development seed has no repository, so it offers no fake network action. The source pack builder now emits repository identity. Nothing was tested or published in this stage.

## Pack admission hardening (unvalidated)

Pack catalog validation now requires exact composition metadata IDs, matching quality tiers, positive integer variation numbers, declared aspect/environment coverage in both directions, valid numeric sampling regions, and distinct day/night file references. Cached update indexes cannot introduce downloadable packs when no trusted release repository is configured. These changes were implemented without running tests, which remain deferred to the final validation stage.

## Quality selection integration (unvalidated)

DISPLAY texture tier now routes Mobile/HD/Ultra-HD directly into composition selection. Uninstalled tiers retain native scenery rather than silently loading another tier. Diagnostics show the actual selected tier, aspect and pack. Fixed location assignments now persist variation identity independent of pack ID/resolution, retaining legacy exact-ID reads. No additional resolution-tier artwork is claimed produced, and no tests were run.

## Texture admission implementation (unvalidated)

Pack verification now inspects PNG signatures/IHDR, caps dimensions/pixel count, requires supported RGB/RGBA depth, requires an alpha channel for mound assets, checks actual source crop bounds and matches each day/night artwork region to perspective aspect. Header checks do not replace final image decoding/visual validation; transparent-channel presence does not prove a correct silhouette. No tests run; final verification remains pending.

## Per-composition calibration (unvalidated)

Added validated composition-specific adjustment storage and precedence after global/aspect overrides. The Mounds scope picker offers the current background when a composition is known, with per-scope reset. Composition IDs namespace downloaded pack revisions, keeping local calibration isolated from unrelated artwork and retaining authored metadata. No tests run; final validation is still deferred.

## Calibration export implementation (unvalidated)

Added Diagnostics export of the last rendered scenery layout as a separately validated JSON metadata draft in the mod cache. The export records normalized mound anchors/bounds/scales, viewport and a copy of saved adjustments; original metadata is not overwritten and no sprite/UI placement is applied. The UI reports the last export path. Live visual dragging and full custom-sprite contact integration remain incomplete. Tests remain deferred.

## Artwork expansion in progress

Generated original grassland variation two (16:9 day): upland pasture with dry stone wall, hawthorn, low hills and a distant lane, distinct from variation one's lake valley. Exact prompt is preserved. Separate night counterpart is being generated before paired registration. This is a source candidate, not a tested/calibrated release asset; all remaining variations/environment/aspect/tier requirements remain. No tests run.

Grassland variation two now has distinct generated 16:9 day/night source images and is registered with independent metadata, using the existing compatible grass mound pair. Runtime calibration and all other aspect families for variation two remain unverified/unproduced. No tests run.

## Variation-two aspect artwork expansion

Generated separate original panoramic and portrait day compositions for grassland variation two, preserving its pasture/stone-wall/hawthorn identity with new framing. Saved untouched generator outputs and exact prompts. These remain unregistered source candidates until their separate night counterparts and matching metadata are present; no runtime tests or rendered calibration were run. The panoramic source includes vertical bleed and still requires an authored 32:9 sampling region.

## Grassland variation two paired aspect registration

Saved separate generated night panorama and portrait originals, retained exact prompts, and registered paired 32:9/9:16 compositions with independent shared-template metadata. Panoramic source regions retain uniform sampling and exclude surplus sky. These entries remain uncalibrated runtime candidates; tests are deferred. Grassland now has two distinct variations across the three prototype aspect families, still short of the required complete environment/variation/aspect/tier collection.

## Offline installer implementation (unvalidated)

Added an explicit-cache offline ZIP importer with manifest/archive/member checksums, member-set/size/path checks, content-addressed staging and atomic checksummed commit slots matching the runtime. It does not extract arbitrary archive paths. The game must be closed during import. Runtime catalog checks remain authoritative for metadata and imagery admission. No installation or tests were performed.

## Damaged pack recovery UI (unvalidated)

Installed descriptors now remain visible even when their payload fails verification; invalid packs are excluded from rendering and labeled REPAIR NEEDED with their concrete error. Asset Manager retains download/restore and removal access. Refresh clears stale aggregate errors and recomputes pack health. No tests run.

## Six-image grassland aspect batch

Added and registered original day/night pairs for variation-two 4:3, 16:10 and 3:2 compositions with explicit ratio/reference metadata and independent day/night mound assets. This is a source/registration batch, not a claim of successful native runtime alignment. Next consolidated check must inspect actual sprite-foot/mound contact at these ratios and resizing thresholds.

## Consolidated validation resumed

Per latest user direction, ran a substantial batch after the six new ratio/period images: current unit suite and 18 v0.3.88 native/full-Menu-Customizer day/night render cases, including 4:3, 16:10, 3:2, widescreen, 5120x1440, portrait and adjacent sizes. Three new-ratio outputs visually inspected with grounded opponent/mound contact. Evidence and limits are documented in COMPATIBILITY.md. Remaining ratio families, all uninspected outputs, alternate sprites, other games and production asset tooling still require validation.

## Remaining grassland aspect day sources

Generated dedicated 21:9, 9:19.5 and 9:20 day compositions for the pasture scene. Saved original files and exact prompts. Matching night sources and registered metadata are still needed before the nine-family alignment batch. These are not substitutes for other environments' dedicated compositions or quality tiers.
