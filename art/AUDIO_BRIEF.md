# Potato turret audio handoff

Owner-produced audio; no AI audio or extracted game samples in the package.

## Needed first

| Suggested filename | Sound | Suggested length |
| --- | --- | --- |
| potato_fire_01.wav | Short compressed-air phoomp; modest mechanical kick | 0.2-0.7 seconds |
| potato_load_01.wav | One potato fed/seated into the barrel; a short mechanism sound | 0.3-0.9 seconds |
| Native splat2.wav — selected | Impact selected by owner; no new recording needed | Existing clip |

Two or three variants of firing and impact are welcome, but one of each is enough to integrate. Reload audio should describe one action, not contain two seconds of silence; the game owns reload timing.

## Optional later

- turret_servo_loop.wav: quiet seamless aiming motor loop, about 1-2 seconds. Starts/stops with actual head movement.
- turret_dry_fire_01.wav: brief empty click, about 0.1-0.3 seconds.
- turret_power_on_01.wav / turret_power_off_01.wav: brief distinct activation/deactivation cues, about 0.2-0.6 seconds.

Existing vanilla material hits, footsteps and zombie reactions can cover other feedback initially; no custom barrier sound set is required for this patch.

## Delivery

WAV, mono, preferably 48 kHz / 24-bit; 44.1 kHz / 16-bit is also usable. Supply separate dry clips with little leading silence, no clipping and no baked-in distance/reverb. Keep a consistent level across variants. These are flexible production recommendations, not import restrictions. Do not bake firing and impact into one clip: their positions and timing differ.

Audio integration and volume/noise tuning follow receipt of the files. The game must separately control audible playback and zombie-attracting noise. No firing sound has been selected or implemented in 0.2.15.

## Selected impact and auditions

0.2.16 references the installed native splat2.wav; it is not copied into the mod. Firing and reload remain undecided. Reload candidates are first in Listening/Potato Turret Native Sounds/Listen.html (workspace root), now with 16 reload candidates and 34 clips total. Provide an HTML audition page for every future audio-selection request.

## 0.2.19 owner replacements

Owner supplied potato_thump_1.wav / potato_thump_2.wav (0.75s each) and potato_splat_1.wav / potato_splat_2.wav (0.25s each) in OMH/Audio/Turrets & Traps. These replace the undecided firing/native impact selections above. Exact WAVs are packaged, with native random variants and per-playback pitch 0.95-1.05. Launch and impact timing are separate. [Listen to the four selected files](POTATO_AUDIO.html). Hashes/format details: diagnostics/v0.2.19/audio-assets.json. Reload audio is still pending selection; supply HTML candidates when that work resumes.

## 0.2.21 test follow-up — selection pending

[Updated audition page](POTATO_AUDIO.html) lists sixteen native loose reload candidates and a browser-only suppression preview using the supplied firing clips. Proposed cutoff: 250 Hz; preview slope 48 dB/octave, pending owner choice. Linear wet keyframes: 0s/0%, 0.04s/100%, 0.09s/100%, 0.18s/25%, 0.69s/0%. Exact equal endpoints produce a 0.04–0.09s plateau. No gameplay patch or reload selection is implied. Native firearm reload feedback should follow actual weapon event names and cycle transitions. See docs/TEST_v0.2.21.md for engine limitations and pitch/timing tradeoffs.

## C71 — selected reload and unfiltered overlay

Potato reload: **stormyShotgunInsertRound.wav**. Owner overlay source: ../Audio/Turrets & Traps/suppressed_shot.wav (48 kHz stereo PCM16, 0.375s). Overlay unfiltered at time zero over the processed original shot, preserving gain. It must not replace the original by itself. Audible quietness is not required; gameplay suppression changes zombie hearing separately.

POTATO_AUDIO.html now provides dry/filtered/layered comparisons and download links for each layered WAV, the original overlay and selected reload. art/audio-previews/ contains two filtered and two layered potato-shot auditions (0.75s, 48 kHz stereo PCM16); README.txt records processing and hashes. No clipping or normalization. These are local discussion artifacts, not installed sound replacements.
## Native firearm audition library (C72)

Owner requested all native firearm shots with the suppression filter and unfiltered owner overlay, plus compact modded-weapon family fallbacks. [Listen and download](FIREARM_AUDIO.html); [source and validation notes](firearm-audio/README.md). The existing potato HTML links to this library.

Twenty real firearms map to eighteen processed native event recordings (797,597 bytes of layered OGGs). Nine proposed families reuse these files, with two separate toy cap-gun entries for completeness. The set uses actual current installed FMOD events, one representative outdoor single shot each. All original files are unchanged. Processing is offline; no runtime DSP, gameplay audio registration, modded-gun adapter or installation is included. Final family selection and sound quality await owner audition.

## 0.2.22 approved integration and balanced layer

C73 approves the processed native library plus two processed owner potato variations for runtime Suppression. JS-14 provides the layer-to-filtered-shot reference over 0.375 seconds; each original determines overlay gain (Double Barrel approximately +11.2 dB). The layer remains unfiltered. Final common gain prevents clipping and is disclosed in the manifest. This supersedes unity layering above. Eighteen native layered OGGs occupy 797,574 bytes; fallback families reuse them. Potato reload references the installed stormyShotgunInsertRound.wav. Native firearm reload/rack event names come from the actual head. See firearm-audio/validation.json for the combined runtime size. Player playback acceptance remains pending.
