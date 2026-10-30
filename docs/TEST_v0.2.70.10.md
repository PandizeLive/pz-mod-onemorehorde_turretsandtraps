# 0.2.70.10 verification and owner test

Status: automated/native verification passed; connected acceptance pending.

- 40,460 Kahlua assertions pass, including short consent leases, batched grants, exact local slowdown, Poke preview reconciliation and popup deduplication.
- Native Barrier test reproduces the stock packet overwrite against frozen old XML. The new node survives, wins real animation selection, dispatches both parsed markers and releases correctly.
- Controlled 50ms transport replay applies health and requests the owner's damage popup at 50ms, settles at 100ms after server dispatch. This is not total contact-to-render time or measured ping.
- 1,000-actor contact replay reaches every actor; 7,680 reports accepted, maximum 32 identities per packet. This is not an FPS benchmark.
- Native and fixture tests have no connected clients; visual multiplayer acceptance remains pending. [Detailed boundaries](MULTIPLAYER_REPAIR_C515.md).

## Owner checklist

After upload, update/restart server and both clients to 0.2.70.10. No new world required. Keep Diagnostic Logging and Detailed Logging enabled for both packages for this test.

- Spike Barrier front, sides and safe rear
- Concertina and Tacks: entry and exit
- Poke Floor fast crossings and corpse dragging
- Bed Spikes landing damage
- Turret hits and damage numbers on both clients

Review `barrier-report-sent`, `barrier-report-accepted`, `barrier-damage-confirmed`, `contact-to-owner-apply`, `contact-to-settled`, and `contact-to-damage-display`. A display measurement records the indicator call, not actual rendered frames. Preserve failed/unconfirmed outcomes separately from automated passes.

## Native/package verification

Native write and fresh-process read pass in 48.6/48.0 seconds. Traps-only, Turrets-only and combined startups pass in 44.5/45.1/45.6 seconds. All 457 source and 631 generated package files validate. [Sanitized proof record](evidence/c515-verification.json). No clients connected during native probes.
