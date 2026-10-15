# Tiny island mounds

Three reusable transparent islet asset pairs are available for water compositions:

| Material | Day asset | Night asset | Current river pairing |
|---|---|---|---|
| Grass and pebbles | art/source/mound-islet-grass-01.png | art/source/mound-islet-grass-01-night.png | Willow bend |
| Mossy rock shelf | art/source/mound-islet-rock-01.png | art/source/mound-islet-rock-01-night.png | Wooded gorge |
| Sand and short reeds | art/source/mound-islet-sand-01.png | art/source/mound-islet-sand-01-night.png | Meadow footbridge |

They are separate scenery textures, never baked into the background. Each pair has a low profile and open central standing surface. Ocean 16:9 variations reuse the same pairs: grass/pebbles for the archipelago, mossy rock for the basalt coast, and sand/reeds for the reef lagoon. Pond 16:9 variations pair them with willow bank, limestone woodland pool and lotus meadow respectively. Lake backgrounds remain unregistered.

The background variation determines the islet and stays stable throughout the battle. Both sides have independent mound placement/scaling through existing Mounds settings. Native battle sprites and UI retain their original transforms. The native player panel can occlude much of the player's mound; this mod does not reposition that panel.

## Image anchors

Perspective metadata supports optional `player.mound_origin` and `opponent.mound_origin`, normalized source-image coordinates in the range 0–1. Omission preserves the existing centered image origin `{0.5, 0.5}`. This lets the artist align an islet's standing surface with the native contact slot without changing Pokémon positions. River opponent islets use `{0.5, 0.62}`, calibrated against the native Red renderer. Origins inherit through metadata, are validated, and are copied into layouts rather than mutating source metadata.

The separate `mound-ripple-01.png` daytime study is retained as an unregistered prototype candidate. It is not an enabled setting or a complete day/night pair.
