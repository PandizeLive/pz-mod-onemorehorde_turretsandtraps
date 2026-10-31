# C326 — Controller organization and responsive UI follow-up

Owner requests confirmation and mockups after testing 0.2.55.2. This records the next patch scope; no gameplay or hosted LootLab change is applied in this discussion. The inspected console confirms client/server/packages-ready 0.2.55.2 on 42.21. These reported UI failures remain open.

## Requested corrections

- Add native UI activation sounds, hover/selection highlighting, valid/invalid drop feedback and a short changed-border pulse. Native `ISButton` uses `UIActivateButton`; custom graph/map hit targets need explicit local feedback. Show pending requests separately from server-confirmed success. No repeated hover sounds, world noise or new world scans.
- Keep disconnect menus above the Controller, including submenus. Add **All**, scoped to the clicked device's incoming or outgoing connections. Preserve individual options. Check actual native stacking rather than assuming `bringToTop` alone fixes the owner-reported layering problem.
- Replace trigger-row linking with row reordering for both Triggers and Defenses. Keep port-click linking and trigger-to-defense map dragging. Right-click map devices or a trigger's right port opens individual/All disconnection. Sorting must not change targeting or fire order.
- Add named, reorderable, collapsible groups containing both columns, with **Add Group** and an Ungrouped destination. Recommend one folder level, unique membership per device, cross-group links preserved, and deleting a group only ungroups its members. Keep cross-group destinations discoverable when collapsed. Persist stable IDs, not display names.
- Narrow device cards within Connections to widen the visible cable gutter; retain readable head subtitle, ammo and condition bar. Preserve sensible pointer targets. Use circles for triggers, squares for defenses and a diamond for the Controller, with labels/legend and selected/active state.
- Anchor Selected Device at the bottom with content-aware height; extra vertical space goes to the map. Retain scrolling at small heights/large fonts.
- Restore centered module rows: four on the first row, up to eight on following rows; 16 slots become **4/8/4**, and extra Sandbox capacity continues **8** per row. Shrink tile width within readable limits; preserve all slots and tooltips at minimum supported width. Source currently hardcodes 4/6/6.
- Move Set Aim into Manage, beneath the battery, sharing equal halves with Remove To. Use the same checked local/remote aim action. Remove its duplicate Controller action; Open Manage remains there.
- Remove Fire from the turret's world context menu. Remove the large summary tooltip from its submenu-parent entry; detailed stats remain in Manage, while action-specific help remains. `TurretMenu.lua` currently attaches `T.description` directly to that parent.
- Show LootLab tiers Mythic first, down to Abundant; retain rarity names, numeric indices, weights, anchors and persistence. Reduce lane padding/gaps/header overhead, preserving individual module-card height. Current `tier-list.js` renders -1 through 6 and thus Abundant before Mythic; presentation reversal must not reverse stored arrays or calculations.
- Stockpile native rows/category header overflow at narrow side-pane widths. Clamp native columns and rendering to the pane, guarantee a readable minimum side-pane width, and switch to the existing full-width Stockpile page earlier when necessary. Keep the native inventory and player HUD separate. Current layout uses 25% width/minimum240 and a fixed 1000px breakpoint, which does not establish sufficient column space.

## Remaining choice

**1A recommended:** share group names/order per Controller, persisted and changed through server-authorized commands by players with write access. Everyone may view. Group changes never alter links or inventory. Bound/sanitize layout data, validate revisions and serialize concurrent edits.

**1B:** keep organization personal to each player, saved per world/Controller identity. Less network state, but faction members see different organization.

No nested folders or speculative extra gameplay controls are proposed. The owner has requested this scope for discussion, not yet approved the full implementation. Existing module/art restrictions and multiplayer authority remain applicable. Medium reasoning is sufficient for planning; the implementation spans several UI surfaces and should use high reasoning with focused native checks. Fast is appropriate if execution exceeds 25 minutes.

## Preview and acceptance

The conversation preview shows Controller grouping, bottom details, compact cards/wide gutter, the Manage button split and centered module rows, and compact descending LootLab tiers. Example tier contents are illustrative; live saved tuning is not read or changed. Preview controls demonstrate screen navigation, device selection, adding/collapsing/renaming groups, not native gameplay or finished drag behavior.

Before delivery, verify stacking with actual native context menus, all gesture/drop states, disconnect All authorization and partial rejection, reconnect/save persistence, group concurrency if shared, 4/8/4 layout at supported sizes/fonts, stockpile clipping/columns in side and full-page modes, and tier presentation without weight changes. Existing installed 0.2.55.2 remains available; R4C2 content stays deferred behind these corrections. Rendered/connected acceptance is not claimed.

## C327 — implementation approved

Owner selects **1A** and says **Approved for patch**. Shared per-Controller groups and the full C326 corrective scope are authorized. Implement as 0.2.56, preserving server authority, existing links and saved LootLab weights.


## C327 delivery evidence

Implemented in [0.2.56](PATCH_v0.2.56.md). [Validation and owner test](TEST_v0.2.56.md) distinguish native server/browser evidence from pending rendered and connected acceptance. Current modules remain bounded at 16, rendered as 4/8/4; no new Sandbox capacity is invented. Shared edits reject stale revisions; collapse is local. LootLab two-asset publication preserves Worker code and saved settings.
