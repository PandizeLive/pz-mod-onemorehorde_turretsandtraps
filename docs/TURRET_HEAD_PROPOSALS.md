# Unique turret head candidates

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
