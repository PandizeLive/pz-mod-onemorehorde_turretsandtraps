# C477 - Barbed Panel contact and backing audit

Owner requested investigation on 2026-10-26 after selecting C475 1A. This is an audit and patch proposal, not gameplay implementation. Installed T&T remains 0.2.68.3; owner testing remains deferred. Inspected local branch codex/performance-barbed-audit at d51137d. Read-only origin fetch succeeded and origin/dev is an ancestor. The previous automatic approval rejection still blocks the private development push; no push was retried.

## Confirmed contact defect

Production BarbContact.touching subtracts the integer wall coordinate from the actor coordinate and requires the result to be at most actor:getWidth(), with no numerical tolerance. Native IsoZombie width is 0.30000001192092896. Position setters/getters use single-precision floats, while Lua performs the subtraction in double precision.

At coordinate 16384, the negative-side offset becomes 0.2998046875 and passes; the positive-side offset becomes 0.30078125 and fails. The native fixture creates an actual wall and two production panel attachments at that location and calls production BarbSections.contact on a real IsoZombie. Negative side hits, positive side misses; moving the same zombie to 0.2 tiles from each face makes both hit. Both records exist throughout. This reproduces an opposite-face failure mechanism without overwriting either attachment. It does not establish that the owner's reported scene used these coordinates or this exact cause.

Across eight coordinates (100, 1000, 2000, 3000, 5000, 10000, 16384, 20000), two axes and two faces, 18/32 nominal native-width placements miss. Tile centers are excluded. Passing width + 0.001 to the unchanged production predicate covers all 32 tested rounded boundary positions. This is an isolated proposed-comparison check, not a shipped fix or a justification for full-tile contact.

Installed 42.21 CollideWithObstaclesPoly bytecode confirms 0.3f obstacle bounds and a float Vector2f closest-point result. Native actor/production lookup results above are controlled positioning tests, not a rendered AI pathing or full motion-loop replay. Collision separation, corners and custom-map coordinate limits must be covered in the eventual correction regression before claiming universal contact parity.

## Backing damage and identity

With two panels attached, native getThumpableFor returns the backing wall and returns nil for both panel frames. Native getThumpableWallOrHoppable also chooses the backing. A native Thump call reduces backing health from 137 to 136. Panels do not intercept this damage or add armor. The fixture restores backing health before its existing serialization checks.

Existing real-object serialization/fresh-process restore tests still pass: both faces resolve, both contact at an interior distance, and removing one retains the other. Their successful interior-distance test did not cover the newly reproduced boundary defect. This does not close the original rendered report or multiplayer acceptance.

## Garage and multi-panel feasibility

BarbSupport.edge explicitly rejects DOUBLE_DOOR and GARAGE_DOOR properties. Removing that guard alone would be an incomplete implementation.

Installed IsoDoor bytecode distinguishes two lifecycles:

- Garage doors toggle open state and sprite on the existing segment objects. A reasonable bounded addition is one panel per selected segment, contact only while closed, hidden/suspended when raised, restored when closed. Keep the binding alive during suspension; current BarbSections.tick retires inactive attachments, so simply returning inactive on opening would delete them. This is a proposed behavior requiring approval and native lifecycle verification.
- Swinging double doors can remove and recreate their middle leaf objects on different squares. Current panel records use a fixed square/exact host association. Supporting these requires explicit leaf identity and relocation handling; removing the guard or searching for any nearby door would risk incorrect rebinding. Recommend a separate checkpoint after the contact correction and garage support.

## Recommended patch scope

Replace the strict boundary comparison with a narrowly precision-tolerant contact test. Retain exposed-side, segment-span, floor, shared cooldown and native backing damage rules. Verify native collision stopping positions and both faces, including coordinate boundaries. Reuse the existing geometry/index/authority paths: no new scan, polling loop, cache or network protocol is needed for this correction.

1A (recommended): contact correction first; garage support remains a separate follow-up.
1B: contact correction plus the proposed closed-only garage-segment support; swinging double gates remain separate.

Neither option is approved for implementation by this investigation request. No gameplay source, package, version, installation or Workshop draft changed.

## Evidence and limitations

- tools/tests/native_barbs.lua: added native backing-thump and coordinate/paired-face audit fixtures.
- tools/NativeBarbProbe.java: four additional isolated squares for the boundary fixture; existing serialized fixture shape remains unchanged.
- diagnostics/c477-barb-audit/server-write.log: native write/startup/save/shutdown passes in 57.0 seconds; initial 32-case boundary audit.
- diagnostics/c477-barb-audit/server-read.log and diagnostics/c477-native-read-summary.log: final fresh-process read passes in 53.5 seconds, including full paired-face reproduction and candidate comparison.
- One intermediate read failed because the new temporary panels consumed two fixture IDs before the old saved wire fixture was reconstructed. The test now restores its temporary ID allocation after cleanup. The rejected run is retained as server-read-fixture-id-mismatch.log. This was a fixture mismatch, not evidence of production save corruption.
- diagnostics/c477-thumpable-bytecode.txt, c477-door-bytecode.txt and c477-collision-bytecode.txt: installed game API/lifecycle evidence. Older decompiled references were discovery aids only.
- No connected player, rendered client, owner save mutation, installation or new owner testing is involved. Native fixtures temporarily route Lua through the single-player branch on real game objects; they do not prove connected multiplayer behavior.

The audit assertions deliberately expose the current defect; replace their expected-miss assertions with expected-contact regression assertions when the correction is approved.


## C478 - Option 1B approved and implemented (2026-10-26)

Owner: "One B". This selects the contact correction plus closed-only garage-segment support presented in C477, including persistence while raised. Implemented as 0.2.69; swinging double gates are not included. Existing backing damage, recipes, saved settings and item identities stay intact. [Patch](PATCH_v0.2.69.md) and [verification](TEST_v0.2.69.md) separate native/automated evidence from deferred rendered and connected-player acceptance. Private mirror remains blocked; no upload attempted.
