# Content and balance plan

Status: proposed tuning plan. Confirmed requirements are identified in [Decisions](DECISIONS.md); unapproved numbers here are experiments, not shipped defaults.

## Planned roster

| Device | Intended role and behavior | Limiting costs | Earliest checkpoint |
| --- | --- | --- | --- |
| Potato turret | Quiet, cheap, farmable ammunition; one shot per second, higher knockdown, potato impact pop and tiny splash | Cadence, hopper capacity, wear; pressure/power design TBD | P1C3 prototype; P2C3 content |
| Bed spikes / Punji | Cheap excavated ground stakes; players automatically jump over them; distinct identity from Spear Traps | Digging/rearming effort; wear/catching capacity proposed | P2C2, beginning with traversal prototype |
| Spike Barrier / Cheval de frise | Cheap freestanding path blocker; damages attackers on thumps; players cannot walk into or vault over it | Direction, footprint, structural health and servicing | P1C2 prototype; P2C2 content |
| Barbed barricade | Attach to an existing barricade; share its remaining HP; damage on thumps | Host health; independent wire wear proposed | P2C2 |
| Concertina | Slow and damage while in contact | Wire cost, traffic wear, maximum slow proposed | P2C4 feasibility; P4C3 content |
| Button / pressure plate | Pulse / maintained ON signal respectively | Placement, access, linkage limits TBD | P4C1 |
| Beam sensor | Maintained ON while obstructed | Power, alignment, range and obstruction rules TBD | P4C3 |
| Control unit | Change targeting for one or all compatible linked smart defenses, including players, other factions or no one; passive objects excluded | Authorized access, linking, smart-device capability and collateral details TBD | P4C1 |
| Poke Floor | Retractable spikes, one strike window per cycle | Reset interval, strike capacity, wear/power TBD | P4C2 |
| Dart emitter | Narrow fixed firing lane | Ammo, reset interval, partial recovery proposed | P4C2 |
| Firearm sentry | Real ammunition; camera/controller-assisted targeting proposed | Ammo scarcity, power, acquisition/turning, magazine, wear | P5C1 |
| Explosive launcher/trap | Specialized crowd damage | Expensive ammo, slow operation, collateral and safe range TBD | P5C2 |

Candidate supporting content: toggle switch, trip alarm, manual drop-weight trap. These remain suggestions. The control unit is now owner-confirmed planned content, with individual/all-linked targeting controls.

Do not bundle automatically triggered noise lures into the first release. The owner identified the tripwire -> sound behind zombie -> return across wire loop. Power consumption or a simple cooldown limits duration but does not establish fair routing behavior.

## Potato tuning

- Owner target: 3-5 successful direct hits against a specified reference shambler, high knockdown chance, one shot per second. The prototype uses real time and fixed 0.50 HP direct damage, targeting 4-5 hits against current Normal-toughness health of 1.8-2.1. Tough/Random configurations must be reported separately; no percentage-of-target scaling.
- Use fixed damage calibrated to the reference, not a percentage of each target's maximum health. This preserves tougher-zombie progression. This is the recommended implementation approach.
- Misses, line obstruction, target acquisition, and reload downtime count toward practical effectiveness.
- Proposed knockdown: direct hit only, standing targets only, with shared recovery protection across all devices. Exact chance and protection duration TBD.
- Confirmed splash: real but extremely low damage. Proposed limit: bounded radius, victim count, and total splash budget, with no secondary stagger/knockdown or double-hit of the direct victim. Exact damage/radius remain TBD.
- Aggregate splash must remain negligible at the maximum supported crowd density. A tiny amount per target can become substantial when multiplied by a large crowd.
- Multiple synchronized turrets, downed targets, sprinters, tougher zombies, and splash finishing blows all require explicit tests.
- Proposed pressure charging is not yet a requirement. Confirm the early turret's operation and ammunition/spoilage policy before recipes.

## Distinct trap behavior

Recommended punji direction: shallow stake bed with replaceable bundles, partial damage, finite catching capacity and servicing. The owner's original grave workflow remains an open alternative. Do not reproduce another mod's assets/code or advertise the recommended design as already approved.

Confirmed player traversal is automatic jumping over the bed spikes, regardless of faction. The footprint must support a proven jump; excavation choice must not silently produce an uncrossable bed or fake teleport. This makes bed spikes an accessible crossing for hostile players too, so do not balance them as an anti-player wall. Zombie crossing/damage behavior is a separate requirement.

Spike Barrier/cheval needs a clear attacked face and native obstruction behavior, with player entry and all player vaulting blocked. Passive hazards do not gain friendly immunity or remote disarming from controller modes. Barbed barricades must not hurt zombies through the protected side, repair the host on upgrade, survive as an invisible attacker after host destruction, or process one thump repeatedly.

Concertina's damage is contact-only unless the owner later requests lingering damage. Recommend strongest-slow-only composition and a minimum movement floor. Exit, death, despawn, unload, and mod interference must restore appropriate movement. Do not overwrite another mod's entire speed state or permanently change a zombie's configured movement type.

## Balance measures

| Measure | Why it matters |
| --- | --- |
| Effective kills per reload/service | Limits unattended output |
| Damage and delay per resource | Makes renewable and scarce ammo comparable |
| Occupancy/target capacity | Prevents a single tile from controlling a whole wave |
| Player Action Time per service | Measures maintenance burden without pricing everything in scarce loot |
| Structure life under sustained pressure | Checks whether passive defenses become effectively immortal |
| Target survival/advance time | Exposes knockdown and slow loops |
| Shared XP per kill and per event | Confirms faction size does not multiply the pool |
| Score earned at matched difficulty | Tests whether the proposed x0.20 modifier reflects increased survival |
| Tick cost and network traffic at density | Establishes practical device limits |

Proposed numerical starting points retained for experiments only: shared XP 25%; punji crossing damage equivalent to 15-25% of the reference shambler's health as fixed damage; concertina 25-40% movement reduction. Do not expose these as owner-approved defaults. Potato's earlier 6-10-hit target is discarded.

## Required comparison scenarios

Use the same game build, zombie configuration, lane geometry, player participation, and resource budget for controls. Compare no devices, one device, paired potato turrets, concertina plus turret, barriers plus servicing, and the maximum intended device density. Test both an engaged defender and an unattended position while the area remains active.

Capture kills, survivors, time to breach, consumed ammo/materials, service time, crowd-control duration, server cost and score. Compare at least early and developed bases; construction expense alone does not constrain a mature renewable farm.

Potato firing has a one-real-second minimum interval, superseding the earlier in-game-time proposal for that cadence. Decay clocks remain a separate design choice; servicing uses native Action Time. Record actual test clock settings and validate fast-forward without replaying a backlog of shots against today's targets.

The current repair keeps a provisional 70% direct-hit knockdown chance and a three-real-second shared target recovery guard. It requests native animated stumble-and-fall with a modest force away from the turret and logs delayed displacement; global ragdoll settings are preserved. Barrier tuning is 0.20 actual HP per observed native animation strike marker, equivalent to 20 at a x100 damage display scale. Marker scheduling and destruction edge cases remain unaccepted; see the [patch record](checkpoints/P1_RETALIATION_RECORD.md). Module values remain proposals in [Modular turrets](MODULAR_TURRETS.md).

## Deliberately deferred

Live CCTV/remote aim, deep physical pits and climbing animations, general circuit logic, unlimited weapon-mod compatibility, incendiary systems, automatic distraction networks, and combat simulation outside the scoped Cure integration are not promised features. Reconsider only through a specific content decision and a bounded prototype.
