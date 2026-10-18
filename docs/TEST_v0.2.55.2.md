# 0.2.55.2 verification — C325

## Owner findings and diagnosis

Owner's screenshots show missing links, bright trigger rows, a Stockpile scrollbar in the list interior and awkward Selected Device scrolling. Owner also reports unstable resizing and requests all three link gestures, disconnect handles, visible resize corners and defense condition/ammo feedback. Inspected console confirms SP 0.2.55.1; the prior repeating ControlGraph child-update exception is not recurring. This is a new corrective test failure, not blanket acceptance of 0.2.55.1 or evidence that its earlier exception returned.

Native `ISResizeWidget:new` enables right/bottom anchoring while the previous `WindowGeometry.resize` also places that grip explicitly. Its incremental local-pointer calculation is affected by the moving grip. The Stockpile's native pane was omitted from the prior explicit-scrollbar fix. Installed `ISUIElement:drawLine2` submits a thin textured quad; `drawLine` calls the thickness-aware native `DrawLine` used by this patch. Earlier layout doubles represented both as generic visible lines and did not prove rendered visibility.

## Automated checks

Kahlua/adapter validation passes **23,252 assertions**, 233 runtime/translation inputs and 1,042 translation keys; native map/resize checks pass. The package manifest contains 299 source and 385 packaged files. Focused coverage includes whole-row dragging, two-handle clicking, map dragging, duplicate-link no-op, one-link removal, explicit selection among multiple inputs, read-only rejection, stationary resize-pointer stability, viewport limits, outside release, native anchor updates, Stockpile width changes, bounded ammo sampling and tall-window details geometry. Existing 32-by-32 graph and client/server authority checks remain included.

The local layout trace is a code-driven geometry artifact with test data, not a gameplay screenshot. Fresh-process native save/reload passes, including the new ID card classification rejection. Traps-only, Turrets-only and combined startup checks pass. Installed from immutable `test/v0.2.55.2` / `b7edb8d792c79e9f19f6e87b8fba26887b6ce800`. All 299 source and 385 tagged/packaged/installed/archive files match; both 0.2.55.1 managed backups verify. [Release evidence](../diagnostics/v0.2.55.2/local-release.json). No connected-player test is claimed.

## Short owner test

1. Restart into **0.2.55.2**. At a powered Controller, use an assigned trigger and a turret with Firing. Check the darker lists, condition/ammo rows and taller menu.
2. Drag the trigger row onto the defense. A line should remain in the list and map. Click the defense handle to disconnect it.
3. Click the trigger's right handle, then the defense's left handle. Repeat an existing pair: it must stay connected. With no trigger armed, the defense handle disconnects or offers its incoming triggers.
4. Disconnect, then drag the trigger marker onto the defense marker on the map. Verify the line and the trigger's actual turret activation.
5. Resize Controller and Manage using **///**. Hold the pointer still and move past a screen edge: neither menu should jump. Release outside, then reopen and confirm the saved size.
6. Open the compact Stockpile page and resize back to the side pane. Its scrollbar should stay at the right edge. Transfer ammo and confirm the defense count updates; check the console for new errors.

Report the failed step or confirm completion. Connected multiplayer remains a separate acceptance test; the same existing server validation handles these gestures.
