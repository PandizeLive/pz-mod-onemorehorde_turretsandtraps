# GitHub workflow setup evidence

2026-10-07, owner authorization C96.

- Created and verified private repository [PandizeLive/pz-mod-onemorehorde_turretsandtraps](https://github.com/PandizeLive/pz-mod-onemorehorde_turretsandtraps).
- Initial shared checkpoint: `10c0d7f8f63edfc80f707483356d7d47793f6fc0`, on `dev`; uploaded with the existing reachable history and all 39 immutable annotated `test/v...` tags. The PC's previous working branches remain intact locally.
- GitHub metadata confirms `dev` as default. The remote branch listing contains only `dev`; GitHub Releases listing is empty. No `main` or official `v...` tag was created.
- Nine development-mirror preflight checks passed in disposable repositories on Windows PowerShell 5.1: untagged and tagged checkpoints, untracked/dirty-file refusals, documentation commits after the test tag, wrong push destination, official-branch refusal, changed source omitting an older test tag, and unchanged remote refs during preflights.
- Actual project mirror preflight passed before upload. Initial push was atomic; remote `dev` matched the local checkpoint. A history scan covered 2,226 blobs for common credential patterns (no matches after excluding embedded-audio substring false positives); largest blob was approximately 4.4 MB. This is a scoped check, not proof that no sensitive data of any kind exists.
- `git diff 01e67a3 HEAD -- Source Contents WORKSHOP_CHANGELOG.txt` was empty after the workflow commit. Package code/assets, gameplay version, installed game and pending Workshop notes were not changed. Native/gameplay tests were not rerun for this process change.
- Cloud connection remains unverified: the connected GitHub plugin returned 404 for this private repository and lists only an installation under a different account. The authenticated local GitHub CLI uses PandizeLive and successfully created/pushed/read the repository. Connect/authorize the PandizeLive repository in the intended Cloud GitHub connection, then select `dev`. No access was granted to another person or account as a workaround.

Follow [GITHUB_WORKFLOW.md](GITHUB_WORKFLOW.md). Repository creation and successful Git pushes do not establish Cloud environment readiness or Workshop publication.

## Connection and process recheck, 2026-10-07 (C97)

- Fetched origin/dev; local dev and remote matched `5fc64467873ea81404927882cdeb5b07d2e1c50a` before the audit branch was created.
- Authenticated CLI and connected GitHub app both returned the private repository with default branch dev. The app successfully fetched `docs/CURRENT_STATUS.md` from dev (blob `18ff514455595cbcfbb5cea2f0418a2d75a2ca06`). The earlier connector-access failure above is resolved. This proves repository/content access, not execution of a Cloud task or planning PR.
- GitHub Actions API returned zero configured workflows; recent run listing was empty. The approved pipeline is the documented planning/implementation/mirroring/release process, not an automated GitHub CI build.
- Reran all nine existing mirror preflight checks successfully in disposable repositories under Windows PowerShell 5.1. Initial sandbox attempts failed on temporary-directory permissions and child PowerShell policy; rerun with approved local execution and process-scoped policy passed. No test logic changed and no network operation occurs in these preflights.
- Root `OMH.cmd -Action Mirror -ValidateOnly` passed at the unchanged dev checkpoint and included the existing test tag. No push, PR, merge, official release or Workshop upload was performed during this recheck.
