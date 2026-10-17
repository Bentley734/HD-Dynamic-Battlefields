# Gen 1 release work

Current milestone: finish actual Red/Blue/Yellow battlefield coverage, integrate it, run a combined release validation batch, then publish. Later-generation desert, snowfield, glacier and swamp environments are outside this milestone.

## Integrated locally, awaiting validation

- Original widescreen room sets for all eight gyms, Fighting Dojo, all four Elite Four rooms, Champion, houses (including plain carpet variants), laboratories, Power Plant, S.S. Anne interiors, Pokémon Tower and Pokémon Mansion.
- Widescreen village and city day/night sets.
- Three widescreen variations each for Rocket Hideout, Silph Co., Safari woodland day/night, Cerulean deep cave, Seafoam coastal cave and underground water.
- Three widescreen day/night variations each for Cycling Road, Route 20/21 land coast, and Vermilion dock, with six selected cleaned road/dock day/night materials and explicit land-versus-ocean context routing.
- Three widescreen day/night variations each for Indigo Plateau courtyard, the distinct Route 23 badge-check approach, Cinnabar island town and Vermilion harbor-city surroundings. Route 23 water encounters now have an explicit inland pond classification, supported by the official runtime's swimming badge-guard scripts. Runtime confirmation remains pending.
- Cleaned siblings for the older gray-floor, blue carpet and burgundy carpet materials; painted interiors and originals retained, perimeter artifacts removed under explicit user authorization.
- Three widescreen constant-light variations each for Mewtwo, Articuno, Zapdos and Moltres, connected to the existing exact species/map encounter classifications. Three newly authored cave floor materials have cleaned selected siblings with source provenance. Safari scenery's old prototype exclusion is removed; Safari runtime/compatibility behavior remains untested.
- Psychic Gym material choices now match the lavender room floors. Lorelei's seamless blue rooms use the cleaned non-grid ice material and her solid white pavilion uses the ivory floor material. Authored uniform source framing drafts raise several low generated room/night boundaries without moving native battlers or UI.
- Three widescreen variations each for the S.S. Anne foredeck, kitchen and captain's cabin, with separately painted foredeck day/night scenes. Exact ship map categories distinguish these areas from ordinary halls and passenger cabins. Foredeck is explicitly outdoor; cabin and kitchen use constant interior lighting. Native framing/selection behavior is untested.
- Three widescreen variations each for Pokémon Center receptions/rest lounge and ordinary supply shops, using matching ivory/gray/sage/beige materials and explicit interior climate. Service-location artwork does not establish ordinary native battles there; named League reception coverage is recorded below.
- Three widescreen variations each for general road-gate interiors and underground pedestrian passages, with independent matching materials, source-reviewed metadata and explicit constant interior climate. Forest gates and Safari rest lodges have separate coverage recorded below.
- Three widescreen variations each for Celadon's hotel, diner, Game Corner gaming hall and separate prize counters, with matching materials and explicit interior climate. The selected gaming hall sources use corrected mechanical reel/lever machines; initial videogame-cabinet studies are excluded.
- Three widescreen variations each for Pewter's downstairs fossil/amber galleries and upstairs space galleries, using separate exact floor classifications, matching independent materials and indoor climate. Native framing/material behavior remains untested.
- Three widescreen variations each for the link Colosseum, communication rooms and Hall of Fame recording rooms, with separate map classifications, matching independent materials and indoor climate. Actual link-battle map selection and special-context rendering still require native validation.
- Three widescreen variations each for Bill's research cottage, Cerulean Bike Shop, Vermilion Fan Club and Fuchsia meeting room. Exact named map classifications replace their generic interior category; independent floor/carpet materials and constant interior climate are configured. Native behavior remains untested.
- Three widescreen variants each for League reception, Safari rest lodges and Viridian Forest gates, with exact map classifications, matching materials and constant interior climate. Source framing and native behavior remain unvalidated.
- Three widescreen variants each for Celadon department-store reception and its enclosed elevator, with independent materials, exact map classifications and interior climate. Other sales floors and rooftops are still unfinished.
- Three widescreen variants each for Celadon trainer supplies (2F) and TV/game sales (3F), with explicit floor classifications, matching independent materials and indoor climate. Floors 4F/5F and rooftops remain unfinished.
- Three widescreen gift/stone department variants for Celadon 4F, with matching materials and exact routing. Fifth floor and rooftops remain unfinished.
- Three widescreen training-department variants for Celadon 5F with matching materials, exact map assignment and indoor climate. Both rooftop locations remain unfinished.
- Three widescreen day/night pairs for Celadon department-store rooftop, with independent concrete materials, explicit outdoor climate and exact routing. Mansion rooftop remains unfinished.
- Three widescreen day/night pairs for Celadon Mansion rooftop, matching independent concrete materials, exact outdoor routing; the separate roof house stays indoors. This closes the current named-location refinement list, not the full asset/aspect inventory.
- Three widescreen enclosed cabin variants each for Silph Co. and Rocket Hideout lifts, with independent materials and exact map assignments.
- All three ocean variations now have separate day/night paintings registered for all nine display families, including authored framing where generated dimensions differed from the requested aspect. Native calibration remains unfinished.
- All three pond variations now have separate day/night paintings registered for all nine display families. Source regions and mound contact still require the final combined native review.
- All three river variations now have separate day/night paintings registered for all nine display families. Authored regions correct generated aspect mismatches; source composition, material blending and native grounding still require the combined review.
- All three beach variations now have separate day/night paintings registered for all nine display families. Dune-lagoon and volcanic-cove source regions keep dry sand under the opponent standing zone; the combined native review must confirm contact and material blending.
- All three ordinary cave variations now have constant-light original paintings registered for all nine display families. Sandstone and limestone are distinct sets with independent matching mounds. Dedicated special caves remain separate categories; source framing and native grounding remain untested.
- All three grassland variations now have original independent day/night paintings registered across all nine display families. Chalk-downland source-region drafts raise low generated night hills; final native composition and mound blending remain untested.
- All three forest variations now have original independent day/night paintings registered across all nine display families. The autumn birch grove uses independent autumn mounds and authored source regions to raise low generated fern banks. Earlier preferred forest art remains saved; native calibration remains untested.
- All three mountain variations now have independent day/night paintings registered across all nine display families. Granite-basin and terracotta-plateau framing and matching mound materials remain drafts pending native calibration.
- All three rocky-terrain variations now have independent day/night paintings registered across all nine display families. Slate gorge uses gravel mounds and limestone terrace uses pale-gravel mounds. Framing, material blending and contact remain pending native review.
- Hillside village variation 1 now has independent day/night paintings registered for all nine families and independent packed-earth mound materials with authorized cleaned edges. Contact and material blending await native review.
- Coastal village variation 2 now has independent day/night artwork registered across all nine families. Its grass mounds are replaced with separate day/night sand materials; source framing and material blending still await native review. The garden-village batch completes the third variation�s source aspect set.
- All three village variations now have independent day/night paintings registered across all nine display families. Garden village uses pale-gravel mounds, coastal village sand and hillside village packed earth. Native framing, grounding and material blending remain untested.
- Residential city variation 1 now has independent day/night paintings registered across all nine display families, with separate asphalt mound materials. Remaining city variations, native source framing and material blending are unfinished.
- Shopping plaza city variation 2 now has independent day/night paintings registered across all nine display families, with separate concrete mound materials. Storefront framing, contact and blending await native review; city variation 3 remains unfinished.
- Newly completed dedicated aspect paintings for the first grassland, forest, cave, beach and river variations. These extend each first variation to all nine aspect families without a renderer change.
- Existing explicit map IDs and tileset guards select these environments. Unknown contexts keep the native fallback.

These registrations are development changes, not evidence of calibration or runtime success. Material blending, horizon framing, transparent decal edges, all display families, and native/other-mod UI preservation must pass the combined release review. Indoor sets currently use constant indoor lighting; their separately saved night paintings are not silently used as outdoor environments.

## Missing artwork / routing still to finish

- Static source planning inventory now covers 224 explicit map rows and 81 environment keys (including water and exact legendary contexts). See `GEN1-SOURCE-ART-INVENTORY.md`. Candidate filename counts are not selected/validated composition totals. Silph Co. and Rocket Hideout lifts now have separate enclosed widescreen scene sets and exact classifications; native framing and remaining aspects are pending.

- Rocket Hideout, Silph Co., Safari woodland, Cerulean deep cave, Seafoam coastal cave and underground water each have three widescreen variations registered. Dedicated other aspects, matching materials and native grounding review are pending. Do not substitute snowy outdoor art for Seafoam.
- Cycling Road, Route 20/21 coast, Vermilion dock and harbor city, Cinnabar town, Indigo Plateau and the Route 23 approach have their three widescreen day/night source pairs registered. Dedicated display compositions and native grounding/blending review remain pending.
- Mewtwo, Articuno, Zapdos and Moltres now have three widescreen paintings and local registrations each. Dedicated remaining aspects and native grounding/material review are pending.
- S.S. Anne bow, kitchen and captain's cabin now have distinct widescreen artwork and explicit subdivisions. Their remaining display compositions and native framing/material review are pending.
- Bill's cottage, Bike Shop, Fan Club and meeting room now have three named widescreen scenes each. The Colosseum, communication rooms, Hall of Fame, museum categories and other service/interior sets also have three widescreen sources registered; remaining aspects, grounding/material review and distinct subtype handling are pending. Some service/special contexts do not host ordinary native battles; retain that distinction when reporting battle coverage.
- The current named-location refinement list is closed with widescreen art. Reconcile the complete map/context inventory against registered assets before claiming full coverage; remaining display families and material calibration are still unfinished. See `GEN1-LOCATION-SUBTYPES.md`.
- Dedicated non-widescreen room compositions, remaining variation/aspect counterparts, matching mound materials and lighting, source-region calibration.

## Release gates

- Complete the actual Gen 1 asset/routing inventory before the combined test batch.
- Retain Alpha 6 doubled mound dimensions and the opponent's three-native-pixel upward adjustment.
- Finish independent player/opponent sprite X/Y controls without changing default native positions or owning the battle UI.
- Use the latest official Gen1Recomp available at test time in an isolated copy. Leave the user's running installation and saves alone.
- Validate source, map/context selection, day/night, all supported display families, grounding and UI compatibility together; package only selected assets and publish verified GitHub release assets after success.

No new release or current-test result is claimed by this document. Alpha 6 remains the latest published build.

- City variation 3 park-side boulevard: eight additional original day/night aspect pairs registered; all three city variations now have nine source families. Native review remains pending; see CITY-03-ASPECT-ASSET-BATCH.md.

- Cave-water variation 1: eight added aspect originals and data registrations; constant cave lighting, independent rock islets retained. Native review pending. Other cave-water variants remain open.

- Cave-water variation 2: eight new original aspect compositions registered. Broad ivory mineral cavern, constant lighting, independent rock islets; native calibration pending. Third variation remains open.

- Cave-water variation 3: eight new original aspect compositions registered. All three cave-water sets now cover nine source families. Native calibration and blending remain pending; no tests or publication.

- Deep cave variation 1: eight added aspect compositions, four creature-contaminated outputs replaced with reviewed empty-scene v2 edits. Failed originals rejected and unselected. Native calibration pending.

- Scope update: remaining aspect artwork is restricted to native trainer/wild/static battle locations. Non-battle locations deferred, existing originals retained. See GEN1-ASPECT-SCOPE.md.

- Deep cave variation 2: eight original empty-cavern aspect sources registered; visual authoring review only, native calibration pending.

- Deep cave variation 3: eight new empty-scene sources registered. All three deep-cave sets now cover nine source families; draft framing, native review pending. Remaining non-battle aspect work deferred.

- Seafoam cave variation 1: eight original empty-scene aspect paintings registered; native calibration pending. Other two variations remain incomplete.

- Seafoam cave variations 2/3: sixteen original aspect sources registered; all three Seafoam cave sets cover nine source families. Visual review only, native calibration pending.

- Safari woodland variation 1 now has independent day/night artwork for all nine aspect families; selected source regions and grass mounds registered. Variations 2/3 remain widescreen-only. Native framing and compatibility are untested; no tests run during the asset hold.

- Safari woodland variation 2: eight independent day/night landscape originals saved and registered for 4:3, 16:10, 3:2 and 21:9. Portrait/superwide remain pending; no native validation yet.

- Safari woodland variation 2 now covers all nine aspect families with separate day/night originals. Variation 3 still widescreen-only. No tests run; native framing and mound blend remain pending.

- All three Safari woodland variations now have original day/night source art for all nine aspect families. Aspect metadata and independent mounds registered. Native calibration, material blend and compatibility remain untested.

- Pokemon Mansion entrance-hall variation 1 now has original source art across all nine aspect families, with constant interior lighting and independent burgundy carpet mounds. Variations 2/3 still need other aspects. Native framing and material blend remain untested.

- Pokemon Mansion study variation 2 now has original source art across all nine aspect families, with uniform source regions and independent gray floor mounds. Variation 3 still needs other aspects. Native validation remains deferred.

- All three Pokemon Mansion variations now have original source art across all nine aspect families with independent materials and aspect framing metadata. Native calibration and material blend remain untested.

- Champion reception variation 1 now has original art across all nine aspect families, with independent blue carpet mounds and uniform source framing. Variations 2/3 remain widescreen-only; native validation deferred.

- Champion glass rotunda variation 2 now has original source art across all nine aspect families, with uniform source regions and independent ivory floor mounds. Variation 3 remains widescreen-only; native validation deferred.

- All three Champion variations now have original source artwork across all nine aspect families with uniform framing and independent materials. Native calibration and material blending remain untested.

- Coastline variation 1 has eight new independent day/night landscape originals for 4:3, 16:10, 3:2 and 21:9, registered with independent sand mounds and uniform source framing. Superwide/portrait remain pending; no native validation.

- Coastline variation 1 now has independent day/night source paintings for all nine aspect families. Uniform framing and separate sand mounds registered; native calibration and material blend remain untested.

- Coastline variation 2 has independent day/night landscape originals for 4:3, 16:10, 3:2 and 21:9 registered with source framing and sand mounds. Superwide/portrait pending; no native validation.
