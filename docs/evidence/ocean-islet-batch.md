# Ocean environments and fishing context

Added three original 16:9 HD ocean backgrounds with separately painted night companions: green limestone archipelago, basalt coast/open sea, and coral-atoll reef lagoon. They use the existing independent grass/pebble, mossy-rock and sand/reed islet day/night pairs. No islands are baked into the background. Ocean is available manually and through explicit map-water classification. Other ocean aspect families, resolution tiers and underwater environments remain unfinished.

## Fishing detection

Official v0.3.88 `BattleState.newWild` accepts `opts.hooked` but uses it only to choose intro dialogue; it does not retain encounter type. The new `lib/adapters/gen1_context.lua` wraps that constructor, calls the native constructor with its original arguments and records a weak-key fishing tag outside native battle state. Scenery classification uses that tag alongside the existing Surf state. Native intro/dialogue, Pokémon, sprites and battle UI are unchanged.

Pure checks verify constructor arguments/return identity, immutable capture after options mutation, ordinary encounter distinction, nil returns, and river/ocean map classification for fishing. Unknown water maps still fail safely rather than guess. This adapter covers Gen 1 only.

## Batch evidence

- All 13 pure Lua checks passed.
- Real catalog audit decoded 158 registered PNGs and prepared 131 composition-period combinations. The source inventory records 164 original images including unregistered studies and superseded art.
- Official v0.3.88 native Red renderer plus Menu Customizer 3.35.4 passed eight alignment renders at 1280x720, 1920x1080, 2560x1440 and 1281x721, in both periods; plus 12 variation renders containing every ocean/islet pair in both periods.
- Three additional native-constructor context renders passed: saved Surf on Route 19 selected ocean, rod encounter on Route 10 selected river, and rod encounter on Route 19 selected ocean. Fishing used actual `BattleState.newWild(..., {hooked=true})` after mod loading, with Surf state false.
- Archived records: `ocean-alignment-batch.json`, `ocean-variation-batch.json`, `ocean-automatic-context.json`, `fishing-river-context.json`, `fishing-ocean-context.json`.
- Visually reviewed archipelago day and the fishing/ocean render. Native contact areas meet their islets, ocean fills the viewport, and native UI/sprite method calls/transforms match the provider-disabled baseline.

These are isolated renderer fixtures, not live rod-item/gameplay traversal or physical-phone QA. Full sprite replacement compatibility, other games, further aspect ratios and final art approval remain open. Ocean water is painted, not animated. No release approval is implied.
