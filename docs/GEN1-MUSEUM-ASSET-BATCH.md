# Pewter museum gallery artwork

Six original 16:9 paintings generated with the built-in image tool on 2026-10-16 are saved unchanged in `art/source/`, with exact same-stem prompts in `art/prompts/`.

| Category | Source stems | Variations |
|---|---|---|
| museum | museum-01-16x9 through museum-03-16x9 | Fossil/amber hall / specimen alcoves / mineral and fossil study hall |
| museum_space | museum_space-01-16x9 through museum_space-03-16x9 | Capsule and meteorites / lunar exhibit / astronomy instruments |

The two floors now have distinct explicit classifications: `MUSEUM_1F` selects `museum`, while `MUSEUM_2F` selects `museum_space`; both retain their existing `MUSEUM` tileset guard. This prevents upstairs scenes from randomly becoming fossil halls or downstairs scenes from becoming a space gallery. Three local compositions per category inherit shared perspective metadata and use independent ivory, gray or beige floor decals.

Original paintings contain only small inert rear exhibits and room architecture. Their lower standing planes have no floor grids, planks, text, living creatures, UI or baked-in mounds. Fossil skeletons and space models are museum exhibits, not battler sprites. Each category uses constant indoor climate. Source-reviewed individual horizon values and modest exact-16:9 insets on fossil hall 1 and space gallery 3 remain calibration drafts.

The inspected native v0.3.88 museum flavor/story sources establish Museum 1F fossil/Old Amber context and Museum 2F's separate map context. These are gallery/special-context scenery registrations, not a claim that ordinary native trainer battles occur there. Actual encounter behavior, source framing, grounding, material blending and UI compatibility remain untested.

Current state: all six source images inspected and saved, both floor categories registered locally and manual labels added. Dedicated other aspect families and the deferred combined release checks remain required. No tests, packaging, live-game changes or release publication were performed.
