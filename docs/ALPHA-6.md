# Alpha 6 — enemy mound contact adjustment

Moves the opponent mound up three native game pixels (contact slot y=56 → 53) to bring its surface beneath Rattata's back feet. Both sides retain the doubled mound dimensions. Native Pokémon sprites and battle UI do not move. Saved mound offsets remain relative to the new default.

Checked with the pure Lua suite and official v0.3.88 Red/Menu Customizer 3.35.4 renderer at 1920×1080, 5120×1440 and 900×1600 in both periods. Native draw calls/transforms remain unchanged. This does not prove contact for every replacement sprite or species.

The full ZIP includes all current art. The Alpha 4/5→6 patch requires an existing Alpha 4 or Alpha 5 installation: close the game, merge the included hd-dynamic-battlefields folder over the existing mod, and replace its files. The patch also includes Alpha 5's doubled player mound. Earlier alphas should use the full ZIP. All broader Alpha 4 coverage limitations remain.
