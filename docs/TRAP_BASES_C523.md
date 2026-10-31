# C523 - Cross approval and trap-only base modeling

## Owner scope

Owner selects the exclusive cross footprint to limit space and authorizes a modest Poke construction-cost increase. This supersedes C522's recommendation for simple neighbor exclusion. One center plus four non-damaging walkable platforms; no overlap or other floor traps occupying reserved platform tiles. One assembly for placement/repair/pickup, no corpse hauling or new delay. The cross is approved design, not implemented runtime behavior. Owner also asks to consider reduced Spike Barrier durability, with capacity to kill at least two zombies, and simulate effective bases using traps only. Barrier values and the interpretation of that minimum remain under discussion. Preserve C518 separately. No other trap is silently converted to a cross.

## Grounding and proof limits

Reviewed current Poke recipes/runtime, Barrier retaliation/footprint and Foundation defaults, Barbs and Beds scripts/contact routines. Inspected installed stock-jar bytecode rather than relying solely on older decompiled source: [native evidence](evidence/c523-native-thump.json). Native thumping retains fractional loss, normally nearby-zombie count / 8 up to one health per strike event; nearby count is not just the attackers currently striking. Therefore barrier health is not a fixed number of kills. The model conservatively applies native loss before retaliation. Actual packet/animation ordering and collider health consolidation require connected validation before promising an exact minimum.

Executed [reproducible Python model](../tools/tests/trap_bases_c523.py): **326 design cases**, comprising base layouts, timing/chance/crowd sensitivities and isolated barrier benchmarks. [Full results](evidence/c523-trap-bases.json). Geometric assertions prove cross footprints in the modeled layouts do not overlap each other or modeled wire strips; outcome checks account for all 100 attackers. These are design computations, NOT gameplay regression tests, native AI, multiplayer proof or a claim that all traps were simulated.

Four independent ten-tile straight fronts (40 frontage tiles), omitting corners and gates. 100 attackers; no player damage, turrets, repairs or corpse blocking. Fixed straight paths, health 100/150, speed 1/2 tiles per nominal active second; mostly 0.5-second arrival spacing per used lane. Even waves use all 40 lanes; focused waves use two lanes on one Barrier. Choke cases deliberately route through one lane per front, or one attacked lane in focused cases. This is an assumed successful funnel, not demonstrated AI behavior; routing-wall construction costs are NOT included, so choke layouts are not proven equal-budget winners. More distant traps cannot assist an already breached lane.

Poke uses inspected 45 damage, 1.5-second cycle, 150ms admission and one wear per successful cycle, 200 health. It retains the current crowd-efficiency behavior; the earlier per-victim-wear proposal is not silently applied. Wire uses shared 2-second actor cadence, 10 damage, divisor-two movement and 50 successful damage events per independent two-tile section. Bed uses 40% entry chance, 20 damage and six wear; successful landing and one-second trip pause are assumptions, varied to zero/three seconds in sensitivity cases. Native ragdolls/recovery are not reproduced. Barrier width two, 10 retaliation, current health100 vs candidate40/80; one attack per second is an assumed cadence, varied to0.75/1.5 seconds. Active attackers2/4/8 and queue approximations stand in for collision and nearby counts. No arbitrary trigger cap is proposed for game code. Reinforced sensitivity uses current damage25 and health multiplier2.

Unmodeled: Barbed Panel backing-wall endurance/attackability and shared-health offense; Tether trajectory, repeated pull/repositioning and interaction with bed falls; player traps/triggers without damage; native pathfinding/rerouting, collision, wall breakage, network timing, restocking and subsequent waves. Do not generalize this pass into all-trap acceptance or assume these alternatives are balanced. Panel-on-durable-backing remains a specific substitution risk.

## Cost direction

Recommended modest recipe increase: Metal Bars4->5 and Screws8->10 in BOTH pump and improvised recipes. Preserve two Small Metal Sheets, one Tire Pump OR two Metal Pipes, tools, skill gates and craft time. These two ingredient counts rise25%; total recipe economic cost is not asserted to rise25%. This is the proposed numeric interpretation of the owner's authorized modest increase; no recipe file changed yet.

Twenty-four crosses would use24 pumps (or48 pipes),120 Metal Bars,48 Small Metal Sheets and240 Screws. The 120-cross deep field uses120 pumps (or240 pipes),600 bars,240 small sheets and1,200 screws. Cost tables in results use the pump recipe, planks and clean ripped-sheet alternatives; no invented conversion from wire rarity to wood value. The basic Barrier recipe remains4 planks/stakes +4 bindings per two-tile section. Beds yield two per4 planks +4 bindings. Each wire section costs1 Barbed Wire +2 Wire. Skills/tools/time are additional costs not collapsed into a budget score.

## Base comparison

Reference: 100-health walkers,1tile/second,0.5-second lane arrivals, candidate80-health basic Barriers, four active attackers per Barrier. Counts are kills out of100, not forecast accuracy.

| Layout | Devices over the whole modeled perimeter | Spread wave | Focused wave |
|---|---|---:|---:|
| Barrier ring |20 Barriers|100|8|
| Shallow cross + ring |24 Poke,20 Barriers|100|8|
| Wire held against ring |40 wire,20 Barriers|100|12|
| Mixed perimeter |24 Poke,40 wire,40 basic beds,20 Barriers|100|17|
| Layered choke approaches |12 Poke,40 wire,40 basic beds,20 Barriers, assumed routing|100|86|
| Deep cross field, no blocking line |120 Poke|60|66|

The last row has no Barrier; its cost and land use are far higher, so it is not an equal-budget comparison. A shallow field mostly injures passersby. Multiple separated strikes along a reliable approach are much more useful than centers scattered across paths zombies do not take. Dense arrivals can traverse centers during recovery; a three-second arrival-gap sensitivity lets the deep field kill100. The choke's result falls sharply with faster or higher-health enemies; it is not invulnerable. At40 base health, mixed-near-Barrier focused results range8-11 across five seeds, choke76-82; reinforced choke kills100 in that tested reference set. These results support layered design but expose reinforcement as a major power increase and show spacing alone still permits effective trap-only defenses.

A ring still handles diffuse pressure well even after a large durability reduction. That is expected: mostly idle sections retain their resources, while a concentrated horde breaks one local segment. Don't claim that reducing Barrier health prevents surrounding a base or makes all perimeter layouts weak.

## Barrier health recommendation

**Explore80 basic /160 reinforced**, preserving the existing reinforcement multiplier. This is a20% reduction from100/200, not approved shipped tuning.40/80 was tested as a stronger nerf and is not recommended for the requested minimum without narrowing the test conditions.

At100 reference zombie HP and sustained fixed frontage, model40 health kills31 sequential isolated zombies,3 with four active attackers plus nearby crowd, and0 with eight active.80 health kills63 isolated or7 with four/eight active; current100 kills79 isolated,8 with four/eight active. This wide spread follows native crowd damage and simultaneous partial injuries. It is not acceptable to advertise80 health as exactly two kills, or guarantee two kills against arbitrary health multipliers, rear attacks, damaged traps or unlimited crowds. In the base model,40 health also kills0 against the focused150HP wave. The owner's 'at least two' should be a named frontal reference test, not kill-count-based invulnerability or magical durability.

Next numeric choice: **1A80/160 starting point (recommended)**; **1B retain100/200 until cross layouts receive connected testing**. Do not re-request approval for the already selected cross direction. Gameplay implementation of the multi-tile assembly still needs server placement reservations, one-object lifecycle, persistence, client previews, pickup/restoration and validation that later construction cannot overlap its arms; no approval is implied for deleting existing installations. No gameplay/version/package/install change in this simulation pass. Prior GitHub automatic approval-review block remains; evidence and planning are local. **Decision needed: Barrier tuning; cross/cost direction approved for follow-through.**
