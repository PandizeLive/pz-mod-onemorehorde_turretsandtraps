# C552 Horde Manager visibility and rotary retest

On November 2 the owner reported that Horde Manager spawns were again invisible and that rotary hits appeared more consistent. The running client and dedicated server both logged T&T 0.2.71.11 on Project Zomboid 42.21.0. This investigation used the current client console, a read-only copy of the dedicated server console, and its admin and command logs.

## Live spawn attempts

At 6:06:00, 6:06:08 and 6:06:11 PM Indianapolis time, the client received the native “Horde spawned.” reply. The admin log records three groups of five near tiles 8002,11747 and 8002,11748. The server recorded five native living-zombie creation messages in each command frame, with zero failed-spawn or corpse-creation messages. The game was running. The client was still sending observations from within a few tiles of the requested location.

The success reply alone would be insufficient. The installed native command discards the list returned by `addZombiesInOutfit` before replying. The individual creation messages occur only after a non-null zombie is returned. That establishes all fifteen server-side creations. The shipped T&T Lua does not intercept the Horde Manager UI or `/createhorde2`. Its zombie index removal routine removes internal tracking entries. It does not remove the native zombie from the world.

From the first spawn through the end of the captured session, T&T recorded no further damage completions or T&T kills. The only two subsequent client lifecycle-index log messages refer to IDs seen before the commands, both more than 75 tiles away when logged. Other client indexing paths can run silently. The live native spawn messages omit the zombie IDs, and the logs contain no correlated delivery, removal or render record for those fifteen. The reason the owner could not see them remains open. The [earlier C535 capture](MULTIPLAYER_FEEDBACK_C535.md) also showed successful server creation, but its missing-actor rejections cannot be assigned to this session.

## Independent local reproduction

A private loopback dedicated server and the installed game's FakeClientManager established a real network connection. A test-only observer recorded the exact newly created zombie IDs at the spawn tile. The server ran three `createhorde2` commands with count 5, radius 0, z 0 and health 1 beside the simulated player. Each ID was compared with the simulated client's incoming “New zombie” records. The matched runs used the same spawn tile (8007,11748).

| Local server configuration | Living zombies created | Matching IDs received |
| --- | ---: | ---: |
| Base game plus observer | 15 | 15 |
| Both T&T entries, 0.2.71.11, plus observer | 15 | 15 |

This exercises the native command and server-to-client spawn delivery. The simulated client has no renderer and does not run the player's client Lua. The local world also lacks the live base, other Workshop mods and live connection conditions. These tests rule out a general server-side block by T&T. They cannot resolve a conditional interaction on the owner's server.

## Live rotary result

The server counted 45 rotary hit submissions and 45 positive damage completions. The client counted 45 owner applications and 45 damage displays. Observation-to-owner application averaged 115 ms and reached 319 ms. Two movement intervals expired before a hit decision. Neither that count nor the 45 submissions establishes how many visible blade passes should have hit. The previous [0.2.71.8 capture](ROTARY_RETEST_C545.md) also delivered all admitted hits (36/36), with a 110 ms average and 187 ms peak. The encounters differed. Record the owner's improvement in perceived consistency separately from measured latency.

**Decision needed.** Recommend **1A** to prepare an opt-in, short-lived trace on the test server and one real client. Correlate ID, outfit, position and floor at server creation, continued server presence or disappearance, owner assignment, and native client-list presence. This separates server removal from client delivery and narrows a display issue to actors confirmed present. **1B** is a two-player comparison of the same group before adding instrumentation. The existing test world remains suitable. No live settings, gameplay package or Workshop listing changed in C552.
