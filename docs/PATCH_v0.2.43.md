# 0.2.43 - Conservation and transfer performance

Approved C154, 2026-10-11: implements the C148-C153 bundle. R1C3 performance continues alongside R3C7 module/power acceptance. No recipe or module-capacity changes.

- Conservation Module
- Matched native ammo-transfer batching
- Trap maintenance and contact caching
- Turret scheduling and rendering optimizations
- Compact Manage window
- Installed Modules benefit list and row tooltips
- Battery endurance tooltip
- Conservation LootLab catalog

## Behavior

Conservation is loot-only, 0.3 weight, offensive-module loot weight 2.5 and ordinary power weight 1. One working copy gives two ammunition uses per round; each additional copy adds one use. The deterministic fractional remainder lives on the exact head's existing cycle. It discounts the existing min(loaded, 1 + Splitter) charge, retains the round until the final use, and never permits firing from an empty gun. Reloads, pickup and module changes do not reset progress. Failed shots do not advance it; every committed volley still consumes normal power. Impact rearms only through its existing genuine empty-reload path. No handheld gun cadence/stat changes.

Both transfer paths retain native timed actions, item identity, weight/capacity/reach checks and interruption. Light ammunition is grouped up to 20 items; Manage prepares native groups directly. Native queue coalescing is limited to 20 owned items per preparation, and cannot discard members of a prebuilt group. Acceptance uses a private synchronous snapshot, incrementally updated after each moved round; unrelated inventory readers always get fresh contents. Non-ammo configuration and extended-magazine removal remain guarded. There is no long-lived transfer cache. Aggregate preparation/batch timings are diagnostic-only.

Barrier health observation reuses discovered objects and avoids unchanged native setters; outline maintenance runs on generation changes with a one-second fallback. Reconciliation has a one-millisecond cooperative budget in addition to its four-slot limit, and retired cleanup is throttled. Barbed object references are validated against loaded squares, indices, exact markers and supports; live door geometry/health still gate every contact. Turret operations share resolved stats; renderer option reads are shared per pass and stale-entry work is bounded. Secondary rays compact once per slice instead of shifting for every finished ray. Empty debug callbacks avoid unnecessary work. Existing idle sweep, combat timing, ray limits, contact damage and actor movement remain intact. These are cooperative limits, not preemption or a frame-time guarantee.

Manage retains 4/6/6, keeps battery/expansion/power above it and leaves the two first-row gaps empty. The normal minimum width is 640 (previously 800), with font/viewport sizing and reduced padding on short viewports. Installed Modules groups exact types with counts, short current effects and individual explanatory hover details; broken/incompatible entries remain visible. The list scrolls within its fixed height. Battery hover shows display-rounded charge/volley, remaining volleys and an explicitly labeled configured-fire-rate estimate in real minutes, excluding reloads and targeting gaps. Actual consumption is unchanged by rounding. No battery idle drain.

LootLab has 25 modules and 175 entries in the existing 16 pools. Existing loot weights/global settings stay unchanged; the additional candidate increases expected module finds only in its eligible pools. Existing saved scenarios retain tuning and receive Conservation multiplier 1/visible.

## Verification and limits

See [focused test and evidence](TEST_v0.2.43.md), [release record](RELEASE.md) and [machine release evidence](../diagnostics/v0.2.43/local-release.json). Native probes exercise real objects, item transfers and save/reload; headless UI fixtures do not establish rendered legibility or crowded-client frame smoothness. Combat remains single-player only. No Workshop publication or automatic merge.
