# R3C4-R3C7: offensive modules and battery endurance

Current work: **C145 / R3C6-R3C7**. See [global power/endurance proposal](#c145---global-module-power-model-and-endurance-proposal-2026-10-11). Owner selects a global module-count power rule with per-type multipliers, initially equal, and requests a recommendation/calculated endurance. Proposed defaults: 0.005% battery charge per firing cycle; +5% of base cost per installed module; all type weights 1; no battery idle draw; generator base 0.0001 native fuel units/cycle with the same multiplier. These numbers await approval and replace the old C144 A/B question. C144 combat foundations remain committed/tested but uninstalled; no gameplay changes in this calculation turn. C143 effect percentages remain approved. Installed 0.2.41/C138 unchanged.

**Current checkpoint: R3C6 implementation and R3C7 power-contract discussion.** R3C4/R3C5 current slice and owner round are complete. C144 authorizes proceeding and implements tested combat foundations; C145 requests global power redesign and calculated endurance before tuning. Numerical power defaults are proposals, not tested runtime behavior.

## Historical direction and early working proposals (superseded below)

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

The related [R3C8 starter-component/expansion checkpoint](R3C8_IMPROVISED_EXPANSION.md) is implemented and installed in 0.2.34. C104 independently settles its recipes, three-row 4/6/6 layout (later owner correction), 2/4/8/12/16 fresh totals and saved-setting/item preservation. Those are no longer R3C4 decisions; offensive effect contracts and realistic endurance targets still are. Include the expanded maximum loadouts in R3C7. Empty slots add no battery cost. R3C8 owner acceptance remains in the combined 0.2.34 test.

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

Owner: "Approved." This approves the complete C135 Fragment baseline alongside Magazine and Splitter, and authorizes implementation/verification/install. No further gameplay decision is required for this slice. [0.2.40 patch](../PATCH_v0.2.40.md) implements the selected rules; automated/native/package verification and tagged installation pass. [Combined test/evidence](../TEST_v0.2.40.md) includes the held paired-Concertina check. R3C4 contract is settled for this slice; R3C5 is implemented pending verification and rendered acceptance. R3C6 stays next for later discussion; R3C7 combined balance/endurance remains pending. Earlier open-choice paragraphs are historical and superseded by this approval.

## C137 current corrective/content extension - 0.2.41

The C136 Magazine/Splitter/Fragment rules remain settled. Enhanced Firing/Detection and the expansion/placement/visual corrections are implemented in [0.2.41](../PATCH_v0.2.41.md); [test](../TEST_v0.2.41.md) covers their remaining acceptance. Enhanced Firing replaces its normal role and scales default 75% firearm cadence to 100%, retaining bounded Rapid-Fire. Enhanced Detection replaces Detection, triples turning and requests 0.10-second scans. Both are loot-only, same weight/pools as Large Expansion. Makeshift/Small/Medium/Large add 100/200/400/650 ammo count, subject to native 50/100 weight limits. Grouped Splitter visuals preserve centered and side rays without changing direct-only damage. Native-derived cadence is turret-only; handheld gun timing is not modified. R3C5 acceptance remains open; R3C6 remains later discussion.

## C138 - requested owner round complete

Owner reports "Test Complete" for 0.2.41 with no new issue. No repeat required. [Console findings](../TEST_v0.2.41.md#c138---owner-test-complete-and-console-review-2026-10-11) distinguish observed configuration/firing from unreported individual checks. R3C6 remains next for discussion, not approved implementation; R1C3 retains the unattributed 331-ms update gap.

## C139 - R3C6 choices offered, not approved (2026-10-11)

Owner asks for choices and recommendations for Piercing, Initial Blow, Execute and Impact. This is planning only: installed 0.2.41, code, tests, item definitions and Workshop draft are unchanged. Inspected active f6ca54d, fetched origin; existing draft PR #1 is the only open PR. C138 closes the requested owner test round; no repeat is needed to discuss this stage.

| Choice | A - recommended starting balance | B - alternative |
| --- | --- | --- |
| 1. Piercing | One additional zombie per module, capped at three additional targets. Each successive hit retains 70% of the preceding damage: 100%, 70%, 49%, 34.3%. | Same one-extra-target/copy and attenuation, limited only by available slots. Stronger long-lane clearing but more collision work; global bounded scheduler still required. |
| 2. Initial Blow | At least 90% health before the hit: +25% primary direct damage/copy, capped at +100%. | Full health only: +50%/copy, capped at +150%; more burst, but incidental prior damage disables it. |
| 3. Execute | At or below 25% health before the hit: +25% primary direct damage/copy, capped at +100%. | At or below 15% health: +50%/copy, capped at +150%; stronger but narrower finishing window. Neither option kills unconditionally. |
| 4. Impact | First shot of each magazine: 60% stumble chance, +10 percentage points/copy after the first, capped at 90%. | Guaranteed first-shot stumble with one module; nonstacking. Predictable control but stronger on small magazines. |

The proposed Impact default spends eligibility when the first shot is fired, including a miss. Rearm only after all ready ammunition (including chamber/extension) was empty and a reload adds ammunition; partial top-ups do not rearm. Initial full load grants one entitlement; insertion/removal of modules, pickup, head swaps and save/reload must not reset a spent entitlement. Native one-round heads rearm each empty reload; propose a shared per-victim five-second guard across turrets after a successful stumble, with no effect on prone/getting-up zombies. Existing potato/Velocity knockdown takes precedence; never request both reactions on the same hit. This retains the owner's first-bullet direction. Actual standing stumble and lifecycle persistence still need native proof, not a knockDown substitute.

Recommended shared scope: Piercing on single-projectile firearms only in the first slice (no potato or multi-pellet shotgun penetration); Initial Blow/Execute/Impact on supported firearm and potato heads. A single firing cycle's primary damage is the only eligible source: Splitter children, fragments, later pierce hits and potato splash do not inherit these new conditional damage/reaction effects. Shotgun health eligibility is sampled per primary victim before that volley damages it, with bonus applied only to that victim's allocated whole-shot damage budget; Impact gets at most one eligible primary victim per magazine entitlement, not a roll per pellet. Damage bonus affects direct damage and ordinary critical multiplication; it does not increase the damage budgets of newly emitted secondary effects. Piercing adds no ammo cost for the same projectile, no range extension or solid-wall bypass, and no duplicate victim hits.

Initial Blow is a healthy-target bonus, not remembered first-hit history: repeated hits may qualify while the victim remains above threshold. Percentages must use a valid full-health reference for native/custom-toughness zombies. Existing Damage/FirearmCombat/TurretVolley paths expose current-health reads but do not establish a universal maximum-health adapter. Do not treat an already injured zombie's first observed HP as its full HP or assume 1.0. Health-source compatibility and native standing stumble are feasibility gates before implementation promises. Inspect current installed sources and prove them locally; no game test ran in this discussion.

Propose loot-only acquisition, Modules grouping, matching Sandbox/LootLab entries and rejecting extra copies beyond useful caps. Exact loot weights, extra firing-power prices and a representative long-battery-life workload remain a follow-up balance choice after these four behaviors are selected. Existing Splitter/Fragment +25%-per-copy power rules remain unchanged. Do not compound new costs onto the existing baseline without the documented endurance check; this choice set is not a complete patch approval.

## C140 - selected uncapped rules and revised Impact proposal (2026-10-11)

Owner selects 1B; custom Initial Blow (>=90% health, +25% damage per copy, no cap); custom Execute (instant death at <=7% HP, +7 percentage points of eligibility threshold per copy); and 4A while requesting a better approach to unlimited module stacking. Treat unlimited as no separate per-effect stack cap within available turret slots, not authorization for unlimited physical slots or removal of unrelated existing module caps. Current ordinary Large Expansion grants 16 total slots; Firing/Detection consume their normal slots. No patch approval; native feasibility, shared compatibility details and loot/power/endurance tuning remain open.

Confirmed selections supersede C139's lower caps/Execute damage-bonus proposals:

- Piercing: one extra aligned victim per copy, slot-limited; each successive hit retains 70% of preceding damage. Retain range, solid-wall, duplicate-victim and bounded processing constraints. No silent three-target cap.
- Initial Blow: target at >=90% full health before the primary hit; direct damage multiplier 1 + 0.25 * count, no separate bonus cap. Four copies give +100%, eight +200%, sixteen +400% (5x total). No first-hit history.
- Execute: count n gives threshold 7*n percent; a successful eligible primary hit kills, rather than only receiving bonus damage. Retain the previously offered before-hit health check unless owner changes it; do not implement an after-normal-damage check silently. Values: 1/4/8/14/15 copies -> 7/28/56/98/105%. Fifteen copies qualify a full-health victim; fourteen qualify any victim at <=98%. Normal Firing+Detection in sixteen slots leave at most fourteen Execute copies; manual configurations can devote fifteen or more. Preserve the requested linear rule; do not silently cap below full health or substitute diminishing thresholds. High-stack universal execution is an explicit consequence now raised, not a newly inferred exception or a duplicate approval gate.
- Proposed kill implementation: use the victim's actual remaining HP through the existing Damage.apply/death route, not a magic 9999 damage amount. Source review confirms that route records actual loss and handles death once; native integration/max-health classification still requires proof. A qualifying Execute supersedes damage bonus arithmetic and cannot create duplicate death/reward events. Misses cannot execute. Inherited child-effect exclusions remain proposed scope, not expanded execution chains.

Impact's first-shot, high-chance direction is selected; the old 90% chance cap and +10-point linear progression are being reconsidered as explicitly requested. Recommend **60% for the first copy; each additional copy removes 25% of the remaining failure chance**. For n>=1: chance = 100 * (1 - 0.4 * 0.75^(n-1)); zero modules means zero. Examples: 1=60%, 2=70%, 4=83.125%, 8=94.6606445%, 16=99.4654616%. No separate copy cap; every extra module improves the mathematical chance, with diminishing practical benefit. Display rounding must not silently turn it into a guaranteed proc. Use one combined probability test, not multiple reaction calls. Finite engine precision still exists; 'unlimited' is slot-limited balance direction, not infinite computation.

Retain as proposed defaults: first fired shot spends eligibility even on a miss; empty-ready-supply reload rearms, partial top-up does not; no entitlement reset on module/head swaps, pickup or reload of the save. One-round heads can rearm every empty reload; five-second per-victim protection across turrets after successful stumble prevents repeated control. Do not extend stun duration, repeat reactions or replace standing stumble with knockdown. Existing knockdown takes priority. The revised Impact curve awaits owner selection.

Source review: Damage.apply reads current HP, removes supplied loss, routes death and emits actual damage; TurretStats still grants sixteen slots with ordinary Large Expansion. No native maximum-health or standing-stumble proof was run. Installed 0.2.41 and C138 completed owner test remain unchanged. Inspected 15e1414 and fetched origin; draft PR #1 only. Planning mirror under C119.


## C141 - slot-budget percentage proposal (2026-10-11)

Owner: "I want to try and utilize our module capacity as a balance. How can we set our percentages, as to not do 100% chances at 16?" This requests a new balance proposal, not approval of replacement values or a gameplay patch. Inspected 11f8b93, fetched origin and checked the only open development PR (#1). Installed 0.2.41 and C138 test completion remain unchanged.

Use the standard sixteen-slot Large Expansion budget to price specialization instead of imposing additional per-effect copy caps. Normal or Enhanced Firing and Detection each occupy one slot, leaving fourteen for effects before other utilities. Source TurretStats computes base capacity plus the largest expansion bonus; defaults are two plus fourteen. Sandbox supports larger values (each input up to twenty), so sixteen is the standard balance target, not a universal technical ceiling. Do not silently rescale bonuses by the currently installed expansion: upgrading should not weaken existing modules.

Revised recommendation, awaiting selection:

- Impact: retain the selected 60% first-copy chance, then add **2 percentage points per additional copy**. For n>=1, chance is 60 + 2*(n-1) percent; with zero copies it is zero. One combined roll on the eligible first shot, not extra rolls/reactions. At 1/4/8/14/16 copies: 60/66/74/86/90%. This replaces the offered diminishing curve only if selected; that curve reached 99.465% at sixteen and is too close to guaranteed for the owner's new objective. Keeping 60% first-copy benefit makes initial acquisition strong; further copies trade other capabilities for reliability.
- Execute: recommend reducing the selected **7 percentage points per copy to 3**. At 1/4/8/14/16 copies the proposed pre-hit HP eligibility threshold is 3/12/24/42/48%. This remains lethal on a successful qualifying primary hit; it is not a probability. Four points per copy would give 64% at sixteen; five would give 80%. Those alternatives increasingly replace normal damage rather than finish wounded targets. The C140 7-point selection remains current until the owner chooses a change.
- Initial Blow: retain +25% damage per copy against >=90%-HP targets, without a separate bonus cap. +400% at sixteen means 5x ordinary direct damage, not a 400% proc chance. Piercing's selected extra-target/70%-retention behavior is unchanged.

General arithmetic: a flat per-copy percentage must be less than 100/16 = 6.25 percentage points to stay below 100% at sixteen. A 60% first-copy curve must add less than (100-60)/15 = 2.6667 points for each later copy. The proposed numbers target normal capacity only: Impact reaches 100% at twenty-one copies; proposed Execute reaches full-health eligibility at thirty-four. Higher Sandbox capacities or future expansions require explicit retuning or a separately chosen asymptotic rule; do not claim these linear rules stay below 100% indefinitely. No physical slot change or unrelated module rebalance is approved.

Arithmetic checked for zero/one and representative counts; no gameplay test, code/version/install/Workshop change. Shared compatibility, native maximum-health/standing-stumble proof and loot/power/endurance tuning remain open under R3C6/R3C7. Decision needed: select the revised Impact/Execute values or an alternative; then continue unresolved contract work before patch approval.


## C142 - Execute base-plus-increment proposal (2026-10-11)

Owner: "If we're doing the impact thing, we should also apply it to Execute. Maybe we start at 10% +2% each time?" Record this as the latest owner proposal, recommended for adoption, not a gameplay implementation approval or a claim that both numerical curves have been conclusively approved. It replaces the assistant's preferred Execute proposal for discussion; C140 historical selection remains documented.

For n>=1 Execute copies, proposed pre-hit HP threshold = 10 + 2*(n-1) percent. Zero copies disables execution. The first copy supplies 10%, not 12%; each additional copy adds two percentage points. Successful primary hits at or below the threshold execute deterministically; this is not a 10%/etc random kill chance. Do not inherit Impact's first-shot restriction: only the base-plus-increment stacking pattern is shared. Retain previously documented child-effect exclusions and native health-source proof requirements.

| Copies | Execute HP threshold | Impact chance (C141 proposal) |
| --- | --- | --- |
| 1 | 10% | 60% |
| 2 | 12% | 62% |
| 4 | 16% | 66% |
| 8 | 24% | 74% |
| 14 | 36% | 86% |
| 16 | 40% | 90% |

Recommend this over the assistant's flat 3-point Execute proposal: first-copy threshold rises from 3% to 10%, both curves reach 24% at eight copies, and sixteen copies now reach 40% instead of 48%. The initial module is useful earlier while each extra copy offers a modest improvement for its slot cost. Actual added value still depends on whether ordinary damage would already kill the target. Standard automated loadouts with Firing/Detection leave fourteen slots before other utilities, giving at most 36% Execute or 86% Impact when dedicated to that effect. These maxima cannot be combined in the same loadout. Physical capacity remains unchanged; higher Sandbox capacities retain C141's explicit balance caveat (this Execute formula reaches 100% at forty-six copies).

Inspected 803d334; origin fetched and only active PR #1 checked. Arithmetic reviewed at zero/one and representative counts; no gameplay tests run. Installed 0.2.41/C138 test completion unchanged; no code, package, version, installation or Workshop edits. Decision needed: settle these proposed percentages, then remaining R3C6 compatibility/loot/power/native feasibility work; no new patch approval.


## C143 - Execute and Impact percentages approved (2026-10-11)

Owner: "Approved", directly answering "settle on Execute 10% +2 points and Impact 60% +2 points?" Both numerical progressions are now approved, superseding C140's Execute 7 points/copy and the unselected C140-C142 alternatives. No further confirmation of these values is needed.

- Execute: for n>=1, pre-hit HP eligibility threshold = 10 + 2*(n-1) percent. Zero copies disables the effect. At 1/2/4/8/14/16 copies: 10/12/16/24/36/40%. A successful eligible primary hit kills; this is an HP threshold, not a random chance. It does not acquire Impact's first-shot restriction.
- Impact: for n>=1, first-shot stumble chance = 60 + 2*(n-1) percent. Zero copies disables it. At 1/2/4/8/14/16 copies: 60/62/66/74/86/90%. One combined roll, not repeated reactions. Previously proposed detailed reload/rearm and recovery-protection rules remain separately tracked pending final contract settlement/native proof.
- Initial Blow remains >=90% pre-hit HP with +25% damage/copy, no separate bonus cap. Piercing remains one extra aligned victim/copy with 70% successive damage retention and slot-limited stacking.

Use standard sixteen-slot capacity as the balance target; Firing/Detection leave fourteen for other modules, and different effects compete for that same budget. No new physical slot limit, higher-Sandbox safety cap, expansion rescaling or unrelated module rebalance is silently approved. Retain C141/C142 caveats for custom larger capacities.

Scope: numerical behavior approval only. Remaining head/secondary-effect compatibility details, native maximum-health/standing-stumble feasibility, acquisition weights, power pricing and endurance validation remain open under R3C6/R3C7. No gameplay code, version, install, test result or Workshop change in this approval-record update; installed 0.2.41 and C138 completed owner round unchanged. Inspected 50c3220, fetched origin and confirmed active draft PR #1; C119 approval record mirrored to GitHub.


## C144 - approved implementation progress and power choice (2026-10-11)

Owner: "Approved", after C143 recorded settled percentages and named remaining compatibility/loot/power work. Proceed with the module implementation using the previously offered compatible-head/primary-effect scope; do not repeatedly reconfirm C143. The prior handoff did not actually supply numerical loot/power defaults, so those values must not be misrepresented as individually approved. Asked one concrete asynchronous question: loot-only at Splitter/Fragment weight 2.5, with either slots alone (recommended to match owner's balance direction) or +25% base firing power per installed new-module copy. The question remains unanswered; no elapsed-time approval is inferred.

Completed independent implementation in canonical Source, not installed:

- Initial Blow/Execute compute health eligibility before primary damage; shotgun victims retain the same eligibility for their allocated pellet damage. Execute supplies actual remaining HP to the existing damage/death route. Unknown baselines grant neither conditional effect. Existing Splitter, Fragment and splash budgets do not inherit these bonuses.
- Impact first-shot entitlement is stored on the exact head cycle, consumed on a committed shot even on a miss, and rearmed after the complete ready supply was empty and then loaded. Partial top-ups and save roundtrips preserve spent state. Existing potato/Velocity knockdown wins; native standing stagger uses a five-second shared victim guard and excludes prone/getting-up/staggering victims.
- Piercing extends the first successful single-projectile firearm primary along its existing line, with one extra successful victim/copy and 70% successive ordinary damage retention. One incremental reserved ray handles the chain; it stays inside existing 256-entry/128-step/one-ms scheduler budgets, respects walls/range and deduplicates victims. No additional ammunition, child effects or knockdown. Actual native head integration still needs complete-patch verification.

Evidence: real 42.21 object probe in diagnostics/r3c6-native/server-write.log passed creation-baseline preservation after wounding, Horde Night's explicit baseline preference, unknown baseline remaining zero, and Lua-exposed setStaggerBack/isStaggerBack without floor/knockdown/health mutation. Current installed-JAR bytecode confirms native stagger duration is bounded and its exit clears the stagger flag; actiongroup XML transitions to standing stagger and back to idle on timer expiry. This is API/state evidence, not rendered animation acceptance. The probe used existing 0.2.41 packages plus test instrumentation; it does not certify the later new combat integration.

5,155 Kahlua assertions pass, including 72 additional checks for chosen curves, fixed shotgun eligibility, threshold boundaries, single death, unknown/Horde baselines, save/reload entitlement, guard/knockdown precedence, bounded two-victim piercing with 70%/49% damage and solid-edge blocking. World/player objects in this suite are doubles. Existing 23 packet checks pass. These results do not claim a full 0.2.42 patch or package install. Reviewed evidence is diagnostics/r3c6-native/checkpoint.json; raw probe logs remain local.

Remaining: answer the offered power choice; finish visible item registrations/tooltips, supported-head feedback, sorted Sandbox entries, native loot/LootLab catalog, complete native/full-package tests, versioned release docs, cumulative Workshop draft, tag and local installation. Existing 0.2.41 packages/install/test tag remain unchanged; Source is ahead of generated Contents at this development checkpoint. No new owner test is requested. Source changes exclude the old immutable test tag from this mirror as intended. Inspected 23f3fe7 and fetched origin; existing draft PR #1 remains the handoff.


## C145 - global module power model and endurance proposal (2026-10-11)

Owner: "Let's create a global rule for power consumption based on module count. We can have a value that multiplies the power consumption for certain modules, but we'll start with all being the same. What's your recommendation for power? Calculate how long it'd last based on hordes, or idle time, etc."

Confirmed direction: one count-based rule across modules, with per-type weights initially equal. This supersedes the unanswered C144 slots-only versus 25%-per-new-copy choice; do not ask that old question again. The owner requests numerical recommendations, not immediate implementation of an unpresented endurance target. C143 offensive percentages remain settled. No source/gameplay changes in this turn.

### Proposed rule and default values, awaiting selection

`firing cost = base firing cost * (1 + module surcharge * sum(physical module copies * type weight))`

- Global module surcharge: **5% of base cost per copy**, additive. Every type's weight starts at **1.0**. A future weight 2 contributes +10% of base per copy rather than doubling the whole turret cost. No exponential compounding and no separate module-count cap beyond actual capacity. This replaces, rather than stacks with, existing Splitter/Fragment 25% surcharges; Magazine and utility modules join the same ordinary-slot rule.
- Count each non-broken physical item occupying an ordinary module slot once, including Firing/Detection and Enhanced replacements. Do not sum the aliased `active` keys: Enhanced/Improvised items also populate their normal role keys and would be double-counted. Count copies even when their conditional damage does not trigger that shot. Empty slots, heads, batteries and the separate Expansion Kit socket do not contribute. Expansion is a storage/capacity kit rather than an ordinary-slot module; this is an explicit proposed scope detail.
- Start with one global Sandbox surcharge control and a per-type weight table for later tuning; avoid twenty identical new sliders. Keep base battery/fuel controls in the Power section and show actual resolved cost in Manage. Reuse the existing inventory summary and committed-shot transaction; no extra per-tick scans or damage-hit billing.
- Base battery cost: **0.005% of full charge per firing cycle**, down from current 0.1%. This deliberately changes the zero-module allowance from about 1,000 to 20,000 cycles to satisfy long-life direction before charging all modules. At sixteen modules the cost is 0.009% and budget about 11,111 cycles. The comparison is battery capacity, not ammo capacity or a guarantee of multi-day continuous fire.
- Battery idle/search/turning/reload draw: **zero**, matching existing behavior. Off, paused and offline do not spend charge. Charge once per committed primary firing cycle, including a miss; Splitter children/Fragment rays/pierced victims do not create separate bills. No-target attempts, failed commits and empty clicks are not firing cycles.
- Generator base extra cost: **0.0001 native fuel units/cycle**, down from current 0.001, with the same module multiplier. Full native tank is 10 fuel units. This yields five full-battery equivalents in turret firing alone before native idle/appliance usage; it does not replace native generator fuel consumption or condition loss. Preserve existing mains-grid priority/no battery charge while grid-powered and battery fallback behavior.
- Existing saved base/Sandbox choices must not be silently reset. New defaults and retirement/replacement of the old SplitterPower/FragmentPower controls need a clear implementation/migration note; apply the proposed balance explicitly in the eventual owner test rather than assuming saved 0.1 values became 0.005.

### Calculated battery budget

Full battery, proposed defaults, all type weights 1; whole firing cycles rounded down. These are Decimal arithmetic estimates, not a benchmark or an owner playtest.

| Occupied module slots | Cost multiplier | Battery per cycle | Cycles/full battery |
| --- | --- | --- | --- |
| 0 | 1.00x | 0.0050% | 20,000 |
| 2 | 1.10x | 0.0055% | 18,181 |
| 4 | 1.20x | 0.0060% | 16,666 |
| 8 | 1.40x | 0.0070% | 14,285 |
| 12 | 1.60x | 0.0080% | 12,500 |
| 16 | 1.80x | 0.0090% | 11,111 |

### Illustrative hordes

One turret, sixteen ordinary-slot modules, full charge, average **three committed firing cycles per zombie killed**, including misses. Hordes are illustrative sizes, not claims about the owner's Horde Night configuration. Ammo is replenished as needed. Secondary effects can reduce required cycles; tougher targets or poor accuracy can increase them. Values in the hordes column are fractional equivalent workload, not a count of fully completed waves.

| Zombies/horde | Firing cycles | Battery used | Equivalent hordes/battery | Extra generator tank used |
| --- | --- | --- | --- | --- |
| 100 | 300 | 2.7% | 37.0 | 0.54% |
| 300 | 900 | 8.1% | 12.3 | 1.62% |
| 500 | 1,500 | 13.5% | 7.4 | 2.70% |
| 1,000 | 3,000 | 27.0% | 3.7 | 5.40% |

At six cycles per kill, double usage and halve equivalent horde counts. A 500-zombie workload then uses 27% battery (about 3.7 equivalent hordes); at three cycles it uses 13.5% (about 7.4). With one such horde per day and no other firing, those are approximately 3.7 or 7.4 days; a different event schedule changes calendar life. Several turrets sharing the same kill workload split total cycles and individual battery use, but overkill/concurrent wasted shots are not assumed away.

### Continuous fire, standby and generator time

At sixteen modules: about 6h10m of actual firing time at 0.5 cycles/s (default two-second potato cadence); 3h05m at 1/s; 54m52s at 3.375/s; 41m09s at 4.5/s (the configured Enhanced M4/M16 baseline before Rapid-Fire). These are real-time cycle-rate models, excluding reload, aiming, target gaps and pauses; those extend elapsed wall time at the same firing count. Rapid-Fire/higher supported cadence shortens it. Do not treat these configured rates as a measured sustained rate or default game hours. At 10% firing duty and 4.5/s while firing, wall time would be about 6h51m because idle costs no battery charge.

Battery standby is indefinite from turret drain alone at zero idle draw. Native generator standby is different: installed 42.21 code uses 0.02 native fuel units per game hour at GeneratorFuelConsumption=1 before appliances. A 10-unit tank has a fuel-only zero-appliance ceiling of 500 game hours (20.8 game days), subject to condition/maintenance. Baseline idle burns 4.8% of the tank per game day. Under the illustrative daily 500-zombie/three-cycle workload at sixteen modules, turret firing adds 2.7% per day, total 7.5%, or about 13.3 fuel-only game days with no other loads and maintained condition. Base-generator idle does not multiply with the number of turrets; only their shot costs add. DayLength changes conversion to real time; native time and firing time are distinct. A six-hour game-night example at native multiplier 1 adds 1.2% generator idle fuel plus that night's 2.7% firing, totaling 3.9%, before other appliances.

### Evidence and state

Read TurretWorld.power/commit, TurretStats.resolve, Turret.contents, Sandbox defaults and installed-JAR IsoGenerator bytecode. Current turret writes occur only at committed firing: battery getCurrentUsesFloat/setCurrentUsesFloat and generator getFuel/setFuel. Installed generator getMaxFuel returns 10, getFuelPercentage divides by 10 then multiplies by 100; base 0.02/hour and Sandbox multiplier are explicit. Do not mistake fuel units for percentage points. The local bytecode extract SHA-256 is 0692eba20931fc468e2ab452ea98834b37657c33710908ce15d3bc8159c76dd2. Arithmetic computed using Python Decimal from the written formula; no new gameplay test ran and prior native/Kahlua results are unchanged.

Inspected e3b7976, fetched origin and checked active draft PR #1. This is a planning/calculation update; C144 Source remains ahead of generated Contents. Item/loot/Sandbox/LootLab integration, complete native tests, release/version/tag and install still await completion. Installed 0.2.41 and completed C138 owner round unchanged. Decision needed: adopt or adjust the proposed 0.005% battery / 5%-per-copy / zero-idle / 0.0001-generator defaults and the stated counting scope, then finish the existing patch; no repeat approval of C143 effects.
