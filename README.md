# HD Dynamic Battlefields — Gen 1 Beta 1

Original illustrated battle scenery and independent mounds. Isolated native and Menu Customizer 3.35.4 checks passed on official gen1recomp **v0.3.89**. The game and your UI mod retain the battle commands, dialogue, HUDs and sprites; optional Pokemon position corrections affect only native sprite pictures.

## Install and enable

1. Close the game. Download `HD-Dynamic-Battlefields-0.1.0-beta.1-base.zip` from the main beta release.
2. Extract `hd-dynamic-battlefields` into `%APPDATA%\pokemon-love2d\mods`. The folder must directly contain `manifest.json` and `main.lua`. When upgrading, replace the previous mod folder; keep your saves and mod cache.
3. Enable the mod in Mod Manager and apply/restart as prompted.
4. Open **Options → HD Battlefields → Asset Manager**. Select your screen aspect ratio and **HD** quality. Choose **One Variation Per Area** to save space, or **All Variations** for more variety. Open **Browse Available Packs**, select a pack, then **Download / Restore**. Check download status and pack health.
5. Open **Backgrounds → HD Backgrounds → On**. Keep **Display → Artwork Aspect** on Automatic. You can install multiple screen ratios independently.

The base includes one original wide grassland day/night fallback with separate mounds. Unavailable environments safely use native scenery until their pack is installed. You do not need every aspect ratio. Compact and full packs are alternative choices for the same screen ratio; remove an old full pack from Installed Packs if you want to reclaim its space after switching to compact.

If the in-game downloader is unavailable, download the chosen pack ZIP and matching `.pack.json` from its artwork release, close the game, and use the included `tools/install_offline_pack.py` importer. See [offline installation](docs/OFFLINE-ASSET-INSTALL.md). Artwork releases are grouped by aspect ratio; the in-game catalog combines them.

Keep one scenery provider enabled when investigating bugs. KIM coexistence and other competing scenery providers remain unvalidated. Your battle UI mod can remain enabled.

## Included

- Grassland, forest, caves, beach, mountain, rocky terrain, river, ocean and ponds: 904 registered compositions, 1,331 referenced PNG assets and 1,279 composition/period combinations.
- All 46 positively identified battle environment types have at least one variation in all nine supported aspect families. Extra variations and preserved nonbattle artwork have uneven coverage.
- Separate day/night paintings and matching mounds. Gen 1 Automatic uses local system time (day 06:00â€“17:59); caves use constant underground artwork.
- Three tiny-island mound pairs for river/ocean encounters, including fishing and surfing detection.
- Random/fixed variation, weather particles, mound offsets/scale, calibration and diagnostics.

## Beta limits and bug reports

This is a partial implementation, **not the completed specification**. Native Red rendering is the validated fixture; Blue/Yellow gameplay, alternate sprite mods, real encounter transitions and physical devices need testing. Gen 2/3 adapters are not shipped. Additional full variations, Mobile/Ultra-HD art, illustrated water/foliage animation remain unfinished. This beta offers HD packs; Mobile and Ultra-HD filters will show no packs until those tiers are available.

Please report game version, other mods, map/encounter, window size, day/night setting and a screenshot. **Options â†’ HD Battlefields â†’ Diagnostics** shows the selected environment/background and fallback reason. Include those values for floating feet, incorrect mounds, missing scenery or resizing bugs. Turn HD Backgrounds off to disable scenery.

## Source and artwork

Git tracks code, metadata, tools, prompts, artwork checksums and written evidence. Large PNGs are in the separate artwork release packs rather than Git history. The lightweight base contains an original grassland fallback. No ROM, executable, saves or KIM artwork/code is included.

See [beta validation and limits](docs/BETA-1.md), [full specification](docs/DEVELOPMENT-SPECIFICATION.md) and [scope ledger](docs/REQUIREMENTS.md). Older development notes describe intermediate states; beta notes describe this release.
