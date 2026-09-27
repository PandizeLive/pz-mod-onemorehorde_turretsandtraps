# Release state and publication policy

## 0.2.5 native-control correction candidate

[Scope and owner test](PHASE_2_CHECKPOINT_2_VAULT_REPAIR.md), [release notes](PR_v0.2.5.md). The 0.2.4 owner test failed collision/approach acceptance; its successful synthetic checks remain historical evidence only. 0.2.5 implements the approved correction, including the pre-existing owner-supplied icon. [Local installation evidence](../diagnostics/v0.2.5/local-release.json) verifies all 75 installed files against the validated manifest and [tagged archive](../artifacts/OMHTT-0.2.5.zip). Annotated `test/v0.2.5` points to `90f7fe7`. The full previous installation is backed up; see the evidence record for baseline comparison. Restart before the owner test. No Workshop content has ever been uploaded; the cumulative draft retains all pending net changes.

## 0.2.4 fence-collision candidate

[C34 / P2C2-vault](PHASE_2_CHECKPOINT_2_VAULT.md) implements the approved edge-collision choice and native player Vault action, combined with the still-unaccepted 0.2.3 repair. Automated/native checks pass; owner SP acceptance is pending. [Release notes](PR_v0.2.4.md) and [complete combined test](PHASE_2_CHECKPOINT_2_VAULT.md#owner-test) distinguish headless evidence from rendered gameplay. Recipes/art remain unchanged. No remote push or Workshop upload is authorized or claimed.

[Local installation evidence](../diagnostics/v0.2.4/local-release.json) verifies all 71 installed files against the manifest, archive and annotated `test/v0.2.4` source (`0ca7095`). All 70 files in the complete previous 0.2.3 backup also match its manifest. The archive is [OMHTT-0.2.4.zip](../artifacts/OMHTT-0.2.4.zip). The running client's loaded version and gameplay acceptance remain pending; restart before testing. Documentation/evidence-only commits can follow the gameplay tag without changing Contents.

## Current state

| Field | State |
| --- | --- |
| Project | OMH: Turrets & Traps |
| Foundation date | 2026-09-25 |
| Edition | One; feature controls in Sandbox |
| Package version | 0.2.5 installed; SP development test |
| Confirmed mod ID | OneMoreHorde_TurretsAndTraps |
| Build evidence | B42.20.4 b0bbce05d5 with PZ Optimizer: dedicated startup/save/restart passed; player acceptance pending |
| Runtime source / installable package | 0.2.5 installed; 75 tagged files verified |
| Git repository / remote | Local working branch; annotated test/v0.2.5 (90f7fe7); no remote configured |
| Workshop item / successful upload | None |
| Public changelog baseline | No upload exists |
| Official score support | Proposed; not implemented |
| Player tests | 0.2.4 failed rendered collision/approach acceptance; 0.2.5 owner test pending |

## Current correction and Sandbox candidate

Version **0.2.3** repairs the [failed 0.2.2 test](TEST_v0.2.2.md) and adds configurable damage/HP with default basic damage 10. [Changes](PR_v0.2.3.md), [scope/evidence/full test](PHASE_2_CHECKPOINT_1C_REPAIR.md). 337 Kahlua assertions, 18 modules, 85 native translation keys and 23 packet serializations pass. Native option loading, item transactions and 16 object write/read fixtures at 37/200 HP passed across fresh processes in 33.9/33.9 seconds. Real SP acceptance and vaulting remain pending. [Install evidence](../diagnostics/v0.2.3/local-release.json) verifies all 70 installed files against the tagged source and matching archive, plus all 70 previous-version backup files. The running 0.2.3 client remains unverified until restart/player testing. Documentation-only follow-up commits leave Contents identical to the tag. No remote or Workshop publication.

## Previous menu, servicing and bundle candidate

Version `0.2.2` combines the owner-requested Crafting category and readable descriptions with basic-barrier pickup/free repair and five-item bundles. [Changes](PR_v0.2.2.md), [scope/evidence/complete owner test](PHASE_2_CHECKPOINT_1C.md). Pickup/free repair take ten active seconds; recovery intentionally resets basic durability under the owner's explicit direction. Native pack/unpack transactions pass, and 299 Kahlua assertions cover menu/layout and guarded service behavior. Fresh write/read server processes passed in 38.0/36.6 seconds, restoring the same 16 native objects at 37 condition. Requested directional vaulting remains pending its native collision/animation prototype; 0.2.2 retains non-vaultable blocking. [Install evidence](../diagnostics/v0.2.2/local-release.json) verifies all 70 installed/tagged files, the matching [archive](../artifacts/OMHTT-0.2.2.zip), and all 66 previous-version backup files. The running 0.2.2 client is confirmed; acceptance failed as recorded in TEST_v0.2.2.md. Later documentation-only commits leave tagged Contents unchanged. The cumulative Workshop draft includes all unuploaded content; no upload baseline exists.

## Previous portable construction candidate

Version `0.2.1` combines the native persistence repair and P2C1b by owner request. [Changes](PR_v0.2.1.md), [scope/evidence/complete owner test](PHASE_2_CHECKPOINT_1B.md). Validation passes: 270 assertions, 14 runtime modules, 69 native translator keys, native material/item transactions and migration, 16 object streams restored across fresh processes (45.2/43.7 seconds), and native texture-pack parsing. Actual SP map streaming/rendering and player acceptance remain pending. The existing cumulative changelog has been merged under 0.2.1; there is still no successful Workshop upload baseline. [Installation evidence](../diagnostics/v0.2.1/local-release.json) verifies all 66 installed files against the exact tagged bytes, all 58 files in the 0.2.0.3 backup, and the matching [archive](../artifacts/OMHTT-0.2.1.zip). The [completed owner review](TEST_v0.2.1.md) confirms the running client, crafting/deployment and undamaged native restoration. Damage preservation and legacy migration remain unproven; two menu defects feed the 0.2.2 patch. Documentation/evidence-only commits may follow the gameplay tag with unchanged Contents. No remote push or Workshop upload occurred.

## Previous native construction candidate

Version `0.2.0.3` repairs category initialization, the native category translation filename and unnamed construction sprites. [Repair notes](PR_v0.2.0.3.md), [owner evidence](TEST_v0.2.0.2.md), [complete owner test](PHASE_2_CHECKPOINT_1.md#owner-test). No recipe eligibility or custom bypass changes. Validation: 254 Kahlua assertions, 13 modules, 64 native translator keys, real native SpriteConfig validity for eight thumpables, menu callback gates and 75 material combinations; isolated startup/save/shutdown passed (74.4 seconds). Native object persistence/rendering remains unverified; the smoke does not save and reload the eight fixture objects. [Installation evidence](../diagnostics/v0.2.0.3/local-release.json) verifies all 58 installed/tagged files, all 58 previous-version backup files and the matching [archive](../artifacts/OMHTT-0.2.0.3.zip). The retired IGUI.json was removed by the managed installer. Source tag: `test/v0.2.0.3` (7d53740); documentation/evidence-only commits may follow with unchanged Contents. The [completed owner review](TEST_v0.2.0.3.md) confirms the running client version and a partial SP construction pass. Six later native SpriteConfig warnings prevent persistence acceptance. No remote push or Workshop upload.

## Previous menu-visibility candidate

Version `0.2.0.2` fixes the exact-global visibility callback, supplies native UI metadata, refreshes cached recipe titles and exposes Spike Barrier under Carpentry and Turrets & Traps. Vanilla Build Cheat covers debug placement; no custom bypass was added. [Release notes](PR_v0.2.0.2.md), [previous owner-log review](TEST_v0.2.0.1.md), and [complete owner test](PHASE_2_CHECKPOINT_1.md#owner-test).

Validation: 244 assertions using native Kahlua and installed ISBuildPanel methods with controlled UI/logic objects; 13 runtime modules; 63 native translation keys. The isolated native B42.20.4 loader verifies one registered recipe, UI style and title refresh, reproduces rejection of the old dotted visibility callback, and accepts the corrected callback with simulated SP flags while rejecting disabled content and multiplayer. All 75 material combinations and insufficient/missing/dull/broken-tool cases pass. Native server startup, save and shutdown pass; no player connected. Native server icon rendering is unavailable, so icon-path/asset checks are static and visual acceptance remains pending. The final native smoke completed in 70.9 seconds. [Local installation evidence](../diagnostics/v0.2.0.2/local-release.json) verifies all 58 installed files against the manifest and exact annotated tag bytes (`test/v0.2.0.2`, f3f64d2), plus all 55 files in the full previous 0.2.0.1 backup. The [archive](../artifacts/OMHTT-0.2.0.2.zip) matches the manifest. The [owner test](TEST_v0.2.0.2.md) confirmed 0.2.0.2 loaded but failed category and construction checks. Documentation/evidence-only commits may follow without changing Contents; no remote push or Workshop upload occurred.

## Previous approved-recipe candidate

Version `0.2.0.1` replaces the temporary recipe with the owner-approved cutting tool, four interchangeable planks/spears and four binding units, Carpentry 1 and 10 base XP. The [checkpoint](PHASE_2_CHECKPOINT_1.md) contains the complete owner test; [release notes](PR_v0.2.0.1.md) track validation. Reinforcement remains scheduled at P2C2a with the approved 25 damage, not implemented in this package. [Installation evidence](../diagnostics/v0.2.0.1/local-release.json) verifies all 55 installed/tagged package files and the complete 55-file 0.2.0 backup. The [archive](../artifacts/OMHTT-0.2.0.1.zip) matches the manifest. Source is preserved at annotated tag `test/v0.2.0.1` (4b31951); documentation/evidence-only commits may follow with unchanged Contents. The [owner run](TEST_v0.2.0.1.md) confirms the client loaded 0.2.0.1 but reported a missing Building entry; recipe transactions and player acceptance remain pending. No remote push or Workshop upload occurred.

## Previous native construction candidate

Version `0.2.0` implements [Phase 2 checkpoint 1a](PHASE_2_CHECKPOINT_1.md): native Building-menu Spike Barriers, preview/rotation, a native material recipe, Sandbox toggles and construction diagnostics. [Release notes](PR_v0.2.0.md) distinguish implemented behavior from scheduled individual items and five-item packs. [Install evidence](../diagnostics/v0.2.0/local-release.json) records exact hashes, source tag and the full previous-version backup. The [archive](../artifacts/OMHTT-0.2.0.zip) contains the same 55 package files. The running client has not yet been confirmed to load 0.2.0; restart and owner testing remain required. No remote push or Workshop upload occurred; the first-release cumulative draft is retained.

## Previous directional footprint candidate

Version `0.1.6`: [checkpoint and prior-test review](PHASE_1_CHECKPOINT_2.md), [release notes](PR_v0.1.6.md), [manifest](../diagnostics/v0.1.6/manifest.json), [archive](../artifacts/OMHTT-0.1.6.zip). Uses numeric versioning and the stable [OMH.cmd](../OMH.cmd) menu. Source is preserved in a local annotated release tag before installation; no remote or Workshop item exists. The initial cumulative Workshop draft covers all unuploaded content, not just this patch. [Process and current tooling limits](RELEASE_TOOLS.md).

Local installation completed and all 44 installed files match both the manifest and exact Git-tag bytes. The prior 0.1.5 package backup also passes all 43 hashes. [Local release evidence](../diagnostics/v0.1.6/local-release.json) records source commits, archive hash and backup location. Tooling/documentation-only commits follow the gameplay tag; Contents are unchanged. The [completed owner test](TEST_v0.1.6.md) now verifies the client loaded 0.1.6 and records the remaining acceptance limits.

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
