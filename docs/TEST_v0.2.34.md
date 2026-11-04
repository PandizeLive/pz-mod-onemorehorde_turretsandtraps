# 0.2.34 — combined owner test

Restart into a fresh single-player debug world with both entries and default Sandbox values. Crafting cheat is fine; disable Instant Actions for timing and God Mode for injury checks. This replaces the held 0.2.33 checklist, not the waived split regression.

1. **Menus/crafting:** confirm **0.2.34**. Check collapsible recipe families, Pack/Unpack and Install Trap labels; craft the three Improvised components. Panel/basic bed/reinforced bed weights remain **2/3/4**.
2. **Expansion:** open Manage and swap kits with modules unloaded: None/Improvised/Small/Medium/Large show **2/4/8/12/16** slots in two rows. Install Detection and Firing; a second version of either role must be rejected.
3. **Automation:** use improvised Detection/Firing on a loaded, powered potato turret. Detection reaches **4.5 tiles** at default range; manual fire reaches **6**. Temporarily set failure chance to **100**: automatic attempts click and wait without spending ammo/power; manual fire still works. Restore **15**.
4. **Placement/service:** attach a panel to a fence and place a bed directly behind it. Time placement and pickup/removal at **5 seconds each**; damaged defenses still repair in **10**. Moving cancels safely.
5. **Movement:** walk/run through beds—brush animation, safe walking; noclip bypasses effects. Sprinting can trip and injure. Lead a few zombies over beds: forward trips, damage once per fall, and recovery to standing.
6. **Load/save:** run your previous heavy turret/module setup, then save/reload. Contents, kits and charge persist. Report any noticeable pauses, the step that failed, and say **Test Complete** so the console can be reviewed.

## Owner result and console review, 2026-10-08

Owner reports Test Completed and says unmentioned checks passed "(I think)". Record those as tentative owner-reported passes, not independent console proof. **Failed:** zombies trip forward far enough to miss the bed. Do not repeat this complete checklist; target changed behavior in the corrective patch.

Console captured through OMH.cmd into `diagnostics/captures/20261008-224128-4929/`; SHA-256 `9db500044e07f6eada25921dc101b7745aa75f4f3a59b3c9baf596b10118e9fb`. It confirms 0.2.34, both entries, game 42.21, and no ERROR/Exception/STACK TRACE lines after packages-ready. Earlier startup errors/warnings include Firearms translation formatting and native world/asset messages; this is not an entirely error-free console.

- Recorded 13 bed-trip requests and 8 damaging bed-fall events. Counts are not paired by actor in summary logging, so they neither give a trip success rate nor establish where each actor landed. The owner's visible launch/missed-bed report remains the acceptance failure.
- Recorded base/improvised module capacities 2/4 and improvised reserve capacity 125. This does not independently prove all tiers, role rejection, failure-at-100%, or every service timer.
- Recorded 10 turret fire results and 9 resource-spent events; maximum reported fire and potato-audio work were 7 ms, preparation 1 ms. Only one deployed turret identity appears in this capture; it does not certify the previous dense-load pause problem fixed. Projectile flight duration is not frame-processing cost.
- One packages-ready marker and an end-of-session save/exit are present. A subsequent reload and restored state are not independently visible in this file.
- Screenshot group identifiers are native crafting debug labels shown by isDebugEnabled(), not extra recipe names in normal play.

Requested follow-up: Normal/Reinforced/Packed crafting organization, Building reintroduction with corresponding useful groups, three module rows, and correction of excessive zombie trip travel. Building's raw-material-versus-crafted-item input route is awaiting clarification; Packed bundles require unpacking for placement. Proposed module arrangement is 6/6/4, preserving capacity. Internal item-ID suffixes are discussed separately from player-facing labels/category. See C106 in [Decisions](DECISIONS.md). No corrective gameplay implementation is claimed by this review.
