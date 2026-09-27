# Decision register

Recorded 2026-09-25 from the current planning conversation. This document is authoritative for approval status, not proof that a feature exists.

## Owner-confirmed requirements

2026-09-25 implementation scope update: the owner requested several more checkpoints back to back before testing, within roughly twenty minutes. This authorizes batching P1C2-P1C4 prototype work while P1C1 player acceptance remains pending. It does not waive acceptance criteria or authorize sibling modifications/publication. See the [batch record](checkpoints/P1_BATCH_RECORD.md).

| ID | Requirement | Source |
| --- | --- | --- |
| C01 | One edition; expose a toggle menu in Sandbox options. | Owner's single-edition instruction |
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
| C15 | Players cannot walk into or vault over the Spike Barrier. | Owner's barrier instruction |
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
