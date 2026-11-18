# C508 - Multiplayer contact and damage path replacement

2026-10-29. Owner explicitly approves underlying multiplayer repair and requires proof before another packaged patch. This is an **unpackaged source candidate**, not multiplayer acceptance or a new release. Installed/staged/tagged 0.2.70.7 remains unchanged.

## What changed

- The native zombie-owning connection reports nearby contact, exit, stance and landing. The server validates connection ownership, identity, incarnation, floor, position, freshness, sequence and existing geometry/cooldowns. Reports cannot choose damage, targets outside their native ownership, loot or XP.
- Owned zombies no longer generate Bed/Wire/Tack/Poke contact from delayed server replicas. Ownerless zombies and players retain their existing paths. The shared server index remains responsible for other detection work.
- Bed's custom trip emits an owner-visible landing variable at the existing 50% ground-contact marker. The owner reports it immediately instead of waiting for the server to infer a different native state. The marker resets before each trip.
- CombatV2 replaces Prepare/Ready/Commit/Applied with Apply/Applied. Server authorization happens before dispatch; native server death, Horde attribution and XP remain after confirmed damage. Duplicate suppression, a cancellation barrier during ownership handoff, absolute-health reconciliation and expiry remain explicit.
- Native grapple-only corpse representations fail the shared living-target check before contact, motion, damage and consent. Genuine living zombies remain eligible.
- Native synchronized timestamps reject delayed commands and reports from before recycled actor creation. Contact reports have a 500ms freshness limit; queued contact damage also expires after 500ms instead of remaining in the general five-second queue. A legitimate earlier crossing can still become visible after network transit; this does not promise zero-delay damage or cancel legitimate hits merely because the zombie has stepped away.
- Poke reports evaluate only the reported actor. They do not rescan every zombie sharing its tile or invalidate player traversal history. Per-trap strike protection and adjacent-trap independence remain unchanged.
- Reporting uses existing nearby indexes, a bounded FIFO, 32-frame packets and bounded per-tick/per-connection work. Discovery keeps its existing 64-state-read budget. Queue delay, contact transit age, stale/rate-limited reports and owner processing/position are included in existing diagnostics.

The native client simulator assigns its primary local player when taking zombie ownership. Server validation therefore checks the authenticated sender's native owning **connection**, allowing split-screen players on that connection; it does not grant another connection permission.

## Evidence

The baseline is immutable source commit `00970de538bf6ad8f14520232ed4ea9297b11043`. Run `tools/check_combat_path.py --full --compare` with the installed game and JDK. The tool reads baseline files from Git, compiles current source, runs native Kahlua and native serialization, and writes only diagnostics. It does not regenerate release packages.

| Controlled delay per message | Baseline owner damage / settlement | Candidate owner damage / settlement |
| --- | --- | --- |
| 25ms | 75ms / 100ms | 25ms / 50ms |
| 50ms | 150ms / 200ms | 50ms / 100ms |
| 100ms | 300ms / 400ms | 100ms / 200ms |

These are transport replays of production Lua, **not measured internet ping or connected gameplay**. They prove the removed exchange costs two message legs. They do not explain every millisecond of the owner's recorded 407ms maximum. Prior logs lack enough stage timestamps to decompose that measurement exactly.

The adversarial replay checks duplicate messages, wrong senders, relative damage with intervening player injury, owner loss, Status overtaking Apply, applied/unapplied handoff, lower new-owner health, lethal reservation, server death, corpse proxies, expiry, recycled identity, fallen hats, changed Horde events, queue capacity and stale queued contacts. Full regression results and source hashes are recorded in `docs/evidence/c508-verification.json`.

Contact replays deliberately disagree about owner/server position. They exercise real report validation and Bed/Poke/Wire runtimes, with actor/world/transport doubles: first contact, exit without stale server repeats, immediate landing despite server `bumped`/false floor state, per-cycle protection, foreign/future-stale identity rejection and corpse exclusion. A 1,000-actor/60-tick report stress reaches all actors and accepts all 7,680 reports in packets of at most32. This is reporting throughput, not proof that1,000 concurrent damaging contacts preserve game FPS. Native network serialization includes the full32-frame packet (5,540 bytes).

`tools/smoke_turret_authority.py --source` materializes source solely in an isolated diagnostic server cache. Real stock42.21 native tests cover clock exposure, grapple-only exclusion, ownerless damage/death, Bed/Wire/Tack contact, overlap suppression, Martyrdom/Synergy, production firing and services. No players connect. The probe also confirms that native server zombie `setVariable` is a no-op; the initial assertion expecting server animation state failed and was corrected to test the actual engine contract. It was not treated as a gameplay pass. Native parsing independently validates the custom landing marker and its50% timing.

Existing Module Pack observer lifecycle, miniature rendering, range/visibility, cancellation and ordering fixtures remain in the full suite. No new claim of connected observer acceptance is made.

## Release gate and remaining work

**Do not package this candidate yet.** No version bump, install, Workshop stage, upload, sibling edit, live-server mutation or new release tag occurred. The existing cumulative Workshop draft is retained; reconcile these candidate changes into it when the release gate opens, without discarding prior unpublished notes.

Still required: actual two-client ownership/animation/health transport, corpse dragging across traps, quick crossings, owner handoff and disconnect, and observer presentation. The source-only native probe has zero connected clients. Current interpolated turret presentation and native owner motion remain; Poke's visible cycle still follows the authoritative server update. Additional speculative Poke animation has **not** been introduced or proven. Assess that remaining visible latency in the connected run before claiming the requested smoothness is solved.

The freshness limits intentionally reject severely delayed contacts instead of replaying old injuries. Existing processing ceilings remain processing safeguards; the crowd report test is not an assertion of unlimited simultaneous damage throughput. Saved tuning and balancing are unchanged.

Next connected checklist (after an isolated candidate setup, before release packaging):

- Bed landings and corpse dragging
- Poke crossings and wire exits
- Ownership handoff and confirmed damage
- Turret aim and remote Module Pack icons

GitHub synchronization remains blocked by the earlier automatic approval-review rejection of destination authorization. Do not use another push route to bypass it. Local reviewable source/evidence can be retained independently.

**Wait for a patch.** The cause-oriented source replacement and controlled proofs are available; connected acceptance and the release gate remain open.
