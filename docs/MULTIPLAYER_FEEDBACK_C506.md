# C506 - Connected trap retest and client authority discussion

2026-10-29. Owner reports missed Bed landing damage, late Wire/Poke reactions and damage after exit, apparent double Poke hits, and corpse pickup triggering Poke. Requests video investigation and explanation of connection/client authority/Horde implications. Investigation and proposal only; no new gameplay patch authorized by this report.

## Evidence

- Client and server logs load 0.2.70.7. Read-only SFTP console, command log and Sandbox snapshot retained outside the public project in workspace diagnostics/2026-10-29-tt-c506. Current local console copied there. No server mutation.
- Reviewed sampled frames throughout the approximately 20-second Discord_XFJ1G9YEij.mp4. The player drags, drops and picks up a corpse across two adjacent Poke tiles; a 45 damage number appears during pickup around 14 seconds. Frames alone do not identify the authoritative victim or prove player damage.
- Current installed stock projectzomboid.jar bytecode confirms IsoDeadBody.reanimateZombieForGrapple calls reanimate and sets IsoZombie.setReanimatedForGrappleOnly(true). The public getter exists. Native ISGrabCorpseAction.complete calls pickUpCorpse. DefenseActors.observe and ControlPoke exclude isDead but not this special representation. Confirmed eligibility defect; exclude consistently from discovery, contact, queued/committed damage and related procs, preserving genuine reanimated enemies.
- Detailed trap logging is enabled at runtime; detailed turret logging is disabled. Two bed-trip events, no bed-landing/bed-fall events in the captured server console. This localizes this observed Bed failure before damage dispatch. Exact missing animation/position transition still requires owner-state evidence; do not declare a particular state-name cause proven. The custom trip animation lives in the bumped animation group, while server stance detection accepts onground/getup as landed.
- 46 detailed combat-result events: all applied; 34 Poke transactions take 150-228ms (mean178ms), 12 barbs transactions155-407ms (mean211ms). These are recorded transaction completion times, not ping, total contact latency or a complete all-turret success rate.
- A pair for victim2793 comes from control-4 then control-3 about193ms apart: distinct adjacent traps, not proof of duplicate receipt execution. Subsequent control-4 hits recur around1.5-1.6seconds. Do not silently introduce a shared cross-trap cooldown or claim all reported doubles explained.
- Server observations precede Prepare/Ready/Commit/Applied. Queued Damage jobs retain identity, expiry and Horde lease but no contact-time/exit validity contract; Commit checks identity/owner/liveness but not current trap contact. Late visible damage is possible even with correctly delivered packets. A legitimate brief-crossing hit must be distinguished from a newly generated stale repeat after exit.

## Recommendation and limits

This is not evidence that the owner's internet is defective. Replication and extra exchanges affect onset; different observers may see different timing. A better connection cannot correct grapple-only eligibility or a missed landing event. Previous 37,207 assertions and native fixture passes remain valid for their tested cases, but did not cover connected corpse dragging/real animation transitions. Connected acceptance of0.2.70.7 fails and remains open.

Recommend1A: replace trap contact/landing observation for client-owned zombies with bounded reports from their native simulation owner, validated against server device identity, floor, position/time, ownership, contact episode and cooldown. Reject corpse representations throughout the shared pipeline. Keep ownerless server fallback. Predict reversible presentation locally, reconcile authoritative trap cycles, and preserve one authoritative damage/death/reward result. Audit whether the existing extra handshake can be reduced without weakening duplicate or ownership-handoff protection; do not promise zero latency or change protocol blindly. Prove eligibility/entry/exit/landing and stale-event behavior first, then require a real connected test.

Alternative1B: fix corpse eligibility and continue server-only contact/landing repairs. Smaller patch, but leaves the server's delayed observations as a responsiveness limitation.

Moving visual/contact observation to the native owner does not inherently break Horde Night. Moving unrestricted damage/kills to arbitrary observers would bypass the current server consent/run lease, assistance classification, death and XP accounting. Preserve DefenseHorde and DefenseXP authority; do not fabricate ordinary player attacks or duplicate awards. Native-owner reports are evidence to validate, not permission to choose damage.

Decision needed:1A recommended,1B narrower. No code, install, Sandbox, live-server or publication changes. GitHub mirror remains blocked by the earlier automatic approval-review rejection of destination authorization; no alternate route attempted.

## C507 owner selection and evidence requirement

**C507 / 1A selected; fundamental-path verification required (2026-10-29).** Owner accepts native-owner contact reports but requests brief confirmation first and concrete evidence instead of another speculative patch. Audit the full observation/queue/Prepare/Ready/Commit/Applied path; separate server scheduling, network transit and confirmation cost before attributing the407ms maximum. Reproduce connected contact, landing and corpse failures and compare the replacement against that baseline; preserve server Horde/XP authority. Do not claim connected success from fixture counts. This turn records scope only; no gameplay or installation change. **Wait for a patch.**
