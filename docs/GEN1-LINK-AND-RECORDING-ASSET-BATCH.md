# Colosseum, communication and recording-room artwork

Original built-in image generation, 2026-10-16. Exact prompts are saved under `art/prompts/`, with untouched generated PNGs under `art/source/` using matching stems.

| Category | Source stems | Variations |
|---|---|---|
| arena | arena-01-16x9 through arena-03-16x9 | Blue viewing balcony / cream hall with red benches / sage practice room |
| link_room | link_room-01-16x9 through link_room-03-16x9 | Trade terminals / reception lounge / sage exchange counter |
| hall_of_fame | hall_of_fame-01-16x9 through hall_of_fame-03-16x9 | Registration chamber / blue archive room / burgundy recording room |

All nine source paintings have been saved, visually inspected and registered locally as `{environment}-room-{1,2,3}-16x9`. Exact map guards retain their separate categories. The blue Hall of Fame archive room, first Colosseum and first communication room use modest authored uniform source insets; the other paintings use their full frame.

Each category has explicit constant interior climate. Existing exact `COLOSSEUM`, `TRADE_CENTER` and `UNION_ROOM` map guards remain intact. General communication scenes include trade/reception contexts, not fabricated native trainer battles. Actual link-battle map/scene selection remains an explicit runtime validation item: link transport messages alone do not prove that a battle renders with the expected map ID.

Native v0.3.88 `data/scripts/story.lua` defines the Hall of Fame's registration machine and induction story sequence. Its backdrop is recording-room/manual coverage, not evidence of a native battle there. Rendering it must not change or replace that story UI.

The floor planes are seamless with no tile grids, hardwood planks, sport court lines, floor emblems or raised fighting platforms. No living battlers, UI or baked-in mounds are included. Independent charcoal, sage, ivory, beige, gray and carpet materials are selected to match the paintings. Individual horizons and modest uniform source insets remain static framing drafts.

Other aspect families, native grounding, material blending, source framing and UI compatibility still need the deferred combined release validation. No tests, packages, live installation or publication were performed.
