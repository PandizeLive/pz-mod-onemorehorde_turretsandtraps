# 0.2.53.2 verification and short test

## Automated checks

Full validator passed **20,897** assertions, 203 runtime/translation compilations,282 source and355 package files (133 Traps,222 Turrets). Includes native42.21 translation/serialization/animation/asset/API checks. Final dependency-timing and native container-button/context-menu corrections are included.

UI regressions cover single-page sequencing, restored section bounds, variable-length Details,600px viewport scrolling, fixed title/footer,4/6/6 slots, equal Ammo/Void, nested stencil repaint using the native level/pixel model, pointer capture/release and child-consumed release recovery, contextual Controller spacing and readable list sizing. Native stockpile tests cover the existing inventory panes,500 display surviving native updates, admission above100, total batch budget, full capacity, favorites, proximity, private read/write and unchanged ordinary-container delegation. Prior native UI-name recursion regression remains.

Native write/read pass (147.3s / 142.7s), including 167-item over100 Controller stockpile persistence and exact 5,000-round turret persistence. Traps-only (127.6s), Turrets-only (129.3s) and both (128.9s) startup pass. No players connected to these probes. Installation evidence: pending. No actual rendered-client or connected multiplayer pass claimed.

## Test now — after installing0.2.53.2

1. Restart and confirm**0.2.53.2**. Open Manage: one page, shaded headers, no overlapping sections. Expand/collapse**Details** and scroll to both ends.
2. Drag Manage and Controller by their title bars; release over a button and outside the window. Both must stop immediately. Select Controller, a turret and a plate; labels/actions must stay readable.
3. **Open stockpile**: use the native inventory windows to store/take an item, check the500 limit, and drag a module from stockpile into remote Manage. Closing Controller should leave native inventory usable.
4. Check**Load Order**,**Reload**, one module tooltip and range/power controls; close/reopen both windows. Report any overlap, stuck drag or black screen.

Capture/review console.txt after the owner report. Connected MP is still a later two-client acceptance check; damage and balance tests are not repeated here.
