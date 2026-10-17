# Gen 1 town and League source batch

Original built-in image generation work, 2026-10-15/16. Selected untouched paintings are saved under `art/source/`, with exact same-stem prompts under `art/prompts/`. No third-party artwork, runtime recoloring, test run, packaging or publication is part of this batch.

| Environment | Variation 1 | Variation 2 | Variation 3 | Map |
|---|---|---|---|---|
| league_exterior | League front courtyard | Side courtyard and mountain vista | Sheltered ceremonial terrace | INDIGO_PLATEAU |
| league_approach | High plateau checkpoint | Wooded badge-check meadow | Final plateau meadow and distant valley | ROUTE_23 land |
| island_town | Cinnabar town square | Island research quarter | Seafront neighborhood promenade | CINNABAR_ISLAND land |
| harbor_city | Vermilion residential square | Harbor-town green square | Gym neighborhood | VERMILION_CITY land |

File pattern: `ENVIRONMENT-0N-16x9.png` and `ENVIRONMENT-0N-16x9-night.png`. Architecture, fences, hills and water remain behind clear standing regions. Paved surfaces have smooth nondirectional texture, with no tile grid, floorboards or paving seams. No mounds or platforms are painted into these backgrounds.

## Routing refinement

The Route 23 checkpoint approach is distinct from the paved League courtyard. Its map entry now uses `league_approach`, while Indigo Plateau retains `league_exterior`. Both are outdoor environments with separate day/night art.

The inspected official v0.3.88 `data/scripts/flavor/route_23.lua` contains the swimming Marsh/Soul badge guards. Route 23 previously had no water classification; its entry now explicitly maps water encounters to the existing inland pond environment. Cinnabar and Vermilion retain their existing ocean water entries. Runtime confirmation remains deferred with the rest of Gen 1 testing.

## Current preparation state

All twelve daytime paintings and twelve separately painted night counterparts are saved and visually inspected. The twelve variations are registered locally in the existing catalog with individual horizon metadata and independent selected concrete/asphalt/grass day/night material paths. Manual environment choices now show the actual location names. Registrations alone do not prove runtime readiness. Do not invent new runtime tinting or copy rejected fringe candidates.

Dedicated non-16:9 compositions, material blending, source regions and native grounding still require completion/review. No full map, aspect, platform or mod compatibility claim follows from source-art completion. Preserve the user's battle UI, native sprite positions and Alpha 6 mound dimensions/three-pixel opponent adjustment.

The previously identified fringe on the older gray-floor decal is also cleaned in `mound-floor-gray-01-clean.png`, using the user's authorized perimeter-only process. Existing room/city material references now select that sibling. Original paint and source PNG are retained; an alpha-composited artwork preview is saved in `docs/evidence/gray-floor-edge-cleanup.png`. This is asset preparation and visual inspection, not a runtime test.

The older blue carpet's conspicuous cyan perimeter and burgundy carpet's small edge flecks are likewise removed in `mound-carpet-blue-01-clean.png` (20-source-pixel trim) and `mound-carpet-burgundy-01-clean.png` (12-source-pixel trim). Existing catalog material references select those cleaned siblings. Interior RGB/alpha and original files remain unchanged. The matte-composited visual review is `docs/evidence/carpet-edge-cleanup.png`, with operations recorded in `art/derivatives.json`.
