# HD Dynamic Battlefields — Alpha 1

Original illustrated backgrounds and independent mounds for gen1recomp **v0.3.88**. Battle commands, dialogue, HUDs, Pokémon and trainer sprites remain owned by the game and your other mods.

## Install and enable

1. Close the game before installing. Download `HD-Dynamic-Battlefields-0.1.0-alpha.1.zip` from the release.
2. Extract its `hd-dynamic-battlefields` folder into `%APPDATA%\pokemon-love2d\mods`. It must directly contain `manifest.json` and `main.lua`.
3. Enable the mod in Mod Manager and apply/restart as prompted.
4. Open **Options → HD Battlefields → Backgrounds → HD Backgrounds → On**. It starts off by default. Keep **Display → Texture Tier** set to **HD** and artwork aspect **Automatic**.

The ZIP includes the current artwork; no asset download is needed. Menu Customizer 3.35.4 integration and standalone rendering have isolated runtime checks. KIM/other scenery providers have not been validated together with this alpha; use one scenery provider when investigating bugs. Your battle UI mod can remain enabled.

## Included

- Grassland, forest, caves, beach, mountain, rocky terrain, river and ocean: 70 registered compositions, 158 registered PNG assets and 131 composition/period combinations.
- Four composition families have dedicated art for all nine supported aspect families. Other families cover fewer ratios; missing combinations retain native scenery.
- Separate day/night paintings and matching mounds. Gen 1 Automatic uses local system time (day 06:00–17:59); caves use constant underground artwork.
- Three tiny-island mound pairs for river/ocean encounters, including fishing and surfing detection.
- Random/fixed variation, weather particles, mound offsets/scale, calibration and diagnostics.

## Alpha limits and bug reports

This is a partial implementation, **not the completed specification**. Native Red rendering is the validated fixture; Blue/Yellow gameplay, alternate sprite mods, real encounter transitions and physical devices need testing. Gen 2/3 adapters are not shipped. Many environments, Mobile/Ultra-HD art, illustrated water/foliage animation and a published downloadable pack catalog remain unfinished. Asset Manager has no published packs; this alpha bundles its artwork.

Please report game version, other mods, map/encounter, window size, day/night setting and a screenshot. **Options → HD Battlefields → Diagnostics** shows the selected environment/background and fallback reason. Include those values for floating feet, incorrect mounds, missing scenery or resizing bugs. Turn HD Backgrounds off to disable scenery.

## Source and artwork

Git tracks code, metadata, tools, prompts, artwork checksums and written evidence. Large PNGs are in the release ZIP rather than Git history. Extract `art/` from the installed alpha into this checkout to run from source. No ROM, executable, saves or KIM artwork/code is included.

See [alpha validation](docs/ALPHA-1.md), [full specification](docs/DEVELOPMENT-SPECIFICATION.md) and [scope ledger](docs/REQUIREMENTS.md). Older development notes describe intermediate states; alpha notes describe this release.
