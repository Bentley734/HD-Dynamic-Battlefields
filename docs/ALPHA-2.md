# Alpha 2 — pond scenery

Adds three original 16:9 HD pond paintings with separate generated night images: willow/alder bank, limestone woodland pool, and lotus meadow. The six untouched PNG outputs and exact built-in image generator prompts are saved in `art/source` and `art/prompts`; inventory hashes are in `art/SOURCES.json`. The existing independent grass/pebble, mossy rock and sand/reed island pairs are reused. Native sprites/UI are unchanged.

Pond selection uses the existing explicit water-map taxonomy. Route 6 Surf and rod encounters select pond; the manual environment list now includes Pond. Other pond aspect families and quality tiers remain unfinished and retain native scenery. No lake artwork is claimed.

## Validation

- All 13 pure checks passed; Route 6 fishing classification is now explicitly asserted.
- Catalog decode: 164 registered PNGs, 137 period combinations, 73 registered compositions. Source inventory includes 170 images, including retained studies/superseded candidates.
- Real v0.3.88 Red renderer with full Menu Customizer 3.35.4: eight day/night alignment cases (1280×720, 1920×1080, 2560×1440, 1281×721), plus twelve variation renders covering all three pond/islet pairs in both periods.
- Four automatic water-context renders passed: Route 6 Surf plus actual native `BattleState.newWild(..., {hooked=true})` river/ocean/pond constructors with Surf false.
- Visually inspected pond day variations 2/3 and night variations 1/2. Opponent feet meet the independent islet surface; native player panel occludes much of its mound as expected. Water fills the viewport. Native draw calls/transforms match the disabled-provider baseline.

Archived evidence: `evidence/pond-alignment-batch.json`, `evidence/pond-variation-batch.json`, `evidence/pond-automatic-context.json`, `evidence/fishing-pond-context.json`. This is isolated fixture evidence; live gameplay, full sprite/device/game compatibility and the remaining original specification are incomplete. Previous Alpha 1 checks and limitations remain relevant. The downloadable pack catalog remains unpublished; this alpha bundles all current artwork.
