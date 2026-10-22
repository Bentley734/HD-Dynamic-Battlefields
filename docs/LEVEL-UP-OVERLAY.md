# Gen 1 level-up scene retention

Version 0.3.0-beta.7 changes only the Gen 1 scenery context lookup. The native
`BattleState.StatBox` has no opaque flag and draws only its frame and stat text.
The native state stack continues drawing the battle beneath it.

Previously the provider inspected only `game.stack:top()`, rejected the stat
window's metatable, and disabled the scenery pass. It now resolves the same
native battle through a chain consisting exclusively of recognized transparent
`StatBox` overlays. It stops at opaque or unrelated states. It never changes the
stack, Pokémon visibility, faint flags, species, input, or battle identity.

The matching Menu Customizer 3.35.23 fix is separate: its old stats-window wrapper
suppressed the entire battle HUD, although its final stats pass already handles
panel layering. Both updates are needed to preserve scenery and HP/status UI.

## Focused validation

`tests/gen1_context.lua` checks native battle identity, one or multiple transparent
stats overlays, opaque stats overlays, unrelated transparent and opaque children,
an orphan stats window, empty/missing stacks, and preserved faint visibility.
Existing fishing and Red/Blue/Yellow live-map classification checks also pass.

`tests/scenery_contract.lua` loads the complete provider against G1R 0.3.95's
module paths, with recorded graphics calls. The stats-overlay cases retain the
same background/variation and two mounds at 640×480, 1024×768, 1280×800, 1536×1024,
1279×799, 1281×801, 1920×1080, 5120×1440 and 900×1600 in day and night. They use
the bundled 16:9 family with uniform cover scaling; this verifies context and
viewport handling, not the artwork of every aspect-family pack. Unrelated,
opaque, disabled and mound-off paths retain their expected behavior.

The checked base source is upstream commit
`5eee7d1d521274b22648656693bade0b063847f6` (0.3.0-beta.6), matching GitHub main at
the start of this fix. No artwork, asset index, pack descriptors, or download
URLs were changed. The original dirty authoring checkout was not edited.

The combined fix also passed seven real LÖVE GPU fixtures through G1R 0.3.95's
Game.draw, Renderer, and StateStack: Red, Blue and Yellow at 1280x720 with native
and Emerald font settings, plus Red at 480x360. They verify preserved scene
pixels/composition, HUD and battler painting, native faint visibility, one-time
stats dismissal, and real Bag/Party transitions. The compact fixture uses the
bundled 16:9 artwork with cover scaling; it does not require an extra art pack.
The portable harness is in Menu Customizer's tests/gen1_level_up_scene_gpu.

These are constructed integration fixtures, not a complete battle playthrough.
Physical Android hardware and every third-party mod combination are unverified.
