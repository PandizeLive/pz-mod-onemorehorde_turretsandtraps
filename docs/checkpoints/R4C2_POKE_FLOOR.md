# R4C2 — Poke Floor

**Current correction — C334:** Poke Floor triggers itself through contact, with no external Button/Plate or manual firing. Earlier external-trigger proposals below are superseded. Tire Pump/improvised crafting and local-battery-first priority are selected. Zombie occupancy repetition remains the presented choice.

## C332 — Initial content choices proposed (2026-10-19)

Owner asks: "Anything need to be discussed with poke floor?" This authorizes discussion, not implementation. Inspected active branch e93f7dc, fetched origin/dev and confirmed the existing draft PR #1 is the only open PR. Installed 0.2.56.1 and its deferred owner test remain unchanged.

Settled: a Button requests one extension/retraction cycle; a held input repeats legal cycles; normal release completes the current cycle and retracts safely. Multiple inputs never multiply cadence or queue a backlog. Independent Traps package, existing ownership/controller access and Horde Night consent/scoring contracts remain requirements. No new targeting, score or friendly-fire exemption is inferred.

All values below are proposals. A is recommended in every block; the alternatives expose distinct tradeoffs, not approved fallback behavior.

**1 — Footprint.** 1A: one tile, independently placeable. 1B: one linked 1x2 assembly sharing condition and service. One tile is easier to place around doors and pair with existing triggers. Both proposals are walkable/nonblocking, non-thumpable floor devices and allow only one damaging floor trap per occupied tile. On intact supported floor, not an excavation system; detailed native placement validation is implementation work. One trap per craft; proposed item weight 8 excluding battery for 1A, 16 for 1B. A 1B selection doubles recipe materials, HP and repair materials; per-target damage is unchanged and one victim cannot take duplicate damage from both halves during one cycle. Battery draw doubles for the larger mechanism.

**2 — Strike.** 2A: 100 damage, one complete cycle per 3 real simulation seconds. 2B: 50 damage, one per 1.5 seconds. These have the same theoretical per-target DPS; A is more readable and needs fewer repeated contact checks. Damage only during the upward strike, at most once per eligible zombie per cycle, including crawlers and prone zombies on the occupied tile. No free hits while retracted, no persistent contact damage while raised, no splash beyond footprint, no knockdown/stun/root and no instant-kill guarantee. All eligible contacted zombies can be hit; do not silently limit to one victim. Ordinary pause/simulation timing applies; never scale cycle seconds as in-game hours.

**3 — Power.** 3A: local electricity with an installed car battery as backup; initially charge 0.05 percentage points of full charge per cycle for the 1A footprint, including misses. 3B: local electricity only, without a battery slot. A supports remote defenses and outages; signals remain requests, not energy supplied by the Controller. Consume/reserve energy before admitting a cycle; successful admission includes safe retraction even if the external signal or supply is lost. Off-state motor drain is zero. Do not claim a measured endurance target; battery variants/capacity and native power reach need implementation verification.

**4 — Player injuries.** 4A: active upward strikes can injure players, including owner/faction, using a proposed 20% chance of one foot/lower-leg scratch with a shared five-second injury guard across these traps. No zombie damage number applied to player health. 4B: zombies only. A makes a deliberately triggered floor hazard meaningful; retracted traps are safe. Preserve applicable server injury/PvP restrictions; no blanket bypass or friendly-fire permission is introduced. Exact protection behavior must be reconciled with existing trap injury policy before code rather than silently inventing an exemption.

**5 — Wear and repair.** Base 1A footprint: 200 HP. 5A: lose 1 HP per cycle that hits at least one eligible victim, not per victim. Empty cycles use power but no wear. 5B: lose 1 HP every completed cycle, including misses. Both: 2 Scrap Metal and 10 seconds to restore full condition, no repair XP; pickup takes 10 seconds, retains condition and the exact installed battery, with no pickup-repair exploit. Broken devices stop, retract safely and remain repairable. Services require the device off and ordinary reach/access/authority. These are new Poke Floor rules, not changes to existing free trap repair/pickup behavior.

**6 — Recipe.** 6A: 2 Metal Pipes, 4 Metal Bars, 2 Small Metal Sheets, 4 Electronics Scrap, 2 Electric Wire, 8 Screws. Keep a screwdriver and wrench/pipe wrench. Mechanics 2 + Electrical 2; 30-second craft; award 20 Mechanics XP + 10 Electrical XP. 6B: replace the 2 Metal Pipes with 1 Jack and reduce the Mechanics requirement to 1; all other quantities, Electrical requirement, time, XP and output unchanged. A avoids a dedicated scavenged component; B gives the lifting mechanism a recognizable native item. Crafted-only first release, no new loot or Module Pack entry/rarity. Both recipes produce identical performance, no installed battery. Explicit material/skill/XP approval is needed before implementation. Native installed 42.21 item definitions confirm Jack, MetalBar, MetalPipe, SmallSheetMetal, ElectronicsScrap and ElectricWire exist; this is not proof that the full recipe has run.

**7 — Upgrades.** 7A: fixed-stat trap without turret-module slots for the first version. 7B: design module compatibility before implementation. Recommend A: a new module host introduces eligibility, slot/storage, UI, power and independent-package questions beyond validating the trap itself. Do not implicitly make Traps depend on Turrets. Sandbox tuning for selected damage/cadence/HP/battery/injury/wear remains appropriate under either choice, without changing existing saved settings.

## Implementation and acceptance limits

Use a bounded server-owned phase state and victim-per-cycle guard; reuse checked contact/combat/score paths where applicable. No per-frame scans of every zombie and every trap, and no simulated unloaded combat. Verify listen/dedicated authority, late join, simultaneous inputs, pause, unload/reload, pickup/destruction, no duplicate damage/score and safe retraction before claiming support. Native collision/render timing remains to prove; final art stays owner-sourced, with only the already-authorized functional placeholder allowed. No pcall/xpcall workaround.

This proposal does not reopen C329 layout, existing trigger behavior, ownership or Horde Night consent. Discussion can proceed while the 0.2.56.1 owner test is deferred. Decision needed: choices 1–7; no new patch approved.

## C333 — Owner selections and shared fallback power (2026-10-19)

Owner selects 1A, 2B, 3A, 5A and 6B, replaces the injury proposal, requests an improvised recipe without the Jack, asks whether a Tire Pump is more appropriate, and explicitly states that traps do not have modules. Owner also requests Controller car batteries, sequential spare-battery use and Controller-battery fallback for connected turrets/traps; Siphon must not affect the Controller. This is the next-patch design discussion, with the concrete remaining choices below. Do not implement unresolved interpretations as already selected.

### Settled scope

- One-tile Poke Floor, proposed weight 8 from selected 1A; walkable/non-thumpable footprint.
- 50 zombie damage per 1.5-second cycle (2B), per-victim once during the upward strike; no stun or adjacent splash. Button/held-input cycle behavior remains settled.
- Local electricity/car battery (3A); 0.05 percentage points per accepted cycle including misses. Add the newly requested assigned-Controller battery fallback, rather than treating C332's receiver-only source list as final.
- 200 HP, one wear per cycle that hits one or more eligible victims, no per-victim wear (5A). Retain the selected 2 Scrap Metal/10-second full repair and condition-preserving pickup terms.
- Standard recipe initially selected as Jack-based (6B), plus an improvised version without the Jack. Tire Pump substitution is requested for evaluation, not yet chosen. Keep the remainder of the C332 recipe, craft time, tools and XP unless explicitly changed.
- Traps do not accept modules. This is a product rule, not merely a first-release restriction. Turret module behavior remains a separate system.

### Movement and injury correction

Installed project code: `BedPlayer.lua` calls `ContactPlayer.update`. Upright walking applies the existing brush traversal animation, while the scratch chance is checked on entry when running/sprinting; sprint entry has a separate trip chance. A new fall onto the hazard applies a cut. The Bed Spikes branch does not use the same explicit movement divisor as barbs. Do not describe all of these as one generic per-frame scratch roll.

Owner wants the same careful walking/traversal behavior, but a successful would-scratch result requests a Poke Floor cycle instead of immediately injuring the player. The actual upward strike causes the normal appropriate trap injury if the player is still in contact; no injury before visible activation and no second random roll for that already-successful scratch event. Reuse movement/entry rules, not both old direct-injury callbacks and new strike damage. This introduces an intrinsic contact activation path alongside linked triggers. It still requires an operational device and sufficient real energy; do not bypass cooldown, manual Off, safe retraction, ownership/security or current server restrictions. No unpowered, broken or cancelled cycle grants an invisible wound. Sprint trips/fall consequences need sequencing with the accepted stroke to avoid duplicate old/new wounds; native implementation evidence is still required.

The owner's change supersedes C332's generic 20%-on-every-strike injury proposal. Do not silently retain its extra universal five-second injury guard as selected; entry guards and per-cycle deduplication remain required. Exact externally triggered player-contact behavior is choice 2 below.

### Controller battery bank — requested behavior and implementation direction

Use the same supported car-battery family as turrets instead of ordinary `Base.Battery` for Controller operation. UI slot, silhouette, tooltip/count, exact-item selection, insertion validation and estimates must change together. Multiple eligible top-level stored car batteries are usable sequentially; choose the next charged battery automatically when the active battery cannot supply the requested debit. Preserve empty batteries for recharging; do not delete, refill or convert them. Existing ordinary batteries retain identity/charge and remain removable in the Stockpile but cease to power the Controller. Preserve the 500-weight stockpile limit; no unlimited or weight-free battery bank is authorized.

Only a valid loaded device assigned to its valid Controller within the existing same-floor 20-tile range may draw fallback energy. A proximity scan or read permission alone must not grant access to somebody else's bank. Assignment/ownership and exact item identity remain server-authoritative. This does not transfer mains/generator coverage through links; the specifically requested shared source is the Controller battery. Passive unpowered traps acquire no artificial power requirement. No player must remain beside the Controller for a valid installed defense to operate.

The existing Controller already caches a selected ordinary battery, advances through stored candidates and charges its own idle cost at `elapsedHours / 48`. The new work must support an atomic server-side operation debit in addition to idle consumption. Preserve current no-load idle cost initially unless retuned separately; loaded uptime is no longer the idle-only 48-hour figure. Debit each receiver's normal configured operation cost (including turret power modifiers) exactly once; no arbitrary extra per-device multiplier. A source inspected during UI/aiming is not a promise it still has energy when the attack commits. Revalidate power, identity and total available charge at commitment; no overdraft or free partial shot from simultaneous requests. Whole cycles reserve safe completion, including retraction. Source withdrawal, depletion, unload, destruction, reassignment and reload must cancel/re-resolve safely without stale drain.

Use existing bounded/cached stockpile traversal, not repeated full inventory/world scans per turret per frame. Present Local Battery versus Controller Battery and bank supply distinctly. Tests must include SP, dedicated/listen paths, concurrent receivers, battery rollover/removal, exact fractional charge persistence and replicated counts. Architecture is proposed, not native/runtime proof.

Siphon: the Controller must never receive a refund. Recommended exact-source interpretation: Siphon refunds only charge actually paid by that turret's own installed battery, to that same battery. Controller-funded shots give no Siphon refund, including no credit into an empty local battery; otherwise the bank could manufacture turret charge indirectly. Existing Siphon snapshot/generation safeguards must be retained. Owner's explicit Controller exclusion is settled; this implementation interpretation is presented transparently for confirmation.

### Remaining choices presented to owner

**1 — Standard recipe donor.** 1A recommended: replace the standard Jack with one Tire Pump, keeping Electrical 2/Mechanics 1; add the improvised two-Metal-Pipe recipe at Electrical 2/Mechanics 2. 1B: retain the selected Jack standard and add the same improvised recipe. Both outputs have identical stats and use all other C332 material counts, 30-second crafting, retained screwdriver/wrench and 20 Mechanics/10 Electrical XP. A Tire Pump is a plausible donor piston/cylinder for a short reciprocating jab; it is not itself a self-powered compressor. A Jack suggests lifting load rather than fast repeated strokes. Do not promise mechanically exact real-world engineering or add unapproved compressed-air/ammo items. The installed native definitions include both `Base.Jack` and `Base.TirePump`.

**2 — Player already over an externally triggered trap.** 2A recommended: careful walking avoids the movement-based accidental activation roll, but a Button/Plate-triggered upward strike can still injure a player in contact. 2B: careful walkers are immune even during an externally triggered strike. A preserves the distinction between avoiding accidental activation and stepping on a mechanism somebody else activates. Intrinsic successful scratch rolls cause actual strike injury as requested in either choice; no duplicate wound from the contact request plus the same stroke.

**3 — Battery priority.** Electricity/generator first in both cases. 3A recommended: device's installed battery, then assigned Controller's battery as fallback. 3B: Controller battery, preserving the device's battery as the last reserve. A follows the ordinary meaning of fallback and lets local Siphon remain useful; B centralizes routine servicing. Only battery priority is undecided, not whether shared fallback exists.

No source/package/version changes are made in this planning turn. Inspected active branch f7d5d5a, fetched origin/dev and confirmed draft PR #1 remains the only open PR. The installed 0.2.56.1 owner test stays deferred; selected choices are not rendered or connected acceptance.

## C334 — Self-triggering Poke Floor; recipe and power order selected (2026-10-19)

Owner selects C333 1A and 3A and corrects activation: Pokes are triggered by the trap itself, need no external trigger, and external/manual activation should do nothing.

Confirmed: standard recipe uses one Tire Pump; improvised uses two Metal Pipes. Keep equal output performance and the C333 common materials, tools, skills, time and XP. Power priority is local electricity/generator, then the device battery, then its assigned Controller battery bank. Stored spares, exact shared debits, 500-weight capacity and Controller Siphon exclusion remain in scope.

Poke Floor is a self-triggering contact trap, not an external signal receiver. Do not offer Button/Plate links or manual Fire/Poke actions. Hide incompatible input ports/actions on Map and Connections, and reject unsupported linking/activation on the server. Controller assignment remains useful for management and fallback power, not firing. Ordinary disarming/service is distinct from a manual strike. This does not change turret signal behavior or preselect the future dart emitter's rules.

The owner's Bed Spikes-style careful traversal and would-scratch -> actual stroke -> wound sequence remains. Do not restore the rejected generic per-strike roll or hypothetical external-trigger injury rule. Failed/unpowered activation cannot injure invisibly; deduplicate the contact request and the resulting strike. Existing power, operational state, safe retraction and 50 damage / 1.5-second cadence remain. Traps have no modules.

This explicitly supersedes all earlier Poke Floor Button-single-cycle and held-Plate-repetition rules. The original activation source is no longer valid; safe cycle completion and no backlog remain requirements.

### Remaining choice — zombies staying on the tile

The existing Bed Spikes code uses movement to offer a trip and a new fall to cause damage; it is not a persistent occupancy actuator. Do not silently inherit it as the new zombie activation policy.

**1A recommended:** eligible zombie contact starts a cycle and continued occupancy repeats at most once per 1.5 seconds. Stop scheduling when clear and complete safe retraction. Include standing, crawling and prone eligible zombies; preserve one hit per victim per strike and Horde Night consent. Stationary zombies cannot bypass the trap.

**1B:** one cycle on first entry, then rearm only after all eligible zombies leave. The 1.5-second minimum still applies; rapid entries never queue a backlog. This reduces upkeep/output but leaves a stationary crowd untouched after the first cycle.

This choice concerns zombies only. Player movement/injury eligibility is already owner-directed and must not become automatic activation for every careful walker.

Planning only. Inspected bd7795f, fetched origin/dev and confirmed draft PR #1 is the only open PR. No gameplay/package/version/install change or new test. Installed 0.2.56.1 owner and connected acceptance remain deferred.
