# Gameplay design

Status: draft specification. Read [Decisions](DECISIONS.md) for which requirements are confirmed. The target is Build 42; source-level feasibility must be checked against the installed build at implementation time.

## Product and play loop

One edition, one maintained implementation, individual Sandbox feature toggles. The player prepares a defensive position, shapes approaches, supplies devices, fights alongside them, and repairs/rearms between attacks. Cheap renewable ammunition is balanced through operating cadence, capacity, wear, and access to maintenance.

Recommended progression is hand-built obstructions and the potato turret, followed by connected mechanical devices, then powered targeting and specialized ammunition. This is an implementation/content order, not separate editions or a final recipe tree.

The core should be playable without Horde Night, Trait Shop, or Cure Defense. Each optional adapter must establish its dependencies and disable unsupported integration features clearly.

## Roles

| Role | Content |
| --- | --- |
| Block an approach | Spike Barrier (cheval de frise); existing barricade with barbs |
| Punish crossing | Bed spikes (punji); Poke Floor |
| Extend exposure | Concertina |
| Deliver intermittent impact | Potato turret |
| Control activation | Button, pressure plate, beam sensor, toggle switch |
| Fire along a prepared lane | Dart emitter; later firearm sentry |
| Coordinate equipment | Control unit with individual/all-linked targeting and connection highlighting |

Placement, sprite collision, facing, and line of fire must agree. A device cannot damage through an intact obstruction merely because a target is in range. Ground traps and obstruction upgrades must not introduce invisible pathing barriers.

## Passive hazards and player traversal

Owner-confirmed: objects without smarts ignore target filters. Passive stakes, wire, Spike Barriers and barbed barricades do not recognize factions or become harmless because the control unit selects No one. Their own physical behavior and any separately defined server rules still apply.

Bed spikes is the working term for the passive punji/stake bed, not the retractable Poke Floor. Players automatically jump over the bed when crossing it. This applies to all players without owner/faction discrimination; it does not imply that zombies gain the same traversal behavior or that players can walk through the spikes unharmed.

Prove a visible, synchronized jump against the installed game's movement and collision system at the start of P2C2. Test approach directions, intended footprint, walk/run/sprint input, movement commands, obstruction at the landing, interruptions and observer synchronization. Recommended fallback when a valid jump cannot complete: stop before the hazard; do not teleport, walk through it or invent faction immunity. Exact injury/interruption behavior remains to be specified from that prototype.

Spike Barrier is the working term for the freestanding cheval de frise. It is solid to players: no walking into/through its occupied footprint, automatic vaulting, or manual vaulting. Check every supported facing and joined corner. Zombie obstruction/thumping remains the planned defense behavior; do not solve player blocking by creating an indestructible zombie wall.

## Signal model

Owner-confirmed sources:

| Source | Output |
| --- | --- |
| Button | Pulse |
| Pressure plate | ON while occupied; OFF when clear |
| Laser/beam sensor | ON while blocked; OFF when clear |

Proposed toggle switch: stays ON until switched OFF. It is optional content, not an owner-confirmed input requirement.

Each receiving device owns its cadence and state. Recommended behavior: a pulse requests one legal activation; sustained ON permits repeated cycles at the normal rate. No repeat commands are needed every frame. OFF blocks new activations; a Poke Floor already moving completes safe retraction. New pulses do not stack an unlimited firing queue while a device is busy.

For multiple inputs, start with OR semantics: any held ON enables operation, and pulses request a cycle. No general logic gates, feedback circuits, programmable scripts, or combinatorial circuit simulator in the initial system. Confirm this limit at P4C1.

Proposed connection UX: select source, click target, see highlighted valid connections and rejection reasons. Start with short same-floor links, a bounded output count, a harmless test pulse, and no permanent line clutter outside setup mode. Preserve links by device identity, not transient object pointers.

On save/reload or area activation, recompute held signals from actual occupancy/obstruction. Do not replay old pulses. Power loss disarms powered outputs; restore according to current signal after validation. Whether a startup safety delay is desirable remains a tuning question.

## Poke Floor

One retractable spike device. Proposed states: retracted, extending, extended, retracting, resetting. The strike window determines damage; a held input permits subsequent completed cycles, not an indefinitely damaging extended state. Exact strike window, target count, and player-crossing safety require tests and policy decisions.

## Potato impact

Confirmed: potatoes pop when they impact zombies, with tiny real splash damage and satisfying feedback. It is not a conventional explosive: no fire, blast impulse, or structural damage is implied.

Recommended: one primary direct hit, a short visible potato splat/pop, appropriate impact audio, and nearby chip damage with a total budget and target cap. Exclude the primary target from secondary damage, never apply secondary knockdown, and respect blocking geometry. Damage and death still use the common authoritative pipeline, including rare finishing blows from splash.

The visual can be more noticeable than the damage. Keep debris temporary and bounded; do not create a persistent inventory item or world object for every potato fragment. Quiet describes the intended small sound footprint, not perfect silence.

## Construction and servicing

Recipes, skills, tool requirements, power sources, ammo conversion, and spoilage policy are TBD. Recommend ordinary material families: wood/metal/wire/electronics, with distinct manual work or capacity costs.

Barbed barricades retain their host's current health on upgrade. No free repairs or duplicate structural HP. A separate wire-condition concept is proposed, not approved. Punji placement in a grave versus a distinct stake bed remains Q06.

Servicing must be possible through a concise context flow: inspect status, load/unload, arm/disarm, repair/rearm, connect/disconnect where supported, and dismantle. Show empty, worn, disabled, unpowered, and obstructed states. Do not refill, reset wear, or award materials by picking up/replacing an object.

## Ownership and danger

Persist solo/faction ownership separately from the current operator. A device's owner can identify the XP recipient faction wherever the device is placed; a geographic base boundary is not a technical prerequisite. Assignment, transfers, disbanding, solo ownership and outsider access remain decisions. Do not infer permanent ownership from whoever is nearest when a trap kills.

Owner-confirmed: a control unit allows targeting changes for an individual compatible smart defense or all compatible linked defenses, including players, other factions, or no one. It manages its authorized linked devices, not every defense in the world. Passive objects are excluded. It is planned content, not merely an optional convenience idea.

Recommended UI: preserve zombie targeting and explicitly distinguish player target groups; define No one as no eligible targets/disarmed operation rather than only 'no players'. Exact combinations/defaults, unfactioned players, faction allies, operator/self treatment and faction-reference ownership remain Q04. The server must validate who may change a device and apply effective target eligibility at the actual activation/damage boundary, not only in the menu or at initial acquisition.

Passive contact hazards do not follow target filters; this is settled by the owner. A device needs an explicit target-recognition capability to participate. A simple mechanical trigger or a connected wire alone does not grant that capability. Specify how controlled Poke Floors/dart emitters acquire it before enabling selective targeting for them. Targeting a zombie does not by itself settle whether its splash may hurt a nearby player; collateral and server PvP/safehouse behavior remain separate decisions.

A beam sensor's electrical ON state still describes obstruction, not friend-or-enemy identity. Eligibility belongs to the controlled device/damage policy. Disabled targeting does not remove a barrier's native collision.

## Simulation boundaries

Early versions operate on active loaded combat. Offline faction members can earn their share of real kills through the reward integration without their own client being online. No damage or reward accrues merely because time passes in an unloaded area or while the server is stopped.

Cure defense simulation is reserved for the final phase. Until then, Cure's existing simulation continues without defense credit. The UI/release notes must state this limitation; defense items remain persisted rather than being deleted when their benefits cannot be simulated.
