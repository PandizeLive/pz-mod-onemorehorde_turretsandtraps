# Decision register

## C97: held playtest, performance audit and wall/fence-backed barbs (2026-10-07)

Owner is away from the PC and holds the 0.2.30 gameplay test while continuing work. This is a deferral, not a pass or waiver. Owner says "approved. also confirm the new pipeline created with github" in response to the proposed performance audit plus barbed-attachment design. Scope is investigation/design and verification of the existing GitHub process; it does not request a new CI workflow, remote push, publication or gameplay installation.

Owner clarifies the barbed host as walls/fences, semi freestanding with a surface required behind it. This replaces the suggested first window/door-barricade host list. When asked about independent barb durability, owner selects "Share the supporting wall/fence health". Preserve the support's existing health pool, with no automatic repair or added HP. Do not silently substitute separate barb durability for hosts without usable health. Host eligibility, native attack/contact detection, damage, footprint, support-loss behavior and recipe/service choices still need proof or discussion. That answer settles health only, not the bundled proposed attack/removal behavior.

Owner then answers "crossing contact" to whether barbs damage zombies only attacking the support or also crossing a supported fence. Owner further specifies: "it should be time based. barbs will always be time based damage when in contact. like 10 damage every 2 seconds". All barb damage uses recurring timed contact, including contact during a crossing; it is not gated on thumps or limited to one hit per crossing. This supersedes the assistant's one-hit-per-crossing recommendation. Use 10 damage every two seconds as the owner's working tuning example, not a separately approved final balance value. Standing in actual contact also qualifies; merely standing nearby does not.

Owner answers "yes" to "should the first hit happen immediately?" Immediate first contact damage is confirmed. Recommend a shared per-zombie two-second interval that persists through brief exits/re-entry and adjacent sections; recheck contact at each hit and stop damage outside contact. Shared cooldown details, player injury and clock semantics still need settlement/native verification. No independent attack/crossing bonus hit or damage-over-time after leaving is implied. Shared support health remains unchanged.

See [audit results and recommendations](checkpoints/R1C3_PERFORMANCE_AUDIT_20261007.md) and [backed-barb design](checkpoints/R2C3_BACKED_BARBED_SECTIONS.md). Operation counts establish redundant calls, not the cause of client pauses. No gameplay code changed in this checkpoint.

## C96: private GitHub development and Cloud planning process (2026-10-07)

Owner approved: "Approved. Go ahead and create this process." This follows discussion of using the normal full repository like Trait Shop, with Cloud restricted to planning and the PC implementing/testing. Create the private PandizeLive/pz-mod-onemorehorde_turretsandtraps repository, preserve local history, use dev as the initial/default branch and short-lived planning/implementation branches, retain immutable test/v<version> build tags, and reserve main plus official v<version>/GitHub Releases for confirmed official Workshop publication. Initial repository configuration and history/test-tag push are authorized; no gameplay change or Workshop upload is included.

Use one shared set of existing planning documents, explicit proposal/approval/implementation/verification/publication status, and a current handoff. Cloud reads pushed code for context, saves planning changes through PRs into dev when requested, and identifies technical assumptions needing local verification. The local PC reconciles incoming plans before implementation and pushes updated evidence when authorized. No game-version bump or changelog reset follows from documentation-only changes. See [workflow](GITHUB_WORKFLOW.md).

Recorded 2026-09-25 from the current planning conversation. This document is authoritative for approval status, not proof that a feature exists.

## Owner-confirmed requirements

2026-09-25 implementation scope update: the owner requested several more checkpoints back to back before testing, within roughly twenty minutes. This authorizes batching P1C2-P1C4 prototype work while P1C1 player acceptance remains pending. It does not waive acceptance criteria or authorize sibling modifications/publication. See the [batch record](checkpoints/P1_BATCH_RECORD.md).

| ID | Requirement | Source |
| --- | --- | --- |
| C01 | One edition with Sandbox controls; C80 supersedes the single selectable-entry assumption with optional Turrets/Traps packages in one Workshop product. | Owner's single-edition instruction |
| C02 | Potato turret is cheap, quiet, and uses farmable potato ammunition. | Original content pitch |
| C03 | Aim for 3-5 successful direct hits against a reference zombie and higher knockdown chance. Base cadence is one shot per second, interpreted as real time for the prototype. | Original balance correction; latest explicit cadence instruction supersedes very slow firing |
| C04 | Potatoes pop on zombie impact and deal extremely low splash damage for satisfaction. | Latest annotation |
| C05 | Buttons provide a pulse. Pressure plates stay ON while pressed; laser sensors stay ON while blocked. | Owner's signal correction |
| C06 | Poke Floor means spikes extend, poke, and retract. Do not create a duplicate retractable-strip feature. | Owner's clarification |
| C07 | Defense XP is one reduced pool split across all faction members, subject to eligibility details still to decide. | Latest owner instruction |
| C08 | Include offline faction members through a toggle, default enabled. | Latest owner instruction |
| C09 | Follow Trait Shop's score-reduction approach rather than making separate editions/categories the intended product. | Owner's scoring direction |
| C10 | Put Cure defense simulation last. It is not a first-release dependency. | Latest annotation and request to formalize phases |
| C11 | Create local project documents, phases, checkpoints, and supporting folders/files now. | Latest explicit authorization |
| C12 | A control unit lets the player change targeting for an individual compatible defense or all compatible linked defenses, including players, other factions, or no one. Devices without smarts do not follow these filters. | Owner's control-unit clarification, narrowed by C13 |
| C13 | Objects without smarts ignore control-unit target filters. Passive hazards do not acquire faction recognition, immunity rules or remote disarming from a targeting selection. | Owner's passive-object clarification |
| C14 | Players automatically jump over bed spikes. Applies to players generally, not only the owning faction. | Owner's traversal instruction |
| C15 | Players cannot walk into the Spike Barrier. The earlier vault ban is superseded by C31; existing runtime remains non-vaultable until the prototype passes. | Owner's original barrier instruction and 2026-09-27 revision |
| C16 | The owner will source final art without AI. Do not create or influence aesthetic design through AI concept art, textures, styling or final assets. | Owner's art-sourcing instruction |
| C17 | Use a temporary white model made only of cubes for the technical turret work. | Explicit placeholder authorization |
| C18 | All gameplay defenses use native construction in the building menu, with a movable placement preview and rotation before confirming placement. The current context menu is developer testing only. | Owner's construction-flow clarification and explicit native-building-menu selection on 2026-09-26; runtime implementation remains pending |
| C19 | Potato hits should have a modest backward impact; prefer the native shove-style stumble-then-fall for successful knockdowns over a physics collapse. | Owner's 2026-09-26 reaction discussion/confirmation; implemented as a 0.1.5 prototype, visual acceptance pending |
| C21 | Spike Barriers occupy 1x2 tiles; the rear face is safe, with front and side-end damage for gameplay. Existing barriers expand only into clear space. | Owner correction after completed 0.1.5 test; width runs across the facing direction |
| C20 | Test Spike Barrier retaliation at 20 damage per actual thump. Do not replace strikes with a once-per-second contact tick. | Owner's 2026-09-26 tuning instruction; Pixel Indicator aids testing, damage units must be explicit |
| C22 | Spike Barrier bundles reduce the combined loose items' encumbrance by 67%. Bundle weight = sum of individual item weights x 0.33. | Owner's explicit 2026-09-26 selection; replaces the proposed 25% bundle reduction. Runtime implementation remains pending. |
| C23 | Schedule individual barrier inventory items and five-barrier bundles within Phase 2, alongside native construction. | Owner's approval to put the discussed feature in checkpoints and begin Phase 2; P2C1b/P2C1c cover implementation. |
| C24 | Basic Spike Barrier consumes four total planks and/or basic crafted wooden spears in any mix, including four spears, plus four binding units. No mandatory frame plank. | Owner's 2026-09-26 recipe discussion and correction allowing four spears. Bindings are ripped sheets, dirty ripped sheets and twine uses. Implemented in the 0.2.0.1 candidate; player acceptance pending. |
| C25 | Basic barrier requires Carpentry 1; reinforced upgrade requires Carpentry 3. Apply corresponding base crafting awards of 10 and 30 Carpentry XP. | Owner's progression correction and subsequent checkpoint approval. Basic recipe implemented in 0.2.0.1; reinforcement is scheduled at P2C2a. |
| C26 | Basic construction uses a retained sharp knife or cleaver. Reinforce an existing barrier using two additional planks, eight nails and a retained hammer; double maximum durability, preserve existing damage and deal 25 damage per thump. | Owner approved the proposed tool/upgrade recipe and corrected reinforced damage to 25 on 2026-09-26. At current basic health, reinforcement is 200 maximum health; preserve missing health rather than repairing for free. |
| C27 | Packing, unpacking and redeploying award no crafting XP. | Owner approved the proposal alongside the recipe checkpoint; first construction/crafting reward must not repeat through transport. |

| C28 | Combine the outstanding native persistence repair with P2C1b portable-item implementation. | Owner request on 2026-09-27; does not include P2C1c bundles or waive player acceptance. |
| C29 | Portable crafting uses the existing basic barrier ingredients, retained tool, Carpentry 1 and 10 base XP. Deploying the finished item consumes only that item and grants no XP. | Owner selected "Use the existing recipe and XP" on 2026-09-27. |

## Owner-proposed content and values

These belong in the design backlog; recording them is not a claim that they have been fully specified or are feasible on the current build.

| ID | Proposal | Remaining work |
| --- | --- | --- |
| O01 | Cheap punji using excavation/grave placement. | Independent stake-bed design versus original grave workflow; damage/catching behavior |
| O02 | Cheap cheval de frise that blocks paths and damages on thumps. | Current thump evidence, geometry, damage, durability |
| O03 | Concertina slows movement and deals damage over time. | Multiplayer movement feasibility and traffic wear |
| O04 | Barbed barricade shares its host's HP and deals damage on thumps. | Exact host types, attacked side, wire wear, and destruction lifecycle |
| O05 | Laser sensors connected to darts and poke floors. | Link UX, range, signal rules, cadence, and limits |
| O06 | Camera-assisted automated real-ammunition turrets; explosive turrets. | Acquisition, firing lanes, compatibility, effects, and collateral policy |
| O07 | 80% score reduction (remaining multiplier x0.20). | Confirm baseline; validate against longer survival; coordinated core/website support |
| O08 | In final-phase Cure simulation, allocate some attackers to defenses instead of the Cure. | Explicit core contract and conservative spatial approximation |
| O09 | Modular turrets with an inventory for motion detection, smart-fire, rapid-fire and velocity components. | Slot compatibility, costs, removal, persistence, authority and balance; see MODULAR_TURRETS.md |
| O10 | Individual barrier inventory items alongside native construction, plus a Spike Barrier Pack meaning a bundle of five items. | Now scheduled under C22/C23. Individual weights, recipes, acquisition and recovery of deployed devices remain to be specified. |

## Recommendations, not approved defaults

| ID | Recommendation | Reason |
| --- | --- | --- |
| R01 | Shared XP pool = 25% of the applicable ordinary kill reward. | Initial tuning point; owner has been asked to choose the rate |
| R02 | Splash cannot stagger/knock down; bound its total damage and affected targets. | Preserve the impact effect without turning massed turrets into area crowd control |
| R03 | Use a shared per-zombie knockdown recovery interval across devices. | Prevent several slow turrets from creating endless knockdown |
| R04 | Bind offline XP entitlements to the recipient's existing character life at earning time. | Preserve Trait Shop death resets; avoid free progression on a replacement life |
| R05 | Snapshot faction recipients when the kill occurs; retain earned entitlements after leaving, exclude future kills. | Prevent membership changes from recalculating or duplicating old shares |
| R06 | Exclude dead/uncreated lives and Horde casualties from new defense rewards; apply no distance/contribution requirement. | Match existing life/event integrity while including offline members |
| R07 | Initial noise device is an alarm, not an automatically triggered lure. | A tripwire/lure can create repeated distraction loops |
| R08 | Disabling a content type stops crafting and operation but preserves objects/resources for recovery. | Avoid destructive configuration changes |
| R09 | Freeze applicable score/configuration facts per event and retain affected-run history. | Prevent removing a mod or changing settings from erasing an earned advantage |
| R10 | Start with vanilla firearms and one ammo family; add third-party adapters separately. | Limit first-version compatibility scope |
| R11 | Use persistent device ownership to identify the reward faction; no mandatory geographic base registration. | Base boundaries were an assistant assumption, not a requirement of shared XP; add an area rule only if the owner asks for one |
| R12 | Support both material construction and deployment of one individual barrier item through the same placement/rotation validation and resulting 1x2 defense. Consume the chosen source exactly once on successful completion; cancellation consumes nothing. | Never charge both an individual barrier item and its raw materials. Recovering an existing device is a separate lifecycle feature and must preserve condition, supplies and installed components rather than reset them. |
| R13 | Start bundles with a pack/unpack recipe: five individual barrier items become one Spike Barrier Pack, and unpacking returns five individual items for placement. Apply C22's confirmed 67% reduction; individual item weights remain to be decided. | Matches native quantity-bundling patterns and avoids needing a partially consumed bundle system initially. Pack/unpack must not repair damaged items or refill supplies; either restrict eligible inputs or explicitly preserve each item's state. |

## Decisions needed before their dependent checkpoints

| ID | Question | Recommendation | Needed by |
| --- | --- | --- | --- |
| Q01 | What percentage of normal XP is the shared pool? | 25% initially; retain as proposed until answered | P3C2 |
| Q02 | Does offline XP survive death and transfer to a new life? Which members count as eligible? | Existing-life receipts; no dead/casualty/new-life transfer | P3C2 |
| Q03 | How is device ownership assigned/transferred, including solo ownership and faction disbanding? | Durable per-device solo/faction owner; no base boundary required | P2C1 / P3C2 |
| Q04 | How do smart-device modes treat unfactioned players, allies, splash and server PvP rules? Which devices have target-recognition capability? | Passive hazards are excluded by C13; define remaining target and collateral policy without PvP bypass assumptions | P2C2 / P4C1 |
| Q05 | Does the basic potato turret target on its own, use a fixed sensor lane, or require operation? | Prove fixed-lane shooting first; decide public behavior before recipes | P2C3 |
| Q06 | Punji grave workflow or a new shallow stake-bed object? | New stake bed with distinct servicing; retain original proposal until resolved | P2C2 |
| Q07 | When does using defenses mark a run for the score reduction? Can outsiders impose it? | Server-tracked benefit and ownership; no nearby-object inference | P3C1 |
| Q08 | Which content toggles default ON, especially firearms and explosives? | Core available content ON; advanced/explosive defaults decided at their checkpoint | P2C1 / P5C1 |
| Q09 | Exact recipes, skill gates, ranges, cadence, health, power, noise, slow, splash, and wear? | Tune after the corresponding prototype; use In-Game Time for autonomous systems | P2-P5 |

## Superseded ideas

- Multiple Survival/Engineering/Siege editions or presets as the distribution plan: superseded by C01.
- Every trigger behaving as a single pulse: superseded by C05.
- A separate retractable spike strip: superseded by C06.
- 6-10 direct hits as the potato reference target: superseded by C03.
- Connected-only defense XP as the default: superseded by C08.
- Treating Cure defense simulation as an early integration prerequisite: superseded by C10.
- A separate assisted leaderboard category as the preferred product: superseded by C09. Existing API limitations still require a coordinated implementation; this does not grant present official eligibility.
- Mandatory base registration as a shared-XP prerequisite: withdrawn; it was an assistant inference from 'at your faction's base'. Ownership can identify recipients without a geographic restriction.
- Zombie-only targeting as the intended final control policy: superseded by C12. Existing zombie behavior remains in scope; exact mode combinations and defaults still need specification.
- Applying controller immunity/disarming to passive stakes, wire and barriers: rejected by C13. Player traversal follows C14-C15 rather than faction filters.
- Very slow potato firing / the prototype's four in-game-minute cooldown: superseded by the owner's one-shot-per-second instruction.
- AI-assisted concept art, textures, icons or visual-design proposals: rejected by C16. Only the unstyled cube-only technical placeholder in C17 is authorized.

## Working terminology

Bed spikes / Spike Bed refers to the passive punji/stake-bed concept in this plan. Spike Barrier refers to the freestanding cheval de frise concept. Poke Floor remains the separate retractable spike mechanism. These map the owner's latest terms to the existing roster; final display names and item IDs are not yet locked.

## Current authorization

2026-09-26 Building-menu correction: the owner requests the corresponding native category plus a custom Turrets & Traps category. Keep Spike Barrier in Carpentry and expose the same recipe through a mod-only filter. The owner withdrew the custom requirement bypass because vanilla Build Cheat already covers testing. Approved ingredients, skills and XP remain unchanged.

2026-09-26 recipe checkpoint approval: the owner approved the retained cutting tool, reinforcement proposal and zero-XP transport rule, with reinforced retaliation increased to 25. C24-C27 close Q10. Implement the basic recipe in the 0.2.0.1 P2C1a follow-up; reinforcement remains scheduled at P2C2a. Existing saved barriers keep their current condition and damage; this recipe patch does not silently reinforce them.

2026-09-26 recipe correction: the owner objected that no recipe was requested before implementation and asked for a Cheval de Frise comparison. The v0.2.0 hammer/four-plank/eight-nail recipe was assistant-selected and remains unapproved test tuning. Review ingredients, tools, skill requirements and crafting XP with the owner before further recipe changes; see [installed B42 recipe comparison](RECIPE_COMPARISON.md). No runtime recipe was changed during this review.

2026-09-26 Phase 2 approval: the owner directs placing individual items/bundles in the phases/checkpoints and explicitly approves beginning Phase 2. P2C1a starts native construction; P2C1b covers individual items, P2C1c covers five-barrier bundles at the confirmed 67% reduction, and P2C1d covers servicing/ownership and multiplayer construction proof. Existing Phase 1 gaps remain tracked. Phase approval did not select a crafting recipe; the earlier interpretation allowing unilateral temporary recipe selection is withdrawn.

2026-09-26 construction follow-up: the owner requests continuing with the remaining Phase 1 tests pending and selects native construction in the building menu. Record that workflow as confirmed; Phase 1 acceptance gates remain open. The owner clarified that a pack means multiple individual items bundled together for reduced encumbrance, using five barriers as the example. This corrects the assistant's single-device kit interpretation; see O10/R12/R13. It does not approve loot/reward integrations. Installed B42.20.4 `media/scripts/generated/items/normal.txt` defines Log at Weight 9 and LogStacks4 at Weight 12; `media/scripts/generated/recipes/recipes_carpentry.txt` defines four-log stacking/unstacking. Native `recipes_packing.txt` also packs twelve Rope items (0.8 each) into RopeStack (8). These establish quantity bundles with reduced scripted weight, not implementation of our barrier items or construction integration.

2026-09-26 follow-up: the owner reports the patch is working well and requests Horde Night naming/process alignment, a safe rear face and 1x2 barriers. Version `0.1.6` implements these changes; see [checkpoint and test review](PHASE_1_CHECKPOINT_2.md) and [release process](RELEASE_TOOLS.md). Positive SP damage/reaction evidence does not certify MP or every animation edge case.

2026-09-26: the owner explicitly approved the shove/damage/retaliation patch after reviewing the completed test. Version `0.1.5-p1retaliation` implements the SP prototype described in [its record](checkpoints/P1_RETALIATION_RECORD.md). Damage units are actual native HP multiplied by 100 for readable balance numbers: barrier 20 = 0.20 HP, potato 50 = 0.50 HP. Pixel Indicator remains optional and its settings are preserved. Strike-marker scheduling/transition limits remain acceptance work rather than a claim that exact native per-strike synchronization is solved.

The test reports authorize repairing combat/visibility and changing base potato cadence. Version `0.1.4-p1combat` addresses those faults. The owner subsequently retained actual per-thump behavior at 20 damage rather than the offered periodic active-thumper approximation, and confirmed the shove-style reaction direction. Reliable per-strike retaliation remains unresolved. The [completed log review](checkpoints/P1_COMBAT_OWNER_REVIEW.md) records current evidence and Pixel Indicator's differing damage/percentage scales. Modular inventory remains an owner-proposed design, not authorization to implement the entire component system during a repair.

The owner additionally authorized temporary white directional-arrow textures and distinguishing developer markers on 2026-09-25. This is a technical testing exception to the final-art restriction. Version `0.1.3-p1markers` does not establish aesthetic direction.

Documentation and local project organization are completed in Phase 0. The subsequent owner-approved cube-only asset preparation is complete. The owner then approved the concrete P1C1 implementation scope, including the proposed package ID `OneMoreHorde_TurretsAndTraps`. Version `0.1.0-p1c1` implements the persistent test-device shell and local validation/installation tooling; see the [checkpoint record](checkpoints/P1C1_RECORD.md). Player-operated acceptance is pending. The owner subsequently authorized P1C2-P1C4 prototype batching and the `0.1.2-p1debug` repair/diagnostics pass. See their checkpoint records. Acceptance, later gameplay, integrations and publication remain pending.

## 0.2.1 provisional item tuning

One portable barrier weighs 6 encumbrance for testing. The owner was offered 6/8/10 and has not selected a weight; 6 is an implementation assumption, not a confirmed balance decision. If retained, a later five-item bundle weighs 9.9 under C22. Deployment accepts pristine items. C32 now explicitly returns full-condition items on pickup; the former condition-preservation proposal is superseded for basic barriers.

## 2026-09-27 menu and servicing approval

- C30: Add Turrets & Traps to Crafting as well as Building, keeping native categories. Use a wrapped purpose description and readable Damage 20 / Durability 100 / Size 1x2 statistics.
- C31: Owner requests player vaulting with a 1-in-5 scratch chance from the spike-facing front. Safe rear was included in the accepted follow-up. This replaces the earlier vault ban as design intent, but it is not implemented in 0.2.2. Whole-square collision versus native edge vaulting needs a bounded prototype; do not teleport players or silently enable zombie vaulting.
- C32: Combine basic-barrier pickup, repair and bundles. Pickup returns one full-condition item; preserving damage is explicitly not required. Owner approved **free repair; 10 seconds for both pickup and repair**, interrupted by movement. This intentionally permits full restoration for time alone. Zero XP remains C27. This exception applies to the basic barrier, not future turret ammunition/power or reinforced tier conversion.

Version 0.2.2 implements the menu correction, nearby condition display and C32 as a single SP test checkpoint. Bundles use five pristine loose items, weighing 9.9 with the current provisional individual weight 6. Existing recipe, cutting tool, skill and initial crafting XP remain unchanged. Final damaged visual stages remain an owner-sourced art proposal.

## 2026-09-27 barrier tuning and repair

- C33: Owner requests configurable basic Spike Barrier damage and HP, reducing default damage to **10**. 0.2.3 adds Damage (0-1000, default 10) and Maximum Durability (1-10000, default 100). Bounds and preserving remaining durability percentage on maximum changes are implementation choices. Free ten-second repair/pickup remain unchanged. Reinforced 25-damage design stays pending and is not silently retuned.
- 0.2.2 acceptance failed service load order, tooltip formatting and native destruction re-entry: [review](TEST_v0.2.2.md). Earlier basic 20-damage tuning/statistics are superseded by C33; historical evidence is retained. C31 vaulting remains unimplemented pending native proof.

## 2026-09-27 combined checkpoint testing

The owner authorized proceeding to the next checkpoint and testing it together with 0.2.3. C34 closes the collision choice; 0.2.3 remains unaccepted rather than retrospectively passed.

- C34: Owner selected **fence-style collision** for [P2C2-vault](PHASE_2_CHECKPOINT_2_VAULT.md), keeping the two-tile construction footprint and one shared durability pool. Version 0.2.4 implements native fence climbing through the Spike Barrier submenu, front 20 percent scratch / safe rear. Older built barriers retain full-square collision until pickup/redeployment. Debug-only placed prototypes remain legacy fixtures. No recipes, art or reinforcement changes are included.
- Implementation detail: one lower-leg environmental scratch after a completed front crossing. This is a flat roll without a clothing protection reroll; native wound severity/traits apply, and the scratch does not roll Knox infection. God Mode prevents injury. Interrupted/failed/removed/dead-player attempts do not roll. Normal fence-key integration is deferred; no generic zombie hopping flags are enabled.

## 2026-09-27 approved native-control correction

- C35: Use native Interact and Run/Sprint controls and player movement settings for Spike Barrier low-fence vaults. Preserve the native trip calculation; no high-wall animation or struggle mechanic. Player traversal must not enable zombie climbing. Scratch and trip are separate outcomes.
- C36: Repair remains tool-free, ten seconds, with label Repair and a short duration tooltip. Pickup remains ten seconds/full-condition. Use reachable approaches and cancel stalls.
- C37: Sandbox scratch denominator is integer 0-50, default 5. Zero disables spike scratches, one always scratches, N gives 1 in N; rear avoids spike scratches. Apply once at edge contact during traversal. Native fall risks still apply.
- C38: Separate General, per-defense and Debug Sandbox categories. Add a visible collision debug option. Use judgment to expose useful future balance controls (ammo, cadence, damage, radius, speed) as features are implemented. Prefer the shortest useful tooltip.
- Implementation: perpendicular native fence edges can share a corner tile with independent identity/HP. Parallel duplicate edges remain rejected. Existing spaced layouts are not automatically bridged with invisible extra collision. This corrects the overbroad former full-footprint overlap ban while preserving the 1x2 barrier.

[0.2.5 scope, source evidence and owner test](PHASE_2_CHECKPOINT_2_VAULT_REPAIR.md). Earlier C34 submenu-only and after-completion scratch implementation notes describe 0.2.4 and are superseded.

## 2026-09-27 failed collision test and clarified actor behavior

- C39: Zombie collision must cover the full occupied blocks. The owner asks whether separate centered player collision and diagonal connections can be implemented. Full-block zombie collision is confirmed intent; feasibility of the separate player shape is not confirmed. C34's shared edge implementation no longer satisfies the final requirement.
- [0.2.5 failed owner test](TEST_v0.2.5.md): displaced overlay, incomplete diagonal joins and inconsistent native-input traversal. 26 captured crossings include 25 incorrectly tracked as interrupted and only one contact. Independent client corrections are prepared as 0.2.5.1 source, not installed.
- [Collision feasibility checkpoint](PHASE_2_COLLISION_FEASIBILITY.md) records current engine limits. No custom Java dependency, global passability bypass, or replacement player physics is approved. Keep the independent fixes separate from geometry acceptance.

## 2026-09-27 approved connected outline

- C40: Owner supplied a front-and-end outline, explicitly allowed the rear to remain open, confirmed that connected runs should only cap their outermost ends, and approved implementation. This supersedes C39's full-block zombie / separate centered-player requirement. Both players and zombies use the same native cardinal outline; no custom diagonal physics or Java dependency is introduced.
- Every 1x2 item keeps its own identity, durability and recovery. Touching straight fronts and perpendicular front joins remove internal caps. Removing or destroying a section exposes and restores caps on surviving ends. Actual gaps are never bridged.
- Implementation: visible footprint parts are passable and non-thumpable; separately owned native edge objects supply the front and exposed caps. Retaliation applies on the outside of front/end edges, not their inward faces. Front vaults use C37; cap vaults have native trip risk but no additional spike scratch. Open rear permits ordinary entry.
- Existing edge-v1 construction migrates to the outline with its durability and ledger identity intact. The correct facing boundary changes some old layouts; barriers are not automatically moved. Legacy full-square test fixtures still require pickup/redeployment. Rendered migration/gameplay acceptance remains pending.

[0.2.6 checkpoint, current engine evidence and owner test](PHASE_2_CHECKPOINT_2_OUTLINE.md). The uninstalled 0.2.5.1 draft is folded into this feature version and is not a separate release.

## 2026-09-27 visibility follow-up

- C41: After the 0.2.6 test, the owner requires normal visibility through the barrier and requests the correction in the next checkpoint. Preserve collision, vaulting and zombie blocking; seeing through an open spike barrier is baseline behavior rather than an optional balance toggle.
- [Test evidence](TEST_v0.2.6.md) is partial, with four unsettled vault results and no completed repair/reload proof. [P2C2a](PHASE_2_CHECKPOINT_2A.md) queues the correction ahead of the already-approved reinforced upgrade. This update records scope; no gameplay patch was installed.

## 2026-09-27 P2C2a approval and reinforced servicing

- C42: Owner approves the P2C2a patch and explicitly selects the same free ten-second pickup/Repair and full-condition recovery for reinforced barriers, preserving their tier. Reinforced bundles contain five items of one tier only and use the same 67 percent weight reduction. This extends C32 to the reinforced tier; mixed-tier bundles are excluded.
- 0.2.7 implements C25/C26/C41/C42. Upgrade duration is ten seconds; inventory/carried-bag materials and usable retained hammer are required outside native Building Cheat. Cheat upgrades do not award XP. Reinforced item weight remains provisionally 6, pack 9.9, pending balance acceptance.
- See [checkpoint, current engine evidence and full test](PHASE_2_CHECKPOINT_2A.md). Native-entry timeout diagnosis remains open; no player test is retroactively marked complete.

## 2026-09-27 upgrade repair and item weights

- C43: Every upgrade also repairs the object. This supersedes C26's missing-health rule: a basic 70/100 barrier becomes reinforced 200/200 with default settings. Later Sandbox maximum changes still preserve remaining percentage.
- C44: Basic barrier weight is 4; reinforced weight is 5. Five-item same-tier packs retain the approved 67 percent reduction, weighing 6.6 and 8.25 respectively.
- The owner reports intermittent service reach warnings and asks whether native Install/Pickup is possible. 0.2.7.1 corrects the zero-distance collision check on arrival. A dedicated Moveables adapter is feasible in principle but remains proposed, not implemented or approved by this question.

## 2026-09-27 P2C2b approval and turret module corrections

- C45: Owner approves P2C2b: reliable right-click selection across both barrier parts/shared corners, full-object menu hover highlight, independent reinforced texture inputs with stable saved sprite IDs, and selection success/miss diagnostics. Native Install/Pickup is deferred. The owner reports reinforcement worked well and waives the separate 0.2.7.1 test round; this does not supply unobserved regression evidence.
- C46: Turrets use an inventory for ammunition and drag/drop module installation. Firing accepts FIRE signals; Motion Detection aims/follows eligible zombies and requests firing; Filter supplies Closest/Furthest/Weakest/Toughest priorities. Detection does not require literal movement. Add Capacity, Range and 360-degree detection alongside Rapid-Fire and Velocity. Motion-module crafting should offer a sensor-based route and a higher-skill raw-material route; exact recipes remain unsettled.
- C47: Owner explicitly permits stacking **Range, Velocity and Rapid-Fire** modules. Previous one-per-type restrictions are superseded for those three. Bonuses, formulas, capacity and power are undecided; recommendations and safeguards are recorded in [module plan](MODULAR_TURRETS.md). No module runtime ships in P2C2b.
- C48 (2026-09-28): Owner approves the complete P2C3a-c next-update recap, on High effort, combined with the held P2C2b test. Universal base plus swappable potato head, actual ammo/module/battery storage, native construction, contents tooltip, contents-based weight and charge/condition/cooldown persistence are in scope. Pickup retains contents; battery swaps return the actual battery with its charge. No automatic ejection. Module effects remain P2C3d; native firearm reuse and Reload/Autoloader behavior remain a later checkpoint.
- C49: The approved revised recipe removes planks and Carpentry. Base: 2 pipes, 2 small sheets, 1 scrap, 8 screws; Mechanics 2, 15 Mechanics XP. Potato head: 1 pipe, 1 small sheet, 2 scrap, 2 electronics scrap, 1 electric wire, 1 tire pump, 2 tape uses; Mechanics 2/Electrical 1, 15 Mechanics + 5 Electrical XP. Improvised head replaces pump with four extra scrap and requires Mechanics 4. Retain screwdriver, wrench/pipe wrench, metal snips; head also requires pliers. Combined recipes sum costs/XP exactly. No deployment, pickup or swapping XP; no magazine requirement.
- C50: Turret power uses a removable car battery or valid native external supply, preferring external power and falling back to battery. No free charging on pickup/swap; use vanilla charging. The potato head includes feeding/cycling; Firing and Motion Detection modules still have separate roles. Useful Sandbox controls and short tooltips are authorized. Initial quantities, charge/fuel consumption and empty base/head/module weights are implementation tuning defaults documented in P2C3, not claims of playtested balance.
- C51 (2026-09-29): Owner requests OMH: Traps and OMH: Turrets categories in Crafting and Building. Category migration is queued with the pending usability patch. The requested magazine capacity 1, reload 1s and cooldown 0.5s require a shared cycle system; 85 total potatoes, overlapping timers and reducing retained tools to screwdriver plus wrench remain recommendations awaiting explicit settlement.
- C52: Owner approves a cube-only hybrid rendering checkpoint before final artist export requirements. Evaluate a stationary base tile and separate rotating model head, using current native APIs, independent-instance tests and visual acceptance. This does not approve final art, a Java injection dependency, or replacing gameplay turrets before the renderer is proven. See PHASE_2_HYBRID_RENDER_PROBE.md.

- C53 (2026-09-29): Owner approves the combined gameplay patch after reporting probe flicker and requesting base collision. Implement integrated tile-base/model-head rendering using recorded 0.4 height / 0.512 scale as starting calibration; see-through 1x1 base collision, native adjacent servicing, Manage/native inventory, category/preview fixes and shared firing cycle. Approval adopts the proposed 85 total ammo, overlapping 1s reload / 0.5s cooldown and screwdriver plus wrench/pipe-wrench tools. Supersedes C51's pending values and C49's snips/pliers. Keep one combined visible test; module effects/automation remain P2C3d and final artist export settings remain unaccepted. See PHASE_2_CHECKPOINT_3_USABILITY.md.


## 2026-09-29 dedicated turret window approval

- C54: Owner approves replacing Manage's loot-page shortcut with a dedicated turret window: head, ammo, module and battery slots, real drag/drop timed transfers, charge and capacity display, live status/stats and manual Fire. Keep one actual native container and exact items; no inventory duplication or instant transfer. Include the reported base-grounding correction. Module effects and multiplayer remain later checkpoints.
- 0.2.11.1 log confirms Manage opened without its previous exception, but the owner rejects opening the standard loot pane as the intended interface. This confirms the load-order repair, not full visual or gameplay acceptance.

## 2026-09-29 turret aiming and balance

- C55: Owner reports the head did not follow the lowered base, model rotation disagrees with firing direction, and requests selection range/FOV and Magazine wording. Requests 35 damage and 2s reload/cooldown; this patch interprets both as two-second overlapping timers, retaining magazine 1 and ammo 85. Saved Sandbox custom values remain authoritative. This supersedes C53's firing defaults and fixed 0.4 head height, while retaining scale 0.512.
- Current manual combat targets radially, with loaded-square and obstruction checks. Selection shows that actual 360-degree radius plus head aim. The owner was offered a separate 90-degree forward restriction or current radial behavior; absent that answer this patch does not change targeting eligibility. Motion Detection/360 module behavior remains P2C3d.
- The 0.2.12 console capture `diagnostics/captures/20260929-183350-0950` records successful exact-item transfers and seventeen shots at damage input 0.5. The owner's screenshot/report establishes failed visual head alignment; it does not imply all prior acceptance gates passed.

## Placement-locked coverage and held test

- C56: Owner selects a forward cone locked to the turret's placement direction. Head tracking must not rotate that cone; manual and automatic target eligibility must share the same boundary. The 360 module expands angular coverage to a full circle without increasing distance. This supersedes the unresolved radial-versus-cone decision in C55; 0.2.13 remains radial until patched. Cone width is not explicitly settled: 90 degrees with a Sandbox control is recommended.
- Owner skips the standalone 0.2.13 test and requests discussion of the next checkpoint. Record it as held/untested, not passed. Combine its height/yaw/Magazine/balance/range acceptance with the next playable checkpoint. This turn authorizes documentation/discussion, not immediate implementation of all module systems.
- Recommended subdivision of P2C3d: d1 placement coverage plus Firing, Motion Detection, Filter and 360 effects; d2 stackable stat/capacity effects. Recipes/tools/skills/XP require concrete owner review before implementation, per the existing recipe agreement. Reload/Autoloader timing effects can be reviewed with d2 now that the shared cycle exists; firearm adapters remain P5.

## Module acquisition and default coverage

- C57: Owner settles the default field of view at 90 degrees (45 degrees either side of placement direction) and makes modules loot-only for now. Module crafting recipes, retained tools, skills and XP are deferred and are not a prerequisite for P2C3d1. Preserve configurable cone width and the C56 placement lock/360 expansion.
- Proposed loot tuning: use suitable electronics/industrial loot pools verified against the installed game; Firing and Motion Detection should be more available than Filter and 360. Expose useful module loot abundance control. Exact pools/weights remain implementation recommendations, not verified current distribution behavior. Introduce gameplay loot for functioning modules only; later-effect modules remain debug-only until their checkpoint. No loot injection or runtime change is made in this discussion update.

## Configurable module and automation tuning

- C58: Owner agrees with the loot-only/core automation direction and explicitly requests Sandbox controls to test and choose balance values personally. Include useful tuning in the feature checkpoint, grouped by category with short tooltips. Do not require another recipe discussion; crafting remains deferred.
- Planned d1 controls: forward cone default 90 degrees; automatic targeting enable/disable; bounded detection interval; global module loot multiplier and separate Firing/Motion Detection/Filter/360 multipliers, with zero suppressing new drops. Use multiplier wording rather than promising an exact percentage from native weighted loot pools. Exact non-confirmed numeric defaults/bounds are implementation tuning, not owner-set values.
- Existing per-turret damage, range, ammo/module capacity, magazine/reload/cooldown and power controls continue to apply to automation. Keep Filter priority and individual turret on/off in Manage. Later active stack modules get per-copy bonuses/caps and loot controls in d2, not inert d1 settings. Changes never delete owned modules or regenerate already-populated containers.

## P2C3d1 implementation approval and defaults

- C59: Owner approves implementing the discussed core automation/loot/Sandbox checkpoint, then approves resuming after an interrupted work turn. Deliver 0.2.14 as one combined test build with held 0.2.13 changes.
- Implementation tuning (owner-adjustable, not individually owner-selected): scan interval 0.25s bounded 0.1–5, cone bounds 10–360 with confirmed default 90, loot multipliers 1 bounded 0–20, and pool weights Firing/Detection/Filter/360 = 2/2/0.5/0.25. Automatic operation defaults enabled when components/power are present; Manage and Sandbox can disable it. Health priorities compare current health.
- Native source verification exposed distribution-merge-before-Sandbox-load ordering. Apply module weights at OnLoadedTileDefinitions and reparse once before map population. Reload for loot setting changes; preserve already-generated containers and unrelated loot. Gameplay remains SP-only. Scope/evidence/combined test: PHASE_2_CHECKPOINT_3D1.md.

## 2026-09-29 C60: approved automation polish and owner audio

Owner approves 0.2.15 after reporting 0.2.14 generally passed, then confirms zombies did thump the turret later. Do not change native thumping or add a speculative workaround. Reused-save Sandbox differences are intentional.

- Visible name is 360 Module; preserve internal Detection360 item/save IDs.
- Manage opens only its own panel, leaving inventory visibility/pinning untouched.
- Powered automatic Motion Detection sweeps visually while searching, freezes without detection/power, and tracks acquired targets. External power counts. Placement cone remains fixed. Idle sweep speed defaults 30 degrees/second, Sandbox 0-180; zero disables the visual sweep only.
- New defaults: 100 total potatoes including magazine; splash 25 percent of direct damage (8.75 at 35), radius 1.5 tiles, at most three secondary targets, no splash knockdown. Existing capacity/radius settings remain unchanged. PotatoSplashPercent replaces the former absolute-damage setting under a distinct key; do not reinterpret an old absolute value as a percent.
- Default solo Hard first night has 17 zombies. Its 10/78/12 toughness mix and 35 direct damage imply about 106 direct-hit potatoes on average before splash/help/misses, not a guaranteed 100-potato clear.
- A short white travel marker precedes the impact pop; this is a presentation effect, not a persistent potato physics item. Damage remains immediate, matching the native separation of hit resolution and tracer presentation.
- Owner will create sounds. No native sample or generated audio is shipped. See art/AUDIO_BRIEF.md.

Captured 0.2.14 test: diagnostics/captures/20260929-204206-9890. Version 0.2.14 and automatic fire are in the log; no OMHTT exception identified. Owner acceptance does not certify multiplayer or every unobserved regression.

## C61: 0.2.16 presentation and mechanical turn speed

Owner accepts 0.2.15 generally, but reports head/base occlusion and low white projectile. Approves the discussed patch after comparison with Horde Night and Trait Shop. All six page labels use OMH: T&T -; potato page has Operation, Storage, Combat and Power headings. This preserves individual-defense pages and internal saved keys. Detection Module and the shortened 360 tooltip are display-only changes.

Turret heads rotate at a maximum rate (default 90 degrees/second; Sandbox 1-360), using shortest angular distance and a one-degree firing tolerance. Manual fire queues one target-specific shot, revalidates access/resources/geometry and spends nothing while turning. Automatic Detection tracks with the same physical angle. Idle sweep updates the current head angle but cannot rotate coverage. Pending shots/targets are transient and are cancelled by invalid targets, missing power/head, lost manual reach or disabled automatic detection; no pending shot persists across reload.

The temporary base sprite uses native FloorOverlay depth instead of the generic tall-object depth; calibrated model height stays unchanged. This is a placeholder floor-depth approximation, not a final per-pixel model-matched depth map. Native flags/collision are verified; rendered head occlusion still needs owner acceptance. Projectile starts higher, travels as a brown marker and pops into larger brown particles. Selected splat2.wav is referenced from the installed game through OMHTTPotatoImpact. No native audio is redistributed.

The listening page now contains 34 exact-copy candidates, including 16 reload candidates. Always supply an HTML audition page for future audio decisions. Source metadata stays beside the local page. No sibling mod is edited.

C61 pre-install correction: the captured 0.2.15 packed-item tooltip failed in native Translator on a literal percent sign. 0.2.16.1 fixes charge wording before the first installation of this patch; 0.2.16 remains an uninstalled source tag.

## C62: held 0.2.16.1 test and next checkpoint discussion

Owner requests recording the pending test and moving forward to discuss the next checkpoint. Hold the full turning/presentation test for combination with P2C3d2; do not count it as passed. P2C3d2 scope is documented as a proposal, with numeric module tuning and implementation approval still pending. This request changes documentation only, not installed gameplay.

## C63: approved P2C3d2 and stackable Reload

Owner approves proceeding with active stat modules and explicitly adds Reload stacking. Use Reload and Fire rate as concise distinct labels. Implement the proposed dedicated Capacity socket, safe removal, configurable gains/caps and loot-only acquisition. Defaults in PHASE_2_CHECKPOINT_3D2.md are implementation tuning; retained Sandbox settings still apply. Combine held 0.2.16.1 acceptance into one complete owner test. No crafting, firearm adapters, multiplayer certification or external publication is authorized by this checkpoint.

## C64: 0.2.17 review and page organization

Owner completes the test and requests Traps / Turrets parent Sandbox pages, logical ordering with Debug last, eight visible slots with inactive extras greyed, attention feedback on changing Manage messages, and investigation of firing hitches. Reports a visible head/base gap and distant building placement; asks about inventory Install. See TEST_v0.2.17.md for observed evidence, native cheat behavior and proposed follow-up. These parent-page labels supersede individual-defense page names; preserve saved option keys.

Owner also approved planning a supported-firearm mount prototype before multiplayer. Keep universal base, swappable actual gun, shared modules and native-mechanism evidence; no blanket modded-gun support claim. Address the current usability/performance findings first.

## C65: approved Expansion Kits and combined usability patch

Owner approves recap and implementation: Capacity becomes one dedicated Expansion Kit socket with Small/Standard/Large variants, increasing capacity and rarity, not multiple installed kits. Preserve existing Capacity as Standard; tier defaults and safeguards are documented in PHASE_2_CHECKPOINT_3D3.md. Ten compact regular slots cover the Large default, unavailable slots dim; omit Module only from installed slot labels. Include ordered parent Sandbox pages, changed-message brightness, head/base depth repair, bounded manual-fire searches and exact-item inventory Install. Building-cheat bypass remains native. Keep one combined test and firearm prototype next.

## C66: approved Install, item naming and projectile/audio repair

Owner approves the 0.2.19 repair and later asks to resume it. New Expansion Kits use accurate IDs and Small/Medium/Large names; audit Detection/360 IDs too and retain saved aliases. Fix silent Install and log rejection stages. Constructed turret projectiles use real travel delay shared by hit effects and damage, default 20 tiles/second with Sandbox tuning. Use owner-supplied potato_thump_1/2.wav and potato_splat_1/2.wav, native variant selection and subtle 0.95-1.05 pitch. Keep bounded queues, saved settings and existing reload/cooldown semantics. See PHASE_2_CHECKPOINT_3D3_REPAIR.md. No external release or multiplayer enablement.

## C67: correct visible aliases and projectile muzzle

Owner requests resolving duplicate item-spawn entries and moving the visible projectile start from head center to barrel end; reports the rest of 0.2.19 worked well. Use native Hidden=true for five saved compatibility definitions and retain their data. Offset only presentation from the actual placeholder barrel geometry without changing combat timing. Owner subsequently reports stuttering on every shot; remove redundant shot refresh/scans, spread verbose telemetry across ticks and add stage timings without claiming unmeasured FPS improvement. Version 0.2.19.1; see PATCH_v0.2.19.1.md. No extra feature checkpoint or balance change.

## C68: approved destruction policy, remove pre-release aliases, combine next checkpoint

The owner approves base loss with partial metal salvage and preserved internals. Two scrap metal is the implementation default. Actual head, ammo, modules, expansion kit and battery survive without additional damage or charge reset; normal pickup does not create salvage. Reduce oversized loose placeholder sprites.

The mod has never been uploaded; the owner explicitly authorizes removing the five old item definitions instead of hiding them. C68 supersedes C66/C67 compatibility retention. Remove their identity mappings/translations as well; retain internal behavior and Sandbox keys because these are not duplicate items. Old private-test items using deleted IDs are not migrated.

Owner reports 0.2.19.1 seems to work well; this does not independently certify frame times. No standalone owner test is required for the cleanup. Prepare source but hold installation to combine with the next checkpoint. Next is early P5C1a supported-firearm feasibility per C64, scoped in PHASE_5_CHECKPOINT_1A.md; firearm implementation remains pending concrete approval. No publication, remote push or sibling changes.

## C69: approved early supported-firearm mount, combined 0.2.20

The owner approves P5C1a and combining it with C68. Scope is three installed vanilla mechanisms: Base.Pistol, Base.Shotgun and Base.HuntingRifle. Use the actual weapon as the head, matching loose ammunition and existing turret modules, power, targeting and Manage. No separate mount item or recipe changes. Preserve actual gun condition, attachments, loaded magazine/chamber and supplies through recovery/save/load.

Implementation uses a bounded stationary-weapon adapter: native item stats, models and sound events; explicit approximate accuracy/damage and mechanical timings, without pretending to execute the character-only firing pipeline. Pistol requires its ordinary magazine inserted before mounting. Autoloader removes loading delay while pump/bolt cycling remains. Existing jams block firing and can be cleared after removing the gun. See PHASE_5_CHECKPOINT_1A.md for measured native references, implementation defaults, limits and the combined owner test. Broad modded-gun support and multiplayer are deferred.

## C70: firearm repair and architecture alignment

The owner reports a partial 0.2.20 test and asks to fix its issues first. Add mounted gun pose/support, dedicated native magazine servicing, persistent red requirements and head removal with reserve retained. Scope/evidence and native magazine identity semantics: PATCH_v0.2.21.md. Autoloader does not add a magazine requirement to potato/internal-magazine heads. Review current engine evidence and Alex's rules; ARCHITECTURE.md records similarities and remaining authority, aggregate-budget and clock gaps versus Horde Night. No sibling modifications or MP enablement.

## C71: suppression audio audition and reload selection

Owner selects stormyShotgunInsertRound.wav for potato reloading. Suppression is stackable without a separate stack cap; ordinary available module slots remain the physical limit. Do not add a Suppression stack-limit option. Per-stack hearing reduction remains tuning to confirm with the gameplay patch. Do not reduce audible playback gain to represent zombie hearing.

Owner supplies OMH/Audio/Turrets & Traps/suppressed_shot.wav as an overlay: layer it unfiltered over the filtered original shot, never use it alone as the replacement. Updated art/POTATO_AUDIO.html links/downloads the reload, overlay and two rendered layered potato-shot previews. Original files remain unchanged. Mixes preserve the previous 250 Hz linear wet envelope; preview slope remains 48 dB/octave pending final choice. Overlay begins at time zero, unity gain, with no normalization. Numerical checks confirm overlay preservation and no clipping. Browser player volume remains a common audition level, not suppression gameplay attenuation.

No gameplay update is authorized by this HTML request. Preprocessed replacement clips make the proposed sound achievable for supported heads without arbitrary runtime DSP. Current installed generated gun/sound definitions have no universal suppressed-shot variants; broader firearm coverage needs explicit replacement clips/profiles or a separately proven runtime FMOD path.

## C72: native firearm suppression library and family fallback auditions

Owner requests processed sounds for all native guns, with the existing filter plus the supplied unfiltered overlay, an HTML audition and proposed generic families for modded weapons, keeping file size small. This authorizes local audio production and documentation, not gameplay installation or broader firearm adapters.

The installed 42.21.0 inventory has 20 real firearms sharing 18 shot events, plus two toy cap guns. Current native events were rendered locally through the installed FMOD libraries; no obsolete loose-file substitution was used. All have original/filtered/layered comparisons and layered OGG/WAV downloads in art/FIREARM_AUDIO.html, linked from art/POTATO_AUDIO.html. Mono 48 kHz Vorbis quality 4 produces a 797,597-byte real-firearm runtime candidate subset; nine proposed families reuse files with no additional audio payload. Cap guns are separate completeness entries. One representative single-shot event render per sound, not every random/indoor/distant variant. No universal modded-gun compatibility implied.

Preserve C71's envelope and unfiltered overlay. Preview slope remains 48 dB/octave. As an export safeguard, common clipping-prevention gain is permitted within this prepared audition set and disclosed per clip, with identical gain on comparison versions; it is not a proposed zombie-hearing volume effect. Source recordings remain unchanged. Exact native event/item mapping, source hashes, processing and verification are recorded in art/firearm-audio/manifest.json and README.md. Proposed family selection is exact item override, recognized native event, explicit cartridge/mechanism family, then unchanged original for unknown mechanisms. Family choices still await owner listening.

## C73: approved balanced suppression, reload feedback and turning repair

Owner accepts matching the unfiltered overlay's perceptual balance to JS-14 rather than applying unity gain to every original shot; approves adding processed firing sounds together with the lootable Suppression Module. Keep 25% remaining-radius reduction as default, no separate stack cap, configurable strength/loot, and unchanged audible gain across stacks. Potato reload is stormyShotgunInsertRound.wav; firearms use native mechanism fields. Include the mounted gun turning fix and one combined test. This specifically authorizes packaging the approved processed native firearm audio and supersedes C60's earlier no-native-samples restriction for this library. Original source files remain unchanged. Scope and evidence: PATCH_v0.2.22.md. Three firearm adapters remain the supported limit; fallback family assets are preparation, not universal gun support.


## C74: resume the held controls/combat patch and expand themed loot

On 2026-10-02 the owner approved the site update together with the held gameplay patch. Retain native firearm critical chance and damage; implement the reviewed Power control, stackable Critical/Accuracy, diminishing uncapped Suppression and random/max-toughness target locks. The accepted defaults and native findings are recorded in PATCH_v0.2.23.md. Add ElectricianTools, GunStoreAccessories and ToolCabinetMechanics with component subsets while retaining the original four full pools. Publish the updated admin LootLab and preserve cross-device settings. Local gameplay install is authorized; GitHub push and Workshop publication are not. Continue with one combined player test and the existing SP boundary.

## C75: adopt the current hosted LootLab tuning

On 2026-10-02 the owner approved applying the current website settings. Read-only production evidence identified revision 84: global 6; Firing, Detection, Small/Large Expansion Kits and Autoloader 3; all other components 2. Apply these as new-world defaults and LootLab reset defaults; preserve existing game saves, generated loot and account scenarios. Scope and evidence: PATCH_v0.2.24.md. Local install and matching admin-site update are authorized; no Steam publication or GitHub push.

## C76: broader loot and turret usability

Owner approves the discussed patch and specifically sets potato hearing to eight tiles. Broaden native themed pools while making ordinary successful finds usually one or two components and retaining uncommon five-plus jackpots. LootLab uses larger circles for generated five-plus totals and chance-scaled circles on the probability overlay. Preserve account tuning and existing generated game loot.

Add the green/red Power symbol, free ten-second base-only Repair, explicit rejection of duplicate utility modules and conventional gun admission based on native data. All twenty native real guns are mechanism-probed; no arbitrary custom weapon-code compatibility claim. Scope, pool weighting and one combined test: PATCH_v0.2.25.md. Local install and admin-site deployment are authorized. This supersedes the three-gun admission restriction, not the single-player gate or required shared-budget/clock work.

## C77 — approved cadence, range and loot normalization (2026-10-04)

Owner approves the combined patch including native distance accuracy: PATCH_v0.2.26.md. Firearm rate 0.75, potato unchanged; native damage/criticals retained. Engagement range is independent of head range. Precision Fire and recoil simulation are omitted. Loot global 4.5 and current component factors become base weights; controls reset to 1. Old Sandbox keys cannot double-multiply; website migration preserves effective tuning except the expressly approved owner reset. Summarize diagnostics and coalesce unchanged inventory work.

## C78 — 0.2.27 range, hearing and compatibility

Owner approved the revised recap on 2026-10-04. Precision includes bolt/lever/semi-auto-only rifles; automatic/burst-capable guns remain ordinary even in Single mode. Original script range supports classification, never a mandatory >40 rule or attachment/module promotion. Defaults 60/80 at full effective weapon range; the engagement cap does not rescale accuracy. Noise visibility is a local Mod Options preference. First P2C3e slice shares work and excludes paused/offline time; multiplayer and dense rendered performance remain acceptance gates.

## C79: approved broader finds, all-gun startup audit and 5x tuning

Owner approves the discussed patch and raises the prior 4.5x baseline to 5x. Add modest themed weights to GarageMechanics, CrateMechanics, ElectronicStoreComputers and ElectronicStoreHAMRadio; preserve uncommon jackpots. Raise normalized base weights by 10/9 with all rate defaults remaining one. Match LootLab and preserve account settings. Debug logging audits every ranged candidate once at startup in bounded batches, with accepted stats, rejection reasons and totals. Investigate the Louisville hang; surviving evidence cannot assign a cause. See PATCH_v0.2.28.md. No new combat balance, recipes or multiplayer enablement.

## C80: selectable Turrets/Traps and roadmap reset

Owner requests two selectable mods, OMH: Turrets and OMH: Traps, shipped together as OMH: Turrets & Traps so users can exclude Turrets. Record this in checkpoints/todos, reassess phases, review collaboration rules, report existing turret plans and suggest unique heads. This authorizes documentation, not a gameplay/package rewrite yet. Traps-only must be independent; turret-only support and shared loading without a third visible entry are recommendations to prove in R1C1. Old combined-ID/save behavior needs an explicit tested policy; do not equate a Sandbox disable with unloading a mod.

Owner reaffirms that the assistant should correct mistakes, challenge proposals and recommend against features with material feasibility/performance/compatibility problems. Approval cannot prove engine capabilities. Revised ROADMAP.md uses R1-R6 IDs while ROADMAP_LEGACY_20261004.md retains previous P0-P6 history. Existing evidence remains valid and unresolved acceptance stays open. TURRET_HEAD_PROPOSALS.md contains unapproved concepts. No new recipes, stats, final art, multiplayer claim or publication is implied.

## C81: offensive module planning and long battery life (2026-10-06)

Owner broadly approves the discussed module direction and explicitly requests adding it to phases/checkpoints, followed by renewed turret-head discussion. This authorizes planning documentation; "most" is not approval of every suggested tuning value, propagation rule or head. No gameplay implementation, installation or release occurs in this update. See [offensive module checkpoints](checkpoints/R3_OFFENSIVE_MODULES.md).

Explicit owner direction:

- Most offensive modules should stack. Splitter adds one child shot per stack, each at 50% of original damage: one alternates left/right 15 degrees, two fire both, three add an alternating 30-degree child, and further stacks continue in paired 15-degree increments. The central shot remains the working interpretation; stack cap and additional-ammunition policy are unresolved.
- Use the name **Fragment Module** for the radial-impact concept: five random radial child shots at 20% of original damage each. Owner prefers a minimum separation of **30 or 45 degrees**, superseding the earlier 20 degrees; exact selection remains open. Recommend 30 degrees with the wraparound gap checked too.
- Impact should affect the first bullet of a magazine with a high stumble chance. Exact native reaction, reload eligibility, single-round heads and stack tuning need proof/selection; do not substitute full knockdown without discussion.
- Module intensity/impact should increase battery usage, while batteries must remain long-lived rather than requiring daily replacement/recharging under normal use. Do not simply multiply the existing per-shot drain. Exact endurance target and representative firing workload remain tuning decisions.
- Exclude Homing and Bleed. Exclude slowing turret effects that undermine OMH Horde Night zombies. Net/slow-based heads leave the active shortlist. This does not silently remove the separately planned concertina trap; R2C4 must revisit its slowdown against this concern before implementation.

Working proposals retained for review: Piercing, Initial Blow and Execute; compatible combinations and capped stacking; Fragment once on the primary projectile's first successful impact per firing cycle, with terminal children; Fragment stacks improve damage rather than count; Impact stacks improve chance with recovery protection; empty-reload rearming; upfront predictable power cost and a separate negligible operating draw if justified. These details are not individually confirmed by the broad approval. Splitter ammunition cost, fragment range, head compatibility, secondary targeting/collateral and exact caps remain explicit scope gates. Existing potato splash remains a separate mechanic.

Puddle/tack bullets are not scheduled; the proposed spike-canister ground trap is deferred. New head candidates remain proposals, with no selection or recipe approval. Maintain existing package, performance, multiplayer and publication gates; do not add planned features to WORKSHOP_CHANGELOG.txt.

## C82: prune heads and replace flail with rotary blades (2026-10-06)

Owner drops Extinguisher as clutter and Pneumatic Ram as too limited in reach to be efficient. Remove both from the active shortlist. Owner prefers Rotary Blades over Rotary Flail because rigid blades should be simpler than the implied flexible-body physics. Record Rotary Blades as the replacement close-defense concept; no chained-physics implementation or head prototype is authorized by this discussion alone.

Working recommendation: bounded fixed-reach swept contacts synchronized to visible rotation, no per-frame damage or permanent aura, no Bleed/slow/stun-lock, and appropriate obstruction/target checks. Coverage, reach, player danger, damage cadence, victim caps, compatible modules, maintenance and recipe remain open. This design is plausibly simpler, not an engine capability claim. Preserve long battery life, owner-sourced final art and R3C1-R3C2 proof/approval gates. Updated candidates and tradeoffs are in [TURRET_HEAD_PROPOSALS.md](TURRET_HEAD_PROPOSALS.md).

## C83: bat variant and temporary nail-scatter head ideas (2026-10-06)

Owner suggests a bat head as a more accessible downgrade to blades and proposes that both could knock zombies back. Record Rotary Bat as a candidate sharing the rotary mechanism, and investigate brief native knockback with recovery protection for both variants. No exact reaction/chance, component availability, recipe or gameplay implementation is confirmed. The restriction against slowing and repeated permanent control remains; this suggestion reopens bounded knockback, not unlimited staggering.

Owner also proposes a dedicated tack/nail head that deploys temporary ground hazards when zombies are in range, potentially in 360 degrees on available tiles. This reopens the previously deferred ground-scatter concept for head discussion, not tack-filled bullet/Puddle modules. Working recommendation is bounded tile patches in a stepped circular radius, with valid floor/path checks, consumable batches, finite life/contact uses, no overlapping damage multiplication and no slowing/Bleed. Coverage/module dependency, damage/contact behavior, player danger, caps, persistence/expiry and supplies remain unresolved. Treat Nail Scatter as a candidate for R3C1-R3C2, not an approved implementation or release. See the updated head proposal for tradeoffs and proof requirements.

## C84: craftable improvised automation and expansion direction (2026-10-06)

Owner requests improvised Detection/Firing modules as a worse-performing craftable route to automation. Working recommendation keeps them as separate role variants, one active item per role, interchangeable with standard variants. Owner proposes approximately 15% click-only misfire for improvised Firing instead of the suggested firing-rate ceiling. Recommend one roll per otherwise valid automatic cycle, normal retry cooldown, retained ammunition/opening-round entitlement, no persistent native jam and no full offensive power charge on failure. Exact misfire tuning/resource policy and Detection's reduced range/acquisition remain proposals. Do not stack the earlier firing-rate penalty on top without a new decision.

Owner clarifies the Improvised Expansion Kit is a craftable version of the existing expansion packs that unlocks four module slots. Treat this as a four-slot expansion bonus through the existing dedicated socket; with the current four-slot base it provides eight total slots. It replaces rather than stacks with another kit. Owner requests a centered layout illustrated as four slots above two wider rows and allows adjusting counts to fit. Higher-tier sizes are not individually confirmed.

Working layout/tier proposal: four centered base slots plus two eight-slot rows; total capacities None/Improvised/Small/Medium/Large = 4/8/12/16/20. Each tier unlocks another group of four; on a half-filled eight-slot row, activate the central four first. Distinguish this proposal from today's implemented 4/6/8/10. Preserve existing item identities and stored modules; explicitly handle saved Sandbox values and over-capacity turrets. Larger slot counts require bounded effect combinations and battery-endurance measurements, not higher drain simply for owning empty slots. Expansion ammunition bonuses and all new recipes/tools/skills/XP remain unresolved. C84 plans exceptions for improvised crafting; standard modules do not automatically become craftable. No gameplay patch or installation is authorized by this clarification alone.

## C85: centered five-row expansion progression (2026-10-06)

After checking the implemented 4/6/8/10 capacities, owner selects a centered five-row diagram with 2, 2, 3, 4 and 5 slots. Map the rows in order to base, Improvised, Small, Medium and Large: total capacities are **2/4/7/11/16**. Each expansion unlocks the next complete row; kit bonuses relative to the new base are 2/5/9/14. Preserve the single dedicated expansion socket and replacement rather than stacking.

This latest layout supersedes C84's 4/8/8 diagram, 20-slot proposal and four-slot Improvised bonus. Improvised now supplies four total slots, adding two to the two-slot base. This consequence was stated in the update rather than silently retaining incompatible numbers. The base has enough space for Detection plus Firing; additional modules require expansion for that automatic configuration.

Record the selected progression in R3C8 and the module plan. Existing gameplay remains 0.2.28; this planning update does not implement the new kit or recipes. Base reduction must preserve installed items and respect saved Sandbox settings through a reviewed migration policy. UI must handle non-default capacities without hiding items and center each row while retaining stable inventory identity. Ammo bonuses, crafting requirements, exact starter-module tuning and the gameplay implementation checkpoint remain open.

## C86: compact-menu progression in equal upgrade groups (2026-10-06)

Owner questions the pyramid's height, requests clearer visual alternatives and permits progression changes. After previews of a four-column grid, a two-row eight-column grid and tier-labeled rows, owner accepts progression of **2, 4, 4, 4**. Interpret these as the four expansion-upgrade increments beyond the two-slot base: None/Improvised/Small/Medium/Large totals **2/4/8/12/16**, with replacement-kit bonuses over base of **2/6/10/14**. This mapping is stated back to the owner and supersedes C85's intermediate totals of seven and eleven.

Decouple capacity progression from physical menu rows. A compact two-row eight-column grid was the latest recommendation; the approval settles progression without separately requiring a named mockup or exact pixel geometry. The five-row pyramid is no longer a requirement. Keep the 16-slot maximum, single expansion socket, safe item preservation and battery/performance gates. R3C8 remains the implementation checkpoint; this update changes planning documents only.

## C87: proceed with package split and consolidate deferred testing (2026-10-06)

Following the next-patch recap and recommendation to split packages before adding content, owner approves proceeding with the update, will test later, and requests adding the outstanding test to the next patch while removing redundancies. Proceed with R1C1 loading/dependency proof and the reviewed R1C2 package split. This does not approve unresolved recipes, offensive-module tuning or every future roadmap item.

Use one complete next-patch owner test in [R1_PACKAGE_SPLIT.md](checkpoints/R1_PACKAGE_SPLIT.md). Carry forward unverified 0.2.27/0.2.28 behavior, remove repeated setup and separate test-round requests, and retain historical evidence without calling deferred tests passed. Do not require another 0.2.28 player test before the approved work.

Installed native inspection finds duplicate tile-definition numbers rejected. The existing 7316 registry contains both barrier and turret identities. Ask whether Turrets may require Traps (recommended existing-registry ownership) or whether standalone Turrets is mandatory before selecting a package workaround; do not turn shared-registry duplication into an accepted runtime error. Current installation stays intact during the proof.

## C88: fully independent entries and fresh test worlds (2026-10-06)

Owner explicitly approves full independence and a fresh test world after discussing the shared tile registry. Implement Traps-only, Turrets-only and both, with no required sibling/Core mod. Use new IDs OneMoreHorde_Traps and OneMoreHorde_Turrets; split tile registries into 7316/7317 and update turret sprite identities. No old combined-save migration is required for this development patch. Preserve item/state IDs and existing gameplay tuning.

Maintain canonical Source and generate shared helpers identically into each package; native loading executes each shared virtual Lua path once. Keep recipes, settings, models, loot and update loops in their owning entry. Adapt manifests, rollback-safe installation and component-aware local LootLab exports. Retire the managed combined installation to a verified full backup. C87 deferred testing remains one consolidated 0.2.29 checklist; neither approval nor native checks establish rendered or multiplayer acceptance. No remote push, Workshop upload or website deployment is authorized by this change.

## C89: waive remaining split regression round; investigate medical loot (2026-10-06)

Owner reports heavily stocked medical containers and asks whether global loot or jackpot behavior changed. Owner states much of the gameplay is already proven and explicitly skips the remaining test. Close the outstanding 0.2.29 checklist as owner-waived, preserving prior evidence without fabricating new passes. Future player checks should target changed behavior and credible regression risks. Read-only loot investigation finds unchanged component weights, only the intended split master-gate change, native medical loot 0.6 and roll multiplier 1.0. Component jackpots do not boost ordinary loot. A vanilla profession-house explanation is plausible but the exact containers are not identified. See TEST_v0.2.29.md; no gameplay fix or loot rebalance is authorized or indicated by these findings.

## C90: performance correction approved; combine with Bed Spikes subject to design (2026-10-06)

After the heavier-load pause report and audio-helper timing evidence, owner approves the proposed performance patch: isolate the audio stall, apply an evidence-backed mitigation and gate unnecessary reaction tracking behind detailed diagnostics. No further approval is needed for this scoped performance work. Preserve combat behavior, zombie hearing and intended audio variation; the exact blocking native operation is not yet identified.

Owner also selects Bed Spikes for the same content patch and asks what must be discussed. Existing automatic crossing for all players and independent Traps ownership remain confirmed. Discuss ground-bed versus grave workflow, footprint/placement, zombie contact cadence and damage, player injury/blocked crossing, durability/repair/pickup, and recipe/tools/skills/XP. New numerical defaults and recipes are proposals until answered. Prove native automatic traversal before promising completed gameplay; the performance correction need not wait for a blocked movement prototype. Broader turret-module content is not included in this approval.

## C91: short trip spikes, reinforced tier and brush-through movement (2026-10-06)

Owner revises Bed Spikes to short spikes with an increased zombie trip chance and large damage when a zombie trips onto them. Include basic and reinforced variants with a 1x2 footprint. Players use the bush/foliage hand-clearing movement animation instead of automatically jumping; this explicitly supersedes C14 and the jump requirements in C90. Owner drops the discussed barbed-flooring addition. Existing planned concertina/barbed-barricade concepts are not deleted or implemented by that exclusion; concertina is a movement reference, not an already completed feature.

Recommended trigger contract, awaiting confirmation: one trip roll per zombie per complete two-tile bed crossing, one damage event on a verified fall onto that bed, rearm after exiting with protection against repeated trip chains. No standing damage ticks or ordinary walking-contact damage. Reinforcement should primarily increase fall damage and durability; keeping trip chance equal is a proposal. Chance, damage, wear, already-fallen/crawler treatment, player speed/injury, placement surfaces and both recipes/tools/skills/XP remain unsettled. The previous proposed 1x1 recipe/numbers were not approved and must not silently become the 1x2 design.

Installed 42.21 movement/inTrees.xml names Bob_WalkTrees with WalkSpeedTrees and the intrees condition; it also emits DamageWhileInTrees. This confirms a native animation exists, not safe runtime integration or the intended injury policy. Do not enable incidental tree injuries by copying the animation without review. Native zombie fall/trip state and landing/contact attribution still require proof; available knockDown methods alone do not prove the requested trip behavior. Performance work stays authorized under C90.

## C92: movement-dependent player risk, repeatable chance-based falls and restrained damage (2026-10-06)

Owner confirms player walking across Bed Spikes has no scratch risk, while running into them does. Running scratch probability/severity and sprint treatment remain numerical/edge-case tuning; recommend sprint inherits running risk. Reinforced beds increase damage and durability only, with unchanged trip chance. Owner requires zombies to be able to fall zero times or multiple times; do not guarantee a trip or impose a lifetime one-fall-per-zombie limit. This supersedes a strict one-roll-per-complete-crossing proposal if it would prevent multiple legitimate falls during traversal. The comment was attached to turret-induced falls; preserve that context without claiming an explicit answer to every external-knockdown/crawler interaction.

Owner explicitly wants damage restrained enough that covering an entire base is not the obvious best choice. Working interpretation: every genuinely new fall can cause one spike hit, but lying/getting up is not a new fall. Recommend distinct upright movement opportunities for trip rolls, with a brief recovery guard shared across adjacent beds so dense placements cannot independently retrigger a zombie every tick. Do not multiply a single fall by the number of overlapped bed tiles/objects. These trigger/guard details remain proposed, not a tested engine capability.

Proposed first balance pass: basic 20 damage and reinforced 30 damage per valid fall (not percentages or instant kills), same trip chance, finite wear per damaging fall. Both numbers and wear/repair/recipe defaults still require agreement. Low damage alone does not prevent excessive crowd-control value; test adjacent beds and recovery as well as isolated damage before claiming balanced mass placement. No trap limit, blanket zombie immunity, barbed flooring or permanent movement modifier is approved.

## C93: Bed Spikes 20/40 damage; recovery rule still under discussion (2026-10-06)

Owner prefers 20 basic / 40 reinforced damage per valid fall, superseding the proposed 20/30 values. Existing Spike Barrier defaults are separately verified as 10 basic / 25 reinforced per qualifying front/end thump; do not change them or treat differing damage triggers as equivalent DPS.

Owner proposes five seconds of trip cooldown after three falls and asks for a simpler alternative. This is discussion, not a finalized recovery contract. Explain that the three-fall rule permits a burst of repeated knockdowns and needs a counter/reset policy. Recommended simpler alternative: a shared per-zombie five-second protection from spike-induced trips after standing up from each fall, with subsequent upright movement eligible for chance-based trips again. Starting on recovery avoids spending the protection while the zombie is already down. Do not suppress ordinary weapon knockdowns. Trip chance, valid roll opportunities, exact recovery behavior, external-fall damage, wear and recipes still require settlement and native proof.

## C94: approve combined patch, reinforced damage ratio and Bed Spikes construction (2026-10-06)

Owner approves the content plus performance patch and requests a consistent 2.5x increase for reinforced items. The stated working interpretation is reinforced damage: Bed Spikes become 20/50 per valid fall; existing Spike Barriers remain 10/25. This supersedes C93's 20/40 bed damage. Do not silently multiply trip chance, recipe costs or all durability values by 2.5. Owner's approval accepts the simpler shared five-second trip protection after recovery, replacing the proposed three-fall counter. Ordinary weapon knockdowns remain unaffected.

Owner explicitly answers the construction/service question with "Approve these defaults": any clear floor; four interchangeable planks/crafted spears and four bindings, retained sharp knife, Carpentry 1 and 10 XP; reinforcement costs two planks and eight nails, retained hammer, Carpentry 3 and 30 XP; free ten-second repair/pickup like Spike Barriers. These choices require no further recipe confirmation.

Two separately asked tuning questions remain unanswered: (1) proposed 20% trip roll on entering an eligible spike tile while upright/moving, 20% scratch risk for running/sprinting per bed entry, durability 100/200 and one wear per damaging fall; (2) proposed one spike hit for a fresh fall from any source landing on the bed, excluding existing crawlers/lying zombies from repeated hits. Preserve these as pending rather than converting the construction answer into approval of all questions. The patch is in progress; 0.2.29 remains installed. See PATCH_v0.2.30.md for source changes and evidence.

## C95: six durability per fall and confirmed prone-zombie handling (2026-10-06)

Owner answers the two remaining tuning bullets: "Let's do 6 damage to durability per fall. Confirmed prone zombies." Apply six shared bed durability loss per damaging zombie fall, replacing the proposed one wear. Confirm one hit for a genuinely fresh fall from any source landing on the bed, including turret knockdowns, with no repeat hit while lying/getting up and no damage merely for detecting an existing prone/crawling zombie.

Retain the other proposed defaults with this amendment: 20% trip chance per eligible upright moving tile entry, 20% running/sprinting scratch chance per whole-bed entry, and 100/200 durability. This interpretation was stated back while continuing implementation; it does not infer a new universal 2.5x durability multiplier. At six wear, the final damaging fall breaks a fresh basic bed on hit 17 or a reinforced bed on hit 34. Shared recovery remains five seconds after getting up; direct weapon knockdowns remain available during trip protection.
