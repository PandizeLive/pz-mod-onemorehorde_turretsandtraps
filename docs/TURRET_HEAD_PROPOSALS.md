# Unique turret head candidates

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
