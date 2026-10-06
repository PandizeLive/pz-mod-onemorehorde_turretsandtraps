# Turret inventory and module plan

Current implementation through **0.2.28**, with C84 improvised-component proposals below. This replaces the old 0.2.14 snapshot; detailed historical approvals remain in [Decisions](DECISIONS.md) and versioned patch documents. Current values are defined in the packaged Sandbox options and shared stat resolver. Module crafting is not implemented; C84 schedules craftable improvised variants with recipes still to review.

## Current inventory and operation

The dedicated Manage window uses actual items and native timed transfers: one head, reserve ammo, the appropriate magazine, battery, one Expansion Kit and regular module slots. Removing/redeploying retains exact head condition, contents, charge and cooldown state; carried weight includes contents. Repair restores base health, not the gun or battery.

Small/Medium/Large Expansion Kits expand ammo/module capacity through a dedicated socket and do not stack with each other. Regular slot defaults are four, rising to six/eight/ten with the kits. Sandbox values can change those capacities. Reject removal if remaining contents would not fit; never silently delete or dump them.

## Implemented module roles

| Component | Role | Stacking |
| --- | --- | --- |
| Firing | Operates automated firing while enforcing resources and cadence | One |
| Detection | Tracks eligible zombies, aims and supplies automatic fire requests | One; stationary zombies remain detectable |
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

## Planned improvised components and centered expansion layout

C84 requests craftable improvised Detection, Firing and Expansion variants; C86 simplifies progression after reviewing compact menu examples. The Expansion Kit uses the existing dedicated socket and replaces the installed kit; it does not occupy a regular module slot or stack with other kits. Keep one active Detection and one active Firing role across improvised/standard variants. Suggested Detection drawbacks are reduced automatic detection range and slower acquisition; owner proposes a 15% click-only failed trigger for Firing. Exact settings and recipes remain unapproved. On a failed trigger, recommend a normal cooldown, retained ammo and no persistent weapon jam or full effect-power cost; do not also impose the earlier proposed firing-rate penalty.

Planned C86 defaults: successive upgrades unlock 2, 4, 4 and 4 more slots beyond the two-slot base. Capacity progression is independent of physical UI rows. These replace C85's 2/4/7/11/16 plan, not the currently installed defaults until R3C8 is implemented.

| Kit | Bonus over base | Total slots | Gain over previous tier |
| --- | --- | --- | --- |
| None | 0 | 2 | Base |
| Improvised, craftable | 2 | 4 | +2 |
| Small | 6 | 8 | +4 |
| Medium | 10 | 12 | +4 |
| Large | 14 | 16 | +4 |

C86 retains four total slots for Improvised, adding two to the two-slot base. Each kit replaces the previous kit's total bonus rather than adding to it. The five-row pyramid is no longer required: a two-row, eight-column grid was recommended after interactive previews; a four-column alternative remains available for readability. Do not couple unlock groups to physical rows. UI must preserve readable labels and drag/drop targets at supported resolutions, with stable slot identity and scroll handling when needed. Locked slots remain visibly inactive. The two base slots can hold Detection and Firing, making expansion necessary for extra modules on an automatic turret.

The planned base reduction from four to two requires an explicit migration policy before implementation. Do not delete, dump or silently disable installed modules, or reinterpret saved Sandbox bonus values as totals. Keep safe removal/downgrade checks and inventory slot identity independent of row coordinates. Non-default saved capacities also need reachable UI slots; the 16-slot preview is not permission to hide stored items.

Expansion ammunition capacity remains separate pending tuning. Additional empty slots do not themselves consume battery; active combinations must meet C81 power/endurance and combat-work limits. Standard modules remain loot-based unless separately approved for crafting. [R3C8's checkpoint brief](checkpoints/R3C8_IMPROVISED_EXPANSION.md) records exact capacity semantics, compact layout, migration and acceptance. It implements this scope after R3C4 resolves tuning/recipes; R3C7 includes the larger loadouts in combined acceptance.

## New heads and package boundary

C80 schedules OMH: Turrets as a selectable component alongside OMH: Traps in one Workshop download. The installed build is not split yet. Turret items/recipes/module loot/render/combat hooks must not load in traps-only mode. Shared helper and optional signal contracts need the R1C1 loading proof.

Use the same universal base for [proposed unique heads](TURRET_HEAD_PROPOSALS.md). Each head declares ammunition, magazine/loading model, power, targeting/hit model and compatible modules. Reuse shared services; do not assume that damage, reload or accuracy multipliers have a sensible meaning for every utility/control head. Explain incompatibility rather than accepting inert modules.

External button/plate/beam signals remain planned in R4C4. They may request legal actions but cannot bypass resource, targeting or timing constraints. Signals must not require Traps to enable turret-only operation or require Turrets for fixed powered traps.

## Remaining gates

C81 schedules stackable offensive effects and intensity-based power costs with long battery life. Planned names are Splitter, Fragment Module, Impact, Piercing, Initial Blow and Execute; none is implemented by this documentation update. Confirmed geometry/damage directions, proposed propagation and unresolved caps/resources are separated in [R3C4-R3C7](checkpoints/R3_OFFENSIVE_MODULES.md). Homing, Bleed and slowing turret effects are excluded. Existing potato splash is not renamed or replaced by Fragment. Broad planning approval does not settle every per-head combination.

- R1C1-R1C2: optional package loading, registration ownership and save/ID policy.
- R1C3: dense mixed-defense frame measurements, including rendering and maintenance outside the combat scheduler.
- R3C1-R3C2: select and prove one new head; recipes/skills/XP require approval.
- R3C4-R3C7: offensive effects, shared hit/resource contract and combined battery-endurance acceptance; preserve current modules and settings.
- R4C4: optional cross-package signaling; no unlimited pulse backlog or reload replay.
- R5C1: authoritative multiplayer transactions/combat, two observers, reconnect and replay protection.
- Final art/audio and full modpack rendered acceptance remain independent of headless checks.

Do not add new module recipes, unsupported gun mechanisms, extra turret models or multiplayer claims merely to complete this documentation plan.
