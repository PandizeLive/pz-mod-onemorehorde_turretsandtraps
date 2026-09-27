# P2C1b and native persistence repair: 0.2.1

The owner authorized this combined candidate on 2026-09-27 and explicitly approved using the existing basic recipe and XP for portable crafting. High reasoning was recommended, with an estimated 35-55 minutes including native verification and Fast for the longer work. P2C1c bundles, reinforcement, recovery and multiplayer acceptance remain separate.

## Behavior

- Crafting > Carpentry > **Craft Spike Barrier** produces one inventory item: four interchangeable planks/basic crafted wooden spears, four binding units, retained sharp knife/cleaver, Carpentry 1, 200 native action units and 10 base Carpentry XP.
- Building > Carpentry or Turrets & Traps > **Deploy Spike Barrier** consumes one finished barrier, with the same rotating 1x2 preview and obstruction/overlap checks. No tools, extra raw materials, skill requirement or XP award. Native Build Cheat retains its normal behavior; it is not evidence of inventory consumption.
- **Spike Barrier** remains the raw-material construction recipe. Both routes create the same basic 100-condition, 20-damage defense. The ledger also preserves which native entity produced each pair.
- Portable encumbrance is provisionally 6. The owner has not selected the offered weight; this is test tuning, not a confirmed decision. Only pristine inventory items deploy; damaged-item recovery and condition-preserving repacking are deferred. Existing placed barriers are not made collectible by this checkpoint.
- Crafting/deployment respect the master/barrier switches and remain SP-only. Switching a feature off preserves existing barriers. The white arrow item icon and packed world sprites reuse the existing authorized PNGs without changing their pixels.

## Persistence repair

The former named, file-backed sprites had ID -1. `IsoObject.load` resolves that ID to the empty sprite before loading the native SpriteConfig, explaining why naming alone fixed creation but not reload.

The package now declares `tiledef=OMHTT_Barriers 7316` and `pack=OMHTT_Barriers`. Sheet `omhtt_barrier_01` has 16 permanent indices: 0-7 for raw construction, 8-15 for finished-item deployment; each route has E/N/W/S A/B parts. The two entities need distinct names because SpriteConfigManager rejects sharing one sprite across entities. Native IDs start at 1918369792. The file number was checked against locally installed mod.info files; global exclusivity is not claimed. Do not renumber a released tiledef or its existing indices.

Reconciliation upgrades exact ledger-owned construction parts to their persistent sprites. If a component is missing, invalid or points at the old part, it replaces only SpriteConfig through the native component factory. Existing damage, paired identity, owner and ledger entries remain. It does not respawn missing objects or adopt unrelated remnants from a failed build. Debug rotation also refreshes the cached native part identity.

Old saves may emit their original invalid-component warning while the engine first reads an old part, before Lua migration can run. Successful restoration logs must follow. Saving the migrated object and reloading should not repeat that warning. A failed or ambiguous old object is not silently deleted.

New `barrier-restoration` records identify the device, coordinates, old/new sprite, persistent ID, native entity validity, heading, damage, owner and whether anything changed. `portable-crafted` reports the item type, ID, count, weight and crafter. Construction-part records identify the recipe source. Diagnostics stay bounded through the existing logger and scheduled reconciliation.

## Evidence

- Installed B42.20.4 b0bbce05d5 with PZOptimizer; installed class hashes are captured by validation. Historical decompiled sources were discovery aids, with installed bytecode/native probes confirming the relevant APIs.
- 270 Kahlua assertions, 14 runtime Lua modules, 69 native translator keys and 23 native network-table serializations pass. Tests exercise installed construction/preview code with doubles, including portable placement in all four headings, missing inputs, duplicate rejection and ledger damage/identity round-trip.
- Native ingredient validation covers 75 mixes for raw construction and 75 for portable crafting. A real CraftRecipeData transaction creates one item and retains its knife. Native deployment consumes one inventory item, preserves another and declares no XP/skill requirement. Missing/damaged input and content/MP gates reject correctly.
- Native migration repairs stale sprites and missing components without changing 37 condition; repeating it does nothing.
- The native loader creates 16 real thumpables. The test launcher writes their actual serialized object bytes, reloads them, and another fresh server process reads those same files. Both preserve SpriteConfig/part/entity identity, 37 condition, collision flags and an ownership marker. Lua ledger persistence is tested separately. Native texture-pack parsing verifies 16 entries, four pages and readable 128x256 PNG streams.
- The successful write/read server runs took 45.2/43.7 seconds and shut down cleanly. No OMHTT invalid SpriteConfig warning or Lua exception appears in either successful run. Unrelated vanilla startup warnings remain.
- The native probe fixtures are not streamed map chunks and have no connected player. Rendered SP visuals, real cell transitions, displayed XP modifiers and owner acceptance remain pending. This does not mark all Phase 1 gates complete.

Item validation exposed an engine detail: `InventoryItem.getActualWeightUnmodded` returns zero when the display name equals its full type. The item supplies its normal script display name as well as ItemName translation, so it loads as Spike Barrier with weight 6 even before a late translator refresh.

## Owner test

1. Restart into **0.2.1** using the disposable SP save from 0.2.0.3 so old barriers are included. Enable the mod, Spike Barrier and Diagnostic Logging; turn Build/Crafting Cheat OFF. Have Carpentry 1, a sharp knife/cleaver, 12 planks/spears and 12 binding units.
2. In **Crafting > Carpentry**, craft two Spike Barriers. Expect two named items at 6 encumbrance each, eight wood/binding units consumed, the tool retained and 10 base XP per craft (displayed XP uses game modifiers).
3. In **Building**, find **Spike Barrier** and **Deploy Spike Barrier** under both Carpentry and Turrets & Traps. Build one raw-material barrier with the remaining four wood/binding units; expect one complete 1x2 barrier.
4. Preview **Deploy Spike Barrier**, rotate, then cancel. Both items should remain. Try overlapping either half of the built barrier and placing across furniture/walls; invalid placement must consume nothing.
5. Deploy one on clear ground. Expect one item left, two correctly directed arrow parts, blocked walking/vaulting, and no extra ingredients or XP.
6. Let a zombie damage one barrier, then travel far enough to unload the area and return. Both parts should reappear without duplication or healing; restoration and health logs will provide the detailed evidence.
7. Save, quit to desktop and reload the same save. Old and new barriers should remain visible, solid and correctly directed, retaining damage. Try overlapping one again; it must still reject placement.
8. Say **Test Complete**, noting any visible failure. I will capture console.txt and verify version, transactions, migration/restoration and warnings. P2C1c bundles wait for this acceptance.

## Release and rollback

See [release state](RELEASE.md) and [repair notes](PR_v0.2.1.md). Commit complete source and create annotated `test/v0.2.1` before installing through OMH.cmd. Keep the managed 0.2.0.3 backup and matching package archive. No Workshop upload or remote push is authorized. Rolling the package back does not make new 0.2.1 inventory items/tile IDs readable by the old package; use the disposable save's pre-update copy when testing a rollback.
