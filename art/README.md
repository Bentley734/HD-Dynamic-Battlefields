# Original prototype artwork

Generated with the built-in imagegen tool on 2026-10-15. No KIM image was supplied as an input, and no KIM pixels or source code are included. Sources are preserved in `source/`; exact prompts are in `PROMPTS.md`. These are initial production candidates, not a completed collection.

- `grassland-01-{16x9,32x9,9x16}.png`: independently composed open meadow illustrations.
- `forest-01-{16x9,32x9,9x16}.png`: independently composed woodland clearings.
- `cave-01-{16x9,32x9,9x16}.png`: independently composed limestone chambers.
- `mound-{grass,forest,cave}-01.png`: independent RGBA ground patches, used on both sides with independent metadata scaling.

The panoramic generator outputs include vertical composition bleed; their explicitly authored 32:9 source regions are stored in composition metadata. The renderer samples these regions without stretching either axis. Portrait scenes were generated as separate vertical illustrations. Tiny source-ratio differences from integer image dimensions are handled through proportional source sampling, not stretching.

All nine compositions have native Red sprite/HUD rendering evidence. These checks do not establish complete sprite compatibility or final art approval. Remaining environment variations, aspect families, quality tiers and mound types are still required. These are HD prototype candidates, not a claimed Ultra-HD collection. Do not substitute ordinary widescreen crops for missing dedicated compositions.
