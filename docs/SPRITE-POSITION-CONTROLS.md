# Pokemon position corrections

Open HD Battlefields > Mounds, choose Adjustment Scope, then Player or Opponent. Pokemon Horizontal and Pokemon Vertical change only that side's native Pokemon picture position. Each step is one Gen 1 logical pixel, rounded to a whole pixel at rendering. Positive values move right/down. Existing mound controls remain independent.

Scopes are Global, a specific artwork aspect, or Current Background. More specific values override the same coordinate from broader scopes. Reset This Scope removes saved corrections for that scope; it does not edit the original artwork or perspective metadata. Changes are stored per playthrough using the existing adjustment store.

Default offsets are zero and the native battle UI remains unchanged. Native drawBattlerPic is supported; a sprite mod that renders outside that method must consume battlefieldScenery.spriteOffset(side) explicitly. Such consumers have not yet been validated. The method returns whole native Gen 1 pixels for player/opponent and returns zero when scenery is inactive.

Pure Lua checks and the official v0.3.88 default-offset standalone fixture passed. Nonzero-offset visual grounding and custom-renderer compatibility remain pending beta validation.
