# C531: stacked projectiles, rotary contact and stabilizer construction

Owner approval: 2026-10-31, C529/C530 option 1A. Implement all reported findings; verify stacked modules and contact timing before packaging. Extra client presentation is authorized where necessary, with disclosure. No Workshop upload, live server or sibling modification.

## Replacement behavior

- Primary firearm visuals are independent of child completion. Incremental child scanning traverses tile boundaries, retains the one-millisecond scheduler budget, and emits each completed ray immediately. The 1024-operation emergency ceiling removes the former 128-operation bottleneck without changing module balance or removing the global work deadline.
- Physical child contact emits before damage-admission waits. Server-announced terminal flights can end visually on local contact or at their endpoint; the existing phase ledger suppresses duplicate late confirmation. Clients never award damage, kills or XP. Local geometry may disagree under latency; dense paths retain authoritative fallback (128 actor checks per flight/frame).
- Standalone turret proximity participates in existing owner position reports. Rotary contact compares reported positions with recorded motor travel at that timestamp. History spans up to 750 milliseconds with a hard 128-sample bound. No invented client attack or parallel damage authority.
- Native entity and legacy wall placement check Poke reservations before construction consumes materials, including either side of a wall edge. Traversal remains available.
- Trigger rendering stops safely when a multiplayer session exits.

## Evidence and limits

Verification completed: 44,249 assertions, three frozen-code negative controls, native write/read and all independent package starts pass. [Evidence](evidence/c531-verification.json). Tests include 1, 2, 4, 5, 6, 8 and 16 Splitters, contact positions rather than only empty flight, delayed confirmation and duplicate suppression, historical rotary crossings, construction completion gates, native API startup and package independence. Automated fixtures are not connected visual acceptance; GPU rendering and two-client live retest remain separate.

## Observed results and boundaries

Released 0.2.71.1 paths fail the named primary-delay, local-contact and disconnect assertions; corrected paths pass. The production scan replay over 30 empty tiles no longer has the old 400/500 ms step-count floor at five/six Splitters. With the real one-millisecond deadline, five/six rays completed in one slice and sixteen required several slices in measured runs. The shared scheduler can still defer work under load; this is not a zero-latency guarantee.

Native IsoZombie health tests exercise actual ray traversal and damage application for stacks 1, 2, 4, 5, 6, 8 and 16: five-tile contact at 20 tiles/second causes no loss through 245 ms, then exact cumulative loss and one impact per child at 250 ms. Square lookup, clear-lane and transport are adapted for isolation. They do not recreate native network transport. Client renderer tests cover delayed launch packets (0/50/150/250 ms), actual target distance, endpoint completion, Fragment source exclusion and late-impact duplicate suppression. Current-module catalog, capacity, persistence and mixed-proc tests remain in the full suite.

Rotary tests distinguish historical crossings from the current sweep, reject repeated/expired observations and owner handoff, preserve high-tick-rate history, and avoid a hit when the target moves away. Existing cone/360 rendering and grounded exclusions remain covered. A reported position is still a sample, not a perfect continuous trajectory; live damage notice timing depends on transport.

Native construction checks invoke ISBuildIsoEntity and ISWoodenWall preview/completion functions and prove reservation rejection before material consumption. Crafting/lookup adapters are used; actual player placement remains in the checklist. Native package startup proves hook installation. Existing negative ownership probes deliberately log the old havePlayer bridge exception; current C531 probes complete without that failure.

Confirmed Workshop content upload of 0.2.71.1 to item 3828638252 on 2026-10-31T05:46:00.8829383Z is the new cumulative changelog baseline. [Receipt](evidence/c531-upload-baseline.json). Only subsequent net changes appear in the 0.2.71.2 draft. Owner edits in AGENTS.md, README.md, docs/AMMO_UI_C446.md and docs/RELEASE.md remain outside this change.

No balance values or save schema changed. No new world required. No Workshop upload, live-server operation, sibling change or alternative GitHub push. The previous automatic approval-review rejection of mirroring remains in force.
