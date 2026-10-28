# Development, Cloud planning, and official releases

Owner-approved 2026-10-07 (C96), amended 2026-10-09 (C108: mirror every update and versioned test findings), 2026-10-10 (C119: mandatory planning handoff) and 2026-10-28 (public visibility with collaborator-only pull requests). Repository: [PandizeLive/pz-mod-onemorehorde_turretsandtraps](https://github.com/PandizeLive/pz-mod-onemorehorde_turretsandtraps), public. This is the full project repository, not a separate documentation copy.

## Branches and versions

| Ref | Meaning |
| --- | --- |
| `dev` | Default branch; current integrated development and approved plans. Tests may still be pending. |
| `planning/<topic>` | Cloud documentation changes based on current `origin/dev`; PR into `dev`. |
| `codex/<topic>` or `feature/<topic>` | Local implementation based on current `origin/dev`; PR into `dev`. |
| `test/v<version>` | Immutable annotated snapshot of a local test build; not a publication claim. |
| `main` | Latest officially published release; created only after the first confirmed official Workshop content upload. |
| `v<version>` and GitHub Release | Exact released source snapshot, created after confirming the official Workshop upload. |

The initial default is `dev`. There is no official release or `main` branch yet. Keep numeric modversion values unchanged; [CURRENT_STATUS.md](CURRENT_STATUS.md) identifies the current development build. Do not rename/move historical test tags. Do not publish old development tags as GitHub Releases. Documentation-only commits need no package version bump or new test tag. Keep `dev` as the default after releases so planning still opens current work.

## Start every session

Read AGENTS.md, [Planning](PLANNING.md), [current status](CURRENT_STATUS.md), [decisions](DECISIONS.md), and [roadmap](ROADMAP.md). State the checked-out branch and commit. Fetch origin when available and inspect new `dev` commits and open development/planning PRs before editing. If the active checkpoint is unmerged, read its branch before reporting current status; do not equate an unchanged dev branch with no new work. Preserve local work and reconcile incoming decisions; never reset or force-push to make histories match. If the network is unavailable, state the last known commit and treat newer remote decisions as unknown.

Existing historical branches are retained locally. Start new work from updated `dev`; do not revive a historical branch without including newer development history. When resuming a branch, merge/reconcile `origin/dev` before mirroring. A push checkpoint makes only committed/pushed files available to Cloud; chat history, user-level skills, sibling repositories and the installed game do not become available through this repository.

## Cloud planning

Cloud may inspect all repository code and evidence, discuss features and tradeoffs, and edit planning Markdown in `docs/` and the README when needed. Use `planning/<topic>` from the latest `origin/dev`, record the base commit in the PR, and target `dev`. Cloud must not change Source, Contents, art/assets, tools, configuration, AGENTS.md, release evidence, test outcomes, or the Workshop changelog unless the owner explicitly expands that task's scope. This is an instruction boundary, not an access-control guarantee.

Keep proposals separate from owner-approved decisions. Approval requires the owner's actual statement; cite its date and scope in DECISIONS.md. An implementation claim needs code evidence; a verification claim needs the relevant test evidence. Mark uncertain engine feasibility as **needs local verification**. Do not infer implementation approval from discussion, a planning PR, or its merge.

Save decisions and acceptance criteria in the existing authoritative documents, not only in chat or a duplicate planning repository. Use CURRENT_STATUS.md as a concise index and handoff, not a second decision register. Planning PRs may contain unfinished proposals if plainly marked. C119 supplies standing authorization and requires committing/pushing every substantive planning discussion or approval before handoff, even without a gameplay patch. Update [Planning](PLANNING.md), its linked contract and decision provenance; use the existing matching PR where appropriate. Do not merge automatically without authorization.

To configure Codex Cloud, select this repository and `dev`, and direct the task to read AGENTS.md and CURRENT_STATUS.md first. No game runtime, publisher credentials, or native-test setup is required for planning. Repository creation does not itself configure or verify a Cloud environment or connector access. If the repository is missing from the picker, grant it access through the existing GitHub connection. A new Cloud task must use a fresh branch/checkpoint; existing task workspaces are not assumed to refresh automatically. The optional chat **OMH: Turrets & Traps - Planning** follows the same Planning record; its chat history is not a substitute for fetched repository evidence.

## Local implementation and checkpoint transfer

1. Fetch and review Cloud planning PRs. Merge approved documentation into `dev`, or bring the exact documentation changes into the active branch and reconcile with `dev`; keep proposals marked as proposals.
2. Implement only approved scope locally. Use current installed-game evidence and the available PZ skills. Source is canonical; rebuild generated Contents when gameplay changes.
3. Run the smallest meaningful checks and record actual results and remaining owner tests. Update CURRENT_STATUS.md and existing patch/release documents. Make no new pass or publication claims from Git operations.
4. Commit intended files and run **OMH.cmd -Action Mirror** after every completed project update. C108 supplies standing authorization: do not leave updates local waiting for another push request. Include code, approved decisions, patch/release records and the current immutable test tag when eligible. Documentation-only updates require no gameplay version bump.
5. Mirror from `dev` to update the shared checkpoint, or from a short-lived branch to push and create/update a draft PR into `dev`. Review/merge when authorized; standing push authorization does not automatically merge. Tell Cloud the PR branch if it needs unmerged work; otherwise it reads `dev`. Verify the remote commit before reporting synchronization. If blocked, report the exact failure and outstanding local commits.
6. After every owner test, inspect console.txt and update `docs/TEST_v<version>.md` (or that version's existing acceptance record), preserving the date, tested version, findings and evidence limitations. Keep automated checks in the associated release/diagnostic records and link them from current status. Commit and mirror these findings promptly, even without a new patch. Distinguish passed, failed, tentative owner-reported, pending and waived outcomes; never promote untested behavior to passed. Keep historical findings attached to their tested version. Raw captures stay local unless deliberately reviewed and selected for public disclosure; the readable findings and relevant evidence references must be on GitHub. Maintain the development PR description with links to Planning, versioned findings and pending acceptance. Every substantive planning turn must update the same shared records even if no test ran; do not fabricate a test entry for a discussion.

The mirror validates exact origin fetch/push URLs and a clean working tree. Local `-ValidateOnly` makes no network calls. A live mirror checks repository identity, the configured visibility (`public`) and default branch, fetches `dev`, and requires its history to be included locally. It never merges, force-pushes, writes `main`, creates an official tag/Release, or uploads to Workshop. It atomically pushes the current branch and, when applicable, its existing annotated test tag. A test tag is included only if it is an ancestor of HEAD and Source/Contents match it. Untagged development checkpoints are allowed. Existing PR titles/bodies/review state are preserved; the script creates a draft with Planning/current-status links only when there is no matching PR. Updating the existing PR Planning section remains part of the agent handoff.

Use `OMH.cmd -Action Mirror -ValidateOnly` for local preflight. Authentication uses the existing shared GitHub CLI/configuration on the PC, or an installed authenticated `gh` elsewhere. Never commit credentials.

New diagnostics caches and packaged ZIPs stay local by default; previously tracked evidence/history remains tracked. Explicitly add only selected new evidence (`git add -f` when necessary) after inspecting its contents. Current code/assets/docs/tools remain in the repository. A fresh Cloud clone cannot run game-dependent probes without the installed runtime; missing ZIPs/caches are not test failures or evidence of a release.

## Official release promotion

The following procedure requires separately authorized release work. Do not execute it during ordinary development or Cloud planning.

1. Choose the exact tested candidate commit, preserve its immutable `test/v<version>` tag and package manifest, and verify the approved release scope and acceptance evidence.
2. Upload that exact package to the intended Workshop item through the authorized publisher. Record the item ID, version, source commit, package hashes, time and successful upload evidence in RELEASE.md. A failed, cancelled, preview-only or unverified upload cannot promote a release. Private test uploads remain development uploads unless explicitly designated an official release by the owner.
3. Create immutable annotated `v<version>` at the exact uploaded source commit. Create/update `main` to that released snapshot and associated release documentation, without bringing newer unfinished development into it. For later releases use a reviewed release PR into `main`; preserve release records when reconciling histories.
4. Create the GitHub Release from the already-existing official tag (use `--verify-tag` with the CLI), with truthful scope and Workshop evidence. Do not allow the UI/CLI to invent a tag at a newer `dev` commit. If GitHub publication fails after a successful Workshop upload, record the partial state and retry the same snapshot; do not upload again merely to fix GitHub.
5. Reconcile the release record back into `dev`. Advance the changelog baseline only for the exact confirmed content upload. Preserve notes for any changes made after that uploaded snapshot.

The repository/workflow setup does not authorize a first Workshop upload, define a release version, waive the 0.2.30 owner test, or enable multiplayer.


## C119 pipeline verification (2026-10-10)

The existing isolated GitHub workflow suite passes all eight preflight scenarios and confirms no remote refs are changed by preflight. Coverage includes development/tagged/documentation checkpoints, dirty or untracked work, wrong destinations, protected release branches and changed-source tag exclusion. Restricted-shell fixture execution was blocked by local permissions; the same suite passed with authorized execution and a workspace-local temporary directory. Planning relative file links resolve. This is tooling/documentation verification, not gameplay or owner acceptance. The live mirror must still verify the remote commit before handoff.

## Public visibility and collaborator-only pull requests (2026-10-28)

The owner explicitly requested applying the public-visibility/collaborator-only recommendation. GitHub PATCH responses and separate unauthenticated GET requests confirm these settings on both `PandizeLive/pz-mod-onemorehorde_turretsandtraps` and `PandizeLive/pz-mod-onemorehorde_traitshop`:

- `visibility: public`, `private: false`.
- `has_pull_requests: true`, `pull_request_creation_policy: collaborators_only`.
- Existing issues remain enabled and Discussions remain disabled. T&T retains `dev`; Trait Shop retains `main` as its default branch. Collaborator membership and licenses were not changed.

Public readers can inspect/download/fork the repositories. Only invited collaborators can create pull requests; visibility does not grant write access. Existing development pull requests remain enabled. These repository settings do not promote a game build or change Steam Workshop visibility.

Before changing visibility, fetched the latest remote branches/tags and scanned all locally available Git history using checksum-verified Gitleaks 8.30.1 with its default rules and redacted output. Trait Shop: 45 commits, no findings. T&T: 603 commits, 112 generic-key matches reviewed in their original committed files: 111 SHA-256 manifest entries and one ordinary battery-test phrase (`insufficient/exhausted/withdrawn`). No credential was identified by this scan; this is a bounded automated check, not a guarantee about every asset or external attachment. Local scan evidence stays under the workspace `.tmp/github-public-20261028/` directory.

`tools/github-process.json` now declares the expected public visibility. The mirror validates that setting alongside the exact repository identity and default branch. Eight existing isolated preflight scenarios and the no-network assertion pass. Four additional checks exercise the actual guard: matching public metadata succeeds; private visibility, wrong repository and wrong default branch fail. The same metadata request and guard also pass against live GitHub. Existing uncommitted `docs/AMMO_UI_C446.md` work and concurrent gameplay changes remain untouched and prevent mirroring from the active checkout. This access-settings task does not absorb or publish those edits.


## C495 - committed mirroring with local documentation edits (2026-10-28)

The owner reported the CMD mirror refusal after a successful install. The clean-tree gate was unnecessarily treating unfinished tracked planning text as an unpublished build. Ordinary modified tracked `AGENTS.md`, `README.md` and Markdown under `docs/` may now remain local with an explicit filename warning. Only existing commits are mirrored. No auto-commit, stash, reset or file mutation is performed. New/untracked files, additions, deletions, renames and source/package/tool changes still block, and the exact destination/default-branch/visibility/tag checks are retained.

Fifteen isolated preflight cases pass, including retained document contents/index state, source/version and tool-edit rejection, untracked/staged additions and deletions, destination and release-branch protection, and unchanged test-tag selection. The suite confirms no remote refs were changed. The restricted PowerShell environment prevented the first fixture run; the same local-only suite passed with authorized execution. Live mirror evidence is recorded after the actual CMD run. This is tooling only; 0.2.70.3 gameplay and Workshop state are unchanged.
