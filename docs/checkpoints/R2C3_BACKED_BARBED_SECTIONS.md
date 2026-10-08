# R2C3: Barbed Panel

Current checkpoint contract, synchronized 2026-10-08. Implemented in 0.2.31 under C99 and revised through installed 0.2.34. Native construction/contact/persistence checks pass; rendered acceptance remains held in the single [combined owner test](../TEST_v0.2.34.md). See [canonical phase status](../ROADMAP.md#current-checkpoint-status-and-next-work). The former C97 wall/fence-only design and unsettled service proposals are historical, superseded by C99-C104.

## Implemented contract

- One-tile wooden-frame Barbed Panel belongs to independent Traps and requires exact backing: ordinary single-panel doors, fixed window frames, walls or fences. Four placement directions use two texture states. No freestanding placement or second blocking collider.
- Doors carry the contact edge with the leaf. Window barbs stay on the frame across open/smashed glass, with independent 50 HP and no increase to glass/window HP. Finite damageable supports share native health; supports without persistent damageable finite HP use independent 50-HP barb durability.
- Immediate/default 10 zombie damage, then 10 every two seconds during actual exposed-side contact. A shared per-zombie interval prevents adjacent-panel and rapid re-entry multiplication. Contact stops on exit; no accumulated catch-up hits. Independent durability loses one per damaging activation. No player injury, slow, trip or knockback is implemented by barbs.
- Bind to exact support identity; a replacement at the same location does not inherit the attachment. Unloaded backing suspends contact rather than proving destruction. Removal/breakage stops active contact. Loaded-edge indexing and bounded maintenance avoid whole-world scans.
- Craft the portable panel, then use inventory **Attach Trap**. Building entries remain removed. The approved wooden recipe consumes one Barbed Wire, two Planks, four Nails and two Wire uses; retain hammer and pliers, Carpentry 1, 10 Carpentry XP. See [crafting conversion](../PATCH_v0.2.32.md).
- Current attachment/removal takes five seconds under C104; repair remains ten seconds. Finite support health uses normal support repair; independent barb durability has a repair route. Placement does not grant support HP or a free support repair. Current service/item behavior is defined by the later patches, not the original C97 no-implementation proposal.

## Evidence and later corrections

The [C98 native feasibility report](R2C3_NATIVE_FEASIBILITY_20261007.md) records initial host/contact fixtures and the map-fence partial-counter persistence limitation. The [C99 implementation record](R2C3_IMPLEMENTATION_20261007.md) records exact support identity, conditional durability, door/window geometry, construction and native serialization. These dated records describe their original builds; their old service times and issued tests are historical.

[0.2.32](../PATCH_v0.2.32.md) adds crafting/attachment terminology, Traps settings grouping, fence/panel Bed Spikes co-placement and reduced texture states. [0.2.33](../PATCH_v0.2.33.md) corrects panel cursor tool/Build Cheat handling and sets panel weight to 2. [0.2.34](../PATCH_v0.2.34.md) applies five-second placement/pickup, including panel attachment/removal. See [release evidence](../RELEASE.md) for installed/native verification, without treating it as rendered acceptance.

## Remaining gates

- Complete the current combined rendered test when the owner is available: actual placement, door-leaf alignment, zombie contact and dense-client behavior. Do not request the superseded 0.2.30/0.2.31 rounds separately.
- Multi-panel/garage doors remain unsupported pending native identity/movement proof. Do not attach to arbitrary replacement leaves.
- Player barb injury and a reinforced panel variant remain unimplemented/unscoped; the general reinforced damage ratio does not authorize either addition or increase support HP.
- Integrated multiplayer requires R5C1. No stall fix, final artwork acceptance or publication is claimed.

No new gameplay is approved by this documentation reconciliation. C97-C104 in [Decisions](../DECISIONS.md) retain the design history; future content follows the roadmap rather than reopening settled health, naming, recipe or service choices.
