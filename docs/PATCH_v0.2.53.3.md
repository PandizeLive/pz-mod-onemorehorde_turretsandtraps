# 0.2.53.3 — compact management and stockpile correction

Approved C291 correction to0.2.53.2.

- Synchronized panel scrolling
- Side-by-side Equipment and Ammunition
- Adjacent Reload and Load Order
- Accessible Details and Installed Modules
- Automatic turret-name saving
- Gray automatic-name placeholder
- Compact name and weight row
- Defense-supply stockpile filtering
- White-cube Controller

## Audit and implementation

Installed42.21 `ISUIElement:setScrollChildren` returns without doing anything until `javaObject` exists. Both scroll bodies called it before `addChild` instantiated the native object. Drawn headers used the scroll offset, while child controls stayed stationary. They now instantiate first. The test harness executes the actual installed Lua method and honors native initialization order; a real Java UIElement parent/child probe verifies absolute coordinates change only with child scrolling enabled. The previous unconstrained test double incorrectly made the early call work. This is the confirmed cause, not a claim of rendered-client acceptance.

Manage retains the title drag band and shaded sections. Equipment/Ammunition share two aligned slot rows; equal-width physical/Void reserves sit above Magazine. Reload/Load Order share the ammunition header; measured button widths move to a second header line if font/viewport space requires it. Details is in the Modules header, opening measured stat rows above Installed Modules. All content controls scroll with their section backgrounds; range/fire controls stay fixed. The title is Turret Management Menu. Weight shares the name row; remote destination remains a separate control. The window is modestly wider to accommodate the requested columns.

One native text-entry subclass handles both turret and input-device naming. Enter or blur sends one validated server action only when the name changes. Blank text uses native gray placeholder text; no Save/Auto buttons remain. Controller names are no longer editable or shown as custom names. Placeholder/head identity and editability are cached; unchanged UI refreshes do not scan ammunition or allocate a new native editable-border style.

Stockpile admission is one shared predicate used by native insertion, the server inventory action and remote turret-to-stockpile transfers. Allows T&T trap/turret/module/ammo items, supported turret ammunition and firearm heads, native Ammo-category supplies (including boxes/magazines), car batteries and the Controller backup battery. It reuses the live turret classifier for modded spears/compatible guns and requires no Turrets dependency in Traps-only mode. Generic clothing, food, materials and bags are rejected. Previously stored unrelated items remain removable.500-weight, exact-item, owner/faction/public, favorite and proximity rules remain authoritative; no automatic deletion or conversion.

Both independent packages register their own four Controller sprite identities over the same existing white-cube PNG. Native SpriteConfig requires distinct identities per placement direction; the initial duplicate-identity attempt was rejected by startup and corrected before delivery. Existing placed radio placeholders convert on authoritative binding while retaining identity, position, links, health and contents. Conversion also rebuilds the native SpriteConfig component when its facing metadata still points to the radio, using the existing barrier repair pattern. A native fixture verifies both the registered cube sprite and its matching valid facing metadata. This is a presentation change: collision and gameplay are unchanged. Inventory uses the existing cube icon as well.

No new tick handler, periodic world scan, Java runtime dependency, exception suppression or inventory reconstruction. Source validation retains the no-pcall/xpcall gate. Layout refresh remains state-triggered; Manage data refresh remains200ms and Controller scanning retains its existing bounded work budget.

## Console findings and limits

Captured owner console at `diagnostics/captures/20261017-035730-5738`: SP0.2.53.2 is confirmed. No recurring Controller UI stack overflow was found. One `ISTimedActionQueue:tick: bugged action OMHTTControlAction, cleared queue` warning occurs after a long paused interval and Manage closure. Installed native code logs this when the Lua queue points to an action absent from the character's native queue; the log does not identify the command or prove its cause. Retain this as an observation to recheck, not a claimed crash fix. Map/model warnings outside T&T also occur.

[Checks and short owner test](TEST_v0.2.53.3.md). Rendered client and connected multiplayer acceptance remain pending. No Workshop publication or gameplay rebalance.
