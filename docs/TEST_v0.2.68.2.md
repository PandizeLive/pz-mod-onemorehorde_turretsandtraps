# 0.2.68.2 - Verification

2026-10-25, C471. Installed and verified; focused owner acceptance remains pending.

## Evidence

- Installed42.21 native actor reproduces the debug spawner sequence:3.7health at OnZombieCreate, then1.0finalhealth. Twelve Initial Blow modules on a20damage Arc hit now remove0.74actual health; second hit does not receive Initial Blow. Execute classifies0.18health at an established1.0baseline, excludes0.1801, and returns remaining health for the finishing blow.
- Installed Kahlua production-code tests cover0-16stacks, saved10/1 and zero overrides, queue ownership/nearest/full-host/no-steal behavior, stale private rows, tether direction/blocking/expiry/simulation ownership and exact kit selection. Final assertion total and native results are appended below.
- Horde settings/persistence/defense/score suite:610assertions pass with both generated package defaults. Tooltip no longer combines T&T and Trait Shop reductions.
- Native headless tests cannot establish rendered icon/glow or connected multiplayer acceptance. No owner save is modified. No Workshop publication or hosted LootLab changes.

## Owner checklist

- Initial Blow on fresh zombies
- Execute finishing threshold
- Specialist icon size
- Controller placement and privacy
- Automatic own-device assignments
- Stacked expansion-kit replacement
- Tether push, pull, reset
- Opposite-side Barbed Panels
- Storage Usage meter

Existing custom Execute/tether Sandbox values remain unchanged. Use18/2when checking the selected new Execute defaults. Rendered and connected-player acceptance remains pending.

## Final automated verification

- Final validator:27,889 assertions,439source files,600packaged files,399checked translation keys. All shipped Lua compiles in installed42.21Kahlua; no banned-call or package mismatch found.
- Native write97.8s/fresh-process read99.0s pass. Baseline1.0survives actual zombie binary serialization. Native reload itself regenerates the fixture health to2.05318/2.09838; the production baseline now expands for observed health above a known maximum and never shrinks with damage. Tests do not claim native zombie health itself stays at the saved0.5.
- Native bathroom/street/outdoor-light sprites with BlocksPlacement reject Controller placement; removing the obstruction restores validity. Native tether pending movement points away on impact and toward the muzzle on pull, without setting world coordinates. Full rendered movement and connected-owner transport remain pending.
- Native own-device assignment passes after the intentionally paused zero-player fixture is temporarily unpaused. Production remains pause-aware. Test fixes also provide a nonempty native player username and wait for queued assignment instead of expecting synchronous completion.
- Opposite panels on one north wall retain distinct identities and correct contact on both sides. Both survive native object serialization, fresh-process reload and removal of only one face; backing health stays137 and remains thumpable. This does not reproduce or close the owner's particular rendered failure. No speculative barb gameplay change shipped.
- Traps-only92.3s, Turrets-only94.6s, combined98.2s startup/save/shutdown pass. The final known-baseline expansion was followed by repeat Turrets-only92.7s and full combined native write/read, in addition to final validation. Shared Traps payload is unaffected by that last Turrets-only adjustment.
- The earlier failed character-persistence fixture omitted the native moving-object factory header and assumed native loading retained wounded health. Corrected those test assumptions; retained the actual observed native health change in evidence instead of hiding it. The initial headless icon check was removed because this server lacks client textures; rendered icon acceptance remains pending.

Evidence: diagnostics/v0.2.68.2/validation.log, manifest.json, server-write.log, server-read.log and packages-*.json; diagnostics/c471 contains intermediate runs. No owner live pass, connected multiplayer pass, real FPS measurement or Workshop upload is inferred.

## Tagged installation

Installed0.2.68.2from immutable test/v0.2.68.2 /9c1eb4af943626dd4b27742055fd68795d7ef87b. All439source files and600package/tag/install/archive files match SHA-256. Both0.2.68.1backups verify:227Traps files and369Turrets files. Backup: diagnostics/p1c1/install-backups/20261025-230801-5552. Archive: artifacts/OMHTT-0.2.68.2.zip; SHA-256 bd748c4125b90d9101f361d5ca367508885fa18fd809213f7d67fc61b0fb8735.

Horde/Cure0.6.16.8is installed from its immutable6350799tagged source; Trait Shop0.9.1.1is unchanged. All sibling package files match local mods and Workshop staging. C108 development mirroring uses the existing T&T branch/PR1; Horde remote updates remain manual through its OMH.cmd. No Workshop publication, hosted loot update, save edit or live-run flag reset. Owner edit docs/AMMO_UI_C446.md retains SHA-25624506649c189a6e0b9f9e7fd04ab53fba940d3741a79ec38c267b75b75207fbaand is excluded from commits.

**Test now (single-player), after restarting.** Use fresh zombies for conditional damage; existing saved Execute/tether values remain unchanged. Opposite panels and icon appearance still need the rendered owner retest. Connected multiplayer remains deferred as requested.

## C472 - Owner feedback, 2026-10-26

Owner reports wrong Specialist artwork, stale stockpile list, questionable management-ring alignment and tether displacement without a shove animation. Displacement is owner-observed working; animation/icon/stockpile are not accepted. Ring mismatch remains unverified. See [diagnosis and proposed scope](FEEDBACK_C468.md#c472---rendered-feedback-and-assistance-policy-review-2026-10-26). Current console confirms0.2.68.2 and later Execute18/2. No new automated gameplay checks or connected-MP result; no full test completion or Execute/Initial Blow acceptance inferred.
