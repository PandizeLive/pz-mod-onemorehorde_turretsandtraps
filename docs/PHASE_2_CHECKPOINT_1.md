# Phase 2 checkpoint 1: construction and portable defenses

Authorized by the owner on 2026-09-26. State: P2C1a implemented in 0.2.0, awaiting player evidence. Phase 1's remaining side-end, reload, cleanup, traversal and multiplayer acceptance is not waived.

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

Temporary recipe: hammer retained, four planks and eight nails consumed, 200 native action-time units, no skill gate or XP award. This is testing balance. Native build-cheat mode keeps its normal free-material behavior and must be identified in diagnostics. Add master and Spike Barrier toggles with ON as implementation defaults for this test. Disabling preserves placed objects/collision/condition and stops new construction and retaliation.

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

## Owner test

1. Restart PZ, confirm OMH: Turrets & Traps **0.2.0**, and use a disposable SP save. Enable the mod, Spike Barrier and Diagnostic Logging in Sandbox; keep Foundation Test Controls OFF and native Build Cheat OFF.
2. Carry a hammer, at least eight planks and sixteen nails. Open the native Building menu, search **Spike Barrier**, and select it; the temporary recipe should show a retained hammer, four planks and eight nails.
3. Move and rotate the preview through all four facings. Both occupied tiles should be visible. Try overlapping an obstacle with either half, then cancel; no structure or material loss should result.
4. Build in clear space. Exactly four planks and eight nails should be consumed once, with the hammer retained. The two white arrow parts should appear immediately and block walking/vaulting.
5. Build a second barrier facing another direction. Let zombies thump the front/side ends and rear; only front/side strikes should deal the existing 20 damage, even with debug controls OFF.
6. Save, exit and reload. Both halves should remain with their facing and damage. Let one barrier break to check paired cleanup, then say **Test Complete** for console review.

Workshop baseline remains never uploaded. The cumulative draft retains all prior unuploaded notes under v0.2.0. Exact install/tag evidence is in [release state](RELEASE.md). P2C1b individual items is next; P2C1c bundles follows it. The broader Phase 2 checkpoint is not accepted yet.
