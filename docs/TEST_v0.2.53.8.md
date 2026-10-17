# 0.2.53.8 — verification and short test

C302, 2026-10-17. Owner requests clearer battery identification and multiple small batteries. Console review still identifies the running client as0.2.53.6, through frame 15629; no T&T Lua exception found in this session. Native/other-mod map/translation warnings are separate. This is not acceptance of 0.2.53.7 or 0.2.53.8.

## Automated checks

Full validation passes 21,008 assertions, 215 compiled Lua/translation inputs and 995 translation keys. Static closure passes 160 Sandbox options and 69 identical shared files. Native write/read checks pass, including exact charged-spare selection after depletion. Traps-only, Turrets-only and combined native startup checks pass. The dedicated probes have zero connected clients. Focused coverage uses the installed native icon helper, checks an empty slot, cached 64-entry count slices, same-size invalidation, unrelated-item rejection, bounded stack processing, SP completion ordering, cancellation/close/access loss and selection of an already-stored spare. Native server fixtures verify two ordinary batteries can be deposited as exact items and a depleted battery selects the charged spare without changing the stored count.

No rendered client or connected multiplayer pass is claimed. No new engine authority or timed-action payload schema.

## Short test

1. Restart with **0.2.53.8**. Open an empty Controller: the battery slot should show the small Battery silhouette.
2. Drag three ordinary **Battery** items onto it together. Confirm **Stored Batteries: 3**, their presence in Stockpile and one selected battery/charge.
3. Remove one through Stockpile, then drag a stored charged spare onto the slot. Confirm the count updates and selecting a spare does not duplicate or move it.
4. Start another multi-battery deposit, then walk away or close Controller. Confirm the remaining batteries stay in your inventory. Reopen and verify counts; report any visual/interaction issue.

Review console.txt after this test. Keep prior rendered/controller and connected MP acceptance open.
