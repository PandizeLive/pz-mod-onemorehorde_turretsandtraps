# C448 - Six-hour ammunition proposal

**C450 update:** Final approval is implemented in [0.2.67](PATCH_v0.2.67.md); [verification/delivery](TEST_v0.2.67.md) distinguishes automated evidence from pending owner acceptance. Earlier proposal and installed-version statements below are historical.

Date: 2026-10-24. Owner: "Let's do 6 hours of constant M4 fire. What would the multipliers and base values be and each of their resulting hours? Also list out the other expansion kit hours for each turret."

This replaces the twelve-hour direction with six hours for the M4 at full Large capacity. The owner requests concrete numbers before selection, not implementation. Recommend retaining the prior Enhanced Firing comparison baseline, without Rapid Fire, Autoloader, Magazine, Splitter or Conservation. A full first magazine and ordinary reloads are included; power, condition, aiming/wake delays, jams and target interruptions are not modeled. Six game hours at the verified saved 90-minute day equals 22.5 normal-speed real minutes. Other day lengths change the game-hour results; inventories remain fixed rather than automatically adapting.

**1A recommended:** uniform total multipliers 1/2.5/5/7.5/10 for no kit/Makeshift/Small/Medium/Large and the base quantities below. These halve the earlier C446 proposed capacities, giving the M4 4,000 rounds and approximately 6h07m with Enhanced, or 7h38m with ordinary Firing. Exact modeled six-hour minimum is 3,925 Enhanced rounds. Other consumable-head Large capacities provide at least six hours at the same baseline. Slower firearms retain longer endurance because they share the firearm ammo family. Fractional slot counts are rounded down; multipliers are total capacity, not an additional bonus, and kits replace rather than multiply each other.

**1B:** use ordinary Firing as the M4 target: firearm base320 and total capacities320/800/1600/2400/3200. M4 ordinary runtimes are0:36/1:31/3:03/4:34/6:06. The exact ordinary six-hour minimum is3,151 rounds. Other family bases can remain as shown, with extra endurance margin. Neither numerical option is selected by the request; no new settings, loot or source changes are made.

The quantity reduction improves supply requirements but does not make continuous firing inexpensive. 4,000 5.56 rounds still requires200 native20-round boxes;3200 needs160. Battery, durability, repair/material supply and rare ammo such as bombs are separate operating constraints. Existing Sandbox overrides need explicit preservation/migration before replacing the current family-difference resolver with multipliers. LootLab rarity/weights are unrelated and remain untouched.

Native slim remains the explicitly selected UI style (C447). Ambient preview carousel state does not override the owner's textual2A selection. C445's outstanding corrections and staged UI source are retained. Installed0.2.66, Contents, cumulative Workshop draft and source remain unchanged this turn. **Decision needed:**1A or1B numerical proposal; no repeat six-versus-twelve-hour or UI-style choice.

All times are game hours:minutes at the current 90-minute day, with ordinary reloads and a full first magazine. This estimates ammunition endurance, not battery/condition endurance. Values are proposed, not installed.

## Capacities

| Ammo family | No kit (1x) | Makeshift (2.5x) | Small (5x) | Medium (7.5x) | Large (10x) |
| --- | ---: | ---: | ---: | ---: | ---: |
| Firearm | 400 | 1,000 | 2,000 | 3,000 | 4,000 |
| Shotgun | 80 | 200 | 400 | 600 | 800 |
| Potato | 75 | 187 | 375 | 562 | 750 |
| Ballista | 30 | 75 | 150 | 225 | 300 |
| Scrapshot | 90 | 225 | 450 | 675 | 900 |
| Lobber | 35 | 87 | 175 | 262 | 350 |

## Enhanced Firing

| Head / firearm | No kit | Makeshift | Small | Medium | Large |
| --- | ---: | ---: | ---: | ---: | ---: |
| Native Pistol | 1:07 | 2:48 | 5:37 | 8:26 | 11:15 |
| Native Pistol2 | 1:45 | 4:22 | 8:45 | 13:08 | 17:31 |
| Native Pistol3 | 1:44 | 4:21 | 8:43 | 13:06 | 17:28 |
| Native Revolver | 2:28 | 6:11 | 12:23 | 18:34 | 24:46 |
| Native Revolver_Short | 2:11 | 5:30 | 11:02 | 16:33 | 22:05 |
| Native Revolver_Long | 2:31 | 6:18 | 12:38 | 18:56 | 25:16 |
| Native AssaultRifle | 0:36 | 1:32 | 3:03 | 4:35 | 6:07 |
| Native AssaultRifle2 | 1:27 | 3:40 | 7:21 | 11:02 | 14:43 |
| Native HuntingRifle | 3:10 | 7:56 | 15:54 | 23:51 | 31:48 |
| Native VarmintRifle | 3:10 | 7:56 | 15:54 | 23:51 | 31:48 |
| Native Shotgun | 0:36 | 1:32 | 3:06 | 4:39 | 6:13 |
| Native DoubleBarrelShotgun | 1:03 | 2:39 | 5:19 | 7:59 | 10:39 |
| Firearms M4 | 0:36 | 1:32 | 3:03 | 4:35 | 6:07 |
| Firearms Pistol | 1:17 | 3:13 | 6:27 | 9:40 | 12:54 |
| Firearms Shotgun | 0:37 | 1:34 | 3:07 | 4:41 | 6:16 |
| Firearms HuntingRifle | 3:20 | 8:21 | 16:41 | 25:02 | 33:24 |
| Potato | 0:39 | 1:39 | 3:19 | 4:59 | 6:39 |
| Ballista | 0:37 | 1:34 | 3:10 | 4:46 | 6:22 |
| Scrapshot | 0:39 | 1:38 | 3:17 | 4:56 | 6:35 |
| Lobber | 0:37 | 1:35 | 3:11 | 4:47 | 6:24 |

## Ordinary Firing

| Head / firearm | No kit | Makeshift | Small | Medium | Large |
| --- | ---: | ---: | ---: | ---: | ---: |
| Native Pistol | 1:23 | 3:28 | 6:58 | 10:26 | 13:56 |
| Native Pistol2 | 2:06 | 5:15 | 10:32 | 15:48 | 21:04 |
| Native Pistol3 | 2:07 | 5:18 | 10:38 | 15:58 | 21:17 |
| Native Revolver | 2:43 | 6:50 | 13:42 | 20:33 | 27:24 |
| Native Revolver_Short | 2:22 | 5:56 | 11:54 | 17:52 | 23:49 |
| Native Revolver_Long | 2:47 | 7:00 | 14:02 | 21:02 | 28:04 |
| Native AssaultRifle | 0:45 | 1:54 | 3:48 | 5:43 | 7:38 |
| Native AssaultRifle2 | 1:52 | 4:41 | 9:24 | 14:06 | 18:49 |
| Native HuntingRifle | 3:53 | 9:43 | 19:27 | 29:11 | 38:55 |
| Native VarmintRifle | 3:52 | 9:43 | 19:27 | 29:11 | 38:55 |
| Native Shotgun | 0:43 | 1:49 | 3:38 | 5:28 | 7:18 |
| Native DoubleBarrelShotgun | 1:06 | 2:48 | 5:36 | 8:25 | 11:14 |
| Firearms M4 | 0:45 | 1:54 | 3:48 | 5:43 | 7:38 |
| Firearms Pistol | 1:36 | 4:02 | 8:04 | 12:06 | 16:09 |
| Firearms Shotgun | 0:44 | 1:50 | 3:40 | 5:31 | 7:22 |
| Firearms HuntingRifle | 4:06 | 10:15 | 20:30 | 30:46 | 41:02 |
| Potato | 0:39 | 1:39 | 3:19 | 4:59 | 6:39 |
| Ballista | 0:46 | 1:58 | 3:58 | 5:58 | 7:58 |
| Scrapshot | 0:50 | 2:05 | 4:11 | 6:17 | 8:23 |
| Lobber | 0:50 | 2:06 | 4:15 | 6:23 | 8:32 |

Arc Emitter, Rotary Bat and Rotary Blade consume no ammunition. Their operation is limited by power and condition; expansion ammo capacity does not establish a runtime for them. Reusable Tether Dart has no consumable ammunition and traps do not accept expansion kits.

Source basis: C446 current-Kahlua stats and installed weapon inputs, rechecked against the current relevant save settings; every original duration recomputed within 0.02 ms. All 200 new tier durations and 40 minimum-six-hour boundaries were checked with the current TurretBatteryEstimate.duration formula. These are calculation checks, not live firing measurements.


## C449 - 1A selected (2026-10-24)

Owner responds **"1A"** to the immediately preceding C448 choice. This approves the recommended entire ammunition table: six-hour M4 target using Enhanced Firing, without Rapid Fire, Conservation, Splitter, reload or magazine modifiers; total capacity multipliers1/2.5/5/7.5/10 for no kit/Makeshift/Small/Medium/Large; floor fractional capacities; one kit's total multiplier, not compounded upgrades.

| Ammo family | Approved base | Approved Large |
| --- | ---: | ---: |
| Firearm rounds |400|4000|
| Shotgun shells |80|800|
| Potato |75|750|
| Ballista |30|300|
| Scrapshot |90|900|
| Lobber |35|350|

The complete intermediate-tier capacities and calculated runtimes above are selected. C4481B (ordinary-Firing target/320 firearm base) and prior twelve-hour capacity proposals are not selected. At the current90-minute day the approved full M4 capacity estimates6h07m with Enhanced or7h38m with ordinary Firing. This is ammunition endurance, not a guaranteed battery/condition/service duration. Fixed capacities remain independent of world day length or current rate. Arc/rotary ammo-free behavior, module-slot totals, Controller expansion bonuses, loot quantities/weights and existing saved tuning are unchanged by this decision.

No additional owner choice is needed for the ammo numbers or Native slim styling. Carry the selected tuning into the next implementation with C445 corrections and C447 styling. Engineering requirements remain: consistent settings/tooltips for the actual selected rule, preserve existing custom Sandbox/base/legacy expansion values through a verifiable migration or legacy path, and do not delete stored ammunition when capacity decreases. Reuse the authoritative kit replacement/overflow protections; no automatic lossy truncation or silent reinterpretation of old saved100/200/400/650 values as literal multipliers. The current resolver uses head-family differences rather than direct multiplication, so changing four numbers alone would be incorrect. Validate independent packages, native save state and new/old settings semantics before delivery.

This turn records the owner's approval; it does not claim implementation, build/install, test acceptance or publication. Current source still includes the staged C447 visual treatment but retains the old ammo resolver/settings. Installed0.2.66 and Contents are unchanged. No new test run was needed for a selection of the already-calculated table; retain C448 calculation evidence and outstanding rendered/MP acceptance. Standing C108/C119 requires committing/mirroring this decision. **Wait for a patch.**
