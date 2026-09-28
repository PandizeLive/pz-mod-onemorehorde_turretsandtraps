# P2C2a — visibility and reinforced Spike Barrier (0.2.7)

Status: implemented and validated; local install evidence is recorded in Release state. Rendered SP acceptance remains pending. C25/C26 approve the upgrade recipe; C41 requires visibility; C42 approves reinforced recovery and same-tier bundles.

## Resulting behavior

- Barriers permit line of sight through fronts, end caps and corners while preserving native walking collision, zombie blocking and directional thump ownership. Existing helpers obtain the same sprite metadata on startup. No visibility toggle is added.
- Reinforce an existing basic barrier from its world submenu: Carpentry 3, two planks, eight loose nails and a retained unbroken hammer. Materials must be in the player's inventory or carried bags. The ten-second action revalidates before consumption, cancels on movement and grants 30 base Carpentry XP once. Vanilla Building Cheat bypasses materials/skill without XP; it cannot repeat an upgrade.
- Reinforced default damage is 25. Maximum durability is twice basic durability (200 at current defaults). Upgrading a 70/100 barrier produces 170/200, preserving missing health. Sandbox changes afterward preserve remaining percentage, as for basic barriers.
- Reinforced Damage (0-1000, default 25) and Reinforced Durability Multiplier (1-10, default 2) appear under Spike Barrier with short tooltips.
- Both tiers use free ten-second pickup/Repair. Pickup returns a full-condition item of the same tier. Reinforced items deploy through Building without another skill/material charge or XP award. They cannot be used in basic bundles or combined across tiers.
- Separate reinforced five-item pack/unpack recipes retain the 67 percent reduction and zero XP. Reinforced items currently reuse the provisional weight 6, giving a pack weight of 9.9. This is a test tuning assumption, not a new final balance approval.
- No final artwork is introduced. Eight additional stable sprite identities reuse the existing technical arrows. World submenu and inventory item names distinguish the tier.

## Vault review

The three interrupted 0.2.6 results all ended beyond the original destination tile after contact and a success outcome. Requiring the exact destination tile was too strict for continued movement. Once contact has been observed, completion checks the crossed side of the plane, the same floor and a normal recovered state. It still rejects returned-to-origin, fall/hit reactions and cancelled attempts; it neither moves the player nor repeats the scratch.

The separate native-entry timeout did not enter the fence state or generate contact. No cause is proved by the old capture. Result diagnostics now include current state, start/target coordinates and entry/animation flags. Keep this case open for the owner test; do not force a retry or bypass native states.

## Installed-engine evidence

B42.20.4 b0bbce05d5 with PZ Optimizer, loose classes before the jar:

- `IsoThumpable.TestVision` uses sprite `doorTrans` for a sight-permitting blocked edge. `IsoGridSquare.CalculateVisionBlocked` separately checks directional transparency. Helper sprites now supply both without changing collision/hoppable flags. Native object and grid vision probes cover both directions and corner insertion orders, alongside the previous pathfinder/thump checks.
- `ISMultiStageBuild.consumeMaterial` and `ISBuildingObject` establish native material removal and retained usable-hammer lookup patterns. Current `ItemContainer` exposes `getSomeTypeRecurse` and `getFirstTagEvalRecurse`; selections stop at two planks/eight nails. Native fixtures validate actual inventory item/tag lookup.
- `ISBaseTimedAction` supplies movement cancellation. The existing bounded active-real-second service clock is reused. `addXp(player, Perks.Woodwork, 30)` supplies a base award; character/world modifiers may change displayed XP.
- `SpriteConfigManager` needs distinct tile identities per construction entity. Existing IDs 0-19 remain stable; IDs 20-27 provide reinforced deployment, using the same four arrow texture pages. Existing objects migrate components in place on reinforcement.

## Verification

Evidence directory: `diagnostics/v0.2.7/`. 1,472 Kahlua assertions, 24 runtime modules, 121 native JSON translation keys, 23 packets and 77 package files pass. Native write/read tests restore 28 objects across fresh processes. Twelve object/grid vision directions pass alongside both corner insertion orders/pathfinders, four cardinal vault directions and twelve native run/sprint parameter cases. The final read probe also confirms each helper does not make its perpendicular direction transparent. Tests cover native visibility with collision intact, material/skill/tool rejection, interrupted and repeated completion, missing-health preservation, tier/condition persistence, settings changes, tier-preserving pickup/deployment, same-tier pack/unpack and continued-running vault completion.

Native smoke runs have no connected player. Rendered visibility, upgrade animations, complete live Repair, live save/reload and the one native-entry timeout remain owner acceptance work. Multiplayer gameplay remains disabled.

## Owner test

1. Restart PZ and confirm **0.2.7**. Use a disposable SP save, Diagnostic Logging/Show Collision on, and No Clip/God Mode off. Check visibility through old/new fronts, end caps and corners while walking collision still blocks.
2. Try Interact, run and sprint across a front and an end, continuing to move after landing. Check that zombies still thump rather than climb; report any refusal or unusual trip.
3. With Building Cheat off, Carpentry 3, two planks, eight loose nails and an unbroken hammer in inventory, damage a basic barrier and choose **Reinforce**. Cancel once, then complete: consume materials once, retain the hammer, grant 30 base XP and preserve missing HP (70/100 becomes 170/200).
4. Check 25-damage front thumps and safe inward faces. Change the reinforced damage/durability settings and check the world condition; restore 25 and multiplier 2 afterward.
5. Finish **Repair** without moving: ten seconds, full reinforced durability, no materials. Pick it up and deploy the returned reinforced item through Building; tier and 200 maximum should remain.
6. Obtain five reinforced items and pack/unpack them through Crafting: one 9.9-weight bundle, then five reinforced items. Basic items should not substitute; neither operation awards XP.
7. Damage a reinforced barrier, save, exit and reload. Check tier, condition, visibility, joins and collision. Exit again and report **Test Complete** for log review.

Handoff: Test now only after local installation is verified in [Release state](RELEASE.md).
