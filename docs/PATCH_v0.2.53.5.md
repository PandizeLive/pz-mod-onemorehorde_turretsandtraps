# 0.2.53.5 — Manage details, grouped Load Order and Controller access

C296, 2026-10-17. Owner directly requests the changes after the 0.2.53.4 test and clarifies that Access/Connections require standing inside the Controller world tile. The earlier whole-PC launch slowdown is owner-reported solved; no causal claim or display-setting change is made here.

## Changes and retained rules

- Installed Modules becomes **Module Stats**, inside Modules **+ Details**. Opening Details grows the window vertically. The main Manage body never scrolls; the module drop hint is removed. Short screens use compact module rows and, when expanded details cannot fit below them, an in-menu Details page with the same close toggle. Only long lists retain their own scrolling. Equipment and Ammunition remain side by side; Reload and Load Order remain adjacent.
- Equipment, Ammunition, Modules and Module Stats have header help. Detail statistics and module benefits retain separate bounded regions, with cleanup of hover tips when pages change or close.
- Load Order is a full-size child page of Manage, with Back and Apply. Physical and Void types share groups, counts and per-ammo bonuses. Reordering cannot cross a platform boundary. Spear detection uses the native SPEAR weapon category; potato/bomb/scrap use the existing accepted families; firearm platforms use exact registered AmmoType identity. Unknown cross-mod compatibility is not guessed from display names. Firearm headings use their ammunition's localized display name; a platform with one known type remains a one-row group.
- Orders persist by platform on the turret. Existing per-head orders remain fallback data. The authority validates identity/access, platform membership, bounded unique types and the previous saved value at completion; stale edits are rejected. Read-only players may inspect the page but cannot apply. Magazines retain their existing one-type-per-load behavior; this patch does not add new alternate firearm ammunition compatibility.
- Controller reach now follows native adjacent interaction's per-axis 1.6-tile test, retaining same-floor, adjacent-square and native wall/reach checks. This corrects valid diagonal edge positions previously excluded by the circular distance test.
- Open Manage can open a directly reachable turret even while the Controller is offline/unassigned. Remote Manage still requires a powered Controller and assignment. Disabled buttons explain power, assignment or access/reach requirements. Assign now enforces the same power condition on the server as in its UI.

## Findings and limits

The screenshot's Controller is **Offline / Backup 0%**. That explains disabled remote Assign/Manage. A powered Controller uses world electricity or a charged ordinary **Battery** in its Stockpile. Local Access/Connections act on the selected device; remote edits require assignment and the existing authorized session.

Native adjacent access passes six directions, plus the newly corrected diagonal edge. The reported general same-world-tile restriction was **not reproduced** in these fixtures. Do not claim that the screenshot proves its exact cause. Rendered owner confirmation is still required, along with connected multiplayer acceptance.

No balance, ammunition capacity, recipes, sound or artwork changed. No permanent per-tick scan, pcall or xpcall was added. Platform grouping happens when opening the editor or completing its existing paged Void read, not each frame. Main detail layout remains keyed to changed display/stat inputs; the duplicate per-refresh drag-method assignment was removed. Exact items and private Void accounting remain unchanged.

Current installed native evidence: shared `luautils.walkAdjObject` uses per-axis 1.6 reach plus `canReachTo`; client `ISButton` provides header/disabled tooltip behavior; existing `NetTimedAction` receives the scalar-table order request. Native zero-client checks do not prove a connected-client UI session.

[Checks and focused test](TEST_v0.2.53.5.md). C108 delivery uses the existing branch/draft PR; no Workshop upload or main merge.
