# 0.2.31 — backed Barbed Sections

C99 authorizes the next local content patch. One-tile wooden frames attach to walls, fences, ordinary single-panel doors and window frames through Building > OMH: Traps. They require backing and supported floor, reject duplicate same-face placement, and use white technical edge/arrow markers. Close a door before constructing on it. Multi-panel and garage doors remain unsupported pending their different movement/identity handling.

Zombies take 10 damage on first actual contact and every two active seconds while touching. One per-zombie interval covers neighboring sections and rapid re-entry. Leaving stops damage; there is no accumulated damage after absence, no extra attack/crossing hit, and no slow, trip or player injury. Damage and interval are adjustable under the Barbed Sections Sandbox page.

Door geometry/markers follow the native leaf edge. Window barbs remain fixed across open or smashed glass, have **their own 50 HP**, and never increase or repair the window's HP. Map/otherwise nondamageable supports also use independent 50-HP barbs. Every successful damaging activation costs one independent durability. Other finite, damageable supports share native health with no added structural HP or activation wear. Zero-durability sections disappear; intact separately durable sections can be repaired to 50 for free in ten seconds. Shared supports retain their ordinary repair methods. Removing a section takes ten seconds and returns no materials or XP; service requires retained hammer/pliers, reach and exact identity, and cancels on movement.

Construction consumes one Barbed Wire, two Planks, four Nails and **two uses** of Wire, retains hammer/pliers, requires Carpentry 1 and awards 10 Carpentry XP. Native construction time is 200 action units, matching the existing ten-second base construction convention; native building speed modifiers still apply.

The runtime indexes only loaded marked supports and checks nearby candidates. Cooldown updates skip repeated support/geometry scans. Cleanup processes at most four indexed sections per tick, including after mass unload. Support replacement cannot inherit a section by coordinate; unloading suspends it without destroying saved state. Frame objects add no collision or independent attack target.

## Verification and limits

Current evidence lives in `diagnostics/v0.2.31/`: Kahlua contact, runtime, lifecycle, pause/cooldown, service and bounded-work checks; native exact ingredient consumption, eight construction orientations/host cases; frame/support write and fresh-process read; Traps-only, Turrets-only and combined loading. The earlier isolated `diagnostics/barb-content-20261007/` probe proves twelve native host fixtures, ordinary door edge changes, controlled window state and eight controlled fence crossings. Actual rendering, autonomous zombie contact and client smoothness remain owner acceptance.

The held 0.2.30 test is consolidated into [one eight-step test](TEST_v0.2.31.md). The old package-split regression waiver remains intact. This patch does not claim that the previously reported turret audio pauses are fixed. No multiplayer combat, remote push, Workshop upload, website change or final art is included. Cumulative unuploaded Workshop notes are preserved.
