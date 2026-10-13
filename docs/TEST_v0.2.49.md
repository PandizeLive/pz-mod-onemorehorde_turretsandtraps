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
