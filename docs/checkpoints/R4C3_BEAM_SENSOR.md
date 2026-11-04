# R4C3 - Laser / beam sensor

## C376 - Discuss before build approval (2026-10-21)

Owner asks whether to discuss the laser now or approve Lever first. Recommend continuing laser design now, retaining the settled C375 Lever scope, and considering a combined build once content and native feasibility are settled. This is a recommendation; no combined implementation, merge or publication is authorized by the process question. 0.2.59.1 remains installed with owner testing deferred.

Existing DESIGN.md specifies an obstruction sensor: ON while blocked, OFF when clear. It does not identify friend from foe; receiver targeting/damage policy remains separate. Use current trigger links, permissions, OR contributions and finish-current-action behavior. Passive hazards/Poke Floor do not become signal receivers. Sensors remain non-thumpable under the existing owner rule; no trap modules.

### 1 - Physical setup

**1A (recommended): emitter plus passive reflector**, placed across a passage as one logical Controller input. Clearly defines the monitored segment and requires no second powered endpoint. Costs and native paired-placement/alignment support still need review; this is not an existing native-system claim.

**1B: one wall-mounted unit with a straight detection line**, simpler setup and fewer parts, with the endpoint defined by its configured range/geometry rather than another placed object. Exact static-obstruction and range rules must be settled if chosen.

### 2 - Visible beam

**2A (recommended): faint beam visible during powered operation**, making the monitored line understandable in ordinary play. No light while unpowered; showing beam state/where an obstruction cuts it remains part of implementation verification.

**2B: beam visible only during setup/selection**, reducing visual clutter but making its operating line less obvious afterward.

No beam color/final artwork, range, battery cost, ingredients, skill or XP is selected. Current authorization remains owner-supplied final art and functional technical placeholders only. Before implementation, settle power, maximum reach, mounting/axis restrictions, static obstruction versus moving occupants, fault/unload behavior, player interaction/collateral and a coherent recipe/service contract. Preserve the distinction between an interrupted valid beam and a failed/unpowered/missing endpoint; losing an endpoint must not invent persistent fire. Runtime proof needs bounded local checks, fast crossings, crawlers, door/wall obstruction, lifecycle cleanup, save/load and server-owned synchronization. These are verification requirements, not passed tests.

The prior Lever patch can remain separate if the sensor needs more investigation. No need to force a Lever-only approval before discussing it. New choices 1/2 are unselected.


## C377 — Single-unit visible beam selected (2026-10-21)

Owner selects C376 1B / 2A: one wall-mounted sensor projects a forward detection line, no placed reflector/receiver, faint beam visible during powered operation. This settles setup and visibility only. Lever C375 remains selected, including its separate faint green ON light; do not silently make the sensor beam green. Sensor color/final presentation remains unselected.

### 1 - Power

**1A (recommended): use the assigned Controller's supply**, no battery slot on every sensor. Follow the Controller's existing mains/generator or Car Battery bank availability, with eventual defined sensor load paid from the applicable source. It requires a valid assigned, loaded, in-range Controller; it cannot operate standalone. This adds a sensor supply policy; current ControlPower.idle supports Controller electricity/battery operation, while its fallback helper is specifically a car-bank debit, so do not claim remote grid support already exists.

**1B: a local ordinary Battery, then assigned Controller fallback.** Allows standalone operation, but adds per-sensor inventory, service and charge accounting. Exact runtime/consumption is not yet selected for either option; present it with the final recipe once supply is chosen. Signals never replace the receiving turret's actual power/ammunition requirements.

### 2 - Reach

**2A (recommended): adjustable 1-10 tiles**, suited to doorways/corridors and modest perimeter coverage. **2B: adjustable 1-20 tiles**, covering longer open stretches with fewer devices. Both propose the four wall-facing directions on the same floor; neither implies diagonal aiming, tracking or seeing through opaque obstacles. Bounds and obstruction preview must agree with the monitored segment. These numbers are proposals, not measured performance limits.

### 3 - Static obstructions

**3A (recommended): walls and closed doors stop/shorten the beam; only an actor interrupting the remaining visible segment supplies ON.** A closed door does not cause indefinite repeated fire by itself. Players and zombies, including crawlers, can interrupt it; no implicit friend/foe classification. This refines the earlier generic obstruction wording for a single-ended device and requires explicit selection.

**3B: closed doors also count as an interruption and hold ON**, useful for a door-sensitive setup but capable of keeping receivers active while the door remains shut. Walls still terminate the line. No history/calibration system is proposed.

For both: eligible actor interruption holds ON; clear returns OFF. Detect crossings between samples so a fast crossing is not silently missed, reuse the established admitted-cycle rule on receivers, and verify crawler coverage. Loss of sensor power, destruction/unload or invalid Controller supply removes output and beam presentation. Reconcile current state on reload; no replay of old events. Non-thumpable/no-module rules remain. Crafting/skill/XP/weight/condition, consumption and final technical indicator choice are next after these decisions, before implementation approval.

Source reviewed: ControlWorld.power delegates to ControlPower.idle; Controller idle supports electricity then a real Car Battery bank, while fallback validates assigned host/range and pays from bank charge. This grounds the proposed integration but is not sensor implementation or a connected test. Installed 0.2.59.1 remains unchanged with owner testing deferred; no gameplay edits, new test claim, merge or publication.


## C378 — Controller supply and range selected (2026-10-21)

Owner: "1A - maybe we apply this to all triggers. We avoided it before, but it's worth a look. 2A". Select assigned Controller power and adjustable 1-10 tiles for the laser. Single wall unit/no reflector/faint visible powered beam remain selected. The wider rule is explicitly an idea to assess, not an approved retrofit. C377 obstruction option 3 remains unselected.

Current source evidence: ControlWorld.input accepts a placed, loaded, healthy, recovered, in-range input and its active state; it does not check its assigned Controller or that Controller's power. ControlWorld.link accepts Plate/Button -> Turret/Tether by endpoint types, range and bounded link counts, without an assignment-power condition. ControlAction's Button pulse directly dispatches to eligible receivers. This establishes that a new all-trigger rule affects actual activation paths, not merely the menu. Do not claim standalone linking UI coverage from these code checks alone.

### New 1 - Scope of Controller dependence

**1A: require a powered assigned Controller for Button, Plate, Lever and laser.** Consistent central supply/maintenance and one clear connected-base rule, but makes even a basic plate/turret setup depend on a Controller and makes Controller power loss a common failure point. If selected, basic input supply could be covered by Controller idle overhead, with explicit incremental laser draw settled separately; no individual trigger battery slots. Explain disabled/unassigned states rather than silently ignoring interactions. Gate both direct Button pulses and held-input admission on the server; presentation-only changes are insufficient.

**1B (recommended): require Controller supply only for laser/electronic sensors; retain independent mechanical Button/Plate/Lever signals.** Preserves simple early setups and avoids making a non-powered mechanism dependent on a control box. Controller management/link organization remains available. Receivers still need their own actual resources. Lever's faint green feedback can remain cosmetic under this option; do not invent a local battery.

If 1A is selected, preserve links and the Lever's saved ON/OFF setting through a supply outage, but suppress output and extinguish powered indicators. On restoration recompute current held states (occupied Plate, ON Lever, interrupted beam); never replay old Button presses. Loss of an input's supply does not cancel an already admitted receiver action if the receiver retains its own power/resources; a real receiver power fault retains existing cancellation rules. Another powered OR-linked input can keep the receiver active. Source failure must not unlink Tether and accidentally restore autonomous firing. The Controller itself must remain independently powerable to avoid a circular startup dependency. Exact timing/fault behavior still needs native and connected verification.

Mechanical Poke Floor and passive traps are not triggers and are excluded from the proposed Controller requirement. Do not reintroduce Poke battery use. Controller mains/generator/car-bank behavior and turret-local Siphon stay unchanged.

### Remaining 3 - Beam obstruction

**3A (recommended): walls/closed doors shorten the monitored beam; no signal from the door alone.** Actors in the visible segment supply ON. **3B: closed doors also hold ON**, potentially sustaining receiver operation while shut. This was not answered by the range selection; do not infer it.

Crafting and exact sensor load remain to settle after these choices. No gameplay patch or new verification result this discussion. Installed 0.2.59.1 remains deferred, and Lever C375 stays selected without implementation approval.


## C379 — Shared power and obstruction selected (2026-10-21)

Owner selects C378 1A with "the non electrical will consume very low electricity when active", and 3A. Every trigger (Button, Pressure Plate, Lever, laser) requires a valid powered assigned Controller. This supersedes independent basic-input activation. Mechanical inputs consume very little while active; their incremental inactive draw is zero, separate from existing Controller overhead. Poke Floor and passive hazards are not triggers and remain independent. Receiving turrets still pay their own real ammunition/energy costs; Siphon never refunds Controller charge.

Walls/closed doors shorten the laser's visible/monitored line without generating ON by themselves. Actor crossings/occupancy within that segment hold ON, clear returns OFF. Preserve unpowered/invalid-source OFF, existing link identity, OR inputs and admitted-action rules. Controller power loss extinguishes the laser and Lever green indicator, but retains the Lever's stored switch position; power restoration reconciles current held states without replaying historical Button presses. Do not remove failed source links and thereby restore Tether autonomous sensing.

### Proposed final balance, common to both recipe choices

Battery costs below are **percentage points of one full Controller car battery**, additive to Controller idle and receiver operation. Time uses **in-game hours**, unlike the earlier real-hour head comparison.

| Input | Proposed incremental draw |
| --- | --- |
| Button | 0.0001% per accepted press, charged once per source event rather than per linked receiver |
| Pressure Plate | 0.01% per game hour while occupied/actively supplying signal |
| Lever | 0.01% per game hour while ON and powered |
| Laser | 0.10% per game hour while scanning/powered, whether interrupted or clear |

For scale, a continuously ON mechanical input adds 0.24% per 24 game hours; one laser adds 2.4%; 10,000 Button presses add 1%. These are proposed arithmetic rates, not endurance measurements. Existing Controller battery-only overhead is 100/48 percentage points per game hour; do not mistake incremental rates for whole-base endurance. Controller mains/generator availability uses its existing supply priority and avoids bank debit; native incremental generator-load accounting is not established by this proposal. No separate batteries on inputs. Preserve fractional debits, authority, spare-bank selection, bounded accumulation and pause/fast-forward consistency; do not round away tiny costs or allocate separate per-trigger frame scans. Expose meaningful Sandbox tuning.

### Remaining package choice - Sensor crafting

**1A (recommended): craft from raw components:** two Electronics Scrap, one Electric Wire, one Small Sheet Metal and two Screws. No existing Button is consumed.

**1B: upgrade one Button:** one Button, one Electronics Scrap and one Small Sheet Metal. Its raw-material total is equivalent to A given the existing Button recipe; transfer Button condition instead of granting a free repair. Retire the consumed Button's identity/links and create a newly assigned sensor identity, never carry old Button pulses.

Both propose the above balance plus retained Screwdriver/Pliers, Electricity 2, ten Electricity XP, 20-second crafting, 0.5 item weight and 100 condition. Crafted-only; no new loot rarity/weight. Standard trigger service: 1s place/pickup and 2s repair, retained Screwdriver, no repair material; preserve condition on pickup. Reuse OMH: Triggers, unique names, Controller assignment/permissions/links and Stockpile admission. Functional temporary beam presentation stays within the existing authorized developer-marker style; no generated final art or artist-direction change.

These exact rates, recipe and new sensor values remain proposed pending package selection; owner has selected the shared supply principle and obstruction rule only. Lever recipe/service/latch remain C375 with its new Controller-power prerequisite. No gameplay edits, tests, installed-version change, merge or publication this turn. 0.2.59.1 owner testing remains deferred. A final combined recap/implementation approval follows the remaining package decision.


## C380 -- Recipe selected and consumption tooltip review (2026-10-21)

Owner selects C379 1A and asks whether Button should be Minimal, others Very Low, with that information in tooltips. Select the raw-component recipe and common package recorded in C379: two Electronics Scrap, one Electric Wire, one Small Sheet Metal, two Screws; retained Screwdriver/Pliers; Electricity 2, 10 XP, 20s crafting, weight 0.5, condition 100, crafted-only and standard trigger service. Button-upgrade alternative is not selected. Exact C379 incremental rates are selected: Button 0.0001% per accepted press, Plate/Lever 0.01% per active game hour, laser 0.10% per scanning game hour. This is design selection, not combined gameplay-build approval.

Tooltip requirement is selected. Rating clarification/recommendation: TurretHeadDescription.rating currently uses percentage points per real unpaused hour with thresholds 1/2.5/5/15/30/60. At a 60-real-minute game day (24 game hours per real hour), Plate/Lever cost 0.24% per real hour, hence Minimal; laser costs 2.4%, hence Very Low. At a 90-minute day these become 0.16% and 1.6%, with the same labels. Different day lengths or Sandbox rates can change hourly bands; do not silently compare per-game-hour values against per-real-hour thresholds. These are calculations, not endurance tests.

Recommend Button 'Minimal (per press)' as an explicitly qualitative per-use description with the exact cost, not a purported hourly rating: 10,000 accepted presses consume 1%. No reference press cadence has been selected. Recommend retaining the shared quantitative bands for continuous triggers with normal-speed day-length conversion and effective Sandbox values. Do not raise costs or invent separate trigger-relative thresholds merely to make every other trigger Very Low. The owner has requested labels but has not yet confirmed this clarification of rating semantics.

Tooltip contents should include the OMH-colored consumption label, exact incremental cost and basis, active condition, and 'Power source: Assigned Controller'. Button: per accepted press. Plate: while occupied. Lever: while ON and powered. Laser: while scanning, including a clear beam. Explain that these costs exclude Controller idle and connected defenses, and that bank debit applies while the Controller is using batteries. No unverified incremental generator-fuel behavior is promised. Keep item and Manage/Controller device descriptions consistent without duplicating balance constants.

Planning only: no source/package edits, new gameplay tests, version bump, install, merge or Workshop upload. Installed 0.2.59.1 remains awaiting owner testing. Combined Lever/laser/all-trigger power implementation still awaits final build approval.


## C381 -- Combined build approved (2026-10-21)

Owner: "Approved" after C380 tooltip/rating clarification and combined-build approval handoff. Authorizes implementing the settled Lever, laser, shared Controller power and tooltip package, including the recommended Minimal basic triggers / Very Low laser at 60-minute days and hourly conversion; Button per-use qualifier remains explicit. Native tests and release evidence follow; approval is not acceptance.


## C381 -- 0.2.60 implementation (2026-10-21)

Settled C375-C380 behavior is implemented in the combined build. See [patch](../PATCH_v0.2.60.md) and [verification](../TEST_v0.2.60.md) for exact behavior, native evidence and remaining rendered/connected-player acceptance. The approved indicator is a faint local green glow; Laser retains the white functional development panel. Native headless construction and persistence are verified, not rendered acceptance. Publication remains separate.
