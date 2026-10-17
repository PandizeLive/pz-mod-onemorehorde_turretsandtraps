# 0.2.53 owner findings — C286, 2026-10-17

## Owner report and current outcome

Owner reports overlapping Turret Manage framing, a name editor blocking window dragging, excessive complexity, a Controller window unlike the accepted preview, and a black screen while using Controller menus. These are failed rendered/runtime findings, not a blanket pass of the other 0.2.53 checks. Installed 0.2.53 remains unchanged. Corrective work takes priority over R4C2 content.

## Evidence and diagnosis

- Capture: `diagnostics/captures/20261017-005841-2703/`; console SHA256 `D8A09ACC2C5979ABB57445568F439AF5D5D56FEC5DB032344B80A12093DF2ECB`. Raw logs remain local. Both installed package manifests were captured.
- Console is 2,689,950 bytes and begins mid-stack; it contains repeated Kahlua stack overflow at frame14663, recurring through native `tostring`, debug-breakpoint UI and mouse-event dispatch. The current DebugLog likewise starts with the recurring failure. Neither retained log establishes the original click/first exception or independently proves the active loaded version; 0.2.53 is the installed candidate, not a recovered startup assertion.
- Confirmed recursive UI-name defect: `ControlPanel.lua` stores an ISTextEntryBox in `panel.name`, then attaches that entry as a child. Native 42.21 `ISUIElement:tostring()` uses `toPathString()`, `toTypeNameString()` stringifies `self.name`, and the child's path walks its parent. KahluaUtil invokes a table's `tostring` method. Formatting this Controller loops parent -> name child -> parent. This is a verified crash-capable defect consistent with the log; the exact original trigger remains unproven.
- Isolated native-Kahlua probe loads the installed ISBaseObject/ISUIElement source. A bounded diagnostic wrapper detects recursion at41 string conversions with the production field arrangement; moving the widget reference to `nameEntry` returns `Controller / Controller.TextEntry` in2 conversions. Probe: local `.local/c286/UINameProbe.java`. No game process was driven and no production code was changed. Java17 cannot directly compile against the Java25 game classes; the completed probe uses reflection and the bundled game JVM.
- Confirmed geometry defect: Modules section ends at `detailsY - 4`, while Status and Installed Modules begin at `detailsY - lineHeight`. Their overlap is `lineHeight - 4` pixels. The naming entry/buttons at y6 cover most of the only permitted drag band (`y < titleHeight`).
- Controller construction uses a fixed plain detail area and a wall of buttons. It does not reproduce C284's Equipment cards, selected-device overview and separated Connections layout. The implementation fell short of the accepted design.
- Related lifecycle issue to include in correction: remote Manage opens stockpile through a temporary helper table, so that call does not retain the child window on the real parent. Inspect duplicate-window prevention and cleanup; this is not established as the black-screen cause.

Earlier test-double bounds checks and zero-client probes did not test native UI stringification, sibling-section overlap or rendered design fidelity. Their pass is not evidence that these screens were correct.

## Proposed corrective scope

1. Fix the recursive field collision and audit nearby native UI field names/callbacks/window lifetimes. Preserve public read/private-faction-public write authority and exact-item remote transactions.
2. Give both windows a permanent unobstructed title/drag bar; keep name editing below it. Keep close reachable at supported heights.
3. Use shared section coordinates, consistent padding and one enclosing border per section. Stop Modules before Status/Installed Modules; avoid borders crossing headers or children.
4. Restore the accepted Controller hierarchy: Equipment/backup/stockpile above a device list and selected-device overview; primary Open Manage action; separate Connections and Access. Show controls relevant to the selected device. Keep the approved small Battery, not the illustrative mockup's Car Battery.
5. Reduce repeated empty-slot instructions; retain module rarity colors, benefit list, equal-width Ammo/Void, Magazine below them, Expansion in Equipment and Power beside Battery. Do not remove functionality or change combat/storage balance.

## One design choice

**1A — Compact single page (recommended):** Equipment, Ammunition, Modules and Installed Modules remain visible. Put detailed combat statistics in an expandable Details section; retain Engagement Range and relevant Lure controls. Fewer borders and repeated labels, without tab switching for routine transfers.

**1B — Two tabs:** Equipment/Ammunition on one tab and Modules/benefits on another. Shorter window, but more switching while configuring a turret.

Both choices include crash correction, a dedicated drag bar and restoration of the approved Controller design. Neither simplification choice is selected by this report. Discussion precedes the corrective implementation under the project's test-findings agreement; no new gameplay version, install, test pass or Workshop publication is claimed.

## Verification required for the correction

Use the actual native UI naming/path methods in the regression, check sibling sections and title hit areas at supported font/screen sizes, and check repeated Controller -> Manage -> stockpile open/close paths. Preserve MP read/write and stale/removed-device guards. Rendered acceptance and connected-client acceptance remain distinct. Do not repeat unrelated prior gameplay tests.
