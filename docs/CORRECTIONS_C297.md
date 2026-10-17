# C297 — attached Stockpile, explicit battery and transfer corrections

2026-10-17. Read-only audit and requested preview of owner findings on **0.2.53.5**. No production Lua, packaged files, installation or version change. Corrective implementation follows review of this proposal; R4C2 remains after corrections.

## Owner report and clarification

- Controller power has no discoverable battery slot; owner requests a Manage-style slot.
- Reload, Load Order and + Details intrude into section headers. Owner requests clearer contrast and mockups.
- Turret power appears black; owner requires red/green off/on feedback.
- Controller Stockpile should extend from the right of the Controller menu. The owner explicitly clarifies this means a **dedicated connected inventory component**, not repositioning or borrowing the player's HUD inventory/loot windows. This supersedes the assistant's initial temporary-docking suggestion.
- Dragging installed items should work into valid destinations, including Stockpile. Dragging a Ballista Head from Stockpile into Manage incorrectly reports that items must come from player inventory.
- Owner says most appears to work. This is partial acceptance; do not infer all previous rendered or connected-MP checks passed.

## Confirmed causes and native feasibility

| Finding | Evidence | Recommended correction |
| --- | --- | --- |
| Black power button | `TurretManage.refresh` assigns the color, then `ControlManage.refresh` calls `ISButton:setEnable`. Installed 42.21 `ISButton.setEnable` restores its originally cached black `backgroundColorEnabled`. | Keep the enabled-state color and actual on/off state in one refresh path. Green/On and red/Off; permissions separately disable interaction without changing the represented power state. |
| Stockpile head rejected in nearby Manage | `ControlPanel` Open Manage callback prioritizes `A.near` and opens without Controller context. `Panel.transfer` selects local `TurretTransfers.queue`; its incoming check requires `source:isInCharacterInventory`. Console records three `TransferCarried` head rejections. | Preserve a valid Controller transfer context for nearby and remote devices. Validate exact stockpile/source, permissions, assignment/power when remotely operating, and reach at completion. Keep ordinary nearby manual service available without authorizing remote stockpile access. |
| Manage-to-Stockpile drop rejected | `ControlTransferAction.canStore` requires the source to be in the character inventory. Installed Manage items do not satisfy that. | Route installed-item deposits through the turret-aware authoritative action, preserving `T.canRemove`, magazine/servicing rules and the requested destination. Do not simply delete the source checks. |
| Header crowding | `TurretManageLayout.create` places Reload/Load Order inside the header using `4 + headerHeight - button.height - 3`, starting 3 pixels above a 26-pixel header when button height is 26. Details also shares the header. | Title-only header bars; padded action rows beneath their content. Retain Equipment/Ammunition side by side and equal Ammo/Void widths. |
| Controller battery hidden in Stockpile | `ControlWorld.power` already selects a charged ordinary `Base.Battery` from its exact Stockpile container, caches its identity and drains it over 48 in-game hours when electricity is unavailable. | Expose that existing active battery through a slot with icon, charge meter, drop and removal. Keep the same item and storage accounting; no duplicate battery or new battery type/balance rule. |
| Attached native inventory | Installed `ISInventoryPage.createChildren` constructs `ISInventoryPane`; the pane provides rows, stacking, sorting, selection, item tooltips, context menus and drag/drop. `ISInventoryPane.onMouseUp` accepts item payloads from another focus. However, several shortcuts and selection/drag helpers explicitly reference `getPlayerInventory/getPlayerLoot`. | A Controller-owned native inventory component with a small scoped adapter is feasible in source. Do not reparent the player's existing HUD pages, replace global player inventory references, duplicate storage, or rewrite the item list. Native in-game lifecycle and MP proof are still required. |

Native evidence is the installed game at `C:/Program Files (x86)/Steam/steamapps/common/ProjectZomboid/media/lua/client/ISUI/ISInventoryPage.lua`, `ISInventoryPane.lua` and `ISButton.lua`. `ISOpenContainerTimedAction` contains an additional page-instance pattern, but its older global-player assumptions are not treated as proof that it can be copied unchanged.

## Proposed layout and behavior

- **Manage:** retained draggable title and compact rename/weight row; neutral charcoal sections, lighter uninterrupted title strips, subtle borders and consistent padding. Reload + Load Order sit below Magazine. Details sits below the module grid and expands the existing Status/Module Stats area. Preserve the in-menu Load Order page and constrained-screen fallback.
- **Controller:** one title/drag bar spans Controller controls and the attached Stockpile wing. Existing Devices, Access and Connections stay on the left; the exact Stockpile inventory is on the right. Its native row list can scroll independently. The player's ordinary HUD stays untouched. On constrained game resolutions, fit/reflow the attached wing; do not add whole-Manage scrolling or put controls offscreen. The phone preview stacks the wing for readability; this is not a claim of mobile PZ support.
- **Battery:** display ordinary Battery, active charge and electricity/battery status. An empty slot shows the accepted battery and drop affordance. Dragging a spare battery from Stockpile selects that exact item rather than copying it. A removed battery remains the same charged item. Retain current spare-selection behavior and authoritative selection on insertion.
- **Transfers:** both directions use the same exact-item routes in SP and MP; items can move to legal player bags, Stockpile and other supported destinations without a mandatory intermediate carry step. Preserve server authority, bounded ammo batches, callbacks, capacity, favorite/removal restrictions, read-only access, current remote leases and defense-only Stockpile admission. Unsupported destinations must explain the restriction instead of silently falling back to player inventory. Withdraw Void's module, not synthetic ammo-count display objects.
- **Performance:** native inventory dirty/update behavior; no duplicate inventory cache or full stockpile scan per render. Reuse existing bounded power/item reconciliation and batch limits. Layout changes happen on size/font/state changes. Release attached-pane tooltips/drag focus when closing, losing reach, losing permission or destroying the Controller.

## Preview and audit evidence

- [Manage image](mockups/c297/manage.jpg) and [Controller image](mockups/c297/controller.jpg). [Editable preview fragment](mockups/c297/connected-stockpile-preview.html). These are design previews with sample values and simple functional placeholders, not in-game screenshots or final art.
- Browser verified at 1024-pixel desktop width and 390/320-pixel phone widths: no detected overflowing child content. Power toggles green/On and red/Off; Details expands to show Module Stats. No browser errors/warnings observed. Images visually reviewed; browser crop capture returned blank images, so retained verified full-page images instead.
- Console file reviewed: `C:/Users/bandi/Zomboid/console.txt`, 266003 bytes, modified 2026-10-17 16:47:46 local. It confirms `version=0.2.53.5 side=sp`; head-transfer rejections at frames 8636, 8862 and 9829. No T&T Lua exception/stack overflow found in this session. Existing world-room metadata errors and an imported skeleton warning remain separate and do not explain these UI defects.
- No new runtime validator pass is claimed: gameplay is unchanged. Next implementation verification must cover actual native-pane lifecycle, full drag/drop in both directions, early pointer release, stockpile-full and removal-blocked cases, local/remote/expired access, and connected server authority. Existing 0.2.53.5 connected acceptance stays pending.

## Status

Owner requirements and correction are recorded; proposed layout/native-component integration is presented for review. No new gameplay build or test request this turn. GitHub development mirror follows C108/C119 on the existing branch/draft PR, with no merge or Workshop publication.

## C298 — One More Horde title branding (2026-10-17)

Owner likes the proposed layout and requests the exact titles **One More Horde - Turret Management Menu** and **One More Horde - Controller Menu**, with **One More Horde red** and the separator/menu name **white**. Owner says approval can follow confirmation; this is not yet implementation approval for the corrective patch.

Confirmed feasible without changing the draggable title-bar behavior. Reuse the existing Horde Night brand-title RGB **0.85, 0.25, 0.25** (approximately `#D94040`), verified read-only in sibling `OMH_ScoreboardUI.lua` at the `IGUI_OMH_Title` draw call. The white suffix uses RGB 1, 1, 1. Render as measured text segments in the title bar rather than another input/control; retain the right-hand close button and account for font scaling/narrow layouts. No sibling changes or new gameplay are authorized by this branding request.

The editable preview now contains both branded titles. The C297 image snapshots above predate this title-only addition and remain evidence of the original reviewed layout. Preview/source structure checked; no new engine test or acceptance claim. Include the branding in the C297 corrective scope when approved. Installed 0.2.53.5 remains unchanged.
