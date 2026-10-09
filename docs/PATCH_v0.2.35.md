# 0.2.35 - Building fallback, crafting categories and short zombie trips

C107 owner approval, 2026-10-08: "Approved. Go ahead and patch." Supersedes C106's pending route/layout choices. Local implementation, checks, immutable test tag and installation are authorized; GitHub mirroring and Workshop publication remain separate.

- Crafting uses native Normal / Reinforced / Packed categories. Remove the custom collapsible-family adapter; retain existing Pack/Unpack recipes and stable item IDs.
- Building has one route per placeable defense, in Normal or Reinforced. Prefer an exact usable carried item; otherwise run its original crafting recipe, then open the existing placement cursor for the actual output. Packed bundles stay crafting-only and must be unpacked first.
- Fallback respects native skill, tools, ingredients, time and XP, followed by the existing five-second placement. It never recursively crafts prerequisites: a reinforced recipe still needs its basic item. Closing/cancelling placement leaves completed output intact. Native over-capacity output may land on the floor and must be picked up. Placement grants no second crafting XP/material charge. Loaded turret placement retains the actual item and contents.
- Building labels match inventory actions: Place Trap, Attach Trap and Install Trap. Original private prototypes remain hidden. Feature switches and independent package boundaries apply.
- Manage has three rows of 4/6/6. Fresh capacities remain 2/4/8/12/16; rows do not represent upgrade tiers. Saved settings, custom capacities and stored overflow remain accessible.
- The zombie-only bed-trip animation disables native deferred displacement, retaining its forward stumble and native landing/get-up events. This targets the reported travel past the bed. Player movement, potato knockdown and damage rules are unchanged; damage still requires a fresh fall on the bed.

Installed 2026-10-08 from `test/v0.2.35` / `07275b2`; 3,830 assertions, native write/read and independent package startups pass. All tagged/source/package/installed/archive hashes and prior backups verify.

## Evidence and limits

Native recipe/action validation binds exact resolved ingredients before queuing; this game build rejects the automatic false input-table argument in ISHandcraftAction.FromLogic. Completion reads actual recipe-created items after the native transaction. No global action replacement, speculative refund or copied crafting transaction is introduced.

Installed 42.21 animation metadata accepts m_useDeferredMovement=false for only OMHTTBedTrip; player trip displacement remains enabled. Tests cover the parsed value and controlled recovery. Natural rendered movement, Building interaction and visual layout still require the [short owner test](TEST_v0.2.35.md). Runtime/installation evidence is recorded in [RELEASE.md](RELEASE.md); headless checks do not certify client frame smoothness.

The prior full test is not reopened. C106's tentative passes remain tentative, and its zombie overshoot failure is addressed by this patch, not retroactively marked passed. R1C3 performance work and later content decisions retain their documented status.
