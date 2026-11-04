# 0.2.53.1 — Manage and Controller cleanup

Owner approval: 2026-10-17, “Approved”, following C288's selected two-tab layout and clean/non-overwhelming acceptance criteria. This is C289; C286–C288 are the governing corrective scope.

## Changes

- Two-tab Turret Manage: Equipment & Ammo / Modules.
- Dedicated title/drag bars and expandable Details.
- Consistent spacing, restrained framing and clear empty module slots.
- Controller Equipment/stockpile header, device list and contextual device actions.
- Controller UI-name recursion correction and owned stockpile window cleanup.

Equipment retains Head/Expansion/Battery/Power, equal-width Ammo/Void, shared Load Order and Magazine/Reload below. Modules retain 4/6/6 slots, rarity shading, left-name/right-benefit Installed Modules and hover explanations. Targeting, relevant Lure/Lobber controls, status and action feedback remain in the fixed footer. The content scrolls independently on shorter displays; the title and tabs remain reachable. Old single-page spacing calculations were removed.

Controller name editing now uses `nameEntry`, leaving the native `name` field available for UI identification. Installed 42.21 UI path-formatting methods run against the corrected widget tree in regression checks. This fixes the independently reproduced recursion; the original first error is absent from the captured owner log, so rendered black-screen recovery still requires the short owner retest. Controller panels replace previous instances per player; stockpile panels belong to their Controller or remote Manage and close on replacement, parent close or lost reach. Context-specific actions are hidden when irrelevant.

## Authority and performance

Client UI only, apart from the version marker/translations. No combat, damage, capacity, signals, ownership rules, save schema or transaction endpoints change. Existing server checks and read-only inspection remain in force. Manage refresh stays at 200 ms; layout recomputes only when tab, disclosure, optional controls or screen height change. Controller discovery remains capped at 64 tiles / two milliseconds per callback with five-second rescans; selected-device ammo and stockpile weight reuse the five-second renewal, with no per-frame inventory scan. No shipped pcall/xpcall/ipairs/next calls were introduced.

## Verification and remaining work

See [verification and four-step test](TEST_v0.2.53.1.md). Native UI formatter regression, production Lua callbacks with UI doubles and native package/persistence checks are separate evidence. Rendered drag/clip/input behavior and connected dedicated/listen multiplayer are not certified by those checks. R4C2 content remains next after this corrective build; unrelated historical tests are not reopened. Workshop publication is not authorized; pending notes remain cumulative.
