# Gen 1 battle-location source planning

Static source inspection only; no Lua execution, runtime tests or asset validation. Imported encounters.lua and trainer_headers.lua read from local Gen2Recomp/data/generated. Presence is a positive scheduling signal; absence is not proof of no battle because scripted/static/fishing/link battles require separate review.

| Environment | Positive encounter/trainer map evidence |
|---|---|
| abandoned_mansion | POKEMON_MANSION_1F (encounters, trainer header); POKEMON_MANSION_2F (encounters, trainer header); POKEMON_MANSION_3F (encounters, trainer header); POKEMON_MANSION_B1F (encounters, trainer header) |
| beach | ROUTE_19 (encounters, trainer header) |
| cave | DIGLETTS_CAVE (encounters); MT_MOON_1F (encounters, trainer header); MT_MOON_B1F (encounters); MT_MOON_B2F (encounters, trainer header); ROCK_TUNNEL_1F (encounters, trainer header); ROCK_TUNNEL_B1F (encounters, trainer header); VICTORY_ROAD_1F (encounters, trainer header); VICTORY_ROAD_2F (encounters, trainer header); VICTORY_ROAD_3F (encounters, trainer header) |
| coastline | ROUTE_20 (encounters, trainer header); ROUTE_21 (encounters, trainer header) |
| corporate_interior | SILPH_CO_10F (trainer header); SILPH_CO_11F (trainer header); SILPH_CO_2F (trainer header); SILPH_CO_3F (trainer header); SILPH_CO_4F (trainer header); SILPH_CO_5F (trainer header); SILPH_CO_6F (trainer header); SILPH_CO_7F (trainer header); SILPH_CO_8F (trainer header); SILPH_CO_9F (trainer header) |
| cycling_road | ROUTE_16 (encounters, trainer header); ROUTE_17 (encounters, trainer header); ROUTE_18 (encounters, trainer header) |
| deep_cave | CERULEAN_CAVE_1F (encounters); CERULEAN_CAVE_2F (encounters); CERULEAN_CAVE_B1F (encounters, trainer header) |
| dojo | FIGHTING_DOJO (trainer header) |
| elite_four_dragon | LANCES_ROOM (trainer header) |
| elite_four_ghost | AGATHAS_ROOM (trainer header) |
| elite_four_ice | LORELEIS_ROOM (trainer header) |
| elite_four_rock | BRUNOS_ROOM (trainer header) |
| forest | VIRIDIAN_FOREST (encounters, trainer header) |
| grassland | ROUTE_1 (encounters); ROUTE_11 (encounters, trainer header); ROUTE_12 (encounters, trainer header); ROUTE_13 (encounters, trainer header); ROUTE_14 (encounters, trainer header); ROUTE_15 (encounters, trainer header); ROUTE_2 (encounters); ROUTE_22 (encounters); ROUTE_24 (encounters, trainer header); ROUTE_25 (encounters, trainer header); ROUTE_5 (encounters); ROUTE_6 (encounters, trainer header); ROUTE_7 (encounters); ROUTE_8 (encounters, trainer header) |
| gym_electric | VERMILION_GYM (trainer header) |
| gym_grass | CELADON_GYM (trainer header) |
| gym_ground | VIRIDIAN_GYM (trainer header) |
| gym_poison | FUCHSIA_GYM (trainer header) |
| gym_psychic | SAFFRON_GYM (trainer header) |
| gym_rock | PEWTER_GYM (trainer header) |
| gym_water | CERULEAN_GYM (trainer header) |
| haunted_tower | POKEMON_TOWER_1F (encounters); POKEMON_TOWER_2F (encounters); POKEMON_TOWER_3F (encounters, trainer header); POKEMON_TOWER_4F (encounters, trainer header); POKEMON_TOWER_5F (encounters, trainer header); POKEMON_TOWER_6F (encounters, trainer header); POKEMON_TOWER_7F (encounters, trainer header) |
| league_approach | ROUTE_23 (encounters) |
| mountain | ROUTE_3 (encounters, trainer header); ROUTE_4 (encounters, trainer header) |
| power_plant | POWER_PLANT (encounters, trainer header) |
| rocket_hideout | ROCKET_HIDEOUT_B1F (trainer header); ROCKET_HIDEOUT_B2F (trainer header); ROCKET_HIDEOUT_B3F (trainer header); ROCKET_HIDEOUT_B4F (trainer header) |
| rocky_terrain | ROUTE_10 (encounters, trainer header); ROUTE_9 (encounters, trainer header) |
| safari_woodland | SAFARI_ZONE_CENTER (encounters); SAFARI_ZONE_EAST (encounters); SAFARI_ZONE_NORTH (encounters); SAFARI_ZONE_WEST (encounters) |
| seafoam_cave | SEAFOAM_ISLANDS_1F (encounters); SEAFOAM_ISLANDS_B1F (encounters); SEAFOAM_ISLANDS_B2F (encounters); SEAFOAM_ISLANDS_B3F (encounters); SEAFOAM_ISLANDS_B4F (encounters, trainer header) |
| ship_bow | SS_ANNE_BOW (trainer header) |
| ship_cabin | SS_ANNE_1F_ROOMS (trainer header); SS_ANNE_2F_ROOMS (trainer header); SS_ANNE_B1F_ROOMS (trainer header) |

## Scripted exceptions inspected

- OAKS_LAB: official v0.3.88 data/scripts/oaks_lab.lua and oaks_lab_yellow.lua implement the starter rival battle; laboratory artwork remains needed.
- CELADON_CHIEF_HOUSE: official v0.3.88 data/scripts/celadon_chief_house.lua line 17 invokes trainer OPP_CHIEF. Do not defer this house merely for being residential.

## Unresolved scope

Need inspect water/fishing contexts, scripted/static battles and header-to-map naming exceptions before deriving a final remaining count. Keep existing non-battle originals. No new non-battle aspect generation.

## Additional positive sources inspected

- Official v0.3.88 data/scripts/gyms.lua defines CINNABAR_GYM/Blaine, retaining gym_fire.
- data/scripts/story.lua defines CHAMPIONS_ROOM battle flow, retaining champion.
- data/scripts/flavor/cerulean_cave_b1f.lua:23, power_plant.lua:47, seafoam_islands_b4f.lua:25 and victory_road_2f.lua:23 invoke the four static legendary battles. All four dedicated legendary sets remain needed.
- src/world/FieldDefaults.lua:56-60 defines Old/Good Rod encounters and per-map Super Rod lookup. Imported field.lua superRod positive map keys follow. This proves fishing content exists, not that every listed tile or shoreline is reachable. Native water routing review remains pending.

CELADON_CITY, CERULEAN_CAVE_1F, CERULEAN_CAVE_2F, CERULEAN_CAVE_B1F, CERULEAN_CITY, CERULEAN_GYM, CINNABAR_ISLAND, FUCHSIA_CITY, PALLET_TOWN, ROUTE_10, ROUTE_11, ROUTE_12, ROUTE_13, ROUTE_17, ROUTE_18, ROUTE_19, ROUTE_20, ROUTE_21, ROUTE_22, ROUTE_23, ROUTE_24, ROUTE_25, ROUTE_4, ROUTE_6, SAFARI_ZONE_CENTER, SAFARI_ZONE_EAST, SAFARI_ZONE_NORTH, SAFARI_ZONE_WEST, SEAFOAM_ISLANDS_B3F, SEAFOAM_ISLANDS_B4F, VERMILION_CITY, VERMILION_DOCK, VIRIDIAN_CITY

- Official v0.3.88 data/scripts/story.lua:423-435 implements SS_ANNE_2F rival battle; dedicated ship_corridor mapping now covers this scripted fight, while the three cabin maps use ship_cabin.

- Official v0.3.88 data/scripts/pallet_town.lua:13-36 implements a post-Champion Prof Oak trainer battle in PALLET_TOWN, mapped to village. Existing village nine-family artwork covers this runtime-specific positive battle area.
- Official v0.3.88 data/scripts/story5.lua:653-666 implements the Cerulean rocket thief battle in CERULEAN_CITY, mapped to city. Existing city nine-family artwork covers it. These scripted positives are retained in the beta coverage audit.

## Beta routing audit continuation

Source inspection of official v0.3.88 yellow_jessie_james.lua confirms all four Yellow ambush sites: MT_MOON_B2F, ROCKET_HIDEOUT_B4F, POKEMON_TOWER_7F, SILPH_CO_11F. These retain cave, rocket_hideout, haunted_tower and corporate_interior respectively, each with nine-family variation 1 artwork.

Added explicit water context mappings for positive Super Rod keys previously missing them: CERULEAN_GYM to its indoor pool scenery, ROUTE_4 to river, ROUTE_11/17/18 to ocean, ROUTE_22 and VIRIDIAN_CITY to pond. Land encounters retain their original scenery. All other positive fishing keys already have explicit water mappings. Reachability and native fishing context remain runtime checks, not established by this static audit.

Link presentation remains explicitly unsupported by the current adapter; this beta must disclose that limitation rather than count the arena artwork as validated link coverage.
