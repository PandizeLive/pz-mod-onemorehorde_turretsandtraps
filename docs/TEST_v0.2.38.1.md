# 0.2.38.1 focused performance test

Automated check: 3,860 Kahlua assertions, 94 runtime/translation files, 574 native translation keys and 23 packet serializations pass. Native audio checks parse all 23 definitions/2,626 clips and start 690 sounds, verifying varying queued pitch across the original 101-value range without calling the emitter setter. Unit fixtures reject any setter call and prove nine nearby coils require only one occupied-coil object lookup, including removal revalidation. Native write/read passed in 148.4/142.1 seconds; Traps-only/Turrets-only/both startup passed in 132.0/130.1/129.4 seconds. Package/static checks also pass. Tagged installation is next; owner acceptance remains pending.

## Owner test

1. Restart and confirm **0.2.38.1** loaded. Use the same mixed Bed Spikes/Concertina/loaded potato-turret setup and approximately the same crowd as the lagging test. Keep diagnostic logging enabled for both entries and detailed logging off.
2. Let the turret fire/reload for about 30 seconds. Expect the same sounds with subtle pitch variation, normal volume and no missing/repeated reload cue.
3. Lead the crowd over spikes and wire while the turret fires for about a minute. Expect normal contact slowing/damage, independent spike wear and recovery. Note any pauses and whether they coincide with firing, reloading or trap contact.
4. Report **Test complete**, whether pauses improved and any audible difference. I will capture console.txt and compare update gaps, audio, reload and trap timings with the saved 0.2.38 run. No other full regression round is requested.

The original full 0.2.38 checklist is historical context; unmentioned items are not promoted to passes. Controlled native audio timing is not a client stress benchmark. Native event audio retains authored behavior and unknown third-party sound definitions are not modified. The previous 633-ms gap without a matching pitch spike remains evidence that other causes may exist.
