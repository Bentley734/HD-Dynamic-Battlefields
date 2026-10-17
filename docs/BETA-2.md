# Kanto Beta 2 — 2026-10-17

Adds FireRed/LeafGreen scenery adapters and **Mounds → Species Positions → Player / Opponent**. The chooser reads the effective species registry when opened, including later registrations, regional/cosmetic forms and sparse mod slots. Duplicate display names are distinguished by form ID. Corrections persist per playthrough, game, species and side, in whole native pixels, add to broader position corrections, and have a targeted reset.

FR/LG uses its native 240×160 coordinate system and existing OPTIONS renderer/page stack. HD Sprites keeps its own camera, sprite tags and UI composition; scenery does not replace battle text, menus, healthboxes or battle mechanics. The native pad anchors are player (64,117), opponent (176,64). Renderer-provided frame dimensions keep mounds aligned with the actual UI presentation; HD-tagged mounds follow the library's camera and side shifts.

## Coverage

244 explicit FR/LG ID/map-type pairs reuse existing habitat paintings. All 159 native map IDs with positive wild encounter rates or trainer objects are mapped. This count is a data audit, not a completed playthrough or exhaustive scripted-encounter audit. Shared Kanto interiors retain their specific environments. Additional Sevii habitats reuse suitable existing grassland, beach, forest, cave and industrial art, rather than claiming newly painted location-specific scenes. Icefall Cave uses Seafoam cave art. Moltres's special scenery resolves at Mt. Ember summit instead of Gen 1's Victory Road. Unmapped/nonbattle/prototype areas and link presentation retain native scenery.

The 18 existing Beta 1 HD artwork packs remain compatible: nine aspect ratios, separately downloadable, with compact one-variation or all-variation choices. This code update does not require downloading those packs again.

## Validated fixtures

Official gen1recomp **v0.3.89**, with imported local data read-only and scratch storage in memory. No live save, installed mod or imported cache was modified.

- Published National Dex Gen 3 **v1.1.3** + G9 Battle Sprites **v1.5.3** + Gen3 HD Sprites **v0.4.5**: **1,153 selectable records**, all 639 added species and 128 forms individually checked.
- Published **1025Dex 1.5.0**, separately: **1,389 selectable records** in FR/LG and Red, including Pecharunt and Mega Charizard X.
- Both FR/LG games and both supported mod setups: **144 habitat/size render checks**, plus added-species rendering, native options navigation, persisted pixel edits/reset, unchanged native healthbox/menu call traces, and scoped offset resolution. Sizes: 1280×720, 2560×1080, 900×1600, each in a fresh process. Resetting a LÖVE display mode clears third-party GPU canvases, so it is not used to simulate an ordinary resize.
- Red/Blue/Yellow native scenery regression fixtures, including nonzero species-only pixel offsets, independent opponent preservation, reset, native UI/effect traces and fallback/error restoration. Red also loaded the published 1025Dex package.
- **19 Lua checks**, including effective registry enumeration, distinguishable form labels, scoped storage, FR/LG classification, real draw-coordinate forwarding and graphics/error recovery.

Screenshots are local evidence, excluded from the base ZIP. Wide and portrait National/G9/HD outputs were visually reviewed, including Pecharunt. Fixtures construct native battles and stage command screens; they do not simulate full gameplay or prove every combat animation, double battle, fainting transition or device combination. Gen 2, R/S/E, link presentation and physical mobile testing remain outside this beta.

National Dex/G9 and 1025Dex declare conflicts with one another. Test them as alternative setups, not all together. No third-party mod code or art is bundled.

Pinned release archive SHA-256:

| Mod | SHA-256 |
|---|---|
| national_dex_gen3 v1.1.3 | cc5790d539b210d757d865005dddedc55623fc6078ef4bc85b4001dd48e927b3 |
| g9-battle-sprites-gen3 v1.5.3 | afec3d692cb881a72a304ee3355a8ecc8e09a45f97c6dcc0ab788ef670a24511 |
| gen3-hd-sprites v0.4.5 | b9ec8b401cc2bdb7857510fbb4ef4495f21da07aa11340d89e43b8ba9475db8f |
| 1025Dex 1.5.0 | 58b5e74fe3bee2baec0301e361dd87a524f421b75a6491390c8102c2cd7b95cc |

Archive sizes and hashes matched their GitHub release metadata before extraction. Full registry and render summaries are under `docs/evidence/frlg/`.
