# Asset release preparation

The alpha bundles its artwork. The production downloadable-pack index remains empty until real asset URLs are published and verified.

`tools/build_asset_packs.py` builds per-aspect HD packs from registered source entries, retaining separate day/night paintings, transparent mounds and inherited metadata. It creates deterministic ZIPs and unique flat release descriptors/payload names using full SHA-256 hashes. Nonempty output directories are rejected. Pass the actual repository, tag and version; QA output uses unpublished URLs and must not be shipped as a production index.

`tools/install_offline_pack.py` accepts an archive, descriptor and explicit cache directory ending in `mod_cache/hd-dynamic-battlefields`. Run while the game is closed. It checks the installed index before staging, verifies archive/member hashes and safe paths, then activates two-slot runtime commits. Runtime metadata/compatibility checks still apply.

`tools/verify_asset_packs.py` validated all nine HD aspect packs on 2026-10-15, including actual Lua runtime backend admission, torn-slot recovery, corrupt archive/index rejection, unsafe paths, removal/reimport and deterministic rebuild. See `evidence/pack-roundtrip-qa.json`. A real v0.3.88 GPU fixture used the imported cache with bundled entries removed: 28 alignment plus 36 variation renders passed; see `evidence/installed-pack-runtime-probe.txt`.

Remote download/update behavior, other artwork tiers and the full environment collection remain unfinished. Offline-imported QA packs are isolated from the user's game/cache.
