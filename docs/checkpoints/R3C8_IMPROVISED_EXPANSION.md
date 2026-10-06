# R3C8: improvised components and compact module expansion

Planning checkpoint, 2026-10-06. Sources: [C84-C86 decisions](../DECISIONS.md#c86-compact-menu-progression-in-equal-upgrade-groups-2026-10-06) and [module plan](../MODULAR_TURRETS.md#planned-improvised-components-and-centered-expansion-layout). Owner explicitly requests documenting the accepted progression in plans/checkpoints. This is scheduled work, not implemented or installed gameplay. Current 0.2.28 defaults remain 4/6/8/10 for None/Small/Medium/Large.

## Accepted module capacity progression

Start with two base slots. The four successive upgrades add **2, 4, 4 and 4** slots:

| Installed kit | Total slots | Gain over preceding tier | Kit bonus over base |
| --- | --- | --- | --- |
| None | 2 | Base | 0 |
| Improvised | 4 | +2 | +2 |
| Small | 8 | +4 | +6 |
| Medium | 12 | +4 | +10 |
| Large | 16 | +4 | +14 |

Kits are mutually exclusive in the existing dedicated expansion socket. A higher tier replaces the previous bonus; players do not stack kits or need to retain earlier kits. Improvised is craftable. Standard kit crafting is not authorized by that exception. Ammunition-capacity bonuses are separate and remain undecided.

## Manage layout

Use a compact grid with clearly inactive locked slots. Progression groups do not have to become separate physical rows. The five-row pyramid and its 2/4/7/11/16 totals are superseded. Two rows of eight were recommended after the interactive comparison; the accepted progression also fits a four-column layout. Exact layout geometry remains subject to readability and owner selection, not inferred from approval of the counts alone.

Retain access to head, magazine, reserve ammo, battery, expansion, power, range and firing/priority controls. Keep item identities stable through layout changes and preserve readable labels, hit targets and feedback. Support saved custom capacities and contents beyond the default grid through accessible scrolling or an equivalent reviewed approach; never hide or lose stored modules.

## Related starter automation scope

C84 requests craftable improvised Detection and Firing variants. Keep one active item per role across standard/improvised tiers. Owner-proposed Firing drawback is about 15% click-only failure; the previous additional firing-rate limit is not a second approved penalty. Working failure rules: one roll per legal automatic firing cycle, ordinary retry cooldown, retain ammo and opening-round entitlement, no persistent weapon jam or full offensive effect-power charge. Detection's reduced range/acquisition, exact failure/power tuning and recipes/tools/skills/XP need agreement in R3C4 before their implementation.

## Implementation order and acceptance

Scope R3C8 in R3C4, implement reviewed components/UI alongside the other module slices, then include them in R3C7 combined acceptance. The numeric checkpoint suffix does not place this work after final balance verification.

- Confirm total capacities and actual usable slots at every tier; larger kits replace rather than accumulate bonuses. Test direct installation of every tier, not just sequential upgrades.
- Prove inventory transfer, save/load and pickup/redeployment preserve kit, module identities, contents and charge. Block unsafe kit removal/downgrade with clear feedback; do not delete or dump overflow.
- Define and review migration before reducing existing base capacity from four to two. Preserve existing installed modules and saved Sandbox tuning; never reinterpret bonus settings as totals or silently deactivate an over-capacity configuration.
- Validate the menu at supported resolutions/UI scales, keyboard/mouse flows and custom capacities. Locked slots must not accept modules; all stored modules must remain reachable.
- Verify starter automation role replacement, target/aim/resource checks and bounded failed-trigger retries. New recipes require owner review; crafting UI/items/settings/loot must respect the optional Turrets package.
- Include 16-slot loadouts and supported non-default capacities in R3C7 damage, processing and battery-endurance measurements. Empty capacity has no battery surcharge. More slots do not remove effect-specific caps.

No multiplayer certification, new recipe costs, exact ammo bonuses, asset approval or release version is implied. R5C1 remains the MP gate. Supply one complete 4-8-step owner test when the reviewed gameplay slice is ready; no gameplay test is needed for this documentation update. Do not add planned behavior to the Workshop changelog.
