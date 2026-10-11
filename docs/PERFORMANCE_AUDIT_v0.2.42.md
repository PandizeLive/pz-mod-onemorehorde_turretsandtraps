# C148: Runtime work inventory and optimization proposals

**C149 follow-up:** owner retains this list for the next update and reports bulk ammo-transfer freezes. [Transfer investigation](#c149-bulk-ammo-transfer-follow-up-2026-10-11) now takes priority. Installed test build unchanged.

2026-10-11. Owner request: investigate optimizations while the owner tests, and count per-tick work and possible substitutes. Read-only gameplay audit; recommendations below are **not implementation approval**. R1C3 investigation accompanies the pending R3C7 owner test. Do not change/install the tested build or reopen previously accepted lag tests.

Inspected branch `codex/performance-barbed-audit`, HEAD `9f469a0b4a84c96606dd63ba3eeb36025ea7eac8`; fetched origin/dev `5fc64467873ea81404927882cdeb5b07d2e1c50a` and confirmed open draft PR #1 targets dev. Source/Contents have no difference from immutable `test/v0.2.42`. Counts come from canonical Lua registrations, cross-checked against both generated packages. No native game instance, benchmark or gameplay test was launched during this audit.

## Counts and scope

| Event family | Traps only | Turrets only | Both, unique callbacks |
| --- | ---: | ---: | ---: |
| OnTick | 6 | 4 | 9 |
| OnTickEvenPaused | 2 | 2 | 2 |
| OnZombieUpdate | 3 | 0 | 3 |
| OnPlayerUpdate | 2 | 0 | 2 |
| Drawing events | 2 | 3 | 5 |
| Total registrations | 15 | 9 | **21** |

Shared virtual Lua paths execute once; do not add the package totals together. These are source registrations for the current SP setup, **not 21 expensive jobs every frame**. Zombie callbacks scale with engine-updated zombies; player callbacks with updated players; render callbacks with their event/viewports. Most handlers have empty-work, feature or debug guards. Three shared registrations account for the overlap: Diagnostics.flush, Diagnostics.pulse, ActiveTime.pause.

The turret scheduler contains **8 workers**, already included in its single OnTick registration: automatic targeting/firing, manual search, aiming, ammo/reload/refresh, projectile arrivals, secondary rays, optional impact observations, and the optional startup firearm audit. The last two are diagnostic work. New Piercing/Initial Blow/Execute/Impact logic and module/weapon power calculation add **zero event registrations**; they execute within existing hit/cycle/stat paths.

There are also **15 declared update/prerender/render overrides** used by active UI, placement previews or timed actions: six action update methods, two Building controls, two wrappers of the same native construction-preview render method, one inventory-tooltip wrapper, one Manage panel and three methods on each instantiated slot widget. These are not 15 global background callbacks or a fixed number of invocations. Native inherited behavior is outside this source count.

## Nine direct tick handlers

Paths below are relative to Source/42.20/media/lua; symbols remain the authoritative references.

| Handler | Actual work / current limits | Better option or reason to retain |
| --- | --- | --- |
| server/OMHTT/FoundationServer.lua: Server.tick (175) | Up to four persistent slots per tick; active barriers run full Footprint.sync, retired slots retry outline/part cleanup. No elapsed-time budget. | Highest priority: separate health observation from geometry repair, dirty/event-driven geometry with a bounded slow safety pass, active loaded work list. Keep saved retired records for streamed cleanup; remove completed cleanup from the hot work list, not persistence. |
| shared/OMHTT/BarbSections.lua: B.tick (387) | Advances a clock; resolves/validates up to four panel/wire records and updates panel orientation. No elapsed-time budget. | Cache object references, retain immediate live support/door validation, stagger repair/cleanup separately. Do not delay contact on an opened door or remove support-health semantics. |
| shared/OMHTT/BedSpikes.lua: B.tick (260) | Clock plus enable/session transition; no world scan. | Cheap. Could share active clock sampling, preserving separate sessions and independent packages. Low priority. |
| shared/OMHTT/TurretClock.lua: C.tick (17) | Active elapsed-time clock; no world scan. | Retain; shared clock plumbing only if it simplifies code without ordering/pause regressions. |
| shared/OMHTT/TurretScheduler.lua: B.tick (21) | Round-robin eight workers, cooperative 3 ms total deadline. | Retain bounded per-tick draining. Empty workers can sleep; deadlines cannot interrupt an already-running native/Lua operation. This is not a hard total-mod frame ceiling. |
| client/OMHTT/TurretRenderer.lua: R.tick (153) | Animates every cached turret each tick; full stale-entry sweep once/second. | Bound stale cleanup and reduce redundant checks; consider a visible render list. Idle sweep writes actual aim state, so blindly skipping off-screen animation can change gameplay. |
| shared/OMHTT/Diagnostics.lua: Diagnostics.flush (216) | Summary check each tick, summaries every 5 seconds; up to two queued messages / cooperative 1 ms slice. | Early return when disabled and empty; activate drain only with work if warranted. Keep useful aggregate diagnostics. |
| client/OMHTT/BarrierCollisionOverlay.lua: Overlay.update (12) | Debug overlay only; when enabled scans 17x17 squares per local player every 250 ms. Disabled path still allocates an empty table each tick. | Clear once on disable; reuse indexed defenses or refresh on movement/changes with a bounded fallback. Debug-only benefit. |
| client/OMHTT/DevMarkers.lua: update (40) | At most eight temporary developer markers; at most two readiness probes/tick, each due every 250 ms, expire after six seconds. | Return before reading time when empty, or attach only while markers exist. Low priority. |

## Other high-frequency paths

- **Three zombie callbacks:** BarrierRetaliation.update polls the thump animation strike token; BedRuntime.B.zombie tracks entry/fall/recovery; BarbRuntime.B.zombie checks contact and scales current pending displacement. Bed/barb callbacks already reject empty defense populations and use nearby tile indexes. Preserve actor-update timing for movement, landing transitions and strike markers. Cache shared trap references/geometry instead of reducing actor-update frequency. A merged dispatcher could share square/key reads, but requires profiling and preserved cleanup ordering; fewer registrations alone are not a worthwhile redesign.
- **Two player callbacks:** BarrierVault.update handles automatic/active vaults; BedPlayer.B.player handles brush/contact, movement and injuries. Preserve prompt entry/exit and no-clip cleanup. Avoid unnecessary writes/geometry work outside relevant tiles; low actor counts make this lower priority than zombie contact.
- **Five drawing callbacks:** turret heads, bounded projectile/effect list (64), selected turret range, collision debug overlay, developer markers. Visible drawing belongs to render events. Optimize candidate filtering/cached data, not a slow timer that makes visuals stutter. Range geometry is already cached. Current head renderer iterates all cached entries for visibility checks each render; firearm draw temporarily changes/restores native item rotations and atlas state, so any batching needs native/render verification and state-restoration safeguards.
- **Two pause-aware callbacks:** ActiveTime.pause updates clocks only while paused; Diagnostics.pulse records optional frame gaps. Preserve pause/offline exclusion and elapsed-time/no-catch-up-burst semantics. Consolidation is minor cleanup, not a proven hitch fix.

## Recommended sequence

1. **Barrier maintenance:** Footprint.sync (server/OMHTT/BarrierFootprint.lua:456) rediscovers parts/health objects, reapplies collider state and always calls Outline.refresh for outline barriers. Outline.objects (BarrierOutline.lua:121) allocates and sorts results; Outline.refresh (224) revisits edge squares. Reuse discoveries within one operation; dirty geometry on construction/removal/repair/load, maintain cheap health observation for damage sources not covered by hooks, bounded periodic reconciliation as fallback. Persistent slot traversal includes inactive/retired entries, so separate the hot loaded work list from saved cleanup records. Preserve joins, outer caps, health loss and unload/reload behavior. Add a trap maintenance time budget without coupling Traps to the Turrets package or starving combat.
2. **Barbed contact resolution:** BarbSections.contact (352) calls B.resolve for every nearby actor/candidate; B.resolve (130) scans square objects or both wire parts. Cache validated frame/host/part references and reuse geometry where safe. Recheck health, removal and door orientation at the point of use; invalidate on service/build/removal/load. Many zombies on one trap should reuse object discovery. Preserve per-actor contact selection, 2-second damage, wear and current-update slowdown. Do not use an unverified native contact event as a claimed drop-in replacement.
3. **Reuse resolved turret stats within each operation:** W.contents already caches inventory for 200 ms, so proposing an inventory cache as wholly new would be redundant. However W.feedTick computes T.cycleConfig, then W.power computes it again; aim and automation also resolve via M.profile and W.power. Pass one resolved stats table through those calls. Prefer local reuse before a long-lived cache with difficult invalidation for condition, attachments, magazines and Sandbox changes. Keep authoritative fresh checks at shot commitment and actual power-source/fuel validation.
4. **Bound rendering/housekeeping work:** incremental stale-entry sweeps, avoid repeated native profile/options lookups within a render pass, cache formatted Manage text at its existing 200 ms refresh. Keep drawing every rendered frame and preserve shared aim state. Measure actual dense-client render cost before attempting broader culling/batching.
5. **Queue and diagnostic cleanup:** TurretVolley.tick removes index 1 from a queue capped at 256, shifting remaining entries; use head/tail FIFO bookkeeping with occasional bounded compaction and preserved reservations/order. Clear disabled overlay buffers once and skip empty debug work. Useful predictable housekeeping; lower expected gain than the first three and no measured speedup claimed.

**Later, profile before redesign:** automatic searches scan a square of side 2*ceil(range)+1 in 64-work-unit slices. At range 50 this includes 10,201 grid positions before moving-object visits, but not all in one tick. Shared spatial target candidates could reduce repeated overlapping/empty scans, but maintaining a zombie index has its own per-zombie cost and correctness burden. Keep existing 4-entry/2 ms automation slices, 8-entry/1 ms aim slices, 100 ms feeder checks, 250/100 ms configured detection intervals, 16 checked/4 completed projectile arrivals, and 128-step/1 ms secondary-ray slices under the shared 3 ms scheduler. Slowing detection, increasing the budget, or dropping side rays would change responsiveness/approved behavior and is not the recommended first fix.

Do not move combat/contact or bulk maintenance wholesale to EveryOneMinute: it changes latency, batches work, and follows game-speed time rather than the approved active elapsed-time behavior. These conclusions identify redundant work, not measured savings or a proven cause of a current pause.

## Evidence limits and handoff

Read-only console snapshot: 24,155 bytes, last write 2026-10-11 18:21:12 local. It contains startup/font/script messages but no OMHTT gameplay timing or loaded 0.2.42 package confirmation. It cannot certify this owner test or attribute performance to OMH. No versioned owner pass/failure recorded; inspect the completed session log after the owner reports results.

Source and generated-package registration counts were independently enumerated; shared duplicate Lua payloads match exactly and the gameplay tree remains identical to the immutable test tag. No gameplay edits, install, version bump, Workshop notes or native stress test. R3C7 test remains pending. **Test now:** continue the existing 0.2.42 test. A later optimization patch requires scope approval; start with items 1-3, then the bounded housekeeping in 4-5.

## C149 bulk ammo transfer follow-up (2026-10-11)

Owner retains C148 for the next update, reports freezing when transferring approximately 600 rounds through ordinary turret inventory, and requests the same fast transfer rate through Manage and inventory. Preserve speed rather than forcing individual-round delays. This sets the next-update direction; no immediate install during the ongoing owner test. Keep all five C148 offers, with bulk transfer first. No repeat scope question needed merely to establish this requirement.

### Findings

- Installed vanilla `media/lua/client/TimedActions/ISInventoryTransferAction.lua`, `checkQueueList`, merges compatible actions and groups same-type light items (rounded weight <= 0.1) into **up to 20 per group**. `perform` validates/transfers that group's items synchronously. Normal batch size is capped; it is not a 600-round group. Queue collection nevertheless loops over all consecutive compatible actions without a time budget. Batch size and queue-preparation cost are separate issues. Other mods could override these inspected vanilla rules.
- `client/OMHTT/TurretTransfers.lua`, `X.queue`, sets `action.canMergeAction = separateTransfer`, whose return is always false. This explicitly disables Manage batching and explains the one-round/group difference. Its selection loop also synchronously creates one action per item with full rejection checks. Simply removing the override would not solve repeated work.
- Both transfer `isValid` and `transferItem` call `X.rejection`. Incoming checks run `T.configure`, `T.contents`, `T.accept`, then native acceptance/room checks. `T.accept` itself calls `T.contents` and resolves stats. `T.contents` scans every item, allocates tables/an ammo list, then walks that list again. Repetition as the reserve fills creates quadratic item-visit growth across a large transfer. Outgoing ammo also causes full scans in `T.canRemove` and firearm-feed restoration in the transfer hook; inspect both directions.
- `W.queueRefresh` **already coalesces refresh work**. Do not attribute the freeze to a proven full visual refresh per round. Transfer validation bypasses the existing 200 ms `W.contents` cache, which each moved item invalidates. Native acceptance may add more scans. No isolated transfer-stage CPU measurement yet.
- Console confirms **0.2.42**. Successive summary windows show 106, 300 and 194 transfers (600 total), with maximum active update gaps of 49, 343 and 542 ms. A later 100-transfer window has a 563 ms maximum. Concurrent combat/UI activity remains a confounder; timing correlation supports the owner report without attributing every gap to this code.

### Next-update contract and recommended implementation

1. Same **turret-specific ammo batching/duration policy** through Manage and ordinary inventory, initially retaining native light-item groups of up to 20. Same items/source/destination/player conditions should match. Preserve exact-item native transfer semantics, sounds and interruption. Do not globally alter unrelated containers or force heavy ammunition into light-item timing.
2. Bound **queue preparation and execution**, avoiding synchronous creation/merging of the entire selection with repeated full checks. Use cooperative time/item limits and yield under load while keeping normal throughput fast. Measure suitable slice sizes; no unsupported rounds-per-second or hard native-call deadline promises.
3. Reuse operation-scoped inventory/stat information with coherent incremental ammo/weight updates and invalidation. Keep fresh reach, ownership, capacity/weight, ammo compatibility and cancellation checks at commitment. Native accept callbacks must share valid state without bypassing limits. Account for live firing/reloading and inventory/head/module changes between slices.
4. Preserve pending-item reservation/deduplication across interfaces and merged groups: current Manage scans individual queued actions, so removing its merge override alone is unsafe. Verify both directions, no ammo loss/duplication, interruption/walking away, full-container partial completion, source changes, firearm overflow and save after cancellation/completion. Preserve native weight limits and avoid a second inventory authority.
5. Add bounded aggregate timings for queue preparation, validation/acceptance, commitment and refresh. Use focused native/Kahlua checks before one short same-quantity comparison through both interfaces, including cancellation/full storage. No heavy reproduction or install during the current owner test.

Local console snapshot: `diagnostics/v0.2.42/console-c149-ammo-transfer.txt`, 146,809 bytes, SHA-256 `6ff4737a6940ab8183d6ecebedab8dd280e02c954032018e37d1195df6a75805`; source last write 2026-10-11 18:35:14 local. [Versioned finding](TEST_v0.2.42.md#c149-owner-finding-bulk-ammo-transfer-freeze-2026-10-11). No gameplay change or fix verification. **Wait for a patch** for this issue; R3C7 is not automatically passed or closed.
