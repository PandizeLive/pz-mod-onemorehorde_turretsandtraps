# 0.2.38.1: native pitch variation and contact optimization

C122 approves another optimization pass while preserving pitch differences. This corrects the C121 proposal to remove variation. The previous 0.2.38 owner report remains a provisional functional result and a performance failure, not a completed performance acceptance.

- Native clip pitch variation
- Concertina contact lookup optimization
- Trap and reload performance measurements

All 23 custom sound definitions now use the native sound-script `pitch` field and randomized clip selection. The same 26 sample references each have 101 equally weighted pitch values from 0.950 through 1.050. No audio file is changed or duplicated; approximately 280 KiB of script metadata replaces per-play Lua pitch mutation. Existing sound identities, sample weighting, volume, distance, per-emitter limits and zombie hearing remain unchanged. `tools/build_sound_pitch.py` regenerates/checks these definitions idempotently. Native FMOD event sounds keep their authored variation; third-party sound definitions are not rewritten.

Installed 42.21 bytecode proves `FMODSoundEmitter.setPitch` logs on a matching handle but assigns the pitch field to every queued/active sound on the emitter. `GameSoundScript.LoadClip` supports static clip pitch, `GameSound.getRandomClip` selects a clip, `FMODSoundEmitter.playSoundImpl` copies it to FileSound, and FileSound applies it to the FMOD channel. EventSound does not consume this FileSound pitch field. Removing both runtime setter calls avoids this logging/broad-mutation path; it is not proof that all observed pauses were caused by logging or FMOD.

Concertina contact now rejects adjacent unoccupied tiles before looking up world objects, and the zombie handler reuses its nearby bucket. A nine-coil fixture resolves only the occupied coil, still validating its live presence. Panel support/door geometry remains freshly checked; no persistent world-object cache or delayed damage is introduced. Bed Spikes/barb callback timing and reload timing are gated by the existing component diagnostic settings and use aggregate summaries.

Validation and installation status: [focused test and evidence](TEST_v0.2.38.1.md), [release record](RELEASE.md). Native queued-sound tests prove pitch selection and propagation, not the audible mix or elimination of in-game stalls. No new content, balance, recipe, artwork, multiplayer or save-layout change.
