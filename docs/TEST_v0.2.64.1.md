# 0.2.64.1 verification

Owner C422 authorizes the selected Arc audio. Test after restarting when available.

- Arc firing pitch variation
- Arc impact volume
- Suppression and sound volume controls
- Multiplayer electrical effects

## Automated evidence

Full validation passes 27,299 assertions and compiles 319 runtime/translation files. Native FMOD playback validates 24 definitions, 2,727 pitch clips and 720 starts, including Arc's 101 pitch choices. No runtime pitch-setter logging. Manifest: 382 source files and 529 packaged files.

Kahlua checks cover one shot cue plus six confirmed contact cues, client deduplication, unrelated receiver ordering, volume controls, Suppression floor, finite input validation and bounded impact starts. The same packet-routing regression covers electrical visuals. These use test doubles for gameplay/network objects, not connected players.

The selected firing sample is 1.06125 seconds, peak 0.133273 and RMS 0.0102624 before playback gain. Native impact audition is approximately 1.0712 seconds, peak 0.397156 and RMS 0.0217912. At selected gains one impact is about 8.1 dB below the firing RMS; overlapping impacts remain subject to the start budget. This is measured source-level mixing, not an in-game loudness guarantee or a full spatial/listener test. The native impact retains its own attenuation and hearing parameters.

Native write and fresh-process read checks pass (110.6s and 118.4s). Traps-only and Turrets-only startup checks pass (104.4s and 104.1s); combined startup passes (109.6s). All probes had zero connected players. Installation and GitHub mirror are pending. Listening, rendered and connected-client acceptance remain open; no Workshop publication.
