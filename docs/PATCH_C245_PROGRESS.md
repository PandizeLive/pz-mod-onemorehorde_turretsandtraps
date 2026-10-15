# C245 — ownership handoff recovery and remaining multiplayer implementation

Owner authorization: continue combat ownership handoff and all remaining MP work, without another approval or owner-test gate; push progress to GitHub. This checkpoint changes development source, not installed 0.2.49.

## Implemented

- Combat preparation can move to a new native owner with a fresh sequence and receipt. A commit already sent to the previous owner is queried rather than blindly retried. An unapplied receipt revokes the old commit before it can be offered to the next owner.
- A valid applied receipt remains usable after ownership changes. The next owner receives a nonce-bound reconciliation instead of another damage subtraction. Lower health on the next owner is preserved; duplicate replies/reconciliation cannot complete the operation twice. The original deadline and bounded queue remain in force.
- Barbed Panel native placement and server-completed repair/removal are enabled in MP. A private persistent panel ledger, exact native frame names and live support bindings replace client-writable durability/identity as authority. Detached host/frame views support client menus. All four placement directions retain existing behavior.
- Window panels retain their own 50 HP without adding glass HP; open/smashed windows remain valid. Finite supports retain native shared-health semantics. Server door-following sprite changes are broadcast. Support removal queues bounded retirement outside the native removal callback; removal grants no item or XP.
- Panel reload restores private records and republishes views; overwritten public markers cannot change authority. Spike Barrier services also resolve canonical native names/private ledger geometry when public markers are replaced.
- Dedicated servers register module/container-pack loot using the same configured weights and idempotent distribution merge as SP. Disabled turret loot remains disabled; unrelated loot entries are preserved.
- The native service harness now rejects mod callback exceptions even when later completion markers exist. Synthetic squares receive actual native chunk ownership and load IDs.

## Verification

- Full stock-class validation: **20,216 assertions**, **142 Lua/translation compilations**, **808 native translation keys**, **238 source / 290 packaged files** (111 Traps / 179 Turrets). Evidence: `diagnostics/c245-multiplayer/validation-console.log`, `validation.log`, `manifest.json`.
- Separate replica fixtures and native serialized payloads cover stable-owner intervening player hits, applied and unapplied handoffs, duplicate replies, delayed old commits, recycled identities, changed connections, queue limits and expiry. These are not connected-peer evidence.
- Panel fixtures cover four directions, public metadata replacement, registry reload, independent broken-window health, repeat-safe server actions, support removal and retirement. Barrier service fixtures now include overwritten visual/collider markers. Loot fixtures cover server registration, duplicate merges and disablement.
- Stock 42.21 dedicated-server probe passes native production panel construction/repair/removal and registry reload, unchanged window HP, native Barrier construction/services, turret/feed/inventory services, Bed/Concertina services and ownerless zombie damage. Module loot is registered once during actual native server startup. Evidence: `diagnostics/c245-multiplayer/combined-server/server.log`, `native-console.log`.
- That server connects **zero clients**. Its fixture squares have native chunks but are not registered mapped-world squares. Remote menus, action delivery, packet ordering, native ownership switching, corpse transport and mapped removal are not established by it. Stock WorldGen warnings remain; no blanket clean-log claim.
- The broader stock native regression suite passes both **write (67.3 seconds)** and **read/restart (70.8 seconds)**: native object/item serialization, firearms/ammo, traps, module packs, recipes, collision/visibility, accuracy and audio registrations. Evidence: `diagnostics/c245-multiplayer/persistence/server-write.log`, `server-read.log`, and the corresponding console logs. These include SP-emulated checks and server fixtures, not connected MP acceptance. The first attempt exposed a probe's fixed directory-depth assumption; source lookup now locates the actual project ancestor. That failed run remains in `failed-persistence-output-depth.log`.

### Correction to the C244 evidence

C245 review found that the C244 native service log contained missing-fixture-chunk exceptions in Barrier outline creation despite reaching its completion marker. The old harness did not reject this combination. C244's marker-only construction success must not be treated as clean callback execution. C245 fixes the fixture and the harness and reruns successfully. Initial C245 failures are retained in `failed-fixture-no-chunks.log` and `failed-fixture-chunk-loadid.log`; they are failed evidence, not passes. Production code does not suppress those exceptions or add exception-catching wrappers.

## Still unfinished — no owner approval/test prerequisite

1. **Combat transport remains experimental and disconnected from production firing/contact paths.** Ordinary handoff recovery is implemented, but if the previous owner disconnects or its native instance is recycled after applying damage and before a receipt can be recovered, the outcome remains uncertain. No replay occurs. Stale native health packets after completion, simultaneous native deaths and consent/run changes during an outstanding operation still require a completed transport/attribution contract. A simple server health ceiling was considered and rejected because it can lose concurrent ordinary player damage; it was not shipped.
2. Connect production automation/projectiles/procs and trap contacts only to that completed contract, with native owner movement/trips, player injury and observer presentation. The current prototype is not evidence that these guards may be removed safely. Full Horde capability remains unadvertised; no ranked MP certification.
3. Finish MP custom Building craft-first consolidation, remaining inventory endpoints and physical/virtual feed integration; retain the approved C235 Lobber/Scrapshot/Lure/ammo/Void scope. Panel lifecycle is no longer in this unfinished list; active panel damage/slowdown is.
4. Complete restart/pruning and connected-engine coverage, and the full Horde default-or-harder configuration audit. Keep the selected /5 factor, receiving-run opt-in and neutral ordinary collision.

## Delivery

Existing development branch/draft PR route; no merge, release/tag movement, install, website deployment or Workshop upload. Preserve the cumulative Workshop draft and 0.2.49 installed/test-tag baseline. No generic approval question or owner test is requested.

**Wait for a patch.** This is verified development progress, not a claim that all multiplayer work or combat ownership failure cases are finished.
