# Gen 1 legendary encounter artwork

Original built-in image generation work, 2026-10-16. Twelve 16:9 environment paintings are saved, with three distinct compositions for each of the four native legendary encounter locations. Selected raw outputs are copied unchanged into `art/source/`; exact same-stem prompts are saved in `art/prompts/`. No creatures, sprites, mounds, UI or symbols are baked into the artwork.

| Category | Native encounter context | Saved scene variations |
|---|---|---|
| legendary_mewtwo | MEWTWO, CERULEAN_CAVE_B1F, wild | Mineral vault / limestone colonnade / deepest natural grotto |
| legendary_articuno | ARTICUNO, SEAFOAM_ISLANDS_B4F, wild | Cold coastal cavern refuge / frost-rimmed limestone columns / remote sea chamber |
| legendary_zapdos | ZAPDOS, POWER_PLANT, wild | Generator chamber / secluded control hall / high-voltage coil gallery |
| legendary_moltres | MOLTRES, VICTORY_ROAD_2F, wild | Sandstone refuge / tall natural colonnade / basalt shelter |

The official v0.3.88 flavor scripts for Cerulean Cave B1F, Seafoam B4F, Power Plant and Victory Road 2F explicitly start the corresponding static wild battles. The existing detector already uses both the exact map and enemy species; general encounters keep their general environment category.

All four locations are enclosed interiors. They use constant authored underground/artificial illumination and explicit indoor climate policy, without outdoor weather or a runtime day/night tint. Moltres's Gen 1 scene is Victory Road, not an invented open lava field. Articuno's Seafoam scene is a cold coastal cavern, not a snowy outdoor environment.

All twelve source paintings have been visually inspected and registered locally as `{environment}-room-{1,2,3}-16x9`, with separate composition metadata and individually authored horizon values. Source filenames are `{environment}-0{1,2,3}-16x9.png`. Native map/species selection already names these exact environment categories. Manual labels identify each encounter chamber clearly.

Generator hall variations 1 and 3 use modest authored exact-16:9 source regions to raise their far floor boundary above the opponent standing area. Original source paintings remain unchanged. These framing drafts require native validation with the rest of the Gen 1 batch.

Three new independent, seamless natural floor materials are saved: `mound-cave-violet-01`, `mound-cave-pale-limestone-01`, and `mound-cave-warm-basalt-01`. Under the user's explicit local edge-cleaning authorization, selected siblings use `-clean.png`; raw generator files remain untouched. Outer trims are 12, 24 and 12 source pixels respectively, with nearest retained paint extended into the filtered edge. See `art/derivatives.json` and `docs/evidence/legendary-mound-edge-cleanup.png` for provenance and a matte-composited before/after preview. This is artwork preparation, not runtime testing.

Mewtwo uses the violet cave material; Articuno uses the pale dry limestone. Zapdos uses the selected gray/charcoal seamless indoor materials. Moltres's first two sandstone scenes use sandstone and the third basalt shelter uses the warm basalt material. Both battle sides reference independent decals, with the Alpha 6 native mound dimensions and three-pixel enemy upward adjustment preserved.

Current state: artwork and local catalog registration complete for this widescreen batch. Dedicated non-widescreen counterparts, native grounding/blending calibration and the deferred Gen 1 validation batch remain required. No test or release has been run for this batch, and no runtime or compatibility success is claimed.

## Safari eligibility correction

Static source inspection also found that the provider still discarded all `battle.safari` contexts from the early prototype. That exclusion is removed: the native Safari battle metatable can now reach existing map classification and scenery preparation. Demo battles remain excluded. This mod still passes no sprite callbacks to its scene renderer and does not take ownership of Safari UI, controls or counters. Safari runtime/compatibility coverage must be checked in the deferred combined batch; this code change is not a test result.
