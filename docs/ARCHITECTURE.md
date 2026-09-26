# Architecture and feasibility

Status: P1C1's persistent test shell is implemented; the remaining architecture is proposed. See the [P1C1 record](checkpoints/P1C1_RECORD.md) for its actual authority/lifecycle and [Integrations](INTEGRATIONS.md) for future sibling contracts.

## Responsibility boundaries

| Concern | Authority |
| --- | --- |
| Device definitions, recipes, settings schema | Shared declarations; authoritative server validation |
| Placement, materials, ammunition, condition, power, linking | Server in multiplayer; equivalent authoritative path in single-player |
| Hit approval, damage, wear, target policy, device kill facts | Authoritative device runtime using proven game combat/sync paths |
| Rendering, aiming previews, particles, sound presentation, menus | Client; no independent damage or rewards |
| Horde ownership, quotas, lifecycle, simulation and score | Horde Night |
| Trait XP, levels, Tokens, Prestige, life records and reward receipts | Trait Shop |
| Private Cure state and Cure-specific damage effects | Cure Defense through its current core contract |

Use explicit single-player, multiplayer-client and multiplayer-server branches where behavior differs. Proving a server-side health change alone is insufficient: death, corpse, loot, and other clients' state must agree under actual zombie simulation ownership.

## Components to establish incrementally

Build one device registry and scheduler; one placement/service path; one activation/damage path; one persistence model; one client effects channel. Add the signal network, reward adapter and simulation adapter only in their phases. Prefer small declarative definitions over one script tree per device or a generic plugin framework with no current consumer.

Confirmed P1C1 package ID: `OneMoreHorde_TurretsAndTraps`, runtime namespace `OMHTT_Foundation`. No sibling dependency is declared. Do not claim a dependency on a future API version before it ships.

## Persistence

Proposed durable fields: schema version, device ID/type, precise object marker, coordinates/orientation, owner identity, condition, loaded ammo, charge/power state, armed state, cycle state and persistent link IDs. Validate field ranges and resolve world objects from IDs/coordinates. Do not serialize live Java references or use a sprite name as sole identity.

P1C1 uses compact server-only global ModData (`OMHTT_Foundation_v1`) and request/reply commands, alongside the engine-saved IsoObject. There is no global ModData receive/store listener. A bounded test ledger retains per-tile epochs after removal so stale placement requests cannot resurrect a device. Reconciliation uses an indexed tile lookup on LoadGridsquare; it never recreates a missing object automatically. Object names and namespaced identity markers must both match before mutation/removal. This test-only schema is not a commitment to final faction ownership or device scheduling. Do not place authoritative balances in player modData that ordinary client synchronization can overwrite.

Load/unload keeps durable data but removes stale live references. Re-entry reconciles the exact object before reactivation. Native barricade upgrades must bind to the correct host and disappear logically when the host is gone. Migrating, dismantling, ownership transfer and replacing an object must never duplicate ammo or reset condition.

World defenses belong to the survival world unless explicitly designated otherwise. Horde end, reset or faction disband must not silently delete every owned structure through generic OMH object retirement. Verify the actual runtime retirement rules before using persistent-object registration; if those rules conflict, keep device persistence outside the run-owned registry and declare only the required integration capabilities.

## Network behavior

Use verified timed-action completion or validated named commands for mutations. Validate player identity, distance, permission, inventory, target identity, enabled content, and expected revision/state on the server. Construction and ammo transactions need duplicate protection and material consumption exactly once. Clients cannot submit kill counts, reward recipients, damage amounts or score modifiers as trusted facts.

Broadcast compact state changes and effect facts. A shot/impact identity prevents duplicate visual/audio playback on retried messages; effects never award damage. Do not broadcast whole registries on every shot, and do not make every client independently scan and apply traps.

Input occupancy and line obstruction are authoritative. Held-state changes trigger recomputation; devices still follow their own cadence. Revalidate state before each legal activation, including power/ammo and disabled settings.

Explicit device capabilities determine whether controller targeting applies. Passive hazards ignore it even if owned by the same faction or near a controller. Implement bed-spike jumping through a verified movement/animation path, not coordinate teleportation or damage immunity disguised as traversal. Spike Barrier collision must reject player entry and both automatic/manual vault attempts. This behavior needs dedicated observer checks, not only server-side object persistence.

## Scheduling and performance

Index active devices spatially; use bounded nearby candidates and stagger target/sensor checks. Do not scan all world objects or all zombies once per turret per frame. Budgets must include maximum devices, scan candidates, rays, splash victims and messages. The exact limits come from P1/P2 measurements, not invented performance promises.

Batch persistent XP/share updates by safe accounting boundaries without losing individual death deduplication. Compact settled receipts only after a replay-safe boundary is established. Do not build one unbounded saved table entry per historical potato forever.

Sleep, fast-forward, pause and large time deltas must preserve resources and stop unlimited backlog activation. Never replay past shots against whatever is currently in range. Evaluate continuous resource decay separately from discrete combat opportunities; the final simulation owns any approved virtual combat.

## Technical risk register

| Risk | Evidence or concern | Proof needed |
| --- | --- | --- |
| Per-thump retaliation | Historical Java thump paths are not a verified universal Lua event | Current build hook/observation, exact attacker/side, single hit under MP batching |
| Autonomous damage/death | Zombie simulation ownership and death transport differ by mode | One-player dedicated then two-observer death/corpse/reward consistency |
| Movement slowing | Other mods may own movement settings; network simulation may overwrite local state | Enter/exit, owner change, sprinters, unload and restoration |
| Player traversal | Automatic bed-spike jumping and solid non-vaultable barriers are design requirements, not yet proven APIs | Current movement/animation evidence, facings/corners/footprints, blocked landing and interrupted jumps, multiple-player synchronization |
| Beam linkage | Native proximity/remote traps are not an existing general wiring system | Occlusion, occupancy, disconnect, persistence and bounded checks |
| Offline faction XP | Existing reward API describes credited participants, not all-member banked shares | Stable membership/life snapshots and exactly-once delivery |
| Official score modifier | Addon registration alone cannot set an approved multiplier | Coordinated core classification, export, UI and leaderboard validation |
| Unloaded Cure defense | Existing API forbids addons editing virtual quotas or claiming kills | New core-owned contract plus conservative outcome comparisons |

## Source map and limitations

- [Horde Extension API](../../pz-mod-onemorehorde_protectthecure/docs/EXTENSION_API.md): current local contract; historical paragraphs may describe older phases, so verify runtime before implementation.
- [Trait Shop integration policy](../../Trait%20Shop/docs/OMH_INTEGRATION.md): score composition, life/event authority and existing completion eligibility.
- [Trait Shop rewards](../../Trait%20Shop/Contents/mods/OneMoreHorde_TraitShop/42.20/media/lua/server/OMHTS_Rewards.lua): existing credited-kill receipts and live reward behavior, not the new defense bank.
- [Historical IsoTrap](../../../references/ProjectZomboid-42.20.2-decompiled/source/zombie/iso/objects/IsoTrap.java), [IsoBarricade](../../../references/ProjectZomboid-42.20.2-decompiled/source/zombie/iso/objects/IsoBarricade.java), [IsoThumpable](../../../references/ProjectZomboid-42.20.2-decompiled/source/zombie/iso/objects/IsoThumpable.java): B42.20.2 discovery references, not a current-build support declaration.
- [Official IsoTrap reference](https://projectzomboid.com/modding/zombie/iso/objects/IsoTrap.html): native trap concepts; presence in Java documentation does not prove Lua exposure or current multiplayer safety.

At the first engine checkpoint, record the installed build, vanilla call sites, exposed methods and actual results. Do not promote a historical method or imagined hook into implementation solely because it would make the plan convenient.
