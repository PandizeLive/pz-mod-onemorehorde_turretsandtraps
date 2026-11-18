# Backed-barb native feasibility results

2026-10-07; C98. Starting local branch `codex/performance-barbed-audit`, commit `dcdcd9d`. Fetched origin/dev (`5fc6446`); no incoming commits. This is an isolated investigation, not a packaged barb implementation or a rendered acceptance test.

## Conclusion

The installed engine provides the APIs needed for a one-tile contact detector and timed zombie damage on representative constructed walls/fences. Native crossing motion reaches the proposed edge contact band. Shared constructed-host health and attachment metadata survive object serialization. Breakable map fences need a distinct adapter, and their partial native damage counter resets on object reload in this test. Ordinary map walls are not proven suitable shared-health supports.

Recommend the first implementation target damageable player-built wall/fence edges, with additional host classes admitted only after their native lifecycle is covered. This is a proposed first supported roster, not permission to silently narrow the owner's wall/fence requirement. Do not add custom HP, make static map walls destructible, rewrite map-fence persistence or change native collision to avoid these limits.

## Environment and reproduction

- Installed game reports 42.21; Traps-only package reports 0.2.30. Stock `projectzomboid.jar` first on classpath, ahead of installed loose classes.
- Jar SHA-256: `e1a69eb743ede60b213a0fe7f8b83d4fcab773036d256cc4543a336f3b058a33`.
- Run `diagnostics/barb-native-20261007/run_probe.py` from the project with the existing Python runtime. It compiles the reflection-only Java probe, copies the current Traps package into an isolated diagnostics cache and adds a test Lua file there. It starts a hidden, non-public loopback server on 29261/29262, runs the probe and shuts down. It does not install into the owner's mods or saves.
- Evidence: `diagnostics/barb-native-20261007/results.txt`, `native.log`, `BarbProbe.lua`, `BarbNativeCheck.java`, `run_probe.py`. Raw intermediate logs remain local. The selected final run exited 0 and logged clean shutdown. Later Lua changes are annotations and formatting only.

## What passed

| Check | Result and scope |
| --- | --- |
| Native Lua object/edge APIs | Eight native fixtures: constructed LogWall and LogFence, map metal fence and map exterior wall, each N/W. Lua can read position, character width, host membership, properties and durability APIs appropriate to each class. |
| Constructed edge lookup | `getThumpableWallOrHoppable` returned the exact constructed host. Four N/W constructed/map fence pairs returned the same host using `getHoppableTo` from either side. |
| Contact geometry | Twenty samples using a real native zombie's coordinates and collision width (~0.3): front contact, repeated stationary contact, outside-band near miss, protected side and beyond-edge endpoint, for four orientations. Geometry is a prototype policy, not precise model/mesh collision. |
| Timed damage | Real native zombie health fell from 1.0 to approximately 0.7 after three 0.1 hits at controlled timestamps 0, 2000 and 4000 ms. Duplicate timestamp, 1500 ms re-entry, 1999 ms and exit at 6000 ms added no damage. The existing SP damage helper was exercised with the Lua `isServer` predicate temporarily overridden; the game's MP behavior is not certified. |
| Constructed host durability | Starting 437/137, native `Damage(10)` reduced health to 427/127. Adding attachment metadata did not heal or add HP. All four health values survived native object save/factory/load. |
| Attachment persistence | All eight native object round-trips preserved the attachment marker and sprite. This is in-process native serialization, not a fresh-process world/chunk-reload test. |
| Native crossing motion | Eight executions: N/S/E/W across constructed log-fence and map metal-fence fixtures. Each entered the width-based contact band and reached the opposite tile. Unstarted-vault controls stayed on the starting tile. Native animation inputs were explicitly controlled. |

The crossing harness uses the engine's `ClimbOverFenceState.setParams/execute` and real IsoZombie objects. On the dedicated server, `IsoGameCharacter.setVariable` deliberately ignores zombie writes; the first motion attempt therefore never started. Current jar bytecode confirms the guard. The successful harness writes the internal animation-variable source only as test instrumentation, without changing the global server flag. Production SP contact detection would observe positions and edges; it must not force animation variables or depend on this Java helper.

## Native support differences

| Host fixture | Native durability | Persistence finding | Recommendation |
| --- | --- | --- | --- |
| Constructed log wall/fence (`IsoThumpable`) | `getHealth/getMaxHealth`, native Damage and destruction lifecycle | Health retained | Best initial support family; admit actual object capabilities and edge properties, not display names |
| Breakable map metal fence (`IsoObject`, fencing_01_1/2) | `getDamage` remaining counter, initial 100; `Damage(100)` reduces it to 90; BrokenFences recognizes host | Counter reloads as 100; marker persists | Separate future adapter must deliberately follow native lifecycle; no promise of preserved partial damage |
| Ordinary map exterior wall (`IsoObject`) | No constructed-health getter/max-health interface; generic damage field alone does not establish normal destructibility | Marker persists, untouched generic counter stays 100 | No verified finite-health support contract; do not infer eligibility from the generic counter |

The map-fence reset was discovered by an initially failing equality assertion and then recorded explicitly, not fixed or relabeled as preserved health. Current IsoObject save/load bytecode has no persistence of that partial counter. These results do not establish that every map fence has the same properties or behavior.

## Remaining verification before a playable patch

Actual placement and host selection; all intended wall/fence types; authored contact thickness/side policy; lifecycle through native demolition, support replacement and damaged fence sprite changes; unloaded versus removed support; marker duplication; fresh-process world reload; contact timer persistence and clock policy; player injury; service actions; recipe parser/consumption; bounded dense processing and later rendered autonomous gameplay. No autonomous pathfinding, animation rendering, slowdowns, damage balance, MP or GPU smoothness was certified here.

Native feasibility work leaves gameplay Source/Contents, installed 0.2.30, test tags and cumulative Workshop changelog unchanged. The owner-held 0.2.30 test remains pending. The performance audit's inventory/ray optimizations are still recommendations, and the long audio pauses remain unresolved.
