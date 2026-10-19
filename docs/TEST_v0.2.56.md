# 0.2.56 verification — C327

Owner selected 1A shared per-Controller groups and explicitly approved the full C326 patch. Automated checks are separate from rendered and connected-client acceptance.

## Automated evidence

- Kahlua validation: 23,775 assertions pass, including native UI geometry, group-layout/concurrent-feedback fixtures, local/remote aim gating and package closure. [Log](../diagnostics/v0.2.56/validation.log).
- Native server write and fresh-process read pass: group create/rename/reorder, serialized device moves, private-write rejection, stale/replay rejection, detached snapshots, group deletion preserving links and persisted organization. No player was connected.
- Browser tier checks pass: actual card drag/drop, keyboard assignment, seven rarity colors, custom weights, confirm/cancel, refresh persistence, mobile bounds and zero page errors.
- Hosted LootLab two-asset update verified: unchanged production Worker SHA-256, 13 protected paths and two public endpoints. See [publication evidence](../diagnostics/v0.2.56/lootlab-release.json).
- Independent Traps-only, Turrets-only and combined startup pass. Installed from immutable test/v0.2.56; 301 source and 389 tagged/packaged/installed/archive files match, and both 0.2.55.2 backups verify. See [release evidence](../diagnostics/v0.2.56/local-release.json).

The initial browser fixture dragged selectable label text instead of the card; a real pointer drag from its border passed. Native ordering fixtures were corrected to check relative placement, preserving unrelated existing devices. Code-driven layout traces do not establish GPU rendering, native popup stacking or connected replication acceptance. All-disconnect can partially fail if permissions/power change. Group edits use revision rejection rather than silent merging. No new gameplay or main-menu performance fix is claimed.

## Short owner test

1. Restart and confirm **0.2.56**. Open Controller; resize narrow/wide and short/tall. Stockpile must stay inside its panel or open as the full-width page, and extra height should grow the map.
2. Add Front/Rear groups. Drag devices within and between them, drag group headers, rename/collapse/delete a group. Links must survive; reopen and reload the save to check names/order.
3. Connect using ports and map dragging. Dragging cards must sort only. Look for hover, pending/confirmed feedback, local click sounds and distinct trigger/defense shapes.
4. Right-click a connected map device or trigger port. The menu must stay above Controller; remove one connection, then All, checking that unrelated links remain.
5. Open Manage with 16 module slots. Check centered **4/8/4**, narrow resizing, Details and Set Aim beside removal. Test nearby with Controller power off, then remotely with power on. Cancel aiming and ensure the menu returns.
6. Check the turret world context menu: no Fire and no summary tooltip covering options. Open hosted LootLab: Mythic first, compact tier spacing, unchanged weights; try a draft move then Cancel.
7. When a second player is available, confirm shared group/order changes, read-only denial, competing-edit rejection and connection updates on both clients. This remains pending until actually tested.

Code-generated layout traces were visually reviewed using software browser rendering after the initial screenshot timed out. They confirm the intended split, anchored panels and module rows, but their test-double text/icon rendering does not replace game acceptance. No game/GPU setting was changed.
