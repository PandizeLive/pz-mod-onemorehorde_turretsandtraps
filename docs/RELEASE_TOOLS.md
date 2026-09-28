# OMH local development and release process

Reviewed the current Horde Night [working agreement](../../pz-mod-onemorehorde_protectthecure/AGENTS.md) and [release-tool documentation](../../pz-mod-onemorehorde_protectthecure/docs/RELEASE_TOOLS.md) on 2026-09-26. Its repository-specific remote, Workshop item, reviewer and paired-package assumptions are not copied into this standalone project.

## Naming

- Player-facing name: **OMH: Turrets & Traps**. Keep the confirmed internal ID `OneMoreHorde_TurretsAndTraps` and existing persistence keys; renaming them would break save/package continuity.
- New versions use `major.minor.patch`, with a fourth numeric field for a small corrective build. Checkpoint labels belong in documentation, not `modversion`. The footprint change is `0.1.6`; a subsequent small correction would be `0.1.6.1`.
- Use `docs/PHASE_2_CHECKPOINT_1.md` for the current construction checkpoint, `docs/PR_v<version>.md` for release notes, and annotated local tag `test/v<version>` for exact source rollback. Historical checkpoint files, suffixed versions and their evidence retain their original names.
- One root [OMH.cmd](../OMH.cmd), stable helpers in `tools/`, and version read from packaged `mod.info`. No new per-version launchers. The two older launchers are retained in [an archive](../artifacts/legacy-launchers.zip).

## Process

1. Review the completed owner test and its exact loaded version; record evidence and unresolved limits before editing. Scope the patch to the approved behavior.
2. Implement and run the smallest meaningful checks; update checkpoint, decisions, current release notes and the cumulative `WORKSHOP_CHANGELOG.txt`. An install or version bump never resets pending Workshop notes.
3. Preserve complete source on a local non-main working branch, commit it and create an annotated `test/v<version>` tag before deployment. The installer requires unchanged tagged Contents and a matching validated SHA-256 manifest. Later tooling/documentation-only commits may follow the gameplay tag while Contents remain byte-identical, matching Horde Night's existing practice. Local Codex-authored commits use an explicitly local agent identity, not an invented owner identity.
4. Install locally with a full managed-folder backup and verify copied hashes. The current helper preserves unrelated files and retains the previous folder copy for recovery; automatic transaction rollback on a mid-copy OS failure remains a tooling gap relative to Horde Night. Never call readiness checks a successful install or test.
5. Establish the intended loaded version before evaluating gameplay. The native server smoke can prove startup separately; the owner's first SP test step verifies the actual client developer-menu version. An installed manifest alone does not prove the running client loaded it. Prefer SP while it can answer the question; combat MP acceptance remains deferred.
6. Review the test log and update acceptance. Remote mirroring and Workshop upload are separate owner-controlled release actions. No remote/item is configured here; nothing is automatically published. Before configuring them, use Horde Night's verified mirror/publisher contract and preserve owner-authored Workshop text/cover.

The stable menu matches Horde Night's action order: **1 Install locally**, **2 Mirror to GitHub**, **3 Publish mod to Steam Workshop**, **4 Check local install readiness**, **5 Check Workshop upload readiness**, **6 Project-specific tools**, **0 Exit**. Actions 2, 3 and 5 explicitly report unavailable. Option 6 captures console.txt and the installed manifest. It does not upload logs.

CLI checks: `OMH.cmd -Action Info`, `OMH.cmd -Action Install -ValidateOnly`, and `OMH.cmd -Action Capture`. Python native validation remains `tools/validate_foundation.py`; release-tool fixtures are in `tools/test_release_tools.py`. Installation does not modify saves, enabled-mod selections or sibling projects.

For 0.2.9, the game is 42.21.0 while installed PZOptimizer loose overrides still target 42.20.4. Set `OMHTT_STOCK_CLASSES=1` for isolated validation and smoke probes to put the stock game JAR first; the manifest records that class order and hashes the classes actually used. This does not fix or modify the normal game installation. Run `tools/smoke_server.py` first with `OMHTT_PROBE_MODE=write`, then `read` for a fresh-process restore. The owner must resolve the external optimizer mismatch before normal client testing.
