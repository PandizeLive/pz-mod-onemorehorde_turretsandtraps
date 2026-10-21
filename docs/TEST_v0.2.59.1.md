# 0.2.59.1 verification - C373

General validation passes 26,133 assertions, 267 runtime/translation compilation checks and 1,137 native translation checks. Native write passes 84 full-construction cases: fourteen routes, SP/server Lua branches, BuildCheat on/off, plus all four Tether faces on native/player-built walls. Checks retain exact selected inputs, preserve decoys, reject replay and retain Tether condition 37. Native parsing verifies eleven Performance module icons/categories; the original PNG is SHA-256 checked. Native texture loading checks four panel centers against IsoUtils projection and zero extra displacement. Native write (58.0s) and fresh-process read (64.0s) pass, including exact private condition and inventory persistence. Independent startup passes: Traps-only 55.1s, Turrets-only 49.1s, both 44.8s. All probes use installed 42.21 stock-first classes and no connected players.

Earlier fixture iterations corrected missing wall fixtures, cursor rotation order, leftover decoy items and reused persisted fixture coordinates. Script parsing also caught an accidental ScaleWorldIcon edit; all eleven numeric values were restored before delivery. Final successful logs supersede these development failures. No rendered or connected-client pass is claimed.

## Owner test after installation

1. Restart and confirm both entries report 0.2.59.1; use a disposable test world.
2. Place Tether traps against both sides of north/west walls, including player-built walls. Check all four facing previews and placed panels sit flush.
3. Let a target trigger each facing; check nail/cable originate at the panel and return normally.
4. Repeat deployment with Build Cheat off and on. Pick up a damaged trap and redeploy; verify condition and exact item contents persist without duplicates.
5. Check Performance module icons in inventory, Stockpile and Manage. Sort by category; verify five category names and unchanged installed slot order.
6. Check Blades/Lobber battery tooltips and consumption; if testing Sandbox overrides, restore your preferred values afterward.

Installed from immutable `test/v0.2.59.1` / `810c5768f09c93edb696435a91e78f290f881fb5`. All 322 source and 422 tagged/package/install/archive files match; both 0.2.59 backups verify. [Release evidence](../diagnostics/v0.2.59.1/local-release.json). **Test now** after restart. Rendered appearance and connected-client action/synchronization remain pending.


## Owner availability - 2026-10-21

Owner is unable to test and asks to continue planning. The installed build remains unchanged. Rendered and connected-player acceptance is deferred, not passed or failed; the complete test sequence above remains available when the owner can test.
