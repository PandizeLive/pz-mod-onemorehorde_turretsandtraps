# 0.2.62 owner test and evidence

**C395 owner test reported issues; acceptance incomplete.** [Findings, source evidence and proposed corrections](AUDIT_C395.md). Installed/tagged files unchanged. Live multiplayer test deferred by owner; no MP acceptance claimed.

Status: **installed and byte-verified** from immutable `test/v0.2.62` / `01fa9fb4648f8bb528ec296284267c26d3cd4f86`. Owner rendered/live multiplayer acceptance is pending. **Test now** after restart.

- [ ] Restart; confirm 0.2.62.
- [ ] Audio balance, including multiple active devices.
- [ ] Turret sleep, wake, cancellation, and state indicators.
- [ ] Tether speed, retraction, depth, and wall alignment.
- [ ] Lever mounting and override; laser beam colors.
- [ ] Connections scrolling, collapsing, grouping, resizing, and text clipping.
- [ ] Controller settings access and 40-tile range.
- [ ] Tooltips, module hints, and rarity-matching icons.
- [ ] Sandbox categories; friendly versus hostile player damage.
- [ ] Multiplayer synchronization, safety protections, and save/reload.

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

## Installation evidence

Both independent entries installed through OMH.cmd with full managed backups. All 367 source and 496 tag/package/install/archive files match SHA-256; both previous 0.2.61 backups verify. [Machine-readable release record](../diagnostics/v0.2.62/local-release.json). The first sandboxed install attempt was denied filesystem access; the authorized elevated installer completed and hashes verified. No player save, enabled-mod selection, Workshop content or LootLab deployment was changed.
