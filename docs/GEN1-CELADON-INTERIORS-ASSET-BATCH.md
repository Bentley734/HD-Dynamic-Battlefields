# Celadon hotel, diner and Game Corner artwork

Original built-in image generation, 2026-10-16. Exact same-stem prompts are saved under `art/prompts/`, and untouched original generator outputs are copied to `art/source/`.

## Saved and locally registered

| Category | Source stems | Variations |
|---|---|---|
| hotel | hotel-01-16x9 through hotel-03-16x9 | Blue-carpet reception / burgundy guest lounge / beige side reception |
| restaurant | restaurant-01-16x9 through restaurant-03-16x9 | Warm diner counter / sage dining room / ivory counter hall |
| prize_room | prize_room-01-16x9 through prize_room-03-16x9 | Blue-trimmed redemption windows / warm exchange hall / sage waiting gallery |

These nine 16:9 paintings have local catalog entries with matching independent gray/sage/beige/ivory or carpet materials, individual horizon metadata and authored uniform source framing where required. They use constant interior climate. Floors are seamless and non-directional, and no battle mounds, UI or living figures are baked into the scenery.

The existing `CELADON_HOTEL` and `CELADON_DINER` map guards retain their categories. `GAME_CORNER_PRIZE_ROOM` now uses `prize_room`, separate from the gaming floor's `arcade` classification. Native v0.3.88 `data/scripts/story3.lua` defines three prize-counter background-event vendors here. `story5.lua` defines the Coin Case gift/conversation in the diner. These are special/service contexts, not evidence of ordinary trainer battles in each room.

## Game Corner gaming floor

The first three `arcade-0N-16x9.png` outputs used videogame cabinets. Targeted built-in image edits saved as `arcade-0N-16x9-v2.png` replace those with mechanical reel/lever machines, preserving the room's original open floor and composition. All three corrected sources have been visually inspected and registered, using blue carpet, burgundy carpet and charcoal independent materials. The videogame-cabinet studies remain saved but unselected. Exact edit prompts and original-to-edit provenance are preserved. Native `story3.lua` explicitly calls `ow:engageTrainer` for the poster-guarding Rocket on `GAME_CORNER`; this is an actual native trainer-battle context.

All other aspect families, native grounding, source-region review, material blending and compatibility checks remain pending in the combined release batch. No tests, packages, live-game changes or publication were performed.
