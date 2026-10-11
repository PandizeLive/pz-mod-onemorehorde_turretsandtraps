# 0.2.38.1 focused performance test

Automated check: 3,860 Kahlua assertions, 94 runtime/translation files, 574 native translation keys and 23 packet serializations pass. Native audio checks parse all 23 definitions/2,626 clips and start 690 sounds, verifying varying queued pitch across the original 101-value range without calling the emitter setter. Unit fixtures reject any setter call and prove nine nearby coils require only one occupied-coil object lookup, including removal revalidation. Native write/read passed in 148.4/142.1 seconds; Traps-only/Turrets-only/both startup passed in 132.0/130.1/129.4 seconds. Package/static checks also pass. Tagged installation and source/package/archive/backup hash verification passed; owner now reports noticeable lag apparently resolved in the captured sample; details and limits follow below.

## Owner test

1. Restart, confirm **0.2.38.1** loaded and use a fresh test world. Recreate the same mixed Bed Spikes/Concertina/loaded potato-turret setup and approximately the same crowd as the lagging test. Keep diagnostic logging enabled for both entries and detailed logging off.
2. Let the turret fire/reload for about 30 seconds. Expect the same sounds with subtle pitch variation, normal volume and no missing/repeated reload cue.
3. Lead the crowd over spikes and wire while the turret fires for about a minute. Expect normal contact slowing/damage, independent spike wear and recovery. Note any pauses and whether they coincide with firing, reloading or trap contact.
4. Report **Test complete**, whether pauses improved and any audible difference. I will capture console.txt and compare update gaps, audio, reload and trap timings with the saved 0.2.38 run. No other full regression round is requested.

The original full 0.2.38 checklist is historical context; unmentioned items are not promoted to passes. Controlled native audio timing is not a client stress benchmark. Native event audio retains authored behavior and unknown third-party sound definitions are not modified. The previous 633-ms gap without a matching pitch spike remains evidence that other causes may exist.

## Owner result and console comparison (2026-10-10)

Owner: "Seems like lag is gone." Record this as a positive, tentative owner result for noticeable lag in this sample. No repeat stress checklist is requested. Unmentioned audio quality and individual gameplay checks are not automatically passed.

Root Capture `20261010-231708-7721` confirms both 0.2.38.1 entries on game 42.21. The snapshot was taken during gameplay; 59 summary windows span 290.763 seconds. [Reviewed metrics and capture hash](../diagnostics/v0.2.38.1/owner-test-20261010.json); raw console remains local.

| Measurement | Previous 0.2.38 | Current 0.2.38.1 |
| --- | ---: | ---: |
| Largest active-update gap | 1,077 ms | 368 ms |
| Largest turret audio-helper duration | 674 ms | 3 ms |
| Bed/barb callback maximum | Not instrumented | 2 ms each |
| Launched shots | 58 | 11 |

Current summaries include 25 audio calls, five reload calls (0 ms at timestamp resolution), 79 bed trips, 71 bed falls, 94,004 barb callbacks and 98,471 bed callbacks. Zero native "Set pitch for" messages appear. The previous repeated 633-1,077-ms gaps do not recur in this sample; smaller outliers do remain (368, 316, 291, 285 ms among the window maxima). The five known native missing-groundcover-tile errors recur, with no gameplay Lua exception/stack trace.

This supports improvement and the owner's perceived result, not a controlled benchmark: firing exposure is lower, the crowd/workload was not measured as identical, and timings do not establish every gap's cause. R1C3 retains residual-gap/large-load/authority scope; the audible mix and unrelated prior checks remain unconfirmed. No new patch or additional optimization is authorized by this report.
