# River scenes and tiny islets

Registered three original 16:9 river variations: willow bend, wooded gorge with distant cascade, and meadow footbridge. All have separate day/night paintings and matching independent tiny islet mound pairs: grass/pebbles, mossy rock and sand/reeds. River is available as a manual environment and through existing explicit Surf-water map classification. Other river aspect families and resolution tiers remain incomplete.

Initial visual review caught a small gap beneath the opponent feet on the rock islet. Added validated, inherited normalized mound image origins and calibrated the river opponent origin to `{0.5, 0.62}`. Default centered origins for existing scenes are unchanged. Pure checks cover invalid origins, metadata immutability, correct draw displacement and unchanged placement of the unrelated side.

After correction:

- All 12 pure Lua checks passed.
- Actual catalog audit decoded 152 registered PNGs and prepared 125 composition-period combinations. Source inventory records 158 images including unregistered/superseded studies.
- Official v0.3.88 Red renderer plus Menu Customizer 3.35.4 passed eight alignment renders at 1280x720, 1920x1080, 2560x1440 and 1281x721 in both periods, plus 12 variation renders. Every river/islet pair appeared in both periods.
- A separate fixture render selected river automatically for `ROUTE_10` with saved Surf state. Evidence is `river-automatic-context.json` and `river-automatic-surf-route-10.png`; this is not gameplay traversal proof.
- Archived batch records are `river-alignment-batch.json` and `river-variation-batch.json`.
- Visually inspected corrected rock day, grass day and sand night renders. Opponent feet meet the island surface and the island rests on water. Native UI/sprite calls and transforms remain unchanged.

Ocean scenes and Gen 1 fishing context were added and checked in the [ocean follow-up](ocean-islet-batch.md). Pond compositions remain inactive. Gameplay/physical-phone testing, further aspect families, other game adapters and final art approval remain open. The cascade is painted, not animated. No release approval is implied.
