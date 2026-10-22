# HD Dynamic Battlefields — 0.3.0-beta.7

Keep the Gen 1 battlefield visible when the level-up stats window opens. The
native stats window is a transparent overlay, so it now retains its underlying
battle and selected scenery instead of falling back to a white screen.

- Keeps the same background, day/night artwork and active battle variation.
- Leaves sprites, faint visibility, battle input and UI rendering with the game
  and the user's UI mod. No Pokémon positions or mound calibration change.
- Party, Bag, summary and other unrelated or opaque screens retain their normal
  native presentation; they do not expose battle scenery behind them.

Install **HD-Dynamic-Battlefields-0.3.0-beta.7-base.zip**, replacing the previous
mod folder, then restart G1R. Update **Menu Customizer 3.35.23** too for the
matching level-up HP/status UI fix. Requires G1R **0.3.95**. **Existing artwork
downloads remain compatible; no artwork redownload is needed.**

Focused tests cover the native battle-context lookup, strict child-screen
fallbacks, unchanged battler state, and scenery retention across nine viewport
sizes in day and night. Seven combined native GPU cases also pass in Red, Blue
and Yellow with Menu Customizer, including 1280x720 and 480x360 windows, opponent
visibility, HUD layering, stats dismissal, and Bag/Party transitions. These
constructed tests do not constitute a complete gameplay playthrough or Android
hardware test.
