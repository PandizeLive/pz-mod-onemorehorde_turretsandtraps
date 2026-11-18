# C241 production multiplayer lifecycle — unfinished combined patch

Follow-up: [C242 inventory, Manage and magazine implementation](PATCH_C242_PROGRESS.md). The open-work list below is the historical C241 checkpoint.

2026-10-14. Owner: “You need to ensure that we're caught up on Multiplayer implementation. You're approved to complete as much as possible.” Continues C235/C240, including the settled Horde /5, receiving-run opt-in, default-or-harder audit and neutral ordinary collision. No new balance decision is needed for this checkpoint.

## Implemented

- Production turret placement callbacks now run on the server. Shared placement validation is available to the client cursor and native server build action. The exact consumed base supplies the actual contents; client-written packed controls are not imported as authority.
- A server-only Global ModData store owns placed/packed turret controls. Public object/item modData is a detached presentation snapshot. Native tile reload rebinds the trusted record by location, even if a public marker was erased. Fully loaded empty tiles retire stale records without granting items. Duplicate live bindings and consumed-item callbacks are rejected.
- Pickup and repair are globally registered native timed actions with explicit serialized device identity. Server completion validates identity, operation, health and reach. Client completion cannot grant anything, and reconstructed server actions do not depend on the client's elapsed timer. MP pickup/repair use native five/ten-second durations; existing SP real-time behavior is retained.
- Pickup checks room and actual inventory insertion before moving contents, retires authority before native world removal, and synchronizes the resulting packed item once. The removal callback cannot also grant salvage. Repair synchronizes native thumpable health and the public state snapshot.
- Native destruction and ordinary removal share the same retirement/salvage routine. The first callback retires the record; a second cannot duplicate scrap or contents. Native destruction may dump the contents before the event, so only items still present are handled by the fallback.
- Multiplayer Install and pickup/repair menu routes are available in development source. They do **not** constitute a functional multiplayer combat release: Manage/inventory transfer, firing, automation and most trap paths remain gated until their authority port is complete.
- No new tick handler or world scan. Live state and tile lookup are indexed; initial persisted-index reconstruction occurs once. State snapshots are sent on mutations, not every frame. No `pcall`/`xpcall` added.

## Evidence

- Full automated validator: **18,298 assertions**, 128 Lua/translation compilations, 808 loaded translation keys, native packet/animation/pitch/model checks and independent-package verification; 227 source / 276 packaged files. Isolated-harness GUID-table and JOML warnings remain; no assertion failed.
- Isolated Kahlua regression suite: 18,216 assertions without optional pack/UI audit. Includes 36 additional checks for authoritative state, erased/replaced metadata, native table persistence, reload binding, stale/unknown service operations, concurrent completion, client denial, no-room/failed-add handling and exact contents.
- Stock Build 42.21 **dedicated server, no clients connected**: the standalone production callback/service probe passes native placement setup, health repair, exact-content pickup, trusted redeployment, destruction salvage and replay rejection. Actual native battery identity and charge survive. These are real native objects on synthetic tiles; the test does **not** establish coordinate-resolved map removal, remote build/action packets, connected-client replication, two-client contention or a listen server.
- Native evidence: installed `ISBuildIsoEntity:create` performs server recipe consumption and invokes the creation callback before `transmitCompleteItemToClients`. `IsoObject:sync` uses native `SyncIsoObject`; `IsoThumpable:syncIsoObjectSend` includes health. This is distinct from the ineffective zombie `syncHealth` discussed in C240.
- Reproducers: `tools/tests/turret_authority.lua`, `tools/tests/native_turret_authority.lua`, `tools/smoke_turret_authority.py`. Local evidence stays under `diagnostics/c241-multiplayer/`; installed 0.2.49 diagnostics are preserved.
- The broader legacy server probe initially exposed an obsolete fixture expecting client-chosen Module Pack rewards, an overfilled reused test player's pickup refusal, and persisted records from failed synthetic-tile runs. The fixture now validates server-selected registered rewards, uses a fresh player, and invokes the normal tile-load reconciliation. A subsequent destruction check exposed the synthetic-tile limitation: native map removal resolves the real server map by coordinates, so removing an unregistered tile object is not a valid test of that route. Native `destroy()`/destruction-event and retirement tests pass; real map removal remains unverified.
- Final broader stock-server startup/save/shutdown and native persistence smoke: **passed in 157.6 seconds**, write mode, both independent packages loaded, no player connected. Most legacy combat probes deliberately execute SP adapters in the server harness; they do not certify multiplayer combat. The stock install emitted existing map/asset warnings; no T&T assertion failed in the successful rerun.

## What is still open

1. Production Manage controls, bounded native inventory transfers, magazine/module changes and Void conversion, including server-owned head/feed/storage state and client refreshes.
2. Remote-owned zombie damage/death, movement/trips and player injury transport. Native owner packets can overwrite server-only health changes; no naive `setHealth + syncHealth` workaround is enabled.
3. Port automation, projectile/proc effects and trap placement/services/contact through those routes; replicate bounded visuals/audio and preserve head compatibility.
4. Complete Horde attraction isolation, durable character/world provenance and the settings/capability audit. C240's core/website work remains local to those siblings as documented there; nothing was deployed or mirrored from those projects this turn.
5. Complete retained C235 head/ammo/Void content, coordinated candidate packaging, connected dedicated/listen-server checks and the deferred owner test.

R1C3 and R5C1 remain in progress; the R5C2 scoring subset remains implemented but not accepted. `OMHTT_DefenseAuthority` stays unadvertised. No new mod version, install, test tag, Workshop publication or full MP compatibility claim. **Wait for a patch.**
