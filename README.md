# HD Dynamic Battlefields — Kanto + Johto + Hoenn Beta

Gen 2 support is now included for **Gold, Silver and Crystal**. Download artwork by individual size, or choose **Download All Assets** for every size in the selected quality/variation profile. New artwork downloads come from commit-pinned repository source files. See [Gen 2 validation and limitations](docs/GEN2-INTEGRATION.md) and [source asset distribution](docs/SOURCE-ASSET-DISTRIBUTION.md).

Original illustrated battle scenery and independent mounds for Red/Blue/Yellow, Gold/Silver/Crystal, FireRed/LeafGreen and Ruby/Sapphire/Emerald. Current candidate tested on official gen1recomp **v0.3.95**. The game and your UI mod retain battle commands, dialogue, fonts and HUDs. **Mounds → Species Positions** lists the effective species registry, including mod additions and forms, with separate player/opponent X/Y corrections in whole native pixels.

## Current release

The current release supports Kanto, Johto and Hoenn on official gen1recomp **0.3.95**. Battle UI remains owned by the game and your UI mods. Only full-resolution HD artwork is offered; compact downloads select one variation per area without lowering resolution.

**0.3.0-beta.7** keeps the active Gen 1 battlefield visible while the native
level-up stats box is open. The stats box overlays the same battle and artwork
instead of causing a non-battle fallback. Update Menu Customizer as well to keep
its HP/status UI visible beneath that box. Existing artwork downloads remain
compatible; no artwork redownload is needed.

**0.3.0-beta.6** adds automatic mound registration for all six native sprite choices in **1025Dex 1.5.2**, covering 1,389 registered species/forms. Pack padding, player front/mirror views and individual doubles contacts are calibrated in HD Battlefields. Pokémon positions and 1025Dex files are unchanged. Existing artwork downloads remain compatible. See [calibration and exact validation scope](docs/DEX-FOOTING.md).

## Install and enable

1. Close the game. Download `HD-Dynamic-Battlefields-0.3.0-beta.7-base.zip` from the latest release.
2. Extract `hd-dynamic-battlefields` into `%APPDATA%\pokemon-love2d\mods`. The folder must directly contain `manifest.json` and `main.lua`. When upgrading, replace the previous mod folder; keep your saves and mod cache.
3. Enable the mod in Mod Manager and apply/restart as prompted.
4. Open **Options → HD Battlefields → Asset Manager**. Select **Screen Size** and **Variations** (one per area saves space; all adds variety). Open **Download Selected Size**, select a pack, then **Download / Restore**. **Download All Sizes** uses the chosen variation profile. Check download status and pack health.
5. Open **Backgrounds → HD Backgrounds → On**. Keep **Display → Artwork Aspect** on Automatic. You can install multiple screen ratios independently.

The base includes one original wide grassland day/night fallback with separate mounds. Existing Gen 1 artwork packs remain readable. Download or restore the new packs to add Gen 2 scenes. Unavailable environments safely use native scenery until their pack is installed. You do not need every aspect ratio. Compact and full packs are alternative choices for the same screen ratio; remove an old full pack from Installed Packs to reclaim its space after switching to compact.

If the in-game downloader is unavailable, download the chosen pack ZIP and matching `.pack.json` from its artwork release, close the game, and use the included `tools/install_offline_pack.py` importer. See [offline installation](docs/OFFLINE-ASSET-INSTALL.md). New artwork is downloaded from repository source; historical artwork releases remain available.

Keep one scenery provider enabled when investigating bugs. KIM coexistence and other competing scenery providers remain unvalidated. Your battle UI mod can remain enabled.

## Included

- Location-specific grasslands, forests, caves, beaches, mountains, rivers, oceans, gyms and special interiors across Kanto, Johto and Hoenn.
- All 46 positively identified battle environment types have at least one variation in all nine supported aspect families. Extra variations and preserved nonbattle artwork have uneven coverage.
- Separate day/night paintings and matching mounds. Gen 1 Automatic uses local system time (day 06:00–17:59); caves use constant underground artwork.
- Three tiny-island mound pairs for river/ocean encounters, including fishing and surfing detection.
- Random/fixed variation, weather particles, mound offsets/scale, calibration and diagnostics.

## Beta limits and bug reports

This is a partial implementation, **not the completed specification**. FR/LG maps 244 inspected areas, including all 159 map IDs with positive native wild encounters or trainer objects. Sevii habitats reuse existing suitable paintings. Tested mod setups are National Dex Gen 3 + G9 Battle Sprites + Gen3 HD Sprites, or 1025Dex separately; those content mods conflict with one another. Full playthroughs, every combat animation and physical devices remain unverified. Link scenery remains unsupported. Additional full variations, Mobile/Ultra-HD art and illustrated water/foliage animation remain unfinished.

Please report game version, other mods, map/encounter, window size, day/night setting and a screenshot. **Options → HD Battlefields → Diagnostics** shows the selected environment/background and fallback reason. Include those values for floating feet, incorrect mounds, missing scenery or resizing bugs. Turn HD Backgrounds off to disable scenery.

## Source and artwork

Git tracks code, metadata, tools, prompts, artwork checksums and written evidence. Current artwork downloads use commit-pinned repository source files. Historical artwork release packs remain available for older installations. The lightweight base contains an original grassland fallback. No ROM, executable, saves or KIM artwork/code is included.

See [Beta 2 validation and limits](docs/BETA-2.md), [earlier Beta 1 evidence](docs/BETA-1.md), [full specification](docs/DEVELOPMENT-SPECIFICATION.md) and [scope ledger](docs/REQUIREMENTS.md). Older development notes describe intermediate states.

### 1025Dex 1.5.3 / G9 GEN3 support (beta.8)

Supports the new G9 GEN3 artwork selection using 1025Dex's versioned live
`pictureBake` API. Mound contacts come from the exact image currently displayed,
including its authored reference foot, body center, mirror and slot geometry.
Each double-battle ally remains independent; native Pokemon draw calls are not
modified. The previous audited path for 1025Dex 1.5.2 remains available. Unknown
versions without the API still keep their existing scenery calibration.
