-- Explicit atmosphere policy; interiors must never acquire outdoor weather
-- merely because their map name resembles an outdoor location.
return {
 grassland={outdoor=true},forest={outdoor=true},mountain={outdoor=true},rocky_terrain={outdoor=true},
 beach={outdoor=true},coastline={outdoor=true},ocean={outdoor=true},river={outdoor=true},pond={outdoor=true},
 village={outdoor=true},city={outdoor=true},island_town={outdoor=true},harbor_city={outdoor=true},harbor={outdoor=true},
 cycling_road={outdoor=true},league_exterior={outdoor=true},safari_woodland={outdoor=true},
 cave={outdoor=false},deep_cave={outdoor=false},seafoam_cave={outdoor=false},cave_water={outdoor=false},
}
