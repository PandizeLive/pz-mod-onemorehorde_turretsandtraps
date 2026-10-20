# Patch 0.2.57.2 — approved compact management corrections

Owner approval follows C342 selections **1A / 2A / 3A**. C344 implements that correction; the separate C343 module-category discussion remains undecided.

- Native compact window framing
- Balanced Equipment/Ammunition
- Compact 4/4/4/4 module grid
- Inline Details resize protection
- Retired-trigger link cleanup
- Connected-input power tooltip

Both menus use the installed native Small-font title/footer formulas, native title texture and fitted close/resize controls. Manage opens at 760 pixels at the tested 18px Small font, with a 640px minimum; larger fonts raise these values. Older saved broad Manage widths are compacted once; subsequent custom resizing persists. Equipment and Ammunition share the width evenly, and Remove To/Set Aim remain equal.

Details stays below Modules and increases the minimum window height. Main equipment/modules never become a hidden details-only page. If the entire viewport is physically too short at the current font, Details remains closed with an explanation; it does not silently hide the main controls. Module Stats retains its own list scrolling for longer benefit lists, with no outer menu scrolling.

Authoritative retirement disconnects incoming/outgoing links and reconciles target power. Startup removes already-retired links; redeployment does not revive them. Temporarily unloaded placed devices retain their links and public names but cannot supply active power. The power tooltip lists actual incoming devices. This addresses a confirmed retained-link inconsistency; the literal reported “Needs trigger” case is not yet reproduced in a rendered client.

No category reordering, rarity/weight changes, LootLab deployment, merge or Workshop upload. Exact five-second multiplayer native placement remains an open item from 0.2.57.1. See [tests](TEST_v0.2.57.2.md).
