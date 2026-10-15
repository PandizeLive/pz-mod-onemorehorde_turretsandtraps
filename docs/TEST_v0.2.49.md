# 0.2.49 verification and focused owner test

Automated:16,574 Kahlua assertions;120 Lua/translation files compile;220 source files/268 packaged files validated. New tests cover Ballista accuracy/power/feed-module math, rotary sector crossings/reversal/independent arms, actual bounded scheduler contact, motor accounting, power-off/exhaustion, off-time exclusion, player exemptions/injury guard, and150-ms/250-ms pack timing. Existing module, transfer, trap and resource tests pass. Mock timings are not engine performance measurements.

Native B42.21.0 stock-first probes pass in fresh write/read processes. Three new recipes actually consume their selected inputs and retain tools; outputs/timing/spear feed/inactive stored modules and three native sound definitions verify. New heads preserve exact type, condition and modData through native item serialization across processes. Existing base/contents/traps persistence probes also pass. Native logs retain known stock world-property warnings; these are not counted as mod failures. Sound registry checks do not prove audible timing. All three package selections pass independently (Traps48.2s/Turrets45.8s/both46.8s).

Source: diagnostics/v0.2.49/validation.log, server-write.log, server-read.log, packages-*.json and manifest.json. Native smoke fixtures exercise SP logic in an isolated server harness; this does not certify multiplayer. Owner client console has not yet been reviewed for this version. No owner test has passed by implication.

Installed from immutable test/v0.2.49 /9cc84c0 using root OMH.cmd. All268 files match, both0.2.48.1 backups pass, and the local archive is verified. [Proof](../diagnostics/v0.2.49/local-release.json).

## Short owner test

1. Restart into the fresh test world and confirm **0.2.49**. Check all three head recipes under **OMH: Turrets > Heads**; Ballista includes eight nails.
2. Install Ballista, battery and a few **Crafted Spears**. Fire at nearby/farther zombies; check ammo use, sound and six-second baseline cadence. Modules/charge change the baseline normally.
3. Try both rotary heads with Firing+Detection and battery. Without360, zombies in the front/rear sectors can be hit while the sides remain safe; with360, both arms rotate and sides can be hit. Listen for impact sounds.
4. Turn a rotary off: motion/damage/drain stop. On a disposable character with protections off, briefly cross a moving Bat then Blades: minor limb injury versus a laceration, without per-frame injury. God/NoClip should exempt you.
5. Pickup/reinstall a loaded head/base, then save/reload: contents/charge persist and the powered-off turret stays stopped. Open one Module Pack: bottom finishes last; rarity cue leads its stop slightly.
6. Report any visual mismatch, silence, wrong contact or lag. I will inspect **console.txt** against the loaded version; there is no additional old-content test list.

Final weapon art and GPU strike alignment are pending. Technical cubes indicate mechanism motion, not final blade/bat proportions. R3C2 remains open until the focused rendered test; R1C3/R3C7 broader load/endurance remain separate.

## C208 owner availability (2026-10-13)

Owner cannot test now. Focused client test is deferred, not passed, failed or waived. No new console result is claimed. Keep the existing short test for when the owner is available; do not request immediate play.


## C224 partial owner findings and console review (2026-10-13)

Owner reports Ballista limited to44 spears and bullet-like firing. Requests rotary90-degree front/rear coverage and longer reach, Ballista narrower FOV/longer range/travelling spear. This supersedes the earlier no-client-feedback status for these findings only; no claim that other checks passed.

Read current console.txt:0.2.49 SP diagnostics,242156-byte captured snapshot; hash/time in [metadata](../diagnostics/head-feedback-c224/console-metadata.json), relevant records in [filtered console](../diagnostics/head-feedback-c224/console-findings.txt). TransferFull appears both for ordinary transfer validation and Manage ammo transfer; later ammo43/loaded1 is consistent with the report. Native Crafted Spear weight2 and configured100-weight storage support a weight-limit diagnosis, not a44-round magazine limit. Exact inventory weights were not captured. Source explicitly disables Ballista projectile travel and marks its effects firearm=true, confirming the presentation finding. No new runtime exception attributable to OMHTT was identified in the inspected error/exception lines; stock world/tile errors are present, so do not call the whole log clean or certify unrelated mods.

No fixes implemented, no new tests run, no install. Rotaries' wider sectors/reach are requested balance revisions, not a claim that the earlier approved45-degree/1.25-tile implementation malfunctioned. Full0.2.49 acceptance remains open without another immediate test request.


## C244 development verification; installed test unchanged (2026-10-14)

Uninstalled development source after the immutable 0.2.49 test tag passes 20,141 assertions, 142 Lua/translation compilations and 238-source/290-package parity checks. Stock dedicated-server probes cover native ownerless damage/death and paired Spike Barrier construction/services alongside existing turret/Bed/Concertina services. No clients connected; synthetic-square fixtures do not prove mapped removal or combat ownership handoff. [Full findings and unresolved combat cases](PATCH_C244_PROGRESS.md). The installed 0.2.49 owner test and its original evidence are unchanged; this is not owner acceptance or a multiplayer-ready release.


## C245 — uninstalled multiplayer development verification (2026-10-14)

No owner test or 0.2.49 acceptance change. [C245](PATCH_C245_PROGRESS.md):20,216 assertions;142 Lua/translation compilations;808 native translation keys;238 source/290 packaged files. Stock dedicated-server native lifecycle/loot callbacks pass with zero clients. Native remote ownership, packet ordering, corpse transport and mapped-world removal remain unverified. The corrected harness rejects mod callback exceptions; prior fixture failures are retained and C244 construction evidence is qualified. No new test tag or installation.

The broader stock native write and read/restart regression suite also passes (67.3s/70.8s, zero clients). It covers existing native serialization, traps, firearms/ammo, packs, collision/visibility, recipes, accuracy and sound registrations; SP-emulated checks are not MP certification. The initial nested-output-path fixture failure was repaired and retained as failed evidence. See C245 for exact paths and limitations.

C245 continued in the same approved turn: multiplayer craft-first/repeat Building now waits for native inventory replication. Final 20,227-assertion run passes (`diagnostics/c245-multiplayer/building-validation-console.log`), including delayed output/removal, duplicate completion, cancellation and timeout fixtures. Earlier 20,216/native results remain historical evidence; no connected client or installed-build acceptance is added. Native ownership API inspection rules out a health-sync/ownership-lock shortcut; see C245 findings.


## C246 development-source verification (2026-10-14)

[Multiplayer implementation and complete evidence](PATCH_C246_MULTIPLAYER.md): 20,319 assertions; 161 compilations; native zero-client production firing/services; write/read persistence; three independent package selections; 462 Horde assertions. These test the uninstalled development source, not immutable test/v0.2.49 or a new owner session. Connected dedicated/listen acceptance is pending. No new owner console result is asserted.
