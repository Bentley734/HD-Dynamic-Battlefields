# Offline artwork installation

Install the lightweight base mod first. Each screen ratio has its own artwork release. Choose `one` for one variation per area or `all` for all available variations. Download the selected ZIP and matching `.pack.json`, with the same aspect, quality, profile and version. Do not extract artwork ZIPs into the mods folder.

Close the game, then run the importer from the installed mod or source checkout:

```powershell
python tools/install_offline_pack.py --archive "path/to/chosen-pack.zip" --manifest "path/to/chosen-pack.pack.json" --cache "$env:APPDATA/pokemon-love2d/mod_cache/hd-dynamic-battlefields"
```

The importer verifies the archive and each file before committing installation. Restart and check Asset Manager > Installed Packs. Additional ratios install independently. To reclaim space after switching to compact, remove the previous full-variation counterpart. No ROM or saves are needed by the importer. Reimport the same verified pack to repair missing files.
