# Kanto + Johto Beta — 0.2.0-beta.1

Adds **Gold, Silver and Crystal** support alongside Red/Blue/Yellow and FireRed/LeafGreen. Requires gen1recomp v0.3.89 (compatible range >=0.3.89, <0.4.0).

Download **HD-Dynamic-Battlefields-0.2.0-beta.1-base.zip**, replace the previous mod folder, then open **Options → HD Battlefields → Asset Manager**. Choose HD, your aspect ratio and **One Variation Per Area** for a smaller install. **Download All Assets** installs every size for the selected quality and variation profile. Enable HD Backgrounds afterward.

Gen 2 includes 53 scenery families and 477 registered compositions across all nine aspect families, with separate painted night scenes where appropriate. Existing Gen 1 artwork is reused where suitable. Native Gen 2 time selects day/night. Fishing, surfing, caves, gyms and special interiors use map-specific scenery. Mounds remain independent, with per-species positioning controls.

Artwork now lives in repository source, organized by game, size and location, with mounds in their own folder. Downloads pin immutable commits and verify file checksums. This release contains only the lightweight mod, download index and checksums; historical artwork releases remain available for older installations.

Validated: pure Lua checks; native Gold/Silver/Crystal rendering at classic, ultrawide and portrait sizes; representative location renders; Tackle, Surf, Psychic and Earthquake animation fixtures; and both mods loaded through the real loader with Menu Customizer. Battle HUD/menu drawing remains owned by the game and UI mod.

**Beta limitations:** full gameplay traversal, every species/scene contact point, physical Android devices, link battles and all transitions are not exhaustively tested. Some mound positions may need species offsets. R/S/E scenery integration is not included. Existing cached packs can be restored through the new catalog. More complete calibration and optional extra Gen 2 variations will follow.

Report game/build, location, other mods, screen size and a screenshot, plus Diagnostics output.
