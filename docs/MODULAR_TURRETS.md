# Turret inventory and module plan

## C351 — Siphon 45% / 2x selected (2026-10-19)

Owner selects C349 1A: one 45% roll per eligible kill, 2x the shot's actual local-battery cost on success, +1x multiplier per additional Siphon; stacking does not increase proc chance. Preserve Synergy-gated secondary kills, same-battery identity/generation and no Controller refund. Legendary rarity/loaded weight 3 remain unchanged. Selected for pending patch, not installed.

Owner also requests head-versus-module drain balancing and adds a cheap pistol to the comparison. [C351 comparison and proposed drain choices](BATTERY_BALANCE_C349.md#c351--siphon-selected-head-versus-module-comparison-2026-10-19) recommends adjusting firearms/Scrapshot costs first, leaving existing rarity surcharges and Ballista intact. No drain increase selected yet.

## C349 — Saved M4 baseline; chance discussion reopened (2026-10-19)

Owner considers 75%/1.5x, leans toward prior 1B and asks for current-save drain without Siphon/Regulator. [Read-only audit, calculations and comparison choices](BATTERY_BALANCE_C349.md) finds approximately 0.00943% per firing cycle, 10,607 cycles from full, and 60–61 real unpaused minutes including normal reload/chambering under continuous-fire assumptions (about 16 game hours at the save's 90-minute day). This is calculated, not a measured endurance run or remaining-runtime claim.

75%/1.5x returns 112.5% on average at one eligible kill per paid cycle; exact first-module break-even requires 50%/2x or 66 2/3%/1.5x under the same kill assumption. Recommend new **1A 45%/2x**, **1B 50%/2x** for theoretical break-even, or **1C retain earlier 60%/2x**. Preserve +1x per extra module. Latest discussion reopens chance; no new value is selected or implemented. Owner's “looking at 1B” is a preference, not final selection. Current installed Siphon is still the earlier guaranteed eligible-kill refund.

## C348 — Siphon proc chance and sustain balance (2026-10-19)

Owner requests a **60% proc chance** so Siphon sometimes fails, with one module extending battery life and stacked modules capable of sustaining charge. Record the chance as selected for the pending patch; no gameplay change is installed yet.

Source audit: `TurretStats` assigns N+1 refund multiplier for N installed Siphons. `TurretSiphon.hit` currently claims each eligible killed actor once and `settle` refunds the originating shot's actual turret-local battery debit times that multiplier per eligible kill. Secondary kills require Synergy. Keep exact-source/generation checks, no Controller/grid refund, Legendary rarity and loaded loot weight 3 unchanged.

Recommended chance semantics: one authoritative 60% roll per eligible kill, shared by the installed Siphon stack; stacking increases refund amount, not probability. Claim the kill even when the roll fails so duplicate callbacks cannot reroll. Retain Synergy eligibility and exact-source checks.

Balance finding: retaining the current 2x first-module multiplier yields 0.6 * 2 = 1.2 times the shot's cost returned on average at one eligible kill per shot. Thus chance alone does not ensure one module is battery-negative. Multiple eligible kills can increase returns further.

**1A (recommended):** keep selected 60% chance, reduce first-module refund to 1x and retain +1x for each additional module. One/two/three modules return 60%/120%/180% of shot cost on average at one eligible kill per shot. This supports the intended stacking threshold but is not a strict guarantee against single-module sustain during multi-kills. No unrequested per-shot refund cap.

**1B:** change only chance to 60%, preserving 2x/+1x. One module can already sustain under efficient killing; owner accepts that tradeoff.

Multiplier choice remains pending; do not implement 1A as approved. Future implementation needs deterministic success/failure/boundary, duplicate callback, stack, secondary eligibility, exact source and rotary-pass coverage, plus updated player-facing descriptions. Installed 0.2.57.2 remains unchanged.

## C343 - Compact category options (2026-10-19)

Owner rejects the earlier seven-category suggestion as too fragmented and requests tighter options: combine direct numerical upgrades (Critical, Velocity, Magazine, Accuracy, Range, etc.) and include 360/Filter with Automation. This is category discussion, not approval to implement sorting, alter slots or change gameplay.

- **1A - Four categories (recommended):** Stats, Automation, Effects, Utility.
  - Stats: Critical, Velocity, Magazine, Accuracy, Range, Rapid-Fire, Reload, Autoloader, Suppression, Regulator, Conservation. These directly improve performance/resource numbers; Autoloader is the zero-reload endpoint and Conservation improves ammunition efficiency.
  - Automation: Firing and Detection (normal, Makeshift and Enhanced variants), 360, Filter.
  - Effects: Splitter, Fragment, Piercing, Initial Blow, Execute, Impact, Martyrdom, Tack, Synergy. These introduce attack behavior or conditional benefits rather than simply changing a baseline stat.
  - Utility: Grid, Siphon, Void, Lure. These provide power supply/recovery, special ammunition storage or attraction. Siphon has a kill trigger but is placed by its power-management purpose.
- **1B - Three categories:** Stats, Automation, Special. Keep Stats/Automation as above and merge Effects/Utility into Special. Fewer groups, but the last group becomes broader and less descriptive.

Naming alternatives: Turret Stats or Performance for Stats; Control for Automation; Special Effects for Effects. Expansion Kits remain in their dedicated expansion socket/family; a Module Pack is a reward container, not an installable module. Category membership does not imply every turret head accepts every module.

No option is selected. Preserve installed 0.2.57.1, saved module ordering and the separately settled C342 layout choices. Source tooltip/catalog inspection supports this classification; no runtime test or implementation is claimed.

**C337 selection (2026-10-19):** Grid Module enables mains and generator supply and is Mythic. [Contract and remaining loot-weight confirmation](checkpoints/R4C2_POKE_FLOOR.md#c337--grid-module-mythic-rarity-selected-2026-10-19). C338 confirms weight 1 and automatic inheritance of assigned rarity weights, with owner LootLab overrides taking precedence. Planning only.

**C336 planning update (2026-10-19):** [Optional Grid Module proposal](checkpoints/R4C2_POKE_FLOOR.md#c336--grid-module-proposal-2026-10-19) would make mains/generator access an upgrade for otherwise battery-powered turrets. One ordinary slot, nonstackable, no charging; supply scope and rarity/loaded loot weight remain owner decisions. Not implemented.

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
