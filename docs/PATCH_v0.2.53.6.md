# 0.2.53.6 — copper-orange menus and attached Stockpile

C300, 2026-10-17. Owner selects copper-orange and approves trying the C297–C299 corrective design. This includes the previously reviewed layout, battery and transfer corrections; it does not authorize sibling-mod changes or publication.

## Changes

- Shared copper-orange accents (`#E7A05A`) and dark copper surfaces (`#30251B`) replace the green-tinted management accents. Charcoal section bodies and restrained borders retain contrast. Titles use red **One More Horde** with white **- Turret Management Menu** / **- Controller Menu**. Power remains green/on and red/off; rarity colors retain their meaning.
- Reload and Load Order sit together below the ammunition slots. Details has its own row below the module grid. Equipment/Ammunition remain side by side, with source selection in Equipment. The title remains a separate drag region. Main Manage never scrolls; short displays use compact rows and the existing Details page fallback.
- Controller owns an attached native `ISInventoryPane` Stockpile, with the native item rows, selection, tooltips, sorting and transfers. Opening/closing it does not reposition, reparent, pin or force open the player's HUD inventory. Narrow windows use a full-width Stockpile page inside Controller with Back. Stockpile remains defense-only with its existing 500-weight limit.
- Controller Equipment includes a visible ordinary **Battery** slot. Dropping a carried battery stores/selects that exact item; dropping an already stored spare selects it. Right-click or drag removes it normally. This references Stockpile contents, not a second container. Existing electricity and backup-drain rules remain unchanged.
- Stockpile context is carried through head, module, ammunition, magazine and Void actions. Nearby physical servicing works even if the Controller is offline or the nearby turret is unassigned. Remote servicing still requires the powered, assigned, authorized Controller session. Native incoming/outgoing transfer hooks retain completion callbacks and exact destinations.
- Failed drops retain their items. Unsupported Manage drops explain the accepted destinations. Removal restrictions, favorite-item protection, capacity, ownership, reach, stale remote sessions and cancellation remain checked at completion on authority.

## Implementation and review

Native `ISButton:setEnable` restores its cached enabled background, which caused the black power state; the shared theme now maintains per-button current-state colors rather than sharing mutable native color tables. The new Stockpile pane owns its own lifecycle and refreshes when containers change. Closed panes leave the active collection; revoked access clears drag/tooltips. Battery selection caches the exact item ID, with a one-second retry only if replication has not delivered it yet.

Existing 64-object/two-millisecond Controller scan budget and five-second refresh remain. No permanent world scan, catch-up processing, separate stockpile inventory or client-authoritative item mutation was added. Bulk ammunition stays capped at 20 exact items per transfer action. Selected-battery changes publish even when the replacement has equal charge. Native NetTimedAction receives the Controller reference as a top-level action field.

No damage, recipes, capacities, sounds, rarity distribution or battery-drain balance changed. Shipped Lua retains the no-pcall/xpcall/ipairs/next gate. Shared Control modules remain independent of Turrets-only UI at load time.

[Verification and focused test](TEST_v0.2.53.6.md). Automated/native checks are distinct from rendered gameplay and connected multiplayer acceptance. C108 delivery uses the existing development branch/draft PR; no merge or Workshop upload.

## Delivery

Installed from immutable `test/v0.2.53.6` / `c84fb616dc4e5c2cc376f6b0ec5aeaa51d6a5514`. All 288 source and 367 tagged/packaged/installed/archive files match; both 0.2.53.5 backups verify. [Release evidence](../diagnostics/v0.2.53.6/local-release.json). Development delivery uses the existing branch and draft PR; rendered/connected acceptance remains open.
