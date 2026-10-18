# Hoenn development — Ruby, Sapphire and Emerald

The published 0.2.0-beta.1 remains the Kanto/Johto build. This development
stage does not enable or claim R/S/E scenery support in its release manifest.

## Native inspection

`tools/inspect_rse_battle_maps.py` reads imported native headers, encounters
and reachable object/coordinate/sign event scripts without loading saves.
It resolves each map's actual RU_, SA_ or EM_ identity from native constants.

- Ruby: 394 imported maps; 142 with positive wild/event battle evidence.
- Sapphire: 394 imported maps; 142 with positive wild/event battle evidence.
- Emerald: 518 imported maps; 177 with positive wild/event battle evidence.

These evidence counts are not proof of exhaustive gameplay coverage: native
specials, generated facilities and map-entry scripts need separate inspection.
The authoring plan explicitly includes known legendary/Frontier battle areas
and excludes unused/prototype maps. There are currently 478 battle-area
candidates across the three games and no unclassified candidates.

`metadata/rse-art-plan.json` records exact per-game IDs, land/water choices,
mixed-terrain overrides, reuse candidates and the missing-art queue. Route 111
retains grassland and a separate desert sand override. Underwater, ashfields,
volcanic terrain, Mt. Pyre, gyms, Elite Four and Frontier facilities keep distinct
identities. Eleven existing scenery families have complete nine-aspect reuse
candidates; visual fit and appropriate mound choices still need review.

## Read-only context adapter

`lib/adapters/rse_context.lua` reads the native battle/session, resolved terrain,
species, weather and existing RTC. It distinguishes native double battles from
link battles and identifies water/underwater without changing terrain IDs,
mechanics, sprite rendering or HUDs. It is deliberately not wired into main.lua
until the scenery pipeline and fallbacks are validated with real Hoenn fixtures.
Its regression checks pass alongside the existing Lua suite.

## Original artwork

The first Route 113 ashfield 16:9 day/night paintings are in
`art/gen3/16x9/ashfield/`. They were separately generated using the built-in
image tool. Exact prompts and SHA-256 authoring records are saved beside them.
Original generated files are retained. No image stretching or lighting filter
was used. The scenes contain no characters or baked-in mounds.

The night painting has its own provisional horizon and opponent ground anchor.
These are authoring candidates, not calibrated runtime placements. Existing
gray-sand/pale-gravel mounds are candidates only. All other aspects, native R/S/E
integration, mound/material fit and special/double battle rendering remain work
to complete before a Hoenn beta is published.
