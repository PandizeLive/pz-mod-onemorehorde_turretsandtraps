# Phase 1 visibility markers and completed-run review

Package: **0.1.3-p1markers**. Date: 2026-09-25. The owner authorized temporary development textures with white directional arrows because the shared cubes made it difficult to tell what was placed. This extends the technical-placeholder permission only; final art remains owner-sourced without AI.

## Review of the completed 0.1.2 run

[Preserved console](../../diagnostics/captures/20260925-231838-7288/console.txt) and [extracted trace](../../diagnostics/captures/20260925-231838-7288/omhtt.log):

- Translation audit resolved all 14 runtime probe strings; no OMHTT Lua exception appeared in the inspected capture.
- Eleven objects were placed: six barriers, four potatoes and one foundation test object. Native thumping reduced one barrier from 100 to 95 and another to 99. This is evidence of native damage reception, not per-thump retaliation or complete traversal acceptance.
- The trace recorded a successful refill and head rotation, one range rejection on a different floor, and stale/occupied placement rejection on the foundation cube's tile.
- One potato shot spent one round, applied damage, requested knockdown and reached the effect's first render callback on the following frame. No death/corpse or repeated-shot cadence proof exists in this capture.
- Its target health changed from 3.3087313 to 3.2712314: actual damage was about **0.0375** from input 0.25. The run used Toughness setting 4. Native global damage reduction applies; reference-target balance remains unresolved. This patch does not guess a damage multiplier or change tuning.
- Barrier texture presence and dimensions were already recorded in the placement frame. The owner nevertheless observed delayed visibility. Texture allocation is not proof that the cached world scene rendered it; the earlier log lacked readiness/refresh evidence. Several barriers also had a nil sprite name despite an allocated texture.

## Changes

- Foundation: flat white tile outline and cross, labeled **TEST**.
- Barrier: flat white tile outline with a thick direction arrow and **BARRIER** label. Four cardinal facings. After Inspect, **Rotate barrier arrow 90 degrees (visual test)** advances facing without changing collision, condition or supplies. The current native barrier blocks the whole tile; an arrow does not implement one-sided damage or retaliation.
- Potato: existing cube geometry plus a white footprint/direction arrow and **POTATO** label. Sixteen facings retained.
- Exact existing prototypes migrate to the appropriate sprite on load/inspection without changing identity, health, ammo, cooldown or revision. No unrelated same-sprite object is selected. Explicitly setting the native sprite path also supplies the missing barrier sprite name.
- Creation marks the square changed and requests native render invalidation. Sprite changes request the corresponding invalidation. Current vanilla `BuildRecipeCode` and `ISMoveableCursor` use these `FBORenderChunk` APIs; `DirtySlice()` is a no-op in the inspected current bytecode and is not used.
- Placement/inspection/action results show a six-second text label with ID, plus a ground cross. These draw without depending on the world texture. Barrier labels include heading; potato labels include rounds. At most eight markers exist; no world scan runs in the render callback.
- The client checks at most two markers per tick, no more often than every 250 ms after an initial 100 ms delay. An allocated texture must report `isReady()` before a one-time deferred redraw. It logs readiness latency or a three-second timeout and stops polling; labels expire after six seconds. Removing the device clears its label.
- Detailed object diagnostics now include `textureReady`, distinct from `texturePresent`.

The textures are simple programmatic white geometry, arrows and developer words, not generated artwork. [Technical preview](../../art/placeholders/dev-markers-preview.png). No item recipes, integrations, automatic firing, native 3D renderer or multiplayer combat were added.

## Verification

[Validation](../../diagnostics/p1markers/validation.log): 56 strings loaded/formatted through the installed native Translator; seven Lua modules compiled; 87 assertions passed; native save-table roundtrips and 23 packet serializations passed (largest 399 bytes). Twenty-two grayscale transparent textures were checked, including four distinct barrier directions. The six-object preview was visually inspected.

New regression cases cover missing versus pending versus ready textures, immediate fallback labels, deferred redraw, unique kind sprites, rotation/duplicate requests, collision/resource preservation, old-cube migration after native table serialization, marker expiry and removal. World/UI/texture objects remain doubles; visible timing needs the next player test.

[Dedicated smoke console](../../diagnostics/p1markers/server-restart-console.log), [manifest](../../diagnostics/p1markers/manifest.json), [archive](../../artifacts/OMHTT-0.1.3-p1markers.zip). The final dedicated smoke passed in 35.7 seconds: native startup, three translation categories resolved, save and clean shutdown. No player connected. Installed locally at `C:/Users/bandi/Zomboid/mods/OneMoreHorde_TurretsAndTraps`; all 39 files were hash-verified and the prior managed copy backed up. The test-only translation probe is not shipped.

## Owner test

1. Fully restart PZ and load the disposable test save with Foundation Test Controls ON. Confirm menu version **0.1.3-p1markers**. Existing nearby objects should adopt their distinct technical markers when loaded or inspected.
2. Place one barrier, one potato and one foundation test object on separate nearby tiles. Expect **BARRIER + arrow**, **POTATO + cube/arrow**, and **TEST + cross**, plus an immediate temporary ID/location label.
3. Inspect the barrier and reopen its menu. Rotate its arrow four times; expect a full turn while the tile still blocks movement and its condition stays unchanged. Inspect/turn the potato independently.
4. Save/reload and inspect the same devices. Expect the same IDs, conditions, supplies and barrier facing. If a texture is late, the short-lived text/cross should still identify its location; the logs will record readiness or timeout.
5. Finish the run and leave console.txt for review, or use **Capture Debug Logs.cmd**. The next log review will assess rendering readiness and migration. Damage tuning, per-thump retaliation and MP combat remain separate pending gates.

Handoff: **Test now** after the verified build is installed. No Phase 1 checkpoint is marked fully accepted from this partial SP evidence.
