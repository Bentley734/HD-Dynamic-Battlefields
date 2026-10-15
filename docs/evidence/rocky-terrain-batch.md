# Rocky terrain batch

Registered three original 16:9 rocky-terrain variations: granite canyon, slate gorge and limestone spire terrace. All have separate night paintings. Granite canyon also has dedicated ultrawide/portrait artwork. Mounds are separate transparent gravel assets; map taxonomy keeps rocky terrain separate from mountain and water environments.

Added a dedicated 4:3 granite composition with separately painted day/night artwork. Pale granite and limestone scenes now use their own pale gravel mound pair; the slate gorge retains the darker gravel pair. Original PNGs, prompts, alpha ranges and hashes are recorded in art/SOURCES.json (119 total source assets).

Pure suite passed. Official v0.3.88 native Red renderer with Menu Customizer passed a combined 46-render rocky batch: 10 alignment renders across 640x480, 1024x768, 1920x1080, 5120x1440 and 900x1600, plus 36 variation renders. Both day/night periods were exercised. Current alignment-batch.json and variation-batch.json record this batch, replacing earlier snapshots. Native UI/sprite calls and transforms remain unchanged.

Visually reviewed 4:3 day/night and ultrawide day. Native opponent feet meet the mound and floor remains behind contact. The pale day mound blends more closely into the floor; night mound edge/contrast still merits final art review. No saturated cyan rim appears on the new mound surfaces; pixel inspection found cyan outliers only at near-transparent alpha (at most 8/255). These remain prototype candidates rather than approved release art.

The initial broader alignment attempt stopped at 1280x800 because rocky terrain had no dedicated 16:10 artwork and fell back to native rendering. That gap is now addressed by the follow-up [nine-aspect batch](rocky-nine-aspects.md), whose JSON evidence replaces this earlier 46-render snapshot. The Python probe runner now returns failure when the fixture writes its error report, even if LÖVE exits with code zero. Gameplay traversal, other game adapters, additional variations and resolution tiers remain incomplete/unverified.
