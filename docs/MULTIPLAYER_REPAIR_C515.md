# C515 - Contact response and Spike Barrier repair

## Approval and scope

2026-10-30: owner explicitly approves fixing multiplayer delay and Spike Barrier, and lifts the packaging hold: "Packaging doesn't need to be on hold, but you need to be certain." This supersedes C514's packaging restriction. It does not waive honest evidence boundaries or authorize Workshop upload, live-server changes, or sibling changes. The candidate is 0.2.70.10.

## Reproduced root cause

The current native `ThumpState.enter` selects a stock ThumpType and sends a Thump packet. `ThumpPacket.processServer` relays that packet back to relevant connections, including the owner; `processClient` writes the packet's ThumpType unconditionally. The old Barrier animation depended on setting this same variable to OMHTTBarrierClaw. A native packet therefore deselects the custom node, suppressing its strike markers. This matches the connected capture's six attachments and zero reports, although that capture did not itself trace the overwritten variable.

`NativeBarrierAnimationProbe` reproduces the overwrite on a real IsoZombie using the actual packet handler and frozen pre-fix XML. The old node loses eligibility. The replacement uses the separate boolean OMHTTBarrierContact and explicit selection priority. It survives the same packet; the real AnimState selector selects it over the three stock thump nodes. Both parsed strike events reach the native actor event dispatcher and set the expected markers. Releasing contact deselects the node. No repeated resetting of native ThumpType is added.

This proves packet/selection/event dispatch behavior, not live animation-track progression. The probe has zero connected clients and no rendered animation. Existing production report/validation/damage tests cover the downstream path separately, including duplicate and foreign-owner rejection and rear safety.

## Replaced waits

- Wire, panels and Tacks: remove delayed server slowdown impulses for client-owned zombies. The server grants a short, renewable consent lease while the owner reports approach to indexed hazards. The native owner applies slowdown from exact local contact, stopping immediately on exit. Grants last at most 400ms, refresh no more often than 200ms, and are batched with at most 32 identities per reply. Ownership, outfit, clock, expiry and Horde denial invalidate permission. Server damage, wear and rewards remain unchanged.
- Poke Floor: under the same permission, show the local raised sprite on entry without awaiting its server publication. A 350ms bounded preview yields to authoritative state or restores the existing sprite. It changes no replicated state or damage. The normal cycle still controls subsequent previews; the first eligible server contact already requested damage immediately. The 150ms stroke window was not a startup delay.
- Damage numbers: the native owner displays actual applied health loss immediately after sending its acknowledgement. The later confirmed broadcast supplies observers; a bounded token set prevents a second popup on the owner. The acknowledgement is sent before optional third-party display code. Observer coordinates use the confirmed owner position.
- Timing: carry the original contact observation time through the damage queue, owner application, settlement and damage-display call. Existing bounded diagnostics now distinguish contact-to-owner-apply, contact-to-settled and contact-to-damage-display. These measure code events, not GPU presentation; Pixel Strike display timing exists only when that indicator is active.

## Evidence and limits

The full production Lua regression suite includes 339 supported head/module hit cases, 360 catalog cells, all trap damage paths and a 1,000-actor contact stress replay. New tests cover local entry/exit with 25/50/100ms controlled transport delays, owner handoff, expired/reordered/revoked permission, lost clock synchronization, Poke preview reconciliation, batched grants and popup deduplication. They use world/network doubles and are not measured internet performance.

The controlled damage transport test applies owner health at 50ms and settles at 100ms after the server request. Owner popup dispatch now occurs at the health application, rather than waiting for acknowledgement and a subsequent broadcast. Initial contact transmission and server scheduling are additional costs; the old 82-105ms server transaction logs never measured the complete path. This patch does not promise zero-latency authoritative damage or smooth observers on every connection. New/spawned actors without an approach lease wait for consent; expired or denied consent deliberately suppresses local prediction.

Current game bytecode and installed vanilla animation files are the implementation authority. Official [42.21 release information](https://projectzomboid.com/blog/news/2026/09/re-population-of-the-dead-build-42-21-unstable-released/) and [42.20 feature overview](https://projectzomboid.com/blog/features-overview-build-42-20/) provide version context, not proof of this mod's fix. Probes prefer the stock jar over stale local optimizer overrides.

See [version checks and delivery](TEST_v0.2.70.10.md). Connected owner/observer smoothness, real Barrier animation progression and Bed landing behavior remain explicit acceptance checks. No sibling scoring or damage-authority rewrite is included.

The previous automatic approval review blocked GitHub mirroring over destination authorization. No alternate push route is used.
