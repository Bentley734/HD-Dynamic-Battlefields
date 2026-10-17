# Additional Gen 1 variation artwork

Generated with the built-in image generation tool on 2026-10-16. Twelve new original 16:9 paintings are saved unchanged in `art/source/`; exact prompts use the matching stems in `art/prompts/`. These complete the three widescreen variations for five previously single-variation categories. No creatures, UI or battle mounds are baked into these paintings.

| Category | New source paintings | Three-variation set now available |
|---|---|---|
| Silph Co. | corporate_interior-02-16x9, corporate_interior-03-16x9 | Office / conference hall / executive operations room |
| Cerulean deep cave | deep_cave-02-16x9, deep_cave-03-16x9 | Existing cavern / mineral arch chamber / secluded charcoal cavern |
| Seafoam cave | seafoam_cave-02-16x9, seafoam_cave-03-16x9 | Existing coastal chamber / inlet arches / chalkstone cascade gallery |
| Underground water | cave_water-02-16x9, cave_water-03-16x9 | Existing underground water / pale limestone lake / dark mineral lake |
| Safari land | safari_woodland-02-16x9 and -night; safari_woodland-03-16x9 and -night | Existing woodland / oak-alder clearing / wooded hill meadow |

Every source stem above has a `.png` image and a same-stem `.txt` prompt. Safari night scenes are separately painted images, not runtime color tints. Enclosed caves and Silph rooms use constant indoor/underground illumination. Seafoam remains a coastal cave; there is no invented snowy outdoor Kanto location.

All new variations are registered in `metadata/prototype.lua`, reusing the explicit existing map/tileset classifications. Underground water keeps the independent rock-islet material and its authored opponent mound origin. Dry caves use the cave/violet/limestone/warm-basalt materials according to the painted ground. Silph uses gray, sage and ivory seamless floor decals. Safari uses the independent day/night grass materials.

## Source framing drafts

Some generated rear walls and night tree lines sit lower than requested. Selected room compositions now carry their own authored source rectangles. `inset16x9` builds an exact 16:9 sample from these 1672x941 paintings, preserving uniform image scaling and leaving the original PNG unchanged. This is per-composition metadata, not a renderer or battler-position change.

Draft insets cover Silph 2/3, deep cave 3, Seafoam 3, and the new legendary generator hall 1/3. Safari variation 1 uses a modest common inset; variations 2/3 have separate night framing because the independently painted night tree line sits lower. Psychic Gym 2/3 also receive lower framing to keep their room boundary above the opponent standing area. These are static artwork decisions; native grounding and calibration still require the deferred combined test batch.

Current state: twelve source paintings inspected and saved; their local catalog entries and framing drafts are in place. Dedicated other aspect families, material blending, native terrain/encounter behavior and full release validation remain pending. No tests, packaging, runtime installation or publication were performed.
