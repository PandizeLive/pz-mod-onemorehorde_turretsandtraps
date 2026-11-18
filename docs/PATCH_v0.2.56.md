# 0.2.56 — Controller organization and UI feedback

- Shared Controller groups and device ordering
- Connection feedback and foreground disconnect menus
- Distinct map markers and bottom-anchored details
- Centered module rows and Manage Set Aim
- Stockpile containment at narrow widths
- Compact Mythic-first LootLab tiers

Drag device cards to reorder within their column or move them between named groups. Drag group headers to reorder; click to collapse; right-click to rename or delete. Deleting a group moves members to Ungrouped without disconnecting anything. Groups and ordering are shared per Controller and saved by stable device IDs. Collapse state is local to the open menu. Port clicks and map drags connect; row drags no longer connect.

Right-click map devices or connection cards/ports for individual disconnects or All. All applies only to that device, runs checked actions sequentially and reports partial failure. Requests show pending separately from confirmed changes; stale group revisions cannot overwrite another operator's edit. Native UI sounds are local and do not attract zombies. Rows retain head subtitles, condition and ammunition; circles identify triggers, rectangles defenses and a diamond the Controller.

Selected Device stays at the bottom; extra height expands the map. Stockpile uses its native inventory with clipped columns and an earlier full-width fallback below 1160 pixels. Manage uses centered 4/8/4 module rows at the current 16-slot maximum. Set Aim sits beside the removal destination below the battery, works locally without Controller power and retains Controller authorization remotely. The world context menu no longer offers Fire or the blocking parent summary tooltip.

LootLab displays Mythic through Abundant, then Unassigned, with smaller lane/header spacing and unchanged module-card height. Only tier-list.js and style.css are published; Worker code, numeric rarity indices and saved tuning remain unchanged.

Existing combat, signals, item capacities and ownership rules are retained. Group copying runs on edits/publication; layout refreshes are cached at 500 ms, inventory statistics remain budgeted and no new world scanner is added. No pcall/xpcall is introduced. See [verification and owner test](TEST_v0.2.56.md). The main-menu slowdown and rendered/connected acceptance are separate unresolved checks.
