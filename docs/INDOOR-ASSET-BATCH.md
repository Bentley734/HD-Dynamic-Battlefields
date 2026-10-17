# Indoor source artwork and seamless carpet variants

Generated with the built-in image_gen tool, 2026-10-15. Untouched selected PNG outputs are saved under `art/source/`; exact prompts have matching stems under `art/prompts/`. Original outputs also remain in the Codex generated_images directory. This batch is local, unregistered source artwork. No tests, package builds, runtime checks or GitHub publishing were run after the user's test hold.

## Current smooth-floor candidates

Three room layouts: timber-trim cottage, town apartment and plaster-walled common room. All battler floor surfaces are seamless; furniture stays along the distant wall. Wood trim/furniture is allowed; wood/plank flooring and tile grids are not.

| Room | Day | Separate night | Independent neutral floor patch |
|---|---|---|---|
| Cottage | house-01-16x9-v2.png | house-01-16x9-v2-night.png | mound-floor-beige-02.png |
| Apartment | house-02-16x9-v2.png | house-02-16x9-v2-night.png | mound-floor-sage-02.png |
| Common room | house-03-16x9-v2.png | house-03-16x9-v2-night.png | mound-floor-clay-02.png |

## Carpet material alternatives

These retain the same room layouts and are material alternatives, not additional genuinely distinct environment variations. Carpet is wall-to-wall and has non-directional soft pile: no rug border, stripes, geometric repeat or alignment seams.

| Material | Day | Separate night | Independent neutral carpet patch |
|---|---|---|---|
| Moss green | house-01-carpet-moss-16x9.png | house-01-carpet-moss-16x9-night.png | mound-carpet-moss-01.png |
| Dusty blue | house-02-carpet-blue-16x9.png | house-02-carpet-blue-16x9-night.png | mound-carpet-blue-01.png |
| Burgundy | house-03-carpet-burgundy-16x9.png | house-03-carpet-burgundy-16x9-night.png | mound-carpet-burgundy-01.png |

The 18 selected images comprise 12 room paintings and six independent transparent floor textures. Mounds are flat decals, not raised stages. Dedicated non-16:9 room compositions, exact lighting matches/night patches, metadata, alpha-edge/compositing checks and runtime grounding remain pending until the appropriate later stage. Generated previews were visually reviewed; no claim of in-game integration or validated transparency blending is made.

## Superseded source studies

The earlier `house-01-16x9.png` and night painting have wood plank floors; `house-03-16x9.png` and night have tile grids; the first apartment pair has faint floor seams. All six are retained only as superseded source studies and must not be registered/shipped as selected artwork. The initial wood/tile floor-mound outputs remain only in generated_images, were not copied into the project and are not selected assets.

Visual follow-up during ship source generation: the blue carpet patch preview shows cyan/blue edge fringing; the burgundy patch also needs edge review. These remain source candidates only and must not be treated as production-ready mound assets. Replacement or a verified compositing solution remains pending; no alpha analysis or runtime tests were run.

The runtime catalog and mod version are unchanged. Keep the no-tests-until-all-assets-done and no-more-releases-until-project-finished instructions in `USER-DIRECTION.md` authoritative for subsequent work.
