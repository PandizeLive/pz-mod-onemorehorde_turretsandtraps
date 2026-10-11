# R3C4-R3C7: offensive modules and battery endurance

Planning record under [C81](../DECISIONS.md#c81-offensive-module-planning-and-long-battery-life-2026-10-06), synchronized 2026-10-11 under C135. Installed 0.2.39 retains SP-only combat and R3C8 starter components; none of this brief's new modules is implemented. Magazine/Splitter/Fragment scope is selected; current Fragment tuning is below in C135. Final recipes, art and unselected heads retain their approval gates. See [canonical roadmap status](../ROADMAP.md#current-checkpoint-status-and-next-work).

**Next module checkpoint: R3C4 contract and battery baseline.** The documented sequence remains R3C4 -> R3C5 -> R3C6 -> R3C7; it does not require a new head first. The assistant's later suggestion to prioritize Initial Blow/Execute was an unapproved reorder, not missing scope: both were already listed in R3C6. This sync records the distinction without selecting a new gameplay patch.

## Owner direction and working proposals

| Module | Owner direction / discussed role | Remaining decisions and recommendation |
| --- | --- | --- |
| Splitter | One child per stack at 50% original damage; alternate sides for odd stacks, paired sides for even stacks, increasing angles in 15-degree steps | Retain central shot; C126 selects slot-limited stacking, superseding the proposed four-stack cap. C131 selects one additional round per child with total consumption capped by ready rounds; full volley still fires when at least one round remains. Define coverage edge, range, pellet budget and persistence before implementation |
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
## C130: any last loaded round gets the full Splitter volley (2026-10-11)

Owner selects B from C129's explicit alternatives. Any weapon with exactly one loaded round remaining may fire the full configured Splitter volley, consuming that primary round and waiving additional-round costs regardless of capacity or installed Magazine modules. The deliberate single-round-loading consequence was explained before selection and is accepted; do not silently restrict the rule to native single-shot heads, charge reserve ammunition for these children or add an anti-underloading restriction. Zero loaded rounds cannot fire. Eligibility should be evaluated before spending the primary shot, not midway through sequential consumption. Chamber-inclusive ready-round accounting still needs to be made explicit alongside native firearm proof.

Magazine design remains 35% linear, minimum +1 per module, final rounding. Slot-limited Splitter and fixed-five/capped-damage Fragment selections remain unchanged. No full patch approval or new owner test is inferred.

Remaining ammo case: two or more rounds remain but fewer than a complete volley costs. Recommend extending the selected behavior consistently: fire the full volley and consume all remaining ready rounds (ordinary cost is capped by available ready rounds). Example: four Splitters normally cost five rounds; with two left, fire five projectiles and consume two. This generalization is a proposal, not implied approval from B. Alternative: fire only affordable projectiles when two or more rounds remain, while retaining the explicitly approved one-round full-volley exception; that creates a discontinuity where one remaining round produces more projectiles than two. Reload-before-full-volley is another possible design but must handle capacity below volley cost without stalling. Ask the owner to settle this material difference before implementation.
## C131: full Splitter volley with capped loaded-ammo consumption (2026-10-11)

Owner selects A from the explicit insufficient-ammunition choice. With at least one ready round, fire the full configured Splitter volley and consume min(ready rounds, normal volley cost). For ordinary one-round primary ammunition, normal cost is 1 + Splitter count. Example with four Splitters: five ready rounds consumes five and fires five projectiles; two consumes two and fires five; one consumes one and fires five; zero cannot fire. C130's one-round exception is now part of this general rule. Do not reduce projectile count, pull the shortfall directly from reserve, wait for a full magazine solely to afford children, or grant free primary fire. Ordinary reload/cooldown/power/target validity still applies. Determine the cost from pre-volley ready ammunition and commit it together to prevent partial consumption/replayed effects. Native chamber/shotgun/nonstandard ammo-per-shot integration remains proof work, not an approved semantic shortcut.

The owner has accepted the ammunition-efficiency benefit of an underfilled volley; do not reopen it as an exploit veto or silently restrict it to base-capacity-one weapons. No new power price, damage multiplier or recursion rule is selected by A. Magazine growth remains linear 35% with minimum +1/module and final rounding. Splitter remains slot-limited; Fragment remains five projectiles with capped damage stacking. Remaining R3C4 decisions include Fragment increment/cap, range/coverage/propagation, compatibility and calibrated power/endurance. No gameplay implementation, version bump or owner test is authorized by this choice alone. C108/C119 mirror applies.

## C134: current module discussion and choices (2026-10-11)

The owner requests adding Magazine, then explicitly asks to check Splitter and discuss possible module rules this turn. Hold implementation for the remaining gameplay choices. Installed 0.2.39 paired Concertina is unchanged and its owner test can be combined with the selected module patch later. Do not infer that Fragment or later R3C6 effects were added to scope.

Confirmed rules retained: Magazine uses ceil(base + count * max(1, base * 0.35)); Splitter keeps the central shot, adds one side shot per installed copy at 50% primary damage, follows the agreed alternating/paired 15-degree pattern, and is slot-limited without an extra four-copy cap. A nonempty ready supply fires the full volley, spending min(ready rounds, 1 + splitterCount) for an ordinary one-round primary. No direct reserve charge for a shortfall. Deliberate underloading remains accepted.

Read-only code evidence: TurretStats.resolve obtains firearm magazine size from gun:getMaxAmmo; Firearms.update also reloads to that native maximum. Firearms.transferMagazine copies current gun rounds into the ejected native magazine. A stat-only bonus would neither reload correctly nor ensure safe ejection. FirearmCombat.hit resolves the selected target, with up to nine pellets divided over up to three targets; it has no angular Splitter path. Whole-shot budgeting is required to avoid multiplying a shotgun's full damage per pellet. TurretWorld.power charges the configured amount per firing cycle (default battery 0.1%, about 1,000 cycles); this is cycle count, not a multi-day endurance guarantee. No new native capacity proof was run in this discussion.

Recommend Magazine + Splitter first (R3C4/R3C5). Fragment is the next directional effect, but its damage increment/cap, radius and propagation remain unselected. Piercing, Initial Blow, Execute and Impact remain R3C6; do not silently reorder them.

| Choice | A (recommended) | B |
| --- | --- | --- |
| 1. Scope | Magazine + Splitter | Also include Fragment, after settling its remaining tuning |
| 2. Capacity shrink/removal | Automatically return excess loaded rounds to turret reserve; reject the service transaction if storage cannot safely accept them | Require the player to unload excess rounds first |
| 3. Splitter coverage | Fan follows aim and may extend outside the targeting cone; retain range/wall checks. Limit total fan to 180 degrees, compressing angle spacing at high stacks instead of wrapping behind or dropping shots | Keep every child inside the targeting cone; compress/shift the fan near the cone edge |
| 4. Side-shot effects | Direct damage only; no additional potato splash, crowd control or child-triggered module effects | Inherit compatible primary effects, with explicit nonrecursive limits and a larger performance test |
| 5. Extra power | +25% of the normal firing cost per Splitter copy; Magazine adds no idle/per-shot surcharge | +50% per Splitter copy; same Magazine policy |

Power proposal applies to battery and generator fuel; existing grid-power handling remains. With four Splitters, A costs twice the baseline per volley (about 500 default battery volleys), B three times (about 333). Neither numerical surcharge nor exemption is approved yet. Preserve long-life requirements and benchmark the selected workload.

Common proposed defaults: existing standard-module loot acquisition, no new crafting recipe in this slice, distinct loot/Sandbox controls and Modules presentation; magazine scaling excludes the separate native chamber, while ready-round spending counts chamber plus loaded feed. Normal gun/magazine capacity must be restored on ejection/removal, with real ammo conserved. Shotgun side damage uses 50% of the whole primary-shot budget per copy, not per pellet. One volley uses one firing/reload cadence and one firing sound, with side-shot visuals/impact cues bounded. These are proposed implementation contracts, not verified engine capabilities. Native save/reload/ejection, module/head swaps, supported firearm classes and maximum-slot work budgets require proof before shipping. Unsupported custom weapon mechanics must not be silently admitted as compatible.


## C135: selected module rules and remaining Fragment baseline (2026-10-11)

Owner selects C134 1B/2A-amended/3A/4A/5A. Planned scope now includes Magazine, Splitter and Fragment. Magazine growth and full-volley available-ammo spending remain C129-C131. Splitter uses the aim-relative fan outside targeting coverage, native obstruction/range checks, a maximum 180-degree total fan with compressed spacing at high counts, direct-only children and +25% base firing power per installed copy. Magazine has no surcharge. Do not re-ask these choices.

Capacity reduction returns each surplus round to turret reserve first, player inventory second, then the floor at the acting player's feet. C135 replaces rejecting removal merely because reserve is full. Preserve partial transfers and exactly-once ownership; never delete rounds when a recipient is unavailable. If the action has no valid actor or loaded destination at commit, keep its original ammo/state rather than committing a loss. Installed B42.21 shared/ActionManager.lua Actions.addOrDropItem implements inventory then floor on excess capacity; shared/TimedActions/ISCraftAction.lua complete uses it. That native helper does not implement reserve routing or transactional rollback. No new native runtime test was performed.

Fragment already has five radial shots per burst, initially 20% primary damage each, with fixed shot count and capped damage stacking (C81/C126). The owner selected adding it after remaining tuning is settled; the following is a new recommended baseline, not approved:

| Rule | Proposed baseline |
| --- | --- |
| Damage stacking | 20% of primary damage per fragment at one copy; +5 percentage points per additional copy; cap 40% at five copies. Display the cap; further copies have no damage benefit |
| Range | Four tiles from the impacted zombie, independent of Range modules, respecting walls; radial shots may leave the targeting cone |
| Angles | Five random directions, at least 30 degrees apart including the wraparound gap |
| Trigger | One burst at the primary shot's first successful zombie hit per volley, including a lethal hit; no burst on a miss or wall impact. Shotguns get one burst, not one per pellet |
| Victims/effects | Exclude the origin victim; each other zombie can take at most one fragment hit from that burst. Direct damage only; no splash, knockdown, splitting, piercing or recursive fragmentation |
| Resources | No additional ammunition. Add 25% of base firing power per installed Fragment copy; additive with Splitter, not compounded. Charge the configured firing cost once per volley, including missed primaries; no idle draw |

Use the primary shot's resolved damage budget, not damage actually lost by a nearly dead victim; share the volley critical multiplier, with no independent extra critical rolls. The potential extra damage budget is 100% of a primary at one copy or 200% at the cap, spread across up to five different victims and subject to misses/obstruction. This is crowd damage, not a guaranteed second hit on the original target. Battery power proposal: baseCost * (1 + .25 * splitterCount + .25 * fragmentCount); generator fuel uses the same multiplier, existing grid handling remains. Damage-capped surplus Fragment copies should be visibly unhelpful rather than concealed as a stat increase. All new Fragment numbers/trigger rules await owner settlement.

Retain the previously proposed loot-only first implementation, native chamber accounting, whole-shot shotgun damage budgeting and native capacity/ejection proof requirements. R3C4/R3C5 govern this selected slice; R3C6 and R3C7 retain their canonical order, and R3C6 effects are not included by 1B. No new gameplay version/install/test in this discussion. Combine the held paired-Concertina owner check with the eventual module patch.


## C136 - approved module patch (2026-10-11)

Owner: "Approved." This approves the complete C135 Fragment baseline alongside Magazine and Splitter, and authorizes implementation/verification/install. No further gameplay decision is required for this slice. [0.2.40 patch](../PATCH_v0.2.40.md) implements the selected rules; automated/native/package verification passes; tagged installation follows. [Combined test/evidence](../TEST_v0.2.40.md) includes the held paired-Concertina check. R3C4 contract is settled for this slice; R3C5 is implemented pending verification and rendered acceptance. R3C6 stays next for later discussion; R3C7 combined balance/endurance remains pending. Earlier open-choice paragraphs are historical and superseded by this approval.
