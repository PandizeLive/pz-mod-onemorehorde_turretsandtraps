# Release state and publication policy

## Current state

| Field | State |
| --- | --- |
| Project | OMH: Turrets & Traps |
| Foundation date | 2026-09-25 |
| Edition | One; feature controls in Sandbox |
| Package version | 0.1.6; development test only |
| Confirmed mod ID | OneMoreHorde_TurretsAndTraps |
| Build evidence | B42.20.4 b0bbce05d5 with PZ Optimizer: dedicated startup/save/restart passed; player acceptance pending |
| Runtime source / installable package | Created; installed locally with file-hash verification |
| Git repository / remote | Local source repository with annotated test/v0.1.6 rollback tag; no remote configured |
| Workshop item / successful upload | None |
| Public changelog baseline | No upload exists |
| Official score support | Proposed; not implemented |
| Player tests | 0.1.5 SP damage/reaction test completed; 0.1.6 footprint/face acceptance and connected MP pending |

## Current directional footprint candidate

Version `0.1.6`: [checkpoint and prior-test review](PHASE_1_CHECKPOINT_2.md), [release notes](PR_v0.1.6.md), [manifest](../diagnostics/v0.1.6/manifest.json), [archive](../artifacts/OMHTT-0.1.6.zip). Uses numeric versioning and the stable [OMH.cmd](../OMH.cmd) menu. Source is preserved in a local annotated release tag before installation; no remote or Workshop item exists. The initial cumulative Workshop draft covers all unuploaded content, not just this patch. [Process and current tooling limits](RELEASE_TOOLS.md).

Local installation completed and all 44 installed files match both the manifest and exact Git-tag bytes. The prior 0.1.5 package backup also passes all 43 hashes. [Local release evidence](../diagnostics/v0.1.6/local-release.json) records source commits, archive hash and backup location. A tooling-only commit follows the gameplay tag; Contents are unchanged. The running owner client still needs a restart and version confirmation.

## Previous shove and retaliation candidate

Version `0.1.5-p1retaliation` implements animated potato knockdowns, fixed actual damage, SP barrier strike-marker retaliation and optional Pixel Indicator popups. [Record](checkpoints/P1_RETALIATION_RECORD.md), [manifest](../diagnostics/p1retaliation/manifest.json), [archive](../artifacts/OMHTT-0.1.5-p1retaliation.zip). Native parser/Kahlua/behavioral checks and isolated server startup/save/shutdown pass. Player marker timing, movement and corpse/loot acceptance remain pending; skipped-frame and final-breaking-strike limitations are explicit. No Workshop upload occurred.

## Previous combat repair

Version `0.1.4-p1combat` repairs negative aim headings/invisible saved turrets, implements the owner's one-real-second shot interval, uses native knockdown/eligible physics requests and logs delayed reaction outcomes. See the [record](checkpoints/P1_COMBAT_RECORD.md), [manifest](../diagnostics/p1combat/manifest.json) and [archive](../artifacts/OMHTT-0.1.4-p1combat.zip). Retaliation, construction and module inventory remain pending. Local checks pass; player animation/visibility acceptance is pending. No Workshop upload occurred.

## Previous visibility patch

Version `0.1.3-p1markers` implements owner-requested distinct developer markers and directional arrows, exact-object visual migration, native render invalidation and bounded readiness diagnostics. See the [record and completed SP-run findings](checkpoints/P1_MARKERS_RECORD.md), [manifest](../diagnostics/p1markers/manifest.json) and [archive](../artifacts/OMHTT-0.1.3-p1markers.zip). No Workshop upload occurred.

## Previous debug patch

Owner evidence exposed an obsolete translation format and obstructive test reports. Version `0.1.2-p1debug` supplies current JSON translations, native-loader validation, automatic missing-translation detection, structured diagnostics and nonmodal action feedback. See the [patch record](checkpoints/P1_DEBUG_RECORD.md), [manifest](../diagnostics/p1debug/manifest.json), and [archive](../artifacts/OMHTT-0.1.2-p1debug.zip). No Workshop upload occurred.

## Previous Phase 1 batch

The owner authorized further checkpoints before player testing. [Batch record](checkpoints/P1_BATCH_RECORD.md), [batch manifest](../diagnostics/p1batch/manifest.json), and [batch archive](../artifacts/OMHTT-0.1.1-p1batch.zip) describe the added native obstruction, SP manual potato, cube aim frames, bounded effects/scheduling and resource persistence checks. Per-thump retaliation and multiplayer firing remain deferred. No Phase 1 checkpoint is accepted and no content upload occurred. Earlier evidence below remains historical.

## P1C1 test package

The owner approved the first runtime checkpoint. The [checkpoint record](checkpoints/P1C1_RECORD.md) documents exact scope, native source evidence, implementation, test limitations and the complete owner test. Local package: [OMHTT-0.1.0-p1c1.zip](../artifacts/OMHTT-0.1.0-p1c1.zip); identity: [manifest](../diagnostics/p1c1/manifest.json).

The installed test controls default OFF. This version contains a static white cube device, unique identity and condition persistence, validated placement/removal requests, duplicate protection, and inspection diagnostics. It does not implement combat or final turret rendering. Automated checks and a real isolated dedicated startup/save/restart passed; no player connected to that smoke test. P1C1 is not accepted yet.

The isolated server was shut down after testing. No production save, server configuration, sibling mod or public listing was changed. No content upload occurred. The following foundation/asset entries describe their historical state at those earlier steps.

## Technical placeholder asset

On 2026-09-25 the owner authorized a temporary white cube-only model and specified final art will be sourced without AI. Created [GLB/glTF exports and offline previews](../art/placeholders/cube_turret/README.md) with a fixed base, separate head pivot, aim cube and invisible muzzle marker. Exactly three cubes, 36 triangles per instance, one plain white material, no textures or aesthetic detailing.

Validation: generator reloaded the GLB and checked chunk/accessor bounds, finite values, triangle winding, cube geometry, material, fixed-base and head rotation behavior. Visually inspected the static preview. This is not Blender import, external-validator certification, a PZ render capture, or multiplayer evidence. No game package was installed or published; gameplay version remains None.

## Foundation verification

Local document audit completed 2026-09-25:

- 15 Markdown documents created; 28 local file links resolve, including the referenced sibling-project and historical game-source files.
- 24 checkpoint IDs defined in the roadmap; no undefined checkpoint references found.
- Confirmed requirements checked against the conversation: single edition/toggles, potato 3-5 direct-hit target and impact splash, pulse/maintained inputs, one Poke Floor, shared XP with offline inclusion default ON, and Cure simulation last.
- Unapproved percentages, numerical tuning, recipient-life policy, ownership assignment, target/contact details and package identity remain labeled as proposals or open decisions.
- No runtime files, gameplay version, installed build, Workshop changelog/upload, or sibling-project changes were introduced. No gameplay tests were run.

The audit checked document consistency and local targets. It did not revalidate remote websites, prove engine behavior, or certify API compatibility.

Planning clarification, 2026-09-25: added the confirmed individual/all-linked control-unit targeting requirement. Withdrew the assistant-imposed base-boundary prerequisite; device ownership can identify the reward faction without a geographic claim. Subsequent owner clarification limits targeting to devices with smarts: passive objects ignore the filters. Players automatically jump over bed spikes; the Spike Barrier blocks entry and vaulting. Collateral, smart-device capability and exact faction-mode details remain explicit open policy choices. Traversal is scheduled for a current-build prototype, not reported as working. Documentation only; no gameplay release change.

## Packaging and local workflow

At P1C1 confirm the persistent package identity, installed game build and supported version-directory convention. Introduce only the necessary common/versioned assets and client/server/shared files. Use original artwork or explicitly permitted sources, with provenance in art/README.md.

Before a deployable test, establish a local source rollback point and exact version identification. A future stable project launcher can handle local validation/install and owner-run mirror/publish operations. Do not create versioned duplicate launchers during planning or invent remote IDs.

Before a public candidate, verify translations, Sandbox defaults, current-build load, clean install/update, ownership/reward migration, dependency absence, relevant compatibility, and the accepted manual evidence. Release notes must state loaded-area limits until P6 ships.

## Workshop changelog baseline

Do not populate a WORKSHOP_CHANGELOG.txt with planned features as if implemented. Create it when actual packaged gameplay changes exist. Keep one cumulative draft containing net changes since this item's last confirmed successful content upload, under the latest packaged version heading.

Local versions, tests, commits, tags, mirrors, preflight and failed/preview/leaderboard uploads never reset the draft. Record exact item ID, released version, uploaded snapshot, upload evidence and time here after a successful content upload. Preserve changes made after that snapshot. Published notes remain until the next real change begins a fresh draft.

Use the publisher's established category/bullet format when publication tooling is introduced. Preserve owner-authored Workshop descriptions and the cover. Required description line for OMH releases: `DISCLAIMER: This mod was made in tandem with ChatGPT`.

## Coordinated integration releases

Record compatible Horde Night, Trait Shop, Cure Defense and website validator versions separately, backed by implementation/test evidence. An extension descriptor does not establish official leaderboard support. Unpublished sibling changes cannot be advertised as existing user-facing functionality.

External publishing, pushing and public listing changes require owner authorization. P1C1 authorizes local implementation and validation, not publication.
