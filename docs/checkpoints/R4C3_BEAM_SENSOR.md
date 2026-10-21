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
