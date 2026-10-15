# Alpha 1 — 0.1.0-alpha.1

This release makes the current scenery work available for user testing. It does not close the full development goal or imply all environments/games are implemented. Battle panels, text, HUDs and native sprite transforms remain owned by the game and other mods.

## Validation before packaging

- Thirteen pure Lua checks passed, including scenery contract, clock/weather, selection, terrain/fishing context, grounding, pixel alignment and pack recovery/errors.
- Catalog audit decoded 158 registered PNGs and resolved 131 composition/period combinations across 70 compositions.
- Real v0.3.88 Loader/Sandbox and native Red renderer with Menu Customizer 3.35.4: 28 alignment and 36 forest variation renders using actual offline-installed packs, with the bundled catalog deliberately removed. Native sprite/UI draw calls and transforms matched the disabled-provider baseline.
- Standalone real-runtime fixture: 1920×1080, 5120×1440 and 900×1600, with unknown-map/disabled/error restoration checks.
- Nine HD aspect packs built and imported offline. Hashes, compatibility, corrupt archives/index, unsafe paths, torn commit recovery, removal/reimport and deterministic rebuild checks passed. These QA packs have unpublished test URLs and are not release downloads.
- Earlier artwork batches checked nine aspect families for grassland, forest, rocky terrain and mountain. River/ocean batches checked island placement, day/night and automatic surfing/fishing selection. Written evidence is under `docs/evidence`.

These are isolated fixtures, not a live gameplay playthrough. Physical devices, performance, full sprite-mod compatibility, KIM coexistence and the complete scenario matrix remain unverified. Only HD art exists. Missing environments/ratios deliberately fall back to native scenery. Download/update HTTP behavior has not been validated against a published asset catalog.

## Distribution

The alpha ZIP bundles the current original artwork, including retained source candidates, prompts and checksums. Runtime selection uses registered entries only. Git tracks code/metadata/prompts and written evidence; release PNGs are excluded from Git to avoid a large binary history. `SHA256SUMS.txt` verifies the archive; `RELEASE-FILES.json` inside verifies its contents.
