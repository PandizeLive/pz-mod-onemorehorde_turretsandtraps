# R3C8: improvised components and compact module expansion

**Status, 2026-10-08: approved, implemented, verified and installed in 0.2.34; owner acceptance pending.** C104 resolves the C84-C86 proposals. This brief describes the resulting contract, not unfinished recipe/layout choices. See [patch and exact recipes](../PATCH_v0.2.34.md), [native/install evidence](../RELEASE.md), [current module contract](../MODULAR_TURRETS.md#improvised-components-and-expansion) and [canonical phase status](../ROADMAP.md#current-checkpoint-status-and-next-work). Historical alternatives remain in [Decisions](../DECISIONS.md).

## Accepted module capacity progression

Start with two base slots. The four successive upgrades add **2, 4, 4 and 4** slots:

| Installed kit | Total slots | Gain over preceding tier | Kit bonus over base |
| --- | --- | --- | --- |
| None | 2 | Base | 0 |
| Improvised | 4 | +2 | +2 |
| Small | 8 | +4 | +6 |
| Medium | 12 | +4 | +10 |
| Large | 16 | +4 | +14 |

Kits are mutually exclusive in the dedicated expansion socket. A higher tier replaces the previous bonus; players do not stack kits or need to retain earlier kits. Improvised is craft-only; standard kit crafting remains unapproved. Reserve-ammunition bonuses are separate: Improvised +25, Small +50, Medium +100, Large +200. Empty slots add no battery cost.

## Manage layout

C107 revises the grid to three rows of 4/6/6 in 0.2.35 with visibly locked slots. Progression groups are independent of physical rows. The five-row pyramid, intermediate 2/4/7/11/16 totals and four-column alternative are historical.

Head, magazine, reserve ammo, battery, expansion, power, range and firing/priority controls remain accessible. Saved Sandbox settings are preserved rather than overwritten by fresh defaults; item identities and overflow remain accessible. Unsafe kit removal/downgrade is rejected instead of deleting contents. Rendered readability/interaction acceptance remains in the combined owner test.

## Related starter automation scope

Improvised Detection uses 75% automatic detection range after Range bonuses, with normal acquisition speed. Manual fire retains full range. Improvised Firing has a configurable 15% click-only failure per otherwise legal automatic cycle; it retains ammo and shot power, persists ordinary retry cooldown on the exact head and creates no native jam. Manual fire is unaffected. One active Detection/Firing role is allowed across standard/improvised tiers.

All three improvised items are craft-only. C104 approves Electrical 2, retained screwdriver and pliers, twenty-second base crafting and 15 Electrical XP per recipe; exact ingredients are recorded in the linked patch. Standard modules/kits remain loot-based. The earlier additional firing-rate penalty and slower acquisition proposal were not implemented.

## Implementation order and acceptance

C104 independently settled R3C8's former R3C4 recipe/layout/migration dependencies and authorized implementation. Do not reopen those choices or claim that all of R3C4 is complete. The numeric suffix is a stable identifier, not execution order.

- **Verified:** 0.2.34's 3,823-assertion suite, native recipe transactions, exact improvised-item identity and loaded-round/cooldown persistence, independent package startup and installation hashes. See release evidence for the precise scope and client-only timing limitation.
- **Owner acceptance:** C106 records completion of the earlier test with tentative unmentioned passes. Check only the revised layout in the [focused 0.2.35 test](../TEST_v0.2.35.md); do not repeat the old round.
- **Future integration:** include 16-slot and supported custom loadouts in R3C7 damage, processing and battery-endurance measurements. Offensive-module propagation/caps and realistic endurance targets remain R3C4 decisions. More slots do not remove effect-specific limits.

No multiplayer certification or publication is implied. R5C1 remains the MP gate; Building remains deferred until crafting/placement acceptance. This documentation sync does not change the installed build.
