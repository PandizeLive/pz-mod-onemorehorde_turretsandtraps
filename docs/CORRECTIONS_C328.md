# C328 — 0.2.56 owner test audit and next corrective scope

Owner reports module ordering/locked-slot text, Add Group alignment, native-window styling, map disconnection failure and interrupted trigger actions. This is the requested audit and proposal; no new gameplay implementation approval is inferred from the test report. Installed version remains 0.2.56. Current console confirms SP, both packages, game42.21. [Sanitized evidence](../diagnostics/v0.2.56/c328-owner-audit.json).

## Confirmed findings

1. **Context-menu exception:** 16 `bind` exception records. `TurretMenu.lua:89` still calls `Range.bind(shot, {object})` after deleting the Fire option; `TurretRange.lua:54` indexes nil. Remove the obsolete call and add a real menu-fill regression. This was introduced by our prior patch and missed by its tests.
2. **Module geometry versus item order:** image1 already has centered4/8/4. `TurretModuleSwap.modules` follows saved item-ID slot assignments, then inventory order; this is intentionally movable rather than a role/type ordering. Three layout paths still contain conflicting six/eight-column arithmetic, and paging still advances by six. Consolidate into one geometry function with four columns and four rows for the current 16-slot display, with no hidden capacity increase (owner correction C329 below).
3. **Duplicate Unavailable:** Manage sets locked slot.label; Slot draws it at the top and again as the empty-item name. Use one centered locked-state label, suppress icon/plus and add “Add Expansion Kits to gain more slots.” once below the section title or above the grid when slots remain locked.
4. **Add Group:** custom painted rectangle/text instead of native ISButton. The actual drawn94-pixel rectangle and click hitbox spanning the header's right110pixels differ; fixed offsets produce uneven text/inset. Replace with a measured native button on a dedicated action row, separate from header and column labels.
5. **Window styling:** custom ISPanel shells use near-opaque backgrounds(.96/.97); native ISCollapsableWindow uses black/.8, grey border/.4 and native close/pin textures. Native window controls should wrap the existing body, retain OMH red/white titles and grey sections, and keep section borders less opaque so opacity does not compound. Preserve native Stockpile internals, controller authority and proven explicit resize clamping. Check font scales, minimum widths, Details/Load Order/Stockpile pages and title-button bounds. The existing custom resize widget does exist; the issue includes its appearance/placement and missing native chrome, not absence of resizing.
6. **Map disconnect:** Map.onRightMouseUp calls Graph.menu, but the native child has no explicit right-click forwarding; setConsumeMouseEvents(false) is not proof of right-button routing. The world-context exception is a separate confirmed defect and may be exposed by click-through. Reproduce with the installed native child; route/consume down/up correctly, share connect/disconnect logic between map/list and ensure popup top-order. Retain individual/All and read-only protection. Do not claim the full cause proven solely by test doubles or historical Java.
7. **Trigger completion:** ControlWorld.pulse uses1ms for non-rotary pulses, special-cases facingPending, but does not retain a reload/normal aiming completion request. receiver applies OFF as soon as input/hold ends. User wants button/plate action completion, so replace guessed hold duration with a bounded server-owned active cycle: turn/reload as needed, discharge once, then OFF if no input remains. Held plate continues normal cycles; release allows only the already-started one to finish. An actual empty supply, depleted power, missing head/module, destroyed/unloaded receiver or lost permission/consent cancels safely. Recommend manual OFF remain immediate. No catch-up queue, free power, indefinite no-target search or second automatic shot from the same pulse. Rotary completes the current swing/pass; launched grenades continue their existing independent fuse without holding the turret powered until detonation.

## Original Decision 1 — superseded by C329

**1A recommended:** automatic stable role order: Firing, Detection,360,Filter, then utility modules, then damage modules; duplicate types adjacent, stable item-ID tie-break. The same ordered exact-item view must be used for swaps and tooltips. Replacing modules still works, but manual visual rearrangement is superseded.

**1B:** preserve player-assigned positions; enforce only the4/8/4 geometry, shared sizing and centered labels. No automatic type sorting.

## Native lock/pin semantics

Installed ISBuildWindow.toggleLock/ update show its padlock controls movement-based auto-close for unbound building browsing. Its object-bound range check remains. ISCollapsableWindow pin keeps the body open versus auto-collapse. Recommend native pin/collapse and close/resize controls plus an explicitly labelled **Lock Position** control if the owner wants drag/resize locking; never use either to bypass reach/access. Confirm **2A: Lock Position (recommended)** or **2B: native-style keep-open lock**, with writes still gated when out of reach. Keep pin/collapse separate.

## Verification required for the patch

Test native world context-menu construction, right-button dispatch through the native map child, a single rendered locked label, Add Group actual button bounds/hitbox, no header/action overlap at all supported sizes/fonts, one module-grid layout/paging rule, cancellation cleanup, pending versus confirmed feedback and Stockpile confinement. Exercise button during turning/reload/cooldown; plate release during those phases; empty ammo/power/manual-off/unload; rapid presses without an unbounded backlog; SP/listen/dedicated authority and synchronized power/shot state. No pcall/xpcall workaround. Native tests are necessary but rendered and connected acceptance remain distinct.

Audit only: no version bump, install, Workshop upload or change to hosted LootLab. C108/C119 require the recorded findings to be committed and mirrored. Next content remains R4C2 after corrections.

## C329 — owner selections (2026-10-19)

The owner replaces the 4/8/4 layout with **4/4/4/4** and selects **2B**, native-style keep-open locking. Use four aligned, centered rows with equal slot sizing; resize the containing section/window to fit without clipping. Preserve saved player-assigned module positions and exact-item swaps: the owner corrected geometry, not type ordering, so automatic role sorting is not authorized. This supersedes the original grid proposal and leaves no sorting decision pending.

Use the native-style keep-open lock with separate pin/collapse semantics and clear tooltips. Keeping a menu open never grants remote reach or bypasses ownership, access or server validation. Position locking is not selected.

The remaining C328 correction scope is retained. These are design selections; no new implementation, package, version or installation occurred in this planning turn. Ready for patch approval; no further design decisions required.

## C330 — implementation approved (2026-10-19)

Owner explicitly says "Approved" after C329. Implement the complete retained correction scope with 4/4/4/4 geometry and native keep-open locking. Version 0.2.56.1 is the corrective candidate; automated, native, installed and owner acceptance are tracked separately in its patch/test records. No new approval gate is required for implementation, verification, local installation or the standing development mirror.
