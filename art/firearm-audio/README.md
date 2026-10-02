# Native firearm suppression auditions

Local asset preparation requested by the owner, 2026-10-01. Open [FIREARM_AUDIO.html](../FIREARM_AUDIO.html), also linked from the existing potato/reload page. No gameplay package change, installation, publication, firearm adapter expansion or module implementation.

## Coverage and proposed runtime footprint

- All 20 real IsAimedFirearm items in the installed 42.21.0 generated item scripts, sharing 18 native SwingSound events.
- Two toy cap guns included separately for inventory completeness, not proposed as combat turret heads.
- One representative outdoor single-shot render per event. This does not capture every bank randomization, indoor/distant mix, or M16 automatic event. Repeat the single-shot sample according to the actual turret cadence; do not bake a burst into a per-shot fallback.
- Real firearm layered OGG files: 797,597 bytes (778.9 KiB). Including cap guns: 823,331 bytes (804.0 KiB). These are candidate asset sizes, not a packaged gameplay update.
- Mono 48 kHz Vorbis quality 4. Nine proposed family mappings reuse existing files, adding zero audio bytes. No per-stack audio copies: module stack affects zombie hearing independently.
- Original and filtered-only comparison OGGs, PCM16 WAV editing masters, manifest and ZIP are local audition deliverables, not proposed runtime content. The whole audition folder is larger than the runtime subset.

## Processing and evidence

`tools/render_native_shot.py` loads the installed FMOD 2.03.09 libraries and current ZomboidSound banks in an isolated Python process. It uses WAVWRITER_NRT and synchronous Studio updates, without changing game files or requiring a new player dependency. This offline access does not prove runtime Lua DSP access. Bank hash, source item/sound paths, parameter defaults and original capture hashes are in manifest.json.

Source/listener distance is one unit, outdoor FirearmInside=0 and RoomSize=0, Occlusion=0. These are rendered authored events, including their native processing/tails, not raw recording stems. Leading capture silence is removed at -80 dBFS with a two-millisecond margin; twenty milliseconds are retained after the last sample above threshold, with a final five-millisecond fade. Captures must have a quiet final quarter-second and cannot still be actively playing; STOPPING with a silent captured tail is allowed.

Stereo sources are averaged to mono without equal-power downmix amplification. The original shot receives a 250 Hz eighth-order Butterworth low-pass (48 dB/octave, still the provisional steep slope). Wet points are (0,0), (.04,1), (.09,1), (.18,.25), (.69,0); interpolate linearly and use dry=1-wet. The owner overlay begins at zero, unfiltered. Overlay source is unchanged. A common final headroom gain, when required to prevent PCM/Vorbis overshoot, applies equally to dry/filtered/layered comparisons; each gain is disclosed in the manifest and HTML. It is not a suppression-volume mechanic. Pitch is unchanged in these previews.

Numerical checks verify that layered minus filtered equals the mono overlay times the disclosed common gain before encoding, within 1e-12. All 60 OGGs decode successfully with peaks below 0.99 and durations within codec padding tolerance. Layered WAV masters contain no saturated samples. Final artistic quality requires owner listening; numerical checks are not hearing approval. Browser UI verification was unavailable because the connected browser blocks local file URLs; no alternate serving workaround was used.

FMOD references: [Studio event descriptions](https://www.fmod.com/docs/2.03/api/studio-api-eventdescription.html), [offline WAV rendering](https://qa.fmod.com/t/fmod-android-error-18-file-not-found/15759), [synchronous Studio updates](https://www.fmod.com/docs/api/content/generated/FMOD_Studio_System_Create.html). Current installed ParameterFirearmInside bytecode confirms zero for outdoors.

## Proposed family selection

Exact item override → recognized native shot event → explicit mechanism/cartridge family → original sound for an unknown or unusual mechanism. Do not infer compatibility or firearm category from an English item name. The HTML lists nine candidate families: light handgun/SMG, heavy handgun, revolver, shotgun, short shotgun, assault rifle/light machine gun, battle rifle/machine gun, bolt-action/precision rifle, and lever-action/pistol-calibre carbine. Weapon-specific native entries remain available as overrides.

Rimfire has no exact native counterpart in this inventory; select an owner-approved approximation or retain its original sound. Bows, energy weapons, launchers and other unusual mechanisms must not automatically become rifle sounds. Native reload/mechanism audio remains separately driven by each weapon's exposed sound fields.

## Rebuild

Run `tools/build_firearm_audio.py` using the bundled Python with NumPy. It uses the existing ShareX ffmpeg executable and the game's installed FMOD libraries; no tool is bundled with the gameplay mod. Raw captures are local ignored diagnostics. Existing captures are reused so random bank sample selection does not change unnecessarily. Delete only a specifically chosen capture and its JSON if a new representative take is desired.

The current set is local audition material. Packaging/installation remains part of a later explicitly approved gameplay patch, with native spatialization, simultaneous turret playback and audible acceptance still pending.
