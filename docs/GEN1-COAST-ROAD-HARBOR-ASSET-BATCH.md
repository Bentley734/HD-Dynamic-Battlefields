# Gen 1 road, coast and harbor artwork

Original built-in image generation outputs, 2026-10-15. Selected images are copied untouched into `art/source/`, with the exact prompt for each image in `art/prompts/` under the same stem. Day/night are separate paintings. Source originals remain in Codex generated_images. No tests or release publication in this asset work.

## Background variations

| Environment | Variation 1 | Variation 2 | Variation 3 | Explicit map destinations |
|---|---|---|---|---|
| cycling_road | Hill embankment, trees, distant lamps and railing | Coastal bridge overlook | Wooded hill rest shelter | ROUTE_16, ROUTE_17, ROUTE_18 |
| coastline | Pale shell-sand and limestone headlands | Pine-fringed cove | Dry gray sand/gravel and basalt headlands | ROUTE_20, ROUTE_21 land encounters |
| harbor | Passenger steamship dock apron | Fishing quay and lighthouse | Commercial brick warehouses and distant cargo ship | VERMILION_DOCK land encounters |

Source names follow `ENVIRONMENT-0N-16x9.png` and `ENVIRONMENT-0N-16x9-night.png`. These sets do not replace Vermilion city's still-missing harbor-city surroundings, Cinnabar's island town, or the League approach. Surf/fishing keeps the map's explicit ocean context rather than putting a water encounter on a concrete dock.

Day paintings have broad empty ground below a rear boundary approximately 21–28% down the image. The third Cycling Road painting includes a small edge marking at far left near the back boundary; it does not cross the battler contact regions. Natural coast standing areas remain dry, with the sea behind them. Dock/road surfaces have no planks, tile grid or directional slab seams to align across layers.

## Independent surface decals

The previous `mound-floor-gray-01.png` shows a pale perimeter fringe in visual inspection. It is not a finished universal material for these outdoor surfaces. New dedicated source materials were generated:

- `mound-asphalt-light-01` for the lighter road variations.
- `mound-asphalt-dark-01` for the coastal road and commercial dock asphalt.
- `mound-dock-concrete-01` for passenger/fishing quays.

The first light-asphalt output and its targeted image-generation edit retained edge defects. The user explicitly authorized scripted perimeter cleanup, preserving original files and painted interiors. Selected day derivatives are `mound-asphalt-light-01-v2-clean-v3.png`, `mound-asphalt-dark-01-clean-v3.png` and `mound-dock-concrete-01-clean-v3.png`. The raw files, first cleanup attempts (`-clean`) and unchanged second attempts (`-clean-v2`) are unselected studies. Do not register or package them as final materials.

Cleanup follows only the outer silhouette, trims twelve source pixels (under one native mound pixel at the current source width), preserves interior RGB/alpha, and extends retained paint into the new antialiased/hidden edge to avoid texture-filter color bleed. `tools/clean_mound_edges.py` and `art/derivatives.json` record the operation. Source PNGs remain untouched. Review previews must composite RGBA onto a solid matte: an RGB-only preview exposes intentionally hidden color padding around the transparent boundary.

Night source counterparts are separately generated against the matching night ground painting, then receive the same perimeter cleanup. Selected files are `mound-asphalt-light-01-night-clean.png`, `mound-asphalt-dark-01-night-clean.png` and `mound-dock-concrete-01-night-clean.png`. All six selected day/night materials have been visually reviewed on a solid matte in `docs/evidence/mound-surface-day-night-preview.png`. This is an artwork transparency preview, not a native runtime/grounding test. Natural coastline uses the existing independent sand/gray-sand material families. No platforms are baked into the background paintings.

## Current state

All eighteen background paintings and six selected cleaned day/night materials are saved and visually inspected. The nine variations are registered locally through the existing catalog and explicit map environments. Original rejected fringe candidates and failed cleanup copies remain unselected; the release builder includes catalog artwork only and follows derivative provenance to retain the original generation prompts. Final material blending, grounding and source-region review remain part of the deferred Gen 1 test batch. No aspect family beyond 16:9 is claimed by this batch; dedicated layouts are still required. Native sprite positions, UI rendering, Alpha 6 mound dimensions and the opponent's three-native-pixel upward correction remain unchanged.
