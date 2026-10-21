# Gen 1 live-map background selection

Gen 1 scenery now resolves its map through BattleState.currentMapId (live overworld first), with the saved player map used only when no live overworld map exists. Previously it read save.player.map, which can remain a town or shop after the player walks onto a route. This could place town/shop art in Route 1 grass battles.

No artwork replacement or re-download is needed. Existing Route 1 grassland paintings, separate day/night images, mounds and manual environment overrides remain available.

Validation: all Lua unit checks; stale Pallet/Viridian/Celadon-Mart save scenarios across Red, Blue and Yellow; official runtime 0.3.95 Loader/Sandbox native battle fixtures for all three games at classic, ultrawide and portrait sizes. Regression records explicitly use live ROUTE_1 plus saved CELADON_MART_1F and verify grassland selection. No real saves were modified by the fixtures.
