# S.S. Anne area artwork

Original built-in image generation, 2026-10-16. Twelve new 16:9 source paintings are saved unchanged under `art/source/`, with exact same-stem prompts under `art/prompts/`.

| Area category | Source stems | Variations |
|---|---|---|
| ship_bow | ship_bow-01-16x9, -02-16x9, -03-16x9; each also has -night | Forward sea view / starboard deckhouse view / sheltered foredeck |
| ship_kitchen | ship_kitchen-01-16x9, -02-16x9, -03-16x9 | Cooking galley / scullery and provisions / bakery and serving galley |
| ship_captain | ship_captain-01-16x9, -02-16x9, -03-16x9 | Blue-carpet study / burgundy-carpet lounge / beige chart-room cabin |

All source stems identify `.png` files and matching `.txt` prompts. The bow has separate original day/night paintings. Interiors use constant authored indoor illumination. The deck uses seamless painted marine coating; the indoor floors are softly mottled covering or unpatterned carpet. None has floor tile grids or wooden planks. Mounds, creatures, battle UI and lettering are not baked into the images.

## Explicit selection

- `SS_ANNE_BOW` with its existing `SHIP` tileset guard selects `ship_bow`. It has explicit outdoor climate policy, so the existing system-time/manual period selection can choose its separate night painting. Both sides use independent neutral gray/cool-night floor decals.
- `SS_ANNE_KITCHEN` selects `ship_kitchen`, with beige, gray or ivory independent decals matching its three floor palettes.
- `SS_ANNE_CAPTAINS_ROOM` selects `ship_captain`, with blue carpet, burgundy carpet or beige independent decals.
- Ordinary S.S. Anne halls and passenger cabins retain `ship_interior`; the new categories do not replace every ship scene with the foredeck or kitchen.

Manual environment choices label all three areas separately. Catalog entries carry individual metadata and authored exact-16:9 source regions. Bow periods have separate framing where their painted railing heights differ. Framing remains a calibration draft; it does not move native battlers, resize UI panels or change the Alpha 6 doubled mound dimensions and opponent upward adjustment.

## Native evidence and limits

The inspected official v0.3.88 sources include `data/scripts/flavor/ss_anne_kitchen.lua` for kitchen conversations and `data/scripts/story.lua` for the captain's HM01/story sequence. These are special room contexts and must not be presented as proof of ordinary trainer battles in those rooms. Existing map IDs and tileset guards are retained; only the scenery category is refined.

Current state: twelve images visually inspected and saved, nine local compositions registered, explicit map categories and climate policy updated. Other aspect families, source framing, material blending and native/UI compatibility still need the deferred combined validation batch. No tests, builds, live-game changes or publication were performed.
