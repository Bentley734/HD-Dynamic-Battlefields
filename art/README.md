# Artwork library

Backgrounds: `gen1/<aspect ratio>/<location>/<image>.png`.
The current Gen 1 paintings also serve FireRed/LeafGreen where appropriate.
Shared images are kept once. Future Gold/Silver/Crystal artwork belongs in
`gen2/<aspect ratio>/<location>`.

All mound cutouts, including originals, revisions and cleaned derivatives,
are in `mounds/<material>/`. Matching generation prompts live in a `prompts/`
subfolder beside their images. Mound previews are in `previews/mounds/`.

Aspect folders such as `16x9`, `4x3` and `9x19_5` identify the authored shape.
Actual pixel dimensions remain in `SOURCES.json`; nothing was resized.
Day/night paintings and rejected studies retain their original filenames.

`RELOCATIONS.json` records every former path, new path, size and SHA-256.
`SOURCES.json` preserves provenance; `derivatives.json` records mound ancestry.
Historical release evidence retains its original release paths.
