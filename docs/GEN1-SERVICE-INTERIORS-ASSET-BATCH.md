# Pokémon Center and supply shop artwork

Generated with the built-in image tool on 2026-10-16. Six original 16:9 paintings are saved unchanged in `art/source/`; each exact prompt is saved in `art/prompts/` using its image stem.

| Category | Source images | Variations and floor materials |
|---|---|---|
| pokemon_center | pokemon_center-01-16x9.png through -03-16x9.png | Small-town healing reception, ivory / urban reception, gray / roadside rest lounge, sage |
| shop | shop-01-16x9.png through -03-16x9.png | Blue supply counter, gray / green neighborhood store, sage / warm cream general store, beige |

All six are registered as `{environment}-room-{1,2,3}-16x9`, with inherited perspective metadata, individual horizon values and authored exact-16:9 source regions where the rear fixture boundary needed raising. Floors are continuous and non-directional; no tile grids, wood planks, geometric carpet patterns, battle mounds, creatures or UI are baked into the images.

Independent matching ivory/gray/sage/beige floor decals are reused. These are enclosed interiors with explicit constant interior climate policy. No outdoor weather or day/night tint is applied. Existing exact map/tileset classifications select the two categories; remaining overly generic subtypes are tracked separately in `GEN1-LOCATION-SUBTYPES.md` and must still be refined. In particular the League lobby needs its own appropriate reception context, not a claim that an ordinary mart is a final match.

This is scenery coverage for service interiors and manual/special battle contexts. It does not establish that ordinary native trainer battles occur inside Pokémon Centers or shops. Native behavior, source framing, texture blending and compatibility remain untested pending the combined release batch.

Current state: six source images inspected and saved, local catalog entries and manual labels added. Other aspect families, subtype refinements and native validation remain required. No tests, packages, live-game changes or releases were made.
