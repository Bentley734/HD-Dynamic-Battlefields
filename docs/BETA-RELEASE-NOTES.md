# Kanto Beta 2

Download **HD-Dynamic-Battlefields-0.1.0-beta.2-base.zip** first. Extract the mod folder into `%APPDATA%/pokemon-love2d/mods`, enable it, then open **Options > HD Battlefields > Asset Manager**. Existing Beta 1 artwork packs remain compatible; you do not need to download them again.

New: **Mounds > Species Positions > Player / Opponent** reads every registered species and form, including mod additions, with saved whole-pixel X/Y offsets and an individual reset. Verified lists contain 1,153 records with National Dex Gen 3 + G9 Battle Sprites + Gen3 HD Sprites, or 1,389 with 1025Dex. Use those as alternative setups because the content mods declare conflicts.

New: **FireRed/LeafGreen compatibility**, including native OPTIONS submenus and HD Sprites camera integration. 244 inspected map IDs reuse existing scenery; all 159 map IDs with positive native wild rates or trainer objects are mapped. Sevii habitats reuse suitable existing art. Moltres is mapped at Mt. Ember. The runtime or your UI mod continues to own battle UI and mechanics.

Choose your screen ratio and HD quality, then **One Variation Per Area** to save space or **All Variations** for variety. Download the selected pack and turn **Backgrounds > HD Backgrounds** on. You can download each screen size independently.

This beta adds original scenery for 46 identified Gen 1 battle environment types, with at least one complete nine-aspect variation for each. Outdoor scenes have separate original day/night paintings. Mounds remain separate, and the battle UI stays with your existing UI mod. Player and opponent X/Y corrections use whole native pixels.

The base contains an original wide grassland fallback. Missing artwork safely retains native scenery. Offline users can download a pack ZIP and matching `.pack.json` from the artwork releases, then use the included offline importer while the game is closed. See the README for instructions.

Validated with official gen1recomp v0.3.89: 19 Lua checks, Red/Blue/Yellow rendering regressions, published 1025Dex in Red, and both FR/LG games with both mod setups across wide, ultrawide and portrait presentations (144 habitat/size checks). Native menu navigation, species offsets/reset and unchanged healthbox/menu calls were checked. Pecharunt was rendered with the actual sprite provider. Existing Beta 1 artwork integrity/download evidence still applies. See `docs/BETA-2.md` for exact fixture scope.

This remains a beta. Full gameplay traversal, every animation/transition, double battles and physical mobile devices remain unverified. Gen 2, R/S/E and link scenery are not integrated. Mobile/Ultra-HD tiers and additional complete variations remain in development. KIM coexistence is unvalidated; keep one scenery provider enabled when troubleshooting.

Report game version, other mods, location, screen size, selected background and a screenshot. Diagnostics shows the active environment and fallback reason.

## Artwork downloads

Each artwork release contains separate compact (`one`) and full (`all`) ZIPs and matching descriptors. The in-game catalog combines these releases:

- [4:3](https://github.com/Bentley734/HD-Dynamic-Battlefields/releases/tag/v0.1.0-beta.1-assets-4-3)
- [16:9](https://github.com/Bentley734/HD-Dynamic-Battlefields/releases/tag/v0.1.0-beta.1-assets-16-9)
- [16:10](https://github.com/Bentley734/HD-Dynamic-Battlefields/releases/tag/v0.1.0-beta.1-assets-16-10)
- [3:2](https://github.com/Bentley734/HD-Dynamic-Battlefields/releases/tag/v0.1.0-beta.1-assets-3-2)
- [21:9](https://github.com/Bentley734/HD-Dynamic-Battlefields/releases/tag/v0.1.0-beta.1-assets-21-9)
- [32:9](https://github.com/Bentley734/HD-Dynamic-Battlefields/releases/tag/v0.1.0-beta.1-assets-32-9)
- [9:16](https://github.com/Bentley734/HD-Dynamic-Battlefields/releases/tag/v0.1.0-beta.1-assets-9-16)
- [9:19.5](https://github.com/Bentley734/HD-Dynamic-Battlefields/releases/tag/v0.1.0-beta.1-assets-9-19-5)
- [9:20](https://github.com/Bentley734/HD-Dynamic-Battlefields/releases/tag/v0.1.0-beta.1-assets-9-20)
