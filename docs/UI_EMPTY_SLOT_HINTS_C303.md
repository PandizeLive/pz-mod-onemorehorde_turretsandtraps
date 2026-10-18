# Empty-slot item hints — C303 / C304

**C305 update:** Owner subsequently says "Patch", superseding the future-art timing below. Implement now using existing normal icons; final art remains owner-sourced. See [0.2.53.9](PATCH_v0.2.53.9.md) for delivery and verification. Earlier discussion below is historical provenance.

2026-10-17. Owner asks to discuss extending silhouettes to Head, Ammo, Magazine, Expansion and other empty slots once icons/art are supplied. C303 opened the future UI proposal; C304 below selects its approach for the future icon/art pass. Based on `codex/performance-barbed-audit` at `fa54716b9ed2a7734bc52307d1d5efc48531d2d6`; fetched origin/dev and reviewed open PR1. Installed0.2.53.8 remains unchanged and its acceptance remains pending.

## Selected approach and alternative

**1A — Context-aware hints (selected in C304):** reuse normal supplied/native item textures and draw them black, preserving transparency. Match ammunition and removable magazines to the installed head. Use existing suitable category/item icons where multiple items fit, retaining labels; no extra silhouette artwork is required.

**1B — Fixed category hints (not selected):** one unchanging symbol per slot. Simpler visual consistency, but offers less guidance about which ammunition or magazine fits. Still preserve all not-applicable/locked states below; neither choice changes admission rules.

C304 approves1A if normal icons can be blacked out. Installed native UI source confirms that tinting path. Final ordinary icons remain owner-sourced; silhouettes are a rendering treatment, not new assets. Schedule with the future icon/art pass, retaining the original timing. No immediate source/package change, new art generation, animation or public release is requested.

| Slot | Recommended empty-state hint |
| --- | --- |
| Head | Existing suitable head/mount icon with a short compatible-head/firearm tooltip. A Potato Launcher picture must not suggest that only that head fits. Keep the label if no supplied icon represents that category clearly; do not require separate silhouette artwork. |
| Physical Ammo | A representative accepted ammunition icon for the installed head/platform: potato, spear, scrap, bomb or the correct firearm calibre. Keep the accepted family/type label; a representative wooden spear must not imply modded compatible spears are excluded. No head: install-head prompt. Rotary: not needed. |
| Magazine | Matching removable magazine only where insertion is supported. Built-in feeds remain a built-in status with their existing next-shot/count display; rotary heads need no magazine. |
| Expansion | Normal expansion-kit icon blacked out, with the category label making clear that no particular tier is required. |
| Module | A suitable normal module icon blacked out for available empty slots; locked slots remain visibly locked. No rare/specific-module recommendation implied. |
| Battery | Correct battery family: native car-battery hint for Turret and ordinary Battery hint for Controller. Controller is already implemented in0.2.53.8. |
| Void | Preserve its distinction as ammunition storage, not a module-installation slot. Missing Void means the module is required in Modules; never imply it can be installed by dropping it into the Ammo/Void display. Active empty storage may share the current head's ammunition hint. |

## Presentation and implementation constraints

Use the existing neutral grey theme and slot labels. Keep ghosts subordinate to text and clearly different from an installed item; replace with the real item/count once occupied. Preserve next-load/next-shot summaries, quantity bars, disabled/read-only styling and capacity feedback. No new panel, slot or animation is needed.

C302's Controller `ControlBatterySlot.lua` demonstrates the native script-icon rendering path without creating an InventoryItem. `TurretSlot.lua` shares the other slot drawing, but Ammo/Magazine/Void currently use summary branches; adding a ghost only to the ordinary empty-item branch would miss those slots. `TurretManage.lua` already distinguishes rotary, built-in and removable magazines and supplies the current head/ammo state. Reuse those classifications rather than inventing another compatibility detector.

Cache icon resolution with the existing head/slot refresh. Draw the cached icon while visible; do not create dummy items, scan the inventory every frame or add network/state messages. This presentation-only proposal should not change persistence, inventory admission, capacity or combat. Performance impact is expected to be small; actual rendering and compatibility still need verification after implementation.

Acceptance later: empty/filled/locked/unneeded states, head swaps, missing/modded art fallback, correct calibre/magazine hints, narrow/large-font layouts, preserved summaries, and unchanged server-authorized drag/drop. No new game test or pass is claimed now. Schedule with the owner-provided icon/art pass; this does not replace R4C2 as the next content checkpoint.

## C304 — normal icons blacked out, 2026-10-17

Owner: "1A if it can be done by taking normal icons and blacking them out." This selects context-aware hints with the condition that ordinary icons are reused. Local implementation feasibility is confirmed from installed42.21 UI source:

- `media/lua/client/ISUI/ISUIElement.lua:1065` exposes `drawTextureScaledAspect(texture, x, y, w, h, a, r, g, b)` and forwards RGB/alpha to the native texture renderer. RGB0/0/0 draws the existing texture black; its transparency supplies the silhouette.
- `media/lua/client/ISUI/ISMoveableInfoWindow.lua:144–147` draws existing moveable textures with RGB0/0/0 for black outlines. This is native usage of the same tint mechanism.
- `media/lua/client/ISUI/ISInventoryItem.lua:25` resolves ordinary script-item textures through `getNormalTexture()` and optional texture icons. The current icon helper accepts opacity, not RGB; the future black silhouette must use the existing texture draw path rather than assuming alpha alone makes the icon black.

Use cached normal textures with black drawing parameters. Do not edit the original texture, create replacement inventory items, generate PNG variants or perform per-frame pixel processing. The ordinary installed item keeps its full-color icon. Texture packs/modded textures can use the same path when available; missing icons retain labels.

Contrast needs a rendered check against the dark slot surfaces. Preserve the selected black shape; if needed, use a restrained lighter grey backing within the existing design. Do not silently switch the requested silhouette to a colored faded icon. This is an implementation/readability consideration, not a new owner decision blocking the selected approach.

Planning documentation only in this turn. No new source build, game test, release claim or acceptance result. Installed0.2.53.8 and R4C2 sequencing remain unchanged.
