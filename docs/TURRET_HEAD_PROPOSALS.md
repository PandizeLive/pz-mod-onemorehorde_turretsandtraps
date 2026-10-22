# Unique turret head candidates

## C404 - Uncapped Arc chains and deferred Splitter branches (2026-10-22)

Owner selects C403 **1A chained pulses / 2B equal base-chain damage / 3A no consumable ammunition**. Owner rejects a total target cap, assigns damage falloff to Piercing after the main chain, and requests auto-aimed Splitter branches to either side. If no additional target exists beyond the initial target, retain the unused split for a subsequent chain connection. This supersedes the proposed fixed victim cap and blanket one-chain/no-branch recommendation. Discussion continues; no gameplay patch or numerical tuning is approved.

### Confirmed intent versus unresolved mechanics

Normal chain jumps should not lose damage merely because they are later jumps. Piercing continuation should still behave as a chain, with reduced damage per piercing. Splitter's side targeting and carry-forward are selected direction; exact branch entitlement sharing and damage/resource handling remain to settle. Existing `TurretStats` has configurable Splitter damage (default 50%) and Piercing retention (default 70%); neither setting is changed here. Existing resource paths use one extra shot per Splitter count, not two extra shots automatically per module. Arc-specific compatibility is not implemented.

There is a real unresolved interaction: if the base chain already continues through every reachable target without a count limit, what constitutes its end and gives Piercing additional targets? Do not silently reintroduce a total victim cap or assume a straight projectile.

### Proposed containment without a victim-count cap

Recommend one hit per victim across every branch of the same pulse, a finite candidate area/set for that pulse, obstruction/target-policy checks at every connection, and incremental authoritative processing within shared work budgets. Avoid adding new arrivals indefinitely or allowing independent pulses to accumulate an unlimited processing backlog. More targets can require more processing time; an uncapped victim count does not mean unlimited synchronous computation or infinite world traversal. Native visual depth, gameplay latency and multiplayer costs still need proof.

Equal base damage over uncapped dense crowds makes total damage grow with crowd size. Resolve jump distance, discharge cadence and power pricing using representative packs before treating the design as balanced. Siphon/Grid and on-hit module propagation need separate explicit review.

### 1 - Chain territory

- **1A (recommended): all jumps stay within the turret's effective range.** No victim-count cap inside that area; a finite eligible set and one-hit rule keep a pulse finite. Range-module behavior remains understandable.
- **1B: initial acquisition uses turret range; chaining uses a separately configurable larger radius.** Greater propagation reach, with more balance and spatial-query cost. Still a finite area, not unrestricted map traversal.

### 2 - When Piercing takes over

- **2A (recommended): gap bridging.** When the chain has no unused target inside ordinary jump distance, a Piercing allowance permits a longer connection. Reduce damage when that allowance is spent; subsequent ordinary jumps retain the reduced damage. Another Piercing continuation reduces it again. This is a new proposal for interpreting the requested end-of-chain effect, not an owner-selected reach rule.
- **2B: a full-damage opening phase followed by a weaker chain phase.** Define how many ordinary jumps comprise the opening phase; Piercing then sustains the diminished continuation. This limits full-damage hops, not total victims, but its exact per-module semantics still require definition.

Do not invent the bridging distance, count, damage, resource debit or shared/per-branch Piercing allocation as settled values.

### Splitter recommendation

Preserve the existing extra-shot allowance as a finite number of split opportunities per pulse. Try distinct targets to either side of the initial aim. If unavailable, carry unused opportunities forward along the chain and try again at later connections in that same pulse. Consuming an opportunity creates an auto-aimed side chain; it does not copy a fresh set of Splitter allowances into every child. All branches share victim reservation/hit tracking so they cannot select the same enemy simultaneously. Unused opportunities expire at pulse completion; they do not accumulate between shots. Side-chain damage should retain the relevant Splitter modifier rather than silently becoming full main-chain damage.

This delivers deferred splitting without recursive branch multiplication. Fragment, Synergy and other secondary effects still need deliberate Arc mappings. The existing shared scheduler demonstrates budgeting infrastructure, not native Arc feasibility or a guaranteed FPS result.

**Decision needed: chain territory 1A/1B and Piercing interpretation 2A/2B.** Installed 0.2.63.2 and deferred personal testing unchanged; no gameplay/source/package edits.


## C403 - Arc Emitter selected next; remaining tracks retained (2026-10-22)

Owner: "We'll do all of these, including Arc Emitter. Let's do arc emitter next. Let's discuss."

Accept the C402 tracks into the intended future scope: shared Trait Shop defense XP, multi-panel/garage-door barbed feasibility/support, coordinated Horde scoring, modder extension documentation/sample, owner-sourced art/release preparation, and Cure simulation (still last). Arc Emitter is now selected for the next design discussion. This does not authorize publishing/deploying, generating final art, choosing unresolved numbers, or starting an unspecified gameplay implementation during this discussion. Installed 0.2.63.2/testing deferral unchanged.

### Existing basis and proposed role

The prior head shortlist describes a damage-focused bounded chain attack without default prolonged stun. Arc is absent from the current `TurretHeads.definitions`; no existing implementation or engine proof is claimed. Recommend an aimed universal-base head with a discrete electrical discharge: strong initial hit and a small capped sequence of nearby eligible targets. Its niche is clustered enemies and electrical supply rather than explosive area damage, projectile piercing or ammunition logistics. It should be less attractive against isolated targets than a comparable dedicated single-target head. This role is a proposal, not approved damage tuning.

### First choices

**1 - Firing behavior.** Recommend finite pulses for readable cadence and bounded processing.

- **1A (recommended): chained pulse.** One initial target, then a finite chain of nearby targets.
- **1B: sustained single-target beam.** Sustained contact damage without chaining; more tracking/presentation work and a less distinct crowd role.

**2 - Damage across a chain (if 1A).** Recommend weaker later jumps so the first target and positioning matter.

- **2A (recommended): diminishing damage per jump.** First victim takes most damage; subsequent hits taper.
- **2B: equal damage per victim.** More dependable crowd damage; needs a lower per-hit damage or tighter target cap.

**3 - Resource model.** Keep the existing turret power-source rules; this choice concerns ammunition.

- **3A (recommended): no consumable ammo, substantial battery cost per discharge.** Power and cooldown pay for convenience. Grid Module/Siphon interactions must be reviewed before numeric balance.
- **3B: consumable electrodes plus lower battery cost.** Adds a supply/crafting burden and an additional item contract; not selected merely because it sounds electrical.

### Recommended constraints, not yet final numerical design

- No default stun-lock, long slowing, fire or building damage. Preserve the existing rejection of general slowing turret effects.
- One chain per pulse, a strict total victim cap, no repeat victim in that pulse, and obstruction/target-policy checks on each jump. Do not create branching recursive chains.
- Charge a declared cost for the committed discharge; specify miss/abort handling and Siphon kill refunds before implementation. Grid supply follows the existing optional Grid Module contract.
- Reuse turret ownership, Controller inputs, Detection/standby and authoritative damage paths. Per-head player injury mapping and shared friendly/hostile modifiers need explicit review, not invented values.
- Module compatibility must be deliberate. Do not let the current non-rotary permissive fallback accidentally enable projectile Fragment/Piercing/Splitter recursion. Review Synergy/Siphon and rapid-fire combinations against a total work/damage budget.
- Prove short-lived native-world arc rendering, depth, replicated endpoints, sound and cleanup; no screen-overlay depth guarantee. Final art remains owner-sourced.
- Include useful settings in an Arc subsection of the existing Turrets Sandbox category. Exposure/ranges/defaults follow the selected mechanic, not speculative inert settings.

After these choices: propose concrete damage/range/jump distance/victim cap/cadence/battery values and representative comparisons; settle module mapping, crafting/skills/repair, audio and any loot rarity using assigned weights. Then obtain concrete patch/prototype approval. No numbers or recipes are selected by C403.

**Decision needed: 1A/1B, 2A/2B if chaining, and 3A/3B.**


**C235 / final capacity selected; ready to implement (2026-10-14).** Owner selects1B:40 spears,20 shared launchable explosives in any mixture,250 ordinary firearm base rounds. [Combined readiness and verification gates](VOID_MODULE.md#c235-final-capacity-selected-ready-for-implementation-2026-10-14). Last presented balance choice settled; remaining work is native integration/validation, not further generic design approval. Installed0.2.49 unchanged; no gameplay/install/test-status change in this readiness turn.

**C234 / shared explosive capacity and Makeshift Bomb confirmed (2026-10-14).** Owner rejects per-explosive-type quotas, chooses Makeshift Bomb naming and approves25%of relative donor-stat difference. [Settled rules and final capacity choice](VOID_MODULE.md#c234-shared-explosive-capacity-and-makeshift-bomb-2026-10-14). One shared bomb count replaces subtype limits/weighted mixing;40 versus20 total bombs remains proposed. No gameplay/install/test-status change.

**C233 / damage-aware ammo limits and attenuated stats (2026-10-14).** Owner asks capacity balance including AoE, replaces Shell wording with grenade, selects retained donor ammo stats with reduced contribution for future alternate-ammo support, and approves whole-potato scope. [Capacity/scaling proposals and native evidence](VOID_MODULE.md#c233-ammo-balance-attenuated-stats-and-separated-decisions-2026-10-14). Vegetable/produce launcher remains an exploration idea. Separate decision blocks with thoughts/options now supersede combined tables in AGENTS.md. Exact capacity and scaling values remain proposals; no gameplay/install/test-status change.

**C232 / selective ammo limits and Void controls selected (2026-10-14).** Owner replaces blanket75% cuts with selective ammo maxima, allows rotten/variant potatoes and requests modded-spear support; selects manual Void beside Ammo, safe module removal and Mythic rarity. Magazines remain. [Native classification evidence and compact remaining choices](VOID_MODULE.md#c232-selective-capacity-broad-ammo-families-and-compact-decisions-2026-10-14). Exact caps, donor-stat normalization and prepared-potato scope remain proposals. Compact decision-table preference added to AGENTS.md. No gameplay/install/test-status change.

**C231 / mini grenades and recipes selected; Void storage proposed (2026-10-14).** Owner selects C2301A and2B, replacing storage option3 with a roughly75% ammo-capacity reduction and portable Void Module holding permanently converted weightless ammo by type. [Approved direction, tradeoffs and remaining choices](VOID_MODULE.md). Reduction scope, normalization, conversion interaction, removal and rarity remain proposals. Preserve five-mini behavior, pump/improvised same-output recipes and earlier unrelated approvals. No gameplay/install/test-status change.

**C230 / selections recorded; recipes, mini grenades and spear expansion open (2026-10-14).** Owner selects C2291A/2A with Lobber Fragment mini grenades/3B/4A/5A/6A/7B/9A with two Scrap Metal/10A/11A/12A with40 spears. [Selections, native storage evidence and three revised choices](NEXT_PATCH_CHOICES.md#c230-owner-selections-and-revised-recipefragment-proposals-2026-10-14). Recipes return for native donor and improvised alternatives. Kits currently increase count, not placed weight capacity; native above100 world-container capacity warns rather than hard-clamps, and larger safe storage remains unproven. No gameplay/install/test-status change.

**C229 / consolidated pre-patch choices (2026-10-14).** Owner requests all remaining choices and recommendations before implementation. [Twelve decision groups](NEXT_PATCH_CHOICES.md) cover mixed ammo, new-head effects, Potato splash overlap, reloads, power, Lure acquisition, exact recipes, player injuries, aiming/travel and the Ballista weight constraint. All A options are recommendations, not approvals; 12A corrects capacity presentation without increasing physical storage. C225-C228 approvals remain intact. No gameplay/version/install/test-status change.

## C228 Combined patch scope and pack-flow correction (2026-10-13)

Owner: "Let's approve a new patch. Recap the new update." Requests adding [Module Pack Skip/Collect and completion-owned rarity audio](PACK_POLISH.md#c228---skip-then-collect-and-completion-owned-rarity-audio-2026-10-13) to the combined update. Record the requested next-patch scope without treating unset balance/recipe choices as selected or claiming implementation has occurred.

Player-facing recap, feature names only:

- Grenade Lobber
- Improvised Shell
- Scrapshot
- Lure Module
- Ballista spear flight and range update
- Ballista ammunition-capacity correction
- Extended rotary reach and coverage
- Rotary Tack and Martyrdom support
- Potato Piercing
- Built-in turret magazines
- Lobber Conservation and Splitter support
- Module Pack Skip/Collect controls
- Module Pack reveal-audio timing

Approved numerical values remain in C225-C227; preserve150/radius4 Shell, native-strength ordinary bombs with linear falloff,5-20tile Lure,2-tile/90-degree rotaries,24-tile/45-degree/24tiles-sec Ballista,8x15/90-degree Scrapshot, and3/5/3/10 custom-head magazines. The capacity correction remains an engineering target requiring native-safe storage/pickup proof; it does not revive packed-weight compression. Final art remains owner-sourced.

Material choices still unset: remaining Lobber/Scrapshot module propagation and mixed-ammo behavior; reload times, power and Lure acquisition/tuning; exact head/shell recipes (including tools/skills/XP/yield), player blast/Scrapshot injuries. User's patch intent does not supply missing recipe values. Consolidate these choices before full implementation rather than repeatedly asking to approve already-selected features. No new gameplay patch/test/install/version state in this recap;0.2.49 remains installed with partial owner findings. Starting34c8e19; fetched origin. Planning mirror under C108/C119.

## C227 Lobber Conservation and Splitter approved (2026-10-13)

Owner selects **C2261B**: Grenade Lobber supports **both Conservation and Splitter**. Retain existing Conservation uses-per-round accounting and stacking, Splitter's50%side-projectile damage and current ammo charging, including insufficient-ammo/full-shot and last-round exceptions. The selected scarcity tradeoff is accepted; do not keep treating inclusion of either module as undecided or silently remove the exceptions for explosives.

Side grenades retain their selected payload's blast radius, linear falloff and separate two-second fuse after landing, with the50%multiplier applied to damage rather than radius or fuse. Base launch interval remains3.5seconds and built-in magazine3. Do not infer side grenades deal full native damage, spawn further Splitters, or cost a full extra payload in every ammo state. Conservation changes consumption, not the identity of an already launched payload; exact unspent items and fractional accounting must survive the existing lifecycle boundaries.

This approval does not settle mixed loaded-payload allocation within one firing event, permit silent conversion of an Aerosol Bomb into a Pipe Bomb, or approve new Fragment/Synergy recursive blast behavior. Recommend one selected ammo type for a firing event and its side grenades, honoring the already approved priority/fallback/safe-switching rules; final mixed-magazine accounting still needs a concrete contract. Piercing exclusion on Lobber remains a separate recommendation, not implied by1B.

Remaining decisions: complete Lobber/Scrapshot module-effect matrix and per-victim/secondary propagation, payload allocation, magazine reload timings, battery/Lure rarity/default/loot rules, exact recipes and player injury. Native trajectory/actor-only blast, bounded workload, reserve-weight and save/pickup proof remain implementation gates. No gameplay patch authorization, source/assets/version/install/test-status change. Inspected f416cd8 and fetched origin before recording. Mirror under C108/C119.

## C226 Rotary effects, Potato contact behavior and Lure range selected (2026-10-13)

Owner selects C225 **1A;2B with "It'll apply on all zombie contacts";3A with5-20tiles**. Confirm Tack and Martyrdom support for both rotary heads; implement Potato Piercing rather than rejecting the module; link Lure audible loudness and attraction range in one slider with5-20tile bounds. This supersedes C225's proposed10-60bounds and30default. No default within the new range has been selected. These are design approvals, not a completed gameplay patch or approval of remaining unspecified rules.

Interpret Potato contact instruction in its presented context: both the normal splash and normal direct-hit knockdown chance occur at **each zombie directly contacted along the piercing path**. Knockdown remains a chance with existing recovery protection, not guaranteed on every victim. This does not turn nearby splash victims into direct contacts or give splash its own knockdown, penetration or recursively repeating splashes. Preserve the separate historical splash crowd-control restriction. Review hit visuals/audio and obstruction at each actual impact; do not apply the full direct-hit handler recursively to splash recipients.

Existing Piercing grants additional contacts according to module count, with70% retained damage per continuation and no wall penetration. Recommend retaining that rule and scaling each contact's splash from its attenuated damage; the new selection does not grant infinite contacts or full damage on all later hits. Per-contact splash overlap may hit the same nearby zombie from more than one direct impact; this balance consequence must be made explicit before final implementation, rather than silently adding a new global per-shot splash cap. Fragment remains its existing endpoint behavior and module-driven secondary effects retain Synergy gating unless separately approved; "all contacts" here answers the previously presented Potato splash/knockdown question, not blanket new module propagation. Any different requested meaning should be reconciled explicitly.

Rotary Tack retains delayed field start, existing lifetime/retrigger and non-stacking overlap behavior. Martyrdom retains delayed death explosions. Every qualifying direct sweep victim can be considered, with once-per-contact accounting and bounded shared work. Existing projectile-count admission cannot be reused unchanged for unbounded crowded sweeps; verify a safe contact-based admission/scheduling strategy without silently dropping effects after spending resources. No recursive death-explosion chain. Other previously excluded rotary modules remain excluded unless selected later.

Lure retains manual/repeating controls and five-second repeat, bundled owned Horde Night audio and no dependency. Exact default, volume mapping, power/rarity and loot weights remain open. No catch-up pulse burst, no direct zombie retarget guarantee and no change to attack Suppression. Current0.2.49 installation/test findings are unchanged. Read-only review of `TurretVolley.pierce/finish`, `PrototypeCombat.hit` and `TurretConservation.consume` confirms these existing behavior boundaries; no runtime test or source edit this turn. Starting commit969f639; fetched origin.

### Next discussion: Lobber ammunition modules (proposals only)

- **1A recommended:** enable Conservation with its existing uses-per-round accounting; exclude Splitter. One Conservation grants two firing uses per round, two grants three, etc. This stretches rare supplies but retains one grenade per firing event and avoids multiplying simultaneous blast work.
- **1B:** enable both Conservation and Splitter. Side grenades would use existing50%side-shot damage, selected payload radius/fuse and normal Splitter ammo rules, including the already established insufficient/last-round exception. This is a deliberate scarcity/power tradeoff, not paid extra ammo in every situation. Mixed payload identity and one ammo type per firing event need a concrete contract before implementation.
- **1C:** exclude both for Lobber; one consumed payload per grenade. Strongest preservation of explosive scarcity, but fewer useful module choices.

Recommend Piercing unsupported on a grenade blast unless a separate physical behavior is desired; do not invent a blast passing through walls or an undeclared blast-radius bonus. These choices are new proposals, not included in this turn's1A answer, which refers to rotary effects. Remaining module matrix, reload/power, recipes/injuries, reserve/trajectory lifecycle and native proof remain open; no gameplay patch approval inferred.

## C225 Selected revisions and previous-head module review (2026-10-13)

Owner selects C224 **1A with Shell150/radius4 and an expensive recipe direction;2B with adjustable volume/range and Horde Night's attraction sound;3B;4A;5A;6B**. Also requests considering modules for previous heads. These selections settle the listed design defaults, not the remaining module/recipe rules or a gameplay patch. Starting development commit a45f57b; fetched origin before recording. Installed0.2.49 and its partial owner findings remain unchanged.

| Confirmed item | Selected behavior |
| --- | --- |
| Lobber ordinary bombs | Native zombie damage roll/radius: Aerosol350-<700/6 tiles, Pipe450-<900/7 tiles, with custom linear center-to-zero-edge falloff. Actor-only, no fire/structure damage; handheld behavior unchanged |
| Improvised Shell |150 center zombie damage,4-tile radius, same falloff; more expensive crafting desired, exact ingredients/tools/skills/XP/yield still open |
| Lure | Manual button plus repeating toggle, five-second repeat interval; user-adjustable volume/range; reuse Horde Night attraction audio. Exact slider relationship/limits, rarity, power and acquisition still open |
| Rotary Bat/Blades |2-tile physical reach via mount extension;90-degree front/rear sectors; retain25RPM angular speed and360 behavior |
| Ballista |45-degree FOV,24-tile range,24tiles/sec spear travel (about1second at base maximum range); shallow visual arc desired, true ballistic clearance still unproven |
| Scrapshot |90-degree fan,8 fragments at15 each,120 total unmodified primary damage if all connect; multiple hits per victim allowed, misses lose their share |
| Built-in magazines | Potato3, Ballista5, Lobber3, Scrapshot10; C2246B scope retains native firearm capacities and exempts ammunition-free rotaries. Magazine growth uses the existing35%/minimum+1/final-ceiling rule unless separately changed |

Capacity here is ready ammunition, not reserve weight. The Ballista44-spear storage mismatch remains a separate engineering issue. Reload timings/overlap must be settled with the selected base shot intervals; do not silently add sequential waits. More expensive Shell materials are direction, not approval to invent a recipe.

### Read-only compatibility and audio evidence

`TurretHeads.supports` currently rejects rotary Filter, Splitter, Piercing, Conservation, Magazine, Reload, Autoloader, Impact, Fragment, Tack, Martyrdom, Synergy, Range and Accuracy. C195-C197 deliberately excluded most of these; owner now authorizes reconsideration, not their automatic activation. `TurretRotary.contact` already applies Critical, Initial Blow and Execute; `TurretStats` applies Velocity damage/reaction, Rapid-Fire/Enhanced Firing motor speed, Regulator, suppression and expansion module slots. Enhanced Detection improves scan interval; its normal3xaim-turn benefit is not3xrotary motor speed. Head-specific descriptions must state actual effects.

Potato currently accepts Piercing as active, counts it in module power, then `TurretStats.resolve` produces piercing0 and `PrototypeCombat.hit` never invokes `TurretVolley.pierce`. This is a verified source-level no-effect compatibility inconsistency, not a newly failed game test. Ballista already calls Piercing, Fragment and hit effects; converting its flight must preserve their timing and meaning. Firearm/Potato existing module support is not a new feature. Potato splash currently does not call proc propagation; any new Synergy-on-splash behavior needs explicit settlement rather than accidental activation during this audit.

Audio file found at `OMH/Audio/Horde Night/soundattraction.wav`, SHA256 `F1D7317FB67773F448EB9164886FDB8B5279F20FF7F514B2FBA09BF8E62FFC35`. Sibling `OMH_sounds.txt` defines `OMH_SoundAttraction` as a non3D UI cue; client bootstrap handles audible cue and gameplay world sound separately. Reuse the owned clip in a Turrets-namespaced positional definition, bundled independently; do not require Horde Night, modify sibling files or copy its protected-call wrappers. Native hearing events attract attention without guaranteeing target replacement. Selected sound is located, not newly auditioned/implemented.

### Proposed next choices (unapproved)

1. **Rotary effects:**1A recommended, add Tack and Martyrdom using existing field/death meanings and delays;1B add Martyrdom only;1C retain current exclusions. A sweep can hit many victims: use per-victim eligibility, existing no-stacked Tack fields/retrigger lifetime, shared bounded work and no recursive explosion chain. Current proc reservations assume projectile counts, so simply removing exclusions would be incorrect. Any gameplay cap needed beyond scheduling must be discussed. Synergy has no distinct work on a plain multi-contact sweep because those are primary contacts; keep it unsupported unless a secondary effect path is separately approved.
2. **Potato Piercing:**2A recommended, mark unsupported, reject new installation and deactivate a carried copy after head swaps without charging its surcharge; preserve the item.2B implement actual penetration; would need to choose where its splash/Fragment occur and whether later hits inherit knockdown. Retain existing splash identity until those rules are chosen. Do not leave an accepted module draining battery for no effect.
3. **Lure controls:**3A recommended, one Loudness slider controlling audible volume and zombie attraction range together, proposed10-60tiles/default30 with Off via toggle;3B separate audible-volume and attraction-range sliders. Either needs bounds and power scaling by attraction radius so a louder/wider lure is not free. The owner approved adjustability, not either mapping or numeric limits yet. Reuse one scheduler with no catch-up burst; Suppression affects attacks, not the explicitly selected lure setting.

Recommend Lure compatible with all heads, including rotaries. Preserve meaningful existing rotary stat effects; keep ammo/reload effects, Splitter, redundant Piercing and Accuracy unsupported on rotary heads. Range must not create invisible reach beyond the extended mount; defer a telescoping-arm adaptation. Filter would only change start/activation criteria, not make a physical sweep spare incidental victims, so it is low priority rather than a free compatibility fix. Lure non-stacking remains recommended, not settled by selecting repeating controls.

Before implementation, complete the module matrix for Lobber/Scrapshot, especially Conservation/Splitter with scarce native bombs, pellet effects and Synergy propagation. Conservation can multiply rare bomb supply and Splitter can multiply blast events; their meaning/cost needs a deliberate choice alongside native-strength ammo. Remaining gates include reload durations, power/Lure rarity and LootLab inclusion, recipes, player injury, projectile/reserve lifecycle and native/rendered proof. No code, asset, version, installation or test-acceptance changes in this planning update.

## C224 Owner head feedback, Lure and magazine redesign (2026-10-13)

Owner requests native bomb damage again, noting scarcity as a reason to retain strength; this is not selection of C2231C yet. Confirms C2232A linear falloff conditionally on the damage choice, and3A multiple Scrapshot fragments may hit one victim, additionally requesting wider spread and more fragments. Replaces the proposed Scrapshot Impact exclusion with4C: built-in magazines for all heads, capacities to discuss. Thus Scrapshot's former no-magazine/no-reload rule and its magazine-related exclusions are reopened/superseded in design; do not implement Impact exclusion. Confirm exact scope for ammunition-free rotary heads before implementation.

Additional requested direction: new player-triggered Lure Module; rotary front/rear angular coverage increased from45 to90 degrees each (angular width, not scan distance); longer bat/blade reach supplied by an extended central mount; Ballista narrower FOV, more range and a visibly travelling spear like Potato, fast but not bullet-fast, with an arc if practical. These are design requests and owner test findings, not numeric default approvals or a completed-patch claim. No new assets generated; final art remains owner-sourced.

### Read-only findings

- Installed42.21 ordinary bomb damage is Aerosol350-<700, radius6; Pipe450-<900, radius7, on OMH's damage scale. [Native calculation evidence](NATIVE_EXPLOSIVE_DAMAGE.md). These are zombie damage budgets before overkill clamping, not player health damage; no native distance falloff. Scarcity makes native-strength ammo defensible, but broad automatic blasts and renewable Improvised Shell balance remain separate. User-reported scarcity has not been quantified in this investigation.
- Ballista's `TurretWorld.fire` branch explicitly clears `projectileSpeed`; `TurretBallista.hit` immediately resolves damage and returns `firearm=true`, hence its bullet trace. The Potato `PrototypeCombat` path already schedules bounded flights, but its arrival resolver and presentation are not a drop-in spear resolver. A shallow presentation arc is feasible in the existing interpolation; genuine ballistic obstacle/roof clearance is not proven and must not be promised. Recommend real travel-time impact, spear presentation and a shallow visual arc while preserving obstruction rules.
- `Turret.configure` clamps placed storage to100 weight units; `TurretTransfers.rejection` additionally checks native `hasRoomFor`. Native Crafted Spear weighs2.0. Ballista inherits advertised100 ammo before expansion, creating a real mismatch for heavy spear feed. Owner reports44 spears; console0.2.49 confirms ammo/full-transfer rejections and an ammo43/loaded1 state, consistent with the weight bottleneck. Exact item-weight inventory snapshot was not captured. This is reserve/container storage, not a44-round magazine. Do not raise capacity beyond prior native safety limits or change player-held spear weight without native proof and a lifecycle-safe design.
- Rotary range is1.25; motion, contact, targeting and overlay use45-degree front/rear sectors. All must agree when changing to90. At the retained25RPM angular speed, wider sweeps take longer to reverse; do not silently double motor speed to preserve the old short stroke time.
- Native `STrapGlobalObject.addSound` uses `addSound` to attract zombie hearing. Lure can reuse world sound plus an audible cue and bounded cooldown; it should not directly assign zombie targets or promise every zombie will abandon its current target. Multiplayer authority remains a separate verification gate.

### Next options (new numbering for this response; all proposals)

| Group | A (recommended) | B |
| --- | --- | --- |
|1 Lobber strength|Native ordinary-bomb damage/radii, with selected linear falloff; Improvised Shell120 at radius2|Strict native ordinary-bomb damage/radii without falloff; Shell value still separate. Would replace conditional2A for ordinary bombs|
|2 Lure controls|Manual Play Lure button; radius30;10-second cooldown|Manual button plus repeating toggle; radius30; one pulse every5seconds|
|3 Rotary reach|1.75 tiles, from1.25, with90-degree front/rear sectors|2 tiles, same sectors; more coverage/clearance needed|
|4 Ballista profile|45-degree FOV,24-tile range,24tiles/sec; about1second at maximum range|30-degree FOV,30-tile range, same24tiles/sec; about1.25seconds at maximum range|
|5 Scrapshot spread/fragments|90degrees,8x15=120 total primary damage|120degrees,10x15=150 total primary damage|
|6 Built-in magazines|Potato1, Ballista3, Lobber1, Scrapshot6|Potato3, Ballista5, Lobber3, Scrapshot10|

Group1A means native-strength **center** damage plus custom falloff, not exact native blast behavior. Other damage/radius proposals remain alternatives if owner rejects both. No-fire/no-structure and2-second landing fuse remain confirmed. Group3 preserves angular speed, not former reversal interval. Group4's speed and arc require matching delayed collision/damage presentation; no additional damage buff or guaranteed bypass over walls. Preserve lower Ballista accuracy unless explicitly changed; expanded ranges change its distance curve and energy factor and must be shown honestly.

Recommend both group6 bundles apply to ammo-using custom heads only, retain actual native firearm capacities, and exempt ammo-free rotary heads. This exception needs owner confirmation because their wording was all heads. Magazine/Reload/Autoloader/Impact should be reviewed again for Scrapshot with real magazine/reload events. No invented rotary ammunition or swing-count reload. Existing per-head base shot cadence is retained; new reload durations/overlap still need selection. Capacity is ready ammunition, separate from reserves/weight;3 Ballista ready spears will not by itself fix the44-spear storage ceiling.

Lure should be powered, non-stacking and use the shared scheduler with no catch-up sound bursts. Sound choice, rarity/loot weight (including LootLab/packs), battery cost and repeat-state lifecycle remain open. Suppression must not silently shrink an explicitly selected lure radius. These defaults and exclusions are recommendations, not owner approvals. Fragment count increases total damage at the retained15 each; do not claim90 remains the approved new total after increasing count. Module propagation, head/shell recipes, reserve solution, player injury and native projectile/persistence proof remain subsequent decisions/work.

No gameplay/source/version/install change this turn. Owner now supplies partial0.2.49 feedback; update its test record rather than retaining a blanket no-client-evidence statement or marking unrelated checks passed. Inspected c3a2f1e and fetched origin before recording this update.

## C223 PC damage findings and remaining decision agenda (2026-10-13)

Owner asks to discuss everything still requiring discussion, including damage. This authorizes investigation and planning, not a gameplay patch. Inspected active development38b5e397 and fetched origin; prior C211-C222 selections remain authoritative. Installed0.2.49 and deferred owner acceptance are unchanged.

The [installed42.21 damage trace](NATIVE_EXPLOSIVE_DAMAGE.md) supersedes historical42.0 inputs. Ordinary Aerosol Bomb zombie damage potential is350 to below700 on OMH's scale, radius6; Pipe Bomb450 to below900, radius7, before overkill clamping and exceptional hooks/states. The native path has no distance falloff. Player injury is a separate native path. Do not call earlier turret proposals native-equivalent, or mistake this investigation for complete in-world blast verification.

### Current options, all unapproved

| Choice | A | B | C |
| --- | --- | --- | --- |
| 1. Lobber damage: Shell / Aerosol / Pipe | **Recommended:80/120/180**, radii2/3/4; Shell mainly wounds |120/180/240, same radii; stronger center hits | Preserve ordinary bombs' native damage/radii; Shell still needs a value. Not recommended for automatic crowd clearing |
| 2. Tuned-blast falloff (1A/1B) | **Recommended: linear center-to-zero edge** | Full damage through inner half, then linear to zero | Not applicable |
| 3. Scrapshot victim allocation | **Recommended: multiple fragments may hit one zombie**, maximum90 unmodified if all six connect; misses keep their lost share | One fragment per zombie, maximum15 unmodified per victim; more crowd-focused | Not applicable |
| 4. Scrapshot Impact | **Recommended: unsupported**, since there is no empty reload | Adapt its trigger; would need a separate explicit design, not an automatic refill/always-on substitution | Not applicable |

Selecting one option does not approve all other recommendations or authorize a patch. Choice1C deliberately differs from tuned falloff; reconcile before implementation if combined with choice2. Existing Scrapshot60-degree/six-fragment spread remains;3A permits multiple physical hits rather than guaranteeing six hits on the selected target.

### Remaining topics after these choices

- **Module compatibility:** produce an explicit per-head matrix. Lobber Splitter, Piercing and secondary effects need blast-specific decisions; Scrapshot direct-feed Splitter/Conservation accounting cannot silently inherit a chamber's last-round exception. Decide critical/Initial Blow/Execute application once per shot versus per fragment and Synergy/Fragment/Tack/Martyrdom propagation. Recommend preserving established module meanings, preventing recursive effect chains and avoiding six independent full-strength secondary bursts by accident; no blanket exclusion or new per-shot proc rule is approved here.
- **Accuracy, collision and danger:** Scrapshot criticals/knockback and player collateral; Lobber scatter and player injury severity/body status. Recommend normal obstruction checks and injury processing once per blast, not once per nearby square. Actual roof/door/arc obstruction and actor-only environmental isolation require local proof. Do not equate zombie damage with player HP.
- **Feed, storage and power:** Lobber loaded capacity/reload overlap versus its settled3.5-second base cadence; safe-switch action duration; both heads' reserve limits/loading and calibrated battery costs with current module/Regulator rules. Damage/radius should be chosen before battery tuning. No new idle drain or additive cooldown is implied.
- **Recipes and service:** exact head/shell ingredients, tools, skills, XP, weights and shell yield. Recommend existing base-only wear/service and integrated head mounts; no separate head durability or new handheld shell use. Numeric recipes must be reviewed before code.
- **Audio and visible feedback:** choose launch/landing/fuse/blast cues, Scrapshot report and readable danger feedback. Final art remains owner-sourced; native sound suitability and cube placeholder behavior must be verified.

Engineering responsibilities, not additional owner questionnaires: exact-item preservation across switching/pickup/save, one-time delayed detonation, unloaded/pause behavior, bounded spatial queries/effect work, no recursive proc explosion, native authority and no fire/building damage. Flag concrete limitations if discovered. R3C3 native trajectory/blast prototype remains a gate after the design is settled; R3C2's existing owner test remains deferred.

## C222 PC planning reconciliation (2026-10-13)

User: "I used our planning chat to update. Check github for new progress." Read the live branch/PR inventory. The planning branch contains ten commits after63c32db, through5b623ef7e11b9e5114054485b0eaeb6f61ea7a32; only CURRENT_STATUS, PLANNING, DECISIONS and this contract differ. Imported those commits with author/provenance preserved, then recorded this pickup. The Cloud branch has no PR because its API access was blocked; the existing development draft PR#1 now carries the synchronized documentation. No PR merge, source change, version bump, game test or new implementation approval follows.

Latest selected values, overriding historical proposals:

| Item | Current approved design |
| --- | --- |
| Lobber ammunition | Turret-only Improvised Shell, ordinary Aerosol Bomb and Pipe Bomb; show loaded types/counts and actual next payload separately from reserves |
| Ammo priority | Player-ordered; Use next ammo type defaults OFF; stop on preferred exhaustion unless enabled |
| Switching | Conflicting priority change pauses for explicit safe unload/reload; preserve exact round; if storage cannot accept it, block swap; fallback returns to preferred at next normal load |
| Lobber timing/range |6-18 tiles;3.5-second base launch interval; independent2-second fuse starts after landing |
| Lobber collateral | Zombie/player damage, no fire or structural damage; native handheld behavior unchanged |
| Scrapshot | One loose ScrapMetal per shot;2-second interval; no magazine/reload;6-tile reach,60-degree total shot spread |
| Scrapshot primary damage | Six fragments at15 each;90 total if all connect before modifiers; misses/obstruction lose their share |
| Scrapshot exclusions | Magazine, Reload, Autoloader approved; Impact exclusion still proposed |

Do not reopen the shell/roster/fuse/priority decisions as unanswered. Do not mistake approved90 total for90 per fragment or per victim, or substitute earlier120/180 proposals. Native explosive HP conversion (C215/C216) is the next local technical follow-up, not resolved by old power metadata or42.0 source. Remaining compatibility, player injury, power, recipes and fragment victim/hit details still need settlement before implementation. No new native-damage result is claimed during this sync. Installed0.2.49 and deferred owner acceptance remain unchanged.


## C221 Scrapshot six fragments at 15 damage each (2026-10-13)

Owner selects **1A - 15 damage per fragment**, amending C220's recommended per-fragment value while retaining its six-fragment count. Approved base **zombie** damage is therefore **6 x 15 = 90 total per shot**, not 120. Do not retain the proposed 20-per-fragment value or interpret 90 as damage to every target. Existing selected rules remain: one Scrap Metal per shot before any later approved module accounting, two-second base firing interval, no magazine/reload cycle, six-tile maximum, 60-degree total spread, and shared whole-shot damage budgeting. Magazine/Reload/Autoloader stay unsupported under C220.

A missed or blocked fragment loses its share; do not redistribute that lost damage to other hits. Ninety is the total unmodified primary-shot budget if all six fragments connect, not guaranteed damage to the selected target or a kill guarantee. Actual victim distribution, possible multiple hits on one victim, accuracy/critical/knockback, collateral and secondary-module interactions still need a compatible hit contract. At the selected baseline cadence the theoretical primary damage budget is 45 per second before misses, obstruction and modifiers. This arithmetic is not measured gameplay balance.

### Next recommendation: Impact compatibility

Recommend **Impact unsupported on Scrapshot as well**: its existing first-shot-after-empty-reload condition has no matching reload event on the selected direct-feed head. Do not invent a refill trigger, timed entitlement or always-on stumble adaptation. C220 approved only Magazine, Reload and Autoloader exclusions; Impact exclusion remains a recommendation awaiting the owner, not automatically included in this answer. `docs/PATCH_v0.2.42.md` records the existing trigger and later Conservation planning explicitly preserves the real empty-reload condition. Preserve Impact behavior on other heads.

After that, review the remaining projectile modules using their established meanings, including concrete direct-feed resource handling where required; no blanket compatibility claim. Power/critical/knockback/player danger and recipes remain separate decisions. Grenade Lobber stays at 3.5-second launches and a two-second post-landing fuse; its native damage comparison is still assigned to the PC. No new patch authorization, game tests or owner acceptance; installed 0.2.49 test remains deferred.

## C220 Scrapshot feed and module exclusions approved; damage choices (2026-10-13)

Owner: **Approved, what's next to discuss?** This approves the immediately preceding recommendations: **one Scrap Metal per Scrapshot shot**, **multiple fragments sharing one total shot damage budget**, and **Magazine, Reload and Autoloader unsupported on Scrapshot**. Keep C219's two-second base shot interval, no magazine/reload cycle, and C218's six-tile maximum/60-degree spread. Do not expand this approval into a full module matrix or gameplay implementation authorization. Impact was not among the three explicitly presented exclusions and remains a compatibility question.

Grenade Lobber retains 3.5-second base launch interval, two-second post-landing fuse, 6-18-tile engagement range and the approved ammo-priority/fallback/switching rules. Native bomb health damage remains assigned to the PC's current decompiled code. Installed 0.2.49 owner acceptance remains deferred.

### Next discussion: Scrapshot fragments and total damage

Recommend a small concrete baseline rather than a new combat mechanic: **six fragments per shot**, sharing **120 total zombie damage** before modifiers. Six permits a bounded shot with a simple 20-damage share per fragment. This is a proposed starting balance, not a measured shotgun equivalent, native engine outcome or owner-approved fragment count. It does not introduce a new global pellet cap or alter other heads.

Present two choices using the same proposed six-fragment count:

| Option | Fragments per shot | Total base zombie damage | Base damage per fragment |
| --- | --- | --- | --- |
| **1A recommended: moderate** | 6 | 120 | 20 |
| **1B: stronger** | 6 | 180 | 30 |

Both are proposals; the owner can change the fragment count or values instead. At the approved two-second base shot interval, theoretical primary damage budgets are 60/90 per second before misses, obstruction, target distribution, modifiers and other limits. These are total shot budgets across all primary victims, not full damage to each zombie in the spread or guaranteed per-target DPS. The lower recommendation starts conservatively with common scrap feed and no reload downtime; cost effectiveness and crowd performance still need local measurement.

Recommend preserving the existing shared-budget principle when resolving misses: fragments that miss or are blocked lose their share rather than redistributing it to surviving hits. The 60-degree pattern's distribution and whether several fragments may strike one victim still require an explicit compatible hit contract before local implementation. Do not claim the current mounted-shotgun approximation already supplies that geometry. Player collateral, accuracy, criticals, knockback, power, storage, remaining module effects and head recipe remain open. No tests or gameplay changes this turn.

## C219 Scrapshot direct feed and revised Lobber firing interval (2026-10-13)

Owner: **Let's do every 2 seconds, and a reload isn't necessary since there's no mag. We'll change grenade launch to 3.5 seconds.** This settles the following design values:

| Head | Base interval between shots | Feed/reload decision | Other retained choices |
| --- | --- | --- | --- |
| Scrapshot | 2 seconds | No magazine and no reload cycle; consume actual loose feed as needed for a shot | 6-tile maximum, 60-degree total shot spread |
| Grenade Lobber | 3.5 seconds, replacing C213's 2 seconds | Existing mixed-ammo priority/safe switching decisions retained; no new feed/capacity rule selected here | 6-18-tile range; separate 2-second fuse starts after landing |

The no-magazine/no-reload direction applies to Scrapshot in this exchange, not an inferred removal of the Lobber's ammo switching rules. No artificial magazine, reload wait or extra volley timer for Scrapshot. Inventory loading/transfer is distinct from a firing reload cycle; absence of a magazine does not grant free ammunition or bypass ordinary target, power and cooldown requirements. Use the shared firing path with an explicit direct-feed capability; exact implementation needs local verification. Do not implement source or tooling from this design approval.

The two head firing intervals are base values before separately reviewed compatible modifiers. Lobber's post-landing fuse is unchanged and independent of travel time and firing cadence. Existing launched rounds retain their identity/fuse. The native explosive health-damage question remains for the PC's current decompiled code under C215/C216.

### Next recommendation, not yet approved

Recommend **one Scrap Metal per shot**, releasing multiple fragments that share one total shot damage budget. This matches the existing whole-shot pellet-budget principle and avoids multiplying the full displayed damage by fragment count. Consumption was not selected by the owner's timing answer; fragment count and total damage still need agreement. Do not automatically grant the current firearm pellet/target caps or a damage-per-pellet number. Preserve the selected 60-degree pattern without silently changing other heads.

No magazine implies the existing Magazine/Reload/Autoloader effects have no ordinary job on Scrapshot; recommend marking those unsupported rather than inventing replacement effects. Impact's opening-magazine trigger also needs a compatibility decision. These are consequences to discuss, not an approval of a complete module matrix. Rapid-Fire is a natural candidate for the existing shot-interval effect, subject to the later compatibility/power contract. Prior compatible-module rules on other heads are unchanged.

Still open: ammo quantity, fragment count/total damage, hit distribution, player collateral, criticals, knockback, battery, reserve capacity, applicable module effects and head recipe. Installed 0.2.49 and its deferred owner acceptance remain unchanged. No gameplay tests, version bump, source/assets/tooling changes or release publication.

## C218 Scrapshot consistency correction and plain firing terms (2026-10-13)

Owner selects **1A**, explicitly accepts **60 degrees**, and challenges why the discussion deviated from existing spread behavior or invented unnecessary mechanics. Owner also challenges the terms "volley" and "every however many seconds". Record C217 1A's six-tile maximum and 60-degree total shot spread as the selected proposal; do not infer approval of C217 option 2, its one-scrap quantity, or either two/three-second timing. Owner requests that useful differences be offered as recommendations with reasons, not introduced as necessary bespoke systems. This is a planning correction, not gameplay implementation approval.

### Read-only comparison with existing behavior

- Current `Source/42.20/media/lua/server/OMHTT/FirearmCombat.lua` resolves native projectile count (bounded 1-9), shares the whole-shot damage budget across those pellets, and assigns them to the selected victim plus at most two nearby valid victims within 1.2 tiles of that victim. It does **not** define a general 60-degree shotgun cone. This current approximation is not proof that native shotgun spread is 60 degrees.
- `TurretVolley.angle` separately supplies Splitter's existing alternating/paired 15-degree side steps, compressed only when needed to stay within 180 degrees. Neither this module pattern nor targeting coverage should silently be replaced by a Scrapshot spread proposal.
- `TurretStats` and `Firearms` already distinguish shot cooldown, reload, chamber/racking and supported module modifiers. Volley is an existing internal term for a firing event plus its projectiles; it is not a new player-facing attack mode or an extra timing gate.

The assistant's purpose in suggesting 60 degrees was a broad close-range scrap shot. It had not established a reason to replace the existing shot model or explained that it was introducing a new angular pattern. Retain the owner's selected angle as Scrapshot's intended pattern, but the PC must reconcile it with the shared projectile handling before promising a working implementation. Do not rewrite other heads' spread, the turret targeting arc or Splitter angles. Final technical interpretation should be explained if the owner meant a different existing spread concept; no silent reinterpretation.

### Corrected recommendation and remaining choices

Use **shot**, **fire rate/shot cooldown**, **reload time** and **ammo per shot** in the discussion. A Scrapshot shot is the single trigger event that releases its scrap projectiles; "volley" in C217 meant that event, not multiple separately timed shots. The proposed every-two/three-second wording meant candidate base shot cooldowns, not a new wait after ordinary reload. Neither timing was selected. Recommend reusing the shared firing/reloading/module framework and choosing the head's base values within it, without an additional volley timer or head-specific timing system.

One loose Scrap Metal per shot remains a simple recommendation, not approved consumption. Actual fragment count, damage distribution and ammo accounting still need a concrete proposal; native/modded compatibility must preserve real identity. Fire rate, reload time, capacity and applicable module effects remain open. Lobber's already approved two-second launch interval and separate two-second post-landing fuse are unchanged. Native explosive damage remains assigned to the PC under C215/C216. No test, version, source, asset or tooling changes; installed 0.2.49 owner acceptance remains deferred.

## C217 Ammo switching selected and Scrapshot pattern options (2026-10-13)

Owner selects C216 **1B / 2A**. Confirm: a player priority change that conflicts with the chambered round pauses firing and requires an explicit safe unload/reload action, preserving the exact unspent round. If storage cannot accept that item, preserve it and block the swap rather than discard it. No free instantaneous conversion or effect on launched rounds. With fallback enabled, return to the preferred type at the next reload when available, without changing the identity of a round already chambered. This automatic selection at a normal reload is distinct from the player's explicit priority-change action; no mid-chamber automatic swap is implied. C211 fallback default OFF, visible loaded types/counts and actual next round remain selected. Native action timing and support across modded ammo/heads still need local proof.

C215/C216's native explosive damage comparison remains an explicit PC follow-up using current decompiled code. No new damage selection, implementation approval, version or owner-test result. Installed 0.2.49 acceptance remains deferred.

### Next proposals: Scrapshot's role and firing pattern

Loose Base.ScrapMetal feed is already selected by C210. Its intended distinguishing role is converting scavenged material directly into a short-range volley without requiring shotgun shells or a new ammunition craft. Range/spread and feed/cadence below are proposals, not verified balance or native capabilities. Confirm actual usefulness against existing mounted shotgun/module combinations during local development.

- **1A recommended: broad close-defense fan**, 6-tile maximum range and 60-degree total shot spread (plus/minus 30 degrees around aim).
- **1B: tighter reach**, 8-tile maximum range and 35-degree total shot spread (plus/minus 17.5 degrees around aim). More concentrated and farther-reaching, but closer to the existing mounted-shotgun role.
- **2A recommended: one Scrap Metal per volley, one volley every three seconds.** At uninterrupted base cadence, theoretical feed demand is 20 items/minute before resource/reload limits.
- **2B: one Scrap Metal per volley, one volley every two seconds.** More responsive at theoretical 30 items/minute; damage and energy per volley still require agreement. The selected two-second Lobber interval does not automatically apply to Scrapshot.

Spread is the firing fan, not the head's detection/targeting field of view. This proposes discrete projectile paths rather than automatic damage to every actor in the cone. Pellet count/damage, distribution, multiple pellets hitting one victim, obstruction, falloff, injury, minimum range, reserves/loading, criticals, knockback, power, module effects and recipes remain unselected. No maintenance/wear rule from the historical shortlist is revived. C206 base-only maintenance direction remains the reference for service discussion. Options may be adjusted individually; choosing these numbers does not settle the remaining mechanics. Recommend 1A/2A, then define the actual volley before choosing damage.

## C216 PC damage follow-up and ammo switching discussion (2026-10-13)

Owner explicitly directs keeping the native damage question for the PC once its decompiled code is available, then asks what else to discuss. C215 is now an owner-requested PC follow-up: answer the actual normal Pipe Bomb/Aerosol Bomb health-damage conversion against the installed build before presenting a native-equivalent turret balance. Historical formulas remain reference only. Damage/radius/falloff options stay unselected; do not block unrelated design choices on this investigation or repeat the historical raw inputs as health loss.

Next proposed discussion concerns priority changes with an already chambered payload and return from fallback. C211 player-defined priority and fallback default OFF are already selected; do not reopen them. The mixed loaded-ammo display is also selected. These new options concern the committed next round, not dropping other loaded/reserve types or imposing a one-type inventory restriction. Actual feeder/chamber support across heads needs local verification; no universal mod-weapon compatibility is claimed.

**1A: finish the chambered round.** A priority change affects the following load; the next shot still uses its actual chambered payload. Keep that payload visibly marked as next. Simple and uninterrupted, but may spend one valuable round after the player changes preference.

**1B recommended: pause and switch safely.** If a priority change selects a different type than the chambered round, pause firing and require an explicit unload/reload action. Return the exact unspent round to storage; preserve it if storage cannot accept it. Do not destroy, convert or silently discard ammunition, and do not consume another lower-priority round merely to clear the chamber. No free instantaneous swap; native supported action timing and interruption behavior remain local design/proof work. Already launched rounds retain their original payload/fuse.

**2A recommended: return to the preferred type at the next reload/selection opportunity when it becomes available.** Applies while fallback is enabled. A previously chambered fallback round retains its identity; apply the selected switching policy, not a mid-flight replacement. UI distinguishes actual next round from preferred type.

**2B: keep using the fallback type until it runs out**, then reconsider the priority list. Fewer changes, but may continue spending lower-priority ammunition even after the preferred supply is restored. Explicit user priority changes still follow choice 1.

Historical options: C217 selects 1B/2A; 1A/2B are not selected. No new capacity, magazine layout, switching duration, player-injury rule, gameplay implementation or test status is settled. After ammo handling, continue with Scrapshot range/feed/spread and then module/power/recipe rules; native explosive damage remains assigned to the PC. Installed 0.2.49 owner test stays deferred.

## C215 Explosion damage trace and version mismatch (2026-10-13)

Owner requests determining what native explosion power equates to. Read-only Cloud investigation found a concrete historical formula, but **does not establish current B42.21 health loss**. No game installed, game-dependent test run, native game artifact downloaded or gameplay file changed.

### Historical public code, explicitly Build 42.0

Pinned public reference: [piromasta/PZDecompiled at 8032006](https://github.com/piromasta/PZDecompiled/tree/8032006b1d52490cbad1dd228f3380d38f7e0612), branch beta/unstable/b42. [Core.java line 144](https://github.com/piromasta/PZDecompiled/blob/8032006b1d52490cbad1dd228f3380d38f7e0612/zombie/core/Core.java#L144) declares GameVersion(42, 0). It is not the installed 42.21 source.

[IsoGridSquare.explosion, line 8966](https://github.com/piromasta/PZDecompiled/blob/8032006b1d52490cbad1dd228f3380d38f7e0612/zombie/iso/IsoGridSquare.java#L8966) computes `p = min(ExplosionPower, 80)` then calls character Hit with `Rand.Next(p / 30.0, p / 30.0 * 2.0) + ExtraDamage`, a synthetic Base.Axe and a fake zombie attacker. Substituting the recorded power inputs:

| Item power input | Capped power | Historical raw Hit input, before ExtraDamage and further processing |
| --- | --- | --- |
| Aerosol Bomb 70 | 70 | approximately 2.333 to 4.667 |
| Pipe Bomb 90 | 80 | approximately 2.667 to 5.333 |

This is **not HP loss** and not a 233-467/267-533 OMH damage claim. In that same historical source, processHitDamage applies target/attacker/weapon-dependent factors and hitConsequences applies weapon-category reduction. ExtraDamage and the synthetic weapon/attacker state also need evidence. Do not mix this old caller with new downstream code to fabricate an exact result.

Historical drawCircleExplosion performs a same-floor radius test and line-of-sight/closed-door exclusion; its damage call contains no explicit distance falloff. It also invokes environmental burning/fire from ExplosionPower independently of the item's separate fire branch. Therefore zero item fire settings alone do not establish that a native blast is environmentally harmless. These are historical observations, not confirmed 42.21 behavior. Player burn/body-part processing exists separately, so a single zombie damage number would not describe player injuries either.

### Newer repository bytecode demonstrates why the old result is insufficient

The committed p1combat server log identifies **42.20**. Its [IsoGameCharacter bytecode](../diagnostics/p1combat/IsoGameCharacter.javap.txt) has processInstantExplosionHitDamage returning input damage times the supplied multiplier, selected when HandWeapon.isExplosive is true (around line 15007). hitConsequences calls CombatManager.applyGlobalDamageReductionMultipliers and CombatManager.applyDamage (around line 15235). This differs materially from the public 42.0 synthetic-axe implementation. The repository lacks the matching complete explosion caller and CombatManager dump needed to trace actual values. No claim that current normal bombs use either path has been verified here. The mod's own Damage.lua uses direct native health subtraction and reports damage100 = health loss * 100; arbitrary raw Hit arguments cannot be compared to that scale.

### Exact PC follow-up

Read current installed **42.21** item definitions for both ordinary payloads, including ExtraDamage and explosive classification. Trace IsoTrap's triggering path, IsoGridSquare's explosion loop (and any replacement helper), the actual HandWeapon supplied to Hit, IsoGameCharacter.processHitDamage/hitConsequences, CombatManager.applyGlobalDamageReductionMultipliers/applyDamage, and player-specific body-damage handling. Record game/JAR identity and method evidence. Determine random bounds, power cap, distance/obstruction behavior, repeat-hit behavior, environmental effects and player injury separately. A local controlled health-delta check belongs on the PC if source/bytecode alone does not settle it; Cloud does not run it. Existing 42.21 item power/range evidence alone is insufficient.

C213 turret damage/radius/falloff proposals remain unselected; no balance change, new patch approval or owner-test result follows. This investigation narrows the missing prerequisite instead of declaring an unverified historical conversion current. GitHub API searches returned Forbidden; public raw GitHub source and native Git reads worked. Installed 0.2.49 owner acceptance stays deferred.

## C214 Native explosive baseline question (2026-10-13)

Owner asks how much damage normal Pipe Bombs and Aerosol Bombs do before choosing the proposed turret balance. Repository C209/C210 records installed B42.21.0 script evidence: ordinary Base.PipeBomb has ExplosionPower 90 and ExplosionRange 7, with zero fire settings; ordinary Base.Aerosolbomb has ExplosionPower 70 and ExplosionRange 6, plus FireStartingChance 10 and FireStartingEnergy 20. These are native explosion parameters, **not verified 90/70 health damage per target**. The available Cloud records do not establish the native power-to-health calculation, distance/randomness/obstruction behavior or resulting player versus zombie damage. Do not invent that conversion or compare C213's proposed direct zombie damage as if the scales matched.

PC follow-up: inspect the current installed native explosion damage path and, when authorized as part of local work, verify representative damage outcomes before claiming parity with handheld ammunition. Preserve the distinction between native Aerosol ignition and the approved no-fire turret behavior. No game installation or game-dependent test in Cloud. C213 payload damage/radius and falloff remain unselected; the prior 80/120/180 and 120/180/240 bundles are arbitrary proposed turret baselines, not measurements of stock explosives. No new design choice or implementation approval is inferred from the question. Current installed 0.2.49 and deferred owner test are unchanged.

## C213 Approved Lobber range and two-second cadence (2026-10-13)

Owner answers C212: **1A / 2 - 2seconds**. Approve the **6-tile minimum / 18-tile maximum** unmodified engagement range and replace the proposed six/eight-second launch intervals with **one launch every two seconds**. This is the base firing interval, not a correction to C211's separately approved **two-second fuse after landing**. Travel time precedes that fuse. Resource, aim and legal-target requirements still apply; reload overlap, capacity and module modifiers remain to settle without silently slowing the selected baseline.

At uninterrupted base cadence the theoretical launch demand is 30 rounds/minute, three times the previous six-second recommendation. This is timing arithmetic, not a measured practical firing rate or a newly approved ammo/power budget. Multiple payloads may be airborne or awaiting detonation simultaneously; local implementation must preserve each committed payload's identity, fuse and resource accounting. Two seconds between launches does not imply two seconds from launch to explosion. The selected minimum range is a targeting restriction, not guaranteed bystander safety.

Current next discussion: payload zombie damage/radius and falloff. All numbers below are **proposed starting values**, not native-item conversions or owner approvals. Native handheld item behavior stays unchanged. The current actor-only/no-fire/no-structure rule and C211 roster/priority/fallback remain confirmed. Player injuries need a separate agreed rule; do not copy these zombie numbers onto player body parts.

| Payload | 1A restrained damage, recommended | 1B heavier damage | Proposed radius for either option |
| --- | --- | --- | --- |
| Improvised Shell | 80 | 120 | 2 tiles |
| Aerosol Bomb | 120 | 180 | 3 tiles |
| Pipe Bomb | 180 | 240 | 4 tiles |

Values are peak damage per zombie per blast before falloff/modifiers; they are not percentages, guaranteed kill counts or total group damage. Both bundles propose these radii; the owner may change individual values. Recommend 1A because the selected two-second launch interval already gives substantial crowd coverage; supply costs, payload density and module effects still need combined balance review. Do not infer additional direct-impact damage or guaranteed knockdown.

**2A recommended:** linear falloff from full damage at the center to zero at the radius boundary. **2B:** full damage across the inner half-radius, then linear falloff to zero at the outer edge; more forgiving against moving crowds, with greater aggregate damage. Both remain proposals. Blast obstruction, player injuries, head/ammo recipes, capacity/reload, battery, module propagation, targeting/trajectory and Scrapshot details remain unresolved. No implementation approval, gameplay changes, new tests or change to the deferred 0.2.49 owner acceptance.

## C211 Cloud ammunition decisions and PC handoff (2026-10-13)

Owner continued C210 in the Cloud Planning chat. Decisions below are design approvals only; no implementation, recipe, installed version or test acceptance changes. Inspected active development checkpoint `63c32db96290aac36d497a5d065aef68388df270` on `codex/performance-barbed-audit`; it contains current `origin/dev` (`5fc6446`). Cloud planning is recorded on `planning/lobber-ammunition` based on that unmerged checkpoint so the latest decisions and implementation context are preserved. PC should fetch this branch and reconcile/cherry-pick its documentation commits into its active development branch before further design or implementation; do not assume chat synchronization or automatically merge PRs.

### Confirmed owner selections

- Owner requests visible additional ammunition when multiloading, including future supported mod-added weapon ammunition. Show each loaded type and count, using actual item names/icons, plus the next ammunition to fire. Reserve inventory and rounds actually loaded must remain distinguishable. Exact controls/layout remain design work; no mockup capacity is an approved capacity.
- Owner selects **2B: player-controlled ammunition priority**, replacing the proposed load-order rule. Players can order ammo types rather than having inventory order choose the payload.
- Owner selects **3B: stop when the preferred type runs out unless fallback is enabled**. The player-facing **Use next ammo type** toggle defaults OFF. With fallback enabled, follow the player's priority order; proposed blocked status is **Preferred ammo empty**. Do not silently spend a lower-priority valuable payload while fallback is OFF. Loaded/chambered-round switching and return-to-preferred behavior still need agreement and native feasibility review.
- Owner selects **1A: Improvised Shell, ordinary Aerosol Bomb and ordinary Pipe Bomb** as the initial Lobber roster. The shell is turret-only ammunition. Player-facing explanation: **Requires the launcher's powered arming system; cannot be thrown by hand.** No new handheld explosive or conversion into one is authorized. Proposed tier direction is Shell < Aerosol Bomb < Pipe Bomb in blast power/radius; exact values, costs and recipes are unselected. Earlier alternate roster recommendations remain historical.
- Owner first wrote **1A / 2C**, then corrected **2A I meant**. Final choice is **two seconds after landing**, explicitly replacing the three-second option. It is not an in-flight fuse or impact detonation.
- C210's blast rule remains: zombie/player damage, no fire or structural damage. Turret use of Aerosol Bomb must respect that rule without changing its native handheld behavior. Loose Scrap Metal for Scrapshot remains selected; quantity is undecided.
- Owner now directs: **Keep continuing this planning process and update GitHub every time. I'll use this until the PC chat picks it up.** Continue the C108/C119 per-turn documentation/push workflow without asking again. Each substantive reply must preserve selected rules, proposed choices and corrections in the shared records before handoff.

### Compatibility and unresolved interactions

Preserving/displaying real ammunition identities is a design direction, not universal compatibility with every mod. Recommend explicit per-head admission and per-ammo behavior definitions covering effects, loading and resource accounting. Native remote/sensor/fire-only payloads are not implicitly accepted. A matching name/category alone does not prove support. The exact extension contract requires local investigation.

Retain priorities, fallback preference and exact ammunition through save/reload, head changes and pickup; determine ownership and safe unloading behavior before implementation. Priority must not magically convert a chambered round or retroactively change an in-flight payload. These are proposed consistency requirements, not verified capabilities or settled switching policy.

Remaining choices: range/minimum range; blast damage/radius/falloff and player injury; capacity/reload/cadence/power; module compatibility and bounded propagation; Scrapshot quantity/spread/damage/economy; recipes/tools/skills/XP; audio/presentation; ammo switching and extension behavior. Native trajectory, obstruction, controlled no-environment-damage blast, persistence and actual UI behavior need local verification. Installed 0.2.49 and its deferred owner test remain unchanged; no new test is requested now.

## C212 Proposed Lobber range and cadence choices (2026-10-13)

Historical proposal bundle; C213 records the owner-selected range and replacement two-second cadence. Set the head's placement role before picking payload blast numbers. Ranges are unmodified targeting limits, not a guarantee that bystanders or the turret are safe from a later-selected blast radius.

- **1A recommended: 6-tile minimum / 18-tile maximum.** Mid-range support with a close-defense gap; same maximum as the current unmodified Ballista.
- **1B: 8-tile minimum / 24-tile maximum.** More of an artillery role, but needs more space and a larger tested trajectory/obstruction envelope.
- **2A recommended: one launch every 6 seconds.** More responsive, with the selected two-second fuse beginning separately after landing.
- **2B: one launch every 8 seconds.** Slower bombardment and lower ammunition demand; greater risk that moving targets leave before follow-up fire.

These are proposed base launch intervals, not an additional reload delay or settled module behavior. Baseline sustained cadence, reload overlap, first-shot timing and modifier interactions must be made explicit before implementation. No target-leading, wall-clearing, trajectory or measured balance claim follows from these options. Follow with payload blast numbers/falloff and player injury, then loading/capacity/power/module details. Scrapshot remains a separate selected design track.


## C210 payload rules and improvised ammunition balance (2026-10-13)

Owner selects C2091C, with possible rudimentary/improvised explosive and concern that it becomes the best option outside turrets; also selects2B/3A/4A. Confirm multiple payload types for the lobber, landing followed by a short fixed fuse (duration not settled), loose Base.ScrapMetal feed for Scrapshot (quantity not settled), and blast damage to zombies/players without fire or structure damage. These settle design rules, not implementation approval. Do not reinterpret2B as an already-lit fuse during flight or an approved number of seconds.

Recommend a new **Improvised Shell** as turret-only ammunition: an ordinary inventory/ammo item consumed by the launcher, without the native throwable-weapon, placed-bomb or explosive activation behavior. The fictional launcher supplies its firing/arming mechanism; this is a gameplay restriction, not real-world explosive guidance. No conversion recipe into handheld bombs. Simpler than creating a new handheld explosive and maintaining different handheld/mounted damage variants. It prevents adding a new usable handheld explosive through this mod; arbitrary third-party item conversions are outside the compatibility guarantee.

Options presented for this unresolved addition:
- **1A recommended:** turret-only Improvised Shell. Proposed lower blast damage and smaller radius than the native-payload tiers; exact cost, stats and recipe need agreement. Starting ammunition, not a claim that it can never dominate turret cost efficiency.
- **1B:** weak throwable Improvised Grenade, also usable by the turret. More gameplay flexibility but requires separate handheld balance and broader injury/exploit testing. Do not silently grant a turret-only damage buff.
- **1C:** no new explosive ammunition; use selected native payloads only. Simplest maintenance, less accessible explosive supply.

Proposed initial roster if1A is chosen: Improvised Shell, ordinary Base.Aerosolbomb and Base.PipeBomb. Multi-payload selection does not mean all modded grenades, fire-only payloads or native remote/sensor/triggered variants are supported. Native installed B42.21.0 weapon.txt verifies Aerosolbomb as base:weapon with Throw/PhysicsObject, ExplosionPower70/Range6 and FireStartingChance10/Energy20; PipeBomb is base:weapon with Throw/PhysicsObject, Power90/Range7 and zero fire settings. These prove stock metadata only, not turret outcome, explosion API safety or exact turret balance. They support a provisional Shell < Aerosol Bomb < Pipe Bomb power/radius ladder, not copied damage percentages.

Consistency with4A: turret-fired Aerosol Bombs must not ignite, even though their native handheld definition can. Keep handheld/native item scripts unchanged; the approved no-fire/no-structure rule concerns turret blasts. A controlled damage path may be necessary; prove obstruction, player injury and no environmental destruction locally. Do not accept fire-only payloads and silently turn them into unrelated blast weapons.

Remaining next choices: confirm improvised-ammo scope/roster; set fuse seconds and mixed-ammo selection/reload behavior; range/minimum range, blast falloff and player injury; Scrapshot material quantity, pellet/spread behavior; power, cadence, modules, recipes and presentation. The balance concern remains relevant inside turrets too, so compare cost per effective damage and supply accessibility rather than assuming a weak round is balanced. Planning only; installed0.2.49 owner test stays deferred. Fetched origin atc6042cf; sole open draft PR#1 into dev. No gameplay or new test result.


## C209 grenade lobber and scrapshot design (2026-10-13)

Owner selects C2081A and1B: Grenade Lobber plus Scrapshot Cannon for discussion. This supersedes the recommendation to discuss only one. Both reuse the universal-base direction; no new recipe, balance, module mapping or gameplay implementation is approved by selection.0.2.49 owner test remains deferred.

Proposed distinct roles: Grenade Lobber is slow area damage with real explosive ammunition and a minimum firing distance; Scrapshot is a short-range broad volley using scavenged ammunition. Scrapshot needs its resource economy and spread to differ from existing firearm heads; do not define it only as a shotgun with a different label. No invisible free ammunition or extra whole-turret crafts.

First owner choices (all proposals):

1. Grenade ammunition: **1A recommended**, ordinary native Base.PipeBomb only initially; **1B**, dedicated craftable launcher ammunition with a separately agreed recipe; **1C**, multiple native explosive payload types, requiring a per-type behavior/compatibility matrix. Remote/sensor/triggered variants are not included in1A. Native installed B42.21.0 generated/items/weapon.txt lines759-766 verifies PipeBomb with ExplosionPower90/ExplosionRange7; this verifies item existence, not a safe launcher API or the proposed turret damage values. Native values do not silently settle turret tuning.
2. Grenade detonation: **2A recommended**, detonate on first valid impact; **2B**, land then detonate after a short fixed fuse, accepting that zombies can move away. Exact fuse timing and trajectory/obstruction behavior still need settlement/proof. No promise of firing over walls, native bouncing or arbitrary mod-grenade support.
3. Scrapshot feed: **3A recommended**, consume loose Base.ScrapMetal directly, avoiding a new ammo craft; **3B**, loose nails; **3C**, a dedicated crafted scrap-load item. Exact material quantity and cadence remain open. Propose a powered firing mechanism; energy cost and any extra consumables must be settled rather than inferred from the material alone.
4. Grenade collateral: **4A recommended**, blast damages zombies and players, without ignition or structure damage; **4B**, destructive blast that can also damage surroundings. Structure/fire scope and native feasibility must be discussed before4B implementation. Neither is a promise that the native explosion can simply toggle those effects;4A may require the project's controlled damage path.

Recommendations1A/2A/3A/4A. After settlement: range/minimum range, damage/falloff/projectile count, cadence, battery, head recipes and service, injury specifics, sound/visuals, module compatibility and bounded proc propagation. Final art remains owner-sourced. Implementation order is not yet approved. No new assertions, gameplay tests, code/version or installation changes. Fetched origin at0a58373; sole open draft PR#1 into dev. Planning mirrored under C108/C119.


## C208 next-head options while testing is deferred (2026-10-13)

Owner: "I'm not able to test right now, should we add new turret heads?" This is a request for advice, not approval of another gameplay patch. Defer the0.2.49 owner test without claiming a pass or requiring immediate play. R3C2 remains the active prototype-acceptance checkpoint for Ballista/Bat/Blades. Final-art, rendered sweep/contact alignment and audible behavior remain unverified; automated/native proof is unchanged.

Recommend using the downtime to settle one additional head design, not expanding the untested implementation batch. Choices for discussion:

- **1A Grenade Lobber (recommended):** strongest remaining distinct role through slow explosive payloads and minimum-range placement. Optional R3C3. Discuss ammunition, impact versus fuse, player/structure/fire collateral, safe range and module propagation. Actual lob trajectory/cover interaction needs a local native feasibility probe; do not promise firing over walls. No implementation approval inferred.
- **1B Scrapshot Cannon:** grounded improvised-ammo option, likely to reuse more of the projectile pipeline, but it needs a meaningful scrap-economy/volley distinction from mounted shotguns and Splitter/Fragment before adding another head.
- **1C Arc Emitter:** damage-focused bounded chain attack, no default prolonged stun. Distinct but less grounded; presentation, power and bounded chain/module behavior require proof. Lower priority.
- **1D Nail Scatter:** keep deferred unless a purpose beyond Tack's temporary ground hazards is selected. Earlier no-Tack/no-slow shortlist statements are historical and superseded by later approved module/contact content.

These choices do not change the roster, roadmap order, ammo recipes, gameplay code or installed version. A user selection would authorize further discussion; concrete prototype work needs its own scoped approval. Recorded after reading current handoff/roadmap and fetching origin at72806fe; sole open draft PR#1 targets dev. No owner play occurred, so no new console result or performance measurement is claimed.


## C207 approved integrated mounts and implemented prototypes (2026-10-12)

Owner: "1A, we should also add nails to the ballista. I think we're far enough to start this patch. You're approved to begin." This authorizes the C206 integrated mount option and implementation. Eight nails is the selected implementation quantity, not a separately quoted owner number. No separate mount item, redundant complete-turret recipe, new head-wear system or final art.

0.2.49 implements Ballista, Rotary Bat and Rotary Blades plus C191 pack timing. Recipes retain C205/C206 skills, tools, XP and ingredients, with 8 Nails added to Ballista. Native CraftRecipeData consumes inputs, preserves tools and produces each exact head. Durations resolve to 90/60/90 seconds at the tested native timing baseline (script units 864/576/864); ordinary character/action speed modifiers still apply.

Ballista: crafted spears, 240 damage, 18 tiles, six-second base shot/reload timers overlapping; one loaded spear before Magazine. Accuracy is 75/60/45% at close/half/full range. Base charge .025 percentage points/shot, then existing damage/range, rarity and Regulator modifiers. Spears are consumed, without recoverable projectile items; Conservation and Splitter retain the established ammunition rules. Spear condition does not scale head damage. Existing projectile effects are supported through the shared bounded pipeline. Native SpearCraftedSwing is the firing cue. No new spear recovery or impact asset system.

Rotaries: 1.25-tile physical reach, opposing front/rear 45-degree sectors, 150 degrees/second in both oscillation and 360 spin; Bat20/40% shove, Blades40/10% shove. Independent actor/pass deduplication per arm; no shared zombie cooldown. Existing five-second stagger protection remains. Contact uses the native line-of-sight obstruction check. Baseline battery life is six in-game motor-hours; moving speed and active module rarity increase draw and Regulator reduces it. A stopped motor does not drain. Manual Fire starts a short out/back cycle (finishing the stroke); automatic Firing+Detection runs while eligible targets remain and finishes its current stroke. Native BaseballBatHit/AxeSawBladeHit play on contact with a per-head150-ms sound guard; Suppression affects hearing/volume.

Bat injuries:2 limb damage/+5 pain. Blade injuries:native laceration/bleeding, no extra fixed damage. All rotaries share a two-second player guard; dead/God/NoClip/Ghost exemptions. No forced player knockdown. Only base maintenance matters; no operational head wear. New item condition metadata is100; weights are6 Ballista/5 Bat/6 Blades. New heads start with0% critical chance and2x multiplier, allowing Critical modules to add chance.

Rotary exclusions: Splitter, Piercing, Conservation, Magazine, Reload, Autoloader, Impact, Fragment, Tack, Martyrdom, Synergy, Range, Accuracy, and Filter. Filter is also inactive because physical sweeps contact everything they cross rather than selecting one priority victim; this consistency decision was explicitly reported during implementation. Existing unsupported items are preserved, removable and marked Inactive without battery surcharge; new insertion is rejected. Supported roles include Firing/Detection variants,360, Rapid-Fire, Velocity, Critical, Initial Blow, Execute, Suppression, Regulator and expansion. Enhanced Firing applies the existing4/3 speed multiplier to these custom heads; Rapid-Fire increases rotary angular speed, with proportional motor cost. Makeshift Firing retains its failed-start chance/cooldown with no spent motor power; native/manual startup is exempt. Normal/enhanced detection scan intervals honor Sandbox tuning. Original heads remain unchanged.

Performance: no extra OnTick callback. Existing automation scheduler owns rotary work with its shared2-ms deadline, at most48 local work units per step and a5x5 square neighborhood. Stats cache follows the contents snapshot. Per-arm hit maps use weak actor keys. Only the last100ms of observed motion can damage; jobs older150ms stop attacking. Overload can miss contacts instead of replaying missed sweeps. Elapsed operating time still bills power, excluding powered-off/offline time. Player-health guards and safe shutdown have behavioral tests; this is not a measured dense-horde performance claim.

Pack rows now start150ms apart, finish6/6.15/6.3s, and the highest-rarity cue begins at6.05s, with final selection at6.3s. Rewards, speed profile and four-second fade remain unchanged.

Evidence:16,574 behavioral assertions and120 Lua/translation compilations; native recipes/ammo acceptance/module exclusion/sound registry; actual new-item type/condition/modData save/reload in fresh native processes; Traps-only, Turrets-only and combined startup. Full existing base/contents persistence suite also passes. Prototype renderer uses the previously authorized cube markers at opposite positions; it is not finished artwork and visual strike alignment is not yet accepted. Native head item persistence does not establish rendered world combat or multiplayer. [Focused test](TEST_v0.2.49.md) owns remaining acceptance; [release](RELEASE.md) owns actual installation/mirror evidence. No Workshop publication.

## C206 base-only maintenance and rotary mounting (2026-10-12)

Owner asks whether Potato has separate condition and selects 1C if not; clarifies "Only the base is the worry", approves 3A injuries and 4A recipe direction, but requires a credible mount for the rotary weapons and asks about saw-blade availability.

Confirmed source distinction: OMHTTTurretPotato has ConditionMax = 100 as item metadata, and generic head validation rejects zero condition. It has no firing-condition decrement. The shipped Lua condition-write search finds mounted native firearm wear in FirearmCombat and base condition restoration on pickup in TurretWorld; TurretWorld.repair restores only the base's world HP. Therefore matching Potato means no operational wear for Ballista/Bat/Blades and no new Repair Head action. Base damage/repair remains unchanged; mounted native firearm wear is not removed. This supersedes C205's proposed independent head maintenance. Do not add fractional wear persistence or condition-inheriting Bat outputs as a hidden maintenance requirement; reject broken input bats, but new crafted heads are operational. Native condition metadata need not be removed or claimed absent.

Owner approves C205 3A: Bat moving contact deals 2 limb damage and +5 additional pain; Blades causes a native limb laceration with bleeding, without extra fixed damage. Shared two-second player injury guard across arms/nearby rotary heads; dead/God/NoClip/Ghost exemptions, physical reach/coverage and no forced knockdown. Independent zombie arm damage is unchanged. Native collision, protection and rendered proof remain pending.

Owner approves 4A's standard-material recipe direction and rejects neither its skills nor tools/XP. Mount presentation is still being discussed. The original common mechanism already consumes 1 MetalPipe, 1 SmallSheetMetal, 2 ScrapMetal, 2 ElectronicsScrap, 1 ElectricWire and 8 Screws per head; these were additional to the two bats or two CircularSawblades + two MetalBars, not optional. Proposed physical interpretation: pipe axle, sheet/scrap mounting brackets and housing, screws fastening, electronics/wire drive controls. This is a gameplay abstraction, not engineering instructions or a claim that electronics scrap is a verified native motor item. Existing universal floor base is distinct from this head assembly and is still crafted separately.

Mount choices for owner: 1A recommended, build the mount directly within each head recipe using those already-listed materials, preserving one craft and no additional item; 1B, create a shared Rotary Mount intermediate from the same mechanism ingredients, then combine it with either weapon set. 1B adds an inventory item and a crafting step; if chosen, split existing time/XP rather than double charging/rewarding, and settle its weight/recipe details before implementation. No mount choice assumed from the phrase "need a mount to craft". Ballista remains a complete head built directly from its approved material list. No extra EngineParts gate, redundant whole-turret recipe or new art authorization.

Native installed B42.21.0 evidence: media/lua/server/Items/ProceduralDistributions.lua lists CircularSawblade at weight 2 in GarageCarpentry (23010), 4 in GarageTools (23390), CarpenterTools (9434) and CrateCarpentry (13676), and 8 in ToolStoreCarpentry (48944), ToolStoreMisc (49218), ToolStoreTools (49344). CabinetFactoryTools (7950-7951) and MannequinFactoryTools (33762-33763) each contain entries weighted 20 and 10. Generic closet pools have 0.1 entries. ToolStoreCarpentry also lists GardenSaw at 10 and CarpentryChisel at 8. These are distribution weights, not literal spawn percentages or a guarantee every container selects the pool. Shop flags, routing, loot settings and fit affect outcomes. Recommendation: keep two native saw blades; they are a reasonable targeted tool-store/workshop scavenging requirement rather than an ultra-rare-only ingredient. No actual-world spawn sample claimed.

Inspected 563d891, fetched origin and checked sole draft PR #1 targeting dev. Documentation only; installed 0.2.48.1 unchanged and C191 pack timing remains queued. Remaining head work includes mount representation, Ballista spear/feed/recovery rules, exact remaining module mapping, critical/audio and native/rendered lifecycle proof. No gameplay tests requested for this discussion.

## C205 durability repair injury and recipes (2026-10-12)

Owner asks for options/recommendations for durability, repair, player injuries and recipes. All values below are proposals. Do not infer patch approval or change already confirmed head/module/motion/battery rules.

Evidence reviewed: TurretWorld.repair restores only IsoThumpable base HP; TurretPickupAction uses10s Repair/5s Pickup and no consumed repair materials. Base and Potato item scripts useConditionMax100. Mounted FirearmCombat uses native gun condition-loss chance. Existing ContactPlayer uses limb setCut(true,true); TurretProc.injure uses limb AddDamage(2), additionalPain+5 and dead/God/NoClip/Ghost guards. Installed generated item scripts contain Base.BaseballBat, CircularSawblade, EngineParts, Plank, MetalBar, MetalPipe, SmallSheetMetal, ScrapMetal, ElectronicsScrap, ElectricWire, Screws, Rope, Twine and DuctTape (latter already used in shipped recipes). Existence is not a completed native recipe transaction or drop-availability guarantee. No new motor item assumed.

1: Head durability. Recommend1A100condition for each new head, separate from existing base HP. Ballista loses1condition per20committed shots (2000shots fresh-to-zero); Bat loses100condition over12in-game motor-hours at baseline speed; Blades over18hours. Track fractional wear on exact head item, persist through pickup/swap/reload, no free resets. Rotary wear follows motor operation/angular travel and compatible speed modifiers, not victim count; stopped motors do not wear. Ballista committed misses count. Costs for projectile module extras need final feed rules, not a silent multiplication per secondary victim. At0 head stops functioning but remains repairable/recoverable; no auto-delete or loss of battery/modules.1B doubles these lifetimes to4000shots/24hours/36hours without increasing displayed100condition.1C disables operation wear for new heads; base attacks still damage base as now. Do not claim turret base attacks already damage head condition.1A provides maintenance after roughly two bare baseline rotary batteries for Bat and three for Blades; module draw changes battery count, not this baseline wear budget. No native acceptance yet.

2: Repair. Recommend2A new Repair Head action,10seconds, free full condition restore, matching existing repair convention. Requires powered off and fully stopped, adjacent access; interruption consumes nothing, grants no XP and preserves previous powered-off state. Base Repair remains distinct and unchanged; never repair native mounted guns as a side effect.2B material maintenance:10seconds restores50percentage points capped at100; Ballista consumes1Plank+2Twine uses; Bat1Plank+2DuctTape uses; Blades2ScrapMetal. Retain screwdriver and wrench/pipe wrench; no repair XP. Materials consume only on successful completion after revalidation. Requires no additional skill beyond access/tools, not a new crafting-XP loop. For both choices power must stay off through service and destruction/movement/head swap must cancel safely. No automatic restart at repair completion.

3: Player rotary injury. Recommend3A actual moving-weapon contact causes Bat blunt limb damage2points plus5additional pain; Blades causes one native limb laceration with bleeding (no extra fixed direct damage).3B harsher: Bat5limb damage+10pain; Blades laceration plus5limb damage. Values are body-part damage, not guaranteed total-health percentage loss. No new fracture, amputation or zombie-infection mechanic. Preserve ordinary wound treatment; this is not real medical advice. Both choices use a shared2-second player injury guard across arms/nearby rotary turrets, not the independent zombie damage entitlement, to prevent0.3s instant injury stacking. Continued contact can injure again; dangerous even walking, because these are powered moving heads rather than safe-to-walk static spikes. Only physical reached sectors/height/obstruction can injure; no side damage without360. Dead/God/NoClip/Ghost exempt as existing proc convention. No forced player knockdown for initial implementation. Power off before service. Exact collision-to-limb selection/protection needs native/rendered verification. Ballista player-projectile collateral is not implicitly changed by this rotary injury choice.

4: Crafting. Recommend4A three separate head recipes, one output each; existing universal base/battery/modules supplied separately. Category OMH:Turrets, Heads group, one recipe per head; no complete-turret or alternate duplicate recipe. Shared consumed mechanism ingredients per head:1MetalPipe,1SmallSheetMetal,2ScrapMetal,2ElectronicsScrap,1ElectricWire,8Screws. Additional ingredients and progression:

| Head | Extra consumed materials | Required skills | Base crafting XP | Proposed base craft duration |
| --- | --- | --- | --- | --- |
| Ballista | 4Plank,2MetalBar,1Rope | Carpentry3,Mechanics3,Electrical1 | Carpentry10,Mechanics25,Electrical5 | 90seconds |
| Rotary Bat | 2plain wooden BaseballBat | Carpentry1,Mechanics2,Electrical1 | Mechanics20,Electrical5 | 60seconds |
| Rotary Blades | 2CircularSawblade,2MetalBar | Mechanics4,Electrical2 | Mechanics30,Electrical10 | 90seconds |

Retained tools for all: screwdriver,wrench OR pipe wrench,pliers. Ballista additionally hammer and saw; Bat hammer; Blades metal snips. Use verified native item/tag identities, no tool consumption. No recipe-book requirement.4B salvage-heavy: all4A costs/tools/skills/XP/time plus2EngineParts consumed per head, increasing scavenging gate without duplicate recipes or altered performance. Recommend4A since batteries/modules and blade/bat inputs already gate assembly. All outcomes use the same selected head behavior, not new tiers. Exact native time-unit conversion/skill adjustments must be validated before describing observed duration.

For Bat, propose healthy inputs only (no broken weapons); output condition inherits the average input-bat condition fraction instead of converting nearly-broken bats to a fresh head. Other ingredients have no weapon-condition transfer requirement. Free Repair Head if2A approved is the explicit restoration path. Do not consume attached/spiked/metal bats or substitute rare weapons via broad tags. CircularSawblade is native material, not an instruction to generate final artwork. Two opposed strike surfaces are owner-selected; proof must match1.25tile reach with authorized technical placeholders before final owner art. These input-condition semantics are included in recipe discussion, not an independent permission assumption.

Recommendations1A/2A/3A/4A. C204 accuracy/power unchanged. Still unresolved beyond this choice bundle: spear condition/recovery/feed and Ballista module interactions, exact remaining supported-module effects, critical/audio and safe stop transitions. Final art owner-sourced. No source/version/install/test changes; C191 timing queued. Inspected e4c8817, fetched origin and checked sole open draft PR#1. Documentation only.

## C204 approved accuracy and battery (2026-10-12)

Owner: "1A / 2A / 3A -0.025%." Approves the C203 accuracy and rotary battery options and overrides proposed Ballista0.05% with0.025% per committed shot. Do not retain0.05% as the new default or ask these choices again.

- Ballista240damage/6s/18tile base remains. Accuracy is75% near,60% at9tiles and45% at18tiles before compatible modifiers, with smooth distance falloff. Preserve true selected endpoints rather than silently adding native point-blank bonuses. Physical rotary contacts remain outside accuracy RNG.
- Rotary full-charge baseline is6in-game hours of motor operation at150degrees/second before modifiers, corresponding to100/6 percentage points per in-game motor hour. Charge while moving even when missing; automated heads finish the current swing and stop when no valid target remains. Stopped motor has no operation draw. Speed increases draw, existing additive rarity costs apply and Regulator extends life.2hours at3x drain,2.5hours with one Regulator, are examples not universal loadout promises. Pause/offline time excluded; game-hour conversion and transitions need implementation proof.
- Ballista base shot charge is0.025 percentage points at240damage/18tiles, or0.00025 normalized charge.100/0.025=4000 shots from100% before other modifiers. At3x drain this becomes about1333 shots; one Regulator gives about1666. Preserve damage/range and module scaling through a head-specific calibration, without changing guns/potato. Actual committed misses spend resources; cancelled/no-target shots do not. Full precision drives accounting, not rounded tooltip text.

Battery counts ignore spear stock, head wear, interruptions and future feed decisions; not a promise of4000 uninterrupted shots. Resource/time-skip and rendered tests remain outstanding. Existing rotor45degree opposed arcs,25RPM spin/150degree-per-second oscillation, independent arm contact, damage/shove values and module exclusions remain selected. Remaining work: durability/wear and repair costs; player injury severity; head recipes/tools/skills/XP; spear condition/recovery/feed; final supported-module details, critical/noise and safe-service/stop behavior. Recipe approval required before implementation under project agreement. No source/version/install/test changes this turn; C191 pack timing remains queued.

Inspected889f8f0 and fetched origin; sole open draft PR#1 targets dev. This is recorded owner approval, not completed gameplay implementation.

## C203 accuracy and battery options (2026-10-12)

Owner requests options and recommendations. These are proposed values, not approvals or implementation. Existing selected240Ballista/6s/18tiles, Bat20/Blades40, opposite45degree arcs,25RPM-equivalent speed and module exclusions remain unchanged.

1: Ballista unmodified aimed-hit probability (smooth linear interpolation over physical effective range):

| Choice | Near-zero-distance limit | Half range9tiles | Full range18tiles |
| --- | --- | --- | --- |
| 1A recommended, heavy but unreliable | 75% | 60% | 45% |
| 1B more forgiving | 85% | 70% | 55% |
| 1C very inaccurate | 65% | 50% | 35% |

Range endpoints follow actual effective head range if a compatible Range module changes it; an engagement slider must not rescale distance falloff to make the same target easier/harder. Accuracy upgrades, if supported by final Ballista matrix, must change true hit probability and tooltip together. Current FirearmAccuracy.chance increases its close endpoint using native point-blank settings; blindly passing75 would not guarantee75. Implement a head-specific endpoint profile without modifying existing gun behavior or double-applying native bonuses. Chance is an intended-target outcome under eligible clear-shot conditions, not a promise of exact short-sample hit counts or final secondary-projectile outcomes. Do not give rotary physical contacts random miss rolls; Accuracy remains incompatible there.

2: Rotary motor baseline at approved150degrees/second, from100% charge before module, Regulator or speed modifiers:

| Choice | Full motor-running duration | Baseline drain per in-game motor hour | With total3x module drain, no Regulator |
| --- | --- | --- | --- |
| 2A recommended | 6hours | 16.6667% | 2hours |
| 2B very hungry | 3hours | 33.3333% | 1hour |
| 2C forgiving | 12hours | 8.3333% | 4hours |

C203 now recommends6hours rather than C200's3 because active module surcharges compound the short baseline. Both rotary heads use the selected baseline at their current base geometry/stats; retain existing damage/range factor semantics for applicable changes and additive rarity load, not a fresh multiplier for every contacted zombie. At default module-power setting, module factor=1+sum(applicable surcharge), and Regulator divides drain by1+0.25*count. Thus2A at3x becomes2hours, or2.5hours with one Regulator; this is a hypothetical3x load, not an assertion all loadouts cost3x. Final compatible module set determines actual draw. Do not charge for excluded effects as active benefits; swap/storage handling remains explicit contract work.

Proposed billing rules with rotary endurance choice: drain while motor actually moves, including empty swings/misses, not once per victim, arm or render frame. Stopped/off motor has zero operation draw. With Detection/Firing automation, recommend start on a valid target in physical coverage and stop after finishing the current stroke when no valid target remains; exact manual behavior/start-stop transitions require lifecycle proof. Swing/spin at the same angular speed share baseline draw;360's existing rarity surcharge still applies. Higher speed scales motor draw proportionally to actual angular speed, in addition to existing module electrical load, so Rapid-Fire is not free motor work. Game-hour basis must respect configured day length in both consumption and estimate, excluding pause/offline time. For illustration only, with a60-real-minute game day,6in-game-hours is15real minutes; at3x it is5real minutes. This makes higher module builds hungry despite the six-hour label. Reconcile sleep/fast-forward/lag safely; no free backlog of attacks or energy after exhaustion. These motor rules are proposals bundled for discussion, not approved by an earlier speed annotation.

3: Ballista shot cost, before module surcharge/Regulator, evaluated at240damage/18tiles:

| Choice | Charge per committed shot | Approximate shots from100% |
| --- | --- | --- |
| 3A recommended, meaningful electrical cost | 0.05% | 2000 |
| 3B preserve shared shot baseline without new head coefficient | 0.000853815% | 117121 |
| 3C heavier electrical cost | 0.10% | 1000 |

Evidence: TurretStats.resolve currently uses0.00045% * max(1,sqrt(damage/80 * range/15)) * moduleFactor / regulator. For240/18 the weapon factor is sqrt(3.6)=1.8973666; TurretWorld.power divides displayed percent by100 before deducting normalized charge. This is not0.085% or0.00085 normalized units. New heads are not implemented, so3B is a calculation if this baseline is reused, not an observed Ballista. Recommend3A via a head-specific electrical coefficient calibrated at240/18, preserving future damage/range and module scaling; do not globally raise firearm/potato drain. Misses still spend power for committed shots; no-target/cancelled shots do not. At3x load3A allows about666shots, or833 with one Regulator, ignoring leftover charge rounding. Shots are battery-only potential and do not imply available spears or ignore durability. Display full internal precision; rounded UI values never drive accounting.

Recommendation1A/2A/3A. All rates use percentage points of charge, and rotary hours mean motor-running game hours, not guaranteed calendar survival or end-game loadout life. Player injury/wear/recipes/spear lifecycle and final module capabilities remain open. No Source/Contents/version/install/test changes. Inspectedf203255, fetched origin and checked sole open draft PR#1. C191 timing remains queued.

## C202 45degree front and rear arcs (2026-10-12)

Owner annotates C201's90degree assumption: "It should be45degrees on the front and back. It won't hit the sides unless it has360." Confirm45degree total front sector and45degree total rear sector, each centered on its opposite arm's placement axis (plus/minus22.5degrees). Side sectors are excluded without360, including through collision-radius padding or interpolated sweeps. This supersedes C199/C20190degree working geometry. With360 the arms spin continuously and can contact all directions within physical reach, subject to obstruction.

At approved25RPM-equivalent150degrees/second,45/150=0.3s endpoint-to-endpoint and0.6s out-and-back with no added dwell. Opposite arms move together.360 operation remains2.4s/full revolution and1.2s between opposite-arm passages at a fixed angle. Narrowing the arc at unchanged angular speed increases repeat contacts inside the sector; it does not preserve old1s/1.5s swing cadence. At sector center ideal crossings are0.3s apart (Bat20/0.3=66.667DPS, Blades40/0.3=133.333DPS before geometry/health/reactions/modules), versus16.667/33.333 during360 spin at a fixed angle. These are mathematical upper contact-rate illustrations, not native measured damage or guaranteed continuous occupancy. Make this tradeoff visible; do not silently impose a shared cross-arm cooldown contrary to C200.

Independently deduplicate each arm's physical stroke/pass; prove reversal/edge contact cannot repeatedly hit without a distinct crossing. Module speed changes must affect render/contact/power consistently. Shared shove recovery remains separate from ordinary damage. All prior module exclusions,240Ballista/reduced-accuracy direction,20Bat/40Blades damage and shove chances remain. Exact accuracy, motor power, injury, wear, recipes and spear lifecycle remain unsettled. C191 pack timing queued. Same-turn correction after36b5773; no source/version/install/test changes. Mirror with C200/C201.

## C201 shared angular speed for swing and spin (2026-10-12)

Owner annotates C200's retained non360 timing assumption: "Convert the25RPM to the rate without360." This explicitly supersedes the old Bat1.5s and Blades1s non360 timers and the C200 interpretation retaining them. Use one baseline angular speed for both rotary heads and both motion modes:25*360/60=150degrees/second before compatible speed modifiers.

Without360, opposite arms oscillate together through their respective front/rear arcs. With the currently proposed90degree total arc, one endpoint-to-endpoint stroke takes90/150=0.6seconds, and an out-and-back cycle takes1.2seconds. For any selected arc A degrees, one-way duration=A/150; do not silently treat25RPM as25swings/minute. Arc90degrees remains the explicit working geometry from C199, not native-rendered proof. Ideal timing excludes an added reversal dwell; do not add an unrequested pause without discussing its effect.

With360, a revolution still takes2.4seconds and opposite-arm passages at a stationary angular position are1.2seconds apart. Non360 contact rate is angle-dependent: a zombie at the middle of a90degree sector can be crossed every0.6seconds by its local arm, whereas crossings near endpoints alternate shorter/longer gaps. The opposite arm attacks the opposite sector, not the same stationary target. Thus equal angular speed does not imply equal per-victim damage frequency between oscillation and full rotation. Conditional nominal sector-center DPS is Bat20/0.6=33.333 and Blades40/0.6=66.667, before movement/obstructions/modifiers, versus16.667/33.333 on full rotation. This is concentrated coverage, not evidence of measured in-game throughput. Preserve one hit per distinct victim per arm stroke/pass, not per frame; independent arm damage is still approved. Endpoint overlap/reversal contact needs proof to avoid jitter/double hits on a stationary victim without a distinct new pass.

Motor-time charging remains a recommendation, not newly approved by annotating its combined commentary paragraph. C200 accuracy and exact battery-budget options remain proposed; no reply selected them. Ballista240/6s/18tiles with reduced accuracy and all module exclusions stay confirmed. C191 timing remains queued. Documentation only; no source/version/install changes. This same-turn correction follows C200 local commit eb4b00e and will be mirrored with it.

## C200 independent arms at25RPM and Ballista accuracy (2026-10-12)

Owner: "1A - It'll also be less accurate than normal. 2B - They consume a lot of battery, but are very strong. 25rpm." Approves C199 Ballista240 base damage, preserving6s spacing and18tile range, and requests reduced accuracy. Approves independent damage eligibility for each physical arm, explicitly rejects the recommended shared per-victim damage interval across both arms, and specifies25RPM with high battery use for rotary heads. Exact accuracy/drain are not yet selected.

Working interpretation stated to owner:25RPM governs full-circle rotation with360 for both heads; previously selected non360 swing intervals remain Bat1.5s and Blades1s. This avoids silently replacing the previously differentiated swing speeds. If owner means25RPM-equivalent motion in both modes, reconcile angular swing and turnaround duration before implementation. Normal operation still uses two opposed swinging arms; no rear safety assumption.

Exact kinematics before modules:25RPM=150degrees/second, one revolution2.4s. With two opposite arms a stationary in-range zombie can be contacted every1.2s, each arm revisiting every2.4s. Up to50 arm passages/minute at that position gives nominal Bat20damage*50/60=16.667DPS and Blades40*50/60=33.333DPS, before misses, obstruction, target movement, shoves or modules. This is per-victim math, not a native performance proof or total crowd DPS. Relative to non3601s Blade swings,25RPM has less frequent passages at a fixed angle, but covers all directions. Do not imply independent arms yield80damage/second or40Batdamage every1.5s automatically; actual path crossings decide. Each arm must deduplicate one victim per physical pass/stroke to prevent frame-based repeat damage. Multi-target contact remains inherent. Shared shove recovery is a separate proposal and must not suppress second-arm ordinary damage.

Accuracy options, unmodified Ballista against zombies:1A recommended75% near,45% at full18tile range;1B85% near,55% at full range. Use distance-based interpolation following the established aiming approach; precise curve remains to define. These are proposed hit chances, not exact observed rates, and are lower than the current precision-rifle range factor80%. Verify semantics when connecting to the existing aim path rather than blindly multiplying percentages twice. Accuracy modules for Ballista remain a separately specified capability; rotary Accuracy stays excluded.

Power recommendation: meter active motor time, including empty swings/misses, rather than bill per contacted zombie or per rendered frame. Turning power off/stopping motor stops that draw. No new passive idle drain is implicitly approved; automatic start/stop behavior remains part of the head contract. Proposed rotary baseline endurance choices:2A recommended3in-game-hours from100% during continuous motor operation before module surcharge/Regulator;2B6in-game-hours. Equivalent conceptual baseline rates are33.333% and16.667% per in-game motor hour. This is an unapproved rotary-specific time-based budget, not a change to existing shot-based guns/potato drain. Modules shorten baseline life and Regulator extends it; final rates must preserve existing additive rarity power semantics and show actual loadout duration. If rates are defined per game hour, day-length changes must be reflected consistently in drain and tooltip; do not mix real-time RPM with unconverted game-hour billing. Pause/offline time excluded. No exact loaded end-game lifetime is promised by these baseline options. A native/time-skip test is still required before implementation acceptance.

Prior head/module choices, Bat20/40%shove and Blades40/10%shove remain. Injury severity, wear/durability, recipes, spear lifecycle and remaining module mapping remain open. No source/version/install/test changes. Inspected7d0c13f, fetched origin and checked sole open draft PR#1. C191 timing remains queued.

## C199 selected stats and opposite rotary arms (2026-10-12)

Owner selects C198 1B with "stronger than the strongest native rifle", initially selects Bat2B, and selects Blades3A with1s swings. Owner then corrects Bat to2A during the same turn. Final selected values: Ballista180 damage,6s total shot spacing,18tiles with rifle-strength requirement; Bat20 damage,1.5s swings,40% shove; Blades40 damage,1s swings,10% shove. Rotary reach target1.25tiles remains subject to visible/contact proof. The briefly selected Bat30/20% is superseded, not an additional variant.

Owner adds two opposite front/back arms for each rotary head; both swing without360 and spin with360. This changes earlier front-only coverage: baseline motion sweeps opposed front/rear sectors. No promised safe rear remains. Bat uses its bat-type striking arms and Blades its blades; this is the owner's mechanical configuration, not new assistant art direction. Proposed baseline sectors reuse the90-degree cone at0 and180 degrees; exact angular sweep/rendered geometry needs proof. With360 they rotate around the full circle. Walls, actual reach and elevation still limit contact. Player contact danger remains selected; safest servicing recommendation is power off and verify stopped motion, with final servicing behavior unresolved.

Installed native evidence: media/scripts/generated/items/weapon.txt contains native rifle damage ranges up to1.2-2.0 (including Base.HuntingRifle, Base.AssaultRifle2, Base.L94_Rifle and Base.MSR7T_Rifle). TurretStats.resolve uses (MinDamage+MaxDamage)*50 at default FirearmDamageMultiplier1, yielding160 noncritical damage. Their native CritDmgMultiplier4 produces640 on a mounted critical before other modifiers; crit chances differ. Native raw upper damage2.0 corresponds to200 in the mod's displayed units, but player-held actual damage also depends on engine/player mechanics. Do not call160 the strongest possible player-rifle hit or claim new-head DPS outclasses all rifles. This comparison excludes Firearms and other mods and altered Sandbox values.

180 already exceeds the default strongest native mounted-rifle noncritical baseline by12.5%. Recommend240 instead for a clear heavy-shot identity:50% above160 and above the raw200 upper bound, retaining6s cadence and18tiles. This is a proposed change, not automatically approved by selecting1B; final Ballista criticals remain unresolved. Explain that a native rifle critical can still exceed an ordinary Ballista hit. Discussion option1A:240 recommended;1B:retain selected180. Both comparisons are per ordinary hit, not DPS/critical superiority.

Two-arm cadence materially affects balance. Recommend option2A: one shared per-victim hit interval across both arms (Bat1.5s, Blades1s), including360 operation; a second arm cannot immediately double-hit the same victim inside that interval. Both arms still hit different contacted zombies, preserving inherent multi-target contact. This keeps selected damage/cadence honest across movement modes. Option2B: independent arm hits, allowing two hits during an interval (up to40 Bat/80 Blades damage to the same victim where both paths actually cross). Do not assume both arms can contact a stationary victim in opposite baseline sectors; timings depend on physical movement. With360, choose visual angular speed consistent with the selected contact cadence, not a silent full-revolution-versus-half-revolution damage multiplier. These options are not yet approved.

Prior exclusions stay settled. Shared five-second shove protection remains recommended, with ordinary damage continuing during protection; this is not a promise of native knockback displacement. Final module mappings, critical/accuracy/noise, durability/power, injury severity, recipes and spear lifecycle remain open. No implementation/version/install change. Inspected5a00327 and fetched origin; sole open draft PR#1 targets dev. C191 pack timing remains queued.

## C198 starting combat stat choices (2026-10-12)

Owner asks for the next decision. Provide starting combat-stat options, not a new request to approve the already settled heads or module exclusions. Current source sandbox defaults verified: Potato damage35, cooldown2s, reload2s, range6, knockdown40%; battery base0.00045% per shot. Existing overlapping potato timers are unchanged. These comparisons do not establish equivalent head strength or zombie kill counts.

All proposals below are before modules, against zombies, using existing displayed damage units. Attack intervals are real seconds at normal game speed. Ballista interval means total sustained shot spacing, not an additional serial reload of the same length; feed/cycle details remain to specify. Range/reach uses horizontal tiles from the turret center. Rotary reach is a target requiring matching physical presentation and obstruction proof; do not silently create invisible reach.

| Choice | Head / role | Damage | Attack interval | Range or reach | Native shove chance proposal |
| --- | --- | --- | --- | --- | --- |
| 1A recommended | Ballista, balanced heavy shot | 120 | 4s | 18 tiles | No new inherent shove proposed |
| 1B | Ballista, heavier slower shot | 180 | 6s | 18 tiles | Same |
| 2A recommended | Bat, control-focused | 20 | 1.5s per stroke | 1.25 tiles | 40% per eligible surviving contact |
| 2B | Bat, more damage / less control | 30 | 1.5s per stroke | 1.25 tiles | 20% |
| 3A recommended | Blades, heavier contact | 40 | 1.5s per stroke | 1.25 tiles | 10% |
| 3B | Blades, faster lighter contact | 25 | 1s per stroke | 1.25 tiles | 10% |

Recommend 1A/2A/3A. Rotary damage applies to each distinct contacted zombie once per stroke; preserve inherent multi-target hits with no approved victim-count cap or successive-victim falloff. Forward coverage/360 module and player contact danger are already selected. Player injuries need their own severity rule; do not use these zombie damage values automatically on player body parts.

Recommend reusing the existing five-second shared victim reaction protection for Bat/Blades shove, allowing damage during protection but no repeated forced reactions. Shove is a brief native reaction, not a teleport, guaranteed knockdown or physics launch; native/rendered suitability still needs proof. This protection and the once-per-stroke rule are explicitly proposed as part of the stat baseline. Do not duplicate independent immunity timers per turret.

Tradeoffs: Ballista 1A and1B have equal nominal direct DPS30 before misses/turning, but1B saves spears per damage and loses responsiveness; recovery/ammo economy remain unresolved. Bat2A offers less damage with more attempted control, not an objectively weaker head. Blade3B has lower nominal per-victim DPS25 versus26.67 for3A but more frequent contact checks, wear/power opportunities and reaction rolls; resource tuning must account for cadence. Inherent multi-target contact multiplies actual damage with crowd occupancy, so per-target DPS is not total throughput. Exact module mappings/critical/accuracy/noise, head health/wear, player injury, power, acquisition recipes/tools/skills/XP and spear lifecycle remain open. No Source/Contents/version/install/test changes. C191 timing remains queued.

Inspected 19b3871, fetched origin and checked sole open draft PR #1. Planning proposals only; no owner stat choice yet.

## C197 inherent rotary multi-target contact (2026-10-12)

Owner: "1A, the blade and bat are always piercing." Approves C196 1A: Piercing and Conservation are incompatible with Rotary Bat and Rotary Blades. Clarifies inherent multi-target contact: hitting one zombie must not inherently end the physical sweep; additional zombies contacted by the moving weapon can be hit without a module. Do not implement the rejected Piercing-module victim-count/damage-falloff mapping as an implicit baseline.

Physical interpretation preserves already established constraints: actual visible reach, selected forward sector or 360 upgrade, same-level obstruction checks and player danger on moving contact. This is not projectile wall penetration or an invisible radius attack. Recommend once per distinct victim per stroke to prevent frame-rate-dependent repeated damage; exact stroke/reaction cadence and dense-horde workload proof remain part of R3C2. No newly approved numerical victim cap or damage falloff is implied. Any necessary gameplay cap must be discussed rather than silently converting the owner's inherent multi-target request into single-target hits.

Initial rotary exclusions are now Splitter, Piercing, Conservation, Magazine, Reload, Autoloader, Impact, Fragment, Tack, Martyrdom, Synergy, Range and Accuracy. Existing projectile-head behavior is unchanged, and Ballista remains a separate compatibility contract. No more decisions are needed about these exclusions. Remaining candidate module benefits, head stats, injury severity, power/wear, recipes and spear lifecycle remain to settle. No gameplay/version/install/test changes this turn. C191 timing stays queued. Inspected 81b349e and fetched origin; sole open draft PR #1 targets dev.

## C196 simpler rotary compatibility (2026-10-12)

Owner: "Let's not use splitter either. We can avoid a lot of the modules I guess." Explicitly excludes Splitter on Rotary Bat/Blades and supports simplifying module compatibility. No change to Splitter on existing projectile heads; Ballista compatibility remains separately specified. Prior rotary exclusions/deferred effects remain: Magazine, Reload, Autoloader, Impact, Fragment, Tack, Martyrdom, Synergy, Range and Accuracy. There is no new request to remove any module item globally.

Recommend 1A: also leave Piercing and Conservation incompatible with rotary heads initially. Baseline sweep contact should determine physical multi-target behavior without relabeling it penetration; ammo-saving need not become a new durability-saving system. Alternative 1B retains discussion of the earlier cleave and wear adaptations. These two exclusions are recommendations, not automatically inferred approval. Do not ask again about Splitter or prior confirmed exclusions.

Remaining candidates are ordinary automation/control, attack speed/damage/critical/health-conditional effects, noise reduction, power regulation and expansion module slots. Exact head-specific benefits, Enhanced Firing baseline, compatibility feedback, stats and recipes still need settlement. Recommended UI: identify incompatible modules clearly, reject new incompatible installs, and preserve existing items during head swaps without silently deleting or ejecting contents; final swap behavior remains to be specified. No code/version/install changes. R3C1 remains active, with R3C2 mechanical proof outstanding. C191 timing remains queued.

Inspected 736acd2 and fetched origin; sole open draft PR #1 targets dev. This records a narrower design, not an engine impossibility or a completed implementation.

## C195 continuous physical rotary scope (2026-10-12)

Owner: "1B / 2B / 3A" in response to C194. Confirm the initial Bat/Blades implementation scope:

- Continuous swings with normal per-stroke cadence, without the proposed magazine/reset sequence. Magazine, Reload, Autoloader and Impact have no rotary function initially. Continuous describes the attack pattern, not authorization to run constantly while idle.
- Physical melee first. Fragment, Tack, Martyrdom and Synergy rotary adaptations are deferred. Do not add endpoint shrapnel, Tack fields or death explosions to rotary attacks in this slice.
- Range and Accuracy are explicitly incompatible with rotary heads initially; no invisible extended reach and no new glancing-hit accuracy mechanic.

These choices apply to Rotary Bat and Rotary Blades. Existing potato/firearm module behavior stays intact. Ballista still uses crafted spears and needs its own exact ammo/module lifecycle specification. C194 forward coverage with 360 upgrade and player injury from moving contact remain confirmed.

Do not infer approval of all unnumbered C194 proposals from this reply. Physical Splitter/Piercing and Conservation-as-wear remain candidate adaptations requiring precise behavior/tuning; other module mappings need a final compatibility matrix. In particular, clarify how follow-up Splitter swings differ from Rapid-Fire during continuous attacks, and how many victims the baseline physical sweep reaches before choosing Piercing bonuses. Recipe materials/tools/skills/XP, base stats, durability/power, player injury severity and spear recovery remain open. No repeat selection of the three heads or these confirmed restrictions is needed.

R3C1 roster/structural choices advance; R3C2 contact/rendered/native proofs remain outstanding. No Source/Contents/version/install changes or new gameplay test this turn. C191 timing refinements stay queued for the next patch. Inspected 98dffb6 and fetched origin; only existing draft PR #1 targets dev.

## C194 confirmed head rules and module adaptations (2026-10-12)

Owner selects C193 1B/2B/3A/4B, explicitly requiring discussion of module feasibility. Confirmed: crafted-spear Ballista ammunition; forward rotary sweep with 360 Module unlocking full-circle coverage; moving rotary contact can injure players. 4B authorizes exploring melee adaptations, not implementation of every mapping or a guarantee all modules can be supported. Base.SpearCrafted already appears in project recipes; attached/upgraded spear variants are not implicitly accepted. Exact item condition/recovery, head recipes, balance, safe shutdown/service and injury severity remain unresolved.

Read-only evidence at 6ec09e7: TurretStats.resolve and Turret.cycle branch on firearm versus potato; TurretModules.profile has placement-locked cone/360 support. TurretImpactCycle.observe rearms Impact only after empty-to-loaded transition. TurretConservation.consume stores fractional ammo debt. TurretProc.hits/available/reserve and TurretVolley.capacity use bounded projectile-derived reservations. Existing conditional damage and proc helpers are reusable candidates, not proof of rotary combat. All rotary contact/rendering/obstruction and adapted-module claims below require implementation and native/rendered verification.

Proposed compatibility (not approved):

| Modules | Rotary proposal | Constraint |
| --- | --- | --- |
| Firing/Detection, including Makeshift/Enhanced | Trigger/reaction/aim support with head-specific cadence | Enhanced Firing needs a rotary baseline; no native gun-rate claim |
| Filter / 360 | Select engagement target / unlock full circle | Filter cannot make an already moving physical sweep harmless to a bystander |
| Regulator / expansion kits | Existing power reduction / module slots | Rotary has no ammo reserve; do not invent a benefit for spare ammo capacity |
| Velocity / Critical / Initial Blow / Execute | Damage, eligible reactions and conditional hits | No geometry bypass; prevent repeated reaction lock |
| Suppression | Reduce zombie hearing generated by the mechanism | Audible motor/impact balance needs owner audio review |
| Magazine / Reload / Autoloader / Impact | Attack sequence: Magazine adds strokes, Reload shortens sequence reset, Autoloader removes reset, Impact applies to the opening stroke | New persisted cycle; minimum stroke interval always remains; no continuous free Impact rearming |
| Conservation | Reduce head wear using persistent fractional wear accounting | Deliberate ammo-to-wear reinterpretation; show head-specific tooltip; no zero-wear promise |
| Splitter | Extra animated follow-up strokes, reduced damage | Extra time, power and wear; no instantaneous duplicated hits or independent overlapping swing jobs |
| Piercing | Additional distinct victims reached by the same physical sweep, with damage falloff | Does not pass walls, exceed visible reach or hit the same victim repeatedly per stroke |
| Fragment | Existing delayed shrapnel burst at outer sweep endpoint | Deliberate hybrid melee/projectile effect, including for Bat; one root event, not one burst per contact by default |
| Tack / Martyrdom / Synergy | Reuse conditional effects on eligible hits/deaths; Synergy extends eligibility to secondary contacts | Existing delays remain; recalculated admission budget, no recursive proc tree |
| Range | Longer reach only with matching visible extension | Current assets do not establish adjustable reach. Recommend defer rotary compatibility until verified |
| Accuracy | Could reduce an explicitly designed glancing-hit penalty | No existing rotary miss mechanic. Recommend no forced mapping for initial version |

Discussion choices:
1A recommended: short attack sequences with resets, enabling coherent Magazine/Reload/Autoloader/Impact mappings; 1B: continuous swings, leaving that ammo-cycle group unsupported rather than inventing artificial stat duplicates.
2A recommended: extra-stroke Splitter, same-stroke multi-victim Piercing, endpoint Fragment and existing Tack/Martyrdom with bounded Synergy; 2B: physical melee only for the first prototype, with Fragment/Tack/Martyrdom/Synergy adaptations deferred.
3A recommended: Range and Accuracy remain explicitly incompatible initially; 3B: also prototype visible reach extension and a glancing-hit accuracy system, adding rendering and balance scope.

Proposed conservation-of-resources rules: Ballista continues to treat spears as real inventory items; Conservation/Splitter must not create recoverable bonus spears. Defer the recovery decision, not silently delete/replace exact item state. Rotary costs belong to committed strokes and movement/cycle decisions, never per rendered frame; whether empty running consumes power remains a tuning choice. Shared per-victim reaction protection and bounded per-stroke contact/proc work are required. Lag cannot generate missed swing bursts. Keep visual forward-sector movement consistent with coverage; no full-circle animation paired with an arbitrarily safe rear.

No native impossibility is established for these adaptations; several are substantial custom mechanics. Do not label an unsupported module impossible or present proposed mappings as implemented. Discuss these structural choices before final stats/recipes. No Source/Contents/test/install/version changes this turn. C191 pack timing remains queued for the next patch; final art restrictions remain.

## C193 three-head development scope (2026-10-12)

Owner: "Let's create 1A 1B and 1C." Ballista, Rotary Blades and Rotary Bat are selected for development; this supersedes the unselected roster state below. Do not ask the owner to select the heads again. Scope authorization does not settle their previously unresolved behavior, ammo, recipes, stats or module interactions. No gameplay implementation/install this turn.

Recommended architecture: retain universal base, inventory, power, scheduling and service paths; implement one rotary mechanism with separate Bat/Blades tuning. Ballista extends projectile handling, while rotary heads need swept contact consistent with visible reach. Read-only inspection at 051e41b finds TurretStats currently branches on firearm profile, gates Piercing on firearm and otherwise uses potato-like defaults. TurretVolley also branches on firearm for impact handling. Explicit head capabilities are needed before adding these heads; do not merely classify Ballista or rotary heads as another potato weapon.

Present these unresolved choices before gameplay work:

| Decision | A (recommended) | B |
| --- | --- | --- |
| 1: Ballista ammunition | Dedicated craftable heavy bolts; separate head and ammo recipes | Consume crafted spears as oversized bolts, reusing an existing item |
| 2: Rotary coverage | Inherent full-circle physical sweep; 360 Module has no benefit | Facing-limited sweep, with 360 Module unlocking full circle |
| 3: Rotary player danger | Players in the moving sweep can be injured, requiring safe servicing | Players immune to rotary contact |
| 4: Module behavior | Explicit physical compatibility: Ballista projectile effects; rotary stat/conditional effects where meaningful; reject ammo/projectile-only modules on rotary heads | Design custom melee equivalents for otherwise incompatible modules, increasing scope and balance work |

Recommend prototype Ballista first, then shared rotary contact and Bat/Blades tuning, packaged together if proofs pass. Bat emphasizes lower damage and more shove; Blades emphasizes damage, without a permanent reaction loop. Exact chance/damage/reach/cadence and resource costs remain proposals to settle after these structural choices. Bolt recovery is desirable only after exact-item conservation is proven; no free recovery of Splitter/Conservation-generated projectiles. Neither recovery chance nor enabled recovery is approved by the head selection.

Recipe ingredients, retained tools, skills and XP must be reviewed with the owner under the project agreement before adding recipes. Preserve long battery life, independent Turrets operation, existing save/pickup state, no catch-up bursts and bounded workload. Verify module changes do not alter existing firearm/potato behavior. Final assets stay owner-sourced; only the already authorized technical cube/arrow placeholders can be used for proofs. R3C2 native/rendered proof is outstanding, not inferred from this design.

C191 pack refinements remain part of the next patch. R1C3/R3C7 remain open with accepted findings preserved. High effort is recommended for the shared combat implementation; it is likely to exceed 25 minutes, so Fast is recommended for that work. This turn records selection and concrete choices only.

## C192 active new-head selection (2026-10-12)

Owner requests starting the new-head track and seeing our list. This selects R3C1 discussion, not a specific head or gameplay implementation. Present choices: 1A Ballista/heavy bolt (recommended first); 1B Rotary Blades; 1C Rotary Bat; 1D Scrapshot cannon (conditional); 1E Nail Scatter (conditional); 1F Grenade lobber (later); 1G Arc emitter (later). Ballista offers the simplest first extension of the projectile system; Rotary Blades offers a larger mechanical difference but needs visible sweep/contact and obstruction proof.

Current shortlist caveats supersede historical exclusions below: Tack and delayed endpoint Fragment are now implemented, and contact slowdown is already approved for existing wire/Tack. Earlier statements that tack bullets remain excluded or Fragment is immediate are historical, not current module rules. Nail Scatter needs a distinct supply/deployment role relative to Tack; Scrapshot needs a distinct role relative to mounted shotguns with Splitter/Fragment. No renewed approval of slowing for new heads is implied. Module compatibility must follow current implemented module contracts, not the old R3C4 placeholders below.

All seven remain candidates. Potato and mounted firearms already exist; Extinguisher and Ram remain dropped, and Rotary Flail remains replaced by Blades. Next decision is which head to specify; behavior, ammo, compatible modules, collateral, recipe, wear and power must be settled before implementation. C191 timing polish stays queued for the next patch. Final art stays owner-sourced.

Planning review, 2026-10-06, revised after C81 offensive-module discussion and C82 head pruning. C82 drops Extinguisher and Ram and replaces the flail concept with Rotary Blades. The remaining heads are candidates, not approved implementations or proven native capabilities. Recipes, skills, XP, stats and exact power remain undecided. Battery longevity is an explicit requirement. Reuse the universal base and module inventory instead of duplicating turret systems. See [offensive module direction](checkpoints/R3_OFFENSIVE_MODULES.md) for confirmed concepts versus proposed tuning.

## Existing plans

- Potato launcher: implemented custom renewable-ammunition blunt-impact head.
- Mounted firearms: implemented conventional gun adapter; gun variety is not a catalogue of unique custom heads.
- Explosive launcher/trap: prior broad concept, without a selected mechanism, ammunition or approved collateral policy.
- Dart emitter: planned fixed triggered trap, not an implemented aimed turret. Proposed ownership is Traps unless an aimed version is separately requested.

No other confirmed, mechanically specified unique head exists in the current plan. Incendiaries, automatic distraction networks and unrestricted custom-gun behavior were explicitly deferred.

## Proposed shortlist

C83 adds Rotary Bat and Nail Scatter as discussion candidates and reopens limited knockback for both rotary variants. These are owner suggestions, not implemented effects or final balance approval.

| Head | Distinct purpose | Tradeoff | Feasibility and priority |
| --- | --- | --- | --- |
| Ballista / heavy bolt | Slow, accurate lane defense; finite bolts, optionally recoverable after proof | Long reload/turning, narrow effective lane; inherent limited penetration is a proposal | Strong first candidate. Initial Blow, Execute and additional Piercing could fit. Penetration alone is no longer its unique selling point; ammunition economy, cadence and placement must distinguish it. Recovery is not free duplication |
| Scrapshot cannon | Cheap improvised payload delivering a short, broad volley | Loud, poor distant accuracy, long reset and wear | Conditional second candidate. Splitter/Fragment now cover much of its proposed crowd damage. Keep only if its scrap economy and native volley differ meaningfully from a mounted shotgun with modules |
| Rotary Blades | Close-range cutting sweep guarding a choke without bullet consumption | Wear, exposure, power and unresolved player danger; no slowing or permanent control | C82 replaces flail with rigid rotating blades. A fixed sweep avoids articulated-chain simulation, but rendered contact and obstruction still need proof. Initial Blow/Execute may fit; bullet-specific modules do not. Preserve long battery life |
| Rotary Bat | Lower-damage entry variant of the rotary mechanism, using a bat rather than blades | Reach/exposure and wear; recipe accessibility and actual material availability still need review | C83 candidate. Share sweep/target/resource code with Rotary Blades. Owner suggests knockback for both; recommend a stronger shove chance on Bat, with shared victim recovery and no physics-launch promise |
| Nail Scatter / Nail Head | Deploy temporary damaging floor patches when zombies enter range; attrition across approach tiles | Consumable supplies, replenishment cadence, finite patch life/charges, maintenance and unresolved player danger | C83 candidate, distinct from a nail gun or Fragment. Recommend bounded 360-degree tile selection within radius, usable floor and clear deployment paths. No slowing or Bleed; contact, persistence and cleanup require proof |
| Grenade lobber | Slow explosive area attack, potentially reaching a different trajectory after proof | Real explosive supplies, minimum range and player/structure collateral | Optional R3C3. Fragment already provides secondary damage, so a lobber needs distinct payload/trajectory behavior. Do not assert lobbed cover-clearing is supported before collision proof |
| Arc emitter | Short-range damage chaining to a small number of nearby targets | Experimental technology, strict hop limits and resource budget | Lower-priority revision of arc stunner: damage-focused, no slow or default prolonged stun. Chain/Charge could define it. Engine damage/presentation and realistic long-lived power balance need proof; not in first grounded roster |

C191 review (2026-10-12): Tack now supplies temporary damaging/slowing floor fields, so Nail Scatter needs a distinct role before selection; do not treat the original shortlist as automatically current gameplay scope. No head is selected.

Recommend **Ballista** first for implementation fit, followed by **Rotary Blades** for a distinct role. Keep **Scrapshot** conditional on a useful difference from a modded shotgun. Grenade lobber and Arc emitter remain later candidates. C82 selects blades as the close-defense concept to discuss, not the next implementation checkpoint.

## Rotary Blades: working behavior proposal

Use a rigid rotating assembly with a fixed physical reach and bounded swept-contact checks. This is likely simpler than representing flexible chains, not proof of a working native implementation. Keep visual blade position and legal damage contact consistent; no invisible constant-damage aura or per-frame damage multiplier. Recommend at most one hit per victim per defined sweep, with a damage cadence cap independent of frame rate and explicit behavior after skipped updates.

Prove obstructions, elevation, loaded-target validity and rendered timing before content. Settle coverage (full circle versus a guarded sector), physical reach, player/faction danger, maximum victims, rotation/damage cadence and maintenance. A Range module must not create hits beyond visible reach. Rapid-Fire needs a defined safe relationship to rotation and damage cadence; Reload, opening-magazine Impact, Splitter and Fragment do not naturally apply. Initial Blow/Execute and other stat modules require declared support rather than automatic inheritance. No Bleed or slowing effect is implied by cutting damage.

Use exposure and blade wear as candidate tradeoffs while preserving C81 long battery life. Do not assume continuous spinning requires frequent battery replacement. Final assets remain owner-sourced; this is a mechanical behavior proposal, not an art brief.

C83 proposes a **Rotary Bat** as an accessible downgrade and knockback on both Bat and Blades. Recommend one shared rotary mechanism with head-specific damage, wear and hit-reaction tuning. Bat trades lower damage for a higher brief shove chance; Blades favor damage with a lower shove chance. This is a proposed distinction, not a promise of material availability or approved recipe. Native brief knockback must be proven; do not teleport targets or assume controllable physics displacement. Share per-victim recovery across nearby rotary heads, and bound reaction frequency independently of attack speed. No slowing, Bleed, permanent stagger or magazine-based Impact behavior is implied. Bat may outperform Blades at displacement despite lower killing power; explain that tradeoff rather than calling every stat a strict downgrade.

## Nail Scatter: temporary tile hazard proposal

Owner revisits the ground-hazard idea as a dedicated turret head that throws temporary tacks/nails when zombies are in range, possibly in 360 degrees over available tiles. This supersedes deferral only for discussing this new head; tack-filled bullets and a Puddle module remain excluded. Small tacks are a weak thematic justification for zombie damage; recommend a nail/spike scatter payload, with exact ammunition/recipe left for owner review. Do not substitute slowing or Bleed to make it useful.

Tile coverage is a plausible simpler representation than individual physical nails: select a bounded set of loaded same-level floor tiles whose centers lie within the deployment radius, yielding a stepped circular footprint. Check the path from head to each tile so it cannot seed through walls, closed barriers or onto another floor. Keep holes where deployment is blocked rather than forcing a perfect circle. A zombie occupying a valid tile must not automatically make that tile unavailable; large solid objects, missing floor and unsafe geometry are separate checks. Whether 360 deployment is inherent or requires the existing 360 Module, and whether radius interacts with Range, remains a decision.

Recommend throwing a limited batch onto valid uncovered/depleted tiles only while a target is in range, consuming supplies and power for the committed batch. Full coverage pauses replenishment; no unlimited layers from adjacent turrets. Each patch has finite contact uses and a lifetime. Apply bounded contact/crossing damage with a shared victim cooldown, not per-frame occupancy damage; settle stationary occupants, re-entry and knockback-induced crossings before implementation. No slowdown, reaction loop or automatic status effect. Persistent ground hazards cannot distinguish friendly footsteps just because the deploying head has a target filter; player/faction collateral needs an explicit rule.

Represent patches with bounded state and temporary owner-sourced tile presentation, not loose recoverable inventory nails per hit. Define a durable deployment identity, source attribution, caps, expiry clock and save/unload/restart reconciliation; temporary must not mean free refills on loading or indefinite accumulation. Exact life, contact damage, uses and whether destruction leaves deployed patches behind remain open. Under R3C1-R3C2, prove tile contact and lifecycle first. Keep turret-only operation independent of Traps even if a common hazard helper is useful. Battery longevity and later multiplayer authority still apply.

## Module overlap and excluded concepts

- Piercing, Splitter and Fragment are reusable effects; a new head cannot justify itself solely by reproducing one. Heads own ammunition, cadence, physical attack pattern and service tradeoffs. Modules tune compatible capabilities rather than turning every head into every other head.
- Initial Blow/Execute are the broadest proposed offensive modifiers. Impact is defined around a magazine's opening bullet; do not apply it to every blade contact or pretend a melee head has a magazine. Splitter/Fragment remain projectile-specific. Exact compatible heads, ammunition costs and fragment range await R3C4.
- C82 drops Extinguisher as roster clutter and Pneumatic Ram as insufficiently effective for its reach; neither remains deferred active content. Rotary Flail is superseded by Rotary Blades. Do not reintroduce these candidates without new owner direction.
- Homing and Bleed are excluded by owner direction. Net launchers and chemical slowing heads leave the active shortlist because slowing undermines OMH Horde Night zombies. Dedicated stun-lock heads do not solve that concern by renaming the effect.
- Puddle/tack-bullet modules remain excluded. C83 reopens temporary ground scatter specifically as a Nail Scatter head candidate above. Fragment remains immediate radial shots with no persistent ground hazard; do not conflate the two mechanics.
- Flechette repeater/nail gun overlap conventional mounts and lose the proposed Bleed niche. Coil launcher overlaps ballista and introduces experimental power demands. Laser cutter could offer sustained tracking/heat but is a later speculative system, not approved content. Wiggle/Curveball/Malformed/Leech remain outside the planned set.
- Existing potato impact splash remains intact and distinct from Fragment. Resolve per-head combination behavior explicitly rather than replacing potato identity or applying two indistinguishable secondary-damage systems by default.

## Ideas to challenge or defer

- Flamethrowers need deliberate fire-spread, structure/player damage and performance decisions. A warning tooltip cannot solve uncontrolled spread or engine limits. Recommend deferring.
- Harpoon dragging, arbitrary physics throws and live camera control add engine/ownership complexity. A heavy bolt without pulling is the simpler starting point.
- Unlimited piercing, fragments, chain hits or repeated stuns scale poorly or create permanent control loops. Bound victims and establish recovery rules first.
- Modules need declared compatibility. Reload must not invent a magazine for rotary blades. Show incompatible modules clearly and reuse the common stat pipeline where applicable. Higher power costs must remain compatible with C81 battery endurance; wear, supply consumption and service time provide other tradeoffs.

Each selected head follows R3C1-R3C2 in [the roadmap](ROADMAP.md): approve behavior, prove the risky mechanic, agree recipe/tuning, implement, then verify resources, persistence, performance and presentation. Approval cannot create a missing engine capability; report failed proofs and propose alternatives instead of quietly changing the feature.
