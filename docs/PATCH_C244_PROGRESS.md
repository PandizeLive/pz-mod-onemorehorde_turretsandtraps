# C244 — zombie combat transport and multiplayer barriers

**C245 evidence correction:** the C244 native Barrier construction fixture logged missing-chunk exceptions despite reaching its completion marker. The marker did not establish clean callback execution. [C245 fixes the fixture, strengthens failure detection and reruns](PATCH_C245_PROGRESS.md#correction-to-the-c244-evidence). Original logs remain unchanged.

2026-10-14. The owner explicitly requests continuing zombie synchronization and all remaining approved multiplayer implementation without waiting for a player test, and pushing progress. C235/C240 authorization remains active; no new generic approval or owner-test gate is introduced.

## Implemented

- An internal owner-directed zombie damage protocol: server-selected victim, amount and provenance; authenticated owner/connection; Prepare/Ready/Commit/Applied receipts; relative subtraction from the owner's current health; bounded pending work and timeouts. Repeated commits/acknowledgements cannot apply twice. A fresh client receipt prevents an old Prepare/Commit pair from damaging a recycled online-ID/outfit identity. Invalid values, foreign senders, invulnerable targets and replaced connections are rejected.
- Terminal results remain reserved at nonzero native health until the server performs death with Horde finishing context. The reserve respects ZombiePacket's thousandth-health quantization. Ownerless server damage uses the same request facade and actual native death event without fabricated player attacks/XP.
- Production Spike Barrier crafting/deployment callbacks, collision-outline creation, client placement/selection and pickup/repair/reinforcement actions now have multiplayer paths. Clients read detached geometry; the private server ledger validates builds and services. Native service durations are five/ten seconds; server completion does not depend on client elapsed/start fields. Concurrent pickup yields one item, and failed insertion leaves the pair intact.
- Server-created collision edges and changed sprites are transmitted. Edge ownership/removal/health enumeration use native position/name and private desired geometry; public marker changes cannot redirect ownership or make reconciliation delete unrelated objects. Genuine orphaned native edges are still removed.
- Client preview neighbor discovery is limited to 49 nearby squares and cached for 100 ms. Combat tracks only observed actors, bounds pending transactions to 128 and timeout inspection to 16 per tick; no map-wide scan or catch-up burst is added.

**The remote-owned combat protocol is experimental and is not connected to production firing/trap damage yet.** Existing synchronous combat guards remain. This checkpoint does not establish reliable connected multiplayer combat merely because its receipt fixtures pass.

## Verification

- Full stock-JAR-first validator: **20,141 assertions**, **142 Lua/translation compilations**, **808 loaded translation keys**, **238 source / 290 packaged files** (111 Traps, 179 Turrets). Package ownership/dependencies, no-pcall/xpcall checks and existing SP regressions pass. Evidence: `diagnostics/c244-multiplayer/validation-console.log`, `validation.log`, `manifest.json`.
- Receipt tests cover an ordinary player hit between preparation and commit, duplicate packets, actor reuse, reconnect, disconnect, queue saturation/timeouts and the deliberately unresolved post-apply ownership handoff. Tests use separate replica doubles and native serialized payloads; they are not connected-client evidence.
- Barrier client/server preview acceptance agrees across 100 candidate placements/orientations. Client menus do not require server-only modules; clients cannot complete service mutations. Tests cover simultaneous pickup, failed inventory insertion, both-part repair, forged collider metadata and orphan cleanup.
- Stock Build 42.21 dedicated-server probe: real native zombie health, invulnerability, one terminal death event and nonzero float sentinel; real barrier service completion and production construction callback producing two parts/four colliders; existing native turret feed/power/inventory and Bed/Concertina services. Evidence: `diagnostics/c244-multiplayer/combined-server/server.log`, `native-console.log`.
- The native probe connects **zero clients** and uses synthetic squares with a test-only square lookup. It does not prove mapped-world removal, remote previews, action delivery, ownership handoff or corpse propagation. The first added construction fixture omitted native SpriteConfig setup and failed; the fixture now creates the entity component like the native builder. Stock world-generation warnings remain in the logs. No clean-log or owner-acceptance claim.

## Still implementation work

1. Native ownership changes after an owner applies damage but before server acknowledgement remain ambiguous. The prototype reports uncertainty and does not blindly replay; a hit may be lost. Stale native health packets, concurrent lethal player hits, disconnect/reassignment and asynchronous Horde consent/run changes still require a reliable transport contract and connected-engine proof. The owner test is not the blocker.
2. Connect production turret automation/projectiles/procs and trap contacts to that completed transport; synchronize movement, trips, player injuries and observer audio/effects. Barrier retaliation/vault injury remain gated. Barbed Panel support authority is unfinished. MP Building's custom craft-first consolidation remains separate from the enabled inventory/native placement route.
3. Complete physical/virtual feed and playable Void content, native/third-party inventory endpoints and persistence/pruning checks. Retain the approved Lobber/Scrapshot/Lure/ammo-family work from C235.
4. Complete Horde receiving-run consent and durable asynchronous attribution/capability/settings certification. One /5 factor, default-or-harder eligibility and neutral ordinary collision are unchanged. The complete authority capability remains unadvertised; R1C3/R5C1/R5C2 are not accepted.

## Delivery

Development source and generated packages are mirrored through the existing draft PR. Installed 0.2.49 and its immutable test tag are unchanged. No installation, release/version promotion, merge, website deployment or Workshop upload. Existing cumulative Workshop notes are preserved; incomplete MP work is not advertised there as a completed feature.

**Wait for a patch.** This is additional verified implementation, not a multiplayer-complete release or a request for another approval.
