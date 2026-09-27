# Phase 2 checkpoint 1: construction and portable defenses

Authorized by the owner on 2026-09-26. State: P2C1a native construction implemented in 0.2.0; the approved recipe follow-up is 0.2.0.1, followed by the 0.2.0.2 Building-menu visibility/category correction. Player acceptance remains pending. Phase 1's remaining side-end, reload, cleanup, traversal and multiplayer acceptance is not waived.

## Checkpoints

| ID | Outcome | State |
| --- | --- | --- |
| P2C1a | Build a Spike Barrier from the native building menu, preview and rotate its 1x2 footprint, consume materials through the native recipe, preserve existing paired identity/damage/persistence | Implemented; player acceptance pending |
| P2C1b | Craft/store an individual barrier item and deploy it through native construction | Scheduled |
| P2C1c | Bundle five individual barriers; pack weight = combined loose weight x 0.33; unpack returns five | Scheduled; 67% reduction confirmed |
| P2C1d | Servicing/recovery, ownership policy and multiplayer construction evidence | Scheduled |

## P2C1a scope

Medium reasoning is sufficient; estimated 20-35 minutes including native-loader and lifecycle validation. Fast is recommended if the integration/verification needs more than 25 minutes.

Use the installed B42.20.4 entity construction recipe and its SpriteConfig hooks. A narrow ISBuildPanel adapter adds the owner-requested mod filter; native recipe construction and transactions remain in control. Reuse the existing white arrow markers. The initial candidate is single-player construction; keep multiplayer construction disabled until material/placement replication is verified. Existing multiplayer combat remains disabled.

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

## Building-menu correction 0.2.0.2

The [0.2.0.1 log review](TEST_v0.2.0.1.md) confirms the loaded client version and missing UiConfig error. Native bytecode inspection identifies the hiding fault: Building's global callLuaBool looks up an exact global name and does not resolve the dotted callback previously supplied. The flat alias fixes that path. The missing native UI style is supplied using an existing arrow marker, and menu refresh corrects any early cached translation.

The same recipe appears under Carpentry and Turrets & Traps. A narrow panel adapter filters its recipe source for the mod category, preserves search, and restores the full source when leaving it. It does not duplicate entities or XP transactions. Bounded diagnostics report recipe enumeration, native callback visibility, names, category/search state and vanilla Build Cheat. The owner cancelled the custom requirement bypass; none is added.

Validation: 244 Kahlua assertions (including category switching, search, refresh, original recipe identity and translation refresh), 13 runtime modules and 63 native translator keys pass. Native loader/dispatcher smoke checks and install evidence are in [release state](RELEASE.md). Actual rendered list/grid, cursor, inventory and XP still require the player test.

## Category/creation correction 0.2.0.3

The [0.2.0.2 owner test](TEST_v0.2.0.2.md) failed category discovery/translation and actual construction. The earlier checks did not exercise native widget startup or real object sprite identity. Version 0.2.0.3 defers the custom category until native recipes load, uses IG_UI.json, initializes named native sprites and preserves distinct part identities. It adds the explicit knife/cleaver tooltip without changing recipe eligibility. [Repair/validation record](PR_v0.2.0.3.md).

Native component save/reload remains an explicit gate: file-backed sprites do not establish stable native tile IDs, and ledger reconciliation alone does not prove native component restoration. Resolve this before accepting persistence or starting portable-item work. Existing Phase 1 reload/traversal limitations remain open.

## Completed 0.2.0.3 owner review

[2026-09-27 evidence](TEST_v0.2.0.3.md): 13 categories, zero missing translations, four completed paired barriers (three cheat, one normal), valid native part identities at creation, Occupied/Blocked rejection previews and no creation exception. Six later native SpriteConfig warnings remain. Exact inventory/XP deltas and actual traversal are not independently logged. P2C1a remains partial; next repair/proof is native object save/load and cell restoration before portable-item work. No new runtime build was produced by this review.

## Owner test

The following was the requested scope for the now-completed 0.2.0.3 test round; only the results documented above are verified. It is retained for reference, not a request to repeat it now.

1. Restart with **0.2.0.3** in a fresh disposable SP save. Enable the mod, Spike Barrier and Diagnostic Logging. Build Cheat may be ON; avoid the failed test's leftover objects.
2. Open Building: native categories should remain, and **Turrets & Traps** should translate. Find Spike Barrier under both it and **Carpentry**; check search and list/grid switching.
3. With Build Cheat ON, rotate and build one barrier on clear ground. Expect two named arrow parts, no error, and blocked walking/vaulting. Try placing directly over it and overlapping just one half: both must fail.
4. Try placing with a wall/furniture under either half, then cancel on clear ground. Nothing should be created. The recipe note should explain **sharp knife or cleaver** even when a specific knife icon is shown.
5. Turn Build Cheat OFF. With Carpentry 1, a sharp knife/cleaver, four planks/spears and four binding units, build once. Expect one material charge, retained tool and one base-10 XP award; missing supplies should block building.
6. Say **Test Complete** for log review, even if a step fails. Save/reload, reinforcement and portable-item acceptance remain separate gates; do not use this development build for a permanent base.

Workshop baseline remains never uploaded. The cumulative first-release draft retains pending notes under v0.2.0.3. Exact install/tag evidence is in [release state](RELEASE.md). Native construction acceptance must pass before P2C1b individual-item work proceeds.
