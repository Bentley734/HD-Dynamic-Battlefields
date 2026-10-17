# Indoor material corrections

Artwork preparation on 2026-10-16, under the user's explicit authorization to clean generated mound edges locally while preserving interiors and original files.

- Psychic Gym's two lavender/mauve carpet rooms previously referenced burgundy decals. A new original `art/source/mound-carpet-lavender-01.png` is generated with the built-in image tool; its exact prompt is `art/prompts/mound-carpet-lavender-01.txt`. The selected `-clean.png` sibling removes its white/magenta perimeter, preserving the painted pile. The smooth observatory floor uses the existing pale lavender `mound-ice-cave-03-v3-clean.png` material, which has no geometric floor grid.
- Lorelei's first two seamless pale blue rooms use `mound-ice-cave-01-clean-round.png`. The older `ice-cave-02` candidate contains a tile pattern and is excluded from these rooms. The solid white pavilion floor uses the ivory floor decal, replacing the pool-platform choice.
- The existing `mound-ice-cave-03-v3.png` has a new cleaned sibling. Originals and earlier rejected candidates remain saved. The initial square-filter `mound-ice-cave-01-clean.png` produced square notches and is not selected; the rounded sibling is selected instead.

The local cleanup tool now supports an optional rounded high-density Gaussian perimeter inset for ragged paint silhouettes. Its original default mode is retained for reproducibility. Cleanup affects the perimeter alpha and nearby edge RGB only; opaque painted interiors and source PNGs remain intact. All selected derivatives and their operations are recorded in `art/derivatives.json`.

Matte-composited artwork previews:

- `docs/evidence/legendary-mound-edge-cleanup.png`
- `docs/evidence/ice-floor-rounded-edge-cleanup.png`
- `docs/evidence/lavender-carpet-edge-cleanup.png`

Local catalog material selections and static source framing have been updated. These previews establish appearance only; native blending, positioning, display behavior and compatibility remain untested. Battle UI and native default sprite positions were not changed. No release was built or published.
