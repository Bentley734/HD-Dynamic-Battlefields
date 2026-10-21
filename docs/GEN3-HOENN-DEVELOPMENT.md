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

Desert candidate integration: catalog126 compositions/14 families. Route111
SAND selects desert, with separate outdoor night art. Yellow sand mounds were
visibly mismatched; original pale mineral-sand day/night cutouts replace them,
with approved perimeter cleanup and preserved originals/prompts. Reviewed:
Ruby16:9day/night, Emerald32:9night and9:16day, clear ground and contact.
The63-case final native batch passes across R/S/E and three sizes; Lua suite
passes. Missing-art fallback explicitly selects unfinished underwater scenery
now that desert is available. Six aspect families, third-party sprite/UI
combinations, all species, doubles, animations and sandstorm appearance remain
unverified. Published eligibility/packs unchanged; no partial release.

Desert additional-aspect batch passes42 limited native cases in Emerald
(4:3,16:10,3:2,21:9,9:19.5,9:20). Captures reviewed:3:2night,16:10night,
4:3day,21:9day/night,9:19.5night,9:20day. Ground clearance and contact
look correct in those samples; this does not prove every species, orientation
change, third-party combination or sandstorm. No UI changes were introduced.

Underwater ocean authoring begins with one original16:9 ambient seabed
painting, stored with exact built-in prompt and draft geometry. It has no
creatures, baked platforms or UI. Indoor period denotes protected underwater
ambient lighting, not a terrestrial room; outdoor rain/snow must not appear.
Eight aspect sources, appropriate blue seabed mound material and native
calibration remain. The catalog builder also needs ambient-only family
integration support before this family becomes runtime-enabled.

Underwater ocean's initial ambient source set now has nine original paintings,
one dedicated composition per aspect family. Exact built-in generation prompts
are saved beside each source.32:9 and9:20 use reviewed user-authorized crops
without resampling, with originals preserved. Full source validation passes:
PNG integrity/SHA, dimensions, ratios, draft anchor bounds and exact crop
pixels. These are ambient indoor-period records to prevent outdoor rain/snow
underwater; this is not terrestrial indoor art. Native calibration, a matching
blue seabed mound and ambient-only catalog integration remain pending. The
family is not runtime-enabled, and no new release is published.

Underwater candidate integration is complete. The catalog now contains135
compositions across15 families and nine aspects. Ambient-only families use
explicit protected lighting; underwater rejects forced outdoor rain/snow and
keeps its ambient artwork even with a night override. A separately generated
blue seabed mound is bound to both sides, with original, exact prompt and
approved edge-cleaned derivative preserved.

All28 unit suites pass. The native batch passes81 limited scene cases across
Ruby/Sapphire/Emerald at16:9,32:9 and9:16, plus54 cases across Emerald's six
remaining aspect families. The fixture uses actual RS UNDERWATER1 and Emerald
UNDERWATER_ROUTE124 map identities. Underwater day captures were visually
reviewed at all nine sizes with the vanilla Treecko/Poochyena pair: the enemy
stands on its mound and the ground extends behind it. These checks preserve
native UI draw transforms; they do not prove all species, expanded sprite
mods, doubles, move animations or live window resizing. Published eligibility
and asset packs remain unchanged until the remaining Hoenn art is ready.

Meteor Falls authoring now has four separately generated ambient cavern
compositions (4:3,16:9,16:10,3:2). Original warm limestone arches and distant
waterfalls frame continuous dry stone; no characters or mounds are baked in.
Exact built-in generation prompts and draft geometry are stored with each
PNG. Integrity, hashes, dimensions, aspect and draft horizon checks pass;
the4:3 boundary records its actual lower scenery transition rather than the
requested prompt height. Five aspect compositions, matching mound selection
and native calibration remain. This partial family is excluded from runtime.

Meteor Falls now has nine ambient source compositions. The first32:9 painting
placed the back wall too low; a targeted built-in edit raises it, followed by
an authorized2079x585 crop without stretching. Both original paintings and
exact prompts remain in drafts. Full-family PNG/hash/aspect/anchor/crop checks
pass.21:9,9:16 and9:19.5 still have lower-than-requested floor transitions:
their metadata records actual boundaries and explicitly uncalibrated source
anchors. These require composition correction before native mound checks,
not moving the native battle UI or pretending prompt coordinates were met.
The family remains excluded from the runtime catalog and published packs.

Meteor Falls candidate integration: targeted built-in edits correct21:9,
9:16 and9:19.5 floor boundaries. Original PNGs and v1 authoring records are
preserved; canonical metadata references versioned v2 paintings. A new warm
rose limestone mound replaces the mismatched gray candidate, with approved
edge cleanup, original and exact prompt preserved. Catalog144 compositions,
16 families; cave climate excludes outdoor weather. All28 unit suites pass.
Emerald's nine-size batch passes90 limited scene cases, including Meteor
Falls at every aspect. All nine Meteor Falls captures were reviewed with
vanilla Treecko/Poochyena: opponent feet contact the mound, dry ground extends
behind it, and native UI transforms remain unchanged. The player contact is
partly covered by the native command panel. This does not establish all
species, expanded sprites, doubles, animations or live resize correctness.
Published eligibility and asset packs are unchanged; other Hoenn art remains.
Ruby/Sapphire add60 passing scene cases across16:9,32:9 and9:16 using
their own METEOR_FALLS_1F_1R map data. Combined with Emerald, this integration
batch totals150 cases; these are rendering fixtures, not full playthroughs.

2026-10-19 authoring-only direction: user requests no further layout testing
until the remaining Gen3 assets are finished. Continue asset generation and
source preparation; defer native render batches and gameplay calibration.

Fiery Path / volcanic_cave begins with four original ambient basalt tunnel
paintings (16:9,4:3,3:2,16:10), saved with exact built-in generation prompts
and explicitly draft geometry. Steam vents and warm mineral seams remain in
the distant scenery; mounds and creatures are absent. The3:2 generator
returned1619x971, prepared by the approved crop-only rectangle[81,0,1538,971]
with original and source geometry preserved. Five aspects and mound pairing
remain; no runtime integration or layout test was performed for this family.

Fiery Path now has one original ambient painting for each of the nine aspect
families.21:9,32:9 and three phone sources complete this authoring set.32:9
uses a2172x611 crop of its preserved2172x724 original;9:19.5 trims side canvas
to807x1749. Neither operation stretches pixels. Exact prompts, originals and
source-space draft geometry remain stored. These are source candidates only:
no new layout tests, native calibration, runtime integration or release
approval is claimed. Matching mound selection remains pending.

Mt. Chimney / volcanic_crater authoring begins with original16:9 and4:3
day/night pairs. Night paintings are separately generated artwork, with
moonlit basalt, stars and distant geothermal glow; no shader recolor is
substituted. All four sources preserve exact built-in prompts and draft
geometry. Seven aspect pairs and mound pairing remain. Layout testing is
still deferred under the user's asset-first direction; these partial sources
are not runtime-enabled or added to published download packs.

Mt. Chimney adds3:2,16:10 and21:9 separate day/night paintings, bringing the
first variation to ten source images across five aspect pairs. Each is an
original built-in generation with exact saved prompt and draft geometry;
16:10 day records its actual lower scenery boundary rather than the prompt's
requested position.32:9 and three portrait pairs remain. No layout tests,
native integration or release approval were performed in this authoring pass.

Mt. Chimney now has eighteen source paintings: separate original day/night
art for all nine aspect families.32:9 originals2048x768 retain source copies
and use crop-only2048x576 preparation.9:19.5 day trims to830x1798 and9:20 day
to808x1795, preserving originals and source-space geometry. No resampling or
day/night shader substitution. Exact built-in prompts are stored beside each
source; geometry remains draft. No layout tests were run, no mound pairing
is certified, and no runtime eligibility or published asset index changed.

Jagged Pass / volcanic_slope starts with original16:9 day and night sources.
Existing alpine mountain art was reviewed but its snowy peaks and alpine
vegetation do not fit this volcanic slope. The first generated night image
was an unwanted day/night diptych, rejected and preserved in drafts. A fresh
single-night painting replaces it in canonical authoring metadata; its actual
lower floor boundary and uncalibrated anchors are recorded explicitly.
Remaining aspects, mound pairing and later composition calibration remain.
No layout tests or runtime integration were performed.

Jagged Pass adds separate full-scene4:3 and3:2 day/night source pairs. Exact
prompts now explicitly reject split panels/comparisons; all four new outputs
are single scenes. Draft geometry is stored with each painting. The first
variation now covers three of nine aspect families; remaining six pairs and
mound pairing are pending. No native layout tests or release changes.

Jagged Pass adds16:10,21:9 and32:9 separate day/night sources, reaching six
aspect pairs.32:9 sources use approved crop-only preparation with preserved
originals/prompts. Their floor transition is lower than requested, so source
geometry records the actual boundary and uncalibrated draft anchors; later
recomposition may be required for unchanged native sprite positions. These
sources are not runtime-enabled. Three portrait pairs remain. No layout tests
were run, and battle UI and published asset packs remain unchanged.

Jagged Pass now adds its three dedicated portrait day/night pairs (9:16,
9:19.5 and9:20), completing eighteen selected source paintings across all
nine aspect families for the first variation. All six new paintings were
visually inspected as single scenes with no characters or baked mounds;
their generated dimensions fit the aspect tolerance without trimming or
resampling. Exact built-in generation prompts and draft geometry accompany
each PNG. Mound pairing and runtime calibration remain pending. No native
layout tests, runtime eligibility changes or release publication occurred.

Granite Cave authoring starts with six dedicated interior paintings for16:9,
4:3,3:2,16:10,21:9 and32:9. An existing original Gen1 cave was inspected;
its cool gray palette and bright roof opening were unsuitable for this warm
ochre/gray-brown enclosed cavern direction, so that source remains intact.
Each new painting has exact built-in generation prompts and draft geometry.
The32:9 output preserves its2048x768 original and uses an approved crop-only
rectangle[0,128,2048,704] to prepare2048x576 without resampling. Three portrait
compositions and mound pairing remain. Existing cave/cave-warm-basalt mounds
are candidates only. No layout tests, runtime eligibility changes or release
publication occurred.

Granite Cave now adds dedicated9:16,9:19.5 and9:20 portrait paintings,
completing the first source variation across all nine aspect families. Each
portrait was visually inspected as a single enclosed cave scene with clear
floor, no characters and no baked mounds. Generated dimensions fit the aspect
tolerance without cropping or resampling. Exact built-in prompts and draft
geometry are saved beside the originals. Mound fit and runtime alignment
remain untested; runtime eligibility and published asset packs are unchanged.

New Mauville authoring starts with16:9,4:3 and3:2 enclosed underground power
station paintings. Existing original Gen1 power-plant scenery was inspected
but its tall outdoor windows did not fit this setting. New sources use teal
generators, conduits and plain gray concrete floors without tiles/hardwood.
The initial16:9 composition's machinery boundary was too low; that image and
prompt are retained in drafts and a fresh composition with more floor space
is selected.4:3 records its actual lower boundary and a calibration limitation.
All selected sources have exact built-in prompts and draft geometry. Six
aspect compositions and mound pairing remain. No layout tests, runtime
eligibility changes or release publication occurred.

New Mauville adds16:10,21:9,32:9 and all three portrait source compositions,
completing the first interior variation across nine aspect families. All six
new paintings were inspected as single enclosed scenes with plain concrete
floor, no characters and no baked mounds.32:9 preserves its1983x793 original
and exact prompt, then trims excess lower canvas to1983x558 without resampling;
the crop provenance and transformed draft geometry are recorded explicitly.
Other new images fit their aspect tolerance without trimming. Exact built-in
prompts accompany all sources. Mound pairing and native alignment remain
pending; no layout tests or published pack/runtime eligibility changes.

Cave of Origin dry-cave authoring now has its first original interior source
variation in all nine aspect families. Existing original Gen1 deep-cave art
was inspected; its prominent blue-violet crystal identity was kept intact
rather than relabeled as this muted gray/brown cavern. Nine new paintings
retain exact built-in generation prompts and draft geometry.32:9 preserves
its2170x725 original and trims[0,100,2170,710];9:19.5 trims836x1880 to836x1811;
9:20 trims826x1904 to826x1836. All are crop-only with originals and provenance
preserved. Sources were visually inspected for single scenes, clear dry
floor and absence of characters/baked mounds. Candidate mound materials are
cave/cave-pale-limestone; fit and native positioning remain untested. This
dry-cave set does not certify legendary water/lava encounter staging. No
layout tests, runtime enablement or published asset pack changes occurred.

Hoenn Safari woodland source coverage reuses the project's original Gen1
safari_woodland variation01 after visual inspection of all eighteen day/night
sources. Broadleaf preserve woodland, distant low fencing, grassy margins and
open grass/earth ground fit the woodland encounter category; water contexts
remain separate. No new image generation or recoloring was used. Twelve
selected files are byte-identical copies, while32:9,9:19.5 and9:20 pairs use
approved crop-only preparation with untouched Gen1 originals, exact prompts,
SHA provenance and transformed draft geometry. Some lower scenery boundaries
are explicitly flagged for later native alignment/recomposition review.
All nine aspect pairs now have source records; grass/forest mounds are only
candidates. No layout tests, runtime enablement or published asset changes.

Rustboro Gym source coverage reuses the project's original Gen1 gym_rock
variation01 after inspecting all nine compositions. Rock-lined training hall
and plain packed-earth floor provide the chosen rock-gym art direction;
separate Hoenn source records preserve their origin rather than claiming new
paintings. Six files are byte-identical copies;32:9 trims2079x756 to2079x585,
9:19.5 center-trims900x1748 to807x1748, and9:20 trims793x1983 to793x1762.
All processing is crop-only, with untouched Gen1 originals, exact prompts,
SHA provenance and draft geometry retained. This is one indoor source set,
not native gym-layout validation. Sandstone/gravel mounds remain candidates.
No image generation, layout tests, runtime enablement or release changes.

Mauville Gym source coverage reuses original Gen1 gym_electric variation01
after visual inspection of all nine compositions. Cream/yellow generators,
wall conduits and seamless warm-gray training floor provide the electric gym
direction. Six sources are byte-identical copies;32:9 trims2115x743 using
[0,80,2115,675],9:19.5 center-trims875x1798 to830x1798, and9:20 trims793x1983
to793x1762. All trimming is crop-only with untouched originals, exact prompts,
SHA provenance and draft geometry preserved. This indoor source set retains
the original daylight windows; it is not a claim of native gym alignment.
Floor-gray/floor-beige mound candidates remain unpaired. No new image
generation, layout tests, runtime enablement or published pack changes.

Lavaridge Gym begins with original16:9,4:3 and3:2 interior source paintings.
Existing Gen1 fire-gym art was inspected but its large lava alcove was kept
for other uses rather than relabeled as Lavaridge. The new direction uses
warm plaster/timber walls, mineral-stained stone, distant steam vents and a
plain ochre-clay floor with no lava, floor holes, tiles or boards. All three
sources were visually inspected and retain exact built-in prompts and draft
geometry. Six aspect paintings and mound pairing remain; terracotta/floor-clay
are candidates only. No layout tests, runtime eligibility or release changes.

Dewford Gym begins with six dedicated original landscape source paintings:
16:9,4:3,3:2,16:10,21:9 and32:9. The existing original Gen1 dojo was inspected
but its bright cream/daylit setting did not fit this dimmer hall direction.
New paintings use dark timber/plaster architecture, small warm lamps and a
plain blue-gray carpet floor without tiles, boards or mat seams. Each source
was visually inspected and retains its exact built-in generation prompt and
draft geometry.32:9 preserves its1983x793 original and trims excess lower
canvas to1983x558 without resampling. Three portrait paintings and mound
pairing remain; carpet-blue/floor-gray are candidates only. No layout tests,
runtime enablement or published asset changes occurred.

Dewford Gym adds dedicated9:16,9:19.5 and9:20 portrait paintings, completing
the first interior source variation across all nine aspect families. All
three were visually inspected for clear carpet floors, single scenes and no
characters or baked mounds. Generated dimensions fit the aspect tolerance
without trimming or resampling. Exact built-in prompts and draft geometry
are saved beside each PNG. Mound pairing/native calibration remain pending;
no layout tests, runtime eligibility or published asset pack changes.

Phoebe's chamber adds original 9:16, 9:19.5 and 9:20 phone compositions,
completing its first source variation across all nine aspect families.
Each was visually inspected for clear dusky-violet carpet and distant
enclosed hall/urn niches, with no creatures, baked mounds or split scenes.
Generated dimensions fit their aspect tolerance without crop/resampling.
Exact built-in prompts and draft geometry accompany each PNG. Matching
mound review and native calibration remain pending. No layout tests,
runtime enablement, battle UI or release changes occurred.

Phoebe's chamber adds original 16:10, 21:9 and 32:9 source paintings,
bringing its first variation to six landscape formats. Each was visually
reviewed for clear dusky-violet carpet, enclosed hall and recessed urns,
with no creatures or baked mounds. The 1983x793 super-ultrawide original
is preserved; an authorized crop trims excess lower carpet to 1983x558
without resampling and transforms draft geometry. Exact built-in prompts
and crop provenance remain with the sources. Three phone formats and
mound pairing/native calibration remain. No layout tests, runtime
enablement, battle UI or release changes occurred.

Phoebe's chamber begins with original 16:9, 4:3 and 3:2 source paintings.
Existing Gen1 ghost-chamber art was inspected but its bright mountain-window
setting was preserved for its original uses. New enclosed violet halls
use warm lamps, a rear door, small recessed ceramic urns and clear dusky
carpet. All three were visually inspected with no creatures, baked mounds,
floor grids or split scenes. Exact built-in prompts and draft geometry
accompany each PNG. Six aspect paintings and mound pairing remain;
carpet-lavender/floor-charcoal are candidates only. No native layout tests,
runtime enablement, battle UI or release changes occurred.

Sidney's chamber adds original 9:16, 9:19.5 and 9:20 phone compositions,
completing its first source variation across all nine aspect families.
Each was visually inspected for clear burgundy carpet, charcoal walls,
bronze door trim and amber lamps, with no creatures or baked mounds.
Generated dimensions fit their aspect tolerance without crop/resampling.
Exact built-in prompts and draft geometry accompany each PNG. Matching
mound review and native calibration remain pending. No layout tests,
runtime enablement, battle UI or release changes occurred.

Sidney's chamber adds original 16:10, 21:9 and 32:9 source paintings,
bringing the first variation to six landscape formats. Each was visually
reviewed for clear burgundy carpet, charcoal walls/bronze door trim and
warm lamps, with no creatures, built-in mounds or floor grids. The 32:9
original is retained at 1983x793; an authorized crop trims excess lower
carpet to 1983x558 without resampling and transforms draft geometry.
Exact built-in prompts and crop provenance are preserved. Three phone
formats and mound pairing/native calibration remain. No layout tests,
runtime enablement, battle UI or release changes occurred.

Sidney's chamber begins with original 16:9, 4:3 and 3:2 source paintings.
Karen's existing blue/indigo chamber was inspected and preserved for Johto;
Sidney's direction uses charcoal walls, burgundy carpet/hangings, bronze
door trim and small amber lamps. Each source was visually inspected for
clear same-level carpet, no creatures or baked mounds, and no floor grid.
Exact built-in generation prompts and draft geometry accompany each PNG.
Six aspect paintings and mound pairing remain; carpet-burgundy and
floor-charcoal are candidates only. Native layout tests, runtime eligibility,
battle UI and release packages are unchanged.

Sootopolis Gym adds original 9:16, 9:19.5 and 9:20 portrait compositions,
completing its first source variation across all nine aspect families.
Each was visually inspected for continuous pale frosted floor, distant
blue/white hall and wave relief, with no creatures or baked mounds. All
three generated originals fit their aspect tolerance without crop or
resampling. Exact built-in prompts and draft geometry accompany each PNG.
Matching mound review and native calibration remain pending; source
coverage does not prove runtime placement. No layout tests, runtime
enablement, battle UI or release changes occurred.

Sootopolis Gym adds dedicated 16:10, 21:9 and 32:9 interior source paintings,
bringing the initial variation to six landscape formats. Each was visually
reviewed for a continuous pale frosted floor, distant blue/white hall and
wave relief, no creatures or baked mounds. The 2106x747 super-ultrawide
original is preserved; authorized crop-only preparation trims excess lower
canvas to 2106x592 without resampling and transforms the draft geometry.
Exact built-in prompts and crop provenance are retained. Three phone
compositions and mound pairing/native calibration remain. No layout tests,
runtime enablement, battle UI or release changes occurred.

Sootopolis Gym begins with original 16:9, 4:3 and 3:2 interior sources.
The existing Gen1 water-gym pool painting was inspected but preserved for
pool environments rather than relabeled. New enclosed blue/white halls
use an abstract wave relief and continuous pale frosted-ice training floor,
with no tile grid, floor holes or baked battler platforms. Each source was
visually inspected and retains its exact built-in prompt and draft geometry.
Six aspect paintings and matching mound review remain; ice-cave/floor-gray
are candidates only, not approved pairings. Native calibration, battle UI,
runtime eligibility and release packages are unchanged; no layout tests ran.

Mossdeep Gym adds original 9:16, 9:19.5 and 9:20 portrait compositions,
completing the first interior source variation across all nine aspects.
Each was visually inspected: clear lavender carpet, enclosed celestial
wall details, no creatures, baked mounds or split scenes. Dimensions fit
the aspect tolerance directly without cropping or resampling. Exact
built-in prompts and draft geometry remain beside each PNG. Native layout
and mound pairing/calibration remain pending. No layout tests, runtime
enablement, battle UI or release changes occurred.

Mossdeep Gym adds dedicated 16:10, 21:9 and 32:9 interior source paintings,
bringing the initial variation to six landscape aspects. All were visually
reviewed for clear lavender carpet, enclosed celestial hall architecture,
and absence of creatures or baked mounds. The 1983x793 super-ultrawide
original is preserved; authorized crop-only preparation trims excess lower
carpet to 1983x558, without resampling, and transforms draft geometry.
Exact built-in prompts and crop provenance are retained. Three phone
compositions and mound pairing/native calibration remain. No layout
tests, runtime enablement, battle UI or release changes occurred.

Mossdeep Gym begins with original 16:9, 4:3 and 3:2 interior paintings.
The existing Gen1 psychic-gym set was visually reviewed across all nine
aspects but its mountain-window scenery was preserved for its original
uses rather than relabeled as Mossdeep. New enclosed halls have ivory
plaster, lavender columns, sun/crescent wall reliefs and uninterrupted
lavender carpet. All three sources were visually inspected with no
creatures, baked mounds, floor grids or split scenes. Exact built-in
prompts and draft geometry accompany each PNG. Six aspect paintings and
mound pairing remain; carpet-lavender/floor-beige are candidates only.
No native layout tests, runtime enablement, battle UI or release changes.

Fortree Gym adds dedicated 9:16, 9:19.5 and 9:20 original portrait sources,
completing its first interior source variation across all nine aspects.
All three were visually inspected for clear moss carpet, distant canopy
windows and absence of creatures, baked mounds or split scenes. Their
generated dimensions fit the aspect tolerance without cropping/resampling.
Exact built-in prompts and draft geometry are retained beside each image.
Mound pairing and native calibration remain pending; no layout tests,
runtime eligibility, battle UI or release changes occurred.

Fortree Gym adds dedicated 16:10, 21:9 and 32:9 source paintings, bringing
the initial variation to six landscape aspects. Each was visually reviewed
for uninterrupted moss carpet, canopy views and no creatures or baked mounds.
The 32:9 generated original is retained at 1983x793; the authorized crop
removes excess lower floor to 1983x558 without resampling. Source geometry,
transformed draft anchors and exact generation prompts are preserved.
The actual post-crop floor boundary is near 38% height, so native contact
still needs review; source coverage does not establish placement quality.
Three phone compositions and mound pairing/calibration remain. No layout
testing, runtime enablement or release changes occurred.

Fortree Gym begins with original 16:9, 4:3 and 3:2 interior source paintings.
The existing Violet Gym source was inspected but its mountain-window view
was retained for Johto rather than relabeled as a tropical canopy hall.
New paintings use timber/plaster walls, broad rear windows overlooking
treetops and uninterrupted moss-green carpet. All three were visually
inspected: no creatures, built-in mounds, platforms, tiled or wooden floors,
or split scenes. Exact built-in generation prompts and draft geometry are
saved with each source. Carpet-moss/floor-beige are mound candidates only.
Six aspect paintings and mound pairing/native calibration remain. No layout
tests, runtime eligibility or release changes occurred.

Petalburg Gym now has a complete nine-aspect initial interior source set,
reusing the original Gen1 dojo-01 paintings after visual review of every
aspect. Cream plaster/timber walls, red banners and the seamless beige
training floor fit this normal-type training hall. Eight files are copied
byte-for-byte; 32:9 trims excess lower floor from its 2048x768 source to
2048x576 without resampling. The Gen1 originals are preserved. Each record
includes original path, exact prompt, SHA-256 and reuse reason; the crop
also retains source geometry and transformed draft anchors. Floor-beige
and floor-clay are candidates only. Native layout/mound calibration remain
pending, with no runtime enablement, layout testing or release changes.

Lavaridge Gym now has its first interior source variation across all nine
aspect families. Six new built-in paintings add 16:10, 21:9, 32:9 and the
three phone formats to the initial set. Visual inspection found single warm
geothermal halls with plain ochre-clay floors, distant steam vents and no
characters, baked mounds, tile grids or hardwood flooring. The 32:9 source
is preserved at 1983x793; an authorized crop trims excess lower canvas to
1983x558 without resampling, with transformed draft geometry and provenance.
All other new originals fit their aspect tolerance directly. Exact prompts
are saved beside sources. Terracotta/floor-clay remain mound candidates;
native calibration and mound pairing are pending. No layout testing,
runtime enablement, release or published asset-pack changes occurred.

Glacia's chamber begins with original 16:9, 4:3 and 3:2 interior source
paintings. The existing Gen1 ice chamber's mountain windows were retained
rather than relabeled. New enclosed pale-blue halls use white columns,
closed silver doors, small ice clusters confined to rear niches and clear
matte blue-gray floors. Each was visually inspected as one continuous scene
without characters, baked mounds or floor grids. Built-in generation prompts
and draft geometry are saved beside sources. Ice-cave/floor-gray are mound
candidates only. Six aspect paintings and native mound calibration remain;
no layout tests, runtime eligibility or published asset pack changes.

Glacia's wide source set now also includes 16:10, 21:9 and 32:9 paintings.
The super-ultrawide original is preserved at 2175x723; an authorized
crop removes excess lower floor to 2175x612 without resampling. Its draft
horizon and anchors are transformed with crop provenance. Visual review
found clear single-scene ice halls with rear niches and uninterrupted floors.
The three portrait paintings remain, along with mound pairing and native
calibration. No layout testing, runtime enablement or release changes.

Glacia's first interior source variation now covers all nine aspect families.
The three new portrait paintings were visually reviewed: enclosed pale-blue
halls, clear flat floors, no creatures, baked mounds, grids or split scenes.
Each fits its aspect tolerance directly without resampling. Exact built-in
prompts and draft geometry accompany every source. Ice-cave/floor-gray remain
candidates pending mound pairing and native calibration. No layout testing,
runtime enablement, release or published asset-pack changes occurred.

Drake's chamber begins with original 16:9, 4:3 and 3:2 interior source
paintings. All three existing Gen1 dragon-hall variations were visually
inspected; their mountain views and dragon ornaments are preserved rather
than relabeled. New enclosed halls use blue-gray stone walls, sandstone
columns, bronze doors, amber lamps and uninterrupted crimson carpet.
Each was visually inspected without creatures, baked mounds, floor grids
or split scenes. Built-in generation prompts and draft geometry are saved
beside sources. Carpet-burgundy/floor-charcoal are candidates only; matching
mound colors and native calibration remain pending. Six aspect paintings
remain. No layout testing, runtime enablement or release changes occurred.

Drake's wide source set now includes 16:10, 21:9 and 32:9 paintings.
Visual review found single enclosed halls with clear carpet floors and no
creatures or baked mounds. The 32:9 original is preserved at 2048x768;
an authorized crop trims only excess lower floor to 2048x576 without
resampling, with transformed draft geometry and provenance. Three portrait
paintings and native mound calibration remain. No layout testing, runtime
enablement, release or published asset-pack changes occurred.

Drake's first interior source variation now covers all nine aspect families.
The three new portrait paintings were visually inspected as single enclosed
halls with clear crimson carpet and no creatures, baked mounds, floor grids
or split scenes. All three fit their aspect tolerance directly without
resampling. Exact built-in generation prompts and draft geometry are saved
beside sources. Carpet-burgundy/floor-charcoal remain candidates; mound color
matching and native calibration are still pending. No layout testing,
runtime enablement, release or published asset-pack changes occurred.

The Hoenn Champion's first interior source variation now covers all nine
aspect families using visually reviewed original Gen1 champion-03 artwork.
The enclosed cream trophy hall, red columns, blue banners and seamless
burgundy carpet provide a shared Champion setting. Seven images are copied
byte-for-byte. Authorized crops trim excess lower carpet from 32:9
(2115x743 to 2115x595) and 9:20 (793x1983 to 793x1762) without resampling;
originals remain untouched. All nine were visually inspected, and both
crops reviewed again, without creatures, baked mounds or split scenes.
Exact original prompts, SHA-256 provenance and draft geometry are saved.
The 32:9 floor boundary is close to the opponent draft anchor and explicitly
flagged for contact review or recomposition during deferred calibration.
Carpet-burgundy/floor-ivory are mound candidates only. No layout testing,
runtime enablement, release or published asset-pack changes occurred.

Hoenn Battle Tower now has a complete nine-aspect initial interior source
set, reusing original Gen2 Battle Tower paintings after visual review of
every aspect. Pale blue-gray walls, closed sliding doors, high windows and
clear seamless floors suit a shared training room. All nine are copied
byte-for-byte, with original paths, prompts, hashes and authoring metadata
references preserved. No new generation, image resizing or crops were
needed. Floor-gray/floor-gray-night-cool are mound candidates only; their
color matching and native contact calibration remain pending. No layout
testing, runtime enablement, release or published asset-pack changes.

The Hoenn Battle Tower authoring family was corrected from battle_tower to
hoenn_battle_tower to match the existing Hoenn map classification table.
All nine image/prompt/metadata paths and reuse targets now use that family;
original Gen2 provenance is unchanged. This is a source naming correction,
not runtime enablement or layout validation.

Battle Dome begins with original 16:9, 4:3 and 3:2 tournament-hall source
paintings. Existing Gen1 arena art was inspected; the formal link room's
small scale was retained rather than relabeled as the Dome. New paintings
use curved empty red/blue seating, cream guards, roof ribs, blank rear
screens and clear sage-gray sports floors. Each was visually inspected
without creatures, baked mounds, floor grids or split scenes. Exact built-in
prompts and draft geometry are saved beside sources. Floor-sage/floor-gray
remain mound candidates, with six aspect paintings and native calibration
pending. No layout testing, runtime enablement or release changes occurred.

Battle Dome's wide source set now includes 16:10, 21:9 and 32:9 paintings.
All were visually inspected as single enclosed tournament halls with clear
sage-gray floors, empty red/blue seating, no creatures or baked mounds.
The 32:9 original is preserved at 2181x721; an authorized crop removes only
excess lower floor to 2181x613 without resampling, with transformed draft
geometry and provenance. The crop was visually reviewed again. Three
portrait paintings remain, along with mound pairing and native calibration.
No layout testing, runtime enablement, release or asset-pack changes.

Battle Factory now has all nine first-variation source compositions, including
three separately painted portrait rooms. Each portrait was visually reviewed
as one uniformly lit indoor scene, with rear equipment, clear concrete floor,
no creatures and no baked mounds. Exact built-in generation prompts and draft
geometry accompany every painting. No portrait trimming or resampling was
needed. Mound pairing and native calibration remain pending; no layout tests,
runtime enablement, release or published asset-pack changes were performed.

Battle Dome's first source variation now covers all nine aspect families.
The three new portrait paintings were visually inspected: clear sage-gray
floors, rear empty red/blue seating, no creatures, baked mounds, floor grids
or split scenes. Each fits its aspect tolerance directly without resampling.
Exact built-in prompts and draft geometry accompany each source. Floor-sage
and floor-gray remain candidates pending mound pairing and native calibration.
No layout testing, runtime enablement, release or asset-pack changes.

Battle Palace begins with original 16:9, 4:3 and 3:2 interior source paintings.
Existing dojo-02/03 and Tin Tower art was visually inspected but retained
for its courtyard, locker-room or autumn-tower settings. New palace halls
use carved timber, ivory plaster, jade upper panels, rear palm planters and
clear ivory-gray stone floors. Each was visually inspected without creatures,
baked mounds, floor grids or split scenes. Built-in generation prompts and
draft geometry accompany every source. Floor-ivory/floor-beige are candidates
only. Six aspect paintings, mound pairing and native calibration remain.
No layout testing, runtime enablement, release or asset-pack changes.

Battle Palace's wide source set now includes 16:10, 21:9 and 32:9 paintings.
All were visually inspected as single tropical palace halls with rear palms,
carved pillars, clear ivory-gray floors, no creatures or baked mounds.
The 32:9 original is preserved at 2079x756; an authorized crop removes only
excess lower floor to 2079x585 without resampling. Crop provenance and
transformed draft geometry are saved, and the crop was visually reviewed.
Three portrait paintings remain, along with mound pairing and native
calibration. No layout testing, runtime enablement, release or pack changes.

Battle Palace's first interior source variation now covers all nine aspect
families. Three new portrait paintings were visually inspected: rear palms,
carved timber, ivory floors, no creatures, baked mounds, grids or split scenes.
All three fit their aspect tolerance directly without resampling. Exact
built-in generation prompts and draft geometry accompany every source.
Floor-ivory/floor-beige remain candidates pending mound pairing and native
calibration. No layout testing, runtime enablement, release or pack changes.

Battle Arena's first interior source variation now covers all nine aspect
families, reusing the original Gen1 dojo-01 paintings after visual review
of every aspect. Cream plaster, timber walls, red banners and uninterrupted
beige carpet provide a shared martial-arts setting. Eight images are copied
byte-for-byte. The 32:9 source trims only excess lower floor from 2048x768
to 2048x576 without resampling; the Gen1 original stays untouched. The crop
was visually reviewed again. Original prompts, hashes, reuse reasons and
transformed draft crop geometry are saved. Floor-beige/floor-clay remain
candidates pending mound pairing and native calibration. No layout testing,
runtime enablement, release or published asset-pack changes occurred.

Battle Factory begins with original 16:9, 4:3 and 3:2 interior source paintings.
Existing Gen1 laboratories/power-plant-03 and Gen2 warehouse artwork was
visually inspected but retained for research, power-station or cargo settings.
New clean technical battle rooms use steel walls, rear consoles, blank teal
screens, overhead pipes and uninterrupted gray concrete floors. All three
were visually inspected without creatures, baked mounds, floor grids or
split scenes. Exact built-in prompts and draft geometry accompany sources.
Floor-gray/floor-gray-night-cool remain candidates pending mound color
matching and native calibration. Six aspect paintings remain. No layout
testing, runtime enablement, release or asset-pack changes occurred.

Battle Factory's wide source set now includes 16:10, 21:9 and 32:9 paintings.
All were visually inspected as single technical rooms with rear consoles,
steel walls, clear concrete floors, no creatures or baked mounds. The 32:9
original is preserved at 2048x768; an authorized crop trims only excess
lower floor to 2048x576 without resampling. The crop was visually reviewed
again; provenance and transformed draft geometry are saved. Three portrait
paintings remain, with mound color matching and native calibration pending.
No layout testing, runtime enablement, release or asset-pack changes.

Battle Pike begins with original 16:9, 4:3 and 3:2 source paintings. The
existing Gen1 poison gym timber dojo was visually inspected but not reused
for this curtained challenge room. Emerald's Battle Pike secondary tiles
were consulted for architectural context only; no game pixels were copied
into the artwork. Cream walls, sage curtains, three closed rear doors and
plain sage-gray carpet keep the fighting floor unobstructed. Each built-in
generation was visually reviewed as a single indoor scene without creatures,
UI or baked mounds. Exact prompts and draft geometry accompany the sources.
Carpet-moss/floor-sage are candidates pending pairing and native calibration.
Six aspects remain. No layout tests, runtime enablement, release or published
asset-pack changes were performed.

Battle Pike's wide source set adds 16:10, 21:9 and 32:9 paintings. Each was
visually reviewed as a single enclosed curtained room with clear carpet,
no creatures and no baked mounds. The 32:9 original is preserved at
2172x724; an authorized crop removes only excess lower floor to 2172x611
without resampling. The crop was visually reviewed again, and provenance
and transformed draft geometry are saved. Three portrait paintings remain.
Mound pairing and native calibration remain pending. No layout tests,
runtime enablement, release or published asset-pack changes occurred.

Battle Pike now has all nine first-variation source compositions. Three
portrait paintings were individually generated and visually reviewed as
single uniformly lit curtained interiors with clear carpet and no creatures
or baked mounds. The 9:19.5 original is preserved at 834x1886; authorized
crop-only preparation trims excess lower floor to 834x1807, without
resampling. The final crop was visually reviewed, with provenance and
transformed draft geometry saved. All exact built-in prompts accompany the
art. Mound matching and native calibration remain pending. No layout tests,
runtime enablement, release or published asset-pack changes occurred.

Battle Pyramid begins with original 16:9, 4:3 and 3:2 source paintings.
Gen2 Ruins of Alph's 16:9 source was visually inspected and retained for
its weathered archaeological setting. New darker gray-brown maze chambers
use square stone piers, rear passages, amber lamps and uninterrupted dusty
stone floors. Each built-in generation was visually reviewed without
creatures, baked mounds or split scenes. Exact prompts and draft geometry
accompany every source. Cave/floor-gray remain candidates pending mound
matching and native calibration. Six aspect compositions remain. No layout
tests, runtime enablement, release or published asset-pack changes occurred.

Battle Pyramid's wide source set adds 16:10, 21:9 and 32:9 paintings.
Each was visually reviewed as one enclosed stone chamber with a clear floor,
no creatures and no baked mounds. The 32:9 original remains at 2115x743;
authorized crop-only preparation trims excess upper wall and lower floor
using rectangle [0,80,2115,675], producing 2115x595 without resampling.
The final crop was visually reviewed; source provenance and transformed
draft geometry are saved. Three portrait compositions remain. Mound pairing
and native calibration remain pending. No layout tests, runtime enablement,
release or published asset-pack changes occurred.

Battle Pyramid now has all nine first-variation source compositions. Each
portrait painting was generated separately and visually reviewed as one
stone chamber with a clear floor, no creatures and no baked mounds. The
9:19.5 original is preserved at 835x1883; authorized crop-only preparation
trims excess lower floor to 835x1809 without resampling. The crop was
visually reviewed again; provenance, exact built-in prompts and transformed
draft geometry are saved. Mound matching and native calibration remain
pending. No layout tests, runtime enablement, release or published asset-pack
changes occurred.

Frontier gardens begin with separate original 16:9 day and night paintings.
Gen1 grass-gym-02's garden was visually inspected but retained for its
walled pergola courtyard. New open landscaped gardens use clipped hedges,
flowerbeds, palms and distant cream pavilions behind clear short lawn.
The two images were independently generated with the built-in image tool,
not simulated with a lighting tint or combined into a split image. Both were
visually reviewed without creatures, UI or baked mounds. Exact prompts and
draft geometry accompany the sources. Grass/forest are provisional material
candidates; day/night mound color matching and native calibration are pending.
Eight aspect pairs remain. No layout tests, runtime enablement, release or
published asset-pack changes occurred.

Frontier gardens now include independently painted day/night pairs at
4:3 and 3:2, alongside 16:9. Each of the four additions was visually
reviewed as a single landscaped garden with a broad clear lawn, no
creatures, UI or baked mounds. No cropping or resampling was required.
Exact built-in prompts and draft geometry accompany every source. Six
aspect pairs remain. Day/night mound matching and native calibration
remain pending. No layout tests, runtime enablement, release or published
asset-pack changes occurred.

Frontier gardens add independently painted 16:10 and 21:9 day/night source
pairs. Each was visually reviewed as one garden with clear lawn, no creatures,
UI or baked mounds. No cropping or resampling was required. Exact built-in
prompts and draft geometry accompany all four. The 21:9 night boundary at
about .40 crowds the opponent draft ground at .43: its authoring limitations
explicitly require recomposition before runtime integration, without moving
the battle UI. Four aspect pairs remain unpainted. All mound matching and
native calibration remain pending. No layout tests, runtime enablement,
release or published asset-pack changes occurred.

Frontier gardens' 21:9 night source has been recomposed with the rear lawn
boundary around .26, replacing the crowded .40 source. The previous image,
prompt and authoring record are preserved under drafts/21x9 and marked
rejected_low_boundary_preserved_original. The replacement was visually
reviewed; this resolves the specific source composition concern, not native
calibration. Separate original 32:9 day/night paintings are also saved.
Both 2172x724 originals are preserved; authorized crop-only preparation
trims excess lower lawn to 2172x611 without resampling. Both final crops
were visually reviewed. Exact built-in prompts, provenance and transformed
draft geometry accompany them. Three portrait pairs remain. Day/night mound
matching and native calibration are pending. No layout tests, runtime
enablement, release or published asset-pack changes occurred.

Frontier gardens add separate original 9:16 and 9:19.5 day/night paintings.
All four were individually generated with the built-in image tool and
visually reviewed as single scenes with unobstructed lawn, no creatures,
UI or baked mounds. The 9:19.5 day/night originals remain at 835x1884 and
835x1883 respectively; authorized crop-only preparation trims only excess
lower lawn to 835x1809, without resampling. Both final crops were visually
reviewed. Exact prompts, provenance and transformed draft geometry are saved.
Only the 9:20 day/night pair remains unpainted for this family. Mound matching
and native calibration remain pending. No layout tests, runtime enablement,
release or published asset-pack changes occurred.

Frontier gardens now have all nine first-variation day/night source pairs.
The last 9:20 day and night paintings were independently generated with the
built-in image tool, visually reviewed as single garden scenes without
creatures, UI or baked mounds, and imported without cropping or resampling.
Exact prompts and draft geometry accompany both. Source coverage is not
runtime readiness: day/night mound color matching, native calibration and
compatibility validation remain pending. No layout tests, runtime enablement,
release or published asset-pack changes occurred.

Artisan Cave begins with original 16:9, 4:3 and 3:2 source paintings.
Gen1 deep-cave-01 and cave-02 were visually inspected but retained for
their stream/crystals and bright sandstone entrance respectively. New dry,
enclosed brown stone chambers use restrained diffuse underground light and
uninterrupted dusty floors. All three built-in generations were visually
reviewed without creatures, exterior views, water, UI or baked mounds.
Exact prompts and draft geometry accompany each source. Cave/sandstone
remain provisional candidates pending mound matching and native calibration.
Six aspect compositions remain. No layout tests, runtime enablement,
release or published asset-pack changes occurred.

Artisan Cave's wide set adds 16:10, 21:9 and 32:9 source paintings.
Each was visually reviewed as a dry enclosed chamber with clear floor,
no creatures, exterior views, UI or baked mounds. The 32:9 original remains
at 2172x724; authorized crop-only preparation trims excess lower floor to
2172x611 without resampling. The final crop was visually reviewed again;
provenance, exact built-in prompts and transformed draft geometry are saved.
Three portrait compositions remain. Mound matching and native calibration
remain pending. No layout tests, runtime enablement, release or published
asset-pack changes occurred.

Artisan Cave now has all nine first-variation source compositions. Three
portrait paintings were independently generated with the built-in image
tool and visually reviewed as dry enclosed caves without creatures, water,
UI or baked mounds. The 9:19.5 original remains at 834x1886; authorized
crop-only preparation trims excess lower floor to 834x1807 without
resampling. The final crop was visually reviewed again. Exact prompts,
provenance and transformed draft geometry are saved. Mound matching and
native calibration remain pending. No layout tests, runtime enablement,
release or published asset-pack changes occurred.

Seafloor Cavern's first land-battle source set reuses original Gen1 cave-03
across all nine aspects after individual visual review. Pale limestone,
rear underground water and dry standing floor fit a shared coastal cave
setting. Gen1 cave-water-02 was also inspected, but its full water surface
is unsuitable for this land family; water encounters retain their separate
water-surface family. Seven images are byte-identical copies. The 32:9
source is cropped from 2121x741 using [0,50,2121,647] to 2121x597; the
9:19.5 source trims excess side canvas from 898x1751 using [45,0,853,1751]
to 808x1751. Both authorized crops preserve originals and avoid resampling;
both were visually reviewed after preparation. Original prompts, source
hashes, reuse rationale and transformed draft crop geometry are saved.
Limestone/cave-pale-limestone are provisional mound candidates. Native
map-specific suitability, mound matching and calibration remain pending.
No layout tests, runtime enablement, release or published asset-pack changes.

Shoal Cave's non-ice land chamber begins with original 16:9, 4:3 and 3:2
source paintings generated with the built-in image tool. All three were
visually reviewed as single enclosed coastal limestone scenes with rear
water and dry standing floor, no creatures, exterior views, UI or baked
mounds. Exact prompts and draft geometry accompany the images. The rear
water/dry-floor boundary is lower than requested (roughly .39-.41); enemy
mound footprint clearance needs explicit review during later calibration,
and recomposition remains possible. Limestone/cave-pale-limestone are
provisional candidates. Six aspect compositions remain. No layout tests,
runtime enablement, release or published asset-pack changes occurred.

Shoal Cave now has all nine first-variation land source compositions. Six
additional paintings (16:10, 21:9, 32:9 and three portraits) were generated
individually with the built-in image tool and visually reviewed. They show
single enclosed coastal limestone scenes with rear water and continuous
dry floor, without creatures, UI or baked mounds. The new compositions
place the water farther back than the initial three. Exact prompts and
draft geometry accompany every source. The 32:9 original is preserved at
2179x722; crop-only preparation trims excess lower floor to 2179x613 without
resampling. Its final crop was visually reviewed, with provenance and
transformed draft anchors recorded. The 9:19.5 painting remains at its
original 853x1844 dimensions (within the source import ratio tolerance).
The initial three paintings still require enemy mound footprint clearance
review; all mound pairing and native calibration remain pending. No layout
tests, runtime enablement, release or published asset-pack changes occurred.

Desert Underpass begins with original 16:9, 4:3 and 3:2 source paintings.
Gen1 cave-02 and deep-cave-02/03 were visually inspected first; their bright
entrance, crystals or water were unsuitable for this dry enclosed tunnel.
The three new built-in generations were individually visually reviewed as
layered brown rock passages with continuous sandy standing floor, without
creatures, exterior views, UI or baked mounds. Exact prompts and draft
geometry accompany each image. Sandstone/mineral-sand are provisional mound
candidates pending color matching and native calibration. Six aspect
compositions remain. No layout tests, runtime enablement, release or
published asset-pack changes occurred.

Desert Underpass now has all nine first-variation source compositions. Six
additional built-in paintings cover 16:10, 21:9, 32:9 and three portraits.
Each was visually reviewed as a single dry enclosed sedimentary tunnel
with continuous standing floor and no creatures, exterior views, UI or
baked mounds. Exact prompts and draft geometry accompany the sources.
The 32:9 original is preserved at 2048x768; authorized crop-only preparation
uses [0,60,2048,636] to produce 2048x576 without resampling. The final crop
was visually reviewed; provenance and transformed draft anchors are saved.
The 9:19.5 original remains at 851x1847, within source-import tolerance.
Sandstone/mineral-sand remain provisional mound candidates. Color matching,
mound footprints and native calibration remain pending. No layout tests,
runtime enablement, release or published asset-pack changes occurred.

Mirage Tower (desert_ruin family, distinct from Regirock's Desert Ruins)
begins with original 16:9, 4:3 and 3:2 source paintings. Gen2 Ruins of Alph
was visually inspected first but retained for its location-specific wall
symbols. The new built-in paintings were individually visually reviewed
as plain crumbling sandstone interiors with continuous sand-covered floor,
without creatures, wall symbols, UI, floor grids or baked mounds. Exact
prompts and draft geometry accompany each source. Sandstone/mineral-sand
remain provisional mound candidates pending color matching and native
calibration. Six aspect compositions remain. No layout tests, runtime
enablement, release or published asset-pack changes occurred.

Mirage Tower's wide source set adds 16:10, 21:9 and 32:9 paintings, each
individually generated with the built-in image tool and visually reviewed.
All show plain weathered sandstone interiors with uninterrupted sand floor,
without creatures, wall symbols, UI, floor grids or baked mounds. Exact
prompts and draft geometry accompany each source. The 32:9 original is
preserved at 2172x724; authorized crop-only preparation uses
[0,50,2172,661] to produce 2172x611 without resampling. The final crop was
visually reviewed, with provenance and transformed draft anchors recorded.
Three portrait compositions remain. Mound color matching, footprints and
native calibration remain pending. No layout tests, runtime enablement,
release or published asset-pack changes occurred.

Mirage Tower now has all nine first-variation source compositions. Three
portrait paintings were generated individually with the built-in image
tool and visually reviewed as plain weathered sandstone interiors with
clear sandy ground around both draft anchors. They contain no creatures,
wall symbols, UI, floor grids or baked mounds. Exact prompts and draft
geometry accompany each source. The 9:19.5 original remains at 853x1844,
within source-import tolerance. Sandstone/mineral-sand remain provisional
mound candidates; color matching, mound footprints and native calibration
remain pending. No layout tests, runtime enablement, release or published
asset-pack changes occurred.

Sky Pillar's enclosed interior begins with original 16:9, 4:3 and 3:2 source
paintings. Native Emerald SkyPillar_1F map metadata identifies underground
map type and WEATHER_NONE. Its layouts.json entry uses General/Pacifidlog
tilesets; the secondary Pacifidlog tiles were inspected only as architectural
reference, with no native pixels copied into artwork:
https://raw.githubusercontent.com/pret/pokeemerald/master/data/maps/SkyPillar_1F/map.json
https://raw.githubusercontent.com/pret/pokeemerald/master/data/layouts/layouts.json
https://raw.githubusercontent.com/pret/pokeemerald/master/data/tilesets/secondary/pacifidlog/tiles.png
The three built-in generations were individually visually reviewed as gray
stone masonry interiors with uninterrupted irregular cracked floor, without
creatures, symbols, outside scenery, UI, regular floor grids or baked mounds.
Exact prompts and draft geometry accompany each image. Floor-gray/pale-gravel
remain provisional mound candidates pending color matching and native
calibration. Six aspect compositions remain. The outdoor summit is a distinct
family. No layout tests, runtime enablement, release or published asset-pack
changes occurred.

Sky Pillar's interior wide source set adds 16:10, 21:9 and 32:9 paintings.
Each built-in generation was individually visually reviewed as an enclosed
gray masonry room with continuous irregular cracked floor, without creatures,
symbols, exterior views, UI, regular floor grids or baked mounds. Exact
prompts and draft geometry accompany each source. The 32:9 original is
preserved at 2089x753; authorized crop-only preparation uses [0,30,2089,618]
to produce 2089x588 without resampling. The final crop was visually reviewed;
provenance and transformed draft anchors are saved. Three portrait
compositions remain. Mound color matching, footprints and native calibration
remain pending. No layout tests, runtime enablement, release or published
asset-pack changes occurred.

Sky Pillar's interior now has all nine first-variation source compositions.
Three portrait paintings were individually generated with the built-in
image tool and visually reviewed as enclosed gray masonry rooms with clear
irregular cracked floor around both draft anchors. No creatures, symbols,
exterior views, UI, regular floor grids or baked mounds were present. Exact
prompts and draft geometry accompany each source. The 9:19.5 painting remains
at its original 853x1844 dimensions, within source-import tolerance. Floor-gray
and pale-gravel remain provisional mound candidates. Color matching, mound
footprints and native calibration remain pending. The outdoor summit remains
a separate uncompleted family. No layout tests, runtime enablement, release
or published asset-pack changes occurred.

Terra Cave begins with 16:9, 4:3 and 3:2 source compositions. Original Gen1
legendary-moltres-03 at 16:9 was individually visually reviewed and reused
byte-identically for its dry charcoal-brown basalt shelter, warm-gray floor
and high reflected amber light. Variations 01/02 were inspected and retained
for their brighter ochre setting. Variation03 has no other existing aspect
paintings. New 4:3 and 3:2 paintings were generated individually with the
built-in image tool and visually reviewed to match the dry dark-rock setting.
No creatures, lava, water, UI, regular flooring grids or baked mounds were
present. Exact original/new prompts, reuse hash/provenance and draft geometry
are saved. Native Emerald layouts.json lists General/Cave tilesets for both
TerraCave_Entrance and TerraCave_End; map-specific visual suitability still
requires calibration. Cave-warm-basalt/cave are provisional mound candidates.
Six aspects remain. No layout tests, runtime enablement, release or published
asset-pack changes occurred.

Terra Cave's wide set adds 16:10, 21:9 and 32:9 source paintings. Built-in
generations were individually visually reviewed for dry charcoal-brown rock,
continuous muted gray floor and restrained amber rear light, without creatures,
lava, water, UI or baked mounds. The first 21:9 result placed the rear wall
near .40, leaving insufficient enemy footprint clearance; it is preserved as
art/gen3/drafts/21x9/terra_cave-01-21x9-low-boundary.png with its exact prompt.
The replacement's rear boundary is about .24 and is the canonical source.
The 32:9 original is preserved at 2048x768; authorized crop-only preparation
trims lower floor to 2048x576 without resampling. Its final crop was visually
reviewed, with provenance and transformed draft anchors saved. Exact prompts
and draft geometry accompany all three sources. Three portrait compositions
remain. Mound matching and native calibration remain pending. No layout tests,
runtime enablement, release or published asset-pack changes occurred.

Terra Cave now has all nine first-variation source compositions. Three
portrait paintings were individually generated with the built-in image tool
and visually reviewed as dry charcoal-brown basalt chambers with continuous
muted warm-gray floor around both draft anchors. No creatures, lava, water,
UI or baked mounds were present. Exact prompts and draft geometry accompany
each source. The 9:19.5 painting remains at its original 853x1844 dimensions,
within source-import tolerance. Cave-warm-basalt/cave remain provisional
mound candidates. Color matching, footprints, map-specific suitability and
native calibration remain pending. No layout tests, runtime enablement,
release or published asset-pack changes occurred.

Marine Cave's first source set reuses Gen1 cave-water-02 across all nine
aspects after individual visual review. Enclosed pale limestone arches sit
above continuous blue underground water; no creatures, UI or baked islands
were present. Eight paintings are byte-identical copies. The 32:9 original
remains unchanged in Gen1 at 2048x768; authorized crop-only preparation uses
[0,70,2048,646] to produce 2048x576 without resampling. The final crop was
visually reviewed, and provenance, source hashes, original prompts and
transformed draft geometry are saved. The phone originals remain at their
existing dimensions within source-import tolerance. Islet-rock/ripple are
provisional candidates. Native Emerald MarineCave_End metadata identifies
underground map type and horizontal fog; its Cave tileset and separate
Underwater_MarineCave layout were read from native source metadata:
https://raw.githubusercontent.com/pret/pokeemerald/master/data/maps/MarineCave_End/map.json
https://raw.githubusercontent.com/pret/pokeemerald/master/data/layouts/layouts.json
Underwater approaches remain distinct from these surface-water paintings.
Map-specific suitability, land-island versus water context, fog integration,
mound matching and calibration remain pending. No layout tests, runtime
enablement, release or published asset-pack changes occurred.

The authoring inventory now excludes preserved drafts from generated source
coverage. An archived Frontier Gardens rejection had previously appeared as
an erroneous family named 21x9; it remains preserved on disk but is no longer
listed as canonical source artwork. This change does not enable runtime art.

Ancient Tomb (regi_ancient_tomb) begins with original 16:9, 4:3 and 3:2
source paintings. Built-in generations were individually visually reviewed
as enclosed gray-brown stone chambers with a plain rear slab and continuous
dusty floor around draft standing anchors. No creatures, inscriptions,
statues, machinery, exterior views, UI, floor grids or baked mounds were
present. Exact prompts and draft geometry accompany each source. Cave and
floor-gray remain provisional mound candidates pending color matching,
map-specific suitability and native calibration. Six aspects remain. No
layout tests, runtime enablement, release or published asset-pack changes
occurred.

Birth Island has eighteen first-variation source candidates: nine day and
nine separately painted night compositions. All eighteen initial built-in
generations preceded visual review. Each has a broad flat short-grass
clearing, low distant coastal stones, ocean behind the clearing and clear
sky (moonlit/readable cool grass at night). No creatures, people, UI,
monuments, triangle puzzle object, baked mounds or split day/night scenes
were seen. Native Emerald BirthIsland_Exterior uses an INDOOR map flag
despite its exterior scene, no weather, 30x30 General/Dewford tilesets:
https://raw.githubusercontent.com/pret/pokeemerald/master/data/maps/BirthIsland_Exterior/map.json
https://raw.githubusercontent.com/pret/pokeemerald/master/data/layouts/layouts.json
Do not infer outdoor/indoor solely from that native flag; time selection
and map suitability remain pending runtime context review. The original
art is an empty battle-facing view, not a copy of the map or its puzzle.
Night 32:9 needed a targeted retry after the complete-set review because
the first shoreline/canvas combination would crowd the opponent or cut
the moon. Rejected original/prompt is preserved in drafts. All exact
prompts, hashes and draft geometry accompany accepted sources.
Sixteen paintings are unchanged. Day ultrawide original 2048x768 is
preserved with crop [0,60,2048,636] to 2048x576; accepted night original
2103x748 is preserved with bottom-only crop [0,0,2103,591] to 2103x591,
keeping its moon and distant coastline intact. Both final crops reviewed.
Observed grassy-ground boundaries (16:9/4:3/3:2/16:10/21:9/32:9 original/
9:16/9:19.5/9:20): day .28/.25/.27/.28/.28/.31/.22/.17/.16; night
.33/.29/.30/.31/.31/.22/.25/.23/.22. Crops transform draft anchors and
boundaries. Grass is a candidate material only; matching night mounds,
footprints and native calibration remain pending. No layout/gameplay tests,
battle UI changes, runtime enablement or GitHub uploads occurred.

Faraway Island has eighteen first-variation source candidates locally,
nine independently painted day and nine night compositions. All eighteen
initial built-in generations preceded review. Existing Gen1 forest-01-
16x9 and Gen3 rainforest-01-16x9 were visually inspected; forest02/03
prompts were read. Their stream/mountain or temperate-grove identities
were not reused for the enclosed island clearing. New set has broadleaf
trees and shrubs confined to the rear, flat short-grass/fine-earth ground,
no streams, ocean or buildings. No creatures, people, UI, baked mounds
or split day/night scenes were seen. Native FarawayIsland_Interior is
INDOOR/SHADE despite exterior vegetation, 29x26 General/Fortree tilesets:
https://raw.githubusercontent.com/pret/pokeemerald/master/data/maps/FarawayIsland_Interior/map.json
https://raw.githubusercontent.com/pret/pokeemerald/master/data/layouts/layouts.json
Nine cramped landscape originals (day16:9/3:2/21:9 and all six night
landscapes) were preserved with prompts in drafts, excluded from inventory.
Nine targeted low-camera retries were generated before retry-batch review,
with substantially more clear ground behind the opponent. The accepted
sixteen non-ultrawide originals are unchanged. Day2048x768 original is
preserved with approved excess-canopy/bottom-canvas trim [0,140,2048,716]
to2048x576; accepted night2103x748 original is preserved with bottom-only
trim [0,0,2103,591] to2103x591. Both final crops reviewed; no resampling.
Observed accepted ground boundaries (16:9/4:3/3:2/16:10/21:9/32:9 original/
9:16/9:19.5/9:20): day .11/.37/.12/.35/.11/.40/.32/.37/.31; night
.09/.12/.11/.11/.12/.11/.37/.35/.28. Exact prompts/hashes/draft geometry
are saved; crop transforms anchors and boundaries. The higher .35-.37
boundaries need particular footprint attention during native calibration.
Forest/grass are candidate materials; matching night mounds, actual
map-specific context and calibration remain pending. No layout/gameplay
tests, battle UI edits, runtime enablement or GitHub uploads occurred.

Eleven more families have explicit local mound candidates after representative
16:9 source/material comparisons: warm basalt for Magma Hideout, Terra Cave,
volcanic cave, Ancient Tomb and Granite Cave; sandstone for Desert Ruins,
Desert Underpass and Mirage Tower; cool cave stone for Island Cave; pale
limestone for the dry floors of Shoal Cave and Seafloor Cavern. These are
surface/palette authoring choices, not final blending or native footprint
certification across all aspect ratios. Water encounters remain separate.
Magma Hideout's special story-room suitability still needs context review.

Original warm-basalt, sandstone, cave and pale-limestone mound cutouts were
visually inspected. User-authorized 12-source-pixel rounded alpha cleanup
created four -clean-v3 siblings, preserving visible paint and originals;
all four outputs were visually reviewed. Existing release assets were not
overwritten. The local catalog now has 30 candidate families/270
compositions; 42 new Hoenn families still need explicit mound bindings.
Source inventory continues to report zero integrity errors. No gameplay/
layout tests, battle UI edits, release enablement or uploads occurred.

Hoenn authoring-readiness inventory now checks canonical image SHA-256,
reference dimensions, aspect tolerance, exact prompt presence, duplicate IDs,
material candidates and explicit mound binding coverage. It ignores archived
draft metadata. Current 675 source records have no reported integrity errors;
this is source evidence only, not gameplay or visual pairing certification.
The catalog builder now also excludes archived draft metadata consistently
with the artwork inventory (one preserved draft metadata file was found).

Reviewed pale-gravel day/night and cool-gray night cutouts had edge matte
contamination. User-authorized 12-source-pixel rounded alpha inset cleanup
preserves originals and all visible painted RGB. Earlier cleanup candidates
with extruded RGB outside the transparent silhouette were rejected in review
and archived under art/mounds/drafts/cleanup-rejected. Revised -clean-v3
copies clear zero-alpha RGB; all three were visually reviewed. Cleaner now
preserves all visible paint rather than extruding color across the new rim.
No other previously used mound files were overwritten or silently replaced.

Navel Rock depths/summit use reviewed pale-gravel candidates (separate summit
night); Sky Pillar summit uses floor-gray and cool-gray night candidates.
These three explicit local bindings bring the integration candidate to 19
families/171 compositions, including existing reuse entries. There remain 53
new Hoenn families without explicit pairings. Candidate material folders have
night assets where required, but availability alone does not prove matching
lighting. Native footprint, blending, context and placement remain pending;
no gameplay/layout tests, battle UI edits, release enablement or uploads.

Sky Pillar summit has eighteen first-variation source candidates locally,
nine day and nine independently painted night compositions. All eighteen
initial built-in generations finished before visual review. Broad level
weathered gray rooftop, distant low broken parapet/pillar stumps and clouds
leave clear standing areas. No creatures, people, UI, inscriptions, floor
grid, baked mounds, standing-plane holes or split scenes were seen. Native
SkyPillar_Top is route/no weather with the Rayquaza encounter:
https://raw.githubusercontent.com/pret/pokeemerald/master/data/maps/SkyPillar_Top/map.json
Sixteen originals unchanged. Day 2231x705 and night 2115x743 originals and
prompts preserved under drafts; approved bottom-only crops [0,0,2231,627]
and [0,0,2115,595] give 2231x627/2115x595 without resampling. Both final
crops were reviewed. Observed rear-floor boundaries, aspect order
16:9/4:3/3:2/16:10/21:9/32:9 original/9:16/9:19.5/9:20:
day .28/.27/.24/.24/.30/.19/.21/.18/.22;
night .32/.28/.26/.34/.31/.29/.24/.18/.20. Night 16:10 and cropped
32:9 need particular opponent footprint/parapet clearance attention during
native calibration. Exact prompts, hashes and draft geometry accompany all
sources. Floor-gray/floor-gray-night-cool are candidate materials only;
actual context, mound matching and calibration remain pending. No
layout/gameplay testing, runtime enablement, battle UI changes or GitHub
uploads occurred.

Pacifidlog water has eighteen first-variation source candidates locally,
nine day and nine independently painted night compositions. All eighteen
initial built-in generations finished before review. Broad calm turquoise/
blue water fills the contact areas; small cream houses on low log rafts and
connecting walkways remain in the distance. No creatures, people, UI,
foreground platforms, baked mounds or split day/night scenes were seen.
Native PacifidlogTown is town/sunny, connected to Routes 131/132:
https://raw.githubusercontent.com/pret/pokeemerald/master/data/maps/PacifidlogTown/map.json
Sixteen originals are unchanged. The day 2089x753 and night 2048x768
originals/prompts are preserved under drafts; approved bottom-only crops
[0,0,2089,588] and [0,0,2048,576] yield 2089x588/2048x576 without
resampling. Both final crops were reviewed. Observed clear-water rear
boundaries in aspect order 16:9/4:3/3:2/16:10/21:9/32:9 original/
9:16/9:19.5/9:20: day .14/.14/.14/.14/.14/.12/.10/.13/.09;
night .19/.17/.20/.17/.16/.16/.13/.15/.14. Exact prompts, hashes and
draft geometry accompany the set. Ripple/islet-sand are material candidates
only; night matching, water encounter mapping, mound footprints and native
calibration remain pending. No layout/gameplay tests, runtime enablement,
battle UI changes or GitHub uploads occurred.

Navel Rock summit has eighteen first-variation source candidates locally,
nine day and nine independently painted night compositions. All eighteen
initial built-in generations finished before visual review. Broad pale
limestone floor, small distant low ridges and high cloudscape keep the
standing plane clear; no creatures, people, UI, inscriptions, baked mounds,
floor drops or split day/night scenes were seen. Native NavelRock_Top has
underground/shade flags despite the summit setting, so those flags alone
must not determine source lighting:
https://raw.githubusercontent.com/pret/pokeemerald/master/data/maps/NavelRock_Top/map.json
Sixteen originals remain byte-unchanged. The day 2243x701 and night
2115x743 originals/prompts are preserved under drafts. Approved bottom-only
crops [0,0,2243,631] and [0,0,2115,595] produce 2243x631 and 2115x595
without resampling; both final crops were reviewed. Observed ground
boundaries in aspect order 16:9/4:3/3:2/16:10/21:9/32:9 original/
9:16/9:19.5/9:20: day .24/.20/.20/.25/.23/.23/.19/.20/.18;
night .25/.26/.24/.27/.25/.29/.23/.22/.24. Prompts, hashes and draft
geometry accompany all sources. Pale-gravel/cave-pale-limestone are only
material candidates; matching night mounds, native story context, footprints
and calibration remain pending. No layout/gameplay tests, runtime enablement,
battle UI changes or GitHub uploads occurred.

Southern Island now has eighteen first-variation source candidates locally,
nine day and nine separately painted night images. All eighteen initial
built-in generations finished before visual review. The sheltered grove has
broad level short-grass/sandy-earth ground, distant subtropical broadleaf
foliage and a small plain rear stone; no creatures, people, UI, inscriptions,
split scenes, baked mounds, water or drops in the standing areas were seen.
Native SouthernIsland_Interior is route/shade, 27x24 General/Rustboro:
https://raw.githubusercontent.com/pret/pokeemerald/master/data/maps/SouthernIsland_Interior/map.json
https://raw.githubusercontent.com/pret/pokeemerald/master/data/layouts/layouts.json
The initial 32:9 night composition had too low a ground boundary for an
acceptable crop; it and its exact prompt are preserved in drafts. One
recomposition places the rear foliage much farther away. Sixteen accepted
originals are unchanged. The 2115x743 day and 2121x741 retry-night originals
are preserved with prompts; approved bottom-only crops [0,0,2115,595] and
[0,0,2121,597] produce 2115x595 and 2121x597 without resampling. Both final
crops were visually reviewed. Observed ground boundaries, in aspect order
16:9/4:3/3:2/16:10/21:9/32:9 original/9:16/9:19.5/9:20, are day
.26/.25/.24/.29/.30/.27/.22/.22/.21 and night
.29/.29/.29/.29/.30/.12/.25/.21/.22. Exact prompts, hashes and draft
geometry accompany every accepted source. Grass/forest are material
candidates only; night matching, stone/context suitability, mound footprints
and native calibration remain pending. No layout/gameplay testing, runtime
enablement, battle UI changes or GitHub uploads occurred.

Mt. Pyre exterior now has eighteen first-variation source candidates:
nine day and nine independently painted night compositions. All eighteen
initial built-in generations were completed before visual review. Gen1
mountain-01-16x9 was visually inspected, and 02/03 prompts read; alpine
snow peaks/red mesas were not reused for the weathered grassy mountainside.
Accepted set has broad level short-grass/gray-brown earth, low rear mossy
rock ledges, small shrubs/trees and distant hazy green ridges. No creatures,
people, UI, monuments, baked mounds, standing-area drops or split day/night
views were seen. Native MtPyre_Exterior is route/no weather, 38x51 with
General/Facility tilesets:
https://raw.githubusercontent.com/pret/pokeemerald/master/data/maps/MtPyre_Exterior/map.json
https://raw.githubusercontent.com/pret/pokeemerald/master/data/layouts/layouts.json
This source set covers exterior slopes; summit story-space suitability
still needs native context review, not an assumption from the family name.
Sixteen originals unchanged, with exact prompts/hashes/draft geometry.
Day32:9 original2089x753 and night2172x724 are preserved with prompts in
drafts; approved bottom-canvas-only crops [0,0,2089,588] and [0,0,2172,611]
give2089x588/2172x611, no resampling. Both final crops were reviewed.
Observed ground boundaries (16:9/4:3/3:2/16:10/21:9/32:9 original/
9:16/9:19.5/9:20): day .23/.22/.22/.24/.25/.24/.19/.20/.18; night
.24/.24/.27/.29/.26/.27/.22/.18/.19. Crops transform boundaries/anchors.
Grass/pale-gravel are candidate materials; night matching, footprints and
native calibration remain pending. No layout/gameplay tests, battle UI
changes, runtime enablement or GitHub uploads occurred.

Ancient Tomb's wide source set adds 16:10, 21:9 and 32:9 paintings. Each
built-in generation was individually visually reviewed as an enclosed gray-
brown chamber with a plain rear slab and clear continuous dusty floor,
without creatures, inscriptions, machinery, exterior views, UI, regular
flooring grids or baked mounds. Exact prompts and draft geometry accompany
each source. The 32:9 original is preserved at 2109x746; authorized crop-only
preparation uses [0,70,2109,663] to produce 2109x593 without resampling.
The final crop was visually reviewed, with provenance and transformed draft
anchors saved. Three portrait compositions remain. Mound color matching,
footprints, map-specific suitability and native calibration remain pending.
No layout tests, runtime enablement, release or published asset-pack changes
occurred.

Ancient Tomb now has all nine first-variation source compositions after
adding 9:16, 9:19.5 and 9:20 portrait paintings through built-in image
generation. Each portrait was individually visually reviewed: one enclosed
gray-brown chamber, plain rear stone slab, continuous clear dusty floor,
constant indoor illumination, no creatures, inscriptions, UI or baked
mounds. Originals were imported without pixel edits; exact prompts and
draft placement metadata accompany each painting. Observed floor boundaries
are recorded at .24, .27 and .25 respectively, rather than the requested
prompt boundary. Source completeness does not prove native mound contact,
map-specific suitability or runtime readiness. Those remain pending, and
layout testing remains deferred until the remaining Gen3 assets are ready.
No runtime catalog, released pack or battle UI changes were made.

Island Cave (regi_island_cave) begins with original 16:9, 4:3 and 3:2
source paintings. Native Emerald IslandCave map metadata identifies an
underground map with no weather; its layout uses General/Cave tilesets:
https://raw.githubusercontent.com/pret/pokeemerald/master/data/maps/IslandCave/map.json
https://raw.githubusercontent.com/pret/pokeemerald/master/data/layouts/layouts.json
A Gen1 cave-01 16:9 reuse candidate was visually inspected, but its large
sunlit opening was unsuitable for this enclosed chamber treatment. Three
built-in generations were individually visually reviewed as cool-gray
rounded enclosed rock chambers with continuous dusty floor, no ice, water,
creatures, inscriptions, UI or baked mounds. Exact prompts and draft
placement metadata accompany each unchanged original. Floor boundaries
are recorded at .30/.28/.30 from observation. Six aspects remain. Cave and
floor-gray mound candidates, map-specific suitability, contact footprints
and native calibration remain pending. No layout tests, battle UI changes,
runtime enablement, release or published asset-pack changes occurred.

Island Cave's wide source set adds 16:10, 21:9 and 32:9 paintings.
Each built-in generation and the final 32:9 crop was individually visually
reviewed: enclosed cool-gray rock chamber, continuous floor and constant
indoor light, no creatures, UI or baked mounds. The 2159x728 original is
preserved; authorized crop [0,60,2159,667] produces 2159x607 with no
resampling. Exact prompts, crop provenance and transformed draft anchors
are saved. Three portrait aspects remain. Mound matching, map-specific
suitability and native calibration remain pending; no layout tests,
runtime enablement, battle UI edits or release changes occurred.

Island Cave now has nine first-variation source compositions with the
addition of 9:16, 9:19.5 and 9:20 portraits. Each built-in generation was
individually visually reviewed as one enclosed cool-gray chamber with a
continuous clear floor and constant indoor lighting, without creatures,
water, ice, inscriptions, UI or baked mounds. Originals were imported
unchanged with exact prompts and draft placement metadata. Observed floor
boundaries are .19/.20/.19. All mound matching, contact footprints and
native calibration remain pending. No layout tests, runtime enablement,
battle UI changes, release or published asset-pack changes occurred.

Desert Ruins (regi_desert_ruins, Regirock chamber; distinct from Mirage
Tower/desert_ruin) begins with 16:9, 4:3 and 3:2 original source paintings.
Native Emerald map metadata identifies underground/no weather; its layout
uses General/Cave tilesets:
https://raw.githubusercontent.com/pret/pokeemerald/master/data/maps/DesertRuins/map.json
https://raw.githubusercontent.com/pret/pokeemerald/master/data/layouts/layouts.json
A visually reviewed Gen2 Ruins of Alph reuse candidate had temple pillars
and carved symbols, so it was not reused. Built-in paintings were visually
reviewed as enclosed ochre-brown rock chambers with clear sand-dusted floor,
constant indoor light, no creatures, UI or baked mounds. Initial 16:9
placed the wall too low (.44), obstructing the draft opponent ground area;
it and its exact prompt are preserved under drafts, excluded from coverage.
A targeted retry raised the boundary to .23; 4:3 and 3:2 boundaries are
.19/.22. Canonical originals are unchanged, with exact prompts and draft
metadata. Six aspects remain. Sandstone/mineral-sand are provisional mound
candidates; matching, native map-specific suitability and calibration remain
pending. No layout tests, runtime enablement, UI changes or release changes.

Desert Ruins adds original 16:10, 21:9 and 32:9 wide source compositions.
All three built-in generations and the final crop were individually
visually reviewed as enclosed ochre rock chambers with clear continuous
sand-dusted floor, constant indoor light, no creatures, UI or baked mounds.
Observed boundaries are .24/.22; the 32:9 original boundary .20 transforms
to approximately .239. Its 2164x727 original and exact prompt are preserved;
authorized crop [0,0,2164,609] produces 2164x609 without resampling. Exact
prompts, crop provenance and transformed draft geometry accompany sources.
Three portraits remain. Native calibration and mound matching remain
pending. No layout tests, runtime enablement, UI or release changes occurred.

Desert Ruins now has nine first-variation source compositions after adding
9:16, 9:19.5 and 9:20 portrait paintings. Built-in generations were each
visually reviewed as one enclosed ochre rock chamber with constant indoor
light and continuous clear sand-dusted floor, no creatures, inscriptions,
UI or baked mounds. Originals are unchanged with exact prompts and draft
placement metadata. Observed floor boundaries are .15/.14/.13. Source
coverage does not prove runtime readiness: mound matching, contact regions
and native calibration remain pending. Layout tests remain deferred;
no runtime catalog, battle UI or published release changes were made.

Navel Rock depths begins with 16:9, 4:3 and 3:2 original source paintings.
Native Emerald NavelRock_Bottom is underground with no weather, using its
own NavelRock secondary tileset. The native tile image was visually read
as reference only; native pixels were not copied into the artwork:
https://raw.githubusercontent.com/pret/pokeemerald/master/data/maps/NavelRock_Bottom/map.json
https://raw.githubusercontent.com/pret/pokeemerald/master/data/layouts/layouts.json
https://raw.githubusercontent.com/pret/pokeemerald/master/data/tilesets/secondary/navel_rock/tiles.png
A Gen1 legendary_mewtwo-01 16:9 reuse candidate was visually reviewed but
had saturated blue crystals and a rear pool, so was not reused. Three
built-in generations were individually visually reviewed as enclosed pale
silver-gray natural stone chambers with clear dry floor and constant
indoor light, no creatures, crystals, UI or baked mounds. Originals are
unchanged with exact prompts and draft geometry. Observed floor boundaries
are .26/.24/.24. Six aspects remain. Cave-pale-limestone/pale-gravel mound
matching, map-specific suitability and native calibration remain pending.
No layout tests, battle UI edits, runtime enablement or release changes.

Navel Rock depths adds original 16:10, 21:9 and 32:9 source compositions.
Built-in generations and the final crop were individually visually reviewed
as enclosed pale-gray chambers with clear dry floor, constant indoor light,
no creatures, UI or baked mounds. Exact prompts and draft placement data
are saved locally. The 2231x705 original is preserved; authorized crop
[0,0,2231,627] yields 2231x627 without resampling, with provenance and
transformed draft geometry. Boundaries .27/.28 and cropped approximately
.281 are recorded from visual observation. Three portraits remain. Mound
matching and native calibration remain pending; no layout tests, runtime
enablement or UI edits occurred. Per the user's updated preference, source
and artwork uploads are deferred until a release, including this batch.

Navel Rock depths now has nine first-variation source compositions with
9:16, 9:19.5 and 9:20 portraits added locally. Each built-in generation was
individually visually reviewed as an enclosed pale-gray rock chamber with
clear dry floor and constant indoor light, no creatures, crystals, water,
UI or baked mounds. Originals are unchanged with exact prompts and draft
placement data. Observed boundaries are .21/.18/.17. Mound matching, native
contact regions and calibration remain pending. No layout tests, runtime
enablement, UI changes or GitHub uploads occurred.

Abandoned Ship dry interior begins with 16:9, 4:3 and 3:2 original source
paintings. Native Emerald Rooms_1F metadata identifies underground/shade
and an InsideShip tileset:
https://raw.githubusercontent.com/pret/pokeemerald/master/data/maps/AbandonedShip_Rooms_1F/map.json
https://raw.githubusercontent.com/pret/pokeemerald/master/data/layouts/layouts.json
The Gen1 ship_corridor-01 16:9 candidate was visually reviewed but too clean
and intact for this weathered treatment, so was not reused. Three built-in
generations were individually reviewed as faded gray-green rusty ship
interiors with clear continuous dry floor, no creatures, UI, baked mounds,
floorboard or tile grids. Exact prompts and draft placement data accompany
unchanged originals. Observed boundaries .36/.31/.29 are recorded; enemy
mound footprint clearance especially on 16:9 needs later native review.
Flooded/submerged sections remain distinct mapping contexts, not certified
by this dry set. Six aspects remain. Mound pairing and map-specific native
calibration are pending. No layout tests, runtime enablement, UI edits or
GitHub uploads occurred.

Abandoned Ship's first dry-interior source set now covers all nine aspects.
16:10, 21:9, 32:9 and three portrait paintings were individually visually
reviewed, including the final 32:9 crop. All have worn gray-green dry floor,
rusted bulkheads, cloudy portholes and edge debris, no creatures, UI,
floor grids or baked mounds. The 2091x752 wide original and exact prompt
are preserved; authorized [0,0,2091,588] crop yields 2091x588 without
resampling. Draft geometry is transformed and crop provenance saved.
Observed wide boundaries .33/.36/cropped approximately .358 and portrait
boundaries .23/.25/.23 are recorded. Wide enemy mound footprint clearance
needs later native review, especially 21:9/32:9. Source completeness is not
runtime certification; flooded/submerged mapping contexts and mound matching
remain pending. No layout tests, runtime enablement, UI edits or uploads.
User reaffirmed first-variant coverage and base compatibility before the
later expansion to three variants per location.

Aqua Hideout begins with 16:9, 4:3 and 3:2 original source paintings.
Native Emerald AquaHideout_1F identifies indoor/no weather and an Aqua
battle scene, with a Facility secondary tileset:
https://raw.githubusercontent.com/pret/pokeemerald/master/data/maps/AquaHideout_1F/map.json
https://raw.githubusercontent.com/pret/pokeemerald/master/data/layouts/layouts.json
Gen1 rocket_hideout-01 16:9 was visually reviewed as a darker warehouse
candidate, and not reused for this cooler facility treatment. Three
built-in generations were individually visually reviewed as blue-gray
facility rooms with distant equipment, continuous matte cool-gray floor,
constant indoor light, no creatures, UI, logos, grids or baked mounds.
Originals are unchanged with exact prompts and draft geometry. Observed
boundaries .24/.26/.24 are recorded. Six aspects remain. Floor-gray and
floor-gray-night-cool are provisional matching candidates, not a night
lighting requirement. Native map-specific suitability, mound matching and
calibration remain pending. No layout tests, runtime enablement, battle UI
changes or GitHub uploads occurred.

Aqua Hideout adds original 16:10, 21:9 and 32:9 source compositions locally.
All built-in generations and the final crop were individually visually
reviewed as cool blue-gray facility rooms with equipment at distant edges,
clear matte floor, constant indoor light, no creatures, UI or baked mounds.
Exact prompts and draft geometry are saved. The 1983x793 original is
preserved; authorized crop [0,0,1983,558] yields 1983x558 without resampling.
Crop provenance and transformed draft anchors accompany it. Observed
boundaries .24/.26 and cropped approximately .334 are recorded. Three
portrait aspects remain. Mound matching, footprint review and native
calibration remain pending; no layout tests, runtime enablement, battle UI
changes or GitHub uploads occurred.

Aqua Hideout now has nine first-variation source compositions after adding
9:16, 9:19.5 and 9:20 portraits locally. Built-in generations were each
visually reviewed as one enclosed blue-gray facility room with distant
equipment and broad clear matte floor, constant indoor lighting, no
creatures, UI or baked mounds. Originals are unchanged with exact prompts
and draft placement metadata. Observed floor boundaries .15/.13/.15 are
recorded. Source completeness does not prove native grounding: mound
matching, map-specific suitability and calibration remain pending. No
layout tests, battle UI edits, runtime enablement or GitHub uploads occurred.

Magma Hideout has nine first-variation source candidates by reusing the
existing original Gen3 volcanic_cave-01 compositions unchanged. All nine
were individually visually reviewed as enclosed dark brown basalt passages
with warm reflected light, distant steam and broad clear dry ground, no
creatures, UI, baked mounds or floor grids. Native Emerald MagmaHideout_1F
identifies underground/no weather, General/Lavaridge tilesets:
https://raw.githubusercontent.com/pret/pokeemerald/master/data/maps/MagmaHideout_1F/map.json
https://raw.githubusercontent.com/pret/pokeemerald/master/data/layouts/layouts.json
This is source coverage for rocky hideout passages, not certification of
all specialized story rooms. Native context review remains pending. Copies
are byte-identical; source hashes, exact original prompts, inherited draft
geometry and reuse provenance are saved. Existing crop provenance remains
nested in draft metadata where applicable, and originals remain preserved.
Cave-warm-basalt pairing, footprint checks and native calibration remain
pending. No new image generation, layout tests, runtime enablement, battle
UI changes or GitHub uploads occurred.

Mt. Pyre interior now has nine first-variation source candidates locally.
The full set was generated before its remaining batch review, following
the user's preference to complete a location's aspect set before checking.
All nine were visually reviewed: muted gray memorial hall, plain rounded
markers and restrained white flowers at the rear, continuous cool-gray
matte floor, no creatures, UI, inscriptions, floor grid or baked mounds.
Native Emerald MtPyre_2F identifies an indoor/no-weather map with
General/Facility tilesets:
https://raw.githubusercontent.com/pret/pokeemerald/master/data/maps/MtPyre_2F/map.json
https://raw.githubusercontent.com/pret/pokeemerald/master/data/layouts/layouts.json
Gen1 haunted_tower-01-16x9 was reviewed but its Gothic architecture was
not reused. Exact generation prompts are preserved. Eight paintings were
imported unchanged; the 2073x759 super-ultrawide original is preserved in
drafts with an approved canvas-only crop [0,60,2073,643] to 2073x583,
reviewed after cropping. Observed floor boundaries are .28/.29/.27/.27/.31
for 16:9/4:3/3:2/16:10/21:9, .30 before the 32:9 crop, and .22/.19/.20
for portraits. Draft anchors are transformed with the crop. Floor-gray
and floor-gray-night-cool are candidate materials only; mound matching,
native map context and gameplay calibration remain pending. Source
coverage is not runtime readiness. No layout/gameplay tests, battle UI
changes, runtime enablement or GitHub uploads occurred.

Seashore House now has nine first-variation source candidates locally.
All nine built-in generations were completed before batch visual review.
Gen1 restaurant-01-16x9 was inspected (only one aspect exists for that
variant), and 02/03 prompts read, before choosing a coherent new seaside
refreshment-room set. Cream walls/blue trim, rear counter with plain cups,
bottles and register, small rear tables/stools and broad ivory matte floor
were reviewed in all nine. No creatures, people, UI, baked mounds or floor
grids were seen. Native Route109_SeashoreHouse is indoor/no weather,
15x10, Building/SeashoreHouse tilesets:
https://raw.githubusercontent.com/pret/pokeemerald/master/data/maps/Route109_SeashoreHouse/map.json
https://raw.githubusercontent.com/pret/pokeemerald/master/data/layouts/layouts.json
Exact prompts/hashes/draft placement metadata are saved. Eight originals
are unchanged; the 2048x768 super-ultrawide original/prompt is preserved
in drafts and the approved bottom-canvas-only trim [0,0,2048,576] gives
2048x576 without resampling. The final crop was reviewed. Observed floor
boundaries .20/.24/.21/.27/.23 (16:9/4:3/3:2/16:10/21:9), .25 before
32:9 crop, and .16/.14/.14 for portraits are recorded. Floor-ivory and
floor-beige are candidate materials. Source coverage does not establish
native context, mound blending or grounded footprints; calibration stays
pending. No layout/gameplay tests, battle UI changes, runtime enablement
or GitHub uploads occurred.

Trick House has nine first-variation source candidates locally. All nine
built-in aspect generations preceded batch visual review. Gen1 dojo-01-
16x9 was inspected but its martial-arts identity was not reused. The new
set has cream timber-trimmed walls, a rear double door, small brass wall
buttons, pivot partitions and low corner blocks, broad empty beige-gray
matte floor, constant enclosed indoor light. No creatures, people, UI,
baked mounds or floor grids were seen. Native Route110_TrickHousePuzzle1
is indoor/no weather, 15x22 with Building/TrickHousePuzzle tilesets:
https://raw.githubusercontent.com/pret/pokeemerald/master/data/maps/Route110_TrickHousePuzzle1/map.json
https://raw.githubusercontent.com/pret/pokeemerald/master/data/layouts/layouts.json
The secondary tiles image was inspected as a grayscale shape reference:
https://raw.githubusercontent.com/pret/pokeemerald/master/data/tilesets/secondary/trick_house_puzzle/tiles.png
This is an original general puzzle-chamber source set, not certification
that every challenge room's specific obstacles match. Per-puzzle context
and mapping review remains necessary before runtime enablement.
Eight originals are unchanged; the 2048x768 ultrawide original/prompt is
preserved in drafts, approved bottom-canvas trim [0,0,2048,576] gives
2048x576 without resampling, and final crop was reviewed. Observed floor
boundaries .20/.17/.22/.21/.23 for 16:9/4:3/3:2/16:10/21:9, .21 before
32:9 crop, .14/.14/.12 for portraits accompany exact prompts, hashes and
draft placement metadata. Floor-gray/floor-beige are material candidates.
Mound matching, footprints and native calibration remain pending. No
layout/gameplay tests, battle UI changes, runtime enablement or uploads
occurred.

Oceanic Museum now has nine first-variation source candidates locally.
All nine aspect compositions were generated before batch visual review.
The Gen1 museum-01-16x9 source was inspected but its fossil exhibits were
not reused for this marine gallery. Original built-in generations show
pale blue-gray walls, navy trim, three rear glass cases with inanimate
model ships/navigation instruments and continuous unobstructed matte
floor. No creatures, people, UI, baked mounds or floor grids were seen.
Native Emerald SlateportCity_OceanicMuseum_2F is indoor/no weather,
20x9 with Building/OceanicMuseum tilesets:
https://raw.githubusercontent.com/pret/pokeemerald/master/data/maps/SlateportCity_OceanicMuseum_2F/map.json
https://raw.githubusercontent.com/pret/pokeemerald/master/data/layouts/layouts.json
Exact prompts and draft metadata accompany each painting. Eight originals
are unchanged; the 2048x768 super-ultrawide original is preserved in drafts
with an approved canvas-only crop [0,60,2048,636] to 2048x576, visually
reviewed after cropping. Observed floor boundaries are .33/.30/.33/.34/.35
for 16:9/4:3/3:2/16:10/21:9, .29 before the 32:9 crop, and .24/.20/.20
for portraits. Floor-gray/floor-gray-night-cool remain material candidates;
this indoor set does not represent separate night lighting. Context,
mound blending, footprints and native calibration remain pending. Source
coverage is not runtime readiness. No layout/gameplay tests, UI changes,
runtime enablement or GitHub uploads occurred.

Mossdeep Space Center has nine first-variation source candidates locally.
All nine aspect versions were generated before batch visual review.
Gen1 museum_space-01-16x9 was inspected but its exhibit gallery was not
reused for the upstairs control room. Built-in generations have pale-gray
walls, blue trim, rear consoles with unmarked teal monitors/tucked chairs,
and broad clear gray matte floor; no people, creatures, UI, baked mounds
or floor grids were seen. Native Emerald MossdeepCity_SpaceCenter_2F is
indoor/no weather, 16x10, General/Facility tilesets:
https://raw.githubusercontent.com/pret/pokeemerald/master/data/maps/MossdeepCity_SpaceCenter_2F/map.json
https://raw.githubusercontent.com/pret/pokeemerald/master/data/layouts/layouts.json
Eight originals are unchanged. The 2048x768 ultrawide original is preserved
with its exact prompt in drafts; approved crop [0,60,2048,636] yields
2048x576 without resampling and was reviewed after cropping. Observed
floor boundaries .30/.29/.28/.30/.33 (16:9/4:3/3:2/16:10/21:9), .31
before the 32:9 crop, and .23/.21/.21 for portraits are recorded. Exact
prompts, hashes and draft placement metadata accompany every source.
Floor-gray/floor-gray-night-cool are material candidates only. Context,
mound matching and native calibration remain pending; this does not prove
runtime readiness. No layout/gameplay tests, battle UI changes, runtime
enablement or GitHub uploads occurred.

Weather Institute has nine first-variation source candidates locally.
All nine initial aspect versions were generated before batch review.
Gen1 laboratory-01-16x9 was visually inspected, and prompts for variants
02/03 read; botanical/fossil identities were not reused for meteorology.
Built-in original artwork has mint-gray walls, cream cabinets, old blank
teal-screen computers, weather-instrument models and clear sage-gray matte
floor, no creatures, people, UI, baked mounds or floor grids. Native
Emerald Route119_WeatherInstitute_2F is indoor/no weather, 20x11 with
Building/Lab tilesets:
https://raw.githubusercontent.com/pret/pokeemerald/master/data/maps/Route119_WeatherInstitute_2F/map.json
https://raw.githubusercontent.com/pret/pokeemerald/master/data/layouts/layouts.json
Initial 4:3/16:10/21:9 had overly close cabinets; these originals/prompts
are preserved under drafts, excluded from inventory. Three retries were
generated as a batch before review and accepted with rear boundaries
.14/.17/.17. Other observed boundaries: 16:9 .36, 3:2 .34, portraits
.27/.26/.22. The 2172x724 super-ultrawide original/prompt is preserved,
approved canvas-only crop [0,70,2172,681] gives 2172x611 with observed
original boundary .38 transformed alongside draft anchors. The final crop
was visually reviewed. Exact prompts/hashes/placement metadata accompany
the accepted set. Floor-sage/floor-gray are candidates; native context,
mound blending, footprints and calibration remain pending. Source coverage
does not imply runtime readiness. No layout/gameplay tests, battle UI
changes, runtime enablement or GitHub uploads occurred.

Cool-gray facility mound pairing: Aqua Hideout, Space Center, Oceanic Museum, Battle Factory and Hoenn Battle Tower now use the new floor-cool-gray source in the local candidate bindings. Representative 16:9 floor materials and both original/clean mound images were visually reviewed. Exact generation prompt and original are preserved in art/mounds/floor-cool-gray; clean-v3 uses approved perimeter alpha cleanup, preserving visible RGB. This is material matching only; all-aspect placement and native calibration remain pending. No gameplay tests or uploads were performed. Future location artwork is generated as a complete aspect/day-night batch before review, per user instruction.

Indoor reuse pairing: Weather Institute and Battle Dome use cleaned floor-sage-02; Trick House and Battle Palace use cleaned floor-ivory-01; Seashore House uses existing floor-beige-02-clean. Representative background floors and mound sources were reviewed. Sage and ivory originals are preserved with approved 12px rounded alpha edge cleanup in new clean-v3 siblings. Cleanup provenance/hashes are in metadata/rse-facility-mound-cleanup.json. Abandoned Ship remains unbound: its darker weathered floor needs a closer material match. These are local material candidates, not certified native/all-aspect layouts. No gameplay/layout testing or uploads.

Neutral stone mound batch: generated original stone-neutral and cave-dust-tan transparent cutouts using built-in imagegen. Exact prompts and originals are preserved under art/mounds; separate clean-v3 siblings use approved 12px rounded alpha perimeter cleanup. Both cleaned outputs visually reviewed together. Existing sandstone was too orange, cave too blue, and warm basalt too dark for these floors. Local ambient bindings now use stone-neutral for Cave of Origin, Sky Pillar interior and Battle Pyramid, and cave-dust-tan for Artisan Cave. Representative 16:9 background floors were visually compared; all-aspect blending/footprints/native positioning remain pending. Provenance/hashes: metadata/rse-neutral-stone-mounds.json. No gameplay/layout tests, battle UI changes or GitHub uploads.

Carpet reuse batch: existing burgundy, lavender, moss and blue originals reviewed and cleaned into separate clean-v3 siblings using approved 12px rounded alpha edge inset. Original painted interiors remain unchanged; provenance/hashes in metadata/rse-carpet-mound-cleanup.json. Representative 16:9 floors reviewed for Sidney, Phoebe, Drake, Champion, Battle Pike, Fortree, Mossdeep and Dewford. New local bindings: Sidney and Champion burgundy, Fortree moss, Mossdeep lavender, Dewford blue, Battle Pike existing clean-v3 sage. Phoebe darker purple and Drake brighter red remain unbound pending closer material matches. These bindings are source material candidates; native/all-aspect blending and grounding remain pending. No gameplay/layout tests, UI changes or uploads.

Gym floor reuse batch: representative 16:9 Petalburg, Battle Arena, Mauville, Lavaridge and New Mauville floors visually reviewed against existing mound sources. Local candidate bindings use beige for Petalburg/Battle Arena, neutral light gray for Mauville, clay for Lavaridge, charcoal for New Mauville. Gray/clay/charcoal originals and new clean-v3 siblings were reviewed; approved 12px rounded perimeter alpha cleanup preserves visible painted RGB and originals, with provenance in metadata/rse-gym-floor-cleanup.json. Native/all-aspect blending, scale and placement remain pending. No gameplay/layout tests, battle UI changes or uploads.

Outdoor reuse batch: representative day/night 16:9 sources reviewed for Birth Island, Faraway Island, Southern Island, Frontier Gardens and Hoenn Safari. Existing grass day/night mounds are local material candidates for these five families. Separate grass and forest clean-v3 siblings remove colored edge fringe with approved rounded 12px alpha inset; visible paint and originals preserved. All four cleaned outputs reviewed; forest remains an alternative rather than forced onto open grass clearings. Provenance/hashes: metadata/rse-grass-forest-cleanup.json. All-aspect/native blending and placement remain pending. No gameplay/layout tests, UI changes or uploads.

Volcanic/mountain batch: existing highland/gravel day-night sources visually compared with crater material and rejected as too pale. Generated separate original volcanic-basalt day and night cutouts with built-in imagegen, completing both before pair review. Exact prompts/originals retained; approved 12px rounded alpha cleanup saved to clean-v3 siblings. Both cleaned outputs reviewed, local crater bindings added. Representative Mt Pyre exterior day/night reviewed for existing grass pair; interior reviewed for existing cool-gray floor; Rustboro sandy floor reviewed for existing muted cave-dust-tan. These four families now have local material candidate bindings. Volcanic Slope day reviewed but its accepted night source is a v2 sibling and still needs material review. No native/all-aspect certification, gameplay/layout tests, UI changes or uploads. Provenance: metadata/rse-volcanic-mounds.json.

Water/ice reuse batch: representative 16:9 Glacia and Sootopolis ice floors, Marine Cave water, and Pacifidlog day/night water reviewed. Existing ice-cave-01 chosen for both frozen rooms, islet-rock for Marine Cave ambient, islet-sand day/night for Pacifidlog. Alternate ice-cave-03-v3 was too lavender; pool platform was not chosen for the frozen floor. Approved edge cleanup saved separate clean-v3 siblings with 24px ice /20px islet rounded alpha inset, retaining visible paint/originals. All four cleaned sources visually reviewed; provenance in metadata/rse-water-ice-mound-cleanup.json. These are local material bindings, not native/all-aspect certification. Water encounter mapping and grounding remain pending. No gameplay/layout tests, UI changes or uploads.

Final first-pass mound material batch: original crimson carpet, medium-dark violet carpet and weathered sage floor generated with built-in imagegen, all outputs completed before batch review. Originals and exact prompts retained; clean-v3 siblings use approved 12px rounded perimeter alpha cleanup. All original and clean images reviewed. Local material bindings now pair Drake/crimson, Phoebe/violet, Abandoned Ship/weathered sage. Volcanic Slope accepted night-v2 source was reviewed; muted cave-dust-tan day and volcanic-basalt night are candidate materials. Provenance/hashes: metadata/rse-final-material-mounds.json. First-pass material assignment now covers the planned Hoenn families; this does not certify map contexts, native blending, all-aspect footprints or species grounding. Broader composition/context review and calibration remain required. No gameplay/layout tests, UI changes or GitHub uploads.

Map context correction: PacifidlogTown has positive water/fishing encounter evidence in all three native map inventories. Its water mapping previously selected generic ocean, bypassing dedicated pacifidlog_water scenery. tools/build_rse_art_plan.py now preserves that location identity for water encounters; regenerated plan and metadata/maps/rse.lua retain all 478 candidate signatures (Ruby142/Sapphire142/Emerald194). Evidence: docs/evidence/rse/pacifidlog-water-assignment.json. This verifies authoring assignment only; native encounter rendering remains untested. No uploads or gameplay/layout tests.

Mixed-water map review: Route130 has positive land encounter rates alongside water/fishing in all three native inventories, but ocean-only land classification ignored Mirage Island grass. Added explicit GRASS/LONG_GRASS grassland overrides while retaining ocean water/default assignment. Regenerated candidate map tables; source assignment evidence in docs/evidence/rse/route130-mixed-terrain-assignment.json. Added deferred regression assertions for Route130 grass/water and Pacifidlog water. Tests were not run; no native/layout validation or uploads. High-tide Shoal Cave maps lack positive direct evidence in the inspected inventory and still need special-context investigation rather than invented encounter support.

Prepared the deferred all-area native preview batch: tools/run_rse_probe.py --all-areas derives fixture scenes from the exact per-game map table and current candidate catalog, with separate night cases where present. It selects one representative native map per reachable family and terrain; this is not every-map/species coverage. Removed the obsolete Rustboro-missing assumption from the fixture, replacing it with an intentionally absent family. Report includes expected scene count and all-area mode. Source reviewed only; batch has not run and no validation success is claimed. Native layout review and remaining special-context/art corrections remain pending. No uploads.

First all-area 16:9 native batch: Emerald real-loader fixture initially exposed missing explicit climate policies for new outdoor families (Frontier Gardens night remained day/interior). Added 56 explicit policies for completed authored outdoor/ambient Hoenn families. Rerun passed 93 representative scenes at1280x720, including separate night sources, unchanged native healthbox/menu call traces, RTC and missing-family fallback checks. Reviewed Weather Institute day and Frontier Gardens night captures: opponent feet on separate mound; player lower body/mound partly occluded by unchanged native command panels. Materials still need broader blending review. This does not validate all aspects, every native map, species, doubles, animation or UI mods. Evidence under docs/evidence/rse/loader/native. No uploads.

Emerald all-area additional-aspect batch completed:93 fixture scenes each at5120x1440,900x1600,1024x768,1440x900,1200x800,2100x900,900x1950,900x2000 (744 scene cases). Combined with16:9,837 loading/UI-trace scene cases across nine aspect families. The initial5120 pass exceeded the old120s capture limit; after verified termination, all-area timeout increased to600s and the full batch reran successfully. Reviewed Abandoned Ship5120 and900x1600 captures: background fills viewport, opponent feet meet independent mound, native UI retained; player contact remains partly hidden by native command panels. These two visual samples do not certify all artwork/grounding. Ruby/Sapphire, broader visual review, special contexts, doubles, animated/expanded species, UI mod profiles and resizing remain pending. Evidence:docs/evidence/rse/loader/native/additional-aspects-summary.json. No uploads.

Opponent contact correction following user visual feedback: shared Hoenn native profile mound center moved from y64 to70 (six native pixels down), retaining sprite/HUD positions. Space Center1280x720 capture reviewed before/after: front feet now inside the visible mound surface rather than near its lower edge. Emerald93-scene16:9 batch passes loading/UI-trace checks after change. Other-aspect captures from earlier batch are stale for this placement change; horizon/wall-overlap compositions still require review/correction. Evidence docs/evidence/rse/opponent-contact-correction.json. No blanket grounding claim or uploads.

Volcanic Slope32:9 floor correction: native night capture showed mound over distant ground beyond shelf. Generated complete replacement day/night pair before review, broad uninterrupted foreground. Original2115x743 paintings retained under drafts; approved crop[0,60,2115,655] gives2115x595 without resampling. Final cropped pair reviewed; ground-edge metadata now approximately .286/.274 versus previous .467/.547. Old paintings, metadata and prompts preserved; updated canonical candidate references and catalog. Native rerender still pending; no claim of corrected all-aspect grounding or uploads.

Focused floor correction review: added --family filters to all-area native batch so selected families can be rerendered without unchanged-area captures, rejecting requested families absent from per-game scenes. Volcanic Slope replacement32:9 day/night rerendered at5120x1440 with corrected Hoenn mound profile; both captures reviewed, mound now entirely on flat foreground shelf. Generated original New Mauville4:3 floor-fix-v2 with boundary at.24 rather than.41; old art/metadata/prompt retained, no source resizing. Updated canonical candidate/catalog, native1024x768 focused run passed and capture reviewed: mound clear of machines/wall, feet inside surface, UI unchanged. Exact prompt retained in canonical prompts folder. Other overlap cases and full aspect/species/context validation remain pending. No uploads.

Shoal Cave 3:2 clearance correction: current y70 profile still left the rear mound edge at the waterline. Built-in imagegen produced a new original 1536x1024 composition with rear water restricted to the upper strip and dry floor across the standing zones. Preserved previous art, metadata and exact prompt; new floor-fix-v2 source copied without edits/resizing, horizon metadata .18. Rebuilt candidate catalog (72 families/648 compositions). Focused Emerald batch passed nine loading/UI-trace cases across Shoal Cave, Weather Institute and Hoenn Champion at 3:2,4:3,16:9. Visually reviewed Shoal all three sizes (3:2 replacement, other sources unchanged), Weather/Champion 3:2: feet on mound and mound clear of rear boundary. Other six family/aspect combinations have load/trace evidence only. Captures/hashes: docs/evidence/rse/shoal-floor-correction.json. No uploads; broader context/species/aspect review remains pending.

Ultrawide floor clearance follow-up: regenerated current Emerald5120x1440 previews for Fortree Gym, Dewford Gym, Champion and Weather Institute. All load/UI-trace checks passed; reviewed all four. Champion mound overlapped the rear wall, so created a new original built-in imagegen32:9 composition, preserving source and previous painting/metadata/prompt. Approved excess-canvas crop[0,50,2117,645] produces2117x595 without resampling, horizon approximately.241. Final crop and rerender visually reviewed: entire mound now on carpet with clear separation from wall. Fortree/Dewford/Weather retained after visual clearance review. Candidate catalog rebuilt72families648compositions; source audit675records,0missing base,0unbound,0integrityerrors. These are not exhaustive species/context proofs. Evidence docs/evidence/rse/ultrawide-floor-corrections.json. No uploads.

Cross-game follow-up: Ruby and Sapphire real-loader all-area batches at1280x720 passed71scenes each (142total); current summaries/per-game reports saved under docs/evidence/rse/loader/native. Candidate manifest only. This is representative family/source loading and native UI-trace preservation, not every-map gameplay or visual certification. Pure Lua suite initially exposed stale test expectations: generic GRASS assertion ignored newly explicit Route130 terrain overrides, and catalog test still expected old144/16 partial inventory. Updated terrain test to verify every declared override, and catalog test to require648compositions/72families plus every family's nine-aspect coverage. Full unit suite then passed, including source PNG/geometry, terrain, native context, grounding, downloads, species/settings, rendering contract and fallbacks. Broader native visuals, special contexts and compatibility remain pending; no uploads.

Flooded Abandoned Ship context: inspected native reports confirm water/fishing encounters in Rooms_B1F and HiddenFloorCorridors across all three games (six exact signatures), previously generic cave_water. Generated complete nine-aspect original flooded-hull batch with built-in imagegen before reviewing any output. Reviewed all nine sources: corroded ship bulkhead/portholes/pipes above broad unobstructed water, no creatures/UI/baked mounds. Originals and exact prompts retained under art/gen3/drafts/<aspect>/abandoned_ship_flooded; canonical prompts/art under art/gen3/<aspect>/abandoned_ship_flooded. Only32:9 required approved excess-canvas trim[0,0,2134,600], no resampling; other eight copied unedited. Added dedicated water classification, explicit interior climate policy and separate existing islet-rock mound binding; dry ship mapping retained. Candidate catalog now73families657compositions; source audit684records,0missing,0unbound,0integrityerrors. Unit suite passes including all six water/dry mappings and nine-aspect coverage. Native real-loader batch passed27cases (R/S/E x9aspects); visually reviewed Emerald16:9/32:9/9:16 captures, opponent contact on mound and rear wall clearance good; player mound partly hidden by native command UI. Other native captures have loading/trace evidence only; no exhaustive species/doubles/context certification. Evidence docs/evidence/rse/abandoned-ship-flooded-native-summary.json and abandoned-ship-water-assignment.json. No uploads.

Scripted legendary-context review: native encounter/event inventory confirms MarineCave_End has setwildbattle but no random encounter rates. Added explicit marine_cave water mapping to prevent native fallback for POND/WATER in that inspected room; normal KYOGRE scene continues same dedicated family. Expanded regression assertions for Marine CAVE/POND/WATER/KYOGRE, Terra GROUDON and all three games Sky Pillar RAYQUAZA. Native all-area fixture now adds separate named special-terrain captures using actual Kyogre/Groudon/Rayquaza species rather than Poochyena. Full unit suite passes. Emerald24cases across16:9/32:9/9:16 pass loading/UI traces. Visually reviewed three actual legendary16:9 captures, Rayquaza32:9 and summit32:9night: grounded Groudon and preserved native hover for Kyogre/Rayquaza, no rear-boundary overlap in named captures. This is terrain/species fixture evidence, not actual story event playthrough or exhaustive compatibility. Evidence legendary-context-review.json and legendary-native-summary.json. No new art or uploads this follow-up; UI and sprites unchanged.

Doubles grounding follow-up: added isolated --double real-loader fixture with valid trainer identity, two player/two enemy Pokemon, all four active battlers asserted and separate evidence folder. Initial fixture setup lacked trainer identity (fixed before successful runs); four-battler capture then exposed rear opponent ahead of the shared single mound. Added data-only Hoenn double presentation profiles: opponent176,66 bounds152x40; player61,117(R/S) or61,121(E) bounds160x40. Provider uses double profile only for current doubles context, including nativeMound consumer; singles and native sprites/UI stay unchanged. Unit regression covers all three profiles and additive saved calibration; full unit suite passes. Native27cases (R/S/E x16:9/32:9/9:16; grass day/night +Rustboro indoor) pass active-scene and unchanged UI-trace checks. Reviewed Emeraldgrass16:9, EmeraldRustboro32:9 and RubyRustboro9:16: visible rear opponent feet on shared mound and clear rear boundary; native UI still occludes front feet/parts of player mound. Not full turn/animation/faint/switch/mod-sprite verification. Evidence doubles-grounding-review.json and doubles-native-summary.json. No uploads.

Expanded-sprite doubles depth correction: actual national_dex_gen3+g9-battle-sprites-gen3+gen3-hd-sprites preview showed rear Zigzagoon above visible shared mound despite passing loading checks. Changed Hoenn doubles opponent profile only from176,66/152x40 to176,64/160x48, preserving single defaults/player profile/native sprite and UI transforms. Updated exact grounding regression bounds/offset expectations; full unit suite passes. Reran27native R/S/E cases plus12National/G9/HD Emerald and12 1025Dex Emerald cases (51total) at16:9/32:9/9:16, grass day/night+Rustboro and added PECHARUNT where relevant. All load/UI trace and real added-sprite visibility checks pass. Visually reviewed corrected Nationalgrass,1025grass/Pecharunt and nativeEmeraldRustboro16:9; rear visible feet now over shared mound. Archived immutable reviewed captures and summaries under docs/evidence/rse/reviewed/doubles-depth-v2; report expanded-sprite-doubles-review.json. Previous doubles capture hashes refer to prior profile and are historical. Other low-boundary interiors now require doubles-specific visual review; no all-family/doubles gameplay/animation certification. No uploads.

32:9 doubles interior correction: current deeper doubles pad exposed wall/cabinet overlap in Fortree, Dewford and Weather Institute; Champion replacement already clears. Generated original replacement art with built-in imagegen, preserving original and previous art/metadata/prompts. Weather first retry rejected for low floor/ocean view and retained under drafts; second no-window lab accepted. Approved excess-canvas crops: Fortree[0,40,2172,651],Dewford[0,20,2172,631],Weather[0,0,2098,590], no resampling. Updated canonical source references, dimensions, hashes and rear-boundary metadata; rebuilt plan/catalog. Source audit684records/73families657compositions,0missing/unbound/integrityerrors. Reviewed all replacement sources and three nativeEmerald32:9 doubles captures, plus NationalFortree and1025Weather: pads entirely on foreground floor. Native R/S/E12single+12double, NationalEmerald4 and1025Emerald4cases pass (32total); full unit suite passes. Other render combinations have loading/trace evidence only. Archived immutable five reviewed captures+summaries in reviewed/interior-32x9-floor-v2; report interior-doubles-floor-corrections.json. No UI/sprite positioning changes or uploads. Broader contexts and actual battle sequences remain pending.

Mt Pyre summit first-pass: native three-game summit encounter/event evidence assigned separate mt_pyre_summit family; exterior slope/interior remain separate. Generated complete18source batch (9aspects xday/night) with built-in imagegen before reviewing any. All18 originals visually reviewed, no creatures/UI/baked mounds.32:9 approved excess-canvas crops day[0,70,2160,678],night[0,100,2172,711], originals/prompts retained.4:3night native mound intersected memorial row, replaced with original floor-fix-v2 unchanged, previous art/metadata/prompt retained. Candidate catalog74families666compositions; source702records,0missing/unbound/integrityerrors. Initial Emerald9-aspect doubles18loading cases passed, then current R/S/E four-size doubles24cases passed after4:3fix. These are scoped fixture checks, not exhaustive visuals. Reviewed current Ruby4:3night, Emerald16:10night/21:9night/32:9day+night; rear boundary clearance good in named captures. Remaining: night grass mound too blue/saturated versus summit ground, material rebind/replacement required before release; other visuals/sprite/battle sequences pending. Also fixed Hoenn field-weather forwarding: saved resolved field weather wins over translated map header; climate gets mapWeather, active battle weather overrides it. Unit regressions cover fog, explicit clear, sandstorm, cycle translation, unchanged session state and indoor suppression; native fixture verifies summit fog then rain override per process. Full unit suite passes. Source checks and native fixture evidence archived under reviewed/mt-pyre-summit-first-pass, report mt-pyre-summit-first-pass-review.json. No uploads or completion claim.

Summit material reuse follow-up: inspected existing original highland day/night mound pair instead of generating redundant assets. Approved rounded12source-pixel perimeter cleanup saved sibling clean-v3 files, originals retained; checked visible RGB identical and alpha only reduced (no recolor/resampling). Both cleaned sources visually reviewed, red/yellow day-edge contamination removed. Rebound only mt_pyre_summit day/night from bright flowering grass to muted earth/sparse-grass highland pair; updated all18authoring material candidates and rebuilt plan/catalog. Source audit still702records/74families666compositions,0integrityerrors/missing/unbound. Full unit suite passes; Emerald8doubles cases at4:3/16:9/32:9/9:16 pass loading/UI trace/weather precedence checks. Visually reviewed4:3night,16:9day,9:16night: material closer to ground, rear boundary clear, native sprites/UI untouched. First-pass blue mound issue superseded in these reviewed samples; broader species/game/battle sequence validation remains pending. Immutable captures archived reviewed/mt-pyre-summit-highland-mounds; report mt-pyre-summit-mound-reuse-review.json, cleanup provenance metadata/rse-summit-mound-reuse.json. No new generation calls or uploads.


Magma Core and latest-runtime follow-up (2026-10-21): native Emerald MagmaHideout_4F encounter/event inventory now selects a dedicated magma_core family; other hideout maps retain their existing environment. Generated the complete nine-aspect ambient batch before source review, retaining exact prompts and originals. Approved excess-canvas crops only for 32:9 and 9:20; no stretching or painted-content edits. Existing warm-basalt mound reused. Candidate coverage now 75 families / 675 compositions / 711 canonical source records, with no missing base aspects or unbound families in the source audit. This remains source coverage, not release certification.

Verified official v0.3.95 runtime asset against its published SHA-256 and migrated the isolated Hoenn probe to version-scoped output. Fixed settings mounting for newer native Rows.withCart path, preserving deduplication and older Rows.build support. Full unit suite passes on v0.3.95; Emerald nine-aspect Magma Core doubles fixtures pass native UI trace, menu registration and weather checks. Visually reviewed 16:9, 32:9 and 9:20: opponent mound remains on clear floor, rear Zigzagoon feet meet its surface and rear wall/lava is clear. Immutable captures and scoped report: docs/evidence/rse/magma-core-first-pass-review.json. Old v0.3.89 Emerald single fixture also passes settings registration after the compatibility change. Broader latest-runtime regression, full battle sequences and other sprite/UI combinations remain pending. No uploads.

Latest-runtime interior review: 15 native doubles cases (five corrected interiors across Ruby/Sapphire/Emerald at 5120x1440) passed on v0.3.95. Visual Emerald review accepted Fortree, Dewford, Weather Institute and Champion rear floor clearance. New Mauville remained too tight at the upper mound edge; generated a targeted original reference edit with generators confined to rear strip. Preserved prior painting, metadata and prompt; new sibling doubles-floor-fix-v2 uses approved crop [0,20,2172,631] only, no resampling. Final Emerald native capture visually reviewed: clear concrete separation behind entire opponent mound. Three-game focused rerun and full unit suite passed. Before review archived under reviewed/interior-runtime-0.3.95; accepted replacement proof under reviewed/new-mauville-32x9-floor-v2. Catalog/source integrity remains 75 families, 675 compositions, 711 source records, no reported errors. These scoped checks do not certify every location/species/battle sequence. No GitHub uploads.

Facility floor clearance continuation (v0.3.95): Emerald 13-family doubles batch at 32:9 5120x1440, 4:3 1024x768 and 16:9 1280x720 passed 39 native loading/UI trace/settings/weather checks. Visually reviewed all13 ultrawide captures plus six 4:3 captures (Aqua Hideout, Space Center, Battle Factory, Battle Palace, Petalburg and Mossdeep). In these 19 samples opponent mounds are on floor and rear Zigzagoon feet meet their surface; no additional artwork replacement justified by these samples. This does not approve unviewed 16:9 captures or every aspect/species/context. Exact reviewed captures, SHA-256s and raw per-size reports archived under reviewed/facility-floor-clearance-0.3.95. No production rendering change or upload in this batch.

Native presentation transition harness added (v0.3.95): opt-in --transitions uses real faintMon/sendOutMon APIs and native Task/Anim ticks. It asserts both callbacks complete, faint visibility hides, returned sprite resets Y/scale, scenery retains composition, and disabled/enabled draws preserve native chrome traces and target presentation. Ball-open palette effects are allowed 40 extra native ticks beyond body completion. Final uniform harness revision passed nine doubles processes across R/S/E x16:9/32:9/9:16: 72 presentation checkpoints plus18day/night scenery cases. Emerald16:9 six transition stages visually reviewed. Archives/raw per-process checks/harness hash: reviewed/native-transitions-0.3.95. This does NOT cover actual battle turns, switching mechanics, move scripts, faint outcomes or native healthbox restoration by full switch flow; those remain pending. No production change, save writes or uploads.

Native move-effect presentation probe added: --move-effects resolves actual ROM-backed Tackle, Water Gun, Thunderbolt, Surf and Earthquake scripts and runs native VM+Task ticks. Initial smoke exposed VM headless mode left enabled by scene setup; rejected the one-frame result, explicitly enabled VM animation and required active launch plus multi-frame progression. Corrected Emerald single smoke completed 25/121/235/136/198 frames respectively. Final nine-process R/S/E doubles batch x16:9/32:9/9:16 executed 45 native scripts with 126 disabled/enabled presentation+chrome draw checkpoints and18day/night source cases, all passing. Five Emerald single and one ultrawide doubles effect/end captures visually reviewed and archived with raw reports and harness hash under reviewed/native-move-effects-0.3.95. This is native animation-script coverage only, not actual battle turns, damage, switching mechanics, full outcomes or all move/mod combinations. No production changes or uploads.

Native full battle-flow fixture added: --battle-flow starts non-headless native autoFight trainer battle against three low-level foes, advances native Task/Battle/Message/UI ticks, requires real damage, opponent replacement, animation VM frames and final win. Native CacheFs fixture gained loadActive matching real Lua cache loading for dialogue chrome. Emerald single smoke:6turns/1617frames/538animation frames; action/award/ending captures reviewed. Nine R/S/E doubles processes x16:9/32:9/9:16 all reached win with phase-level native UI trace invariance. Archived per-process actual flow evidence under reviewed/native-battle-flow-0.3.95. Expanded combinations did NOT pass: National/G9/HD stops at native mon-animation wait after Task reports missing nil animation function;1025Dex1.5.1 fails native registry with item913/move709 collisions on v0.3.95. Latest1025release tag verified1.5.1. Causes remain unisolated; static prior-version compatibility is not sufficient latest-runtime proof. Error logs retained, runner now retains process output on failures. These failures do not justify a compatibility claim or release. No production change, real-save writes or uploads. Voluntary player switch/user-input and broader battle scenarios remain pending.

1025Dex asset prerequisite follow-up: user correctly requested verification of asset-manager installation. Existing isolated artwork had no manager completion receipt, despite an earlier file verification. Freshly hashed all23,109 files (218,381,564 bytes) against 1.5.1 catalog: zero missing/mismatched files. Added opt-in --prepare-dex-assets helper using the actual published manager's catalog-verified local migration, with embedded UI disabled only in preparation; original downloaded bytes reused unchanged and isolated completion/index/metadata receipts written. Actual1025Dex manager after entry execution reports manager_present=true, complete=true, label=READY, recorded BEFORE content validation rollback clears exports. Collision item913/move709 still reproduced with READY assets. Thus asset absence is ruled out for this isolated retry, but no network/UI-download or successful compatibility claim. Reports:1025dex-assets-fresh-verification.json,1025dex-real-manager-preparation.json,1025dex-loaded-manager-readiness.json. Native-error/process logs retained. Initial post-rollback missing-manager observation superseded by pre-validation observation. Investigation:1025Dex mutates native modern move names/item rows during registration, possible self-collision with newer validator; not yet proven/fixed. National/G9 intro failure narrowed to form slot1206 selected by post-mod ZIGZAGOON name lookup and missing native front animation, not native Poochyena286. Causes/fixes remain pending. No uploads or user-cache writes.

1025Dex registration cause isolated and local fix staged in tracked .work/1025dex-double-fix (published extraction untouched): compatibility code filled native move/item arrays during registration, before v0.3.95 assigned slot ownership; modern native move IDs such as AERIALACE also claimed AERIAL_ACE's existing slot. Candidate defers compatibility table fills until mods.loaded, preserves reload restoration thereafter, and normalizes only native move registry calls to their existing native identity while preserving modern lookup/API IDs and caller records. Apples remain1001/1002; National compatibility aliases unchanged. New tests/gen3_registration_order.lua verifies pre/post-commit timing, native move reuse, modern lookup, immutable input and saved item IDs. Nine R/S/E x16:9/32:9/9:16 native doubles trainer battles all reach win with actual animation VM frames;27scene/added-art/species-chooser checks pass. Real1025manager remainsREADY; native index failure report nowempty. Two Emerald16:9 captures visually reviewed, realPecharunt art visible. Proof, exact source hashes and candidate patch archived reviewed/1025-registration-fix-0.3.95. This supersedes prior1025load failure only for patched local source. No release/version bump/publication; FRLG, older runtimes and broader mechanics regression remain pending. National/G9 form intro issue still pending.

1025Dex hotfix finalized separately under standing mod-release authorization: FR/LG latest-runtime fixtures exposed missing Fairy registry declaration and native move aliases retained in learnset/TM references. Explicit Fairy index18 registration and immutable native-reference conversion added; regression expanded. Current source passes3Hoenn16:9 doubles flows plus6FR/LG singles flows across16:9/32:9(5120x1440)/9:16,81scene cases, real asset managerREADY and1,389species/form chooser. All483Lua files compile inLuaJIT/Lua5.3. Release1.5.2 source committed/pushed to9c9d56c5d623694df4d930a6eff746b2717cde5b, latest release verified with ZIP8,275,177bytes SHA256a31f5a61310251c3fb0962d2341388d13a29ad3d2f6610aeb9c45c6119175af2 matchingGitHubdigest; checksumasset also uploaded. Archive preserved603baseline entries byte-for-byte, changed onlyfiveexisting files andaddedregression/proof. GitHubfirstcreate rejected shorttargetSHA, retried fullverifiedSHA successfully. URL https://github.com/Bentley734/1025Dex/releases/tag/1.5.2 . Proof1025dex-1.5.2-release-verification.json. No HD Battlefields code/art pushed or released. National/G9 form intro issue and broader HD release gates remain pending.

Current National/G9 compatibility follow-up: official latest releases checked; downloaded National1.2.0 and G91.5.4 into isolated suite, verifying National published checksum and G9 GitHub digest. HD library0.4.5 remainslatest and reused. Corrected Hoenn fixture startup to applyMerged, Pokemon.install and game.ready like native runtime; oldNational1.1.3 still stalled under corrected startup, current1.2.0/G91.5.4 completes. No third-party source changes. Nine R/S/E doubles flows x16:9/32:9/9:16 plus FR/LG16:9 singles complete; chooser includes all1,155species/forms. Current-version proof supersedes older-version intro failure for these scoped cases. Latest1025Dex1.5.2 also passes Emerald flow after corrected startup.

HD mound follow-up: library documents playerRaise separately from pad drop. Scenery adapter now follows dropPlayer-raisePlayer for player mound; keeps trainer tagging and native sprite/UI behavior. Measured actual Emerald single raisePlayer1.6339042834/dropPlayer0 verifies nonzero correction path. Emerald three-shape doubles and16:9single, Ruby/Sapphire16:9doubles and FR/LG16:9singles pass after correction, with full unit suite. Reviewed Emerald current-suite real art/flow samples; not every species/form or battle type. Versioned raw reports, source hash and download provenance archived reviewed/national-current-suite-0.3.95 and national-suite-latest-2026-10-21.json. Probe defaults now current verified suite/1025Dex1.5.2; historical files retained. No HD Battlefields uploads. Wider layouts/contexts, WildFollowers, UI profiles, manual switch, performance/tiers/release remain pending.

### Current Menu Customizer and WildFollowers compatibility fixtures

Verified Menu Customizer 3.35.15 remains the latest published release. Nine native 0.3.95 automatic trainer battles across Ruby/Sapphire/Emerald at 1280x720, 5120x1440 and 900x1600 completed with that mod loaded; 90 source-scene comparisons preserved native UI transforms. Default fixture configuration only: no exhaustive custom UI profile or visual certification.

The local WildFollowers 2.22.17 copy was stale. Downloaded the unmodified published 3.4.5 archive and verified its GitHub SHA-256 digest (see wildfollowers-release-fixture.json). Added opt-in source roots, real-loader enablement and separate output paths to the native RSE runner. Initial Emerald 16:9 automatic trainer battle completed with both WildFollowers and Menu Customizer loaded. Broader combined batch is pending; overworld follower behavior remains unverified. No HD assets or source were pushed.

Combined batch completed: all nine Ruby/Sapphire/Emerald x widescreen/5120x1440/portrait processes won their native automatic trainer battles, with WildFollowers 3.4.5 and Menu Customizer 3.35.15 both loaded. All 90 source-scene UI-transform comparisons passed. Raw per-game reports under docs/evidence/rse/loader/menu-customizer/runtime-v0.3.95/wildfollowers/battle-flow. This supersedes the pending-batch note above; custom UI profiles, visual grounding and overworld behavior remain outside this check.

### Map lifecycle battle coverage correction

Extended native encounter/event inspection to read compiled map lifecycle roots from scripts/events.lua and follow their battle operations through the existing script graph. Runtime version now comes from actual Version.lua (0.3.95), and events.lua is included in provenance hashes. This found Emerald Mossdeep Space Center 2F missing from the prior object-only inventory; it now selects the authored space_center family. Rebuilt plan/map/catalog: 479 map signatures (Ruby 142, Sapphire 142, Emerald 195), still 75 families/675 compositions with no unclassified battle maps. Native four-battler scene checks for both Space Center floors passed at 1280x720, 5120x1440 and 900x1600; evidence archived under reviewed/space-center-map-lifecycle-0.3.95. This is script reachability and rendering evidence, not a completed story-event playthrough. Dynamic specials/generated facilities still need separate evidence.

### Local Hoenn source-pack preparation

Added metadata/distribution_hoenn.lua as an author-time candidate union. Kept metadata/distribution.lua independent because the Hoenn authoring builder consumes its Gen1/Gen2 reuse catalog; this avoids a circular generator dependency. The new union rejects conflicting duplicate composition IDs or metadata rather than silently selecting one.

Prepared source descriptors locally for candidate 0.3.0-beta.1 using build_source_asset_packs.py --catalog metadata/distribution_hoenn.lua, without a source commit or upload. Eighteen HD pack catalogs cover nine aspect families x compact/full options, retaining all 1110 previous composition IDs and adding Hoenn for a deduplicated 1686-composition union. Every size/profile contains all 75 Hoenn families, compact catalogs contain exactly one variation per unique environment, and metadata inheritance references are closed within each catalog. Source inventory: 2335 distinct files, 6387513311 bytes; shared art remains referenced rather than copied into duplicate source folders. See docs/evidence/rse/hoenn-source-pack-candidate.json.

These are unpinned local candidates, not a published update or working new download index. Mobile/Ultra-HD tier content, source commit pinning, remote checks, remaining visual/compatibility gates and base packaging remain unfinished. No HD GitHub uploads occurred.

### GPU graphics-mode resize regression gate

Added opt-in --resize runner and resize.lua fixture: same battle through seven actual desktop graphics-mode sizes (16:9, 5120x1440, portrait, landscape, tall portrait, 4:3, return), with native UI transforms, composition/metadata viewport changes, battle identity/HP and provider-picture alpha checks. Ruby/Sapphire/Emerald doubles pass 21 resize checkpoints with vanilla sprites. Inspected initial Emerald single captures at ultrawide, tall portrait and return-to-widescreen. No production UI or sprite code changed.

The first National/G9/HD-library trial exposed invisible sprites despite passing layout assertions. Added mandatory nontransparent sprite checks and invalidated its earlier success records. Current National Dex 1.2.0 / G9 sprites 1.5.4 / HD library 0.4.5 now correctly fails after love.window.updateMode: cached provider artwork is transparent after graphics-mode recreation. Baseline sprite alpha passes before the mode change. This does not yet establish whether ordinary user dragging or mobile rotation reproduces it; do not claim native-resize compatibility. Earlier combined 1025/WildFollowers/Menu graphics-mode output predates alpha gating and also needs rerun. Native mode-change behavior and third-party cache recovery require further investigation.

The runner now removes obsolete per-case and summary success records before a rerun, preventing an earlier green report from surviving a later failure. Failed-process logs are retained. No GitHub upload.

### User-requested doubles footing and downloader cleanup

Raised the shared Hoenn opponent doubles mound two native pixels (y64 -> y62), retaining its 160x48 coverage and all single/player defaults. Sprites/UI untouched. Native Emerald National/G9 doubles trainer flows passed at widescreen, 5120x1440 and portrait; inspected the 16:9 actions frame for rear-slot Zigzagoon foot contact. Ruby/Sapphire vanilla doubles trainer flows also passed. Corrected the battle-flow observer to track damage/replacement in both enemy slots: tracking only state.enemy could miss slot 3 replacement despite a real completed win.

Asset downloader: informational rows now have inert activation because Gen1/2 Options treats A on a row without activate/step as Back. Renamed filters to SCREEN SIZE and VARIATIONS, downloading choices to DOWNLOAD SELECTED SIZE / DOWNLOAD ALL SIZES; hid unpublished texture tiers, removed redundant recommendation, and grouped status/error/cancel and maintenance tools. Automatic size also works before opening a battle by reading window dimensions. Per-action result messages are no longer shared across unrelated actions. Native Emerald menu navigation with Menu Customizer/WildFollowers confirms choices return to downloader and informational status selections stay put; unit suite passes. No downloads or uploads initiated by menu tests. Evidence: reviewed/doubles-footing-downloader-cleanup.

### Separate existing-window resize from mode recreation

Added a trusted standalone test-host SDL window-size helper, initialized before mod loading and never exposed through mod APIs. --resize-method desktop changes the existing window and handles normal resize events without changing graphics mode. This gives separate resize-desktop evidence, preserving the prior graphics-mode failure evidence. National Dex 1.2.0 / G9 1.5.4 / HD library 0.4.5 doubles pass seven window sizes in each of Ruby/Sapphire/Emerald (21 checkpoints); same battle/UI transforms retained and sprite provider art nontransparent. Inspected Emerald ultrawide/tall portrait captures with all four sprites visible and raised mound geometry.

1025Dex alpha probe needs a different visibility method: it fails on Torchic raw picture data before any resize, while the actual baseline capture visibly draws Torchic. Do not interpret that failure as evidence of a real 1025Dex resizing bug or claim combined resize compatibility. Graphics-mode recreation still clears current G9 art; mobile OS orientation remains untested. Reviewed evidence under reviewed/desktop-window-resize. No production rendering or third-party files changed and no upload.

### 1025Dex resize visibility probe corrected

Inspected actual sprite-provider code: 1025Dex builds battle and non-battle preview sheets separately/asynchronously. The alpha helper was requesting a fresh Torchic preview after rendering battle art, then reading its pending transparent image immediately. Added real core.update warm-up after requesting that preview, retaining the alpha assertion. No production or third-party sprite code changed.

1025Dex 1.5.2 plus WildFollowers 3.4.5 and Menu Customizer 3.35.15 now pass existing-window resize in all three Hoenn games: 21 checkpoints, same native battle, nontransparent provider art, correct aspect metadata and unchanged native UI transforms. Downloader native navigation checks also pass in these processes. Inspected standalone 1025Dex Emerald ultrawide/tall portrait scene captures: all four sprites visible. Supersedes the earlier pending 1025 visibility-probe note, not the separate G9 graphics-mode recreation failure. Evidence in reviewed/1025-desktop-resize. Mobile rotation still untested; no upload.

### Water-islet size and surface-centering correction

Added metadata/mound_materials.lua with Hoenn-only per-asset rules, consumed by both final native blit and HD-library mound paths through Grounding.apply. Islets use 1.6x uniform coverage and painted-surface origins (grass/sand .58, rock .66), compensating transparent canvas padding without stretching the artwork. User then requested lower placement; applied +3 native-pixel Y to both sides while keeping coverage. User adjustments remain additive and all sprite/UI coordinates unchanged. Full unit suite and 12 native Emerald water-family/day-night scene checks at widescreen/portrait pass. Inspected full-size ocean after the final shift. Evidence: reviewed/water-mound-coverage-centering.

For wall overlap, prepared 53 new 32:9 crop-only source siblings with higher floor lines; originals and prior authoring records retained, all pixels unresampled. Rebuilt catalog and authoring audit passes all 711 sources. Focused 14 ultrawide scene checks passed; inspected Battle Palace/Meteor Falls floor clearance and larger ocean islet. Larger post-crop batch terminated without a Lua diagnostic before completing; do not count that as validation of all 53 crops. It requires smaller batches and further visual review. Pending source-pack candidate catalogs must be regenerated after these artwork changes; none published.

### Full revised-ultrawide source validation batch

Added run_rse_horizon_review.py to run revised families in fresh bounded native GPU processes, archive each raw report/capture before the next batch, require coverage of every revised source metadata ID, and create diagnostic sheets without touching artwork. Six batches completed successfully: 65 native scene comparisons covering all 53 revised source records, Emerald vanilla doubles at 5120x1440. All eight diagnostic sheets reviewed for broad floor/mound clearance; no wall or distant-horizon overlap observed. Full-size Battle Palace and Meteor Falls had also been inspected. This replaces the incomplete large-batch status for revised-source coverage; it does not certify every map/species/other aspect. Current water material +3px offset included in these runs. No upload.

### Shared-texture reuse and installed material identity

Found that installed catalogs namespace mound texture paths; the new raw-path material table would therefore fail to apply to downloaded islets. Asset library now preserves canonical source identities alongside cache paths and clears old mappings on pack/version refresh. Scene resolves mound identities once during preparation; both native and HD-library grounding consume those canonical paths. Tests cover original identity, new pack versions and refresh invalidation.

Scene transitions now reuse unchanged active textures, load only new paths, release textures no longer needed on successful commit, and release only newly owned textures on failure. No growing historical cache is retained. Added ownership/failed-transition tests, including shared mound reuse and canonical identity resolution. Full unit suite passes; 14 native Emerald National/G9 water-family scene checks across widescreen and 5120x1440 pass. No Android speed claim or complete remote download claim. Evidence: reviewed/texture-reuse-material-identity. No upload.

### Real installed-pack native water verification

Added opt-in isolated installed-pack fixture support to the native runner. prepare_rse_installed_pack_fixture.py creates a small 16:9 ocean day/night pack from current source bytes, then uses the existing offline importer to stage its actual SHA256-protected objects and commit slots. Cache root is .work/hdb-pack/mod_cache/hd-dynamic-battlefields; original deeper fixture path exceeded Windows io.open path limits for one 264-character file and was shortened (not a corrupt asset). No real user cache changed.

Real Loader/ImportAccess/PackStore verifies and loads the pack. Fixture hides only bundled ocean backgrounds to require installed selection; assertions require the installed pack ID, health, mound scale/origin and y65 in doubles. Six installed day/night cases pass across Ruby/Sapphire/Emerald with current National/G9/HD library; native UI transforms unchanged. Inspected full-size installed Emerald ocean day capture. Actual offline installation/rendering now supplements the unit identity test. HTTP download and every pack/aspect remain separate gates. Evidence: reviewed/installed-water-pack. No upload.


### Current local package and full-resolution milestone

The latest user-requested water correction is +6 native pixels total (another +3 after the first review), uniformly retaining scale 1.6 and painted origins. Seven focused Emerald water scenes passed; the rebuilt base archive was then exercised against the isolated real ocean pack in R/S/E, with all six installed day/night checks asserting doubles mound y68. Earlier +3/y65 reports remain historical evidence only. Current evidence: reviewed/water-offset-6px and reviewed/full-resolution-base-v2.

The base builder now uses explicit shipping boundaries: runtime Lua, manifest, selected user guides, offline importer and four fallback PNGs. Authoring records, draft art, evidence and pack catalogs stay out of the base ZIP. The latest local archive is 10,081,825 bytes, SHA256 86e8d16c17a5054dd20fa378fb0caa4dce270b6a8c5960c77b2bf748101ba197. It still uses the old release manifest; it is not a published Hoenn beta.

All 18 candidate source catalogs pass actual runtime schema/compatibility/PNG-header/geometry validation. This does not validate remote source pinning or file hashes; local placeholder URLs in that validator are explicitly schema-only. A separate real HTTP test downloaded and verified all 95 files (226,660,999 bytes) of a historical published pack through runtime 0.3.95 in an isolated memory cache. Unit recovery tests now cover multi-file process restart, verified-object reuse, corrupt staged-object repair and previous-version retention. New Hoenn pack HTTP verification remains pending until publication.

User chose full-resolution assets only for now. No Mobile downsampling was performed; display offers Original HD only. Compact/full remain variation-count choices. Missing quality/size diagnostics now identify the unavailable tier and an actionable alternative without silently loading a heavier tier.

Current Emerald widescreen/portrait doubles rerun passed 204 native scene comparisons. Six widescreen risk scenes were visually reviewed; the remaining captures are not automatically visually certified. Evidence: reviewed/current-wide-portrait-doubles. That batch preceded the final extra water offset; focused and installed-pack checks above cover that correction.
