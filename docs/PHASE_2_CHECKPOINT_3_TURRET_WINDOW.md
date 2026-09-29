# P2C3 dedicated turret window — 0.2.12

## Scope and behavior

C54 approves a turret-specific Manage window after the owner reported the prior implementation opened standard loot. Head, battery and ammo each have a labeled area; module slots use four-per-page layout at higher capacities. Drag from carried inventory into the matching area. Drag installed items back into vanilla inventory or right-click a slot to remove its contents. Unload ammo queues all potatoes. One native container remains authoritative; slots hold references to its actual items.

Manage opens/pins player inventory, never opens/selects loot. Normal vanilla transfers may still select their source/destination internally. The underlying container remains accessible to vanilla inventory; hiding it or changing global inventory behavior is outside scope.

Transfers retain vanilla durations, animations, sounds and actual item identity. Incoming batches reserve available per-kind space; repeat requests do not queue the same item twice. Execution rechecks reach, capacity and loaded-head restrictions, including transfers initiated from vanilla loot. Incompatible, favorite, missing and excess items stay at their source. Removing a loaded head requires unloading first. Battery charge and head condition are preserved. Closing the window does not cancel an otherwise valid queued transfer; moving away interrupts/invalidates it.

Status includes ammo/loaded rounds, battery charge, power source, readiness, damage/range/durability, reload and shot cooldown. Short feedback describes queued items or rejection. Modules are explicitly labeled storage-only; effects and automation remain P2C3d, multiplayer P2C3e. No recipes, materials, skills, XP or balance defaults change.

The base-only tile retains 0.2.11.1's corrected ground center (64,224). The 16-direction full-turret sprite fallback now shares that center instead of the old 16-pixel-high anchor. The actual head keeps the owner's scale 0.512 / height 0.4 calibration. No final art or model redesign.

## Evidence and limits

- Captured prior console: `diagnostics/captures/20260929-172914-1427`. Loaded 0.2.11.1; `turret-manage-open containerSelected=true` confirms the old loot shortcut. No Manage exception in that run. Native font/map/recipe warnings are unrelated to this change. Visual acceptance was not established by this log.
- Current installed 42.21.0 sources: `ISInventoryPane.getActualItems` expands selected groups while removing duplicate selections; `ISInventoryPane.onMouseUp` hands dragged exact items to timed transfers and calls the source's mouse-up cleanup. Both installed functions execute in the regression harness against UI/player doubles.
- `ISInventoryTransferAction.new/isValid/transferItem` supplies native timing, legality checks and actual transfer. New wrappers apply only when either container belongs to OMHTT. `ISItemSlot.onMouseUp` is the native precedent for receiving inventory drags in a separate panel; this UI does not use its crafting-resource mutation path.
- Runtime-loaded world access retains the prior client-before-server regression guard. `TurretTransfers`, `TurretSlot`, `TurretManage` split transfer rules, slot interaction and layout. Duplicate shared cycle helper definitions discovered during review are removed without changing behavior.
- Kahlua tests cover dedicated opening without loot access, exact-item queue/transfer policy, grouped selection, duplicate requests, ammo overflow, head prerequisites, full inventory, favorites, stale reach, all twenty module slots, native outbound drag handoff and a 1280x720 layout. These use world/UI doubles and do not prove rendered mouse routing or GPU alignment.
- Diagnostics: `turret-manage-open` includes `interface=dedicated` and dimensions; status changes record supplies/power; transfer requests record requested/queued counts and denial reason; completed transfers record exact item ID and actual destination membership. No per-frame log spam.

## Automated validation

1,641 Kahlua assertions pass; 36 runtime Lua files compile, 243 native translation keys load and 23 packet checks pass. All 102 package files are manifested. Native model import, 49 tile identities / 27 texture pages, and byte-level ground-anchor checks pass for the base and all sixteen fallback headings. The isolated stock 42.21.0 write/startup/shutdown probe passed in 88.2 seconds, including actual-item in-process save/restore and four-sided collision/clear sight/reach. This patch does not change the persistence schema; no new fresh-process read run is claimed.

## Complete owner test

Use single-player, with a deployed turret, potato head, charged car battery, potatoes and at least one module available. Existing Sandbox values remain saved; adjust to 85 ammo / magazine 1 / reload 1s / cooldown 0.5s only if testing current defaults. Leave inventory room for removed items.

1. Restart and confirm **0.2.12** in Foundation Test Controls. Open Turret → Manage: expect a dedicated slot window, plus your inventory, without automatically opening the loot window.
2. Drag in a head, battery, potatoes and module. Expect timed transfers, correct counts/charge and live status. Try a wrong item or second head: it should remain in inventory with short feedback.
3. Drag the battery back into inventory, then reinstall it; charge should match. Try removing the loaded head, then Unload ammo and remove it: only the empty head should transfer. Reload the turret afterward.
4. Fire at a visible nearby zombie. Expect one real potato/power charge spent, loaded/reload feedback, independent aiming and a grounded base. Walk into the base: blocked, but sight stays clear.
5. Close/reopen Manage, then walk away with it open: it should close. Pick up/redeploy, save/reload, and reopen: contents/charge remain. Switch 3D items off/on once: both base and fallback should sit on the ground.
6. Finish with **Test complete**. Capture console through OMH.cmd → 6; send a screenshot if placement, layout or drag/drop still looks wrong.
