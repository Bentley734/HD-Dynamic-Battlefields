-- Names are resolved through each runtime environment module's TERRAIN table,
-- avoiding assumptions that FRLG and RSE share numerical scene IDs.
local common={GRASS='grassland',LONG_GRASS='tall_grass',SAND='beach',UNDERWATER='underwater',
 WATER='ocean',POND='pond',MOUNTAIN='mountain',CAVE='cave',BUILDING='interior',PLAIN='open_plain',
 GYM='gym',LEADER='gym_leader',CHAMPION='champion'}
local function family(extra)local result={};for k,v in pairs(common)do result[k]=v end;for k,v in pairs(extra)do result[k]=v end;return result end
return {
 frlg=family({LINK='link_room',INDOOR_1='interior_scene_1',INDOOR_2='interior_scene_2',
  LORELEI='elite_four_ice',BRUNO='elite_four_rock',AGATHA='elite_four_ghost',LANCE='elite_four_dragon'}),
 rse=family({FRONTIER='battle_frontier',GROUDON='legendary_groudon',KYOGRE='legendary_kyogre',RAYQUAZA='legendary_rayquaza',
  MAGMA='team_magma',AQUA='team_aqua',SIDNEY='elite_four_dark',PHOEBE='elite_four_ghost_hoenn',GLACIA='elite_four_ice_hoenn',DRAKE='elite_four_dragon_hoenn'})}
