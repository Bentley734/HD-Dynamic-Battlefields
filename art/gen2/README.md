# Gen 2 artwork work in progress

## First-variation source milestone (2026-10-17)

All nine aspect families now have source candidates for the 21 new Gen 2 environments (189 paintings), with 27 separate outdoor night paintings. The 17 supplemental sources complete the warehouse and Underground passage gaps while reusing the existing Gen 1 Underground 16:9 source. The reuse inventory reports zero missing source compositions and zero missing referenced files. These counts establish source availability only: runtime catalog registration, mound matching, grounding calibration, integration, packaging and gameplay verification remain outstanding.

Final 32:9 additions: Radio Tower, Tin Tower rooftop day/night, harbor water day/night, post-eruption Cinnabar coast day/night, warehouse and Underground passage. Outdoor night crop rectangles preserve the painted moon; the warehouse retry uses a top-aligned crop to retain all lamp fixtures and reviewed clear standing regions. Original attempts and exact prompts remain under drafts, and crop provenance is recorded in authoring JSON. The first warehouse attempt was unsuitable for a scenery-preserving 32:9 crop and was not imported.

The 32:9 first-variation source set now also includes all seven distinct Johto gym interiors, Crystal Battle Tower, Dance Theater, Karen's chamber and Olivine Lighthouse. The additional reviewed crop plans are `metadata/gen2-reviewed-crops-gyms*.json` and `metadata/gen2-reviewed-crops-special-interiors.json`. Original generated paintings and exact prompts are retained in `art/gen2/drafts/32x9/`; each final source has crop provenance and transformed draft anchors. No gameplay testing or runtime enablement is implied.

On 2026-10-17 the user authorized trimming excess canvas from compositions generated for their requested ratios, preserving scenery and both Pokémon positions without stretching. Reviewed crop rectangles and source-space draft geometry are recorded in `metadata/gen2-reviewed-crops*.json`; `tools/trim_gen2_source.py` preserves originals, crops without resampling, transforms anchors and records provenance in each authoring file. These remain source candidates pending runtime calibration. Approved crops include three 32:9 tower interiors, Ruins of Alph, Dragon's Den, Lugia's chamber and the missing 9:19.5 Underground composition. Lugia's opponent standing anchor remains on dry limestone beyond the distant pool.

Gold, Silver and Crystal reuse suitable existing Gen 1 paintings and mounds
by reference. Do not copy shared PNGs into this folder or regenerate them
just to change the game name. Shared Kanto locations and common natural
habitats are tracked in `metadata/gen2-art-plan.json`.

New backgrounds use `<aspect>/<location>/<location>-<variation>-<aspect>.png`.
Exact built-in ImageGen prompts are alongside each location in `prompts/`.
All transparent mounds remain in the shared `art/mounds/<material>/` tree.

The planning audit reads actual locally imported Gold/Silver/Crystal map
and encounter metadata. Its candidate classifications are authoring aids,
not a claim of complete runtime integration or playthrough verification.
Scripted encounters, terrain subcases and artwork fit still need review.

First source candidates: Ruins of Alph underground chamber, Burned Tower
and Dragon's Den lake. Existing sandstone, charcoal floor and rock-islet mounds are material
candidates. Exact pairing and edge review remain pending; the first sandstone
cleanup was rejected for edge banding and preserved under mounds/sandstone/rejected.
Runtime grounding is unverified.

No battle UI changes are part of this artwork work. Gen 2 is not yet enabled
in the published Beta 2 build. Remaining aspect families, meaningful variants,
applicable outdoor night paintings and unique environments remain in progress.

Tin Tower variation 1 (16:9) is now a source candidate. Its initial painting was rejected because the rear wall overlapped the opponent standing region. The corrected painting keeps that region on clear floor; its authoring metadata records the approximate horizon and pending mound/runtime calibration. Current source-candidate counts are maintained in metadata/gen2-art-plan.json; those counts exclude further day/night and mound review.

Additional 16:9 source candidates: Lugia chamber, Azalea Gym and Mahogany Gym. Each includes an exact generation prompt and authoring JSON with image dimensions, checksum, approximate horizon, standing anchors and existing mound material candidates. No gameplay calibration is claimed.

Goldenrod Gym, Violet Gym and Olivine Gym now also have visually reviewed 16:9 source candidates with saved prompts and draft anchor metadata. The importer in tools/import_gen2_source.py preserves originals, refuses overwrites and checks that proposed mound materials exist; it does not register or certify runtime compositions. Carpet/stone colors remain candidates for a later matching pass.

Blackthorn Gym, Ecruteak Gym and Dance Theater now have 16:9 source paintings with exact prompts and draft calibration metadata. Reuse review: Gen 1 arena variations 1-3 have clear level floor and are possible Battle Tower sources; the room context must still be compared before making a final binding. No PNG copies or runtime substitutions were made for that reuse candidate.

Initial 16:9 authoring milestone: each of the 19 planned Johto-specific families now has a first source painting. The latest batch adds Olivine Lighthouse, Radio Tower, Karen's chamber, a compact Battle Tower room, and separate Tin Tower rooftop day/night paintings. The arena reuse review was not promoted to a binding because the imported Crystal room is compact and the existing arena art has grandstands/balconies. Existing shared Gen 1 scenery remains referenced for the other reuse candidates. This is source-art coverage only, not complete battle-location mapping or verified gameplay coverage.

Release scope update: the initial Gen 2 release now targets one variation per battle environment. Variations 2 and 3 are deferred. Dedicated aspect compositions and day/night sources still apply to variation 1; the authoring worklist records this release scope explicitly. Existing extra Gen 1 art is retained for reuse.

Dedicated 4:3 sources now also include Burned Tower, Lugia chamber and Azalea Gym, recomposed from their original 16:9 location references. The importer checks PNG dimensions against the requested aspect family and preserves the source files. Mound tone/edges and runtime placement remain pending calibration.

The first-variation 4:3 source-art set now covers all 19 planned Johto-specific families, including a separately painted Tin Tower rooftop night source. See docs/GEN2-4X3-SOURCE-PAINTINGS.md for exact saved image/prompt paths. Other aspect families and runtime calibration remain unfinished; this is not a gameplay support claim.

The 16:10 first-variation set is underway: Sprout Tower, Tin Tower, Burned Tower, Ruins of Alph, Dragon's Den and Lugia chamber are saved as dedicated compositions. See docs/GEN2-16X10-SOURCE-PAINTINGS.md for source and exact-prompt links. Sprout Tower's first low-wall draft was corrected before import; the original generated file remains preserved outside the project and both prompts are retained.


## First variation milestone: 16:10 complete

All 19 new Johto families now have first-variation source paintings in 4:3, 16:9 and 16:10 (57 base paintings), plus three separate rooftop night paintings. Exact prompts and original PNGs are retained. Initial release scope stays at one variation per environment. Six aspect families (114 base compositions), reuse mapping review, mound calibration, runtime integration and final validation remain pending. See ../../docs/GEN2-16X10-SOURCE-PAINTINGS.md for the 16:10 index.


## 3:2 source batch: first six families

Sprout Tower, Tin Tower, Burned Tower, Ruins of Alph, Dragon's Den and Lugia's chamber now have dedicated 3:2 originals with exact prompts and draft authoring metadata. See ../../docs/GEN2-3X2-SOURCE-PAINTINGS.md. These remain unregistered and uncalibrated source candidates.


## First variation milestone: 3:2 source set complete

All 19 new Johto environment families now have dedicated first-variation source paintings in 4:3, 16:9, 16:10 and 3:2 (76 base paintings), plus four separate rooftop night paintings. Exact prompts and original PNGs are retained. Five aspect families (95 base compositions), reuse mapping review, mound calibration, runtime integration and final validation remain pending. See ../../docs/GEN2-3X2-SOURCE-PAINTINGS.md. No gameplay tests were run during this art batch.


## First variation milestone: 21:9 source set complete

All 19 new Johto families now have dedicated originals in 4:3, 16:9, 16:10, 3:2 and 21:9 (95 base paintings), plus five separate rooftop night paintings. Exact prompts and draft metadata are retained. Remaining at that milestone: 32:9 and three portrait families (76 base compositions), reuse mapping review, mound matching/calibration, runtime integration and final validation. No gameplay tests performed during this art batch. See ../../docs/GEN2-21X9-SOURCE-PAINTINGS.md.

## First variation milestone: 9:16 source set complete

All 19 Johto families now have dedicated first-variation 9:16 portraits, including a separately painted rooftop night scene. Six aspect families are covered (114 base paintings and six rooftop night paintings). Remaining artwork: 57 base compositions across 32:9, 9:19.5 and 9:20, plus three rooftop night compositions. Original PNGs and exact built-in ImageGen prompts are preserved. Perspective metadata remains draft, not runtime-calibrated; mapping review, mound matching, integration and final gameplay validation are still pending. See [the portrait source and prompt index](../../docs/GEN2-9X16-SOURCE-PAINTINGS.md). No gameplay tests were run during asset authoring.
