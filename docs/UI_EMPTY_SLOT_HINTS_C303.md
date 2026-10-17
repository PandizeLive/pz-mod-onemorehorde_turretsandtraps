# Empty-slot item hints — C303

2026-10-17. Owner asks to discuss extending silhouettes to Head, Ammo, Magazine, Expansion and other empty slots once icons/art are supplied. This is a future UI proposal, not approval to implement now. Based on `codex/performance-barbed-audit` at `fa54716b9ed2a7734bc52307d1d5efc48531d2d6`; fetched origin/dev and reviewed open PR1. Installed0.2.53.8 remains unchanged and its acceptance remains pending.

## Recommendation and choice

**1A — Context-aware hints (recommended):** reuse supplied/native item icons at low opacity; match ammunition and removable magazines to the installed head. Use approved category art where multiple unrelated items fit.

**1B — Fixed category hints:** one unchanging symbol per slot. Simpler visual consistency, but offers less guidance about which ammunition or magazine fits. Still preserve all not-applicable/locked states below; neither choice changes admission rules.

Neither option is selected yet. Final icons remain owner-sourced. No new artwork, generated silhouettes, animation, public release or gameplay changes are authorized by this discussion.

| Slot | Recommended empty-state hint |
| --- | --- |
| Head | Approved head/mount category icon with a short compatible-head/firearm tooltip. A Potato Launcher picture must not suggest that only that head fits. Keep the label if suitable category art is unavailable. |
| Physical Ammo | A representative accepted ammunition icon for the installed head/platform: potato, spear, scrap, bomb or the correct firearm calibre. Keep the accepted family/type label; a representative wooden spear must not imply modded compatible spears are excluded. No head: install-head prompt. Rotary: not needed. |
| Magazine | Matching removable magazine only where insertion is supported. Built-in feeds remain a built-in status with their existing next-shot/count display; rotary heads need no magazine. |
| Expansion | Approved generic expansion-kit icon that does not imply a particular tier is required. |
| Module | Approved generic module icon for available empty slots; locked slots remain visibly locked. No rare/specific-module recommendation implied. |
| Battery | Correct battery family: native car-battery hint for Turret and ordinary Battery hint for Controller. Controller is already implemented in0.2.53.8. |
| Void | Preserve its distinction as ammunition storage, not a module-installation slot. Missing Void means the module is required in Modules; never imply it can be installed by dropping it into the Ammo/Void display. Active empty storage may share the current head's ammunition hint. |

## Presentation and implementation constraints

Use the existing neutral grey theme and slot labels. Keep ghosts subordinate to text and clearly different from an installed item; replace with the real item/count once occupied. Preserve next-load/next-shot summaries, quantity bars, disabled/read-only styling and capacity feedback. No new panel, slot or animation is needed.

C302's Controller `ControlBatterySlot.lua` demonstrates the native script-icon rendering path without creating an InventoryItem. `TurretSlot.lua` shares the other slot drawing, but Ammo/Magazine/Void currently use summary branches; adding a ghost only to the ordinary empty-item branch would miss those slots. `TurretManage.lua` already distinguishes rotary, built-in and removable magazines and supplies the current head/ammo state. Reuse those classifications rather than inventing another compatibility detector.

Cache icon resolution with the existing head/slot refresh. Draw the cached icon while visible; do not create dummy items, scan the inventory every frame or add network/state messages. This presentation-only proposal should not change persistence, inventory admission, capacity or combat. Performance impact is expected to be small; actual rendering and compatibility still need verification after implementation.

Acceptance later: empty/filled/locked/unneeded states, head swaps, missing/modded art fallback, correct calibre/magazine hints, narrow/large-font layouts, preserved summaries, and unchanged server-authorized drag/drop. No new game test or pass is claimed now. Schedule with the owner-provided icon/art pass; this does not replace R4C2 as the next content checkpoint.
