# Granite canyon: nine aspect families

Added ten original paintings: separate day/night artwork for 16:10, 3:2, 21:9, 9:19.5 and 9:20. Together with existing 4:3, 16:9, 32:9 and 9:16 artwork, granite variation 01 now has all nine composition families in the HD prototype tier. Slate and limestone variations still have only 16:9. Other environment, variation and resolution-tier requirements remain open.

Each new composition has its own perspective metadata and uses the separate pale-gravel day/night mound pair. The 21:9 illustration uses an authored uniform sample (x=188, y=160, width=1540, height=660) to put the open floor behind native battler contacts. No battle UI, native sprite coordinates or rendering engine changes were made for these assets.

## Batch evidence

- Pure Lua suite passed all 12 checks.
- New `tools/audit_art_catalog.py` decoded 128 registered source PNGs and exercised the real scene preparation/metadata validation for 107 composition-period combinations. This verifies catalog integrity, not visual quality or full project coverage.
- Official v0.3.88 native Red renderer with Menu Customizer 3.35.4 passed 64 renders: 28 alignment renders across 14 sizes in both periods, plus 36 rocky variation renders. Native sprite/UI calls and transforms matched the disabled-provider baseline.
- The 14 sizes include every required aspect family, 5120x1440, odd intermediate dimensions and a narrow 451x1001 window. This is an isolated renderer fixture, not gameplay or physical-phone QA.
- Visually reviewed day 1280x800, day 2520x1080 and night 900x2000. Native feet meet their mounds, scenery fills the window and the floor stays behind contacts. Night mound contrast remains subject to final art polish.

Current `alignment-batch.json` and `variation-batch.json` contain this 64-render batch and replace previous snapshots. The previously missing 16:10 composition now loads. `art/SOURCES.json` records all 129 original source assets and their prompts/hashes/alpha ranges. All are prototype candidates; this is not release approval.
