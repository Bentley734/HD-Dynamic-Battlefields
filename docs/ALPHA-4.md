# Alpha 4 — ultrawide and portrait river scenery

Adds dedicated willow-river day/night paintings for 32:9 and 9:16. These are new compositions rather than stretched standard widescreen images. Four untouched built-in image generator outputs and exact prompts are saved under `art/source/river-01-*` and `art/prompts/river-01-*`. `art/SOURCES.json` records hashes/dimensions. The dedicated 1983×793 panorama has a uniform top sample of 1983×557.71875, retaining its distant bank and open water. The portrait image is used full-frame.

Each composition has inherited aspect-specific perspective metadata and independent grass/pebble island assets for both periods. Enemy mounds retain Alpha 3's doubled footprint; Pokémon/UI transforms remain native. River variations 2/3 still have only 16:9 artwork. Remaining ratio families, other water environments' wide/portrait paintings and additional tiers are unfinished; missing combinations use native scenery.

## Evidence

- 13 pure Lua checks passed.
- Actual PNG decode/scene audit: 75 registered compositions, 141 composition-period combinations and 168 registered PNGs. Source inventory contains 174 images including retained studies/superseded sources.
- Official v0.3.88 Red renderer with Menu Customizer 3.35.4 passed six alignment renders plus 36 variation renders across 1920×1080, 5120×1440 and 900×1600 in both periods. The variation batch includes all three 16:9 river compositions; wide/portrait use their newly authored variation 1.
- Four automatic water-context renders passed: Surf on Route 10 and native rod-encounter constructors for river/ocean/pond, with Surf false during fishing.
- Visually reviewed ultrawide day and portrait night: continuous water covers the viewport and opponent contact meets its enlarged island. UI remains unmodified, including its user-controlled palette/readability.
- Archived records: `evidence/river-expanded-alignment-batch.json`, `evidence/river-expanded-variation-batch.json` and existing automatic-context records.

These are isolated render fixtures, not physical phones or live game traversal. The complete specification, supported-game adapters, environment collection, performance matrix and downloadable pack catalog remain incomplete. Alpha 4 bundles all current original art for testing.
