# Expanded aspect batch

The official v0.3.88 Red renderer and Menu Customizer fixture passed 118 renders: 28 aspect/day-night cases plus 90 variation switches across 1920x1080, 5120x1440 and 900x1600. Records: alignment-batch.json and variation-batch.json. These cover actual native rendering with the scenery consumer; no live gameplay or physical-device coverage is implied.

Visually inspected forest-02 at ultrawide/portrait, cave-02 ultrawide, and the corrected cave-02 16:9. Mound contact and background floor agree. Cave-02 portrait loaded successfully but still requires visual review. Day/night originals remain separate files, and battle UI/native sprite transforms remain unchanged.

An older cave-01 ultrawide scene still placed its floor too low. Its uniform sampling region was shifted down 118 source pixels to raise the visible floor. That follow-up correction awaits the next combined batch. Additional environments, aspect variants, quality tiers and game adapters remain unfinished.
