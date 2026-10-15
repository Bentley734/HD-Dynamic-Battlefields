# HD Dynamic Battlefields
## Complete Gen1Recomp Battlefield Overhaul — Development Specification

### Project Objective

Create a completely new, standalone, high-definition battlefield overhaul for **Gen1Recomp**, supporting Pokémon Red, Blue, Yellow, Gold, Silver, Crystal, FireRed, LeafGreen, Ruby, Sapphire, and Emerald wherever supported by the installed Gen1Recomp runtime.

Use **Kanto in Motion / KIM1025** as the primary visual reference. Match its illustrated art style, battlefield perspective, environmental depth, lighting, and overall presentation as closely as practical, while creating entirely original artwork and a new rendering implementation.

Do not reuse, upscale, recolor, or redistribute KIM1025's existing background assets.

The finished mod must feature:

- Three to five original HD battlefield variations for every distinct environment type.
- Dedicated compositions for all major desktop, ultrawide, tablet, and mobile aspect ratios.
- Day/night lighting and weather-dependent visual effects.
- Optional animated environments with configurable performance settings.
- Independent Pokémon battle mounds that blend naturally into each environment.
- Automatic mound and Pokémon positioning, with manual calibration options.
- **A shared, data-driven perspective and anchor metadata system for every battlefield composition.**
- Randomized or fixed background selection.
- Downloadable asset packs hosted on GitHub Releases.
- A lightweight base installation with reliable offline fallbacks.
- Compatibility with existing Pokémon sprite, Pokédex, and battle interface mods.

The overarching goal is to create the most visually polished, versatile, and immersive battlefield system possible without compromising performance, stability, or correct Pokémon positioning.

---

## 1. Technical Research and Architecture

Before writing implementation code, inspect the actual Gen1Recomp runtime, modding APIs, game identifiers, battle rendering pipeline, texture replacement mechanisms, viewport handling, and configuration systems.

Study KIM1025 to understand its visual design, perspective, sprite placement, rendering approach, and handling of different display configurations.

Use that knowledge as reference material, not as code or artwork to copy.

Design the mod as a modular system consisting of:

1. Game-specific adapters.
2. Map and environment classification.
3. Background selection.
4. Battlefield rendering.
5. Shared perspective and anchor metadata.
6. Independent mound rendering.
7. Pokémon sprite grounding and alignment.
8. Time-of-day and weather effects.
9. Optional environmental animation.
10. Viewport and aspect-ratio management.
11. Asset downloads, validation, and caching.
12. Configuration, diagnostics, and compatibility management.

Keep shared functionality independent of game-specific code wherever possible.

Investigate which APIs actually exist before relying on networking, filesystem access, archive extraction, runtime texture loading, or custom rendering hooks.

Document unsupported capabilities and implement compatible alternatives rather than nonfunctional features.

## 2. Original HD Battlefield Artwork

Create a cohesive collection of entirely original, beautifully illustrated battlefield environments.

Maintain consistent artistic direction across the entire collection, closely inspired by Sugimori pokemon artwork, Kanto In Motion/KIM1025's perspective, colors, environmental depth, and Pokémon-inspired presentation.

### Environment categories

Support all distinct environment types encountered across the supported games, including:

**Natural environments**
- Grasslands and open plains
- Tall grass and flower-filled meadows
- Forests and woodland clearings
- Dense and dark forests
- Mountains, hills, and cliffs
- Rocky terrain and canyons
- Caves and underground tunnels
- Deep caves and volcanic areas
- Beaches and sandy coastlines
- Rivers, lakes, and ponds
- Open ocean and underwater environments
- Deserts and arid landscapes
- Snowfields and frozen environments
- Icy caves and glaciers
- Swamps, marshes, and wetlands

**Civilization and interiors**
- Small towns and villages
- Large cities and urban streets
- Houses and ordinary buildings
- Laboratories and research facilities
- Industrial facilities and warehouses
- Pokémon Centers and special interiors
- Gyms and training facilities
- Battle arenas and stadiums
- Cruise Ship Interiors

**Special environments**
- Pokémon League arenas
- Elite Four chambers
- Champion battlefields
- Legendary encounter locations
- Ancient ruins and temples
- Ghostly or supernatural environments
- Important story-specific locations

Inspect actual game maps and battle conditions to refine these categories. Do not force visually distinct environments into generic backgrounds simply to reduce the number of assets.

### Background variations

Create **three to five genuinely distinct background variations per environment category**.

Variations must feature meaningful differences in composition, scenery, lighting, and environmental details—not simple flips, recolors, or minor edits.

All variations must maintain consistent battlefield perspective and Pokémon grounding.

Special locations may have unique backgrounds in addition to their general environment category.

## 3. Aspect-Ratio-Specific Artwork and Resolution Support

Every battlefield must fill the available battle viewport without black bars, distortion, obvious seams, or awkward cropping.

Create dedicated compositions for:

| Aspect ratio | Target |
|---|---|
| 4:3 | Classic displays |
| 16:9 | Standard widescreen |
| 16:10 | Laptops and tablets |
| 3:2 | Tablets and laptops |
| 21:9 | Ultrawide displays |
| 32:9 | Super-ultrawide displays |
| 9:16 | Mobile portrait |
| 9:19.5 | Modern smartphone portrait |
| 9:20 | Tall smartphone portrait |

Support intermediate aspect ratios and device-specific viewport constraints through intelligent layout selection.

### Composition requirements

- Detect the actual battle viewport rather than assuming the display resolution.
- Automatically choose the most suitable artwork and perspective metadata.
- Support live window resizing.
- Support mobile orientation changes.
- Preserve consistent Pokémon scale and perspective.
- Protect critical Pokémon and HUD regions from cropping.
- Never stretch artwork disproportionately.
- Extend ultrawide compositions naturally rather than stretching standard widescreen artwork.
- Compose portrait artwork specifically for the available vertical space.

The 32:9 layout must be tested at **5120×1440**.

### Quality tiers

Separate artwork composition from texture resolution.

Provide:

- **Mobile:** Optimized texture resolution and memory usage.
- **HD:** High-quality desktop assets.
- **Ultra-HD:** Maximum-detail artwork for large and ultrawide displays.

Do not generate redundant full-resolution assets for every individual display resolution.

Use reusable compositions and appropriate scaling within each aspect-ratio family.

## 4. Independent Pokémon Battle Mounds

Create a dedicated rendering system for the platforms or mounds that Pokémon stand on.

**Mounds must never be baked into the background artwork.**

Render them as separate transparent assets with independent positioning, scaling, and layering.

### Mound types

Create appropriate mound designs for:

- Grass and flowers
- Dirt and soil
- Sand
- Rock and gravel
- Forest vegetation
- Snow and ice
- Cave stone
- Water surfaces
- Indoor flooring
- Gym platforms
- Special arenas

Create additional variations where needed to match individual battlefield compositions.

Each battlefield must support separate player-side and opponent-side mound configurations.

### Pokémon grounding

Preserve the general battle perspective established by KIM1025.

Ensure that:

- Pokémon appear naturally grounded on their mounds.
- Mound textures and lighting match the surrounding environment.
- Pokémon do not float or appear embedded in the ground.
- Shadows align correctly.
- Large Pokémon retain appropriate grounding.
- Flying Pokémon preserve intended hovering offsets.
- Sprite replacements do not automatically break positioning.
- Mounds remain stable during resizing and orientation changes.

Use appropriate sprite contact points rather than assuming every Pokémon's feet are at the geometric center of its image.

Support species-specific or sprite-specific offsets where the runtime allows.

### Manual adjustment controls

Provide options for:

- Player mound horizontal and vertical offsets.
- Opponent mound horizontal and vertical offsets.
- Independent mound scaling.
- Player Pokémon positioning offsets.
- Opponent Pokémon positioning offsets.
- Resetting positions to recommended defaults.

Store user adjustments separately from the original layout metadata.

Allow global settings and aspect-ratio-specific overrides.

Apply changes immediately when technically possible.

## 5. Shared Perspective and Anchor Metadata System

**This is a core architectural requirement, not an optional enhancement.**

Implement a completely data-driven perspective and anchor metadata system, independent of the artwork and rendering engine.

Every battlefield composition must have an associated metadata definition.

### Metadata requirements

Each definition must contain:

- Unique composition identifier.
- Reference canvas dimensions.
- Aspect-ratio family.
- Horizon position.
- Perspective and depth parameters.
- Player mound anchor coordinates.
- Opponent mound anchor coordinates.
- Player Pokémon grounding coordinates.
- Opponent Pokémon grounding coordinates.
- Default mound scales and offsets.
- Sprite depth and layering rules.
- Pokémon shadow positioning.
- Safe boundaries for Pokémon and HUD elements.
- Optional environmental lighting parameters.
- Optional composition-specific corrections.

Use normalized coordinates relative to the reference viewport whenever appropriate.

Background variations sharing the same perspective should inherit common metadata templates.

Individual compositions may override only the properties that differ.

### Runtime behavior

Whenever a battlefield loads, the renderer must:

1. Identify the selected background composition.
2. Load its corresponding perspective metadata.
3. Validate the metadata and resolve inherited properties.
4. Calculate final positions using the current viewport.
5. Position the player and opponent mounds.
6. Align Pokémon sprites using their grounding anchors.
7. Apply any species-specific sprite corrections.
8. Apply saved user adjustments.
9. Render all elements using the appropriate layering and perspective.

The positioning system must remain stable across aspect ratios, quality tiers, and window resizing.

### Critical architectural rules

1. **Adding a new battlefield must not require modifying the rendering engine.**
2. Adjusting one battlefield's alignment must not affect unrelated battlefields.
3. Every aspect-ratio composition must load its appropriate metadata.
4. User adjustments must never overwrite the original metadata.
5. Missing or invalid metadata must trigger safe fallback positioning.
6. Metadata must be versioned and validated when loading asset packs.
7. Rendering code must not contain hardcoded per-background coordinates.
8. Mound assets must remain interchangeable with compatible backgrounds.
9. Shared perspective templates should minimize redundant configuration.
10. The metadata format must support future environments without structural redesign.

### Developer calibration mode

Create a developer-facing calibration mode that overlays:

- Horizon guides.
- Player and opponent anchor points.
- Mound boundaries.
- Pokémon grounding markers.
- Safe viewport boundaries.
- Perspective reference lines.
- Current normalized coordinates.

Allow developers to adjust anchors visually and export updated metadata where supported.

The purpose is to make correcting battlefield alignment straightforward without repeatedly changing Lua rendering code.

### Example metadata structure

The following is a conceptual schema, not an assumption about the runtime's exact file format:

```json
{
  "schema_version": 1,
  "composition_id": "forest_clearing_01_32x9",
  "inherits": "forest_perspective_template",
  "reference_size": {
    "width": 5120,
    "height": 1440
  },
  "aspect_ratio": "32:9",
  "horizon_y": 0.42,
  "player": {
    "mound_anchor": [0.30, 0.78],
    "pokemon_ground_anchor": [0.30, 0.75],
    "mound_scale": 1.0
  },
  "opponent": {
    "mound_anchor": [0.72, 0.52],
    "pokemon_ground_anchor": [0.72, 0.49],
    "mound_scale": 0.72
  },
  "safe_area": {
    "left": 0.03,
    "top": 0.04,
    "right": 0.97,
    "bottom": 0.96
  }
}
```

All example coordinates must be calibrated against actual rendered battlefields rather than treated as final values.

## 6. Dynamic Day/Night and Weather

Implement environment-aware lighting and weather variations.

### Time of day

Support at minimum:

- Day
- Night

Sunrise and sunset lighting may be added where practical.

Use in-game time where available.

For games without native day/night systems, provide system-local-time and manual-selection options.

### Weather

Support appropriate conditions such as:

- Clear skies
- Rain
- Snow
- Sandstorms
- Fog and mist
- Harsh sunlight
- Other game-supported weather effects

Use actual battle weather or map metadata whenever available.

### Asset efficiency

Avoid multiplying full-resolution background files for every combination of weather, time, and aspect ratio.

Prefer reusable lighting overlays, atmospheric layers, and environmental effects.

Create dedicated weather-specific compositions only when necessary for convincing visual results.

## 7. Optional Environmental Animation

Add subtle animations to bring environments to life.

Examples include:

- Moving grass and foliage.
- Flowing rivers.
- Ocean waves.
- Moving clouds.
- Falling rain and snow.
- Drifting fog.
- Flickering lights.
- Atmospheric particles.

Animations must preserve the illustrated visual style and avoid distracting from Pokémon battles.

### Animation quality settings

Provide:

- OFF
- LOW
- MEDIUM
- HIGH

OFF must disable unnecessary animation processing.

LOW should prioritize mobile performance.

HIGH may enable more detailed effects.

Use efficient animation techniques supported by the runtime.

Avoid unnecessary full-screen texture updates and per-frame asset allocations.

## 8. GitHub Releases Asset Distribution

Keep the base mod package lightweight.

Host downloadable background and effect assets through **GitHub Releases**.

### Asset manifest

Maintain a versioned asset manifest containing:

- Pack identifiers.
- Asset versions.
- Aspect-ratio families.
- Quality tiers.
- Included environments.
- Download URLs.
- Compressed and installed sizes.
- SHA-256 checksums.
- Compatibility requirements.
- Metadata schema versions.
- Optional dependencies.

Every downloadable composition must include or reference its corresponding perspective metadata.

Do not allow artwork and positioning metadata to become mismatched after updates.

### In-game asset manager

Add:

**OPTIONS → HD BATTLEFIELDS → ASSET MANAGER**

Include:

- Recommended pack for the current display.
- Browse available aspect ratios.
- Select quality tier.
- Download packs.
- View progress.
- View installed packs.
- Verify assets.
- Check for updates.
- Remove unused packs.
- Restore missing assets.

Allow users to install multiple aspect-ratio packs simultaneously.

### Download reliability

Implement:

- Temporary downloads.
- Integrity verification.
- Safe installation.
- Interrupted download recovery where supported.
- Corrupt archive detection.
- Compatibility validation.
- Clear error messages.
- Offline fallback support.

Never replace a working asset pack with an incomplete download.

### Runtime limitations

Verify whether the modding API supports HTTP requests, filesystem writes, archive extraction, and dynamic texture loading.

If direct in-game downloads are impossible, implement a compatible launcher-assisted or external asset installation workflow.

Do not create nonfunctional menu options.

## 9. Environment Detection and Background Selection

Implement accurate automatic battlefield selection using:

- Game identifiers.
- Map identifiers.
- Map metadata.
- Tileset information.
- Indoor/outdoor flags.
- Battle context.
- Surfing and water encounter state.
- Gym and special-location identifiers.
- Weather state.
- Time of day.

Use game-specific environment mapping tables where required.

Prefer explicit mappings over unreliable assumptions.

### Selection modes

**RANDOM**

Randomly select from the current environment's installed background variations.

Keep the selected variation stable throughout the battle.

Avoid unnecessary consecutive repeats.

**FIXED**

Use a consistent background variation for each location.

Persist the selection across sessions.

Allow users to reset or change assignments.

Provide a manual override for troubleshooting.

Special story and legendary encounters may use dedicated backgrounds.

## 10. Compatibility With Other Mods

Investigate and maximize compatibility with:

- 1025Dex
- WildFollowers
- Menu Customizer

The new mod should control battlefield backgrounds and mound rendering without unnecessarily modifying Pokémon sprite rendering or battle HUD behavior.

### Rendering compatibility

Prevent:

- Duplicate battle backgrounds.
- Duplicate Pokémon sprites.
- Competing rendering hooks.
- Incorrect sprite layering.
- HUD displacement.
- Background flickering.
- Mound misalignment.
- Incorrect rendering when the game window becomes narrow.

Define an explicit compatibility policy for KIM1025 when both mods are enabled.

Where possible, let the new mod override only the battlefield-related rendering layers while preserving unrelated features.

Do not claim simultaneous compatibility until it has been tested.

## 11. In-Game Configuration

Organize all settings under:

**OPTIONS → HD BATTLEFIELDS**

### BACKGROUNDS
- Enable/disable HD backgrounds.
- Random/fixed variation selection.
- Time-of-day mode.
- Weather effects.
- Manual environment override.

### ANIMATION
- OFF / LOW / MEDIUM / HIGH.

### MOUNDS
- Enable/disable mounds.
- Automatic positioning.
- Player mound offsets.
- Opponent mound offsets.
- Mound scaling.
- Pokémon anchor corrections.
- Reset positioning.

### DISPLAY
- Automatic aspect-ratio detection.
- Quality tier.
- Manual aspect-ratio override.
- Viewport calibration.

### ASSET MANAGER
- Recommended packs.
- Available downloads.
- Installed packs.
- Verification and updates.
- Remove unused assets.

### DIAGNOSTICS
- Mod version.
- Active game.
- Active map/environment.
- Selected background.
- Active asset pack.
- Current viewport.
- Loaded metadata identifier.
- Compatibility status.
- Developer calibration mode.

Persist all supported settings using the runtime's configuration system.

## 12. Performance and Memory Management

Optimize for both desktop and mobile devices.

Requirements:

- Load only the assets needed for the active battlefield.
- Cache reusable textures.
- Release unused high-resolution assets.
- Avoid decoding large images during every frame.
- Preload likely assets where practical.
- Avoid noticeable battle transition delays.
- Minimize unnecessary memory allocations.
- Scale animation complexity appropriately.
- Handle missing or corrupt assets safely.
- Avoid assumptions about desktop-class hardware.

The mod should remain responsive during window resizing and orientation changes.

Do not sacrifice visual alignment or rendering stability for small performance gains.

## 13. Testing and Quality Assurance

Test all supported games and major battle types.

### Display configurations

Test at minimum:

- 4:3
- 16:9
- 16:10
- 21:9
- 32:9 at 5120×1440
- iPhone portrait
- iPhone landscape
- Android portrait
- Android landscape
- Dynamically resized desktop windows

### Battle scenarios

Test:

- Wild encounters.
- Trainer battles.
- Rival battles.
- Gym leaders.
- Elite Four.
- Champion battles.
- Legendary encounters.
- Surfing and water battles.
- Indoor environments.
- Caves and forests.
- Weather conditions.
- Day/night changes.

### Sprite compatibility

Test with:

- Vanilla sprites.
- Animated sprites.
- Expanded Pokédex sprites.
- Large Pokémon.
- Small Pokémon.
- Flying and hovering Pokémon.
- Alternate sprite sets.

### Perspective validation

Verify that:

- Every background loads its correct metadata.
- Pokémon grounding remains accurate.
- Mounds align naturally with the environment.
- User adjustments persist.
- Window resizing does not break alignment.
- Aspect-ratio changes load the correct composition metadata.
- Shared metadata inheritance works.
- Invalid metadata triggers safe fallbacks.
- Calibration changes do not affect unrelated battlefields.

### Asset system validation

Test:

- Fresh installation.
- Offline startup.
- Missing packs.
- Interrupted downloads.
- Corrupt downloads.
- Asset updates.
- Multiple installed aspect-ratio packs.
- Pack removal.
- Metadata version mismatches.

Do not mark a feature complete without verifying its actual behavior.

## 14. Development Roadmap

### Phase 1 — Technical Investigation

Inspect Gen1Recomp, KIM1025, supported APIs, and game-specific rendering behavior.

Establish technical feasibility and document limitations.

### Phase 2 — Rendering and Metadata Prototype

Build a working prototype with:

- Grassland.
- Forest.
- Cave.

Implement original artwork, independent mounds, shared perspective metadata, Pokémon grounding, and viewport-aware rendering.

Test 16:9, 32:9, and mobile portrait compositions.

### Phase 3 — Environment Mapping

Implement accurate map classification for every supported game.

Add random and fixed background selection.

### Phase 4 — Complete Artwork Collection

Create three to five original variations for every environment category.

Produce dedicated aspect-ratio compositions and resolution tiers.

Calibrate perspective metadata for each composition.

### Phase 5 — Weather and Animation

Implement day/night lighting, weather effects, and optional environmental animation.

### Phase 6 — Asset Management

Create the GitHub Releases asset structure, manifest, verification system, and downloader or compatible alternative.

### Phase 7 — Compatibility and Optimization

Test all supported games, sprite systems, and relevant mods.

Resolve rendering conflicts, performance issues, and alignment bugs.

### Phase 8 — Final Release

Deliver:

- Installable mod archive.
- Complete source code.
- Original artwork collection.
- Versioned asset packs.
- Perspective and anchor metadata.
- GitHub Releases manifest.
- Configuration documentation.
- Compatibility matrix.
- Testing results.
- Known limitations.
- Installation and troubleshooting instructions.

## 15. Non-Negotiable Requirements

1. All battlefield artwork must be original and visually cohesive.
2. Every environment category must have three to five distinct variations.
3. Major aspect-ratio families must receive properly composed artwork.
4. Mounds must remain independent of backgrounds.
5. Every battlefield composition must have associated perspective and anchor metadata.
6. Adding new backgrounds must not require rewriting the renderer.
7. Pokémon must appear naturally grounded across supported sprite sets.
8. Manual adjustments must not overwrite original metadata.
9. Background selection must correctly identify the battle environment.
10. Asset downloads must be verified and recoverable.
11. Missing assets must never prevent the game from functioning.
12. Animations must be optional and performance-conscious.
13. Existing battle interfaces and sprite mods must be preserved wherever technically feasible.
14. Do not hardcode background-specific coordinates into the rendering engine.
15. Do not report untested features as complete or silently substitute placeholders.

**Complete the project in testable stages. Prioritize getting the rendering architecture, shared perspective metadata, and Pokémon alignment correct before scaling up artwork production.**

The finished result should feel like a professionally designed evolution of KIM1025's visual concept: a fully modular, beautifully illustrated HD battlefield system that adapts naturally to every supported Pokémon game, environment, and display configuration.