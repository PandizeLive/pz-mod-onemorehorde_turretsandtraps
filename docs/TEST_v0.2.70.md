# 0.2.70 verification

C484, 2026-10-26. Automated verification is complete; installation is recorded separately below. Owner acceptance remains pending.

- Foundation validation:34,400 assertions;354 Lua/translation compilation checks;446 source and614 package files. World/player/UI objects in this harness are test doubles.
- Installed game PZNetKahluaTableImpl roundtrip preserves all64 target IDs and every timed-action payload field in1523 bytes.
- Regression coverage: mixed eligible/ineligible group drops, assignment before grouping, stale/deleted group rejection before side effects, foreign-owner/other-Controller exclusions, exact replay rejection, capacity, offline/out-of-range release, box/Ctrl selection, collapsed selection cleanup and full-width tab visibility.
- Native timestep checks cover the3-second reset, accelerated progression and elapsed/debt interruption; no rendered stun-duration measurement.
- Production UI drawing trace rendered in isolated Edge; `diagnostics/c484-controller.png` reviewed for basic spacing. This is a geometry/render trace, not live-game UI acceptance. Native wheel clipping and input acceptance still require owner testing.
- Horde settings validation:610 assertions including package-default parity. The validator also compares both actual T&T capability strings against Horde's reviewed baseline.
- Intermediate native failures: the old tether fixture expected the half-second reset; updated to assert that it remains busy through that interval and finishes after3 seconds. New batch fixture initially supplied sprites incompatible with its legacy native entity helper; corrected to reuse the existing helper's accepted sprites. Do not classify those intermediate runs as successful release proofs.
- Final native write/read pass in107.3/108.1 seconds with no connected player; actual batch assignment/grouping, replay rejection and fresh-process persistence pass.
- Independent Traps/Turrets/both startups pass in93.5/89.8/98.5 seconds at0.2.70.
- Installed from immutable test/v0.2.70 / 85d2551daafd1dbcb8ede9fdc0938adea9f4b2c1. All 446 source and 614 package/tag/install/archive files plus both previous-package backups verify. Horde/Cure 0.6.16.9 is also installed and hash-verified. Rendered and connected-player acceptance remain pending.

## Owner checklist after verified installation

- Box selection and Ctrl-click.
- Group drops and bulk assignment.
- Whole-group assignment and unassignment.
- Settings tabs, resizing and scrolling.
- Tether recovery with Reset Duration set to3.

Connected multiplayer remains pending/deferred. No new world is required; restart for installed Lua changes. Saved tuning is not rewritten.

## Local delivery evidence

T&T backup: `diagnostics/p1c1/install-backups/20261026-220520-5157`; previous0.2.69.1 packages verify234/376 files. Archive `artifacts/OMHTT-0.2.70.zip`, SHA-256 `acea66fb66f84c8e6b23763447c1fc5a36cf81b6c5dd8db09e3261400eb3079a`. Machine-readable proof: `diagnostics/v0.2.70/local-release.json`.

Horde/Cure tagged source `test/v0.6.16.9` / `1544656b614347b3bddc8be30aa901cb82d9026c` installed through its root launcher; local mods and local Workshop staging hashes match. Backup: `C:/Users/bandi/Zomboid/OMH-local-backups/before-v0.6.16.9-20261026-220541-6681`. Trait Shop unchanged. Native isolated probes establish T&T loaded0.2.70; the owner client must restart and its loaded versions remain to be confirmed from console.

The launcher and release recorder retain generic historical fresh-world wording; this patch does not require a new world. Preserve saved tuning and set Reset Duration to3 explicitly. Owner AMMO_UI_C446.md SHA-256 remains `24506649c189a6e0b9f9e7fd04ab53fba940d3741a79ec38c267b75b75207fba`.

Private T&T GitHub mirroring remains blocked by the prior automatic approval review requiring explicit destination/payload authorization; no retry or bypass. Horde mirroring remains manual-only. No Workshop content upload, save changes or historical flag reset. **Test now (single-player), after restart when available.**

## C485 owner acceptance -2026-10-26

Owner: "You removed the range preview on the map. I only wanted the gradient circle removed in-game. The rest has passed." Record the0.2.70 checklist as owner-passed for Connections box/Ctrl selection, group drops/bulk/whole-group assignment, settings tabs/resize/scroll and tether recovery. The map-outline omission remains failed and is corrected in0.2.70.1. No connected-player acceptance is inferred. Console snapshot diagnostics/c485-console.txt confirms T&T0.2.70 SP and Horde0.6.16.9. Unrelated startup font/Firearms/map warnings remain; no Controller stack trace found.
