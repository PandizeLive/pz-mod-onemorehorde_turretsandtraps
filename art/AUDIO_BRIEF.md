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
