# Source-backed artwork downloads

The new distribution path keeps artwork in the repository's organized `art/`
tree instead of attaching every image to a release. Original and draft artwork
stays preserved; runtime packs reference only their selected compositions.
Historical release URLs remain accepted so older installs can still repair
their cached packs. No historical releases are deleted by this migration.

`metadata/distribution.lua` combines the independent runtime catalogs for
distribution, deduplicating shared Gen 1/Gen 2 composition IDs. It does not
change runtime game selection.

`tools/build_source_asset_packs.py` prepares nine HD aspect families, each with
one-variation and all-variation profiles. First run it without `--source-commit`
to prepare versioned `asset-packs/<version>/<pack>/compositions.json` files.
Commit those files together with every referenced original/derivative PNG.
Then run it again with the full source commit SHA. It checks each source's Git
blob identity against that commit before emitting any final pack/index URL.
The URL points to `raw.githubusercontent.com/<repository>/<40-char SHA>/<path>`;
mutable branch URLs and path traversal are rejected by the downloader.

Final pack descriptors carry SHA-256 hashes and installed sizes. The small
`asset-index.json` can accompany the lightweight mod release so existing update
discovery remains compatible; individual artwork files are source downloads.
This workflow creates no offline ZIP attachments. Offline users can build a
verified archive from a source checkout using tools/prepare_offline_source_pack.py,
then import it with tools/install_offline_pack.py. See OFFLINE-ASSET-INSTALL.md.

The first prepared set contains 18 pack definitions and 1,584 unique referenced
source files (4,387,630,692 bytes across both profiles and all sizes). Publication proof is recorded in
`docs/evidence/source-artwork-verification.json`: every referenced file is
checked against the immutable remote Git tree, with HTTP checksum samples
covering every pack and size.

The in-game DOWNLOAD ALL ASSETS action queues every size matching the selected
quality and variation profile, independently of the browse/display aspect
filter. Downloads remain sequential and each pack keeps its own transactional
verification/resume behavior. Batch failures stop the queue and appear in the
download error row; cancellation stops the active transfer.
