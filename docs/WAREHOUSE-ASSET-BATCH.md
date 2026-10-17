# Warehouse and workshop artwork source batch

Generated locally with the built-in image_gen tool on 2026-10-15. Seven selected untouched PNG outputs are saved under `art/source/`; exact prompts have matching stems under `art/prompts/`. Original generator outputs remain in Codex generated_images. No tests, packaging, runtime registration or publishing were performed.

## Three distinct industrial interiors

| Scene | Day source | Separate night source |
|---|---|---|
| Coastal shipping depot | warehouse-01-16x9.png | warehouse-01-16x9-night.png |
| Steel-rack storage hall | warehouse-02-16x9.png | warehouse-02-16x9-night.png |
| Machinery maintenance workshop | warehouse-03-16x9.png | warehouse-03-16x9-night.png |

Furniture and storage stay at the far wall. Floors are broad seamless concrete without floor tile grids, planks, cracks or directional markings. No battler mounds are painted into the backgrounds. Night paintings retain the scene architecture with local lamps and night windows, independently generated rather than runtime lighting filters.

## Floor patch

`mound-floor-gray-night-cool-01.png` is an independent transparent cool-gray concrete patch, a candidate for cool-lit night industrial interiors. Existing gray, ivory and charcoal patches remain daytime material candidates. Exact background matching, alpha compositing and grounding are not yet validated.

Two warm night patch attempts (`mound-floor-gray-night-warm-01` and `-02`) showed colored edge fringes in generated previews. They were NOT copied into the project or selected for shipping. Their original outputs remain only in Codex generated_images; warm night material remains unfinished. Avoid claiming it was fixed or approved.

This batch is 16:9 source artwork only. Eight other aspect families, quality tiers, matched materials, perspective metadata, integration and final validation remain pending. It does not cover every industrial facility or unique story-location interior. User direction remains assets only, no tests until all assets are done, and no GitHub releases until the entire project is finished.

