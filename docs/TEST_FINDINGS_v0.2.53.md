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

## C287 — both Manage designs previewed, 2026-10-17

Owner requests seeing both options, without selecting either or approving implementation. Created `turret-manage-cleanup.html` in the thread visualization directory (`C:/Users/bandi/.codex/visualizations/2026/10/06/01a11283-2701-7630-a9bf-aac054c7bf3c`). The comparison contains Compact page (1A) and Two tabs (1B), with working equipment/module tabs, Details disclosure, local name/power/range/loop controls and a title-bar drag demonstration. Item transfers/fire are labeled preview-only; no gameplay action is performed. Sample values match the owner's Scrapshot screenshot; no balance change is proposed.

Both preserve Equipment expansion/battery/power, shared Load Order, equal Ammo/Void panels, Magazine below, 4/6/6 desktop module slots, rarity colors and left-name/right-benefit alignment. Small-screen preview reflows the module grid for readability, not as a selected PZ layout change. Compact remains the recommended no-tab workflow; the tabbed alternative is materially shorter. The dedicated drag band is separate from name editing in both.

Browser checks verified the Details disclosure and both Equipment/Modules tab states, with no captured JavaScript error. Narrow preview at360 viewport width had no child extending beyond the product window; the final spacing pass reduced the compact desktop window to about915px high at640px width. This is a browser design preview, not native PZ rendering, mobile-host certification or multiplayer verification. C286 crash/layout corrections remain pending; installed0.2.53 is unchanged. No Controller design re-selection is requested.

## C288 — two-tab Manage selected; update recap, 2026-10-17

Owner selects **1B** and requests a recap. The corrective design is now settled on two tabs: **Equipment & Ammo**, and **Modules** with the Installed Modules benefit list. Retain the separate title/drag bar, name editing below it, expandable Details and shared targeting/Lure controls shown in the preview. The 1A recommendation is superseded by this selection.

Planned update: Controller crash correction; two-tab Turret Manage; dedicated window drag bars; consistent panel spacing/backgrounds; expandable combat details; Controller layout aligned with the approved preview; child-window lifecycle cleanup. Preserve equipment/ammo grouping, rarity colors, remote multiplayer permissions and exact-item transactions. No gameplay or balance additions are inferred.

This turn records the selection and requested recap, not an implementation, installed build or successful crash retest. C286 corrections remain the next work before R4C2 content; installed0.2.53 remains unchanged.

### C288 follow-up — clean, approachable presentation

Owner: "Make sure it's clean and not overwhelming." This refines the selected1B design; it does not add features or reopen the layout choice. Acceptance criteria for implementation:

- Keep the two tabs and a stable header/footer; changing tabs must not make common controls jump around.
- Use consistent alignment, padding and section backgrounds. Avoid nested framing, overlapping headers, clipped labels and decorative borders around every row.
- Keep primary actions obvious. Put detailed combat statistics behind Details, and longer explanations in tooltips. Keep essential state/errors visible and show only device/module-relevant optional controls.
- Use restrained rarity color on modules; keep other labels neutral. Replace repetitive slot numbers/Drop here instructions with one concise hint while keeping empty targets clear.
- Preserve all existing management functions, remote permissions and item accounting. Simplifying presentation must not silently remove controls or weaken access rules.
- Verify actual native UI behavior and compare the result with the selected preview, including normal/small supported screen sizes, font sizes, tab switching, dragging and repeated open/close. A browser preview or rectangle-only test does not establish native visual acceptance.

This requirement is recorded for the corrective patch. No additional owner decision is needed for this presentation refinement; implementation and rendered acceptance remain pending.
