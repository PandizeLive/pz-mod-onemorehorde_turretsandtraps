# 0.2.30 — Bed Spikes and performance

Approved combined scope: C90-C95. Source and packages are prepared; installation evidence is recorded in RELEASE.md. The cumulative Workshop draft retains all previous unuploaded changes under 0.2.30. No publication is authorized. Rendered gameplay remains pending in TEST_v0.2.30.md.

## Construction and behavior decisions

- Basic/reinforced Bed Spikes are 1x2, on any clear floor, with foliage-style player hand-clearing animation. Walking is safe; running can scratch. No barbed flooring.
- Damage is 20 basic / 50 reinforced per actual fall; reinforcement keeps the same trip chance. Spike Barriers retain 10/25. No continuous standing/downed damage.
- Shared five-second protection from spike-induced trips starts after standing up. Zombies may fall zero or multiple times; external weapon knockdowns remain possible.
- Basic build: four planks/crafted spears plus four bindings, retained sharp knife, Carpentry 1, 10 XP. Reinforce: two planks plus eight nails, retained hammer, Carpentry 3, 30 XP. Free ten-second repair/pickup, like barriers. Explicit construction/service answer recorded in C94.
- C95 sets six shared durability wear per damaging fall, replacing one wear, and confirms fresh external-fall damage with existing prone/crawler exclusion. Retain the other defaults with this amendment: 20% trip chance per eligible moving tile entry, 20% running/sprinting scratch risk per whole-bed entry, and 100/200 durability. A fresh bed breaks on damaging fall 17/34. Boundary jitter, lying/getting up and repeated callbacks cannot multiply damage or wear.

Implemented Traps-owned construction and same-tier portable redeployment, shared identity/health across both tiles, reinforcement, ten-second repair/pickup, nine Sandbox options and white technical markers. Clear-floor placement rejects an internal wall. Shared reinforcement material selection preserves independent defense toggles. Native tile indices 28-51 are appended; build/deploy recipes need distinct sprite identities. Existing identities are unchanged.

Bed contact uses indexed nearby squares, skips work when no beds are indexed and reuses the current-frame snapshot. There is no scan of every bed or zombie. Removal of a companion tile is deferred outside native removal callbacks and bounded to four per tick. Recovery protection spans neighboring beds, leaving the nearby area and saved-session reload. Pickup returns one full-condition item; weight is 4/5 like barriers, with no service/deployment XP.

## Performance work completed in source

Reaction observations now require both turret diagnostics and detailed turret logging. Turning either off clears pending observations; trap detailed logging alone cannot collect them. Removed a duplicate identical renderer restore function.

Audio timings now separate emitter acquisition, playSound, pitch and volume. Normal diagnostic summaries retain maximum stage timings; turning turret diagnostics off skips timing collection. Playback, random pitch, gain, sound variants, combat and AI hearing are preserved. This instruments the reported stall; it does not establish that the native stall is fixed.

Evidence: diagnostics/v0.2.30/validation.log records 3,540 passing assertions, 77 compiled runtime/translation files, 503 native translations and 23 packet serializations. Includes diagnostic gating/queue clearing, an injected 300ms playback stall, fresh/prone/repeat falls, shared and reloaded protection, six wear, break/cleanup, walking/running/sprinting injury, service timing/cancellation/capacity/replay and menu indexing. World/render objects in these checks are test doubles.

tools/NativeAudioTiming.java runs 120 muted play/pitch/volume/stop calls against installed 42.21 FMOD and the four actual potato WAV files. diagnostics/performance-bed-spikes/audio-native.log reports AUDIO_PROBE_PASS. This isolated test does not run a dense client world or full emitter tick loop and did not reproduce the owner's 300-700ms pauses. SoundManager.CacheSound is a no-op in the installed bytecode, so it is not a viable preload fix. Native audio already caches loaded files. No speculative preload or sound-quality reduction was added.

## Native Bed Spikes investigation

Installed player movement/inTrees.xml uses Bob_WalkTrees but also emits DamageWhileInTrees. The dedicated bed movement node omits that injury event and passes native parsing. It clears its custom variable on exit and makes no global movement-speed changes. Rendered blending remains a player test.

Installed IsoZombie.updateZombieTripping uses setBumpType("trippingFromSprint"), which beds now request. The native animation has fall events and ragdoll variants. BumpFall's player-only branch is not used. Native Lua probes confirm trip/recovery/crawler APIs, three recipes, four facings and 24 native parts. Fresh-process write/read preserves their sprites, passability, identity, condition and matching persistent authority records. Rendered falls remain a player test.

## Release checks and player handoff

There are 176 canonical source files and 212 packaged files (93 Traps, 119 Turrets), with 27 identical shared files and 102 unique Sandbox options. Static isolation and native independent loading are checked under diagnostics/v0.2.30. Installation uses the existing tagged-source OMH.cmd process. The six-step TEST_v0.2.30.md covers new beds and the heavy turret workload. The owner-waived full split regression round remains waived. Audio stall elimination and multiplayer compatibility are not claimed.
