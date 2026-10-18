# Hoenn development — Ruby, Sapphire and Emerald

The published 0.2.0-beta.1 remains the Kanto/Johto build. This development
stage does not enable or claim R/S/E scenery support in its release manifest.

## Native inspection

`tools/inspect_rse_battle_maps.py` reads imported native headers, encounters
and reachable object/coordinate/sign event scripts without loading saves.
It resolves each map's actual RU_, SA_ or EM_ identity from native constants.

- Ruby: 394 imported maps; 142 with positive wild/event battle evidence.
- Sapphire: 394 imported maps; 142 with positive wild/event battle evidence.
- Emerald: 518 imported maps; 177 with positive wild/event battle evidence.

These evidence counts are not proof of exhaustive gameplay coverage: native
specials, generated facilities and map-entry scripts need separate inspection.
The authoring plan explicitly includes known legendary/Frontier battle areas
and excludes unused/prototype maps. There are currently 478 battle-area
candidates across the three games and no unclassified candidates.

`metadata/rse-art-plan.json` records exact per-game IDs, land/water choices,
mixed-terrain overrides, reuse candidates and the missing-art queue. Route 111
retains grassland and a separate desert sand override. Underwater, ashfields,
volcanic terrain, Mt. Pyre, gyms, Elite Four and Frontier facilities keep distinct
identities. Eleven existing scenery families have complete nine-aspect reuse
candidates; visual fit and appropriate mound choices still need review.

## Read-only context adapter

`lib/adapters/rse_context.lua` reads the native battle/session, resolved terrain,
species, weather and existing RTC. It distinguishes native double battles from
link battles and identifies water/underwater without changing terrain IDs,
mechanics, sprite rendering or HUDs. It is now wired into the development
main.lua branch. The release manifest still excludes R/S/E while environment
coverage, loader integration and compatibility testing remain unfinished.
Its regression checks pass alongside the existing Lua suite.

`metadata/maps/rse.lua` now contains the compiled signatures, consumed by
`lib/environments_rse.lua`. The classifier checks game/map type/battle-scene
identity, applies per-battle terrain overrides and rejects uninspected water
contexts instead of choosing dry scenery. Its tests cover all 478 candidates.

The isolated `tools/rse_native_probe` runs against the actual v0.3.89 Dataset
and constructs a native battle in each of Ruby, Sapphire and Emerald. All
compiled signatures match those live datasets (142/142/194 respectively), and
the adapter reads the native battle and resolves Route 101 to grassland.
Reports are `docs/evidence/rse/*-native-context.json`. These fixtures do not
claim scenery rendering, playthrough or sprite-mod compatibility coverage.

The original native grass platform alpha bounds are recorded separately in
`native-platform-bounds.json`. Hoenn's enemy platform differs from FR/LG's;
art bounds alone are insufficient to choose final custom mound ground anchors.

## Original artwork

Route 113 ashfield day/night paintings now cover all nine aspect families,
18 source compositions under `art/gen3/<size>/ashfield/`. They were separately generated using the built-in
image tool. Exact prompts and SHA-256 authoring records are saved beside them.
Original generated files are retained. No image stretching or lighting filter
was used. The scenes contain no characters or baked-in mounds. The generator's
two 32:9 candidates included excess vertical canvas: approved crop-only trims
produce the requested ratio while preserving source-space anchor provenance.
Originals and prompts remain in `art/gen3/drafts/32x9/`.

The night painting has its own provisional horizon and opponent ground anchor.
These are authoring candidates, not calibrated runtime placements. Existing
gray-sand/pale-gravel mounds are candidates only. All 18 source records pass
dimensions, aspect tolerance, SHA-256, draft anchor bounds and crop pixel
identity checks; evidence is `ashfield-source-verification.json`. Those checks
do not certify native rendering or mound contact. Native R/S/E
integration through the real Loader/Sandbox, the other Hoenn environments,
mound/material fit and special/double battle rendering remain work
to complete before a Hoenn beta is published.

## First native scenery batch

`tools/build_rse_catalog.py` builds 108 integration candidates across 12 complete
nine-aspect families: eleven reused families and the new ashfield family.
Incomplete families stay absent, retaining native scenery. This catalog is not
yet added to the release download index. Mound bindings live separately in
`metadata/rse-mound-bindings.json`; the ashfield uses cleaned gray-sand copies
with originals preserved and provenance in `art/derivatives.json`.

The Game3 scenery adapter and native options bridge are shared with FR/LG.
Hoenn presentation profiles live in `metadata/native_rse.lua`; Ruby/Sapphire's
back-sprite layout differs from Emerald/FRLG. Their contact points remain
calibration candidates until more species and sprite providers are reviewed.

Nine isolated native processes cover Ruby/Sapphire/Emerald at 1280×720,
5120×1440 and 900×1600. Each renders grassland day and ashfield day/night,
for 27 scene cases. Actual Treecko/Poochyena native pictures are required;
the fixture resolves internal species IDs rather than supplying ambiguous
National Dex numbers. Disabled/enabled healthbox and menu call transforms
match. Native RTC period selection and missing-desert native fallback pass.
The summary is `docs/evidence/rse/scene-integration-summary.json`.

Visual review caught the initial 32:9 night horizon below the opponent mound.
A separately painted higher-horizon v2 replaces that source reference, with a
crop-only 32:9 derivative. The v1 painting and authoring record remain preserved.
The revised native 5120×1440 capture places the mound over visible ground.

These first checks use direct mod entry into the real engine, not the real mod
Loader/Sandbox. They do not validate UI-mod profiles, sprite-mod combinations,
double battles, animations, every species or the other ten candidate families.
The cleaned mound palette/texture also needs broader visual review. No Hoenn
release has been published from this development stage.

## Loader, Menu Customizer and native options batch

The next batch loads the actual mod through v0.3.89's Loader/Sandbox. The
published manifest remains unchanged; the fixture adds only its active Hoenn
game to a candidate manifest in the virtual filesystem. This proves execution
under the real sandbox, not production eligibility or release readiness.

Eighteen isolated processes cover all three games at 1280×720, 5120×1440 and
900×1600, once with HD Battlefields alone and once with Menu Customizer 3.35.15
at its default configuration. Grassland day and ashfield day/night produce
54 scene cases. Native healthbox/menu call transforms remain equal with scenery
disabled/enabled. Native clock selection and unfinished-desert fallback pass.

Each process also opens the actual game-specific OPTIONS pages, navigates
HD Battlefields → Mounds → Species Positions, selects native Treecko, applies
a one-native-pixel horizontal correction and resets it. All 386 native species
are exposed by the chooser. The fixture uses the native save schema to create
an identified save facade alongside its session; storage writes go only to the
virtual filesystem, not live game saves. Early storage rejection was a fixture
omission of that facade, not evidence of a runtime storage defect.

The options bridge now resolves the active screen through Screens.get instead
of assuming FR/LG's menu. Ruby/Sapphire use their native _pages stack; Emerald
uses _st.pages. Public adjustment guards follow the active Game3 session.
FireRed with National Dex Gen 3 + G9 Battle Sprites + Gen3 HD Sprites passes a
separate 1280×720 regression, including its chooser and twelve habitat cases.

Evidence: `docs/evidence/rse/loader/integration-summary.json` and
`docs/evidence/rse/frlg-options-regression.json`. The Menu Customizer screenshots
were visually reviewed in Emerald; default consumer font/layout behavior is
preserved, not claimed repaired. User-defined UI profiles, other sprite mods,
double battles, animation scripts and full gameplay traversal remain untested
by this batch. Other candidate environments still need visual calibration.

Reproduce a full mode with `python tools/run_rse_probe.py --mode loader` or
`--mode menu-customizer`. Use `--game emerald --size 1280x720` for one case.
The runner accepts alternate LÖVE and Menu Customizer paths, prepares its
directory inventory and records the exact limited run scope.


Expanded-content candidate checks (2026-10-18): the real Loader runs with
National Dex Gen3, G9 Battle Sprites and Gen3 HD Sprites in all three Hoenn
games at 1280x720, 5120x1440 and 900x1600. All 36 scenery cases pass,
including an added Pecharunt fixture with a nontransparent sprite pixel check.
Registered species/forms are checked against the position chooser. Reports
record exact loaded versions under `docs/evidence/rse/loader/native/national`.
This is limited render/options evidence, not a full gameplay certification.

The published 1025Dex 1.5.1 core package was separately downloaded and verified
against its GitHub asset digest. Its chooser contains added species/forms,
but the fixture does not yet install its separate persistent artwork pack.
A blank placeholder was initially accepted by the nonnil-image assertion;
that assertion is now supplemented by an alpha-pixel check, which correctly
fails. The earlier 1025 reports explicitly record incomplete status and must
not be used as sprite compatibility proof. Install the catalog-verified pack
in the isolated fixture before repeating this matrix. No real saves were read
or written. Inventory files are isolated by mode/content to avoid competing
fixture runs replacing each other's mod directory listings.


Follow-up: the isolated fixture now reads the separately installed 1025Dex
artwork through its injected cache filesystem. All 23,109 entries match the
published core's size/SHA-256 catalog (`1025dex-artwork-verification.json`).
Normal draw/update cycles bake the battle-scoped sprite sheets before capture;
the initial transparent image was not evidence of an HDB renderer defect.
The repeated matrix passes all 36 cases across R/S/E and three sizes. Emerald's
Pecharunt screenshot was visually reviewed with the sprite above the mound.
These reports supersede the preceding incomplete fixture results. Doubles,
move animations and full playthroughs remain outside this proof.

Rainforest now has its first original 16:9 day and separately painted night
sources. Prompts and draft perspective records sit beside each PNG. The night
treeline is lower, so its opponent ground anchor is recorded separately.
Neither painting is runtime-enabled: eight aspect pairs and in-game mound
calibration remain. Source integrity is recorded separately from coverage.

Rainforest source progress: eight original paintings now cover day/night at
16:9, 4:3, 3:2 and 9:16. Five aspect pairs remain. PNG integrity and source
hashes pass; horizons and draft anchors reflect each painting, including
the lower 3:2 daytime treeline. Gameplay calibration is still pending.

Rainforest now also has 16:10, 21:9 and 32:9 day/night originals: fourteen
active sources, seven aspect pairs. The 32:9 paintings arrived with excess
canvas; reviewed crop rectangles trim only bottom canvas, preserve originals
and standing regions, and pass pixel-for-pixel crop identity checks. Prompts
and transformed draft anchors are retained. The two tall-phone aspect pairs
remain, followed by complete-family validation and gameplay calibration.

Rainforest's first day/night source family now covers all nine aspect ratios
(18 paintings). `rainforest-source-verification.json` proves PNG integrity,
source hashes, dimensions, draft anchor bounds and crop provenance. The final
9:20 day crop trims only excess side canvas and keeps both standing regions;
the original and exact prompt remain under drafts. These are authoring
candidates, not evidence of runtime mound contact. Next: bind an appropriate
forest mound, integrate the complete candidate family, and inspect native
Hoenn captures at wide, ultrawide and portrait sizes before treating it as
release-ready.

Rainforest candidate integration (2026-10-18): the development catalog now
contains117 compositions across13 families. Rainforest uses separate cleaned
day/night forest mound cutouts, preserving original art and recording edge
processing in art/derivatives.json. Its outdoor policy enables the independently
painted night image. The published manifest/download packs remain unchanged.

The first native16:9 night capture exposed the enemy mound overlapping the
forest backdrop. A targeted image edit raised the ground boundary; the v1
image and metadata remain preserved, and the active record references v2
with its own SHA/geometry and saved edit prompt. Emerald1280x720 v2 was
visually reviewed, plus5120x1440 and900x1600 night captures. All45 final
render checks pass across R/S/E and those three sizes, including native UI
call transforms, clocks, missing-family fallback and options. The Lua suite
also passes. This does not certify all nine aspects, arbitrary resizing,
species contact points, sprite/UI mod combinations, doubles or animations.
Further art/mound color blending and remaining aspect calibration are pending.

Additional-aspect native captures now include Emerald4:3,16:10,3:2,21:9,
9:19.5 and9:20 (30 limited render checks). Review exposed low nighttime
treelines in16:10 and21:9: separately saved v2 edits raise them, preserve
originals/prior metadata and have correct image reference dimensions. The
final additional-aspect batch and source integrity checks pass. Native
captures of those two revisions were visually reviewed with clear ground
behind the enemy mound. Review also exposes a remaining3:2 DAY issue: the
forest floor is too low behind the enemy mound. Do not interpret passing
render checks as visual calibration approval; fix this and inspect other
daytime compositions before approving the family.

Daytime native review found low forest boundaries in3:2,16:10 and21:9.
All three now use separately saved v2 edits with preserved originals, prompts,
image dimensions and draft geometry. Source validation and the30-case
additional-aspect batch pass. Native captures of those three DAY revisions
were visually reviewed with ground behind mounds. Additional reviewed samples:
4:3day,9:19.5day and9:20night. Remaining known issue:4:3 NIGHT still has
forest under the rear mound edge and needs a higher boundary. This family
remains a development candidate pending that correction and broader species,
resize, color-blending and compatibility review.

The4:3 rainforest night v2 raises the remaining low treeline. Its native
Emerald capture was reviewed with clear ground behind the rear mound edge;
the five-case4:3 fixture and18-source integrity checks pass. Prior images
and metadata remain preserved. Broader species/third-party compatibility and
mound color blending still require review.

Hoenn desert starts with byte-identical reuse of the existing original
mineral-basin16:9 day/night artwork (Gen1 unused desert variation3). Exact
prompts and SHA provenance accompany its Gen3 candidate records. No new
lighting simulation or resampling. Eight aspect pairs and gameplay
calibration remain; the incomplete family is not runtime-enabled.

Desert authoring progress: six new original paintings add4:3,3:2 and9:16
day/night compositions to the reused16:9 pair. Eight sources now cover four
of nine aspect pairs; five pairs remain. Exact built-in generation prompts
and draft geometry accompany the sources. Partial PNG/hash/dimension/aspect
checks pass;3:2 night horizon is recorded at its actual lower boundary,
not the requested prompt value. No runtime desert integration or gameplay
calibration is claimed.

Desert now adds16:10,21:9 and32:9 separate day/night sources, bringing
the initial family to14 paintings across seven aspect pairs. Exact prompts
and draft geometry are retained. The32:9 generator returned excess canvas;
reviewed crop-only rectangles remove spare ground without stretching, keep
both standing positions and pass pixel identity checks against preserved
originals. Two tall-phone pairs and complete-family validation/calibration
remain. These assets are not runtime-enabled or release-approved yet.

Desert source family complete:18 day/night sources now cover all nine aspect
ratios. Two are byte-identical reused original16:9 project paintings and16
are new original compositions. Tall-phone9:19.5 crop-only preparation keeps
standing regions and preserves originals;9:20 sources match their ratio.
Full-family source checks pass (hashes, dimensions, anchor bounds and crop
pixel provenance). Mound material selection, native integration and gameplay
calibration are next; source completion does not imply release readiness.
