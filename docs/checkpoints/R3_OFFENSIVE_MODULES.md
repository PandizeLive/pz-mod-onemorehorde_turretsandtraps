# R3C4-R3C7: offensive modules and battery endurance

Planning record under [C81](../DECISIONS.md#c81-offensive-module-planning-and-long-battery-life-2026-10-06), synchronized 2026-10-10 under C125. Installed 0.2.38.1 retains SP-only combat and adds R3C8 starter components; none of this brief's offensive modules is implemented. Final recipes, art and unselected heads retain their approval gates. See [canonical roadmap status](../ROADMAP.md#current-checkpoint-status-and-next-work).

**Next module checkpoint: R3C4 contract and battery baseline.** The documented sequence remains R3C4 -> R3C5 -> R3C6 -> R3C7; it does not require a new head first. The assistant's later suggestion to prioritize Initial Blow/Execute was an unapproved reorder, not missing scope: both were already listed in R3C6. This sync records the distinction without selecting a new gameplay patch.

## Owner direction and working proposals

| Module | Owner direction / discussed role | Remaining decisions and recommendation |
| --- | --- | --- |
| Splitter | One child per stack at 50% original damage; alternate sides for odd stacks, paired sides for even stacks, increasing angles in 15-degree steps | Retain central shot; C126 selects slot-limited stacking, superseding the proposed four-stack cap. Additional round per child remains undecided while a Magazine module is discussed. Define coverage edge, range, pellet budget and persistence before implementation |
| Fragment Module | Five random radial shots from impacted zombie, 20% original damage each; preferred minimum spacing 30 or 45 degrees | Recommend 30 degrees, including wraparound. Recommend one burst at the primary shot's first successful impact per firing cycle, terminal children, exclude origin victim; C126 selects fixed five fragments with capped per-fragment damage stacking. Angle, range, stacking increment/cap and propagation remain unselected |
| Impact | First bullet of a magazine has a high chance to stumble | Prove actual stumble separately from knockdown. Recommend stacks improve chance, one eligible primary victim, per-victim recovery guard, entitlement stored on head and rearmed by empty reload. Partial reload, chamber, one-round head and expiry rules need concrete agreement |
| Piercing | Discussed lane damage across aligned targets; retained in broadly approved direction | Recommend stackable penetration count, damage attenuation, no wall piercing, deduplicated victims and bounded ordered path checks. Numbers and compatible heads remain proposals |
| Initial Blow | Discussed damage bonus against healthy targets; retained in broadly approved direction | Recommend current-health threshold rather than permanent first-hit history; stackable capped bonus. Threshold/max-health source and interaction order remain proposals |
| Execute | Discussed damage bonus against wounded targets; retained in broadly approved direction | Recommend stackable capped damage rather than unconditional death. Threshold and modifier order remain proposals |

Homing, Bleed and slowing turret effects are excluded. Puddle/tack-bullet damage areas are not scheduled. A spike-canister ground trap is deferred. No rule here replaces existing potato splash, Velocity knockdown or Suppression's approved no-separate-count-cap policy. Explain module incompatibility rather than installing inert items.

Splitter example, excluding unchanged central shot:

| Stacks | Child directions |
| --- | --- |
| 1 | Alternate -15 / +15 degrees |
| 2 | -15 and +15 degrees |
| 3 | Both 15-degree sides plus alternating -30 / +30 degrees |
| 4 | Both 15-degree and both 30-degree sides |

Further pairs continue in 15-degree steps if a larger cap is selected. All children retain the owner's 50% damage direction; do not compound a new 50% reduction for each additional stack. A shotgun branch must have a defined whole-shot damage budget rather than multiplying damage per pellet.

## Battery endurance is a requirement, not a surcharge afterthought

Owner requires module intensity/impact to increase usage while preserving long battery life, rather than draining a battery in a single normal day of use. Exact days/nights and workload have not been selected. Recommend multi-day ordinary operation, with idle/search draw absent or negligible unless a useful separate cost is demonstrated. Sustained maximum-rate firing must be reported separately, not presented as normal usage or guaranteed multi-day endurance.

Current source reference: `sandbox-options.txt` sets PotatoBatteryPercentPerShot to 0.1; `TurretWorld.power` resolves the per-shot fraction and the shot commit subtracts it. This gives approximately 1,000 firing cycles per full battery at that default before new effects, not a measured days-of-life figure. Existing firing consumes real active time, not game-clock-scaled cadence. Saved settings may differ.

R3C4 must measure baseline and agree representative workloads: actual head/cadence, module loadout, firing cycles per horde, idle time, game-day length and starting charge. Propose an endurance target from those figures; do not invent a universal day-to-shot conversion. Compute base drain from desired total cycles, then modest capped effect surcharges; account for increased cadence and multiplicative combinations as well as individual module counts. Do not stack surcharges on today's baseline without recalibration.

Recommend a predictable resolved per-cycle cost charged with ammunition before launch, independent of successful victims; insufficient resources reject the whole firing cycle without partial consumption or free children. Snapshot effects at launch. Validate generator/external-power behavior as well as battery fallback; it is not yet an approved new fuel balance. Preserve saved tuning and document any deliberate migration rather than changing key semantics silently. Manage should make increased cost understandable; do not display a misleading days-remaining estimate without a workload.

## Checkpoints and acceptance

The related [R3C8 starter-component/expansion checkpoint](R3C8_IMPROVISED_EXPANSION.md) is implemented and installed in 0.2.34. C104 independently settles its recipes, two-row eight-column layout, 2/4/8/12/16 fresh totals and saved-setting/item preservation. Those are no longer R3C4 decisions; offensive effect contracts and realistic endurance targets still are. Include the expanded maximum loadouts in R3C7. Empty slots add no battery cost. R3C8 owner acceptance remains in the combined 0.2.34 test.

1. **R3C4 - contract and baseline.** Settle range, compatible heads, stack/target limits, damage ordering, Fragment separation/propagation, Splitter ammunition and Impact reload eligibility. Define source IDs and one damage/death route, no global weapon overrides or mutable zombie speed. Baseline current battery use and agree endurance target before gameplay tuning.
2. **R3C5 - directional children.** Prove geometric rays/ordered candidates against installed game behavior before content. Then implement Splitter and Fragment separately on shared bounded work. Check misses, walls/windows/corners, loaded areas, coverage/collateral, origin-victim exclusion, angular minimum including 360-degree seam, exactly five Fragment rays and saved odd-stack alternation. Persist serializable state; do not let swapping a head replay an entitlement. Agree what happens to committed pending effects on save/unload.
3. **R3C6 - penetration and conditional hits.** Implement each agreed effect in a small slice. Check first-round/chamber/partial reload and single-round edge cases, recovery guard, HP thresholds and native stumble feasibility. Do not silently substitute full knockdown or alter Horde Night zombie movement. Native/custom armor and weapon-script integrations require explicit evidence; metadata admission is not proof of custom hit semantics.
4. **R3C7 - combined acceptance.** Measure no-module, representative and maximum-supported combinations, including rapid-fire firearms, pellet weapons and potato heads where compatible. Compare charge per horde and cycles per battery under defined workloads; normal use must meet the agreed long-life target. Verify refunds/rejections, save/pickup/reload, resources, actual slots, UI, loot/Sandbox, dense rendering plus combat cost, and traps-only absence. R5C1 still gates multiplayer.

Recommended propagation is deliberately finite: primary first impact may produce Fragment; later pierce hits and Splitter children do not; Fragment children cannot Fragment, Split or Pierce. Five paths each piercing three victims would otherwise permit 75 Fragment children from one cycle. Power pricing cannot replace hard work limits. Looser propagation requires a new measured scope decision.

No permanent speed/status mutation, free ammo, recursive child effects, invented sibling reward API or double-counted death. Keep targeting/authority shared with current combat, with separate presentation facts. Do not claim MP from the server-directory location. Native proofs and bounded tests precede one complete 4-8-step owner test per playable combined checkpoint; no player test is requested for these documentation changes.

## C125: module track selected; first contract choices (2026-10-10)

Owner answers "Modules" to R3C4 versus R3C1 selection. This selects module planning and baseline work, not the unconfirmed numerical proposals or gameplay implementation. New heads stay deferred; R3C4 -> R3C5 -> R3C6 -> R3C7 remains unchanged. No new owner gameplay test is required.

Preserve the recorded owner direction: Splitter side shots deal 50% original damage with 15-degree stepped angles; Fragment starts with five radial shots at 20% each. First discussion choices (all recommendations remain unapproved):

| Choice | A (recommended) | B | Tradeoff |
| --- | --- | --- | --- |
| 1. Splitter ammunition | One normal firing cycle's ammo, extra effect power cost | One additional round per side shot | A revises the earlier extra-round recommendation because it keeps single-shot heads usable without inventing extra magazine capacity or a reserve-feed bypass. Stronger damage per ammo needs explicit power/stack balance; no extra inventory rounds are created. B requires a separate magazine/reserve sourcing contract. |
| 2. Splitter limit | Four modules maximum, central shot plus four side shots | Slot-limited stacking | Four is a proposed limit, not an existing owner decision. It bounds projectile work and damage multiplication. More stacks require measured work limits. |
| 3. Fragment stacking | Keep five fragments; stacks increase damage to an agreed cap | Stacks increase fragment count | Fixed count is easier to bound and keeps sound/effect/collision work predictable; damage increment/cap remain undecided. |

Recommend the primary shot's first impact can trigger one Fragment burst; side shots/fragments cannot create further bursts. This interaction rule remains proposed. Recommend preserving standard-module loot acquisition and no new recipes in this first slice. Compatibility, shotgun whole-shot budgeting, side-shot range/coverage, fragment distance, damage increments/caps and numeric power/endurance targets still need a concrete contract after these foundational choices; no claim that three answers finish R3C4. Keep native firearm and potato special effects explicit. No battery benchmark was run for this discussion; measure defined firing workloads before claiming days or nights of endurance.
## C126: selected stacking and proposed Magazine module (2026-10-10)

Owner selects 2B (Splitter limited by available slots, not a separate four-module cap) and 3A (five fragments, stacks increase damage to a cap). The Fragment increment/cap remains undecided. Owner asks whether a Mag Size module could increase magazine capacity to make Splitter option B practical. This is a feasibility/design question, not unconditional approval of B or a new module implementation.

Read-only evidence: TurretStats.resolve uses configured PotatoMagazineCapacity for the custom head, but gun:getMaxAmmo() for firearms. TurretCycle.update supports variable custom capacity; its consume path currently spends one round. Firearms.update reloads to native gun capacity and Firearms.consume spends one shot; Firearms.transferMagazine recreates the native magazine with the gun's current round count. Installed B42 Lua ISEjectMagazine.complete and ISInsertMagazine.complete similarly transfer the native round count, while ISLoadBulletsInMagazine:isLoadFinished checks the magazine's own maximum. No native setMaxAmmo/persistence probe was performed. Changing a displayed stat alone cannot implement universal capacity; native gun/magazine round-trip and lifecycle safety remain proof work.

Recommendation for discussion: a stackable Magazine Module increases ready-to-fire capacity while installed, distinct from expansion-kit reserve storage. Proposed +2 rounds per module makes a one-round potato head hold three, enough for one central plus two paid side shots. This number is not approved. For firearms, recommend evaluating a turret-owned feed extension that preserves real round accounting and stock magazine capacity, rather than overfilling ejected magazines or changing global gun scripts. It must reload, persist, conserve ammunition on head/module removal, and display its ready rounds honestly; it must not silently bypass the native magazine requirement or make Autoloader grant extra capacity. Implementation/compatibility remains unproven. No separate recipe or loot change is approved.

Paid Splitter tradeoff: two side shots plus the central shot spend three rounds for at most twice the primary-shot damage before other effects. Larger capacity improves sustained volleys, not ammunition efficiency. Reload/top-up behavior with too few ready rounds must be settled: the current empty-only reload path would otherwise stall a full-volley rule with leftover rounds. Proposed safe service policy rejects capacity-module removal until excess ready rounds are unloaded; exact UI/refund handling remains open.

Slot-limited Splitter still needs a measured work budget, pellet budgeting and a declared fan/coverage rule: continuing 15-degree steps can put high-stack children outside the current forward cone. Do not silently restore the rejected four-stack cap. Fragment propagation remains proposed (primary first impact only; no recursive child bursts). These are R3C4 contract issues, not grounds for a new owner gameplay test or an already-approved patch.
## C127: linear percentage magazine growth and final rounding (2026-10-10)

Owner requests multiplying magazine capacity and rounding up, suggesting 25% per module with linear growth. This replaces the assistant's flat +2-per-module proposal as the active design direction. Interpret as effectiveCapacity = ceil(baseCapacity * (1 + 0.25 * activeMagazineModules)), computing once from the unmodified base magazine capacity. Do not compound 1.25 per stack, round per module, or repeatedly modify the previously resolved capacity. Percentage/round-up direction is owner-requested; 25% is the suggested working value, not an implementation approval. Keep any firearm chamber separate from base magazine capacity; the exact firearm/feed implementation remains native-proof work.

Checked examples for 0/1/2/4 modules: base 1 -> 1/2/2/2; base 4 -> 4/5/6/8; base 10 -> 10/13/15/20; base 15 -> 15/19/23/30. Base 1 first reaches capacity 3 at five modules. Rounding therefore creates plateaus: potato magazine modules 2-4 add no immediately usable capacity, and a paid central-plus-two-side-shot volley would require five Magazine modules at the default one-round base. This is a material slot-efficiency tradeoff, not a reason to silently add a minimum +1 per module (which would change the selected formula). Recommend the linear formula for consistent proportional scaling, with clear effective-capacity preview before installation.

C126's slot-limited Splitter and fixed-five/capped-damage Fragment choices stand. Paid Splitter ammunition remains open, as do capacity removal, leftover-round handling, compatibility, Fragment caps, and battery targets. A subsequent decision should settle reduced volleys versus topping up for a full volley; neither is approved here. No gameplay code, package, version or owner test changes. C108/C119 mirror applies.

## C128: minimum one-round magazine gain (2026-10-10)

C128: owner requires at least one added round per Magazine Module, explicitly base 1 plus two modules = 3. With the working linear 25% rate, use ceil(base + count * max(1, base * 0.25)), rounded once from the unmodified base. This supersedes C127 small-magazine plateaus. Examples for 1/2/3/4 modules: base 1 -> 2/3/4/5; base 7 -> 9/11/13/14; base 14 -> 18/21/25/28; base 30 -> 38/45/53/60; base 60 -> 75/90/105/120. No compounding or per-module rounding. Native capacity lifecycle, Splitter ammo rules and other R3C4 choices remain unresolved; no gameplay patch or test is authorized by this arithmetic clarification.

## C129: 35-percent magazine scaling and one-round ammo exception (2026-10-11)

Owner changes the magazine bonus to 35% per module, retaining linear growth, minimum +1 per module and final upward rounding. Confirmed design formula: ceil(base + count * max(1, base * 0.35)). This replaces the prior 25% value; no compounding or per-module rounding.

Owner also requests ignoring ammo-consumption rules when a weapon has only one round in the magazine because no additional rounds remain. Context indicates waiving Splitter's extra-round costs while still consuming the normal primary shot; do not interpret this as infinite ordinary shots. The eligibility needs clarification: A) effective magazine capacity is one after modules, or B) any weapon currently has only one loaded round remaining. Recommend A: B permits intentionally loading one round to obtain all Splitter children at single-round cost and reduces the value of magazine expansion. Neither interpretation is approved by this discussion. Under A, increasing effective capacity would remove the exception; confirm that consequence. Default paid-child costs are implied as the direction being discussed but the complete ammo contract remains unsettled. Behavior with two or more rounds insufficient for a full volley is also still open.

C126 slot-limited Splitter and fixed-five Fragment damage stacking stand. Native firearm capacity/servicing proof and other R3C4 rules remain pending. No code, package, version or new owner test. Mirror confirmed tuning and the unresolved question under C108/C119.