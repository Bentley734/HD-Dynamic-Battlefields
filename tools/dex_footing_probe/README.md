This fixture uses the official isolated 0.3.95 engine and native Emerald battle
renderer through the real Loader/Sandbox. It reads imported cartridge caches
and installed artwork, and writes only isolated evidence files. It never edits
1025Dex, KIM, the BW companion, sprites, or player saves.

Run `tools/run_dex_footing_probe.py` from the HD Dynamic Battlefields directory.
The 1025Dex full asset manager pack, local BW import, and KIM artwork must already
be installed. The KIM manifest is virtualized **only in this fixture** to load its
actual public sprite provider without its independent battle scene. A successful
run does not claim compatibility with the complete KIM presentation.

The 100 cases cover six styles, native sizes and anchors, player back/front/
mirrored-front views, normal/shiny palettes, added forms, doubles, and water.
The full GEN9 static size/anchor/view matrix and focused animated PACK views
guard the distinction between physical front artwork and logical back metrics.
Selected doubles resize through landscape, 32:9, portrait, and landscape again.

Each comparison freezes the animation phase, verifies a real ready replacement
picture, and asserts unchanged native sprite draw arguments with HD scenery
enabled and disabled. GPU alpha bounds are measured separately from the actual
painted mound draws. Grounded static feet must agree with the calibrated painted
surface within one native pixel; material origins and offsets are included.
Animated bobbing and intentional hovering are measured without being flattened.

The report and screenshots are written to
`docs/evidence/dex-footing/native-0.3.95/`. This representative native probe
complements the exhaustive source/frame geometry audit. It does not simulate a
full playthrough, every move animation, or every species in a live battle.
