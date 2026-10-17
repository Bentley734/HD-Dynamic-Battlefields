# Route gate and underground passage artwork

Original built-in image generation, 2026-10-16. Six new 16:9 paintings are saved unchanged in `art/source/`; exact prompts use identical stems in `art/prompts/`.

| Category | Source stems | Meaningful scene variations |
|---|---|---|
| gatehouse | gatehouse-01-16x9 through gatehouse-03-16x9 | Road checkpoint / upstairs observation hall / older waiting hall |
| underground_tunnel | underground_tunnel-01-16x9 through underground_tunnel-03-16x9 | Dark concrete passage / pale lined passage / utility section |

All six are registered locally as `{environment}-room-{1,2,3}-16x9`. Each has separate inherited perspective metadata and a source-reviewed horizon value. Gate 3 uses an authored uniform 16:9 inset. Raised scenery is confined to the far wall area; floors have no tile grids, plank lines, rails, stripes, platforms or baked-in battle mounds.

Matching independent sage, gray, beige and warm charcoal materials are reused. Exact existing map/tileset guards select the categories. Both categories have explicit indoor climate policy, so outdoor weather and day/night changes do not affect these enclosed scenes.

These general route-gate scenes are not final replacements for distinct Safari rest lodges or forest gates. Those pending refinements remain in `GEN1-LOCATION-SUBTYPES.md`. Artwork for a mapped passage does not establish an ordinary native battle there.

Current state: six paintings visually inspected and saved, local metadata/catalog/manual labels updated. Remaining aspect families, material blending, native grounding and compatibility require the deferred combined validation. No tests, release packaging, live installation or publication were performed.
