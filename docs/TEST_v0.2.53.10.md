# 0.2.53.10 — Verification and short test

C308, 2026-10-17. Implements approved C306/C307 corrections. Owner rendering and connected multiplayer acceptance remain pending.

## Automated verification

Full validation passes 21,596 assertions, 218 compiled runtime/translation inputs and 1,008 translation keys; 290 source files and 370 package files. Focused Kahlua fixtures cover invalid angles, exact identities, owner/read-only access, Controller power/range/assignment, replay protection, exact-angle profiles, retained 360 coverage, OFF-state persistence, bounded turning without implicit fire, single-pulse completion, cursor click/cancel/replacement handling, contextual linking and non-overlapping action rows. Native table serialization retains direction. Initial new-fixture failure was a missing getObjectIndex method on its Controller double, corrected before the pass. Test doubles do not establish rendered or connected acceptance.

The first native pass reached the new direction checks but its test left the shared fixture switched OFF, causing a later existing reload assertion to fail. The fixture now restores its original power before continuing. Its crawler fixture also now uses the installed native setCrawler API. Neither failure was suppressed or worked around in production code. Native dedicated write/read both pass with zero connected clients: real standing and crawling zombies cannot select plates for thumping; server publication preserves the exact direction; native save/restart restores 234.5 degrees and the pending-turn state. Existing-plate binding reapplies the passive flags. Review also caught and corrected placeholder-sprite collisions: an ordinary map floor cannot bind a saved control device, because binding now requires the native IsoThumpable class. Traps-only, Turrets-only and combined native startup all pass. Static dependency closure and the shipped Lua banned-call gate also pass. Installed bytes, source/tag/archive correspondence and prior-version backups are verified below.

## Short owner test

1. Restart with **0.2.53.10**. Walk zombies across an existing and a newly placed pressure plate: both activate normally and neither attracts thumping.
2. In a powered Controller, choose a plate, **Use as Input**, select an assigned turret, then **Connect**. The same button becomes **Disconnect**; pressing/releasing the plate powers/fires and stops the turret.
3. Select the turret and **Set Facing**. Click a new direction: FoV and straight shots match it; selecting direction itself fires nothing. Repeat and cancel with right-click/Esc; the menu returns without changing facing.
4. Set facing while the turret is OFF, then activate it: it turns only after power returns. Check a button still requests one cycle. Detection tracks within the new FoV; 360 keeps full coverage.
5. Save/reload and confirm the direction and links remain. Report any issue; Codex will inspect console.txt. Connected dedicated/listen acceptance remains a separate held test.

## Delivery

Installed from immutable `test/v0.2.53.10` / `a51256e1685e770de1b68721df5736b92e843424` using `OMH.cmd -Action Install`. All 290 source and 370 package/tag/install/archive files match. Both 0.2.53.9 backups verify. [Release evidence](../diagnostics/v0.2.53.10/local-release.json) records hashes, package counts and the managed backup. Development mirror uses the existing branch/draft PR under C108. No Workshop upload or official release; rendered and connected dedicated/listen acceptance remain pending.
