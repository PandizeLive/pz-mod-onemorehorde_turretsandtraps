# C236 multiplayer verification (2026-10-14)

**Current follow-up:** [C241](PATCH_C241_PROGRESS.md) implements production server turret state, placement and service actions. The table below is the historical C236 audit; its pack/lifecycle rows are superseded by C240/C241. Inventory, combat and trap authority remain unfinished.

**Result: production gameplay is not multiplayer-compatible.** This is an existing supported-mode restriction, not a newly observed networking regression. The owner requested verification and explicitly deferred player testing. No multiplayer port, live server session, owner test, release or installation is claimed by this audit.

## Verified restrictions

| Area | Current evidence | Result |
| --- | --- | --- |
| Turret construction and inventory | `Turret.recipeInput`, `OMHTT_TurretMenuAvailable`, `Turret.accept`; `TurretInstall.lua` | Disabled on both MP client and server |
| Turret management and transfers | `TurretManage.lua`, `TurretTransfers.lua`, `TurretMagazineAction.lua` | SP-only file guards; no production network action route |
| Combat and automation | `TurretWorld.valid`, `PrototypeCombat.fire`, `TurretAutomation.lua`, `TurretVolley.lua`, `TurretProc.lua`, `TurretRotary.lua` | SP-only; combat explicitly returns `MPCombatDeferred` |
| Packs and new storage helpers | `TurretModulePack.open/onDeath`, `TurretPackAction.lua`, `TurretVoid.deposit/spend/consume` | MP mutations rejected; no server reward/conversion service |
| Bed Spikes | `BedSpikes.enabled`, `BedRuntime.lua`, `BedService.lua`, `BedPlayer.lua` | SP-only contact, placement and service |
| Barbed Panel and Concertina | `BarbSections.enabled`, `BarbRuntime.lua`, `BarbSupport.bind` | SP-only attachment and contact |
| Spike Barriers | `BarrierMenu.lua`, `BarrierPlacement.lua`, `BarrierService.canService`, `BarrierRetaliation.observe`, `BarrierVault.lua` | Production placement/service/contact still have MP gates |
| Earlier foundation prototype | `FoundationServer.onCommand`, `Foundation.canUse` | Existing debug command transport with capability, version, distance, epoch and revision checks; this is not the production turret protocol |

`triggerEvent("OnServerCommand", ...)` in the SP combat paths is a local event dispatch. Its name does not make it a network broadcast. The current generated mod descriptions also explicitly identify both entries as single-player content.

## Checks performed

- Reviewed the installed Build 42.21 `ISAddFuelAction:complete()` pattern: authoritative inventory mutation, server synchronization and coordinate-based campfire resolution. Reviewed the Build 42 multiplayer skill's timed-action argument serialization and whole-table ModData replacement rules.
- Added `tools/tests/multiplayer_audit.lua` to the Kahlua runner. It runs both client/server modes and confirms production gates, explicit combat rejection and no pack consumption. `turret_void.lua` independently confirms both modes cannot convert/spend or initialize Void state. These are negative safety checks with world/network doubles, not functioning multiplayer tests.
- Full stock-JAR-first validation passes **18,229 assertions**, **122 runtime/translation compilations**, native animation/pitch/model checks and package parity/dependency checks. Existing prototype packet serialization covers23 packets, largest390 bytes; it does not cover new production combat or Void payloads.
- Evidence: [development validation log](../diagnostics/c236-dev/validation.log), [manifest](../diagnostics/c236-dev/manifest.json). Installed0.2.49, immutable `test/v0.2.49` and its original evidence remain unchanged.

| Environment | This audit | Acceptance |
| --- | --- | --- |
| Single-player | Automated regression checks and native table serialization | New rendered behavior remains untested |
| Dedicated server | Simulated runtime-side guards; current source review | Production gameplay blocked; no live acceptance |
| Listen-server host | Same client/server restrictions apply | No live acceptance |
| Two clients / reconnect | No runtime session | Pending a production MP implementation |

## Required before an MP claim

Keep the guards until a deliberate port supplies server-owned deployment/service, exact-item inventory and Void conversion, authoritative ammo/power/damage, bounded replicated effect facts and client-only UI/render/audio. Register server-executed timed actions in a server-loadable location; reconstruct their arguments and revalidate reach, identity, ownership and current state. Existing `elapsed` fields updated only in client actions cannot simply be trusted on a rebuilt server action.

Void requires exact-module item identity, server-owned counts/debt and safe removal/reload transactions. Do not synchronize partial ModData tables or store live object references in replicated payloads. Do not remove guards and rely on the existing SP native transfer override. Define zombie-ownership and player-injury authority before enabling effects.

Then verify simultaneous service requests, duplicate commands, disconnects, reconnects, restart persistence, moving modules between turrets, zombie ownership changes and two-observer effects on dedicated and listen servers. Keep the owner test deferred until that path exists. C237 corrects the earlier implication that this established project requirement needed fresh generic scope approval.

## C237 - Original multiplayer requirement and continuation (2026-10-14)

Owner: "Okay, we knew this was for multiplayer from the beginning. Why have we stopped? What's needed."

Multiplayer was an original delivery requirement: P1C1 requires authoritative lifecycle and dedicated-server agreement; ROADMAP R5C1 requires server-owned combat, service and inventory. The roadmap explicitly says authority design begins with each device, not at final certification. SP-first prototypes and later integrated MP acceptance were documented, but accumulated SP-only production paths are unfinished engineering, not an unforeseen external blocker. C236's premature handoff and implication that MP was new scope were incorrect. Deferred owner testing does not prevent implementation or automated/native verification. The combined content patch remains approved and unfinished.

Recommended implementation order within the existing R1C3/R5C1 scope:

1. Establish one production turret lifecycle: server-validated placement, exact-item loading, firing and pickup. Reuse shared rules and stable identity; do not promote debug-only permissions to production authorization.
2. Move service, module installation, magazine switching, pack rewards and Void conversion to repeat-safe authoritative transactions. Revalidate reach, item identity, current state and revision; concurrent clients must not duplicate or lose resources.
3. Establish zombie-ownership-aware damage/death and player-injury handling, then integrate approved heads, projectiles, secondary effects and trap contacts through that path. Prevent double damage/rewards across observers.
4. Replicate bounded state/effect changes to clients for Manage, animation, audio and late join. UI stays client-only; clients request actions rather than dictate outcomes.
5. Preserve inventories, module-owned Void counts/debt, device identity and timers across pickup, disconnect, area reload and restart. Share global work/network budgets and retain independent turret/trap packages.
6. Run native and automated authority, replay, concurrency, persistence and load checks during development. Dedicated/listen-server sessions with two observers remain required before an MP compatibility claim; owner participation stays deferred.

Start with the common authority/transaction path before completing new ammo integrations, avoiding another SP-only implementation to port later. This is the engineering recommendation, not a claim that the port is complete or that a live engine limitation has been solved. No new gameplay balance choice is required by the identified gaps. Optional sibling integrations and publication remain separately scoped.
