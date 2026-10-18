# Gen 2 beta release validation

The 0.2.0-beta.1 package adds Gold, Silver and Crystal support. The Gen 2
catalog contains 477 compositions across 53 environment families and nine
aspect families, including reused Gen 1 artwork. Map classification covers
485 native game/map signatures; water triggers resolve independently.

Release checks:

- 25 Lua regression files, including Gen 2 context, classification, scenery,
  night geometry, species positions, asset queue and schema validation.
- Native Gold/Silver/Crystal fixtures at classic, ultrawide and portrait sizes,
  with Menu Customizer 3.35.15 loaded through the actual v0.3.89 Loader/Sandbox.
- Tackle, Surf, Psychic and Earthquake animation fixtures in each game.
- Every source-backed pack passes the runtime metadata/PNG-header validator.
- Every indexed source file matches the immutable remote Git tree; HTTP
  checksum samples cover every pack. See source-artwork-verification.json.
- One actual compact pack exercises source-to-offline-archive creation and
  transactional offline import. Base ZIP members receive checksum validation.
- Release publication checks the exact uploaded asset set, byte lengths and
  GitHub SHA-256 digests before marking the release latest.

These are fixtures and integrity checks, not a full playthrough. Physical
Android performance, every species/scene mound contact point, link battles,
all transitions and custom UI profiles still need user testing. Battle UI
remains owned by the engine and the user's UI mod.
