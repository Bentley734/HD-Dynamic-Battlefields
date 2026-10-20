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
