# C493 - Connected test failures (2026-10-28)

Owner reports: dragging 100 potatoes transfers one and retains 99; firing raises repeated errors; the observer does not see the same effects; Player B can open Player A's Private turret; most traps/turrets appear broken. Owner will update Horde Night and Trait Shop. This authorizes log investigation, not a new gameplay patch. No source, package, installed file, balance, server setting or Workshop change was made.

## Captured evidence

Local diagnostic directory: `C:/Users/bandi/Zomboid_Modding/diagnostics/2026-10-28-tt-multiplayer`. Preserved console.txt, the 14:30 client DebugLog and previous logs.zip. Read the matching dedicated server console, 13:30 DebugLog, command/admin/user logs and Testing settings through the existing SFTP connection after the owner restored its missing saved login. Server timestamps are one hour behind the client's displayed timezone; the session matches. Server reads only; no remote writes. Raw logs and account identifiers remain outside the mod repository.

Loaded versions on PZ 42.21.0:

| Component | Client | Dedicated server |
| --- | --- | --- |
| Turrets & Traps | 0.2.70.2 | 0.2.70.2 |
| Horde Night | 0.6.16.9 | 0.6.16.5 |
| Trait Shop | 0.9.1.1 | 0.9.0.1 |

The integration mismatch is real, but cannot repair the T&T client call below. Do not treat this session as XP/scoring acceptance. Server mod configuration includes the five OMH entries plus MultiplayerFastForwarding; local client translation warnings also mention Firearms. Those warnings are separate from the confirmed combat exception.

## Findings

1. **Confirmed shared combat failure.** Client console lines 6553-6564 and subsequent stacks record `attempted index: extraUpdate of non-table: zombie.characters.NetworkZombieAI`. There are 23 first error messages: 22 at DefenseCombatClient.lua:155 (Commit) and one at :144 (Reconcile). Both calls happen after setHealth and before the reply. Installed-jar javap confirms extraUpdate exists on NetworkZombieAI, but the runtime Lua access fails; Java existence is not Lua accessibility. The installed Lua exposer's bytecode has no NetworkZombieAI/NetworkCharacterAI registration. The server command log contains 33 Ready messages but only one Applied message. This is not proof of 33 distinct shots, since protocol retries/operations differ. It is evidence that normal acknowledgements are not completing reliably. TurretHit, Arc, Poke Floor and tether damage share this transport. Fix the invalid synchronization call and verify native health/death/owner handoff; do not swallow it with pcall or claim every independent trap defect is diagnosed.

2. **Ammo completion invalidates the current client action.** At client console lines 6378-6382, a Base.Potato transfer starts, then stops about 294 ms later with the network action marked Done. Another attempt follows seconds later. TurretTransferAction.isValid calls rejection on both sides; when replicated inventory moves the item to turret storage, incoming validation returns TransferCarried because source equals storage. stop delegates to native ISBaseTimedAction.stop, which resets the whole queue. An isolated installed-Kahlua probe executing these production functions reproduces valid-before/invalid-after and stop delegation for the remaining 99 entries. This establishes the faulty lifecycle condition; the precise network arrival order still requires a connected regression. Potatoes are separate inventory objects and do not use the <=0.1-weight ammunition batching path. Preserve authoritative per-item checks and bounded work; fix completion handling instead of forcing a giant batch or bypassing inventory validation.

3. **Private is currently write-private, not inspection-private.** OpenAction.isValid passes read=true; ControlAccess.authorized skips ownership checks for reads. ControlManage then marks the panel readOnly when write access is denied. The production-policy probe verifies a nearby unrelated non-admin can inspect while a write is rejected. Admin override also exists, so the report alone does not establish unauthorized changes or theft. Proposed behavior: Private denies ordinary non-owner inspection and changes, preserving explicit Public/Faction policy and the existing admin override. Audit native container access as well as Manage, including an already-open panel after permission changes.

4. **Observer effects remain unresolved.** DefenseEffects.send currently targets every online player within its bounded 100-tile area. The owner's client records projectile rendering; the other client's log is not part of this capture. No evidence yet establishes whether the observer failed to receive, deduplicated, failed to render or errored while processing the event. Include both-client effect delivery/rendering and ownership changes in the patch's connected verification; do not call this solved by the combat fix alone.

5. **Startup noise is distinct from combat.** Server errors in the capture include missing animation folders, broken-fence/property loading and other startup issues. No matching server-side DefenseCombatClient stack exists: that module is client-only. Do not equate all ERROR entries with separate broken defenses or claim the log is clean.

## Verification limits and proposed patch

The local reproduction is `production-path-probe.txt` in the diagnostic directory, with its Java/Lua fixtures. It uses the installed Kahlua and unmodified production transfer/access functions, but fixture world/inventory objects. It is not a connected transport test. Previous native combat smoke uses ownerless synthetic zombies and explicitly has zero connected clients; it never proved this client-owned Lua bridge path. Future checks must exercise real Lua exposure and client-owned/observer states, not merely provide extraUpdate as a mock method.

Recommend **1A: one focused multiplayer correction** for the combat call, transfer completion, Private inspection boundary and observer-effect investigation. **1B: combat exception only**, leaving the other known failures deferred. High reasoning is appropriate; estimate 35-55 minutes at Normal speed for implementation and automated/native checks, with Fast recommended under the workspace timing preference. Connected owner acceptance remains separate and cannot be promised by elapsed development time.

Owner approval for the corrective gameplay patch is pending. Current build 0.2.70.2 failed this connected acceptance round. The confirmed Workshop baseline remains 0.2.70.2; no new cumulative gameplay draft is created for this documentation-only audit. No new world is indicated by the diagnosed code defects. **Decision needed.**

## Documentation handoff

Read-only fetch of origin/dev succeeded and there are no origin/dev commits missing from this branch. Findings committed as 73ceb18. The required OMH.cmd -Action Mirror attempt stopped locally: `Commit intended changes before mirroring`. The pre-existing owner edit in docs/AMMO_UI_C446.md is preserved, SHA-256 `24506649c189a6e0b9f9e7fd04ab53fba940d3741a79ec38c267b75b75207fba`; it was not folded into this audit, stashed or reverted. No remote push occurred. This specific stop is a clean-worktree prerequisite, not an automatic approval-review rejection. Resolve that intended edit before retrying the mirror.
