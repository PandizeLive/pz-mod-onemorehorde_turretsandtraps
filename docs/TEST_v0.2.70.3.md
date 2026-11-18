# 0.2.70.3 verification

Approved scope: [C494 patch](PATCH_v0.2.70.3.md). C493's failed 0.2.70.2 connected acceptance remains historical evidence, not acceptance of this build.

## Checks

- Full foundation validation: **37,026 assertions**; 447 source files, 615 packaged files. Eight replacement automation textures match owner SHA-256 hashes and retain 28x29 RGBA dimensions. Multiplayer text checks pass.
- Combat tests exercise Prepare/Commit/Applied, reconciliation, duplicate delivery and owner changes with the unexposed NetworkZombieAI method unavailable. Current-game bytecode also confirms native received-health transport. These are not connected ownership acceptance.
- 100-potato regression exercises queued validation, running remove/add replication gaps and stale server completion. Controller withdrawal covers replication and revoked access. Server authority checks remain unchanged.
- UI regressions verify retained Private inspection, grey disabled mutation buttons, pending-edit cancellation, locked mouse/gamepad slider changes, authoritative display refresh and restored write access. Existing item/server permission checks continue to pass.
- Observer checks deliver to two nearby recipients and exclude a distant player; serialized client rendering uses local time and retains line of sight. The reported two-player visual discrepancy is not independently reproduced.
- Native save/write **65.5s**, fresh-process read **61.1s**, independent Traps **58.4s**, Turrets **58.9s**, combined **59.0s** all pass. These native server probes had **zero connected players**.
- Installed from immutable `test/v0.2.70.3` / `ccf9e7bd5a7e07a4bc05a745d02dc6d18c9fba14`. All 447 source and 615 package/tag/install/archive files verify, plus both previous 0.2.70.2 backups. `diagnostics/v0.2.70.3/local-release.json` records hashes and backup/archive paths. No Workshop upload or hosted-server update has occurred.

Fixtures use simulated players/network/UI objects and cannot establish a successful connected server session. Diagnostic evidence: `diagnostics/v0.2.70.3/` and `diagnostics/c494-*.txt`.

## Owner checklist

Both clients and the server must load 0.2.70.3 before this test. Local installation alone does not update the Workshop server. No new world required.

- Full potato-stack loading
- Turret and trap damage
- Both players' shot effects
- Private inspection with grey controls
- Automation replacement icons

Connected acceptance and observer visual parity remain pending.


C494 mirror attempt (2026-10-28): `OMH.cmd -Action Mirror` stopped at its local clean-tree guard because unrelated `AGENTS.md`, `README.md` and `docs/AMMO_UI_C446.md` edits remain. The patch and installation evidence are committed; those edits are preserved and excluded. No network push occurred in this attempt; this was a local preflight refusal, not an automatic approval-review rejection.


C495 (2026-10-28): CMD mirror tooling now leaves ordinary tracked documentation edits local with a warning while publishing committed work. Fifteen isolated cases pass; no gameplay/package/tag change. The earlier blanket clean-tree blocker is superseded; live push verification follows.

C495 live result: `OMH.cmd -Action Mirror` successfully pushed and independently verified commit `78b9ef8c81b9c5d2454acb91c27948226074c8d8` and the immutable `test/v0.2.70.3` tag on the configured GitHub repository, using existing draft PR1. Original AGENTS.md, README.md and AMMO_UI_C446.md edits remain local. No merge, official release or Workshop upload occurred.


## C498 - owner retest used 0.2.70.2 client (2026-10-28)

The16:16 client session reports `packages-ready` and `client-ready version=0.2.70.2`, with13 `java.lang.RuntimeException: attempted index: extraUpdate` errors at DefenseCombatClient.lua155. Read-only SFTP capture confirms the15:10 server session loaded0.2.70.3, with no corresponding extraUpdate exception. This is not evidence that the removed call still exists in the0.2.70.3 patch.

The local native Workshop authoring stage still contained0.2.70.2 and both extraUpdate calls, while the ordinary local install and downloaded Steam item contained0.2.70.3 without them. Installed42.21 ZomboidFileSystem bytecode establishes default enumeration order `workshop,steam,mods`, placing this stale authoring copy first. Refreshed the managed native stage using `OMH.cmd -Action Stage`; it preserves its owner metadata and prior contents in the helper's backup. All615 packaged files now match the immutable tag across all three local locations. No new code, upload, world or server change.

SteamCMD receipt `upload-v0.2.70.3-20261028-200859-0574-3f7611c1` independently confirms the owner's upload at2026-10-28T20:09:27.9380072Z. This establishes0.2.70.3 as the new per-item content baseline; preserve its current changelog until the next content change. Earlier failed authentication receipts remain failed/pending attempts, not publication evidence.

Evidence: workspace `diagnostics/2026-10-28-tt-retest/`, project `diagnostics/c498-filesystem-javap.txt` and `diagnostics/c498-copy-verification.json`. Connected acceptance still requires a restarted client that actually reports0.2.70.3. The other player's loaded version was not independently captured.

- Restart Zomboid; verify 0.2.70.3
- Turret and trap attacks
- Both players' shot effects


## C499 - restarted multiplayer test (2026-10-28)

Both captured sides now load0.2.70.3; no extraUpdate exception in the new capture. Owner reports low-health survival, target resets during ammo loading and missing empty feedback. Server records50 Applied receipts and one module-loot container packet error during death. This is not accepted combat testing or proof that every receipt completed a kill. See [C499 findings and proposal](MULTIPLAYER_FEEDBACK_C499.md). No gameplay patch or new owner test in this checkpoint.
