# 0.2.70.1 - Controller map range preview

C485,2026-10-26. Owner corrects the C479/C481 interpretation: remove only the gradient circle in the game world, retain the Controller menu map preview. The previous removal deleted the map renderer block and changed its test to expect no outline; that was the wrong acceptance criterion.

Restore that existing64-segment outline in ControlMap.render using ControlAccess.radius once per render. Existing map projection, zoom, stencil clipping and markers remain in use. No new overlay, scan, networking, setting or state is introduced. In-world rendering and server range enforcement are unchanged. Tests check every endpoint against all five kit radii at three map zoom scales.

The owner reports the rest of0.2.70 passed: Connections selection/grouping/assignment, compact settings and tether recovery. Connected multiplayer remains pending. Console snapshot diagnostics/c485-console.txt confirms T&T0.2.70 SP and Horde0.6.16.9. Its errors concern fonts, Firearms Sandbox formatting and world-map data; no Controller stack trace was found. These log observations do not independently prove rendered acceptance.

Existing saves work; restart is needed for changed Lua. Horde/Cure0.6.16.9 and Trait Shop0.9.1.1 remain unchanged. Preserve the cumulative Workshop draft and owner AMMO_UI_C446.md edit. Read-only origin/dev fetch found zero newer commits. Private mirroring remains blocked by the previous approval review; no retry or publication. See [verification](TEST_v0.2.70.1.md).
