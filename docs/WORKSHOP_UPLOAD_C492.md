# C492 - Native first upload and unlisted CMD updates

2026-10-27. The owner requests a T&T equivalent of `OMH_TraitShop.cmd`, then explicitly selects this sequence: stage under `C:\Users\bandi\Zomboid\Workshop`, initialize the upload through Zomboid, and use the CMD for subsequent updates. The owner supplies `OMH/Images/Traps & Turrets/punjabistill.png` as the still. This authorizes local tooling and staging; the owner performs the first external upload. No official release, gameplay change, promotional redesign or sibling change is included.

## Ready locally

- Launcher: [OMH_TurretsAndTraps.cmd](../OMH_TurretsAndTraps.cmd). Existing [OMH.cmd](../OMH.cmd) opens the same menu.
- Native stage: `C:\Users\bandi\Zomboid\Workshop\OneMoreHorde_TurretsAndTraps`.
- Version: **0.2.70.2**, from immutable `test/v0.2.70.2`, source commit `42822d3a78a69f8b31ed1719db933196a23b6aa3`.
- Both independent packages are present, with all **614 content files** hash-verified against the tagged project content. Local installed mods and saves were not changed.
- `workshop.txt` was staged with an empty ID and `visibility=unlisted`; the native uploader has since assigned **3828638252**. Initial copy says development multiplayer testing is in progress; it does not claim connected acceptance.
- `preview.png` is a 512x512 export of the owner's 400x401 still, fitted without cropping. The original is unchanged. No AI artwork or new design was used.

In Zomboid, open **Workshop > Create/Update Items**, select **OneMoreHorde_TurretsAndTraps**, verify **Unlisted**, and complete the upload. The game writes its assigned ID into the staged `workshop.txt`. A returned ID alone proves neither content success nor the changelog baseline. The owner subsequently confirmed that Zomboid completed the upload for this exact ID, establishing the first content baseline.

## Subsequent updates

Menu **5** checks Workshop readiness offline. Menu **3** updates the existing item after an explicit `UPDATE` confirmation and normal Steam login/Guard prompts. Close Project Zomboid first. The updater reads the game-created ID automatically. It cannot create a new item, rejects known sibling IDs and conflicting project/staging IDs, and records the learned ID in the project's `workshop.txt` after a confirmed update. Commit that identity before the following update.

Updates send content, cumulative change notes and Unlisted visibility only. Title, description, tags and preview are omitted, preserving the Steam page. The initial still remains in place; changing it to the existing animated cover can be separate work if requested.

Menu **6 > 1** refreshes the native staging folder; **6 > 2** checks staging without changes; **6 > 3** retains diagnostic capture. Existing staged ID, text and preview are preserved. Managed content is checked before replacement; unmanaged/modified content refuses rather than discarding it. Restaging saves the complete old folder in project diagnostics and restores it if replacement fails. The local install action retains its existing behavior.

CLI equivalents:

```powershell
.\OMH_TurretsAndTraps.cmd -Action Info
.\OMH_TurretsAndTraps.cmd -Action Stage -ValidateOnly
.\OMH_TurretsAndTraps.cmd -Action Stage
.\OMH_TurretsAndTraps.cmd -Action Publish -ValidateOnly
.\OMH_TurretsAndTraps.cmd -Action Publish
```

## Evidence and persistence

Live updates require committed release inputs, an annotated ancestor test tag and unchanged tagged Source/Contents. No official tag, main-branch promotion or remote mirror is manufactured to permit a development upload. T&T's own prior menu had no publisher or GitHub prerequisite for Workshop uploads; Trait Shop's official-tag/remote-release gate was not copied into this development workflow. C108's independent mirror requirement remains in effect and its existing blockers remain recorded.

The Steam transport is copied from Trait Shop into this project, with its existing DPAPI credential storage and password/Guard log redaction. Credentials use the distinct `%LOCALAPPDATA%\OMH\TurretsAndTrapsPublisher` directory; no credential was read, created or requested during preparation. No runtime dependency on Trait Shop is added.

Each upload uses a hash-checked snapshot under `diagnostics/workshop/upload-*`, preserving the exact change note, content hashes, source/tooling commits, VDF, sanitized log and result receipt. Only Steam's success confirmation produces a confirmed receipt and an entry in [RELEASE.md](RELEASE.md). Failure or cancellation cannot clear notes or advance the baseline. `WORKSHOP_CHANGELOG.txt` stays untouched; its existing cumulative draft must survive the first in-game upload until that exact upload is confirmed and documented. Unlisted test uploads remain developmental unless separately designated official.

## Verification

- Windows PowerShell fixture suite: **15 grouped checks pass**, covering read-only preflight, both-package staging, native-ID handoff, metadata preservation, sibling/zero/malformed/overflow/conflicting IDs, changed/untracked content, unmanaged/edited stages, rollback, concurrent native metadata edits, cancellation, frozen snapshots, successful bookkeeping and failed-upload baseline preservation. Steam calls are stubbed in an isolated fixture; **zero real Steam calls**.
- Installed **42.21.0** `SteamWorkshopItem.readWorkshopTxt`, `validateContents` and `getVisibilityInteger` pass on the actual staged folder. This validates the PNG, native upload layout and visibility value **3**; it is not a Steam upload or connected-player test. Probe: [NativeWorkshopCheck.java](../tools/NativeWorkshopCheck.java).
- Installed `media/lua/client/OptionScreens/WorkshopSubmitScreen.lua` explicitly exposes Unlisted and reads/writes the item ID/visibility. Current installed Java requires a square 256px or 512px PNG, at most 1,024,000 bytes. The supplied still needed only a native-compatible export.
- Valve's [visibility enum](https://partner.steamgames.com/doc/api/isteamremotestorage#ERemoteStoragePublishedFileVisibility) confirms Unlisted = 3: accessible to everyone but excluded from global queries.
- CMD Info and pending-first-upload behavior verified through the actual named launcher. Native validation ran without calling `create` or `submitUpdate`.
- Early shell checks exposed inherited PowerShell module resolution; the shared helper now imports Windows PowerShell Utility/Security by their absolute built-in paths. The fixture suite was rerun after correction. Windows execution-policy failures in fixture wrapper scripts were corrected to use the same Bypass invocation as the launcher; failure-path tests now assert the injected failure message, rather than accepting any nonzero exit. The installer fixture no longer overwrites historical 0.2.29 evidence. A probe command's initially unquoted Java `-D` argument was corrected; the successful native result above is the completed run.

Source cover SHA-256: `9fc87eeeb79ec611f01199c5a03b3f71161da4be4697ef2cd16b289cadcc6c24`. Export: `b0e1f96dfb2d1a94372d81c4a2e49d084d8eaac33af94ba4976b11c100c19a31`. Changelog remains `e3272a3bb4d410e9e8eba1e759f328131f4675ac2ce7b3f0bbf514aa265775d6`.

Working branch at start: `codex/performance-barbed-audit`, HEAD `5c030c3`. Read-only origin/dev fetch failed with `getaddrinfo() thread failed to start`; newer remote state is unknown. Pre-existing owner edits in `docs/AMMO_UI_C446.md` remain byte-identical, SHA-256 `24506649c189a6e0b9f9e7fd04ab53fba940d3741a79ec38c267b75b75207fba`. Prior automatic approval review blocked the private mirror pending destination/payload authorization; no bypass or retry of that rejected upload was attempted.

**Test now: connected multiplayer through the unlisted Workshop item.** Connected multiplayer acceptance and C488 deployment remain pending. The owner completed the initial native upload; the CMD performed only offline preflight against the real item.


## Confirmed first content upload

The owner explicitly answered **Yes, upload completed** when asked whether Zomboid reported a successful upload for item **3828638252**, on 2026-10-27 (America/Indianapolis). Staged metadata and all 614 content hashes were read back after confirmation; they match 0.2.70.2 / `test/v0.2.70.2` / `42822d3a78a69f8b31ed1719db933196a23b6aa3`. Staged metadata says Unlisted. The native metadata, including owner-edited description and tags, was copied into project `workshop.txt`; future updates preserve the remote page. No Steam credentials or upload were invoked by Codex.

Tracked confirmation: [c492-workshop-upload.json](evidence/c492-workshop-upload.json). Full machine-readable evidence: `diagnostics/workshop/native-v0.2.70.2-3828638252/upload-result.json`, alongside the native metadata and the preserved local cumulative draft. The native change-note text was not captured; the draft snapshot is not represented as the actual Steam change note. Public web retrieval was unavailable, so content success is explicitly owner-confirmed rather than independently verified remotely. This confirmed content upload establishes this item's baseline; keep the current draft until a subsequent change starts a new draft, preserving anything changed after this exact snapshot. No official tag, GitHub Release or main promotion.

The installed local mod folders still coexist with the Workshop subscription. Use one copy of each mod when testing, and establish 0.2.70.2 on the server and both clients. No local copies, saves or enabled-mod selections were removed.
