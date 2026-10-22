# 1025Dex mound registration

The beta.6 update belongs entirely to HD Dynamic Battlefields. It observes the selected sprite source and moves painted mounds; it does not patch 1025Dex files, change its options or move Pokémon. Battle commands, HUDs, fonts and other UI remain owned by the game and UI mods.

## Calibration

The audit uses the original uncomposited artwork and the production `setupFrames` layout in 1025Dex 1.5.2. Separate shadows, crystals and clouds are not mistaken for feet. The stable animation union supplies the rest ground; a jumping frame does not drag its mound up and down. Deliberate floater padding remains intact.

Pack alignment can leave up to 29 native pixels below the body. Its offsets depend on species, source pack, palette, size and logical side. A player using front artwork still uses back-side pack metrics, so that case has its own calibration. Feet and Box alignment use the existing canvas ground. Mound material origins and manual mound adjustments are applied afterward.

The small runtime source catalog supports all 1,025 base species and 364 registered forms. Missing pack-specific artwork follows 1025Dex's actual fallback. KIM's public requests are observed without altering their arguments, decoded pixels, metadata, return values or errors. This avoids predicting a different source from the one actually selected. All metadata loads lazily; no GPU readback or artwork decoding is added to normal battle frames.

Each visible doubles slot gets a mound at its own contact. Existing sprite position settings remain unchanged. Gen 2 uses the screen's displayed mon during queued switches; pending and native fallback pictures retain native mound placement. Unknown versions and unknown Pack geometry fail safely to existing placement.

## Evidence

- Official gen1recomp **0.3.95**; 1025Dex **1.5.2**; BW sprite provider **1.0.0**; KIM public sprite provider **1.7.46**.
- Full installed 1025Dex asset manager reported Ready. Its 23,109 downloaded files passed size and SHA-256 checks. All 18,353 body PNGs in that cache match the audited originals; BW and KIM artwork was read from the installed providers.
- **23,253 original sheets / 528,594 frames** scanned. No missing or undecodable files.
- **66,672 species/form, style, gender, side and palette source selections** matched the production resolver, including fallbacks.
- **7,863,984 production layout checks**, including logical player-side front artwork. Runtime data contains **69,796** explicit known source/union keys and **1,020** deduplicated Pack profiles.
- **31,608 complete production frame bakes** across 90 representative sources checked against source alpha and stable layout.
- **216 Red and 216 Crystal native GPU cases** cover DBK, Gen9 Static, EE Animated and EE Static, three sizes, three anchors, three player views, classic and wide layouts. Static body alpha matched mound contacts exactly. HD on/off preserved native sprite draw arguments and transforms.
- **100 Gen 3 native GPU cases / 222 ready sprite draws** cover all six styles, additional Pack front/mirror cases, shiny palettes, forms, doubles and water. All **114 grounded static measurements** match the actual painted mound surfaces with zero gap. Twelve window transitions cover portrait and 32:9 doubles. Their machine-readable report is linked below.
- **1,000 ranked contact-risk sprites and 300 flagged floaters** received contact-sheet review. Thin legs, tails, airborne poses and first-pose animation gaps were kept distinct; speculative anatomical offsets were not applied.

See [audit summary](evidence/dex-footing/audit-summary.json), [native Gen 3 results](evidence/dex-footing/native-0.3.95/footing-report.json) and the Gen 1/2 summaries in the same evidence folder. New regression runners are `tools/run_dex_footing_probe.py` and `tools/run_dex_gb_footing_probe.py`.

These are exhaustive source/layout checks plus targeted real battle and visual checks. They do not claim a manual in-game inspection of every animated frame, all move mechanics, arbitrary manual sprite/mound overrides, other custom battle-scene renderers or physical Android hardware. The KIM test loads its actual public sprite provider with its separate stage disabled; it is not a full KIM scene compatibility claim.
