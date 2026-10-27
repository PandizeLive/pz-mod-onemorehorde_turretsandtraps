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
- Local installation and immutable-tag/hash evidence pending.

## Owner checklist after verified installation

- Box selection and Ctrl-click.
- Group drops and bulk assignment.
- Whole-group assignment and unassignment.
- Settings tabs, resizing and scrolling.
- Tether recovery with Reset Duration set to3.

Connected multiplayer remains pending/deferred. No new world is required; restart for installed Lua changes. Saved tuning is not rewritten.
