# Test 0.2.57.2

## Automated evidence

Installed-game Kahlua validation passes **25,867 assertions**, including native Small-font sizing formulas, compact module geometry, equal action buttons, shrink-with-Details containment, ordinary unload versus retirement, and public/authoritative input agreement. Package validation checks 308 source files, 402 packaged files and 344 local UI translation keys.

Native write/fresh-process read probes pass live-link persistence, cleanup of deliberately seeded legacy retired links, public/server input agreement, real-item ownership and reload/firing authority. Traps-only, Turrets-only and combined startup checks pass (52.4 / 50.6 / 47.4 seconds). These isolated dedicated probes use zero connected clients. Both UI drawing traces were rendered and inspected as geometry evidence; they are not screenshots of the native game renderer. Installation evidence follows in local-release.json.

The first native write attempt stopped in the existing 5,000-round fixture because AddItem rejected a randomly duplicated item ID. The fixture now assigns deterministic IDs to that isolated batch; production item identity is unchanged. The complete rerun passed after that fixture correction. A second native run caught retirement unnecessarily applying Off to an unlinked turret; cleanup now requires an actual incoming link. An empty-index regression check also verifies that packed power is preserved.

## Focused owner test

1. Restart and confirm **0.2.57.2**. Compare both title/footer strips with Building at your current font size; close and corner resizing should fit, with no lock/pin controls.
2. Open Manage and shrink its width. Equipment/Ammunition should be balanced, Remove To/Set Aim equal, and all sixteen modules remain centered in four rows of four.
3. Open Details and shrink the height. Equipment, ammunition and modules must remain visible above stats; the resize stops at the content minimum. Close/reopen both menus to check saved geometry.
4. Try Lure/Lobber controls with Details. A very short viewport may explain that Details cannot fit, but must never replace or hide the main sections.
5. Link a Button/Plate, activate it, then pick up the trigger. Its connection should disappear from the turret and Controller, and it must no longer force trigger-only power. The power tooltip should name only actual remaining inputs.
6. Leave a live linked trigger in place, unload/reload the area and restart. Its connection should survive; reinstalling a previously picked-up trigger should require a new explicit connection. If available, repeat remotely with a second player.

## Remaining acceptance

Rendered client/UI/audio and connected-player acceptance are pending. Exact five-second native multiplayer placement remains separate and unresolved. This patch does not establish a cause or cure for the earlier whole-PC main-menu slowdown. No Workshop publication or merge.
