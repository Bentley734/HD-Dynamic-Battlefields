# Hoenn beta candidate 0.3.0-beta.1

Requires Gen1Recomp 0.3.95 or newer within the 0.3 series. Adds Ruby, Sapphire and Emerald to the existing Kanto/Johto scenery adapters. Battle UI and native sprite placement remain controlled by the game and UI/sprite mods.

## Artwork and installation

The lightweight base includes one widescreen grassland day/night fallback. Install artwork from Options → HD Battlefields → Asset Manager. Choose Screen Size, then one variation per area or all available variations. Download Selected Size opens the matching packs; Download All Sizes honors the chosen variation count. Only original full-resolution HD textures are offered. Compact packs reduce variation count, not resolution.

Eighteen source-backed packs cover nine aspect families with compact/full alternatives. Hoenn has 75 registered environment families and 675 compositions, including reused suitable Kanto/Johto artwork and separate day/night sources where applicable. Assets and perspective metadata are pinned to one immutable source commit. Preserve the mod cache when upgrading.

## Changes

- Native Hoenn single/double mound profiles and explicit environment mappings.
- Larger water islets, lowered six native pixels; no sprite/UI displacement.
- Revised ultrawide floor clearance for 53 source compositions.
- Species positioning supports effective mod registries and alternate sprite providers.
- Active shared textures are reused; downloaded mound paths retain original material identities.
- Downloader navigation, informational rows and status pages behave consistently.
- Missing texture tier/size diagnostics explain the required action.

## Validation and limits

Targeted runtime 0.3.95 checks include all eleven game adapters, actual loader checks, installed ocean packs in R/S/E, full native trainer flows, existing-window resize with sprite visibility, and 126 current Emerald water scenes across all nine aspects in singles/doubles. Additional Emerald family fixtures and revised ultrawide batches have separate evidence. These are not full playthroughs or every-map/species/move certification.

National Dex Gen3 + G9 sprites + Gen3 HD Sprites are one tested setup; 1025Dex is tested separately. Do not combine conflicting Pokédex providers. Menu Customizer and WildFollowers have targeted compatibility evidence. Competing scenery-provider coexistence remains unvalidated.

Physical Android/iOS orientation and performance are unverified. G9 cached sprite canvases were observed becoming transparent after graphics-mode recreation; existing-window resize passed the tested fixtures. Link scenery remains native. Three-to-five complete variants per environment and detailed illustrated environmental animation remain future work. Mobile downsampling is deferred by user request.

Remote source verification covers 2,335 files against the immutable GitHub tree and 27 HTTP samples. A complete 32:9 compact-pack download verified 246 files (472,760,426 bytes) through runtime 0.3.95 in an isolated cache. Index upgrade tests reject stale cached catalogs and remote rollbacks. Other full-pack HTTP downloads remain untested. See GEN3-HOENN-DEVELOPMENT.md and the evidence directory for exact test scopes.
