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

These checks use direct mod entry into the real engine, not the real mod
Loader/Sandbox. They do not validate UI-mod profiles, sprite-mod combinations,
double battles, animations, every species or the other ten candidate families.
The cleaned mound palette/texture also needs broader visual review. No Hoenn
release has been published from this development stage.
