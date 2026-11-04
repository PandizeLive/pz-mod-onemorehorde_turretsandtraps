# 0.2.71 verification and owner test

Status: automated and native verification passed; locally installed and staged from immutable `test/v0.2.71` / `bd42f08`. Connected acceptance remains pending. [Checks](evidence/c526-checks.json) | [Delivery](evidence/c526-delivery.json).

41,863 Kahlua assertions pass, including the full existing damage/module/contact suite. Five frozen pre-fix implementations fail their intended regression assertions: physical child travel, explosive Fragment delay, rotary packet freeze, Tether packet freeze and bomb batch duration. The corrected production paths pass.

Focused coverage includes projectile family/arrival/impact origin, remaining piercing flight, Arc exclusion, firearm tracers, delayed snapshots, rotary cone reversals/360 wrap/stops/restarts, bounded prediction, server-only exact-item bomb transfers and replay rejection. Cross placement covers every arm, overlap, blocked floors/fixtures/walls, safehouses, legacy placements, pickup and serialized reservations.

Native checks use installed stock game classes with zero connected clients. The placement probe verifies one object, five reserved squares and no obstacle objects on the arms. Native bomb items retain weight 1; 41 selected bombs form three bounded actions, and native inventory batching merges at most 20. The stabilizer mesh imports through the native model pipeline. These checks do not prove rendered appearance or live connection smoothness.

Initial native failures were outdated test fixtures (old Barrier repair health and old Poke recipe quantities); corrected fixtures still require native material consumption, retained tools and exact outputs. Failure logs are retained in diagnostics/c526. No production guard was relaxed to pass a fixture.

## Owner checklist

After uploading both T&T 0.2.71 and Horde Night 0.6.16.10, update/restart the server and both clients. No new world required. Keep both packages' Diagnostic Logging and Detailed Logging enabled during this test. Existing Sandbox tuning is retained; redeploy a Poke Floor to test its new footprint.

- Splitter and Fragment projectiles on both clients
- Rotary starts, turns, stops and restarts
- Tether travel, attachment, pull and cooldown
- Makeshift Bomb stack loading
- Poke cross placement, overlap and pickup
- First crossings: Bed Spikes, wire, panels and Poke
- Spike Barrier damage and durability

No Workshop upload or live-server change is performed by this update. GitHub mirroring remains blocked by the prior automatic approval review; it has not been bypassed.

Delivery verifies all461 source and636 tagged/package/local/archive/stage files, previous package/stage backups, and unchanged Workshop page metadata/preview. All three independent package starts pass. The artist handoff contains164 unique payloads and47 aliases, including Tether nail/cable and the stabilizer mesh. Horde Night0.6.16.10 is also locally installed/staged from its immutable tag.

## C527 connected rotary failure

Owner reports delayed hits and a violent spin after stopping. Client/server logs confirm0.2.71. The stop-path renderer handoff and stale native-position rejection are reproduced; server logs45 post-hit impact callback exceptions. Rotary acceptance is failed. [Findings and proposed correction](ROTARY_FEEDBACK_C527.md). No replacement build installed.
