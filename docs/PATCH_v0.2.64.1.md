# 0.2.64.1 - Arc audio

Owner C422 selects S1B for firing with pitch variation and S1C for impact.

- Arc firing and impact audio
- Multiplayer Arc effect routing

One RadioZap-derived firing sample plays per paid main shot, with native file-clip pitch selection from 0.95 to 1.05. The selected local audition sample is packaged as a 14,762-byte mono OGG; this is the explicit selected sound implementation, not the remaining unselected audition library. DismantleFailed stays a reference to the installed native event. Successful chain and Fragment contacts emit impact cues; rejected damage does not. Restored ongoing chains do not replay the initial firing sound.

Playback gains are 0.65 for firing and 0.12 for impact. Both honor the existing device master, local feedback volume and Suppression volume floor. Impacts admit at most four starts per 100 wall-clock milliseconds per client, limiting stacked cues independently of gameplay damage. Nearby recipients get authoritative facts through the existing bounded-distance presentation dispatch. No new settings or balance changes.

The older projectile receiver claimed duplicate-suppression tokens before checking whether it handled the command. It now filters its commands first, allowing the separate Arc visual and audio receivers to process their packets exactly once. The fix also avoids stealing other unrelated presentation events.

Installed 42.21.0 bytecode confirms EventSound does not consume the generic pitch field; the emitter setter also touches other queued/active sounds and logs each call. FileSound inherits clip pitch. Use the established file-clip approach with native selection; do not call the emitter pitch setter or add a Java runtime dependency. Source sample and output hashes are recorded in art/ARC_AUDIO_SELECTED.json. Native-event captures and unselected previews remain local.

See [verification](TEST_v0.2.64.1.md). Listening balance and connected-client acceptance require player testing.
