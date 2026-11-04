# Focused owner test — 0.2.30

Held, not passed or waived. Carried into [the combined 0.2.31 test](TEST_v0.2.31.md); do not request this as a separate round.

Use a disposable single-player world with OMH: Traps and OMH: Turrets enabled. Restart the game after installation. Use debug/build cheat to prepare beds and the previous heavy turret setup; normal materials are needed only for the recipe check. Leave turret diagnostics ON and detailed turret logging OFF for performance evidence. The full split regression round remains waived.

1. Confirm 0.2.30 in the loaded OMH developer menu/log. Build a basic Bed Spikes from the OMH: Traps construction category on a clear floor, rotating the preview. Expect two passable tiles and no overlap through a wall or occupied floor.
2. Reinforce one bed, then inspect both tiles. Expect basic/reinforced durability 100/200, a shared condition display and the reinforced marker on both halves. Normal construction costs four planks/spears plus four bindings and keeps the knife; reinforcement costs two planks/eight nails and keeps the hammer.
3. Walk, run and sprint across both halves. Expect hand-clearing movement without jumping. Walking must never scratch; running/sprinting has a 20% chance once per bed entry, not once per tile.
4. Lure upright zombies across several adjacent beds. Trips are random; each fresh fall on spikes deals 20 basic or 50 reinforced damage and removes six durability total. Lying/getting up causes no further hits; five-second trip protection begins after getting up. Existing crawlers receive no repeated damage.
5. Let a potato turret knock zombies onto the beds. Expect one spike hit per fresh landing, even during spike-trip protection. Repair and pickup each take ten seconds and cancel on movement; pickup returns one full-condition item for redeployment. Save/reload a damaged bed and verify its tier, both tiles and condition remain.
6. Repeat the previous heavy module/zombie workload for two minutes. Report any pauses and their approximate frequency, plus the bed results. Use OMH.cmd's diagnostic capture afterward; new audio-stage maxima will distinguish emitter, playback, pitch and volume delays.

Headless native evidence covers script/recipe registration, movement flags, animation parsing, object/global-state serialization and package isolation. Rendered brush-through, actual animated trips and dense-client smoothness require this test. No multiplayer combat claim is made.
