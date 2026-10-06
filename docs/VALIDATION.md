# Validation and evidence

Historical candidate `0.2.0`: [P2C1a](PHASE_2_CHECKPOINT_1.md) added native construction. Checks compiled 12 Lua modules, loaded 61 translations and passed 232 assertions, including the installed native creation path with recipe/world doubles. Native startup validated the entity/recipe, four two-tile faces and closed MP construction gate. See [validation](../diagnostics/v0.2.0/validation.log) and [native smoke](../diagnostics/v0.2.0/server-restart.log). The [0.1.6 owner review](TEST_v0.1.6.md) remains prior player evidence. No headless or double-based check establishes rendered player acceptance.

## Current validation pointer

Current 0.2.29 evidence is in RELEASE.md and PATCH_v0.2.29.md; earlier version notes are historical observations. C88 approves fully independent packages and fresh worlds; owner testing remains deferred. Native package isolation, shared registration and separate controls pass in all three selections; 3,439 Kahlua assertions pass. All current player checks are consolidated in the [single next-patch test](checkpoints/R1_PACKAGE_SPLIT.md#combined-owner-test-for-the-next-playable-build); old patch checklists are historical and must not become additional requested rounds. Native package-combination/loading/absence checks precede installation; rendered acceptance remains pending until the owner tests later.

## Smallest reliable checks

2026-09-26 player evidence: [completed review](checkpoints/P1_COMBAT_OWNER_REVIEW.md) confirms 26 shots, all eight requested knockdowns reaching the floor, ready textures for all 62 queued checks, and one native barrier destruction. No OMHTT error occurred. Live one-second boundary, reload/migration, death/loot and MP still need evidence. Potato damage remains below target; the new shove-style preference and 20-per-thump retaliation are unimplemented.

| Work | Initial check | When to expand |
| --- | --- | --- |
| Documentation | Local links, decision consistency, checkpoint references and status claims | Only when structure or a decision changes |
| Package shell | Installed-game script parsing/loading and exact version log | Add SP object lifecycle before gameplay |
| Device damage | One device and one zombie with authoritative death/corpse evidence | Add dedicated ownership/transport, then second observer |
| Construction/service | Materials consumed once, valid target retained | Add concurrent requests, restart and failed validation |
| Signals | One source and one receiver | Add held input, multiple sources, broken links and reload |
| Shared XP | Deterministic pool/divisor/fraction and unique-death ledger checks | Add offline delivery, crash/retry, faction/life changes |
| Score | Pure multiplier/configuration/history checks | Add core export, website validator and end-to-end UI |
| Cure simulation | Deterministic population/resource reconciliation | Compare loaded control and adversarial transitions |

Do not write tests that merely mirror constants or implementation structure. Use contracts and observed outcomes. Compilation and static checks do not prove multiplayer behavior or player-facing animation.

## Runtime coverage

| Environment | Required evidence |
| --- | --- |
| Single-player | Construction, damage, servicing, settings, save/load, pause/fast-forward and standalone behavior |
| One-player dedicated | True server authority, item/world transport and persistence |
| Two-player dedicated | Shared ownership, simultaneous actions, zombie ownership changes, matching visible impacts/deaths, split XP |
| Hosted multiplayer | Confirm listen-server lifecycle follows the same authoritative paths; focused regression when relevant |
| Offline recipient | One faction member absent while active combat earns real kills; bank and reconnect settlement |
| Dependency combinations | Core only; Trait Shop only if supported ownership exists; Horde only; Horde+Trait Shop; Cure combination |

Start with SP where sufficient. Add one-player dedicated only for networking, and a second player for cross-player behavior. Broader combinations can be distributed across release gates instead of repeating the full matrix after every small edit.

## High-value invariants

- A device ammo unit is consumed once, including concurrent/retried activation; failed shots follow the explicitly chosen consumption rule.
- One authoritative death produces at most one reward path and one pool. Splash finishing blows do not duplicate primary or ordinary-player rewards.
- Pool allocations sum to the original pool, with bounded precision and retained fractional remainder; faction size does not create XP.
- Offline ON includes the absent member in the divisor and preserves that entitlement. Offline OFF affects future allocations only.
- Delivery and its receipt remain consistent across interruption; old-life entitlements cannot drift to a new life under the recommended policy.
- Construction, pickup, dismantle, repair and settings toggles do not duplicate items or refill turret resources. Basic-barrier pickup/free repair intentionally restore full durability under C32; verify the ten-second delay and one-item return.
- A lost/removed host object leaves no damaging barbs behind. Obstructions agree with sprites and attacked faces.
- Held input is not a backlog of pulses. Reload restores current occupancy rather than replaying past triggers.
- Control-unit changes affect only authorized individual/all-compatible-linked smart devices. Passive hazards remain unaffected, including under No one. Current smart-device target eligibility is revalidated before effects; changing factions/targets does not change reward ownership or bypass the chosen PvP/collateral policy.
- Players of any faction automatically jump over bed spikes using visible synchronized traversal. Test walk/run/sprint input, supported directions/footprint, blocked landings and interruptions; no teleport or silent walk-through substitutes for the jump.
- The Spike Barrier blocks walking into its footprint; existing runtime remains non-vaultable. The requested player vault prototype must cross the actual obstruction safely, roll once per completed front crossing (20% ordinary scratch), keep the rear safe, reject blocked landings and retain zombie obstruction/thumping.
- Potato crowd effects are bounded, blocked appropriately and cannot create permanent knockdown chains.
- Score reductions apply once, multiply correctly and retain earning-time history. Disabling/uninstalling cannot erase prior benefit.
- Before P6, no kills, damage or rewards are synthesized for unloaded areas or stopped servers.
- P6 transitions conserve virtual/live survivors and resources; repeated transitions do not improve defense effectiveness.

## Performance and compatibility

Record build, device count/types, zombie count/density, relevant mods, server hardware, clock settings and profiler method. Compare a no-device control at the same workload. Capture scanning, target/ray checks, splash victims, authoritative activations and network events rather than claiming performance from client FPS alone.

Choose practical acceptance budgets after measurement. Test barriers against native pathing and thump settings, concertina against other movement effects, and sentries against the initially supported weapon set. Audit third-party damage/barricade mods only when relevant to an actual compatibility claim.

## Example future owner test: offline XP

This is a template, not a test-now instruction. Before issuing it, fill in the exact installed/published build, configured XP/rate, expected per-member amount, provided test setup and log location.

1. Load the specified build with two living faction characters and supported Trait Shop integration; verify the version and both XP totals.
2. Keep offline rewards ON, disconnect member B, and cause one known eligible defense kill while A keeps the area active; A receives the calculated share and B's same-sized share is pending.
3. Restart the server, reconnect B on the same life, and inspect progression; B receives the pending share exactly once and A keeps its prior share.
4. Reconnect B again and inspect both totals; no reward repeats and fractional amounts are preserved.
5. Turn offline rewards OFF, disconnect B, and repeat a known kill; A receives the full reduced pool and B earns no new share.
6. Reconnect B, return the settings to the intended baseline, and report both totals with the requested logs; inspect logs before accepting the checkpoint.

Life death/respawn, faction changes, simultaneous killing, final-Horde kills and deliberate interrupted delivery get separate short tests when their behavior is implemented and agreed. Do not bury all known steps in follow-up messages.

## Evidence record

Use the checkpoint template to record exact source/build identity, automated command/result, runtime environment, observed output, relevant logs, unresolved risks and release status. Player observation without the matching version is insufficient; a successful upload is not proof of gameplay correctness.

Foundation review on 2026-09-25 covers document structure, links, checkpoint IDs and consistency only. Verification results are recorded in [Release state](RELEASE.md); no runtime success is implied.
