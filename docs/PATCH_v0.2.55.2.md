# 0.2.55.2 — Controller connections and resizing

- Three connection gestures
- Persistent connection lines and disconnect handles
- Defense condition bars and ammunition counts
- Taller Controller and darker inset lists
- Stable resizing and visible corner grips
- Stockpile scrollbar alignment

Drag a trigger row onto a defense, click the trigger's right handle then the defense's left handle, or drag between map markers. An armed trigger always adds a link; an existing pair is a no-op. An unarmed connected defense handle removes its single incoming link, or opens a choice when several triggers are connected. The old Use as Input/Connect controls and duplicate incoming list are removed from Selected Device; trigger filtering, Controls and Access & Assignment remain separate.

Lines and the corner grip now use the native thickness-aware line renderer. Explicitly laid-out resize grips and Stockpile scrollbars no longer also use deferred right/bottom anchors. Resizing uses the initial pointer/window bounds, keeps the top-left fixed and stops at the viewport edge. The Controller starts up to 1,000 pixels tall; older saved Controller geometry adopts the taller height once. Subsequent user sizes persist. Smaller screens and long device/stockpile lists retain bounded scrolling.

Defense ammunition is the total usable supply for the installed head, including magazine and compatible Void contents. Counts are sampled while the menu is open, with at most 128 inventory-item reads and a 1 ms deadline per slice; they may briefly lag transfers/firing. The display never changes inventory or grants remote access. Condition reads use the existing synchronized object. No new server command, combat rule, input signal or loot item is introduced.

The ID card visible in the owner's Stockpile is an additional audit finding. Existing disallowed contents must stay removable; this patch does not delete them. A native item-classification regression checks rejection of a new ID card deposit. The screenshot alone does not establish when or how it entered storage.

See [verification](TEST_v0.2.55.2.md) and [C325](CONTROLLER_MAP_C316.md#c325--connection-gestures-and-controller-polish-2026-10-18). Rendered and connected multiplayer acceptance remain separate from automated checks. The earlier main-menu performance investigation is not declared resolved by this UI patch.
