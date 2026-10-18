# 0.2.55.1 verification — C324

## Owner-reported failure

0.2.55 is **not accepted**. Owner reports game freeze/exit, errors and a scrollbar in the screen interior; later suspects one overloaded CPU core. The captured console identifies loaded version 0.2.55 and contains **454** `attempted index: refreshDue of non-table: null` exceptions, all from `ControlGraph.lua:65` through native `UIElement.update`. Its ending records world/GlobalModData saving and `GameThread exited`. No new `hs_err_pid` report was found in the game/user-root locations checked. No CPU profile or core-utilization recording is available.

The local raw console is preserved under `diagnostics/v0.2.55.1/owner-console-0.2.55.txt`; only a sanitized summary/hash is mirrored. This supersedes the earlier automated-pass handoff without rewriting its historical results.

## Corrective evidence

- Installed Build 42.21 stock-JAR-first validation: **21,849 assertions**, 231 compiled Lua/translation files, 298 source / 383 packaged files. Shipped Lua retains the banned-call gate: no `pcall`, `xpcall`, `ipairs` or bare `next`.
- The new regression drives 600 recursive child-widget updates with native dispatch semantics, rather than only invoking Controller refresh helpers. This catches the original method-name collision. No update errors or gameplay/remote-session commands occur.
- Native `UIElement.update` bytecode confirms it retrieves `update` through the widget table and passes that same widget as `self`, including hidden child elements. The corrected `Graph.refreshForPanel` does not occupy that callback name.
- Native `UIElement` construction/update probe reproduces deferred scrollbar anchor drift after explicit geometry changes. Disabling those anchors preserves exact right-edge placement and panel height at widths 400, 270, 540 and 310. UI geometry checks cover all three affected scrollbars, including their containing stencil policy.
- Native UIWorldMap v3 construction/signature checks pass. Adapter tests verify automatic map selection, visited-area settings, single data initialization over 100 draws, and safe map-disabled behavior. The renderer itself is not executed by this probe.
- Existing resize, persistence, exact-stockpile, drag-link permission and 32-by-32 connection tests remain passing. Geometry traces are development render adapters, not live gameplay screenshots.

Native write/read pass in 146.7 / 126.1 seconds with no connected client. Traps-only, Turrets-only and both startup checks pass in 127.1 / 115.5 / 110.4 seconds. Installation evidence is next. Rendered owner acceptance, connected multiplayer acceptance and actual gameplay CPU/frame measurements remain pending.

## Short owner test

1. Restart and confirm **0.2.55.1**. Open the Controller; the in-game map should appear directly.
2. Leave it open for 30 seconds, then select several devices. Check for freezes or a growing error counter.
3. Resize wider/narrower and scroll Connections and Selected Device. Scrollbars should remain inside their sections.
4. Drag a trigger to a turret, open Manage and return to Stockpile. Close/reopen the Controller once.

After this test, inspect the new console for the previous callback exception and any new errors. Connected clients are a separate acceptance check; no connected multiplayer pass is claimed here.
