# 0.2.70.8 - C510 multiplayer test candidate

Owner: "Approved. Patch it and let me test." This explicitly lifts the C508/C509 packaging hold for a connected owner test. It does not mark multiplayer accepted or authorize a Workshop upload or live-server change.

## Final changes

The native zombie-owning client reports fresh trap contact, exits and landings; the server validates reports and retains damage, wear, resource, death, Horde Night and XP authority. Corpse-dragging representations cannot activate these attacks. Owned-zombie contact no longer depends on the dedicated server's delayed replica or a second tile scan. Ready Poke Floor contact strikes immediately, with its existing rising window and one hit per victim per cycle.

The former Prepare/Ready/Commit/Applied exchange is replaced with Apply/Applied. Ownership changes, duplicate delivery, actor recycling and missing acknowledgements retain bounded validation and reconciliation. Expired contact attacks are discarded. This reduces a controlled 50ms-per-leg replay from 150ms to 50ms before damage application; it is not a measurement of the owner's connection.

The whole-catalog audit also corrected admission when the transport is full, linked-trigger Arc eligibility, delayed Scrapshot/Siphon and piercing splash snapshots, and receipt retention during sustained combat. Existing range acquisition, moving effects, aim interpolation and nearby Module Pack presentation remain included.

## Evidence and limits

- [C508 replacement and controlled comparisons](MULTIPLAYER_REPAIR_C508.md).
- [C509 catalog coverage, five failing-before/passing-after regressions and limits](MULTIPLAYER_COVERAGE_C509.md).
- [This package's verification and short owner checklist](TEST_v0.2.70.8.md).

The source candidate passed 40,287 Kahlua assertions, 339 production head/module hit cases, every trap damage route and combined Arc interactions. Native stock-server checks had zero connected clients. Connected animation, transport, observer parity and perceived smoothness still require the owner test. No new world is required; saved tuning and integration contracts are unchanged. Server and both clients must load the same new version after restart because the combat protocol changed.

The cumulative changelog starts after the confirmed 0.2.70.7 upload to item 3828638252 at 2026-10-29T21:52:24.317917Z. The successful publisher log, all 625 uploaded files and exact note text were verified (line-ending normalization only); [baseline evidence](evidence/c510-upload-baseline.json). No 0.2.70.8 publication is claimed.
