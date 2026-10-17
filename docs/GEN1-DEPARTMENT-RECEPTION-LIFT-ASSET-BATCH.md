# Celadon reception and elevator artwork

2026-10-16: six original widescreen paintings created with built-in ImageGen, visually inspected and registered locally. Unchanged generated originals are saved under `art/source`; the exact prompt set is under `art/prompts` with the same basenames.

| Category | Source files | Independent materials |
|---|---|---|
| Store reception | department_lobby-01/02/03-16x9.png | Sage floor, blue carpet, beige floor |
| Enclosed lift | elevator-01/02/03-16x9.png | Gray floor, ivory floor, sage floor |

Only CELADON_MART_1F and CELADON_MART_ELEVATOR change categories; their original LOBBY tileset guards remain. Sales floors 2F–5F and both outdoor rooftops still need dedicated art and routing. Both completed categories explicitly retain constant interior climate. Service/transport scenery coverage does not establish ordinary native encounters there.

Reception layouts differ in desk, doors, waiting areas and furnishings. Elevator layouts differ in door placement, trim, rails, wall arrangement and controls. All standing surfaces are seamless, without tile grids or planks. Authored uniform 16:9 source insets lift the low elevator wall junctions while retaining the unchanged source images. Framing and mound material matching are drafts pending native review.

Source context: official runtime v0.3.88 `data/scripts/story3.lua` defines CELADON_MART_ELEVATOR through the elevator helper; `story5.lua` identifies the third-floor TV-game clerk and `story4.lua` identifies rooftop vending machines. These are static source observations, not runtime validation.

No renderer, battle UI, sprite defaults or Alpha 6 mound dimensions changed. No tests, packaging or publication performed. Dedicated remaining aspect compositions, material/grounding calibration and other release gates remain open.
