# Phase 2 checkpoint 1: construction and portable defenses

Authorized by the owner on 2026-09-26. State: P2C1a native construction implemented in 0.2.0; the approved recipe follow-up is 0.2.0.1, awaiting player evidence. Phase 1's remaining side-end, reload, cleanup, traversal and multiplayer acceptance is not waived.

## Checkpoints

| ID | Outcome | State |
| --- | --- | --- |
| P2C1a | Build a Spike Barrier from the native building menu, preview and rotate its 1x2 footprint, consume materials through the native recipe, preserve existing paired identity/damage/persistence | Implemented; player acceptance pending |
| P2C1b | Craft/store an individual barrier item and deploy it through native construction | Scheduled |
| P2C1c | Bundle five individual barriers; pack weight = combined loose weight x 0.33; unpack returns five | Scheduled; 67% reduction confirmed |
| P2C1d | Servicing/recovery, ownership policy and multiplayer construction evidence | Scheduled |

## P2C1a scope

Medium reasoning is sufficient; estimated 20-35 minutes including native-loader and lifecycle validation. Fast is recommended if the integration/verification needs more than 25 minutes.

Use the installed B42.20.4 entity construction recipe and its SpriteConfig hooks rather than overriding the game's building menu. Reuse the existing white arrow markers. The initial candidate is single-player construction; keep multiplayer construction disabled until material/placement replication is verified. Existing multiplayer combat remains disabled.

Original 0.2.0 recipe: hammer retained, four planks and eight nails consumed, 200 native action-time units, no skill gate or XP award. The owner rejected selecting those requirements without consultation. The approved 0.2.0.1 follow-up replaces them as described below. Native build-cheat mode keeps its normal free-material behavior and must be identified in diagnostics. Master and Spike Barrier toggles default ON for this test. Disabling preserves placed objects/collision/condition and stops new construction and retaliation.

Construction-created parts adopt the same paired ledger as the prototype, with exact owner username and placement source recorded. A single shared 100 condition value, facing, front/side retaliation and rear-safe behavior remain. No inventory pickup/repacking yet. The existing 64 distinct ledger-tile limit still applies and must reject before material consumption.

## Evidence and acceptance

Installed Lua: `ISBuildPanel:createBuildIsoEntity`, `ISBuildIsoEntity:isValid/create/setInfo`, `ISBuildAction:start/stop`, native feeding-trough multi-tile entity definitions and `CraftRecipe_BuildMenu.lua` menu predicates. Verify script registration and four faces in an actual native server startup; no connected-player MP claim follows from that smoke.

Required validation: compile Kahlua, native recipe/entity parsing and translations; both-tile/capacity rejection; four-facing adoption; duplicate callback protection; shared condition/reload/removal; enable/disable behavior. Exercise the installed native creation path with controlled material logic to verify that failed placement precedes consumption and two parts consume one recipe. Visual cursor/pathing and actual SP inventory consumption require owner evidence.

## Verification results

- Package: 0.2.0, internal ID and existing save keys unchanged. Existing 0.1.6 records do not gain construction ownership or new supplies through migration.
- Native Kahlua compilation: 12 runtime modules. Native JSON translator: 61 keys, including the recipe name. Texture checks verify the eight new part sprites are byte-for-byte copies of the authorized white arrows, with unique names required by SpriteConfig.
- Behavioral suite: 232 assertions, including the installed `ISBuildIsoEntity.create/isValid` functions exercised with controlled recipe/world doubles. Four faces, obstruction/missing ingredients/toggles before consumption, one recipe for two parts, duplicate callback/build rejection, shared condition, native table save roundtrip, no-debug retaliation, master disable preservation, paired removal and ledger cap passed.
- Native B42.20.4 b0bbce05d5 startup registered the construction recipe, hooks and all four two-tile faces, translated the name, and confirmed the MP gate. The isolated server saved and shut down cleanly. Headless smoke has no player, rendering or actual inventory transaction acceptance.
- Diagnostics now include bounded `construction-menu`, `construction-preview` and `construction-part` records. Part logs record ID, primary tile, heading, shared condition, completion of both parts and native build-cheat status. Construction diagnostics work with Foundation Test Controls OFF.
- No new gameplay art, module system, XP integration, item pickup or packs in this candidate. Native build-cheat deliberately does not consume ingredients. Construction recipe/health are test tuning; player evidence remains required.

## Approved recipe follow-up: 0.2.0.1

Four total planks/basic crafted wooden spears in any mix, four total binding units (ripped sheets, dirty ripped sheets, twine uses), retained sharp knife/cleaver with native light wear, Carpentry 1 and one 10 base Carpentry XP award. The native SharpenStakeWood action replaces hammering; action time remains 200. Materials, tool eligibility, skill checks and XP use native crafting. Base durability remains 100 and thump damage remains 20; existing objects are not upgraded or healed.

Validation: the existing 232 lifecycle assertions, 12-module Kahlua compile and 61 native translation keys pass. Native B42.20.4 verifies recipe registration, Carpentry 1 / one 10 base XP award, and all 75 combinations of five wood mixes and fifteen binding mixes. Knife and cleaver fixtures pass; three wood/binding units and missing/dull/broken tools fail, with no preview consumption. The isolated server saves and shuts down cleanly in 44.8 seconds. The ingredient probe runs at OnServerStarted because native input caches are not ready at the earlier world-data event. Actual player animation, displayed XP after game modifiers, material consumption and UI acceptance remain pending.

The approved reinforced upgrade is scheduled separately at P2C2a: existing barrier + two planks + eight nails, retained hammer, Carpentry 3, 30 base XP, 200 maximum durability preserving existing damage, and 25 damage per thump. It is not in 0.2.0.1. Individual items and five-item bundles remain P2C1b/P2C1c; transport operations award no crafting XP.

## Owner test

1. Restart PZ and confirm **0.2.0.1** in a disposable SP save. Enable the mod, Spike Barrier and Diagnostic Logging; keep Foundation Test Controls and Build Cheat OFF. Use Carpentry 1+ and a sharp, unbroken knife/cleaver.
2. Open Building > Spike Barrier. Verify Carpentry 1, four planks/spears and four bindings; no hammer/nails. Remove the cutting tool or leave only three wood units: building must be unavailable with no item/XP change.
3. Restore materials. Rotate the two-tile preview in all four directions, overlap an obstacle with either half, and cancel a valid placement. None of these should consume materials or grant XP.
4. Build one barrier using four planks and four sheets, then another using four crafted spears and four twine uses. Select inputs or move alternatives out of reach. Each build consumes once, retains the cutting tool and grants one Carpentry XP award (base 10, displayed gain may be modified).
5. Build using two planks, two spears, one clean sheet, one dirty sheet and two twine uses. Verify exact consumption and a single XP gain; the native wood-carving animation should play. Front/side thumps still deal 20 damage; rear thumps deal none.
6. Save/reload to check both halves, facing and condition persist; verify blocked walking/vaulting and paired cleanup when destroyed. Then say **Test Complete** so console.txt can be reviewed. Reinforcement is not available in this build.

Workshop baseline remains never uploaded. The cumulative draft retains all prior unuploaded notes under v0.2.0.1. Exact install/tag evidence is in [release state](RELEASE.md). P2C1b individual items is next; P2C1c bundles follows it. The broader Phase 2 checkpoint is not accepted yet.
