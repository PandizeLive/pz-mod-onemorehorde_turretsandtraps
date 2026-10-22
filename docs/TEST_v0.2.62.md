# 0.2.62 owner test and evidence

Status: automated/native validation passed; tagged installation pending. Owner rendered/live multiplayer acceptance is pending.

1. Restart and confirm **0.2.62** in the developer menu. Check Sandbox: Controller range 40, laser range 10, standby 7/1 seconds, separate friendly/hostile multipliers, and head/trap headings. Existing saved values remain authoritative.
2. Open Controller, resize and scroll Connections, collapse a linked group, drag/reassign devices and use right-click **Assign to Group**. Check fixed Add Group, hidden collapsed cables, clipped labels, and **Controller Settings** after selecting a device.
3. Connect a Lever and sensor to one defense. OFF must block the sensor; ON must allow it. Test two Levers (both ON required), power loss/restoration, switch sounds and all four wall orientations. Laser should show green clear/red interrupted and no device range slider.
4. On a Detection-equipped turret, leave no target for seven seconds. Check lowered head/amber marker/deactivate sound, one-second wake and alert only at completion. Remove the target during wake; it should sleep immediately. Check manual operation and a turret without Detection, including power off/on.
5. Fire Tether past/in front of zombies and walls from four orientations. Check fast launch, impact, 0.75-second hold, falling nail/reeling, world depth and reset sound. Listen to Poke/rotary cues and check pause/resume. Report the face/zoom when alignment looks wrong.
6. Inspect Poke, reinforced Bed Spikes and other device tips; check repair material/tool/time. Inspect Performance/Expansion icons in inventory and Manage. Change an effective rarity in Sandbox, then hover/draw an existing item: tooltip and artwork should agree. Confirm other categories retain their art.
7. Compare friendly and hostile turret injury with server PvP rules enabled, then repeat with safety/non-PvP protection and armor. Check wounds/damage separately. With a second client, verify signals, state markers, wake audio and injuries arrive once; save/restart with devices linked. Send console.txt after testing.

## Evidence and limits

The Kahlua suite includes standby boundary/abort/bypass/busy checks, separate relationship multipliers, fixed-range defaults/bounds, falling-nail message validation, cached rarity-art changes, compact descriptions for all device families, existing Controller/native-window tests, Horde Night authorization, packet validation and resource conservation. Model imports use the installed 42.21 native mesh converter. Independent package validation checks Lua closure, unique Sandbox identities and all custom visual model/texture dependencies.

Development failures caught before installation: missing technical-item family prefixes; a test-double head missing native item modData; stale rarity-audio test settings after live rarity refresh was introduced; an unintended Tether reset-default change, restored to the existing 0.4 seconds. Failed runs are not counted as passes. Native startup retains the established stock-game map/property warnings; report only new mod-specific errors as patch regressions.

Rendered depth, wall alignment, audio balance and connected-player behavior remain pending. Native server fixtures have no connected clients. The held tests from 0.2.61 remain relevant where covered above.

The final automated pass reports **26,904 assertions**, 367 source files and 496 packaged files. Five owner WAVs and fourteen owner PNGs match original SHA-256 values. A clean diagnostic cache was used after the early failed runs had saved the superseded reset default; no player save was altered. Native write and fresh-process read passed; all three independent package startup checks passed after the final audio gains (Traps 69.2s, Turrets 71.1s, both 66.7s).

## C393 follow-up: audio balance (2026-10-21)

Owner explicitly requests balanced audio before installation. Production playback gains now distinguish high-priority wake/impact cues from quieter laser transitions, reel, shutdown and pull. Owner WAV bytes remain unchanged. Measurement uses 50 ms windows with an ungained -50 dBFS active gate; native captures are at one metre/default FMOD parameters. This is a reproducible relative-level check, not a claim of perceived in-game loudness or clipping-free simultaneous playback.

- Owner clip gains: reel 0.38, laser detect 0.38, laser clear 0.60, turret wake 0.65, turret sleep 0.50.
- Native cue gains: launch 0.80, impact 0.70, pull 0.35, reset/switch 1.00, Poke/rotary 0.65.
- Laser active-window RMS differs by 0.48 dB after adjustment; wake is about 3 dB above laser and 8 dB above reel/shutdown. Single-cue peaks retain at least 3 dB headroom at the default device-volume multiplier. Native switch/reset stay at their already quiet native level; no blanket amplification.
- Global Sandbox volume multiplies the mix, including mute; source normalization and zombie hearing/attraction are unchanged.
- `tools/measure_device_audio.py` reads actual shipped gains and writes local diagnostics plus `art/DEVICE_AUDIO_BALANCED.html`. Native preview captures are not distributed. An in-game listen with multiple devices and normal combat remains required.

Balanced audition integrity check: twelve embedded PCM clips decode correctly and expose manual controls without autoplay. Browser rendering/playback was not verified because browser tooling blocks file URLs; no alternate browser route was attempted.

Installed 42.21 bytecode confirms `FMODSoundEmitter.Sound.getVolume()` multiplies emitter gain by the clip effective volume; the custom mix is applied once and still respects game/user volume. Native package probes additionally verify all five custom clip gains and reel-only looping. Final package probes run after the gain changes; prior write/read gameplay persistence remains unchanged.
