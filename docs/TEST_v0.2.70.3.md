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
