# 0.2.54 verification — C314

Approved scope: [C310-C313 contract](CORRECTIONS_C310.md), [patch](PATCH_v0.2.54.md). Development only; no Workshop upload or merge.

## Automated evidence

- Full validator: **21,643 assertions**, 222 runtime/translation inputs, 1,027 native JSON translation keys; 293 source and 374 packaged files. No shipped `pcall`/`xpcall`, invalid runtime syntax or package closure failures.
- Siphon fixtures cover fractional battery charge, multiple eligible deaths, duplicate-death suppression, Synergy gating, original battery identity/detachment, charge cap, destroyed source, grid exclusion, stack math and rotary timing across 1/2/6/30/120 updates. Interrupted strokes settle only actual paid energy; both arms share the same pass.
- Synergy fixtures cover the extra half-damage Martyrdom generation and prohibit another Martyrdom generation from its kills. Existing bounded work, authority, consent and scoring fixtures remain active.
- Native Set Aim lifecycle loads the installed `ISBuildingObject` at use time, after verifying that startup does not require that class. World cursor rendering itself still needs in-game acceptance.
- Native server write and fresh-process read probes passed. Exact Stockpile replacement, same-turret reorder, rejected favorite/exclusive-module swaps, replay rejection and native timed-action serialization passed. Native battery fractional refund, duplicate-death suppression and detachment checks passed. Incoming links show both button and plate, then remove exactly the disconnected source. Pressure-plate sprites retain native Floor render layer through serialization.
- Independent Traps/Turrets/both native startup checks all pass for 0.2.54.
- LootLab: all seven model/weights/tiers/appearance/cloud-catalog test entries pass. Package defaults and site provenance checks pass. Desktop/mobile browser tests pass for direct weights, tier dragging, saved weights, visibility, import/export and navigation, with no browser errors. Siphon is the 32nd component control; native extraction contains 233 module-pool entries.

## Findings corrected during verification

The native Controller container intentionally rejects ordinary server-side insertion through its admission callback. The new swap action now validates the explicit turret-related-item whitelist and net Stockpile weight before its exact-item transaction, matching the existing authorized transfer path. Rejected swaps preserve both items. A failed probe left a stale local fixture identity; the fixture now invokes the normal authority reconciliation path before recreating it. The first restart attempt also exposed an ambiguous fixture lookup across old identically named plates; it now persists and checks the exact saved plate and receiver IDs, and the new write/read pair passes. Old loot-count and migration fixtures were updated for Siphon/Lure/Void; saved tuning remains exact.

The native scrolling list does not reset its accumulated scroll height on `clear`. Incoming Connections now rebuilds only when its bounded signature changes and resets that height explicitly. Its permission/state refresh runs every 500 ms, not each frame. Siphon uses existing combat/motor scheduling and adds no global tick loop.

## Delivery and limitations

All automated checks are complete; installation/tag/hash evidence is being recorded. Native server probes use installed Build 42.21 with **zero connected clients**. They establish engine API, serialization and server behavior, not live network convergence or GPU layout. Owner-reported acceptance is pending.

Hosted LootLab was **not deployed**: the existing Cloudflare login is expired and the noninteractive deployment query could not authenticate. The local catalog and a matching tested account-settings helper are prepared under `tools/loot_site/cloud/`; a fresh authenticated live-source comparison is required before publishing. No account settings or production database were changed. Do not deploy the stale website checkout.

## Short owner test

1. Restart and confirm **0.2.54**. Open the Controller at its physical crate; confirm a turret does not offer the Controller menu.
2. Link a button and pressure plate to one turret. Confirm both incoming links appear, disconnect one, then use **Set Aim** and click a world direction.
3. Walk onto/off a plate; check its floor layering, depression and kneeling pickup animation.
4. Swap modules from inventory and Stockpile onto occupied slots, then reorder installed modules. Check the returned exact item, brief border pulse, tooltips and Ammunition alignment.
5. Try Siphon at one and two copies: eligible kills restore 2×/3× paid battery cost; secondary module kills require Synergy. Check a rotary too, and that charge never exceeds 100%.
6. Trigger a Martyrdom chain: the extra generation has half damage and stops there. Save/reload and confirm incoming links, module order and contents remain intact.

Tracked evidence: [validator](../diagnostics/v0.2.54/validation.log), [native excerpts](../diagnostics/v0.2.54/native-evidence.txt), [LootLab tests](../diagnostics/v0.2.54/loot-tests.txt), [desktop/mobile weights](../diagnostics/v0.2.54/loot-browser.txt), [tier browser checks](../diagnostics/v0.2.54/loot-tiers-browser.txt).
