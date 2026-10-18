# Gen 2 environment assignment review

This is an authoring review of the imported Gold, Silver and Crystal data, not a claim of runtime integration or gameplay verification. Initial release scope remains one variation per environment, with suitable Gen 1 artwork reused directly.

## Mixed dry and water cave encounters

The asset plan now records imported grass, water and swarm trigger rates rather than relying solely on encounter-table membership. A positive water rate on a cave map creates separate candidate assignments: `land` uses the dry cave family; `surf` and `fishing` use `cave_water`. There are 39 context-dependent cave map entries across the three games. These entries must retain encounter context when the runtime adapter is integrated.

The surf and fishing assignments are candidates. A surf table does not prove that every reachable fishing tile or scripted encounter should use the same water composition. Terrain, rod encounters, scripted battles and mound selection still need runtime review. Distinctive locations such as Dragon's Den and Lugia's chamber retain their dedicated families.

## S.S. Aqua

`FAST_SHIP_B1F` now selects the existing `ship_corridor` family as its reuse candidate, rather than the generic `ship_interior` family. Cabins continue to use `ship_cabin`. The imported map is an indoor basement with ship-layout blocks, coordinate events and trainer objects; its final visual assignment remains subject to runtime review.

## Remaining gates

### Initial Gen 2 scope and Cinnabar correction

The initial Gen 2 release uses one variation per environment, with existing Gen 1 originals reused where suitable. Additional variations are deferred. Cinnabar Island now has its own `cinnabar_coast` surf/fishing candidate instead of the intact Gen 1 town. Imported Crystal text describes the eruption and destruction of Blaine's original gym. Separate 16:9 day and night paintings show open water and a distant volcanic coastline; the original bytes, exact prompts and draft contact metadata are saved under `art/gen2/16x9/cinnabar_coast`. Other aspect compositions and runtime integration remain pending. These assets were made with the built-in image generator; no gameplay tests were run during authoring.

### Port water composition

Vermilion City's positive-rate water encounter candidates now share the existing `harbor_water` first variation with its port. This preserves the waterfront setting while keeping both contact regions on water instead of the dry `harbor_city` plaza. The original town painting remains preserved for future uses. This is an authoring assignment; encounter-context behavior still requires the deferred runtime pass.

The saved Gen 1 harbor, harbor-city and island-town originals have dry foregrounds. Their availability does not establish suitability for surf encounters. Olivine Port and Vermilion Port now have a distinct `harbor_water` authoring assignment for surf/fishing candidates, with original 16:9 day and separately painted night scenes and open-water foregrounds. The original dry harbor art remains preserved. Other aspect sizes, independent water/islet mound matching and runtime encounter-context selection remain unfinished. The planning tool now tracks night compositions for this outdoor family as well as Tin Tower's rooftop.

### Follow-up: battle evidence and first gap paintings

The imported Crystal data gives positive surf trigger rates for Cinnabar Island (15), Vermilion City (15), and Olivine/Vermilion ports (5 each). Goldenrod Underground, its switch-room entrances and its warehouse contain trainer objects. These are relevant battle candidates, but the waterfront scenes need water/shore framing rather than assuming a dry dock floor. Imported Gold/Silver rows carry the same candidate categories; reachable terrain and script behavior still need the deferred runtime pass.

Dedicated 4:3 first-variation originals are now saved for Goldenrod's Underground and basement warehouse. The warehouse composition removes the old reference's open seaside doorway and windows, retaining the painted brick, steel and storage materials in a sealed lamp-lit basement. The old Gen 1 original remains preserved. The reuse inventory now records 38 absent source compositions; this replaces the initial inventory count of 40 below. Neither new original is runtime-registered or calibrated yet.

The [single-variation reuse inventory](GEN2-REUSE-INVENTORY.md) identifies 256 registered Gen 1 compositions across 33 candidate families, with no missing referenced files. Five families have incomplete catalog coverage: harbor, harbor city, island town, underground tunnel and warehouse. The warehouse has a preserved unregistered 16:9 original, so it must be reviewed before any replacement is generated. Forty aspect-specific originals are absent across those five candidate families. These are potential gaps, not forty confirmed required paintings: map accessibility and actual battle eligibility must be resolved before generation, especially for town/port entries inferred from encounter-table membership.

- Review fishing, Headbutt and Rock Smash accessibility; a table or fish-group name alone does not establish a reachable encounter.
- Verify scripted rival, legendary, gym and story encounters against the adapter's actual battle context.
- Match the selected dry/water art to independent mound materials and calibrated contact points.
- Complete the missing aspect-specific artwork, integrate the Gen 2 adapter, then perform the deferred batch gameplay checks.

The authoritative generated inventory is [gen2-art-plan.json](../metadata/gen2-art-plan.json); its source is [build_gen2_asset_plan.py](../tools/build_gen2_asset_plan.py). No game data or battle UI was modified during this review.
