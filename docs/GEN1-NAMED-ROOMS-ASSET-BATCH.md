# Bill's cottage, Bike Shop and club rooms

Original built-in image generation, 2026-10-16. Twelve original 16:9 paintings are saved unchanged in `art/source/`; exact same-stem prompts are saved in `art/prompts/`.

| Category | Image stems | Scene variations |
|---|---|---|
| bills_cottage | bills_cottage-01-16x9 through bills_cottage-03-16x9 | Paired separator booths / study laboratory / compact equipment room |
| bike_shop | bike_shop-01-16x9 through bike_shop-03-16x9 | Blue display counter / repair alcove / sage showroom |
| fan_club | fan_club-01-16x9 through fan_club-03-16x9 | Burgundy chairman lounge / sage reading lounge / blue reception room |
| meeting_room | meeting_room-01-16x9 through meeting_room-03-16x9 | Administrative desk / planning office / consultation hall |

All twelve source paintings were visually inspected and registered locally as `{environment}-room-{1,2,3}-16x9`. Each has its own perspective metadata, floor material and source-reviewed horizon value. Bill's cottage and the Bike Shop have authored exact-16:9 source insets to raise their rear fixture boundaries; meeting room variations 1 and 2 also have modest insets. These are static framing drafts rather than verified native calibration.

Existing exact maps now select the named categories while retaining their original tileset guards:

- `BILLS_HOUSE`, `INTERIOR` → `bills_cottage`
- `BIKE_SHOP`, `CLUB` → `bike_shop`
- `POKEMON_FAN_CLUB`, `INTERIOR` → `fan_club`
- `FUCHSIA_MEETING_ROOM`, `LAB` → `meeting_room`

These locations no longer depend on the unregistered generic `interior` category. Manual environment choices identify each room separately. Constant enclosed lighting is explicitly configured; outdoor weather and time-of-day tint do not apply. Independent gray, sage, beige and blue/burgundy carpet decals are reused according to the painted ground.

The v0.3.88 story sources describe Bill's cell separator, the Bike Shop voucher exchange and the Fan Club chairman's voucher conversation. Artwork includes only room equipment and decor, never Bill, club Pokémon, people, story effects or UI. These sources establish special/story room context; they do not prove ordinary native trainer battles in these rooms. No floor tile grids, wooden floor planks, geometric rugs, baked-in mounds or fighting platforms are present.

Current state: twelve sources saved and local map/category/catalog integration complete for this widescreen batch. Other aspect families, blending, native grounding, source framing and compatibility checks remain pending in the deferred combined release batch. No tests, packages, live-game changes or publication were performed.
