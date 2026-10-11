# Turret inventory and module plan

Current implementation: **0.2.34**, synchronized 2026-10-08. Improvised Detection/Firing/Expansion crafting and the expanded Manage grid are implemented under C104; standard module crafting remains deferred. [Decisions](DECISIONS.md) and versioned patches preserve historical proposals/approvals. Current defaults are defined in packaged Sandbox options and the shared stat resolver; saved settings may differ. [Roadmap status](ROADMAP.md#current-checkpoint-status-and-next-work) defines the remaining checkpoints.

## Current inventory and operation

The dedicated Manage window uses actual items and native timed transfers: one head, reserve ammo, the appropriate magazine, battery, one Expansion Kit and regular module slots. Removing/redeploying retains exact head condition, contents, charge and cooldown state; carried weight includes contents. Repair restores base health, not the gun or battery.

Improvised/Small/Medium/Large Expansion Kits expand ammo/module capacity through a dedicated socket and do not stack. Fresh regular-slot totals are 2/4/8/12/16 for None/Improvised/Small/Medium/Large. Saved Sandbox values are preserved. Unsafe removal/downgrade is rejected; contents are never silently deleted or dumped.

## Implemented module roles

| Component | Role | Stacking |
| --- | --- | --- |
| Firing | Operates automated firing while enforcing resources and cadence | One |
| Detection | Tracks eligible zombies, aims and supplies automatic fire requests | One; stationary zombies remain detectable |
| Improvised Firing | Craft-only variant; 15% configurable click-only automatic failure with ordinary cooldown and retained ammo/shot power | One Firing role across both tiers; manual fire unaffected |
| Improvised Detection | Craft-only variant; 75% automatic range after Range bonuses, normal acquisition speed | One Detection role across both tiers; manual range unaffected |
| Filter | Closest, Furthest, Weakest or Max Toughness priority | One; Max Toughness uses maximum HP and retains the target |
| 360 | Unlocks all aiming/engagement directions | One; placement-locked forward cone otherwise |
| Rapid-Fire | Improves firing cadence and relevant mechanical cycling | Stackable; configured gain/limit; no added accumulating-recoil system |
| Reload | Reduces reload duration | Stackable; configured gain/limit |
| Autoloader | Removes reload delay; ammunition, magazine requirements and cycling still apply | One |
| Velocity | Increases damage and eligible knockdown chance | Stackable; configured gain/limit |
| Range | Extends firing/detection range within implemented limits | Stackable; obstruction/loaded-area checks still apply |
| Accuracy | Improves hit chance | Stackable |
| Critical | Improves critical chance | Stackable; native firearm base critical chance/damage retained |
| Suppression | Reduces zombie hearing radius, with approved processed/fallback audio | Stackable, diminishing returns and no separate count cap beyond slots |

Non-stackable duplicates are rejected with feedback. Without Filter, a random eligible target is retained until invalid/dead. Power controls operation; manual Fire remains a deliberate request and does not bypass aim, resources or cooldown. Detection/Firing are distinct capabilities. The head must turn into alignment before firing.

Forward coverage defaults to 90 degrees, locked to placement. Engagement range is a per-turret slider bounded by effective weapon range. The selected blue coverage and optional amber hearing ring use current resolved stats; hearing display is a local Mod Options preference. Visual idle scanning does not move the coverage cone.

## Improvised components and expansion

C104 settles the earlier proposals and is implemented in [0.2.34](PATCH_v0.2.34.md). All three improvised items are craft-only with approved Electrical-2 recipes, retained screwdriver/pliers, twenty-second base crafting and 15 Electrical XP. Exact ingredients are in the patch. Failed automatic triggers persist ordinary cooldown on the exact head; they do not consume ammunition/shot power, create a persistent jam or impose an additional firing-rate penalty.

The dedicated expansion socket replaces the installed kit without consuming a regular slot. Successive upgrades add 2, 4, 4 and 4 usable slots beyond the two-slot base:

| Kit | Bonus over base | Total slots | Gain over previous tier |
| --- | --- | --- | --- |
| None | 0 | 2 | Base |
| Improvised, craftable | 2 | 4 | +2 |
| Small | 6 | 8 | +4 |
| Medium | 10 | 12 | +4 |
| Large | 14 | 16 | +4 |

The C107 three-row 4/6/6 grid separates visual rows from unlock groups. Locked slots remain visibly inactive, and stored/custom overflow stays accessible. The two base slots can hold Detection and Firing. Saved Sandbox capacities are not overwritten or reinterpreted as totals; exact item identities remain stable. The earlier pyramid and four-column alternatives remain historical decisions, not pending choices.

Reserve-ammunition bonuses are Improvised +25, Small +50, Medium +100 and Large +200. Empty slots add no battery cost. Standard modules/kits remain loot-based. [R3C8](checkpoints/R3C8_IMPROVISED_EXPANSION.md) is implemented/native-verified/installed, with rendered acceptance held in [the focused 0.2.35 test](TEST_v0.2.35.md). C104 resolved its former R3C4 recipe/layout gates independently; future R3C7 still includes larger loadouts in combined endurance/performance acceptance.

## New heads and package boundary

R1C1-R1C2 implemented fully independent Turrets/Traps entries in 0.2.29 under C87/C88. Native isolation proof is recorded in [the package checkpoint](checkpoints/R1_PACKAGE_SPLIT.md); C89 waived the remaining owner regression without declaring it passed. Later builds retain independent-package checks. Optional signaling remains R4C1/R4C4 work, not an unfinished package split.

Use the same universal base for [proposed unique heads](TURRET_HEAD_PROPOSALS.md). Each head declares ammunition, magazine/loading model, power, targeting/hit model and compatible modules. Reuse shared services; do not assume that damage, reload or accuracy multipliers have a sensible meaning for every utility/control head. Explain incompatibility rather than accepting inert modules.

External button/plate/beam signals remain planned in R4C4. They may request legal actions but cannot bypass resource, targeting or timing constraints. Signals must not require Traps to enable turret-only operation or require Turrets for fixed powered traps.

## Remaining gates

C81 schedules stackable offensive effects and intensity-based power costs with long battery life. Planned names are Splitter, Fragment Module, Impact, Piercing, Initial Blow and Execute; none is implemented in 0.2.35. Confirmed direction and unresolved choices are separated in [R3C4-R3C7](checkpoints/R3_OFFENSIVE_MODULES.md). The documented sequence remains contract/baseline, directional effects, conditional/penetrating effects, combined acceptance. An Initial Blow/Execute-first patch was suggested but not approved as a reorder. Homing, Bleed and slowing turret effects are excluded. Existing potato splash is not renamed or replaced by Fragment.

- R1C3: dense mixed-defense frame measurements, including rendering and maintenance outside the combat scheduler.
- R3C1-R3C2: select and prove one new head; recipes/skills/XP require approval.
- R3C4-R3C7: offensive effects, shared hit/resource contract and combined battery-endurance acceptance; preserve current modules and settings.
- R4C4: optional cross-package signaling; no unlimited pulse backlog or reload replay.
- R5C1: authoritative multiplayer transactions/combat, two observers, reconnect and replay protection.
- Final art/audio and full modpack rendered acceptance remain independent of headless checks.

Do not add new module recipes, unsupported gun mechanisms, extra turret models or multiplayer claims merely to complete this documentation plan.


## C136 implemented module slice (0.2.40)

Magazine, Splitter and Fragment are now implemented under the approved C129-C136 rules. See [patch](PATCH_v0.2.40.md) and [verification/combined test](TEST_v0.2.40.md). This supersedes historical statements above that these three remain unimplemented. R3C6 effects and R3C7 combined endurance remain later work.
