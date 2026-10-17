# Gen 1 location subtype review

Static source/map inventory, 2026-10-16. This tracks unfinished scenery classification work; it is not a runtime test or a claim that every mapped context hosts a native battle.

## Completed local refinement

S.S. Anne's `SS_ANNE_BOW`, `SS_ANNE_KITCHEN` and `SS_ANNE_CAPTAINS_ROOM` now select their own three-variation widescreen sets. Normal halls and passenger cabins keep the ordinary ship-interior set. Existing exact map IDs and tileset guards are retained. See `GEN1-SHIP-AREAS-ASSET-BATCH.md`.

`BILLS_HOUSE`, `BIKE_SHOP`, `POKEMON_FAN_CLUB` and `FUCHSIA_MEETING_ROOM` now have named classifications and three original widescreen paintings each, with matching independent materials and constant interior climate. They no longer use the generic `interior` category. Other aspects and native validation remain pending. See `GEN1-NAMED-ROOMS-ASSET-BATCH.md`.

League reception, all four Safari rest lodges and both Viridian Forest gates now have separate exact classifications, three original widescreen scenes each, matching materials and explicit interior climate. See `GEN1-LOBBY-LODGE-GATES-ASSET-BATCH.md`.

The Celadon store first-floor reception and elevator now each have three original widescreen scenes, independent materials and exact map classifications. Sales floors and rooftops remain unfinished. See `GEN1-DEPARTMENT-RECEPTION-LIFT-ASSET-BATCH.md`.

The second-floor supplies department and third-floor TV/game department now each have three original widescreen scenes, separate classifications and matching materials. See `GEN1-DEPARTMENT-SUPPLIES-ELECTRONICS-ASSET-BATCH.md`.

The fourth-floor gift and stone department now has three original widescreen scenes with independent materials and an exact classification. See `GEN1-DEPARTMENT-GIFTS-ASSET-BATCH.md`.

The fifth-floor training department now has three original widescreen scenes, independent materials and exact routing. The two rooftop locations below remain on this refinement list. See `GEN1-DEPARTMENT-TRAINING-ASSET-BATCH.md`.

The department-store rooftop now has three original widescreen day/night pairs, explicit outdoor climate and exact map routing. Celadon Mansion rooftop remains. See `GEN1-DEPARTMENT-ROOF-ASSET-BATCH.md`.

## Named-location refinement list

The previously listed named locations now have dedicated widescreen artwork registered locally, including three Celadon Mansion rooftop day/night pairs. Its ROOF_HOUSE remains an indoor house. See `GEN1-MANSION-ROOF-ASSET-BATCH.md`.

No rows remain on this specific refinement list. This is not proof that the full Gen 1 asset inventory, every aspect family or runtime coverage is complete. Those remain release gates.

Keep classification refinements data-driven. Do not add fabricated native battles to justify an art category. Where no ordinary native battle exists, describe it as special-context/manual coverage and verify its behavior separately if another mod introduces a battle there.

The general gate, underground passage, Game Corner/prize-room, hotel, museum fossil/space gallery, restaurant, link Colosseum/communication-room and Hall of Fame categories now each have three widescreen compositions registered locally. This does not finish the named-location refinements in the table above. All dedicated remaining aspect families, material matching, sprite-offset controls and release validation remain open in `GEN1-RELEASE-READINESS.md`.
