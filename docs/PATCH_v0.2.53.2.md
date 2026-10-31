# 0.2.53.2 — Manage and Controller correction

Approved C290 corrections to0.2.53.1. Current gameplay, capacities and multiplayer ownership remain intact.

- Single-page Turret Manage
- Restored section backgrounds and layering
- Measured expandable Details
- Reliable window drag release
- Controller spacing and readable device labels
- Native Controller stockpile inventory

## Diagnosis and implementation

The previous layout removed header strips. Details assumed three lines regardless of wrapped content. Manage now keeps Equipment, Ammunition,4/6/6 module slots, Installed Modules and Details in one scrollable body, with a separate title/name band and fixed firing/range controls. Header strips, dim sections and inset contents share consistent bounds. Details renders measured lines and reserves their actual height.

Installed42.21`UIElement.setStencilRect/clearStencilRect/repaintStencilRect` bytecode confirms nested clips increment pixels and decrement the level without automatically repainting the parent. Slot/list text clips now clamp to their parent and repaint the clipped region. Controller details account for their own scroll offset and restore the viewport stencil between text groups. Header/footer remain outside the content clip.

Both windows capture a title drag, release on inside/outside mouse-up, and clear stale movement on the next UI update if a child consumed the release. Closing also releases capture. Controller removes unsupported prefix glyphs, uses Small-font native device rows and collapses unused action space when the Controller itself is selected.

The custom paged stockpile and its invented drag/list behavior are removed. Open stockpile selects the actual Controller container in Zomboid's native loot window and opens the native player inventory. Native sorting, stacking, tooltips and inventory dragging are retained. Closing Manage/Controller leaves native inventory under normal player control. Controller capacity display/drag admission are scoped to its500 limit; ordinary containers delegate to native methods. Preview budgets selected items together, caches unchanged drags and performs no timed-action allocation. The existing server transfer validates ownership, reach, favorite protection and capacity again. Equipped items use native`ISTransferAction.removeItemOnCharacter` cleanup after successful storage. Source/destination identities, multiplayer transaction routing and remote authority are preserved.

The console's premature building-class require is deferred until device placement, after native server/shared building definitions have loaded. No global exception suppression, new tick loop, gameplay balance, audio, art or persistence schema change.

## Verification boundary

[Verification and four-step test](TEST_v0.2.53.2.md). Automated geometry and native-style stencil simulation are not a rendered-client acceptance test. Connected multiplayer acceptance remains deferred. Previous0.2.53.1 failures remain recorded on that version. No Workshop publication; the cumulative draft retains all pending changes.
