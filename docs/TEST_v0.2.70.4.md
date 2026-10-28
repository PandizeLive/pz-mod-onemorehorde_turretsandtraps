# 0.2.70.4 verification

Approved scope: [C500 patch](PATCH_v0.2.70.4.md).

## Automated and native evidence

- Full foundation validation: 37,150 assertions;448 source files and616 packaged files. Source/package manifests are in diagnostics/v0.2.70.4. Simulated players, network and UI objects do not establish connected acceptance.
- Ammo deposit/removal regressions reject any full equipment refresh and retain the existing target/fire deadline. Existing exact-item permissions, stale-transfer rejection and100-item transfer lifecycle checks continue to pass.
- Owner-receipt regressions retain duplicate/ownership-change protection and verify native corpse completion follows a lethal result. Corpse-loot regression forces an error if an early world-container packet is attempted; one death still rolls only one pack.
- Empty-warning regression covers100 concurrent attempts sharing one limiter, one-second cadence, snap/fade/pause, one reused native light, matching alpha/intensity, no distant lights, refill cleanup, visibility expiry and player-option cleanup.
- Installed42.21 native authority proof reproduces Kill leaving corpse creation unfinished, verifies die creates exactly one corpse and removes the live actor, verifies inventory preservation and production lethal completion, and exercises native lamp add/color/disable/remove and marker alpha. Final proof also uses the real OnZombieDead module-pack hook. Native network transport is inspected in the installed bytecode; no clients connect to these probes.
- First native probe placed the test pack before native kill inventory generation, which correctly replaced it. The corrected probe checks the actual post-generation death-hook timing; this fixture correction did not require a gameplay workaround.
- Native persistence/package results and installation hashes are recorded below after completion. Owner-rendered light quality, death animation, observer corpse visibility and no-longer-stalled firing remain pending live multiplayer acceptance.

## Owner checklist

Upload0.2.70.4 using the CMD, then restart/update the server and both clients. Local installation does not update Steam. No new world required.

- Turret and trap finishing blows
- Corpse visibility and loot on both clients
- Loading ammunition while firing
- Empty click, fading amber light, and refill


Native save/write **96.0s**, fresh-process read **90.3s**, Traps **76.0s**, Turrets **84.5s**, combined **68.3s** pass. Final authority probe with real death-hook loot also passes. All native probes had zero clients. Sanitized evidence: [C500 verification](evidence/c500-verification.json); raw native log copied to diagnostics/v0.2.70.4/native-combat-authority.log.
