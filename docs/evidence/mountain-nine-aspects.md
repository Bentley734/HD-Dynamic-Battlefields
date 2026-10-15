# Mountain saddle: nine aspect families

The HD prototype now has dedicated day/night paintings for all nine aspect families of mountain variation 01. Added six pairs for 4:3, 16:10, 3:2, 21:9, 9:19.5 and 9:20. The basin and terracotta variations still have only 16:9. Other environments, variation coverage, resolution tiers and game adapters remain unfinished.

## Framing correction

The initial 64-render batch passed the renderer checks, but visual review caught clipped peak tips in the 21:9 crop and the older 32:9 crop. Those paintings were not accepted as final framing.

Created new `mountain-01-21x9-v2` and `mountain-01-32x9-v2` day/night pairs, retaining originals for provenance. The new compositions put the complete distant skyline in the upper quarter and leave broad open plateau below. 21:9 now uses the whole painting. 32:9 samples a uniform top region (day 2116x595.125, night 2115x594.84375) and trims only surplus foreground. No mountain tips or sky are removed by those authored regions.

All geometry is catalog metadata. Native battler coordinates, sprite transforms and battle UI remain unchanged. Independent highland mounds use their matching day/night assets.

## Verification

- Pure Lua suite passed all 12 checks after the six new composition families were registered.
- After the panorama replacement, the actual-image catalog audit decoded 140 registered PNGs and prepared 119 composition-period combinations using the real scene/metadata modules. There are 64 registered compositions across the prototype; this is integrity evidence rather than complete-project approval.
- Official v0.3.88 native Red renderer plus Menu Customizer 3.35.4 passed the initial 64-render batch: 28 alignment renders across 14 sizes/day-night, plus 36 mountain variation renders. Archived records are `mountain-nine-alignment-batch.json` and `mountain-nine-variation-batch.json`.
- The revised panoramas passed six focused day/night renders at 2520x1080, 2560x1080 and 5120x1440. `mountain-panorama-followup.json` preserves that result. Native HUD/sprite method calls and transforms matched the disabled-provider baseline.
- Visually reviewed day 640x480, day 1536x1024, night 900x1950, revised day 5120x1440 and revised night 2520x1080. Feet meet their mounds; plateau remains behind contacts; corrected panorama skyline is visible and unclipped.

`art/SOURCES.json` now records 145 source assets, including superseded originals. Prompts and image hashes are retained. Live gameplay traversal, physical-phone behavior, replacement-sprite grounding, all other game adapters and final mound/material polish remain unverified or incomplete. No release approval is implied.
