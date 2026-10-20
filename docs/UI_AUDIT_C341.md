# C341 — owner test and UI decisions (2026-10-19)

Discussion only. Installed gameplay remains 0.2.57.1. The owner reports oversized window chrome, an apparently unconnected turret requesting a trigger, excessive blank module margins and equipment/modules disappearing when Details is open and the window is shortened. Owner explicitly asks for options/confirmation before the next patch. C340's direct implementation did not expose the layout choices adequately; this discussion does not authorize another gameplay patch.

## Evidence

- Current console identifies client/server/packages 0.2.57.1, game 42.21, viewport 2560 by 1369. No OMHTT exception trace was identified for these reports. The reported wording "Needs trigger" is not a literal in packaged English translations; its exact UI source/session link is not established from the log.
- Installed vanilla `ISUI/Building/ISBuildWindow.lua` derives from `ISCollapsableWindow`. The latter's `titleBarHeight()` is `max(16, titleFontHgt + 1)`; default title font is Small. Its close button follows this bar height and `resizeWidgetHeight()` uses half of Small font height plus six, then two pixels. OMHTT's Manage and Controller instead choose Medium font height plus 16, a close icon up to 24 pixels, and an 18-pixel footer. This is a concrete sizing mismatch. Font settings change measured glyph height; they do not require our extra padding. UI FPS/offscreen rendering are not terms in these sizing formulas.
- Read the local 42.20.2 decompile (`zombie.ui.TextManager.getFontHeight`, `UIElement.setWidth/setHeight/setVisible`) and verified these relevant methods against the installed 42.21 JAR with JDK17 javap. Font height returns the selected font's line height. Width/height setters mark resize state and store dimensions; visibility is explicitly set. The old decompile alone was not treated as current-build proof.
- `TurretManageLayout.refresh` sets `detailsPage = detailsOpen and desired > panel.height`. It then explicitly hides all slots, power, source, Set Aim, Reload, Load Order and category help. Its minimum height excludes Details. The screenshot's replacement page is explained by our own fallback, not native automatic clipping. That fallback must not silently replace the main Manage view.
- `TurretManage.open` defaults to at least 900 pixels (912 at the logged font metrics). Equipment receives 40 percent of the upper row; Ammunition gets the remainder. Module width is capped at 108 and also subtracts 440 from the available row before division. Merely narrowing Ammunition without revising the overall width and module calculation will not reliably remove the blank margins; it can just redistribute them or shrink tiles too early.
- `ControlWorld.publish` excludes input records whose `placed` flag is false. `ControlWorld.input` sets `linked=true` for every reverse-index entry before checking source availability. `retire` clears placed state but leaves stored links; `removed` removes the loaded object binding. A retired input can therefore disappear from the public list while its retained entry continues to affect firing power. This mismatch is confirmed by source inspection; matching it to the owner's exact turret is still unverified. Temporarily unloaded live inputs must retain their links and safe inactive behavior. Controller assignment and trigger connections remain separate concepts.

## Proposed corrections and decisions

### 1 — Window chrome

Recommend **1A**. Use the native title/footer sizing rules, Small title font, correctly sized close control and native title-bar texture; keep red/white OMH branding and omit locking/pinning.

- **1A:** Match native compact window chrome.
- **1B:** Keep a slightly larger Medium-font title with minimal padding; compact footer remains native-sized.

### 2 — Manage width

Recommend **2A** for the least complex change. Target roughly 720–760 pixels at the owner's current font, then validate actual text fit before setting the default. Equipment/Ammunition move toward equal widths; preserve compact 4/4/4/4 modules and remove the artificial 440-pixel margin calculation. Width remains resizable and font-aware. A narrower Ammunition panel alone cannot fix a full-width empty module background.

- **2A:** Narrow the whole menu and balance Equipment/Ammunition; retain the current section order.
- **2B:** Keep the wider menu and place Details beside the module grid when open, using the side space but adding responsive layout complexity.

### 3 — Details and vertical resizing

Recommend **3A**, consistent with the owner's earlier no-main-menu-scroll preference. Retain inline Details and all main controls; clamp the minimum height to the currently visible content after compact reflow. Short viewports still require explicit fit validation, with local Module Stats scrolling available for long lists; do not silently substitute a details-only page.

- **3A:** Keep inline Details; stop vertical shrinking before visible sections would be lost.
- **3B:** Allow a shorter window with a scrollable main content area; fixed title/footer remain outside scrolling.

### Trigger-state correction

No new requirement for external triggers is proposed. A turret with no real input links must retain normal manual power and module behavior. Reconcile permanently retired/stale links across authority and presentation, preserve temporarily unloaded inputs, and expose the actual retained input names when a turret is controlled by them. Reproduce pickup/destruction, explicit disconnect, temporary unload and restart paths before claiming this defect fixed. Controller unassignment alone must not silently erase legitimate trigger links.

## Next verification

After the owner selects the layout options: compare title/footer/close dimensions directly against installed vanilla at the owner's 16px setting; exercise wide/narrow and tall/short windows with Details both ways, including long module names and Lure/Lobber controls. Add assertions that the chosen policy keeps equipment/modules visible. Test both public input lists and authoritative power after link removal/unload/restart. Rendered owner acceptance remains required; the previous geometry tests passing did not prove the rejected details-page behavior was appropriate.

Exact five-second native multiplayer placement remains a separate open item from 0.2.57.1. No new version, local install, LootLab change, merge or Workshop publication in this discussion.

## C342 — Owner selections (2026-10-19)

Owner selects **1A, 2A, 3A**. These supersede the alternatives above: native compact chrome with red/white OMH branding and no locking/pinning; narrower, font-aware Manage layout with balanced Equipment/Ammunition and compact 4/4/4/4 modules; inline Details with a minimum height that keeps main controls visible. The 720–760 pixel target remains subject to text-fit verification rather than a rigid width promise. No automatic details-only fallback or main-content scrollbar is selected.

All three layout choices are settled. This selection turn records the design; implementation approval remains pending following the owner-requested discussion gate. Installed 0.2.57.1 remains unchanged. The proposed trigger-state reconciliation and multiplayer verification requirements remain as described above; no new gameplay requirement or automatic Controller-link deletion is inferred. **Wait for a patch.**
