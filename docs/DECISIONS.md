# Decision register

**C394 / Short test checklists (2026-10-21).** Owner replaces detailed testing instructions with small feature checklists, at most ten words per item, unless longer guidance is essential. Updated the [0.2.62 owner test](TEST_v0.2.62.md) and project agreement. This is documentation only: installed 0.2.62, its immutable tag and pending owner acceptance remain unchanged. **Test now.**

**0.2.62 / C393 installed (2026-10-21).** Approved device feedback/standby, native tether visuals, Lever/Laser corrections, Controller polish/radius, friendly/hostile tuning, compact tooltips and rarity-aware owner artwork are installed. Audio uses measured individual gains with quieter reel/shutdown/pull and matched laser transitions; originals are unchanged. **26,904 assertions**, native write/restart and all three independent-package startup checks pass, including final sound gains/loop registration. Immutable `test/v0.2.62` / `01fa9fb4648f8bb528ec296284267c26d3cd4f86`; all **367 source and 496 tagged/package/install/archive files** match, with both 0.2.61 backups verified. [Patch](PATCH_v0.2.62.md) / [Owner test](TEST_v0.2.62.md) / [Release evidence](../diagnostics/v0.2.62/local-release.json). Rendered depth/alignment, in-game listening and connected-player acceptance remain pending; native fixtures had no connected clients. C108 mirror uses the existing development branch/draft PR. No Workshop upload, merge or LootLab deployment. **Test now** after restart.

**C393 audio follow-up (2026-10-21).** Owner requests balanced audio. Measured native captures/owner WAVs now use individual playback gains; laser transitions are matched, reel/shutdown/pull are subdued, Sandbox master volume remains. Originals are unchanged. [Measurements and limits](TEST_v0.2.62.md#c393-follow-up-audio-balance-2026-10-21). Final rebuild/installation is underway; in-game listening acceptance remains pending.

**C393 / Patch approved and implementing (2026-10-21).** Owner explicitly approves the complete recap: C390 corrective scope, selected audio, Detection-only standby/indicator, native tether visuals, friendly/hostile tuning, 40-tile Controller range, Sandbox/tooltip/artwork work and verification. No further design gate. Implementation and automated/native checks are in progress; installed 0.2.61 remains unchanged until a verified tagged build is ready. **Wait for a patch.**

**C392 / Standby choices settled (2026-10-21).** Owner selects **1B Detection-only standby / 2A indicator plus pose and text**. Manual/trigger-only operation bypasses standby; detector-equipped turrets retain existing Detection and trigger gates. Seven-second idle delay, one-second wake, invalid-target abort and successful-wake alert remain. Amber asleep, green active, unlit disabled; explicit Waking status. [Contract](AUDIT_C390.md#c392--standby-scope-and-indicator-selected-2026-10-21). C390/C391 selections retained, no further generic design choice required. Documentation only; installed 0.2.61 unchanged. **Decision needed: final next-build approval.**

**C391 / Audio, damage and radius selected; standby proposed (2026-10-21).** Owner selects native bounded tether visuals, 40-tile Controller radius, 2x friendly damage and 4x hostile damage/wound chance versus installed 0.2.61 (friendly wound chance unchanged). Six native sound choices and five new owner WAVs recorded; WAV metadata verified. New request: 7-second idle standby, lowered head, 1-second wake, alert after successful wake, immediate abort on invalid target. [Selected scope and remaining choices](AUDIT_C390.md#c391--owner-selections-and-turret-standby-proposal-2026-10-21): **1A all turret heads with existing acquisition/request gates (recommended) / 1B Detection-only standby; 2A status indicator plus pose/text (recommended) / 2B pose/text only**. Useful Sandbox timing/audio/indicator controls proposed. No gameplay or installed change; 0.2.61 remains current. **Decision needed.**

**C388 / Stronger PvP option requested (2026-10-21).** Owner asks for **1C, even larger**, interpreted as a stronger package than C387 1B. [Proposed 1C values](TARGETING_AUDIT_C386.md#c388--stronger-1c-requested-2026-10-21) use twice 1A damage and three times its wound chances (33% more damage and 50% higher wound chances than 1B). This is a numeric proposal, not owner approval of those exact multipliers. Existing proposed wound-roll and anti-instant-kill safeguards remain; no extra immunity or damage cap. Targeting implementation remains approved and unfinished; installed 0.2.60 unchanged. **Decision needed: confirm the proposed 1C values.**

**C387 / Reduced custom turret PvP profile selected (2026-10-21).** Owner selects C386 **1B**, rejecting native gun/spear severity and requesting substantially lower player damage and wound chance for enjoyable PvP. Full targeting implementation remains authorized; exact values are not yet selected. [Proposed numeric package](TARGETING_AUDIT_C386.md#c387--custom-reduced-player-injuries-selected-2026-10-21): **1A cautious fixed per-head damage/wounds with bounded wound rolls (recommended) / 1B 50% higher damage and doubled wound chances, with the same protections**. Preserve zombie balance and passive traps. No gameplay change or new test claim this turn; C386 policy remains staged, installed 0.2.60 unchanged. **Decision needed: numeric starting package.**

**C386 / Targeting patch approved; policy foundation staged (2026-10-21).** Owner approves the patch. Implemented Controller defaults, explicit overrides, current-owner faction classification and authoritative edit validation; 26,217 assertions and native command checks pass. Full UI/acquisition/player combat is not enabled. The current-game audit confirms missing player-hit rules for firearm, Ballista and Potato direct projectiles. [Concrete decision and evidence](TARGETING_AUDIT_C386.md): **1A native gun/spear wounds plus existing light Potato bruise (recommended) / 1B separate custom PvP damage values**. Existing collateral and player module effects stay unchanged under 1A. No zombie-only release substitution; complete targeting remains approved and unfinished. Installed 0.2.60/tag unchanged; no new playable build or acceptance claimed. **Decision needed: missing player injury mapping.**

**C385 / Targeting readiness clarified (2026-10-21).** Owner asks whether anything else needs discussion. No further generic targeting or friendly-fire choices are needed now; C383-C384 remain the contract. Use Zombies Only default and the defense owner's current faction as the stated working baseline, retaining Controller inheritance/local overrides and existing SP collateral rules. [Remaining engineering boundary](checkpoints/R4C1_CONNECTED_CONTROLS.md#c385--remaining-discussion-versus-engineering-2026-10-21): per-head deliberate player hit/damage, server protections and permission/persistence checks are not yet verified. Do not call the full targeting patch ready or invent player damage values; return a concrete choice only if the native audit exposes a real balance/scope gap. No new patch approval, gameplay edit or test result. Installed 0.2.60 testing remains deferred. **Wait for a patch.**

**C384 / Target groups and single-player damage parity selected (2026-10-21).** Owner selects C383 **1A / 2B**: Other Factions includes zombies and factionless outsiders. For collateral, owner explicitly requires the existing single-player turret/trap rules; do not introduce blanket faction immunity or universal friendly damage. Owner/own-faction exclusion applies to deliberate acquisition, with existing per-device incidental injuries retained. [Selected behavior and audit boundary](checkpoints/R4C1_CONNECTED_CONTROLS.md#c384--target-groups-and-single-player-damage-parity-2026-10-21). Retain Controller defaults/per-device overrides; recommend Zombies Only default and defense-owner faction reference. Per-head deliberate player acquisition/damage and server protections still need native compatibility review before a complete patch recap; no new damage values or missing paths are silently invented. Planning only, installed 0.2.60/testing deferred unchanged. **Wait for a patch.**

**C383 / Controller targeting and faction scope selected (2026-10-21).** Owner selects C382 **1A / 2B**, specifying **Other Factions / Zombies Only**. Controller targeting is next, including deliberate player/faction targeting in the first slice; the proposed zombie-only staging is not selected. Retain Controller defaults and individual overrides. [Mode semantics and remaining choices](checkpoints/R4C1_CONNECTED_CONTROLS.md#c383--other-factions-and-zombies-only-selected-2026-10-21): **1A Other Factions also targets zombies (recommended) / 1B other-faction players only; 2A factionless players excluded (recommended literal interpretation) / 2B factionless outsiders included; 3A protect excluded players from controlled-defense collateral too (recommended) / 3B filter acquisition only, retain collateral.** Ownership reference, default mode and server-rule handling are recommendations pending the final contract; no gameplay patch approval or new test claim. Installed 0.2.60 testing remains deferred. **Decision needed.**

**C382 / Testing deferred; next-checkpoint discussion (2026-10-21).** Owner delays the 0.2.60 test and asks what follows. Installed packages and immutable tag remain unchanged; rendered/connected acceptance is deferred, not passed. The Poke Floor, Tether, Lever and Laser content sequence is implemented. Source review finds access sharing and Plate actor filters, but no Controller target-default/inheritance commands or deliberate faction/player acquisition path. Recommend completing that previously selected Controller targeting requirement next, preserving per-device overrides. [Concrete choices and boundaries](checkpoints/R4C1_CONNECTED_CONTROLS.md#c382--post-sensor-controller-targeting-discussion-2026-10-21): **1A Controller targeting (recommended) / 1B balance and endurance / 1C another device; 2A Zombies and No One first, explicit player/faction targeting afterward (recommended) / 2B include player/faction targeting in the first slice.** These are proposals, not implementation approval. R1C3 performance, R3C7 balance and R5C1 connected acceptance remain open. **Decision needed.**

**0.2.60 / C381 installed (2026-10-21).** Lever, Laser Sensor, Controller-powered triggers and consumption tooltips are installed. **26,179 assertions**, 148 native construction cases, native write/restart and all three independent-package startup checks pass. Immutable `test/v0.2.60` / `362b30fcee7ac347e5986d2ce3700712f4f2f6ac`; all **330 source and 438 tagged/package/install/archive files** match, with both 0.2.59.1 backups verified. [Patch](PATCH_v0.2.60.md) / [Owner test](TEST_v0.2.60.md) / [Release evidence](../diagnostics/v0.2.60/local-release.json). Native fixtures cover SP/server Lua branches, not rendered or connected-player acceptance; those remain pending. C108 development mirror uses the existing branch/draft PR. No Workshop upload, merge or LootLab deployment. **Test now** after restart.

**C381 / Combined trigger build approved (2026-10-21).** Owner explicitly approves C380: Lever, single-unit laser sensor, all-trigger assigned Controller supply, selected recipes/rates and consumption tooltips. Implementation is underway for 0.2.60. Preserve C375-C380 persistence, Detection, OR-input, obstruction, service and independent-package rules. Installed 0.2.59.1 remains unchanged until validated/tagged installation; no new runtime acceptance or publication is claimed. **Wait for a patch.**

**C380 / Raw-component sensor package selected; consumption tooltips requested (2026-10-21).** Owner selects C379 **1A**, including its common numeric balance/service package, and asks whether Button is Minimal and other triggers Very Low. [Selection and rating review](checkpoints/R4C3_BEAM_SENSOR.md#c380--recipe-selected-and-consumption-tooltip-review-2026-10-21) records the raw-component recipe and tooltip requirement. Existing head bands are per real hour: at a 60-minute game day, Plate/Lever are Minimal (0.24%/real hour), laser Very Low (2.4%/real hour). Recommend preserving those bands, explicit game-hour costs and Controller source; Button Minimal is a qualitative per-press description, not an invented hourly firing cadence. No consumption increase merely to reach a label. This recommendation is not an owner-selected change to rating semantics. Planning only; combined build approval and implementation remain pending, installed 0.2.59.1 unchanged. **Wait for a patch.**

**C379 / All-trigger Controller power selected (2026-10-21).** Owner selects C378 **1A**, adding very low active electricity use for mechanical triggers, and selects **3A**: walls/closed doors shorten the laser without firing. Buttons, Plates, Lever and laser will require powered assigned Controllers; Poke Floor/passive hazards stay independent. [Final proposed balance and crafting package](checkpoints/R4C3_BEAM_SENSOR.md#c379--shared-power-and-obstruction-selected-2026-10-21): Button 0.0001% per accepted press; Plate/Lever 0.01% per active game hour; laser 0.10% per powered game hour. Sensor recipe **1A raw components (recommended) / 1B upgrade a Button**, with shared Electricity 2/10 XP/20s and trigger service rules. Numerical balance/recipe are proposals; no gameplay patch approved or installed. **Decision needed.**

**C378 / Laser power/range selected; wider trigger-power review (2026-10-21).** Owner selects C377 **1A / 2A**: assigned Controller supply and adjustable 1-10 tiles. Suggests considering that supply rule for all triggers; this is exploratory, not approval to change Buttons/Plates/Lever. [Tradeoffs and choices](checkpoints/R4C3_BEAM_SENSOR.md#c378--controller-supply-and-range-selected-2026-10-21): new **1A require Controller power for every trigger / 1B require it only for laser/electronic sensors (recommended)**. Existing basic inputs currently have no Controller-power gate. Prior obstruction choice **3A shorten at walls/closed doors without firing (recommended) / 3B closed doors also trigger** remains unanswered. Mechanical Poke Floor is not a trigger and stays independent. No gameplay/install change; 0.2.59.1 testing remains deferred. **Decision needed.**

**C377 / Single-unit visible beam selected (2026-10-21).** Owner selects C376 **1B / 2A**: one wall-mounted forward sensor, no reflector, with a faint beam visible while powered. [Next beam choices](checkpoints/R4C3_BEAM_SENSOR.md#c377--single-unit-visible-beam-selected-2026-10-21): **1A assigned Controller supply / 1B local ordinary Battery plus Controller fallback; 2A adjustable 1-10 tiles / 2B adjustable 1-20 tiles; 3A walls/closed doors shorten the monitored line without triggering / 3B closed doors also trigger**. Recommend A for each. These are proposals; exact consumption and crafting remain to review after selection. Lever stays settled; no implementation approval or installed-build/test change. **Decision needed.**

**C376 / Discuss laser before build approval (2026-10-21).** Owner asks whether to discuss the laser now or approve Lever first. Recommend discussing R4C3 now and considering one combined build after laser design/native feasibility are settled. Lever choices remain selected, not reopened. [Beam discussion](checkpoints/R4C3_BEAM_SENSOR.md): **1A emitter plus passive reflector (recommended) / 1B single-unit forward sensor; 2A faint visible beam while powered (recommended) / 2B beam shown only during setup/selection**. DESIGN.md already specifies ON while interrupted, OFF when clear, without inherent friend/foe identity. Power, range, mounting details, obstruction/fault handling and recipe remain to settle. No implementation approval or new test claim. **Decision needed.**

**C375 / Lever choices selected (2026-10-21).** Owner selects C374 **1A / 2A / 3A**: wall-only, Button-equivalent crafting, placed latch persistence with pickup/reset OFF. Owner adds a **faint green light while ON, no light while OFF**. [Settled contract](checkpoints/R4C1_CONNECTED_CONTROLS.md#c375--lever-selections-and-on-light-2026-10-21). Existing Detection/Firing, OR inputs, finish-current-action and trigger service rules remain. No further design choice is needed for this slice; implementation/native light verification and rotary Detection correction belong in the next approved patch. No new gameplay build or test claim; installed 0.2.59.1 remains deferred. **Wait for a patch.**

**C374 / Testing deferred; Lever discussion (2026-10-21).** Owner cannot test 0.2.59.1 and asks to continue. Installed build and rendered/connected acceptance remain unchanged. Recommend completing the requested Lever before R4C3 beam sensors. [Lever choices](checkpoints/R4C1_CONNECTED_CONTROLS.md#c374--lever-content-choices-2026-10-21): **1A wall-only / 1B wall-or-floor; 2A Button-equivalent crafting / 2B convert a Button plus one Scrap Metal; 3A retain latch while placed, reset OFF on pickup / 3B preserve latch through pickup**. Recommend A in each case. These are proposals, not selected content or patch approval. **Decision needed.**

**0.2.59.1 / C373 installed (2026-10-20).** Approved placement/wall corrections, Rotary Blades x2 / Lobber x1.5, seven consumption bands, owner Performance icons and five native module categories are installed. **26,133 assertions**, 84 native construction cases, write/restart and all three package startup checks pass. Immutable `test/v0.2.59.1` / `810c5768f09c93edb696435a91e78f290f881fb5`; all **322 source and 422 tagged/package/install/archive files** match, with both 0.2.59 backups verified. [Patch](PATCH_v0.2.59.1.md) / [Owner test](TEST_v0.2.59.1.md) / [Release evidence](../diagnostics/v0.2.59.1/local-release.json). SP/server Lua branches use native objects with synthetic square lookup; rendered/connected acceptance remains pending. C108 development mirror uses the existing branch/draft PR; no merge, LootLab deployment or Workshop upload. **Test now** after restart.

**C369 / Repair mapping and Controller timing approved (2026-10-20).** Owner selects **1A / 2A**: the family-specific one-material/one-tool mapping and Controller **5s place/pickup, 10s repair**. Source/generated packages implement authoritative repair costs, category pickup/repair timing, category SP portable placement and exact carried condition. Mixed fresh/damaged Bed inputs retain their own health even in reverse callback order; paired barriers/wire share one recovery claim. **26,069 assertions**, 256 compiled files, 1,117 translation keys and independent-package checks pass. Native server write and fresh-process read pass, including exact private condition, mixed Bed callbacks and Controller/Poke recovery; rendered/connected acceptance remains pending. [Selected contract and implementation boundary](SERVICE_RULES_C368.md#c369--approved-mapping-and-implementation-2026-10-20). Exact MP native placement duration remains unfinished: installed 42.21 BuildAction ignores recipe/cursor timing. Tether/Lever integration remains queued. Installed 0.2.58 and its immutable tag are unchanged. **Wait for a patch.**

**C368 / Service rules and condition retention selected (2026-10-20).** Owner sets traps **2s place/pickup, 4s repair**; triggers **1s place/pickup, 2s repair**; turrets **5s place/pickup, 10s repair**, superseding the opening general ten-second statement. One consumed material per repair, except tool-only triggers; one retained tool each. Exact condition must survive moving/redeployment. [Source audit and concrete choices](SERVICE_RULES_C368.md) confirms full-health resets for Spike Barriers, Bed Spikes and Concertina Wire, existing exact turret state and rounded Controller/trigger state. Proposed **1A family-specific material/tool pairs (recommended) / 1B Scrap Metal + Wrench for all paid repairs**; **2A Controller 5/5/10 (recommended) / 2B 2/2/4**. Specific pairs and Controller category remain unselected. No new code/install or timing/retention test claim; C367 corrections remain staged for the next release. **Decision needed.**

**C367 / Tether split damage and uniform repair requirements (2026-10-20).** Owner selects one-Scrap Tether repair, revises combat to **30 impact + 15 pull after a 0.75-second hold**, and lowers Poke Floor to **45**. [Repair audit](REPAIR_AUDIT_C367.md) covers every custom repair path and native/shared-health exceptions. Source/generated packages now give all custom Repair entries uniform materials/tools/skill/time/result tooltips; Poke material counts share its authoritative selector and its label is Repair. Existing other repair costs stay unchanged. Poke default/runtime fallback are 45; saved Sandbox overrides remain. **25,945 assertions**, 256 compiled files and independent-package checks pass; rendered/connected acceptance remains pending. Tether combat is selected but full integration is unfinished; installed 0.2.58 remains unchanged. **Wait for a patch.**

**C366 / Tether balance and crafting selected (2026-10-20).** Owner selects C364 **1A / 2A**: 35 damage, six-tile reach, 100 condition, four weight and the reviewed Mechanics 2 / 20 XP mechanical recipe. Requests comparison with Poke Floor cost/range/DPS/AoE. [Source-based comparison](checkpoints/R4C2_DART_EMITTER.md#c366--tuning-and-recipe-selected-poke-floor-comparison-2026-10-20) supports the selected package: Poke deals 50 to each eligible zombie on its tile per 1.5-second cycle; Tether is single-target with ideal ~47.7/25/14.6 DPS at 1/3/6 tiles. These are calculations, not measured endurance. One proposed correction remains: **1A one Scrap Metal per full Tether repair (recommended)** versus **1B retain selected free repair**; Poke consumes two for its 200 condition. No repair change is silently selected. Integration remains authorized and unfinished; installed 0.2.58 and C365 tooltip patch status are unchanged. **Decision needed: repair adjustment.**

**C365 / Head tooltip cleanup (2026-10-20).** Owner requests removal of the redundant head-only explanation and repair of the missing space before Medium. Both are fixed in source/generated packages; colored ratings and battery balance remain unchanged. Full-line measurement preserves the interior space and caches its offset. **25,918 assertions**, 252 compiled Lua/translation files, native translation and package-independence checks pass; rendered acceptance remains pending. [Evidence](TOOLTIP_C365.md). Installed 0.2.58 is unchanged; corrections await the next gameplay patch. C364 Tether integration and its remaining tuning/recipe choices remain open. **Wait for a patch; Tether decisions needed.**

**C364 / Tether Dart Trap and prototype cleanup (2026-10-20).** Owner selects damage-only **1B**, first-hit player collateral **2A**, the name **Tether Dart Trap**, and a wall panel firing outward in one of four placement directions. Owner reports prototype success; console confirms 13 zombie impacts, not connected MP acceptance. Removed the exact verified six-file debug mod from the game directory, preserving it in project diagnostics. Ported inactive cycle/collision/wall-geometry modules into Traps; **32 new native + 41 regression assertions** and package checks pass. Actual playable item, Controller/lifecycle wiring and injury settlement are not delivered yet; 0.2.58 remains installed. [Evidence and remaining tuning/recipe choices](checkpoints/R4C2_DART_EMITTER.md#c364--tether-dart-trap-selected-prototype-retired-2026-10-20): new **1A 35 damage (recommended) / 1B 50**, shared six-tile/tested-cycle/100-condition/four-weight proposal; **2A Mechanics 2 / 20 XP (recommended) / 2B Mechanics 1 / 10 XP**, same proposed mechanical materials/tools. No new stats/recipe selection, tag or gameplay install. **Decision needed.**

**C363 / Next emitter checkpoint (2026-10-20).** Recommend integrating the installed tether prototype into the wall-mounted trap with Controller links and persistence. [Combat choices](checkpoints/R4C2_DART_EMITTER.md#c363--next-checkpoint-and-combat-choices-2026-10-20): **1A 25% retraction knockdown with five-second repeat protection (recommended)** / **1B damage only**; **2A zombie sensing with player first-hit collateral (recommended)** / **2B zombies-only collision/damage**. All new values are proposals, not selected or measured balance. Rendering/live multiplayer remain pending; deferred testing does not block approved independent development. Lever remains queued, beam sensors follow emitter. Planning only; 0.2.58 and debug prototype 0.0.1 unchanged. **Decision needed.**

**C362 / Tether prototype installed (2026-10-20).** Owner approved installation after the status clarification. Installed the separate **OMH Tether Prototype (Debug Only)** / `OMHTT_TetherPrototype` **0.0.1** in `C:/Users/bandi/Zomboid/mods/OMHTT_TetherPrototype`; all six files match C361 native-tested source/preview by SHA-256. No existing mods/saves changed and no save auto-enabled; main release remains 0.2.58. [Owner test and install evidence](TETHER_PROTOTYPE_C361.md#c362--owner-approved-local-installation-2026-10-20). SP requires debug mode; no damage, markers expire after 60 seconds. 41 native assertions passed previously; rendered/connected acceptance pending. **Test now.**

**C361 / Scripted tether prototype approved and built (2026-10-20).** Owner selects C360 **1A**. The isolated debug package implements a single nail, swept first-hit collision, full retrieval/reset, corrected detection/input modes, server authority and client cable interpolation; no damage or gameplay integration. **41 native-runtime assertions pass**, including native actor/square fixtures, authorization, message ordering and authority-session renewal; client Lua compiles. [Prototype and evidence](TETHER_PROTOTYPE_C361.md). Rendering and connected-client acceptance remain pending; the clean preview ZIP matches tested source. No final balance/recipe/knockdown selection, installed-package change or version bump; 0.2.58 unchanged. **Wait for a patch.**

**C360 / Physical tether investigation completed (2026-10-20).** Owner selects C359 1B and conditionally authorizes the physical approach if feasible. Installed 42.21 bytecode and a 46.1-second isolated Lua API probe verify vehicle towing access but no direct Bullet/WorldSimulation/luajava globals. The vehicle route requires two vehicles, has no found winch/rope-length setter, and carries vehicle collision/persistence/client simulation ownership; animal leashes do not provide a rope solver. No physical or connected-client tether was tested, and production feasibility is not established. [Evidence and recommendation](TETHER_FEASIBILITY_C360.md): **1A scripted prototype (recommended)** / **1B defer the retractable trap**. Neither fallback selected. Probe tooling/documentation only; 0.2.58 unchanged. **Decision needed.**

**C359 / Tether feasibility reviewed (2026-10-20).** Installed bytecode confirms a rope constraint used by vehicle towing; arbitrary nail/zombie tether support is unproven. Existing projectile visuals, obstruction checks and knockdown routing support a scripted approach, pending a rendered/connected prototype. [Evidence and choices](checkpoints/R4C2_DART_EMITTER.md#c359--tether-feasibility-review-2026-10-20): **1A scripted-tether prototype (recommended)** / **1B investigate true physical tethering**. Neither newly approved; knockdown remains TBD and 0.2.58 unchanged. **Decision needed.**

**C358 / Single nail and input override confirmed (2026-10-20).** Owner selects C357 **1A: one tethered nail per cycle** and corrects detection: default autonomous sensing; connecting any trigger disables sensing and requires an input. Linked activation does not require a detected target. This supersedes C356/C357 detected-target gating. Removing the last input restores default sensing. Button requests one cycle; held Plate/Lever repeats only after full return/reset. No piercing, consumable ammunition, batteries or modules; knockdown remains TBD. [Current contract](checkpoints/R4C2_DART_EMITTER.md#c358--single-nail-and-trigger-override-2026-10-20). Design recorded only, not gameplay implementation approval; installed 0.2.58 unchanged.

**C357 / Retractable dart trap selected (2026-10-20).** Owner selects C356 **1A linked-input activation** and replaces consumed nail ammunition with reusable long nails that retract/reload fully before refiring. No enemy piercing; retraction knockdown is explicitly TBD. Wall-only, autonomous when unlinked, no batteries and no modules remain. [Updated contract and firing-pattern choice](checkpoints/R4C2_DART_EMITTER.md#c357--retractable-trap-replaces-consumable-darts-2026-10-20): **1A one tethered nail per cycle (recommended)** / **1B three-nail volley, all return before refiring**. Neither new pattern is selected; recommend cycle/wear balancing and defer knockdown tuning. No gameplay changes or implementation approval; 0.2.58 testing remains pending. **Decision needed.**

**C356 / Next checkpoint (2026-10-20).** Owner asks what follows 0.2.58. Continue R4C2 Dart Emitter discussion with settled wall-only/nails/autonomous/no-battery/no-modules rules. [Optional-input choices](checkpoints/R4C2_DART_EMITTER.md#c356--next-checkpoint-and-optional-input-decision-2026-10-20): **1A linked triggers arm detected-target firing (recommended)**; **1B autonomy stays active and inputs request ordinary-cadence straight-ahead shots**. Neither is selected. Lever remains queued, beam sensors follow the emitter, and 0.2.58 rendered/connected acceptance remains pending. No gameplay or installed-version changes. **Decision needed.**

**0.2.58 / C355 installed (2026-10-20).** Approved tier battery surcharges, firearm x1.5/Scrapshot x1.25 factors, Siphon 45% chance, colored head consumption ratings and mechanical Poke Floor/Building corrections are delivered. **25,906 assertions**, native write/read and Traps-only/Turrets-only/both startup checks pass. Installed from immutable `test/v0.2.58` / `befd7291a328e0edb5fb7c2f214ee063a029ad44`; all 308 source and 402 tagged/package/install/archive files match, with both 0.2.57.2 backups verified. [Patch](PATCH_v0.2.58.md) · [Tests](TEST_v0.2.58.md) · [Release evidence](../diagnostics/v0.2.58/local-release.json). Rendered/connected acceptance remains pending. Lever and Dart Emitter retain unresolved content choices and are not included. C108 development mirror uses the existing draft PR; no merge, LootLab deployment or Workshop upload. **Test now.**

**C355 / Patch approved (2026-10-20).** Owner approves implementing settled C354 battery balance, C351 Siphon chance, head-only consumption labels, and C345–C346 mechanical Poke Floor/Building corrections as 0.2.58. Lever and Dart Emitter remain planned with unresolved content details; no recipes or stats are invented. Implemented as 0.2.58; 25,906 assertions, native write/read and all independent package selections pass. Tagged installation is next; 0.2.57.2 remains the rollback baseline. Rendered/connected acceptance is pending. No Workshop upload or merge.

## C354 — Explicit tier surcharge replacement

Owner supplies 10%, 15%, 25%, 50%, 75%, 100%, 150% in the preceding rarity-table order. [Selected replacement schedule](BATTERY_BALANCE_C349.md#c354--owner-replaces-the-tier-surcharge-schedule) supersedes C353 tier values without changing head factors, loot tuning, Siphon or exceptions. Planning persisted; no installed gameplay change.

## C353 — Gentler head and tier values confirmed

Owner selects C352 1A and requests per-module battery multipliers. [Selected exact values and source-backed surcharge table](BATTERY_BALANCE_C349.md#c353--gentler-values-selected-per-module-surcharge-audit). Head balance and tier adjustments are settled for the pending patch. No code/install or unresolved recipe approval inferred from this informational follow-up.

## C352 — Gentler combined balance, colored head rating and recap

Owner wants smaller family-level head increases and then a modest higher-tier module increase, explicitly retaining purposeful DPS/effect differences. Adds colored Low/Medium/High head battery consumption tooltip. [Selected direction, proposed exact values and recap](BATTERY_BALANCE_C349.md#c352--gentler-hybrid-balance-and-consumption-labels-2026-10-19). C351 aggressive values are superseded proposals, not approved tuning. New 1A/1B numbers need confirmation; no code/install or unreviewed recipe change.

## C351 — Siphon selection and head consumption comparison

Owner selects the prior 1A (45% / 2x, +1x per additional module), then requests comparison of higher-tier module penalties versus head consumption, including Ballista, Scrapshot, modded M4 and a cheap pistol. [Audit and proposed drain choices](BATTERY_BALANCE_C349.md#c351--siphon-selected-head-versus-module-comparison-2026-10-19). Siphon is selected for pending patch; proposed firearm x3/Scrapshot x2.5 costs are not selected. No code, save, installed package, loot tuning or publication change.

## C350 — Lever requested; Detection firing condition clarified

Owner requests a latched power-switch trigger and confirms that Detection-equipped turrets wait for detection to provide a target. [Lever contract and current rotary exception](checkpoints/R4C1_CONNECTED_CONTROLS.md#c350--lever-trigger-requested-2026-10-19). No implementation claim or unreviewed recipe selection.

## C349 — Saved M4 drain audit and Siphon alternatives

Owner asks about 75%/1.5x, leans toward earlier 1B, requests a saved-turret battery baseline without Siphon/Regulator and clarifies real versus game time. [Evidence, calculation and comparison choices](BATTERY_BALANCE_C349.md). Result is approximately one real unpaused hour from full under continuous-fire assumptions, around 16 game hours at the saved day length. No measured endurance claim. Chance discussion reopened; no new value selected. No gameplay or save mutation.

## C348 — Siphon 60% proc requested; multiplier tradeoff pending

Owner requests a 60% chance and stacking that enables sustained power. The current 2x first refund can still sustain at that chance. Recommend 1x first/+1x per additional module, with one shared roll per eligible kill; owner selection of the multiplier is pending. Preserve Synergy gating, turret-local source restriction and loot tuning. [Contract and exact choices](MODULAR_TURRETS.md#c348--siphon-proc-chance-and-sustain-balance-2026-10-19). Planning only.

## C347 — Wall-only, nail-fed, autonomous dart emitter

Owner selects C346 1B/2B/3B and explicitly requires built-in forward detection without batteries or mandatory external triggers. Optional trigger support remains; camera flavor is tentative. [Selected contract and remaining design](checkpoints/R4C2_DART_EMITTER.md#c347--wall-only-autonomous-emitter-selected-2026-10-19). No gameplay patch this turn; mechanical Poke correction remains queued.

## C346 — Poke recipe 1A selected; dart emitter foundation proposed

**C346 / Mechanical Poke Floor recipe selected; dart emitter discussion (2026-10-19).** Owner selects C345 **1A**; Poke Floor correction scope is settled and pending implementation. [Dart emitter choices](checkpoints/R4C2_DART_EMITTER.md): **1A floor-mounted / 1B wall-mounted; 2A crafted metal darts / 2B nails; 3A local car battery then Controller bank / 3B no electrical consumption**. Recommend A for each; these are proposals, not selected balance or implementation approval. Retain the existing single-Button/held-input cycle model and no trap modules. Installed 0.2.57.2 remains unchanged; R4C3 sensors follows. **Decision needed: emitter foundation.**

## C345 — Building visibility, Triggers naming and mechanical Poke Floor

**C345 / Building audit and pressure-driven Poke Floor (2026-10-19).** Owner reports 0.2.57.2 seems functional. Confirmed missing Poke Floor hybrid Building registration and 88 missing inventory-title warnings. Owner requests OMH: Triggers and mechanically pressure-driven Poke Floor with no battery/grid/Controller energy. [Audit and recipe choices](checkpoints/R4C2_POKE_FLOOR.md#c345--building-audit-and-pressure-driven-poke-floor-2026-10-19): **1A remove electrical materials/skill/XP (recommended)**; **1B retain recipes, remove operational power only**. No gameplay/install change this audit turn. Next content: fixed dart emitter (R4C2), then beam sensors (R4C3). **Decision needed: recipe scope.**

## C343 - Fewer module categories requested (2026-10-19)

Owner requests tighter grouping than seven categories: direct numerical upgrades together, with 360/Filter under Automation. [Four-category recommendation and three-category alternative](MODULAR_TURRETS.md#c343---compact-category-options-2026-10-19). Names and exact classification remain proposals; no sorting/gameplay implementation approval. C342 layout selections remain separate and unchanged.

## C342 — Native compact Manage layout selected (2026-10-19)

Owner answers 1A / 2A / 3A to C341: native compact chrome, narrower balanced Manage, inline Details with a content-aware minimum height. [Selected contract](UI_AUDIT_C341.md#c342--owner-selections-2026-10-19). Layout decisions are settled; implementation approval remains pending. No gameplay/package/install change in this selection turn.

## C341 — UI owner test and choices requested (2026-10-19)

Owner reports 0.2.57.1 title-bar mismatch, apparently unlinked trigger requirement, blank module margins and disappearing controls on Details resize. Explicitly requests discussion/options before patching. [Source-backed audit, proposals and recommendations](UI_AUDIT_C341.md). None of the new layout options is selected yet; no gameplay edits authorized by this discussion.

## C340 — Owner-test corrections requested (2026-10-19)

Owner requests removal of locking/pinning, corrected window framing and compact 4/4/4/4 modules, equal action buttons, power investigation, Poke Floor technical texture, player-built wall support, game-speed-aware five-second pickup/placement, consistent Connections formatting and light-switch audio. Implemented correction scope and the unresolved native multiplayer placement duration are recorded in [0.2.57.1](PATCH_v0.2.57.1.md). Standing C108 covers local installation and GitHub mirror; no merge or Workshop upload.

## C339 — Poke Floor and power patch approved (2026-10-19)

Owner approves the final C333–C338 recap. Implement contact-only Poke Floor, car-battery Controller bank, assigned fallback, battery-default turrets and Mythic Grid Module at assigned weight 1; preserve owner LootLab overrides. [Implementation](PATCH_v0.2.57.md) and [verification](TEST_v0.2.57.md). No Workshop upload or merge.

## C326 — Controller organization and feedback follow-up (2026-10-18)

Owner requests confirmation/mockups for UI feedback, connection grouping/reordering, Manage/context corrections, LootLab ordering/density and native Stockpile overflow. [Contract and 1A shared / 1B personal organization choice](CORRECTIONS_C326.md). Planning only; no new gameplay approval or version bump inferred.

## C325 — Controller corrective interaction and polish (2026-10-18)

Owner directly requests three connection gestures, defense disconnect handles, visible links, condition/ammo rows, darker inset lists, taller initial height, stable resizing with /// corners and a right-edge native Stockpile scrollbar. Remove redundant Connect controls after gesture support. [Contract](CONTROLLER_MAP_C316.md#c325--connection-gestures-and-controller-polish-2026-10-18). Multiple-input removal offers a choice of the individual connection; no blanket disconnect or new signal semantics. Implemented, validated and installed as [0.2.55.2](TEST_v0.2.55.2.md); rendered and connected acceptance remain pending.

## C313 — Siphon Module name and final wording (2026-10-18)

Owner: **“6A - instead of ‘the attack’s’ we’ll use ‘the shot’s’.”** Select **Siphon Module** with **“Feature: Kills restore 2× the shot’s battery cost.”** and **“Stackable: +1× refunded per module.”** [Final contract](CORRECTIONS_C310.md#c313--siphon-module-name-and-final-wording). This settles the remaining naming choice without altering per-kill eligibility, Synergy requirements or actual paid rotary swing/pass accounting. All C310–C312 corrective scope remains queued; no gameplay/version/install change or new test claim. Standing C108/C119 covers the documentation mirror.

## C312 — Rotary Synergy selected; Sap naming question (2026-10-18)

Owner explicitly selects **5A**, approving Synergy on rotary heads for supported effects while retaining unrelated module exclusions. Owner asks whether **Sap Module** better describes the energy-refund feature than Leech, whose health/repair association is misleading. [Comparison and proposed wording](CORRECTIONS_C310.md#c312--rotary-synergy-approved-battery-refund-naming): recommend **6A Siphon Module**, with **6B Sap Module** as an alternative; neither new name is selected yet. No formula/eligibility change and no additional gameplay decision. All C310/C311 corrective scope remains recorded. Planning only, installed 0.2.53.11 unchanged; standing C108 mirror applies.

## C311 — Grouped Controller and Leech/Synergy selections (2026-10-18)

Owner selects **1A, 2B, 3A, 4A**, explicitly requiring Synergy for Leech refunds from Splitter, Fragment, Martyrdom and other secondary effects. Confirm Grouped layout, per-kill 2x/+1x stacking refunds (not once per shot), one additional 50%-damage Martyrdom generation, and rotary refunds based on actual paid swing/pass energy. [Contract](CORRECTIONS_C310.md#c311--confirmed-selections-and-rotary-compatibility). Source review identifies the existing rotary Synergy exclusion alongside supported Martyrdom/Tack. Present **5A enable Synergy for supported rotary effects (recommended)** versus **5B retain exclusion/direct-kill-only rotary Leech**. This interaction is not silently settled by 4A. No gameplay/version/install change; preserve all C310 findings and deferred acceptance. Standing C108 covers this planning mirror.

## C310 — Owner test findings, Controller alternatives and module discussion (2026-10-18)

Owner reports plate/player ordering, missing pickup animation, Controller access from turrets, invisible incoming links, eight-pixel Manage inset, module replacement/pulse needs and Set Facing errors. Requests **Set Aim**, explanatory Open Manage/Unassign tooltips, then adds missing **To Stockpile / To Inventory** tooltips. Owner asks for three Controller redesigns and **A/B/C = designs, D = original, E = another three**. New proposed module refunds 2x paid shot power on kill, +1x per stack; Synergy should permit one self-chain at 50% damage. [C310 evidence, mockups and open decisions](CORRECTIONS_C310.md) records exact causes, semantic tradeoffs and recommendations. No redesign/module-default choice or gameplay patch approval inferred. SP 0.2.53.11 findings supersede its pending rendered acceptance; immutable tags remain unchanged. Standing C108 requires this planning/test-evidence mirror.

## C309 — Inset pressure plate with activation feedback (2026-10-18)

Owner asks to make the plate visually slightly smaller than one tile and press down while activated, like Minecraft. This is implementation authorization. Use two native sprite states with about 85% width, six-pixel released height and one-pixel pressed height in the existing neutral technical placeholder style. Keep full-tile occupancy, filtering, power/signals, durability and non-thumpability. Existing plates convert when bound; server owns state and publishes native sprite changes only on transitions. No new gameplay/recipes, art direction, per-frame animation or sensors. [Patch](PATCH_v0.2.53.11.md) and [verification](TEST_v0.2.53.11.md). R4C2 remains next.

## C308 — Implement plate, linking and Set Facing corrections (2026-10-17)

Owner says "Patch", authorizing implementation, verification, local installation and development mirroring of C306/C307. Preserve 1A Set Facing with normal Detection, matching FoV and no implicit shot; existing plates and future passive sensors use native non-thumpable behavior. Keep current control permissions, package independence and power semantics. [Patch](PATCH_v0.2.53.10.md), [tests/delivery](TEST_v0.2.53.10.md). No new trap content, recipes, Manual Aim Lock, merge or Workshop publication. R4C2 Poke Floor stays next; rendered/connected acceptance is pending.

## C307 — Controller Set Facing selected (2026-10-17)

Owner replies "1A" to C306: save normal facing and rotate its firing/detection sector together, retaining normal Detection tracking and 360 coverage. Direction selection does not shoot. Preserve power/access/range/identity checks and no physical turning while OFF. Manual Aim Lock is not selected. [Confirmed next-patch contract](CORRECTIONS_C306.md#c307--confirmed-aiming-behavior). Record alongside non-thumpable plates and clearer linking; no gameplay/version/install change in this planning turn. R4C1 corrections precede R4C2 Poke Floor; connected acceptance remains pending.

## C306 — Pressure-plate feedback, Controller aiming and checkpoint reconciliation (2026-10-17)

Owner reports tentative success, functional pressure-plate activation, confusing linking and zombie thumping. Requires non-thumpable plates and the same rule for future sensors; requests selecting a Controller turret then clicking a world direction to aim. Queue for the next patch. [Contract and subsequent selection](CORRECTIONS_C306.md): recommend1A saved facing plus sector rotation with normal Detection;1B manual aim lock is the alternative. The subsequent C307 reply selects 1A. R4C1 remains corrective work; R4C2 Poke Floor is the next selected content, followed by fixed dart emitter and R4C3 beam sensors. Record the actual0.2.53.9 SP console and owner evidence separately from connected MP acceptance; no gameplay patch in this discussion turn.

## C305 — Implement context-aware empty-slot silhouettes (2026-10-17)

Owner says "Patch" after selecting C304/1A. This authorizes immediate implementation using existing normal icons tinted black, overriding the earlier future-art scheduling. Preserve native texture alpha, category labels, current-head ammo/removable-magazine matching, built-in/locked/not-needed distinctions and empty Void requirements. Ordinary filled slots retain real items and color. Use cached texture references and native drawing; no extra PNGs, dummy hint items, per-frame lookup/scan or multiplayer messages. Keep the grey theme, existing multiple Controller batteries and capacity rules. Placeholder custom icons remain until owner art replaces them. [Patch](PATCH_v0.2.53.9.md) and [test/evidence](TEST_v0.2.53.9.md) distinguish automated verification from pending visual/connected acceptance.

## C304 — context-aware silhouettes from normal icons, 2026-10-17

Owner: "1A if it can be done by taking normal icons and blacking them out." Select1A with black tint applied to existing icon textures, preserving alpha and original artwork. [Native feasibility evidence and contract](UI_EMPTY_SLOT_HINTS_C303.md#c304--normal-icons-blacked-out-2026-10-17). No extra silhouette files, generated art, inventory items or per-frame image processing. Retain the original future icon/art-pass timing and compatibility exceptions. Native API feasibility is confirmed; rendered readability still needs checking after implementation. No new patch or gameplay acceptance is inferred.

## C303 — future empty-slot silhouettes discussion, 2026-10-17

Owner: "Once we add icons and art for the other assets, can we add silhouettes to the other empty slots too, like the head, ammo, magazine, and expansion slots, so players know what goes where? Discuss." [Proposed mapping, compatibility exceptions and1A/1B choice](UI_EMPTY_SLOT_HINTS_C303.md). Recommend context-aware faded icons with supplied/native art, preserving labels and non-insertable/locked states. Discussion is not implementation approval or a new acceptance result.0.2.53.8 remains installed; no Source/Contents, test evidence, Workshop changelog or version change.

## C302 — Controller battery silhouette and multiple small batteries, 2026-10-17

Owner: "The battery section makes me unsure of which battery to add... add a sillouhette of the item... allow multiple batteries to be stored, since they're so small." Direct implementation request, scoped to the Controller's ordinary Battery. [Contract and implementation](PATCH_v0.2.53.8.md): faded native item icon, stored count and multi-item drop through existing authority. No separate inventory, car-battery expansion or capacity/drain change. Findings explained before implementation: storage and charged-spare selection already exist; the old UI showed only one and stopped after the first dropped battery. C301 grey choice is retained. Validation/delivery/acceptance tracked separately.

## C301: grey replaces copper-orange (2026-10-17)

Owner finds the copper build brown/bland and directly requests returning to grey. This authorizes a color-only correction, superseding C299/C300's accent choice. Use neutral charcoal/grey surfaces, borders, highlights and labels. Retain red/white OMH titles, green/red power states, rarity colors, separate action rows, attached native Stockpile, Battery slot and exact transfers. [0.2.53.7 patch](PATCH_v0.2.53.7.md) / [verification](TEST_v0.2.53.7.md). No general C300 gameplay acceptance is inferred from this aesthetic feedback.

## C300: copper-orange corrective patch approved (2026-10-17)

Owner: "We'll do copper-orange. So instead of the green background accents, we'll use that color I think. Let's try it out. You're approved." Implements the reviewed C297 correction and C298 titles with C299 option 1A: copper-orange #E7A05A / dark #30251B, charcoal bodies, red One More Horde and white menu suffixes. Green/red power states and module rarities stay independent. Attached native Stockpile belongs to Controller rather than moving the player's HUD. Visible ordinary Battery and exact-item transfers are included. [Patch](PATCH_v0.2.53.6.md) and [verification](TEST_v0.2.53.6.md) track implementation separately from installation and rendered/connected acceptance. No sibling edits, merge or Workshop publication.

## C299: OMH family colors audited; T&T accent choice open (2026-10-17)

Owner requests palette comparison before approving the patch. [Source-backed findings and three accent proposals](CORRECTIONS_C297.md#c299--omh-family-palette-audit-and-tt-accent-proposals-2026-10-17): Horde Night red/gold, Cure blue and Trait Shop green identities; native menus also share red/gold. Recommend 1A copper-orange, alternatives 1B violet / 1C steel. Preserve C298 red brand/white menu title, power semantics and rarity colors. No accent selected, sibling change, gameplay patch or installation.

## C298: One More Horde menu-title branding (2026-10-17)

Owner requests `One More Horde - Turret Management Menu` and `One More Horde - Controller Menu`, with red brand text and white separator/suffix. Existing Horde Night title RGB 0.85/0.25/0.25 verified; editable preview updated. [Exact requirement and implementation notes](CORRECTIONS_C297.md#c298--one-more-horde-title-branding-2026-10-17). Owner's "Once confirmed, we can approve" reserves final patch approval; no gameplay change or install this turn.

## C297: attached native Stockpile and clearer Manage controls (2026-10-17)

Owner reports 0.2.53.5 mostly working and requests a Controller battery slot, clear section/action separation, red/green power feedback and direct Manage/Stockpile drag transfers. Requests paired mockups, then explicitly clarifies the Stockpile must be a dedicated component connected to the Controller menu, not the player's repositioned HUD. [Findings, proposal and evidence](CORRECTIONS_C297.md). Preserve the native list/item system with a scoped adapter, exact inventory and existing authority/capacity. Read-only audit and mockups completed; layout proposal awaiting review, no new implementation/install or blanket acceptance implied.

## C296: expanding Details, grouped Load Order and Controller reach correction (2026-10-17)

Owner directly requests Module Stats inside + Details, vertical expansion instead of whole-menu scrolling, category tooltips/removal of the drop hint, and a full-size grouped Load Order page. Owner reports disabled Assign/Open Manage and clarifies Access/Connections require standing inside the Controller world tile. Implement these corrections with existing ownership/power authority; no new recipe/balance decision. [Contract, evidence and limits](PATCH_v0.2.53.5.md). Owner separately reports C295 launch slowdown solved; exact cause remains unconfirmed. Rendered/connected acceptance is not inferred.

## C295: investigate launch and whole-PC slowdown (2026-10-17)

Owner asks why launching/playing now slows the whole PC; clarification is "Starts on the main menu, stops on exit or minimize." Read-only process/resource, log, display-setting and current-hook inspection is authorized. [Evidence, uncertainty and recommended comparison](LAUNCH_LAG_C295.md). No source, display, Java-agent, other-mod or driver change was requested or made. Current 0.2.53.4 loading is confirmed; no completed acceptance result is inferred.

## C294: C293 corrective patch approved (2026-10-17)

Owner: "Approved" following the stockpile clarification, capitalization audit and five recommended corrections. Implement, validate, install and mirror under the established local workflow; no additional gameplay decision is required. [0.2.53.4 implementation](PATCH_v0.2.53.4.md). Preserve defense-only admission and native recovery of existing items. Related validation closes stale remote-stockpile access from local turret proximity and handles synchronized replacement items for native callbacks. Connected and rendered acceptance are still pending, not waived by this approval.

## C293: stockpile clarification, capitalization and corrective proposals (2026-10-17)

Owner asks why backpacks/clothing appeared in the audit, reaffirms turret/trap-only storage, requests a UI capitalization check, and asks to consider solutions to the listed findings. [Reviewed contract and recommended corrections](CORRECTIONS_C293.md). The backpack is a withdrawal destination; clothing describes legacy-item recovery, not admission. Keep the existing scope. Title-case actions/short labels and the five engineering corrections are recommended without a new gameplay decision. This is review/planning, not a new installation or test acceptance. Standing C108/C119 authorize recording and mirroring the findings.

## C292: deferred-test audit (2026-10-17)

Owner: “Unable to test this moment. Audit and check for any issues.” Audit and reproduce current integration/performance defects; preserve the installed patch and pending acceptance. [Five confirmed findings](AUDIT_C292_v0.2.53.3.md). No new gameplay, balance, recipe, art, or feature approval inferred. C108 authorizes mirroring this audit/test record.

## C291: native scrolling and compact management correction (2026-10-17)

Owner explicitly requests implementing and auditing the reported defects. Equipment and Ammunition share a row; Reload/Load Order are adjacent; title is "Turret Management Menu". Keep the shaded headers. Details/module stats must remain accessible. Rename commits on Enter or blur; clearing shows the automatic name in gray; weight shares that row. Controllers have no rename UI. Stockpile accepts defense supplies only, retaining access,500 capacity and removal of pre-existing unrelated items. Controller uses the existing authorized white-cube technical art. Preserve gameplay and server authority; no new approval or owner test blocks implementation. [Implementation/audit](PATCH_v0.2.53.3.md). Owner's report rejects the relevant0.2.53.2 rendered behavior; its automated results are not acceptance.

## C290: single-page Manage, Controller cleanup and native inventory (2026-10-17)

Owner: “Let's switch to the1 tab view instead” and “Please clean everything up. The inventory can use the native zomboid inventory system, not this invented thing.” Supersedes C288's two-tab choice. Authorizes implementation of the reported header/Details/Controller layering defects, reliable window dragging and removal of the custom stockpile browser. Preserve equipment/ammunition layout, module4/6/6, full remote Manage,500 stockpile capacity, read/write access and exact-item server authority. Native inventory lifetime belongs to the player; closing Controller no longer closes a custom child inventory. No balance change or acceptance inferred. [Patch and diagnosis](PATCH_v0.2.53.2.md).

## C289: approved corrective patch (2026-10-17)

Owner: “Approved.” Authorizes implementing the selected C288 two-tab Manage and Controller cleanup, including C286 recursion/window-lifecycle fixes, validation, installation and the standing C108 GitHub mirror. Preserve gameplay, remote authority and exact-item accounting. [Implementation](PATCH_v0.2.53.1.md) | [Checks and short test](TEST_v0.2.53.1.md). Approval does not establish rendered or connected multiplayer acceptance.

## C288: two-tab Manage selected (2026-10-17)

Owner: "1B / Recap the update." Selects the two-tab design from C287, superseding the compact-page recommendation. [Final corrective scope](TEST_FINDINGS_v0.2.53.md#c288--two-tab-manage-selected-update-recap-2026-10-17). Record the choice and recap; no implementation/install/test acceptance is claimed in this discussion turn. Preserve C286 crash correction, approved Controller hierarchy and multiplayer authority. Owner follow-up: "Make sure it's clean and not overwhelming." Record concrete presentation/verification criteria in the same C288 contract; no new feature or design choice is inferred.

## C287: preview both proposed Manage layouts (2026-10-17)

Owner: "Show the designs for both options." [Comparison and browser verification](TEST_FINDINGS_v0.2.53.md#c287--both-manage-designs-previewed-2026-10-17). This authorizes design previews, not selection of1A/1B or a new implementation. Preserve C286 corrections, the accepted Controller direction and pending native/connected acceptance. No balance, authority, installed version or Workshop changes.

## C286: owner UI failures and corrective design discussion (2026-10-17)

Owner reports overlapping Turret Manage framing, blocked dragging under the name controls, excessive complexity, a Controller unlike the approved preview, and a black screen during Controller menu use. [Diagnosis, proposed corrections and one layout choice](TEST_FINDINGS_v0.2.53.md). The native UI-name recursion is independently reproduced; retained logs cannot identify the original trigger. Recommend1A compact single page with expandable detailed stats;1B uses Equipment/Modules tabs. This is a finding/design discussion, not a selection or new patch implementation. Preserve the accepted C284 Controller hierarchy, multiplayer authority and installed0.2.53 evidence; prioritize corrections before R4C2. Standing C108/C119 authorizes mirroring these findings.

## C285: implement the approved connected-controls patch (2026-10-16)

Owner: "Looks good. Approved to patch. Implement the controller, pressure plates, updated menus, and ammo capacity changes. Keep multiplayer in mind and push it to GitHub." This approves C283 storage/capacity rules and C284 menu direction for local implementation, native verification, installation and the standing development mirror. [Implementation](PATCH_v0.2.53.md) | [Tests](TEST_v0.2.53.md). No new approval or owner-test gate; connected/rendered acceptance remains deferred, and no Workshop/main publication is authorized.

## C100: 0.2.31 findings, presentation cleanup and movement revisions (2026-10-07)

Owner requests consolidated Traps settings, consistent naming with **Barbed Panel**, fewer reusable bed/panel textures, fence-side bed placement, bush-like player traversal with sprint-trip/fall injury, recovery for zombies stuck down, increased bed-trip chance, and **40% potato knockdown**. Owner also asks whether to replace Building with crafting plus inventory installation and authorizes a quick live stress-log inspection. [Findings and concrete next-patch scope](TEST_FINDINGS_v0.2.31.md) distinguish direct requests, proposed defaults and verified defects. Craft-only flow, the exact increased bed-trip percentage and player fall-injury defaults remain pending answers; do not infer their approval. Installed gameplay remains 0.2.31 during the active test. No publication is requested.

Owner subsequently selects **2B**, settling zombie Bed Spikes trip chance at **40%** (both tiers); this is separate from the already requested 40% potato knockdown. Player sprint-trip behavior remains under discussion: the owner asks whether it should be native bush behavior. Current installed IsoPlayer bytecode distinguishes bush sprint interruption from the explicit tree/collapsed-fence trip branch, so do not invent a native bush percentage. Building removal remains a question, not approval. After checking vanilla trapping recipes and inventory placement, the revised recommendation is craft-and-place for portable beds/barriers/turret bases, with construction/attachment retained for supported Barbed Panels. This supersedes the blanket recommendation to retain all Building entries; exact flow is still the owner's choice.

## C99: develop backed barbs; host expansion and conditional durability (2026-10-07)

Owner explicitly requests: "Doors, windows, walls, and fences, and you're approved to develop it for the next patch." This authorizes local implementation of the one-tile wooden-frame barbs and the C97 recipe. It supersedes the earlier wall/fence-only host direction. Preserve the held 0.2.30 test, existing cumulative Workshop notes and manual GitHub mirroring; no publication is requested.

When asked how to handle supports without persistent finite HP, owner directs: "If it doesn't have HP or it's infinite, then give the barbs HP and it gets damaged when it deals damage. Deal 1 damage to durability per damage activation, with 50 HP." This explicitly revises the previously universal shared-health rule: ordinary finite, damageable supports share native health, while other supports use a separate 50-HP barb pool. Successful damage activations wear that separate pool by one; neither attachment nor repair adds or heals native support HP. Partial map-fence counters that reset on native reload are not a persistent shared-health pool.

Owner also directs: "Opening doors should have the barbs follow the door. Opening a window does not follow." Move door contact geometry with the native swinging leaf; keep window contact fixed across its opening. Do not disable ordinary door barbs just because the door opens. No additional collision, slowing, trips or player-injury policy is authorized here.

Owner selects "Allow repair too" when offered the otherwise ten-second construction/removal, retained hammer/pliers and no removal refunds/XP defaults. Include repair of the separate barb pool. The implementation recommendation is the existing free, ten-second repair restoring 50; this recommendation is not an owner-specified new recipe. Shared support repairs remain native. Broken zero-HP sections require rebuilding; no repair of stale removed objects. The exact shared-glass versus independent window-frame health choice remains pending: preserving barbs after glass breaks requires frame-based independent durability. Both alternatives can be tested without selecting one for release.

Ordinary single-panel door geometry has a current native API (`getSpriteEdge(false)`). Multi-panel doors may relocate/recreate objects when toggled, and garage doors have different movement; these classes are rejected by the initial helper pending additional native proof, rather than silently damaging their former doorway. This technical limitation was reported to the owner; it does not change the requested eventual host scope.

Owner resolves the window choice with "50 HP on the window frame", then clarifies: "It won't increase the window's HP, it will stay on the window with 50HP until depleted." Window barbs always have independent 50 durability; opening/smashing the glass does not remove them or alter the window's native HP. Removing the actual backing object still removes its attachment. This settles the previously pending window policy above.

Implementation and validation are in [0.2.31](PATCH_v0.2.31.md) and [C99 evidence](checkpoints/R2C3_IMPLEMENTATION_20261007.md). Release/installation status is recorded separately in RELEASE.md.

## C98: proceed with backed-barb native verification (2026-10-07)

Owner replies "approved" after the confirmed one-tile recipe/footprint handoff and the proposed next step of native support-health/contact verification. Proceed with that local investigation; no new recipe confirmation is required for the chosen wooden-frame construction. The turn's stated scope is native verification before gameplay code changes. This approval does not settle unresolved service/player/host-roster policies or authorize remote publication.

The [native feasibility report](checkpoints/R2C3_NATIVE_FEASIBILITY_20261007.md) records successful native API, contact/timer, constructed-health/marker serialization and controlled zombie-crossing checks, plus the map-fence partial-counter reset and limits. Recommended first implementation scope is damageable player-built wall/fence edges; this recommendation is not a newly approved restriction. No gameplay files or installed package changed.

## C97: held playtest, performance audit and wall/fence-backed barbs (2026-10-07)

Owner is away from the PC and holds the 0.2.30 gameplay test while continuing work. This is a deferral, not a pass or waiver. Owner says "approved. also confirm the new pipeline created with github" in response to the proposed performance audit plus barbed-attachment design. Scope is investigation/design and verification of the existing GitHub process; it does not request a new CI workflow, remote push, publication or gameplay installation.

Owner clarifies the barbed host as walls/fences, semi freestanding with a surface required behind it. This replaces the suggested first window/door-barricade host list. When asked about independent barb durability, owner selects "Share the supporting wall/fence health". Preserve the support's existing health pool, with no automatic repair or added HP. Do not silently substitute separate barb durability for hosts without usable health. Host eligibility, native attack/contact detection, damage, footprint, support-loss behavior and recipe/service choices still need proof or discussion. That answer settles health only, not the bundled proposed attack/removal behavior.

Owner then answers "crossing contact" to whether barbs damage zombies only attacking the support or also crossing a supported fence. Owner further specifies: "it should be time based. barbs will always be time based damage when in contact. like 10 damage every 2 seconds". All barb damage uses recurring timed contact, including contact during a crossing; it is not gated on thumps or limited to one hit per crossing. This supersedes the assistant's one-hit-per-crossing recommendation. Use 10 damage every two seconds as the owner's working tuning example, not a separately approved final balance value. Standing in actual contact also qualifies; merely standing nearby does not.

Owner answers "yes" to "should the first hit happen immediately?" Immediate first contact damage is confirmed. Recommend a shared per-zombie two-second interval that persists through brief exits/re-entry and adjacent sections; recheck contact at each hit and stop damage outside contact. Shared cooldown details, player injury and clock semantics still need settlement/native verification. No independent attack/crossing bonus hit or damage-over-time after leaving is implied. Shared support health remains unchanged.

Owner selects "wood frame" from the proposed recipe alternatives. Approve the presented wooden-frame construction materials: one Barbed Wire, two Planks, four Nails and two uses of Wire; retained hammer and pliers; Carpentry 1; 10 Carpentry XP. Wire consumption is two uses, not two full spools. Owner subsequently answers "1 tile" to the width question: confirm one tile-wide section aligned to a single wall/fence segment, retaining these recipe costs. No separate frame HP or host repair is added. Construction duration and servicing remain unresolved.

See [audit results and recommendations](checkpoints/R1C3_PERFORMANCE_AUDIT_20261007.md) and [backed-barb design](checkpoints/R2C3_BACKED_BARBED_SECTIONS.md). Operation counts establish redundant calls, not the cause of client pauses. No gameplay code changed in this checkpoint.

## C96: private GitHub development and Cloud planning process (2026-10-07)

Owner approved: "Approved. Go ahead and create this process." This follows discussion of using the normal full repository like Trait Shop, with Cloud restricted to planning and the PC implementing/testing. Create the private PandizeLive/pz-mod-onemorehorde_turretsandtraps repository, preserve local history, use dev as the initial/default branch and short-lived planning/implementation branches, retain immutable test/v<version> build tags, and reserve main plus official v<version>/GitHub Releases for confirmed official Workshop publication. Initial repository configuration and history/test-tag push are authorized; no gameplay change or Workshop upload is included.

Use one shared set of existing planning documents, explicit proposal/approval/implementation/verification/publication status, and a current handoff. Cloud reads pushed code for context, saves planning changes through PRs into dev when requested, and identifies technical assumptions needing local verification. The local PC reconciles incoming plans before implementation and pushes updated evidence when authorized. No game-version bump or changelog reset follows from documentation-only changes. See [workflow](GITHUB_WORKFLOW.md).

Recorded 2026-09-25 from the current planning conversation. This document is authoritative for approval status, not proof that a feature exists.

## Owner-confirmed requirements

2026-09-25 implementation scope update: the owner requested several more checkpoints back to back before testing, within roughly twenty minutes. This authorizes batching P1C2-P1C4 prototype work while P1C1 player acceptance remains pending. It does not waive acceptance criteria or authorize sibling modifications/publication. See the [batch record](checkpoints/P1_BATCH_RECORD.md).

| ID | Requirement | Source |
| --- | --- | --- |
| C01 | One edition with Sandbox controls; C80 supersedes the single selectable-entry assumption with optional Turrets/Traps packages in one Workshop product. | Owner's single-edition instruction |
| C02 | Potato turret is cheap, quiet, and uses farmable potato ammunition. | Original content pitch |
| C03 | Aim for 3-5 successful direct hits against a reference zombie and higher knockdown chance. Base cadence is one shot per second, interpreted as real time for the prototype. | Original balance correction; latest explicit cadence instruction supersedes very slow firing |
| C04 | Potatoes pop on zombie impact and deal extremely low splash damage for satisfaction. | Latest annotation |
| C05 | Buttons provide a pulse. Pressure plates stay ON while pressed; laser sensors stay ON while blocked. | Owner's signal correction |
| C06 | Poke Floor means spikes extend, poke, and retract. Do not create a duplicate retractable-strip feature. | Owner's clarification |
| C07 | Defense XP is one reduced pool split across all faction members, subject to eligibility details still to decide. | Latest owner instruction |
| C08 | Include offline faction members through a toggle, default enabled. | Latest owner instruction |
| C09 | Follow Trait Shop's score-reduction approach rather than making separate editions/categories the intended product. | Owner's scoring direction |
| C10 | Put Cure defense simulation last. It is not a first-release dependency. | Latest annotation and request to formalize phases |
| C11 | Create local project documents, phases, checkpoints, and supporting folders/files now. | Latest explicit authorization |
| C12 | A control unit lets the player change targeting for an individual compatible defense or all compatible linked defenses, including players, other factions, or no one. Devices without smarts do not follow these filters. | Owner's control-unit clarification, narrowed by C13 |
| C13 | Objects without smarts ignore control-unit target filters. Passive hazards do not acquire faction recognition, immunity rules or remote disarming from a targeting selection. | Owner's passive-object clarification |
| C14 | Players automatically jump over bed spikes. Applies to players generally, not only the owning faction. | Owner's traversal instruction |
| C15 | Players cannot walk into the Spike Barrier. The earlier vault ban is superseded by C31; existing runtime remains non-vaultable until the prototype passes. | Owner's original barrier instruction and 2026-09-27 revision |
| C16 | The owner will source final art without AI. Do not create or influence aesthetic design through AI concept art, textures, styling or final assets. | Owner's art-sourcing instruction |
| C17 | Use a temporary white model made only of cubes for the technical turret work. | Explicit placeholder authorization |
| C18 | All gameplay defenses use native construction in the building menu, with a movable placement preview and rotation before confirming placement. The current context menu is developer testing only. | Owner's construction-flow clarification and explicit native-building-menu selection on 2026-09-26; runtime implementation remains pending |
| C19 | Potato hits should have a modest backward impact; prefer the native shove-style stumble-then-fall for successful knockdowns over a physics collapse. | Owner's 2026-09-26 reaction discussion/confirmation; implemented as a 0.1.5 prototype, visual acceptance pending |
| C21 | Spike Barriers occupy 1x2 tiles; the rear face is safe, with front and side-end damage for gameplay. Existing barriers expand only into clear space. | Owner correction after completed 0.1.5 test; width runs across the facing direction |
| C20 | Test Spike Barrier retaliation at 20 damage per actual thump. Do not replace strikes with a once-per-second contact tick. | Owner's 2026-09-26 tuning instruction; Pixel Indicator aids testing, damage units must be explicit |
| C22 | Spike Barrier bundles reduce the combined loose items' encumbrance by 67%. Bundle weight = sum of individual item weights x 0.33. | Owner's explicit 2026-09-26 selection; replaces the proposed 25% bundle reduction. Runtime implementation remains pending. |
| C23 | Schedule individual barrier inventory items and five-barrier bundles within Phase 2, alongside native construction. | Owner's approval to put the discussed feature in checkpoints and begin Phase 2; P2C1b/P2C1c cover implementation. |
| C24 | Basic Spike Barrier consumes four total planks and/or basic crafted wooden spears in any mix, including four spears, plus four binding units. No mandatory frame plank. | Owner's 2026-09-26 recipe discussion and correction allowing four spears. Bindings are ripped sheets, dirty ripped sheets and twine uses. Implemented in the 0.2.0.1 candidate; player acceptance pending. |
| C25 | Basic barrier requires Carpentry 1; reinforced upgrade requires Carpentry 3. Apply corresponding base crafting awards of 10 and 30 Carpentry XP. | Owner's progression correction and subsequent checkpoint approval. Basic recipe implemented in 0.2.0.1; reinforcement is scheduled at P2C2a. |
| C26 | Basic construction uses a retained sharp knife or cleaver. Reinforce an existing barrier using two additional planks, eight nails and a retained hammer; double maximum durability, preserve existing damage and deal 25 damage per thump. | Owner approved the proposed tool/upgrade recipe and corrected reinforced damage to 25 on 2026-09-26. At current basic health, reinforcement is 200 maximum health; preserve missing health rather than repairing for free. |
| C27 | Packing, unpacking and redeploying award no crafting XP. | Owner approved the proposal alongside the recipe checkpoint; first construction/crafting reward must not repeat through transport. |

| C28 | Combine the outstanding native persistence repair with P2C1b portable-item implementation. | Owner request on 2026-09-27; does not include P2C1c bundles or waive player acceptance. |
| C29 | Portable crafting uses the existing basic barrier ingredients, retained tool, Carpentry 1 and 10 base XP. Deploying the finished item consumes only that item and grants no XP. | Owner selected "Use the existing recipe and XP" on 2026-09-27. |

## Owner-proposed content and values

These belong in the design backlog; recording them is not a claim that they have been fully specified or are feasible on the current build.

| ID | Proposal | Remaining work |
| --- | --- | --- |
| O01 | Cheap punji using excavation/grave placement. | Independent stake-bed design versus original grave workflow; damage/catching behavior |
| O02 | Cheap cheval de frise that blocks paths and damages on thumps. | Current thump evidence, geometry, damage, durability |
| O03 | Concertina slows movement and deals damage over time. | Multiplayer movement feasibility and traffic wear |
| O04 | Barbed barricade shares its host's HP and deals damage on thumps. | Exact host types, attacked side, wire wear, and destruction lifecycle |
| O05 | Laser sensors connected to darts and poke floors. | Link UX, range, signal rules, cadence, and limits |
| O06 | Camera-assisted automated real-ammunition turrets; explosive turrets. | Acquisition, firing lanes, compatibility, effects, and collateral policy |
| O07 | 80% score reduction (remaining multiplier x0.20). | Confirm baseline; validate against longer survival; coordinated core/website support |
| O08 | In final-phase Cure simulation, allocate some attackers to defenses instead of the Cure. | Explicit core contract and conservative spatial approximation |
| O09 | Modular turrets with an inventory for motion detection, smart-fire, rapid-fire and velocity components. | Slot compatibility, costs, removal, persistence, authority and balance; see MODULAR_TURRETS.md |
| O10 | Individual barrier inventory items alongside native construction, plus a Spike Barrier Pack meaning a bundle of five items. | Now scheduled under C22/C23. Individual weights, recipes, acquisition and recovery of deployed devices remain to be specified. |

## Recommendations, not approved defaults

| ID | Recommendation | Reason |
| --- | --- | --- |
| R01 | Shared XP pool = 25% of the applicable ordinary kill reward. | Initial tuning point; owner has been asked to choose the rate |
| R02 | Splash cannot stagger/knock down; bound its total damage and affected targets. | Preserve the impact effect without turning massed turrets into area crowd control |
| R03 | Use a shared per-zombie knockdown recovery interval across devices. | Prevent several slow turrets from creating endless knockdown |
| R04 | Bind offline XP entitlements to the recipient's existing character life at earning time. | Preserve Trait Shop death resets; avoid free progression on a replacement life |
| R05 | Snapshot faction recipients when the kill occurs; retain earned entitlements after leaving, exclude future kills. | Prevent membership changes from recalculating or duplicating old shares |
| R06 | Exclude dead/uncreated lives and Horde casualties from new defense rewards; apply no distance/contribution requirement. | Match existing life/event integrity while including offline members |
| R07 | Initial noise device is an alarm, not an automatically triggered lure. | A tripwire/lure can create repeated distraction loops |
| R08 | Disabling a content type stops crafting and operation but preserves objects/resources for recovery. | Avoid destructive configuration changes |
| R09 | Freeze applicable score/configuration facts per event and retain affected-run history. | Prevent removing a mod or changing settings from erasing an earned advantage |
| R10 | Start with vanilla firearms and one ammo family; add third-party adapters separately. | Limit first-version compatibility scope |
| R11 | Use persistent device ownership to identify the reward faction; no mandatory geographic base registration. | Base boundaries were an assistant assumption, not a requirement of shared XP; add an area rule only if the owner asks for one |
| R12 | Support both material construction and deployment of one individual barrier item through the same placement/rotation validation and resulting 1x2 defense. Consume the chosen source exactly once on successful completion; cancellation consumes nothing. | Never charge both an individual barrier item and its raw materials. Recovering an existing device is a separate lifecycle feature and must preserve condition, supplies and installed components rather than reset them. |
| R13 | Start bundles with a pack/unpack recipe: five individual barrier items become one Spike Barrier Pack, and unpacking returns five individual items for placement. Apply C22's confirmed 67% reduction; individual item weights remain to be decided. | Matches native quantity-bundling patterns and avoids needing a partially consumed bundle system initially. Pack/unpack must not repair damaged items or refill supplies; either restrict eligible inputs or explicitly preserve each item's state. |

## Decisions needed before their dependent checkpoints

| ID | Question | Recommendation | Needed by |
| --- | --- | --- | --- |
| Q01 | What percentage of normal XP is the shared pool? | 25% initially; retain as proposed until answered | P3C2 |
| Q02 | Does offline XP survive death and transfer to a new life? Which members count as eligible? | Existing-life receipts; no dead/casualty/new-life transfer | P3C2 |
| Q03 | How is device ownership assigned/transferred, including solo ownership and faction disbanding? | Durable per-device solo/faction owner; no base boundary required | P2C1 / P3C2 |
| Q04 | How do smart-device modes treat unfactioned players, allies, splash and server PvP rules? Which devices have target-recognition capability? | Passive hazards are excluded by C13; define remaining target and collateral policy without PvP bypass assumptions | P2C2 / P4C1 |
| Q05 | Does the basic potato turret target on its own, use a fixed sensor lane, or require operation? | Prove fixed-lane shooting first; decide public behavior before recipes | P2C3 |
| Q06 | Punji grave workflow or a new shallow stake-bed object? | New stake bed with distinct servicing; retain original proposal until resolved | P2C2 |
| Q07 | When does using defenses mark a run for the score reduction? Can outsiders impose it? | Server-tracked benefit and ownership; no nearby-object inference | P3C1 |
| Q08 | Which content toggles default ON, especially firearms and explosives? | Core available content ON; advanced/explosive defaults decided at their checkpoint | P2C1 / P5C1 |
| Q09 | Exact recipes, skill gates, ranges, cadence, health, power, noise, slow, splash, and wear? | Tune after the corresponding prototype; use In-Game Time for autonomous systems | P2-P5 |

## Superseded ideas

- Multiple Survival/Engineering/Siege editions or presets as the distribution plan: superseded by C01.
- Every trigger behaving as a single pulse: superseded by C05.
- A separate retractable spike strip: superseded by C06.
- 6-10 direct hits as the potato reference target: superseded by C03.
- Connected-only defense XP as the default: superseded by C08.
- Treating Cure defense simulation as an early integration prerequisite: superseded by C10.
- A separate assisted leaderboard category as the preferred product: superseded by C09. Existing API limitations still require a coordinated implementation; this does not grant present official eligibility.
- Mandatory base registration as a shared-XP prerequisite: withdrawn; it was an assistant inference from 'at your faction's base'. Ownership can identify recipients without a geographic restriction.
- Zombie-only targeting as the intended final control policy: superseded by C12. Existing zombie behavior remains in scope; exact mode combinations and defaults still need specification.
- Applying controller immunity/disarming to passive stakes, wire and barriers: rejected by C13. Player traversal follows C14-C15 rather than faction filters.
- Very slow potato firing / the prototype's four in-game-minute cooldown: superseded by the owner's one-shot-per-second instruction.
- AI-assisted concept art, textures, icons or visual-design proposals: rejected by C16. Only the unstyled cube-only technical placeholder in C17 is authorized.

## Working terminology

Bed spikes / Spike Bed refers to the passive punji/stake-bed concept in this plan. Spike Barrier refers to the freestanding cheval de frise concept. Poke Floor remains the separate retractable spike mechanism. These map the owner's latest terms to the existing roster; final display names and item IDs are not yet locked.

## Current authorization

2026-09-26 Building-menu correction: the owner requests the corresponding native category plus a custom Turrets & Traps category. Keep Spike Barrier in Carpentry and expose the same recipe through a mod-only filter. The owner withdrew the custom requirement bypass because vanilla Build Cheat already covers testing. Approved ingredients, skills and XP remain unchanged.

2026-09-26 recipe checkpoint approval: the owner approved the retained cutting tool, reinforcement proposal and zero-XP transport rule, with reinforced retaliation increased to 25. C24-C27 close Q10. Implement the basic recipe in the 0.2.0.1 P2C1a follow-up; reinforcement remains scheduled at P2C2a. Existing saved barriers keep their current condition and damage; this recipe patch does not silently reinforce them.

2026-09-26 recipe correction: the owner objected that no recipe was requested before implementation and asked for a Cheval de Frise comparison. The v0.2.0 hammer/four-plank/eight-nail recipe was assistant-selected and remains unapproved test tuning. Review ingredients, tools, skill requirements and crafting XP with the owner before further recipe changes; see [installed B42 recipe comparison](RECIPE_COMPARISON.md). No runtime recipe was changed during this review.

2026-09-26 Phase 2 approval: the owner directs placing individual items/bundles in the phases/checkpoints and explicitly approves beginning Phase 2. P2C1a starts native construction; P2C1b covers individual items, P2C1c covers five-barrier bundles at the confirmed 67% reduction, and P2C1d covers servicing/ownership and multiplayer construction proof. Existing Phase 1 gaps remain tracked. Phase approval did not select a crafting recipe; the earlier interpretation allowing unilateral temporary recipe selection is withdrawn.

2026-09-26 construction follow-up: the owner requests continuing with the remaining Phase 1 tests pending and selects native construction in the building menu. Record that workflow as confirmed; Phase 1 acceptance gates remain open. The owner clarified that a pack means multiple individual items bundled together for reduced encumbrance, using five barriers as the example. This corrects the assistant's single-device kit interpretation; see O10/R12/R13. It does not approve loot/reward integrations. Installed B42.20.4 `media/scripts/generated/items/normal.txt` defines Log at Weight 9 and LogStacks4 at Weight 12; `media/scripts/generated/recipes/recipes_carpentry.txt` defines four-log stacking/unstacking. Native `recipes_packing.txt` also packs twelve Rope items (0.8 each) into RopeStack (8). These establish quantity bundles with reduced scripted weight, not implementation of our barrier items or construction integration.

2026-09-26 follow-up: the owner reports the patch is working well and requests Horde Night naming/process alignment, a safe rear face and 1x2 barriers. Version `0.1.6` implements these changes; see [checkpoint and test review](PHASE_1_CHECKPOINT_2.md) and [release process](RELEASE_TOOLS.md). Positive SP damage/reaction evidence does not certify MP or every animation edge case.

2026-09-26: the owner explicitly approved the shove/damage/retaliation patch after reviewing the completed test. Version `0.1.5-p1retaliation` implements the SP prototype described in [its record](checkpoints/P1_RETALIATION_RECORD.md). Damage units are actual native HP multiplied by 100 for readable balance numbers: barrier 20 = 0.20 HP, potato 50 = 0.50 HP. Pixel Indicator remains optional and its settings are preserved. Strike-marker scheduling/transition limits remain acceptance work rather than a claim that exact native per-strike synchronization is solved.

The test reports authorize repairing combat/visibility and changing base potato cadence. Version `0.1.4-p1combat` addresses those faults. The owner subsequently retained actual per-thump behavior at 20 damage rather than the offered periodic active-thumper approximation, and confirmed the shove-style reaction direction. Reliable per-strike retaliation remains unresolved. The [completed log review](checkpoints/P1_COMBAT_OWNER_REVIEW.md) records current evidence and Pixel Indicator's differing damage/percentage scales. Modular inventory remains an owner-proposed design, not authorization to implement the entire component system during a repair.

The owner additionally authorized temporary white directional-arrow textures and distinguishing developer markers on 2026-09-25. This is a technical testing exception to the final-art restriction. Version `0.1.3-p1markers` does not establish aesthetic direction.

Documentation and local project organization are completed in Phase 0. The subsequent owner-approved cube-only asset preparation is complete. The owner then approved the concrete P1C1 implementation scope, including the proposed package ID `OneMoreHorde_TurretsAndTraps`. Version `0.1.0-p1c1` implements the persistent test-device shell and local validation/installation tooling; see the [checkpoint record](checkpoints/P1C1_RECORD.md). Player-operated acceptance is pending. The owner subsequently authorized P1C2-P1C4 prototype batching and the `0.1.2-p1debug` repair/diagnostics pass. See their checkpoint records. Acceptance, later gameplay, integrations and publication remain pending.

## 0.2.1 provisional item tuning

One portable barrier weighs 6 encumbrance for testing. The owner was offered 6/8/10 and has not selected a weight; 6 is an implementation assumption, not a confirmed balance decision. If retained, a later five-item bundle weighs 9.9 under C22. Deployment accepts pristine items. C32 now explicitly returns full-condition items on pickup; the former condition-preservation proposal is superseded for basic barriers.

## 2026-09-27 menu and servicing approval

- C30: Add Turrets & Traps to Crafting as well as Building, keeping native categories. Use a wrapped purpose description and readable Damage 20 / Durability 100 / Size 1x2 statistics.
- C31: Owner requests player vaulting with a 1-in-5 scratch chance from the spike-facing front. Safe rear was included in the accepted follow-up. This replaces the earlier vault ban as design intent, but it is not implemented in 0.2.2. Whole-square collision versus native edge vaulting needs a bounded prototype; do not teleport players or silently enable zombie vaulting.
- C32: Combine basic-barrier pickup, repair and bundles. Pickup returns one full-condition item; preserving damage is explicitly not required. Owner approved **free repair; 10 seconds for both pickup and repair**, interrupted by movement. This intentionally permits full restoration for time alone. Zero XP remains C27. This exception applies to the basic barrier, not future turret ammunition/power or reinforced tier conversion.

Version 0.2.2 implements the menu correction, nearby condition display and C32 as a single SP test checkpoint. Bundles use five pristine loose items, weighing 9.9 with the current provisional individual weight 6. Existing recipe, cutting tool, skill and initial crafting XP remain unchanged. Final damaged visual stages remain an owner-sourced art proposal.

## 2026-09-27 barrier tuning and repair

- C33: Owner requests configurable basic Spike Barrier damage and HP, reducing default damage to **10**. 0.2.3 adds Damage (0-1000, default 10) and Maximum Durability (1-10000, default 100). Bounds and preserving remaining durability percentage on maximum changes are implementation choices. Free ten-second repair/pickup remain unchanged. Reinforced 25-damage design stays pending and is not silently retuned.
- 0.2.2 acceptance failed service load order, tooltip formatting and native destruction re-entry: [review](TEST_v0.2.2.md). Earlier basic 20-damage tuning/statistics are superseded by C33; historical evidence is retained. C31 vaulting remains unimplemented pending native proof.

## 2026-09-27 combined checkpoint testing

The owner authorized proceeding to the next checkpoint and testing it together with 0.2.3. C34 closes the collision choice; 0.2.3 remains unaccepted rather than retrospectively passed.

- C34: Owner selected **fence-style collision** for [P2C2-vault](PHASE_2_CHECKPOINT_2_VAULT.md), keeping the two-tile construction footprint and one shared durability pool. Version 0.2.4 implements native fence climbing through the Spike Barrier submenu, front 20 percent scratch / safe rear. Older built barriers retain full-square collision until pickup/redeployment. Debug-only placed prototypes remain legacy fixtures. No recipes, art or reinforcement changes are included.
- Implementation detail: one lower-leg environmental scratch after a completed front crossing. This is a flat roll without a clothing protection reroll; native wound severity/traits apply, and the scratch does not roll Knox infection. God Mode prevents injury. Interrupted/failed/removed/dead-player attempts do not roll. Normal fence-key integration is deferred; no generic zombie hopping flags are enabled.

## 2026-09-27 approved native-control correction

- C35: Use native Interact and Run/Sprint controls and player movement settings for Spike Barrier low-fence vaults. Preserve the native trip calculation; no high-wall animation or struggle mechanic. Player traversal must not enable zombie climbing. Scratch and trip are separate outcomes.
- C36: Repair remains tool-free, ten seconds, with label Repair and a short duration tooltip. Pickup remains ten seconds/full-condition. Use reachable approaches and cancel stalls.
- C37: Sandbox scratch denominator is integer 0-50, default 5. Zero disables spike scratches, one always scratches, N gives 1 in N; rear avoids spike scratches. Apply once at edge contact during traversal. Native fall risks still apply.
- C38: Separate General, per-defense and Debug Sandbox categories. Add a visible collision debug option. Use judgment to expose useful future balance controls (ammo, cadence, damage, radius, speed) as features are implemented. Prefer the shortest useful tooltip.
- Implementation: perpendicular native fence edges can share a corner tile with independent identity/HP. Parallel duplicate edges remain rejected. Existing spaced layouts are not automatically bridged with invisible extra collision. This corrects the overbroad former full-footprint overlap ban while preserving the 1x2 barrier.

[0.2.5 scope, source evidence and owner test](PHASE_2_CHECKPOINT_2_VAULT_REPAIR.md). Earlier C34 submenu-only and after-completion scratch implementation notes describe 0.2.4 and are superseded.

## 2026-09-27 failed collision test and clarified actor behavior

- C39: Zombie collision must cover the full occupied blocks. The owner asks whether separate centered player collision and diagonal connections can be implemented. Full-block zombie collision is confirmed intent; feasibility of the separate player shape is not confirmed. C34's shared edge implementation no longer satisfies the final requirement.
- [0.2.5 failed owner test](TEST_v0.2.5.md): displaced overlay, incomplete diagonal joins and inconsistent native-input traversal. 26 captured crossings include 25 incorrectly tracked as interrupted and only one contact. Independent client corrections are prepared as 0.2.5.1 source, not installed.
- [Collision feasibility checkpoint](PHASE_2_COLLISION_FEASIBILITY.md) records current engine limits. No custom Java dependency, global passability bypass, or replacement player physics is approved. Keep the independent fixes separate from geometry acceptance.

## 2026-09-27 approved connected outline

- C40: Owner supplied a front-and-end outline, explicitly allowed the rear to remain open, confirmed that connected runs should only cap their outermost ends, and approved implementation. This supersedes C39's full-block zombie / separate centered-player requirement. Both players and zombies use the same native cardinal outline; no custom diagonal physics or Java dependency is introduced.
- Every 1x2 item keeps its own identity, durability and recovery. Touching straight fronts and perpendicular front joins remove internal caps. Removing or destroying a section exposes and restores caps on surviving ends. Actual gaps are never bridged.
- Implementation: visible footprint parts are passable and non-thumpable; separately owned native edge objects supply the front and exposed caps. Retaliation applies on the outside of front/end edges, not their inward faces. Front vaults use C37; cap vaults have native trip risk but no additional spike scratch. Open rear permits ordinary entry.
- Existing edge-v1 construction migrates to the outline with its durability and ledger identity intact. The correct facing boundary changes some old layouts; barriers are not automatically moved. Legacy full-square test fixtures still require pickup/redeployment. Rendered migration/gameplay acceptance remains pending.

[0.2.6 checkpoint, current engine evidence and owner test](PHASE_2_CHECKPOINT_2_OUTLINE.md). The uninstalled 0.2.5.1 draft is folded into this feature version and is not a separate release.

## 2026-09-27 visibility follow-up

- C41: After the 0.2.6 test, the owner requires normal visibility through the barrier and requests the correction in the next checkpoint. Preserve collision, vaulting and zombie blocking; seeing through an open spike barrier is baseline behavior rather than an optional balance toggle.
- [Test evidence](TEST_v0.2.6.md) is partial, with four unsettled vault results and no completed repair/reload proof. [P2C2a](PHASE_2_CHECKPOINT_2A.md) queues the correction ahead of the already-approved reinforced upgrade. This update records scope; no gameplay patch was installed.

## 2026-09-27 P2C2a approval and reinforced servicing

- C42: Owner approves the P2C2a patch and explicitly selects the same free ten-second pickup/Repair and full-condition recovery for reinforced barriers, preserving their tier. Reinforced bundles contain five items of one tier only and use the same 67 percent weight reduction. This extends C32 to the reinforced tier; mixed-tier bundles are excluded.
- 0.2.7 implements C25/C26/C41/C42. Upgrade duration is ten seconds; inventory/carried-bag materials and usable retained hammer are required outside native Building Cheat. Cheat upgrades do not award XP. Reinforced item weight remains provisionally 6, pack 9.9, pending balance acceptance.
- See [checkpoint, current engine evidence and full test](PHASE_2_CHECKPOINT_2A.md). Native-entry timeout diagnosis remains open; no player test is retroactively marked complete.

## 2026-09-27 upgrade repair and item weights

- C43: Every upgrade also repairs the object. This supersedes C26's missing-health rule: a basic 70/100 barrier becomes reinforced 200/200 with default settings. Later Sandbox maximum changes still preserve remaining percentage.
- C44: Basic barrier weight is 4; reinforced weight is 5. Five-item same-tier packs retain the approved 67 percent reduction, weighing 6.6 and 8.25 respectively.
- The owner reports intermittent service reach warnings and asks whether native Install/Pickup is possible. 0.2.7.1 corrects the zero-distance collision check on arrival. A dedicated Moveables adapter is feasible in principle but remains proposed, not implemented or approved by this question.

## 2026-09-27 P2C2b approval and turret module corrections

- C45: Owner approves P2C2b: reliable right-click selection across both barrier parts/shared corners, full-object menu hover highlight, independent reinforced texture inputs with stable saved sprite IDs, and selection success/miss diagnostics. Native Install/Pickup is deferred. The owner reports reinforcement worked well and waives the separate 0.2.7.1 test round; this does not supply unobserved regression evidence.
- C46: Turrets use an inventory for ammunition and drag/drop module installation. Firing accepts FIRE signals; Motion Detection aims/follows eligible zombies and requests firing; Filter supplies Closest/Furthest/Weakest/Toughest priorities. Detection does not require literal movement. Add Capacity, Range and 360-degree detection alongside Rapid-Fire and Velocity. Motion-module crafting should offer a sensor-based route and a higher-skill raw-material route; exact recipes remain unsettled.
- C47: Owner explicitly permits stacking **Range, Velocity and Rapid-Fire** modules. Previous one-per-type restrictions are superseded for those three. Bonuses, formulas, capacity and power are undecided; recommendations and safeguards are recorded in [module plan](MODULAR_TURRETS.md). No module runtime ships in P2C2b.
- C48 (2026-09-28): Owner approves the complete P2C3a-c next-update recap, on High effort, combined with the held P2C2b test. Universal base plus swappable potato head, actual ammo/module/battery storage, native construction, contents tooltip, contents-based weight and charge/condition/cooldown persistence are in scope. Pickup retains contents; battery swaps return the actual battery with its charge. No automatic ejection. Module effects remain P2C3d; native firearm reuse and Reload/Autoloader behavior remain a later checkpoint.
- C49: The approved revised recipe removes planks and Carpentry. Base: 2 pipes, 2 small sheets, 1 scrap, 8 screws; Mechanics 2, 15 Mechanics XP. Potato head: 1 pipe, 1 small sheet, 2 scrap, 2 electronics scrap, 1 electric wire, 1 tire pump, 2 tape uses; Mechanics 2/Electrical 1, 15 Mechanics + 5 Electrical XP. Improvised head replaces pump with four extra scrap and requires Mechanics 4. Retain screwdriver, wrench/pipe wrench, metal snips; head also requires pliers. Combined recipes sum costs/XP exactly. No deployment, pickup or swapping XP; no magazine requirement.
- C50: Turret power uses a removable car battery or valid native external supply, preferring external power and falling back to battery. No free charging on pickup/swap; use vanilla charging. The potato head includes feeding/cycling; Firing and Motion Detection modules still have separate roles. Useful Sandbox controls and short tooltips are authorized. Initial quantities, charge/fuel consumption and empty base/head/module weights are implementation tuning defaults documented in P2C3, not claims of playtested balance.
- C51 (2026-09-29): Owner requests OMH: Traps and OMH: Turrets categories in Crafting and Building. Category migration is queued with the pending usability patch. The requested magazine capacity 1, reload 1s and cooldown 0.5s require a shared cycle system; 85 total potatoes, overlapping timers and reducing retained tools to screwdriver plus wrench remain recommendations awaiting explicit settlement.
- C52: Owner approves a cube-only hybrid rendering checkpoint before final artist export requirements. Evaluate a stationary base tile and separate rotating model head, using current native APIs, independent-instance tests and visual acceptance. This does not approve final art, a Java injection dependency, or replacing gameplay turrets before the renderer is proven. See PHASE_2_HYBRID_RENDER_PROBE.md.

- C53 (2026-09-29): Owner approves the combined gameplay patch after reporting probe flicker and requesting base collision. Implement integrated tile-base/model-head rendering using recorded 0.4 height / 0.512 scale as starting calibration; see-through 1x1 base collision, native adjacent servicing, Manage/native inventory, category/preview fixes and shared firing cycle. Approval adopts the proposed 85 total ammo, overlapping 1s reload / 0.5s cooldown and screwdriver plus wrench/pipe-wrench tools. Supersedes C51's pending values and C49's snips/pliers. Keep one combined visible test; module effects/automation remain P2C3d and final artist export settings remain unaccepted. See PHASE_2_CHECKPOINT_3_USABILITY.md.


## 2026-09-29 dedicated turret window approval

- C54: Owner approves replacing Manage's loot-page shortcut with a dedicated turret window: head, ammo, module and battery slots, real drag/drop timed transfers, charge and capacity display, live status/stats and manual Fire. Keep one actual native container and exact items; no inventory duplication or instant transfer. Include the reported base-grounding correction. Module effects and multiplayer remain later checkpoints.
- 0.2.11.1 log confirms Manage opened without its previous exception, but the owner rejects opening the standard loot pane as the intended interface. This confirms the load-order repair, not full visual or gameplay acceptance.

## 2026-09-29 turret aiming and balance

- C55: Owner reports the head did not follow the lowered base, model rotation disagrees with firing direction, and requests selection range/FOV and Magazine wording. Requests 35 damage and 2s reload/cooldown; this patch interprets both as two-second overlapping timers, retaining magazine 1 and ammo 85. Saved Sandbox custom values remain authoritative. This supersedes C53's firing defaults and fixed 0.4 head height, while retaining scale 0.512.
- Current manual combat targets radially, with loaded-square and obstruction checks. Selection shows that actual 360-degree radius plus head aim. The owner was offered a separate 90-degree forward restriction or current radial behavior; absent that answer this patch does not change targeting eligibility. Motion Detection/360 module behavior remains P2C3d.
- The 0.2.12 console capture `diagnostics/captures/20260929-183350-0950` records successful exact-item transfers and seventeen shots at damage input 0.5. The owner's screenshot/report establishes failed visual head alignment; it does not imply all prior acceptance gates passed.

## Placement-locked coverage and held test

- C56: Owner selects a forward cone locked to the turret's placement direction. Head tracking must not rotate that cone; manual and automatic target eligibility must share the same boundary. The 360 module expands angular coverage to a full circle without increasing distance. This supersedes the unresolved radial-versus-cone decision in C55; 0.2.13 remains radial until patched. Cone width is not explicitly settled: 90 degrees with a Sandbox control is recommended.
- Owner skips the standalone 0.2.13 test and requests discussion of the next checkpoint. Record it as held/untested, not passed. Combine its height/yaw/Magazine/balance/range acceptance with the next playable checkpoint. This turn authorizes documentation/discussion, not immediate implementation of all module systems.
- Recommended subdivision of P2C3d: d1 placement coverage plus Firing, Motion Detection, Filter and 360 effects; d2 stackable stat/capacity effects. Recipes/tools/skills/XP require concrete owner review before implementation, per the existing recipe agreement. Reload/Autoloader timing effects can be reviewed with d2 now that the shared cycle exists; firearm adapters remain P5.

## Module acquisition and default coverage

- C57: Owner settles the default field of view at 90 degrees (45 degrees either side of placement direction) and makes modules loot-only for now. Module crafting recipes, retained tools, skills and XP are deferred and are not a prerequisite for P2C3d1. Preserve configurable cone width and the C56 placement lock/360 expansion.
- Proposed loot tuning: use suitable electronics/industrial loot pools verified against the installed game; Firing and Motion Detection should be more available than Filter and 360. Expose useful module loot abundance control. Exact pools/weights remain implementation recommendations, not verified current distribution behavior. Introduce gameplay loot for functioning modules only; later-effect modules remain debug-only until their checkpoint. No loot injection or runtime change is made in this discussion update.

## Configurable module and automation tuning

- C58: Owner agrees with the loot-only/core automation direction and explicitly requests Sandbox controls to test and choose balance values personally. Include useful tuning in the feature checkpoint, grouped by category with short tooltips. Do not require another recipe discussion; crafting remains deferred.
- Planned d1 controls: forward cone default 90 degrees; automatic targeting enable/disable; bounded detection interval; global module loot multiplier and separate Firing/Motion Detection/Filter/360 multipliers, with zero suppressing new drops. Use multiplier wording rather than promising an exact percentage from native weighted loot pools. Exact non-confirmed numeric defaults/bounds are implementation tuning, not owner-set values.
- Existing per-turret damage, range, ammo/module capacity, magazine/reload/cooldown and power controls continue to apply to automation. Keep Filter priority and individual turret on/off in Manage. Later active stack modules get per-copy bonuses/caps and loot controls in d2, not inert d1 settings. Changes never delete owned modules or regenerate already-populated containers.

## P2C3d1 implementation approval and defaults

- C59: Owner approves implementing the discussed core automation/loot/Sandbox checkpoint, then approves resuming after an interrupted work turn. Deliver 0.2.14 as one combined test build with held 0.2.13 changes.
- Implementation tuning (owner-adjustable, not individually owner-selected): scan interval 0.25s bounded 0.1–5, cone bounds 10–360 with confirmed default 90, loot multipliers 1 bounded 0–20, and pool weights Firing/Detection/Filter/360 = 2/2/0.5/0.25. Automatic operation defaults enabled when components/power are present; Manage and Sandbox can disable it. Health priorities compare current health.
- Native source verification exposed distribution-merge-before-Sandbox-load ordering. Apply module weights at OnLoadedTileDefinitions and reparse once before map population. Reload for loot setting changes; preserve already-generated containers and unrelated loot. Gameplay remains SP-only. Scope/evidence/combined test: PHASE_2_CHECKPOINT_3D1.md.

## 2026-09-29 C60: approved automation polish and owner audio

Owner approves 0.2.15 after reporting 0.2.14 generally passed, then confirms zombies did thump the turret later. Do not change native thumping or add a speculative workaround. Reused-save Sandbox differences are intentional.

- Visible name is 360 Module; preserve internal Detection360 item/save IDs.
- Manage opens only its own panel, leaving inventory visibility/pinning untouched.
- Powered automatic Motion Detection sweeps visually while searching, freezes without detection/power, and tracks acquired targets. External power counts. Placement cone remains fixed. Idle sweep speed defaults 30 degrees/second, Sandbox 0-180; zero disables the visual sweep only.
- New defaults: 100 total potatoes including magazine; splash 25 percent of direct damage (8.75 at 35), radius 1.5 tiles, at most three secondary targets, no splash knockdown. Existing capacity/radius settings remain unchanged. PotatoSplashPercent replaces the former absolute-damage setting under a distinct key; do not reinterpret an old absolute value as a percent.
- Default solo Hard first night has 17 zombies. Its 10/78/12 toughness mix and 35 direct damage imply about 106 direct-hit potatoes on average before splash/help/misses, not a guaranteed 100-potato clear.
- A short white travel marker precedes the impact pop; this is a presentation effect, not a persistent potato physics item. Damage remains immediate, matching the native separation of hit resolution and tracer presentation.
- Owner will create sounds. No native sample or generated audio is shipped. See art/AUDIO_BRIEF.md.

Captured 0.2.14 test: diagnostics/captures/20260929-204206-9890. Version 0.2.14 and automatic fire are in the log; no OMHTT exception identified. Owner acceptance does not certify multiplayer or every unobserved regression.

## C61: 0.2.16 presentation and mechanical turn speed

Owner accepts 0.2.15 generally, but reports head/base occlusion and low white projectile. Approves the discussed patch after comparison with Horde Night and Trait Shop. All six page labels use OMH: T&T -; potato page has Operation, Storage, Combat and Power headings. This preserves individual-defense pages and internal saved keys. Detection Module and the shortened 360 tooltip are display-only changes.

Turret heads rotate at a maximum rate (default 90 degrees/second; Sandbox 1-360), using shortest angular distance and a one-degree firing tolerance. Manual fire queues one target-specific shot, revalidates access/resources/geometry and spends nothing while turning. Automatic Detection tracks with the same physical angle. Idle sweep updates the current head angle but cannot rotate coverage. Pending shots/targets are transient and are cancelled by invalid targets, missing power/head, lost manual reach or disabled automatic detection; no pending shot persists across reload.

The temporary base sprite uses native FloorOverlay depth instead of the generic tall-object depth; calibrated model height stays unchanged. This is a placeholder floor-depth approximation, not a final per-pixel model-matched depth map. Native flags/collision are verified; rendered head occlusion still needs owner acceptance. Projectile starts higher, travels as a brown marker and pops into larger brown particles. Selected splat2.wav is referenced from the installed game through OMHTTPotatoImpact. No native audio is redistributed.

The listening page now contains 34 exact-copy candidates, including 16 reload candidates. Always supply an HTML audition page for future audio decisions. Source metadata stays beside the local page. No sibling mod is edited.

C61 pre-install correction: the captured 0.2.15 packed-item tooltip failed in native Translator on a literal percent sign. 0.2.16.1 fixes charge wording before the first installation of this patch; 0.2.16 remains an uninstalled source tag.

## C62: held 0.2.16.1 test and next checkpoint discussion

Owner requests recording the pending test and moving forward to discuss the next checkpoint. Hold the full turning/presentation test for combination with P2C3d2; do not count it as passed. P2C3d2 scope is documented as a proposal, with numeric module tuning and implementation approval still pending. This request changes documentation only, not installed gameplay.

## C63: approved P2C3d2 and stackable Reload

Owner approves proceeding with active stat modules and explicitly adds Reload stacking. Use Reload and Fire rate as concise distinct labels. Implement the proposed dedicated Capacity socket, safe removal, configurable gains/caps and loot-only acquisition. Defaults in PHASE_2_CHECKPOINT_3D2.md are implementation tuning; retained Sandbox settings still apply. Combine held 0.2.16.1 acceptance into one complete owner test. No crafting, firearm adapters, multiplayer certification or external publication is authorized by this checkpoint.

## C64: 0.2.17 review and page organization

Owner completes the test and requests Traps / Turrets parent Sandbox pages, logical ordering with Debug last, eight visible slots with inactive extras greyed, attention feedback on changing Manage messages, and investigation of firing hitches. Reports a visible head/base gap and distant building placement; asks about inventory Install. See TEST_v0.2.17.md for observed evidence, native cheat behavior and proposed follow-up. These parent-page labels supersede individual-defense page names; preserve saved option keys.

Owner also approved planning a supported-firearm mount prototype before multiplayer. Keep universal base, swappable actual gun, shared modules and native-mechanism evidence; no blanket modded-gun support claim. Address the current usability/performance findings first.

## C65: approved Expansion Kits and combined usability patch

Owner approves recap and implementation: Capacity becomes one dedicated Expansion Kit socket with Small/Standard/Large variants, increasing capacity and rarity, not multiple installed kits. Preserve existing Capacity as Standard; tier defaults and safeguards are documented in PHASE_2_CHECKPOINT_3D3.md. Ten compact regular slots cover the Large default, unavailable slots dim; omit Module only from installed slot labels. Include ordered parent Sandbox pages, changed-message brightness, head/base depth repair, bounded manual-fire searches and exact-item inventory Install. Building-cheat bypass remains native. Keep one combined test and firearm prototype next.

## C66: approved Install, item naming and projectile/audio repair

Owner approves the 0.2.19 repair and later asks to resume it. New Expansion Kits use accurate IDs and Small/Medium/Large names; audit Detection/360 IDs too and retain saved aliases. Fix silent Install and log rejection stages. Constructed turret projectiles use real travel delay shared by hit effects and damage, default 20 tiles/second with Sandbox tuning. Use owner-supplied potato_thump_1/2.wav and potato_splat_1/2.wav, native variant selection and subtle 0.95-1.05 pitch. Keep bounded queues, saved settings and existing reload/cooldown semantics. See PHASE_2_CHECKPOINT_3D3_REPAIR.md. No external release or multiplayer enablement.

## C67: correct visible aliases and projectile muzzle

Owner requests resolving duplicate item-spawn entries and moving the visible projectile start from head center to barrel end; reports the rest of 0.2.19 worked well. Use native Hidden=true for five saved compatibility definitions and retain their data. Offset only presentation from the actual placeholder barrel geometry without changing combat timing. Owner subsequently reports stuttering on every shot; remove redundant shot refresh/scans, spread verbose telemetry across ticks and add stage timings without claiming unmeasured FPS improvement. Version 0.2.19.1; see PATCH_v0.2.19.1.md. No extra feature checkpoint or balance change.

## C68: approved destruction policy, remove pre-release aliases, combine next checkpoint

The owner approves base loss with partial metal salvage and preserved internals. Two scrap metal is the implementation default. Actual head, ammo, modules, expansion kit and battery survive without additional damage or charge reset; normal pickup does not create salvage. Reduce oversized loose placeholder sprites.

The mod has never been uploaded; the owner explicitly authorizes removing the five old item definitions instead of hiding them. C68 supersedes C66/C67 compatibility retention. Remove their identity mappings/translations as well; retain internal behavior and Sandbox keys because these are not duplicate items. Old private-test items using deleted IDs are not migrated.

Owner reports 0.2.19.1 seems to work well; this does not independently certify frame times. No standalone owner test is required for the cleanup. Prepare source but hold installation to combine with the next checkpoint. Next is early P5C1a supported-firearm feasibility per C64, scoped in PHASE_5_CHECKPOINT_1A.md; firearm implementation remains pending concrete approval. No publication, remote push or sibling changes.

## C69: approved early supported-firearm mount, combined 0.2.20

The owner approves P5C1a and combining it with C68. Scope is three installed vanilla mechanisms: Base.Pistol, Base.Shotgun and Base.HuntingRifle. Use the actual weapon as the head, matching loose ammunition and existing turret modules, power, targeting and Manage. No separate mount item or recipe changes. Preserve actual gun condition, attachments, loaded magazine/chamber and supplies through recovery/save/load.

Implementation uses a bounded stationary-weapon adapter: native item stats, models and sound events; explicit approximate accuracy/damage and mechanical timings, without pretending to execute the character-only firing pipeline. Pistol requires its ordinary magazine inserted before mounting. Autoloader removes loading delay while pump/bolt cycling remains. Existing jams block firing and can be cleared after removing the gun. See PHASE_5_CHECKPOINT_1A.md for measured native references, implementation defaults, limits and the combined owner test. Broad modded-gun support and multiplayer are deferred.

## C70: firearm repair and architecture alignment

The owner reports a partial 0.2.20 test and asks to fix its issues first. Add mounted gun pose/support, dedicated native magazine servicing, persistent red requirements and head removal with reserve retained. Scope/evidence and native magazine identity semantics: PATCH_v0.2.21.md. Autoloader does not add a magazine requirement to potato/internal-magazine heads. Review current engine evidence and Alex's rules; ARCHITECTURE.md records similarities and remaining authority, aggregate-budget and clock gaps versus Horde Night. No sibling modifications or MP enablement.

## C71: suppression audio audition and reload selection

Owner selects stormyShotgunInsertRound.wav for potato reloading. Suppression is stackable without a separate stack cap; ordinary available module slots remain the physical limit. Do not add a Suppression stack-limit option. Per-stack hearing reduction remains tuning to confirm with the gameplay patch. Do not reduce audible playback gain to represent zombie hearing.

Owner supplies OMH/Audio/Turrets & Traps/suppressed_shot.wav as an overlay: layer it unfiltered over the filtered original shot, never use it alone as the replacement. Updated art/POTATO_AUDIO.html links/downloads the reload, overlay and two rendered layered potato-shot previews. Original files remain unchanged. Mixes preserve the previous 250 Hz linear wet envelope; preview slope remains 48 dB/octave pending final choice. Overlay begins at time zero, unity gain, with no normalization. Numerical checks confirm overlay preservation and no clipping. Browser player volume remains a common audition level, not suppression gameplay attenuation.

No gameplay update is authorized by this HTML request. Preprocessed replacement clips make the proposed sound achievable for supported heads without arbitrary runtime DSP. Current installed generated gun/sound definitions have no universal suppressed-shot variants; broader firearm coverage needs explicit replacement clips/profiles or a separately proven runtime FMOD path.

## C72: native firearm suppression library and family fallback auditions

Owner requests processed sounds for all native guns, with the existing filter plus the supplied unfiltered overlay, an HTML audition and proposed generic families for modded weapons, keeping file size small. This authorizes local audio production and documentation, not gameplay installation or broader firearm adapters.

The installed 42.21.0 inventory has 20 real firearms sharing 18 shot events, plus two toy cap guns. Current native events were rendered locally through the installed FMOD libraries; no obsolete loose-file substitution was used. All have original/filtered/layered comparisons and layered OGG/WAV downloads in art/FIREARM_AUDIO.html, linked from art/POTATO_AUDIO.html. Mono 48 kHz Vorbis quality 4 produces a 797,597-byte real-firearm runtime candidate subset; nine proposed families reuse files with no additional audio payload. Cap guns are separate completeness entries. One representative single-shot event render per sound, not every random/indoor/distant variant. No universal modded-gun compatibility implied.

Preserve C71's envelope and unfiltered overlay. Preview slope remains 48 dB/octave. As an export safeguard, common clipping-prevention gain is permitted within this prepared audition set and disclosed per clip, with identical gain on comparison versions; it is not a proposed zombie-hearing volume effect. Source recordings remain unchanged. Exact native event/item mapping, source hashes, processing and verification are recorded in art/firearm-audio/manifest.json and README.md. Proposed family selection is exact item override, recognized native event, explicit cartridge/mechanism family, then unchanged original for unknown mechanisms. Family choices still await owner listening.

## C73: approved balanced suppression, reload feedback and turning repair

Owner accepts matching the unfiltered overlay's perceptual balance to JS-14 rather than applying unity gain to every original shot; approves adding processed firing sounds together with the lootable Suppression Module. Keep 25% remaining-radius reduction as default, no separate stack cap, configurable strength/loot, and unchanged audible gain across stacks. Potato reload is stormyShotgunInsertRound.wav; firearms use native mechanism fields. Include the mounted gun turning fix and one combined test. This specifically authorizes packaging the approved processed native firearm audio and supersedes C60's earlier no-native-samples restriction for this library. Original source files remain unchanged. Scope and evidence: PATCH_v0.2.22.md. Three firearm adapters remain the supported limit; fallback family assets are preparation, not universal gun support.


## C74: resume the held controls/combat patch and expand themed loot

On 2026-10-02 the owner approved the site update together with the held gameplay patch. Retain native firearm critical chance and damage; implement the reviewed Power control, stackable Critical/Accuracy, diminishing uncapped Suppression and random/max-toughness target locks. The accepted defaults and native findings are recorded in PATCH_v0.2.23.md. Add ElectricianTools, GunStoreAccessories and ToolCabinetMechanics with component subsets while retaining the original four full pools. Publish the updated admin LootLab and preserve cross-device settings. Local gameplay install is authorized; GitHub push and Workshop publication are not. Continue with one combined player test and the existing SP boundary.

## C75: adopt the current hosted LootLab tuning

On 2026-10-02 the owner approved applying the current website settings. Read-only production evidence identified revision 84: global 6; Firing, Detection, Small/Large Expansion Kits and Autoloader 3; all other components 2. Apply these as new-world defaults and LootLab reset defaults; preserve existing game saves, generated loot and account scenarios. Scope and evidence: PATCH_v0.2.24.md. Local install and matching admin-site update are authorized; no Steam publication or GitHub push.

## C76: broader loot and turret usability

Owner approves the discussed patch and specifically sets potato hearing to eight tiles. Broaden native themed pools while making ordinary successful finds usually one or two components and retaining uncommon five-plus jackpots. LootLab uses larger circles for generated five-plus totals and chance-scaled circles on the probability overlay. Preserve account tuning and existing generated game loot.

Add the green/red Power symbol, free ten-second base-only Repair, explicit rejection of duplicate utility modules and conventional gun admission based on native data. All twenty native real guns are mechanism-probed; no arbitrary custom weapon-code compatibility claim. Scope, pool weighting and one combined test: PATCH_v0.2.25.md. Local install and admin-site deployment are authorized. This supersedes the three-gun admission restriction, not the single-player gate or required shared-budget/clock work.

## C77 — approved cadence, range and loot normalization (2026-10-04)

Owner approves the combined patch including native distance accuracy: PATCH_v0.2.26.md. Firearm rate 0.75, potato unchanged; native damage/criticals retained. Engagement range is independent of head range. Precision Fire and recoil simulation are omitted. Loot global 4.5 and current component factors become base weights; controls reset to 1. Old Sandbox keys cannot double-multiply; website migration preserves effective tuning except the expressly approved owner reset. Summarize diagnostics and coalesce unchanged inventory work.

## C78 — 0.2.27 range, hearing and compatibility

Owner approved the revised recap on 2026-10-04. Precision includes bolt/lever/semi-auto-only rifles; automatic/burst-capable guns remain ordinary even in Single mode. Original script range supports classification, never a mandatory >40 rule or attachment/module promotion. Defaults 60/80 at full effective weapon range; the engagement cap does not rescale accuracy. Noise visibility is a local Mod Options preference. First P2C3e slice shares work and excludes paused/offline time; multiplayer and dense rendered performance remain acceptance gates.

## C79: approved broader finds, all-gun startup audit and 5x tuning

Owner approves the discussed patch and raises the prior 4.5x baseline to 5x. Add modest themed weights to GarageMechanics, CrateMechanics, ElectronicStoreComputers and ElectronicStoreHAMRadio; preserve uncommon jackpots. Raise normalized base weights by 10/9 with all rate defaults remaining one. Match LootLab and preserve account settings. Debug logging audits every ranged candidate once at startup in bounded batches, with accepted stats, rejection reasons and totals. Investigate the Louisville hang; surviving evidence cannot assign a cause. See PATCH_v0.2.28.md. No new combat balance, recipes or multiplayer enablement.

## C80: selectable Turrets/Traps and roadmap reset

Owner requests two selectable mods, OMH: Turrets and OMH: Traps, shipped together as OMH: Turrets & Traps so users can exclude Turrets. Record this in checkpoints/todos, reassess phases, review collaboration rules, report existing turret plans and suggest unique heads. This authorizes documentation, not a gameplay/package rewrite yet. Traps-only must be independent; turret-only support and shared loading without a third visible entry are recommendations to prove in R1C1. Old combined-ID/save behavior needs an explicit tested policy; do not equate a Sandbox disable with unloading a mod.

Owner reaffirms that the assistant should correct mistakes, challenge proposals and recommend against features with material feasibility/performance/compatibility problems. Approval cannot prove engine capabilities. Revised ROADMAP.md uses R1-R6 IDs while ROADMAP_LEGACY_20261004.md retains previous P0-P6 history. Existing evidence remains valid and unresolved acceptance stays open. TURRET_HEAD_PROPOSALS.md contains unapproved concepts. No new recipes, stats, final art, multiplayer claim or publication is implied.

## C81: offensive module planning and long battery life (2026-10-06)

Owner broadly approves the discussed module direction and explicitly requests adding it to phases/checkpoints, followed by renewed turret-head discussion. This authorizes planning documentation; "most" is not approval of every suggested tuning value, propagation rule or head. No gameplay implementation, installation or release occurs in this update. See [offensive module checkpoints](checkpoints/R3_OFFENSIVE_MODULES.md).

Explicit owner direction:

- Most offensive modules should stack. Splitter adds one child shot per stack, each at 50% of original damage: one alternates left/right 15 degrees, two fire both, three add an alternating 30-degree child, and further stacks continue in paired 15-degree increments. The central shot remains the working interpretation; stack cap and additional-ammunition policy are unresolved.
- Use the name **Fragment Module** for the radial-impact concept: five random radial child shots at 20% of original damage each. Owner prefers a minimum separation of **30 or 45 degrees**, superseding the earlier 20 degrees; exact selection remains open. Recommend 30 degrees with the wraparound gap checked too.
- Impact should affect the first bullet of a magazine with a high stumble chance. Exact native reaction, reload eligibility, single-round heads and stack tuning need proof/selection; do not substitute full knockdown without discussion.
- Module intensity/impact should increase battery usage, while batteries must remain long-lived rather than requiring daily replacement/recharging under normal use. Do not simply multiply the existing per-shot drain. Exact endurance target and representative firing workload remain tuning decisions.
- Exclude Homing and Bleed. Exclude slowing turret effects that undermine OMH Horde Night zombies. Net/slow-based heads leave the active shortlist. This does not silently remove the separately planned concertina trap; R2C4 must revisit its slowdown against this concern before implementation.

Working proposals retained for review: Piercing, Initial Blow and Execute; compatible combinations and capped stacking; Fragment once on the primary projectile's first successful impact per firing cycle, with terminal children; Fragment stacks improve damage rather than count; Impact stacks improve chance with recovery protection; empty-reload rearming; upfront predictable power cost and a separate negligible operating draw if justified. These details are not individually confirmed by the broad approval. Splitter ammunition cost, fragment range, head compatibility, secondary targeting/collateral and exact caps remain explicit scope gates. Existing potato splash remains a separate mechanic.

Puddle/tack bullets are not scheduled; the proposed spike-canister ground trap is deferred. New head candidates remain proposals, with no selection or recipe approval. Maintain existing package, performance, multiplayer and publication gates; do not add planned features to WORKSHOP_CHANGELOG.txt.

## C82: prune heads and replace flail with rotary blades (2026-10-06)

Owner drops Extinguisher as clutter and Pneumatic Ram as too limited in reach to be efficient. Remove both from the active shortlist. Owner prefers Rotary Blades over Rotary Flail because rigid blades should be simpler than the implied flexible-body physics. Record Rotary Blades as the replacement close-defense concept; no chained-physics implementation or head prototype is authorized by this discussion alone.

Working recommendation: bounded fixed-reach swept contacts synchronized to visible rotation, no per-frame damage or permanent aura, no Bleed/slow/stun-lock, and appropriate obstruction/target checks. Coverage, reach, player danger, damage cadence, victim caps, compatible modules, maintenance and recipe remain open. This design is plausibly simpler, not an engine capability claim. Preserve long battery life, owner-sourced final art and R3C1-R3C2 proof/approval gates. Updated candidates and tradeoffs are in [TURRET_HEAD_PROPOSALS.md](TURRET_HEAD_PROPOSALS.md).

## C83: bat variant and temporary nail-scatter head ideas (2026-10-06)

Owner suggests a bat head as a more accessible downgrade to blades and proposes that both could knock zombies back. Record Rotary Bat as a candidate sharing the rotary mechanism, and investigate brief native knockback with recovery protection for both variants. No exact reaction/chance, component availability, recipe or gameplay implementation is confirmed. The restriction against slowing and repeated permanent control remains; this suggestion reopens bounded knockback, not unlimited staggering.

Owner also proposes a dedicated tack/nail head that deploys temporary ground hazards when zombies are in range, potentially in 360 degrees on available tiles. This reopens the previously deferred ground-scatter concept for head discussion, not tack-filled bullet/Puddle modules. Working recommendation is bounded tile patches in a stepped circular radius, with valid floor/path checks, consumable batches, finite life/contact uses, no overlapping damage multiplication and no slowing/Bleed. Coverage/module dependency, damage/contact behavior, player danger, caps, persistence/expiry and supplies remain unresolved. Treat Nail Scatter as a candidate for R3C1-R3C2, not an approved implementation or release. See the updated head proposal for tradeoffs and proof requirements.

## C84: craftable improvised automation and expansion direction (2026-10-06)

Owner requests improvised Detection/Firing modules as a worse-performing craftable route to automation. Working recommendation keeps them as separate role variants, one active item per role, interchangeable with standard variants. Owner proposes approximately 15% click-only misfire for improvised Firing instead of the suggested firing-rate ceiling. Recommend one roll per otherwise valid automatic cycle, normal retry cooldown, retained ammunition/opening-round entitlement, no persistent native jam and no full offensive power charge on failure. Exact misfire tuning/resource policy and Detection's reduced range/acquisition remain proposals. Do not stack the earlier firing-rate penalty on top without a new decision.

Owner clarifies the Improvised Expansion Kit is a craftable version of the existing expansion packs that unlocks four module slots. Treat this as a four-slot expansion bonus through the existing dedicated socket; with the current four-slot base it provides eight total slots. It replaces rather than stacks with another kit. Owner requests a centered layout illustrated as four slots above two wider rows and allows adjusting counts to fit. Higher-tier sizes are not individually confirmed.

Working layout/tier proposal: four centered base slots plus two eight-slot rows; total capacities None/Improvised/Small/Medium/Large = 4/8/12/16/20. Each tier unlocks another group of four; on a half-filled eight-slot row, activate the central four first. Distinguish this proposal from today's implemented 4/6/8/10. Preserve existing item identities and stored modules; explicitly handle saved Sandbox values and over-capacity turrets. Larger slot counts require bounded effect combinations and battery-endurance measurements, not higher drain simply for owning empty slots. Expansion ammunition bonuses and all new recipes/tools/skills/XP remain unresolved. C84 plans exceptions for improvised crafting; standard modules do not automatically become craftable. No gameplay patch or installation is authorized by this clarification alone.

## C85: centered five-row expansion progression (2026-10-06)

After checking the implemented 4/6/8/10 capacities, owner selects a centered five-row diagram with 2, 2, 3, 4 and 5 slots. Map the rows in order to base, Improvised, Small, Medium and Large: total capacities are **2/4/7/11/16**. Each expansion unlocks the next complete row; kit bonuses relative to the new base are 2/5/9/14. Preserve the single dedicated expansion socket and replacement rather than stacking.

This latest layout supersedes C84's 4/8/8 diagram, 20-slot proposal and four-slot Improvised bonus. Improvised now supplies four total slots, adding two to the two-slot base. This consequence was stated in the update rather than silently retaining incompatible numbers. The base has enough space for Detection plus Firing; additional modules require expansion for that automatic configuration.

Record the selected progression in R3C8 and the module plan. Existing gameplay remains 0.2.28; this planning update does not implement the new kit or recipes. Base reduction must preserve installed items and respect saved Sandbox settings through a reviewed migration policy. UI must handle non-default capacities without hiding items and center each row while retaining stable inventory identity. Ammo bonuses, crafting requirements, exact starter-module tuning and the gameplay implementation checkpoint remain open.

## C86: compact-menu progression in equal upgrade groups (2026-10-06)

Owner questions the pyramid's height, requests clearer visual alternatives and permits progression changes. After previews of a four-column grid, a two-row eight-column grid and tier-labeled rows, owner accepts progression of **2, 4, 4, 4**. Interpret these as the four expansion-upgrade increments beyond the two-slot base: None/Improvised/Small/Medium/Large totals **2/4/8/12/16**, with replacement-kit bonuses over base of **2/6/10/14**. This mapping is stated back to the owner and supersedes C85's intermediate totals of seven and eleven.

Decouple capacity progression from physical menu rows. A compact two-row eight-column grid was the latest recommendation; the approval settles progression without separately requiring a named mockup or exact pixel geometry. The five-row pyramid is no longer a requirement. Keep the 16-slot maximum, single expansion socket, safe item preservation and battery/performance gates. R3C8 remains the implementation checkpoint; this update changes planning documents only.

## C87: proceed with package split and consolidate deferred testing (2026-10-06)

Following the next-patch recap and recommendation to split packages before adding content, owner approves proceeding with the update, will test later, and requests adding the outstanding test to the next patch while removing redundancies. Proceed with R1C1 loading/dependency proof and the reviewed R1C2 package split. This does not approve unresolved recipes, offensive-module tuning or every future roadmap item.

Use one complete next-patch owner test in [R1_PACKAGE_SPLIT.md](checkpoints/R1_PACKAGE_SPLIT.md). Carry forward unverified 0.2.27/0.2.28 behavior, remove repeated setup and separate test-round requests, and retain historical evidence without calling deferred tests passed. Do not require another 0.2.28 player test before the approved work.

Installed native inspection finds duplicate tile-definition numbers rejected. The existing 7316 registry contains both barrier and turret identities. Ask whether Turrets may require Traps (recommended existing-registry ownership) or whether standalone Turrets is mandatory before selecting a package workaround; do not turn shared-registry duplication into an accepted runtime error. Current installation stays intact during the proof.

## C88: fully independent entries and fresh test worlds (2026-10-06)

Owner explicitly approves full independence and a fresh test world after discussing the shared tile registry. Implement Traps-only, Turrets-only and both, with no required sibling/Core mod. Use new IDs OneMoreHorde_Traps and OneMoreHorde_Turrets; split tile registries into 7316/7317 and update turret sprite identities. No old combined-save migration is required for this development patch. Preserve item/state IDs and existing gameplay tuning.

Maintain canonical Source and generate shared helpers identically into each package; native loading executes each shared virtual Lua path once. Keep recipes, settings, models, loot and update loops in their owning entry. Adapt manifests, rollback-safe installation and component-aware local LootLab exports. Retire the managed combined installation to a verified full backup. C87 deferred testing remains one consolidated 0.2.29 checklist; neither approval nor native checks establish rendered or multiplayer acceptance. No remote push, Workshop upload or website deployment is authorized by this change.

## C89: waive remaining split regression round; investigate medical loot (2026-10-06)

Owner reports heavily stocked medical containers and asks whether global loot or jackpot behavior changed. Owner states much of the gameplay is already proven and explicitly skips the remaining test. Close the outstanding 0.2.29 checklist as owner-waived, preserving prior evidence without fabricating new passes. Future player checks should target changed behavior and credible regression risks. Read-only loot investigation finds unchanged component weights, only the intended split master-gate change, native medical loot 0.6 and roll multiplier 1.0. Component jackpots do not boost ordinary loot. A vanilla profession-house explanation is plausible but the exact containers are not identified. See TEST_v0.2.29.md; no gameplay fix or loot rebalance is authorized or indicated by these findings.

## C90: performance correction approved; combine with Bed Spikes subject to design (2026-10-06)

After the heavier-load pause report and audio-helper timing evidence, owner approves the proposed performance patch: isolate the audio stall, apply an evidence-backed mitigation and gate unnecessary reaction tracking behind detailed diagnostics. No further approval is needed for this scoped performance work. Preserve combat behavior, zombie hearing and intended audio variation; the exact blocking native operation is not yet identified.

Owner also selects Bed Spikes for the same content patch and asks what must be discussed. Existing automatic crossing for all players and independent Traps ownership remain confirmed. Discuss ground-bed versus grave workflow, footprint/placement, zombie contact cadence and damage, player injury/blocked crossing, durability/repair/pickup, and recipe/tools/skills/XP. New numerical defaults and recipes are proposals until answered. Prove native automatic traversal before promising completed gameplay; the performance correction need not wait for a blocked movement prototype. Broader turret-module content is not included in this approval.

## C91: short trip spikes, reinforced tier and brush-through movement (2026-10-06)

Owner revises Bed Spikes to short spikes with an increased zombie trip chance and large damage when a zombie trips onto them. Include basic and reinforced variants with a 1x2 footprint. Players use the bush/foliage hand-clearing movement animation instead of automatically jumping; this explicitly supersedes C14 and the jump requirements in C90. Owner drops the discussed barbed-flooring addition. Existing planned concertina/barbed-barricade concepts are not deleted or implemented by that exclusion; concertina is a movement reference, not an already completed feature.

Recommended trigger contract, awaiting confirmation: one trip roll per zombie per complete two-tile bed crossing, one damage event on a verified fall onto that bed, rearm after exiting with protection against repeated trip chains. No standing damage ticks or ordinary walking-contact damage. Reinforcement should primarily increase fall damage and durability; keeping trip chance equal is a proposal. Chance, damage, wear, already-fallen/crawler treatment, player speed/injury, placement surfaces and both recipes/tools/skills/XP remain unsettled. The previous proposed 1x1 recipe/numbers were not approved and must not silently become the 1x2 design.

Installed 42.21 movement/inTrees.xml names Bob_WalkTrees with WalkSpeedTrees and the intrees condition; it also emits DamageWhileInTrees. This confirms a native animation exists, not safe runtime integration or the intended injury policy. Do not enable incidental tree injuries by copying the animation without review. Native zombie fall/trip state and landing/contact attribution still require proof; available knockDown methods alone do not prove the requested trip behavior. Performance work stays authorized under C90.

## C92: movement-dependent player risk, repeatable chance-based falls and restrained damage (2026-10-06)

Owner confirms player walking across Bed Spikes has no scratch risk, while running into them does. Running scratch probability/severity and sprint treatment remain numerical/edge-case tuning; recommend sprint inherits running risk. Reinforced beds increase damage and durability only, with unchanged trip chance. Owner requires zombies to be able to fall zero times or multiple times; do not guarantee a trip or impose a lifetime one-fall-per-zombie limit. This supersedes a strict one-roll-per-complete-crossing proposal if it would prevent multiple legitimate falls during traversal. The comment was attached to turret-induced falls; preserve that context without claiming an explicit answer to every external-knockdown/crawler interaction.

Owner explicitly wants damage restrained enough that covering an entire base is not the obvious best choice. Working interpretation: every genuinely new fall can cause one spike hit, but lying/getting up is not a new fall. Recommend distinct upright movement opportunities for trip rolls, with a brief recovery guard shared across adjacent beds so dense placements cannot independently retrigger a zombie every tick. Do not multiply a single fall by the number of overlapped bed tiles/objects. These trigger/guard details remain proposed, not a tested engine capability.

Proposed first balance pass: basic 20 damage and reinforced 30 damage per valid fall (not percentages or instant kills), same trip chance, finite wear per damaging fall. Both numbers and wear/repair/recipe defaults still require agreement. Low damage alone does not prevent excessive crowd-control value; test adjacent beds and recovery as well as isolated damage before claiming balanced mass placement. No trap limit, blanket zombie immunity, barbed flooring or permanent movement modifier is approved.

## C93: Bed Spikes 20/40 damage; recovery rule still under discussion (2026-10-06)

Owner prefers 20 basic / 40 reinforced damage per valid fall, superseding the proposed 20/30 values. Existing Spike Barrier defaults are separately verified as 10 basic / 25 reinforced per qualifying front/end thump; do not change them or treat differing damage triggers as equivalent DPS.

Owner proposes five seconds of trip cooldown after three falls and asks for a simpler alternative. This is discussion, not a finalized recovery contract. Explain that the three-fall rule permits a burst of repeated knockdowns and needs a counter/reset policy. Recommended simpler alternative: a shared per-zombie five-second protection from spike-induced trips after standing up from each fall, with subsequent upright movement eligible for chance-based trips again. Starting on recovery avoids spending the protection while the zombie is already down. Do not suppress ordinary weapon knockdowns. Trip chance, valid roll opportunities, exact recovery behavior, external-fall damage, wear and recipes still require settlement and native proof.

## C94: approve combined patch, reinforced damage ratio and Bed Spikes construction (2026-10-06)

Owner approves the content plus performance patch and requests a consistent 2.5x increase for reinforced items. The stated working interpretation is reinforced damage: Bed Spikes become 20/50 per valid fall; existing Spike Barriers remain 10/25. This supersedes C93's 20/40 bed damage. Do not silently multiply trip chance, recipe costs or all durability values by 2.5. Owner's approval accepts the simpler shared five-second trip protection after recovery, replacing the proposed three-fall counter. Ordinary weapon knockdowns remain unaffected.

Owner explicitly answers the construction/service question with "Approve these defaults": any clear floor; four interchangeable planks/crafted spears and four bindings, retained sharp knife, Carpentry 1 and 10 XP; reinforcement costs two planks and eight nails, retained hammer, Carpentry 3 and 30 XP; free ten-second repair/pickup like Spike Barriers. These choices require no further recipe confirmation.

Two separately asked tuning questions remain unanswered: (1) proposed 20% trip roll on entering an eligible spike tile while upright/moving, 20% scratch risk for running/sprinting per bed entry, durability 100/200 and one wear per damaging fall; (2) proposed one spike hit for a fresh fall from any source landing on the bed, excluding existing crawlers/lying zombies from repeated hits. Preserve these as pending rather than converting the construction answer into approval of all questions. The patch is in progress; 0.2.29 remains installed. See PATCH_v0.2.30.md for source changes and evidence.

## C95: six durability per fall and confirmed prone-zombie handling (2026-10-06)

Owner answers the two remaining tuning bullets: "Let's do 6 damage to durability per fall. Confirmed prone zombies." Apply six shared bed durability loss per damaging zombie fall, replacing the proposed one wear. Confirm one hit for a genuinely fresh fall from any source landing on the bed, including turret knockdowns, with no repeat hit while lying/getting up and no damage merely for detecting an existing prone/crawling zombie.

Retain the other proposed defaults with this amendment: 20% trip chance per eligible upright moving tile entry, 20% running/sprinting scratch chance per whole-bed entry, and 100/200 durability. This interpretation was stated back while continuing implementation; it does not infer a new universal 2.5x durability multiplier. At six wear, the final damaging fall breaks a fresh basic bed on hit 17 or a reinforced bed on hit 34. Shared recovery remains five seconds after getting up; direct weapon knockdowns remain available during trip protection.

## C101 — crafting-only placement and 0.2.31 repairs (owner-approved 2026-10-07)

Owner explicitly commits to crafting and removal from Building, with Place Trap / Attach Trap / Install Trap labels. Owner approves authored native-animation bush-like traversal, requests noclip bypass, previously chose 2B (40% bed trip chance), 40% potato knockdown, Traps settings grouping, singular Barbed Panel naming, one repeating bed texture and two panel states with four directions. Preserve approved recipe costs and exact items; offer crafted portable reinforcement using existing service costs. Chosen implementation default for the new player sprint-trip control is 20%, exposed in Sandbox; it is not a verified native ordinary-bush percentage. Environmental laceration applies once on an actual new fall; walking remains safe.

[0.2.32 implementation](PATCH_v0.2.32.md) also fixes the observed barb service startup dependency and fence-adjacent bed placement. Native knockdown replaces animation-only zombie requests; controlled engine checks do not establish rendered recovery acceptance. [Four-step test](TEST_v0.2.32.md) replaces the remaining long checklist. No remote push, Workshop publication, broad content expansion or renewed old regression round is authorized.

## C102 — 0.2.32 owner findings and cleanup requests (2026-10-07)

Owner requests one grouping verb with no Five in names; choose Pack/Unpack. Turret placement should read Install Trap, not only component management. Owner asks whether modified recipes can collapse below their base family, reports panel placement failure and incorrect trip/run-brush visuals, and asks about weights. Preserve simplified Building as a deferred idea; do not re-enable it now. [Evidence and repair scope](TEST_v0.2.32.md#owner-findings--2026-10-07).

Native group presentation exists but the recipe-group enum only defines OPEN_BOX in current 42.21. A custom-family UI adapter needs a prototype. Current weights are 4/4/5 for panel/basic/reinforced bed; panel 2 with beds unchanged is a recommendation, not approved balance. Grouping and weight options are pending owner reply. No acceptance or new installed patch is established by this report.

## C103 � approved crafting organization, movement repairs and lighter beds (2026-10-07)

Owner approves the seven-feature patch after the names-only recap: consistent Pack/Unpack naming, collapsible crafting groups, forward trip animations, running brush-through animation, Barbed Panel placement repair, turret Install Trap action and trap weight rebalance. Latest approved loose weights are Barbed Panel 2, Bed Spikes 3 and reinforced Bed Spikes 4; Spike Barriers remain 4/5, their five-item packs remain 6.6/8.25, Turret Base remains 6 and Potato Launcher Head remains 4. This supersedes C102's pending weight recommendation and implements the owner's requirement that beds weigh less than the corresponding barriers.

Use native expandable list rows for exact OMH recipe families; icon view remains flat. Preserve each base/reinforced/pack/unpack recipe, filtering and actual recipe selection. Keep Building deferred; successful grouping may inform a later simplified design, but does not authorize re-enabling it. No recipe ingredient/skill/XP changes, new damage tuning or broader performance claims. Local implementation, validation, test tag and installation are approved; mirroring/publication remain separately controlled. See [0.2.33](PATCH_v0.2.33.md).


## C104: approved starter modules, expanded Manage, performance cleanup and faster service (2026-10-08)

Owner chooses 1A/2A/3A/4B, explicitly approves crafting, selects 5B, then confirms the patch. Approve two rows of eight; 2/4/8/12/16 total slots for None/Improvised/Small/Medium/Large; 75-percent automatic detection range after Range bonuses with normal acquisition speed; 15-percent configurable click-only automatic failure with ordinary retry cooldown, no spent ammo/shot power or persistent jam, and no manual-fire penalty. One Detection/Firing role across tiers; kits replace, never stack. Improvised reserve bonus 25; standard 50/100/200 bonuses remain. Empty slots add no power cost. Preserve saved Sandbox values and accessible existing/overflow contents; fresh-world tests remain authorized.

All three improvised items are craft-only: Detection consumes 3 Electronics Scrap, 1 Electric Wire and 2 duct-tape uses; Firing consumes 2 Electronics Scrap, 1 Electric Wire and 4 Screws; Expansion consumes 1 Small Metal Sheet, 1 Electronics Scrap, 1 Electric Wire and 4 Screws. Electrical 2, retained screwdriver and pliers, twenty-second base crafting and 15 Electrical XP each are approved. Standard modules/kits remain loot-based.

Approve cached advisory aim inventory summaries and removal of same-step duplicate LOS checks while retaining fresh shot checks and multi-tick search revalidation. This is not proof the reported client pauses are fixed. Owner also reduces portable trap/turret placement and pickup to five seconds each, including panel attachment/removal; repair and reinforcement remain ten seconds. Native instant-placement debug behavior remains native.

Local implementation, validation, tagging and installation are approved by "Approved to Patch". No remote push or publication is implied. The held 0.2.33 rendered test is consolidated into TEST_v0.2.34.md, not marked passed or waived. See PATCH_v0.2.34.md.

## C105: synchronize roadmap and checkpoint status (2026-10-08)

Owner asks what the documented next work was, challenges recommendations presented as the roadmap, and requests syncing checkpoints/phases. This authorizes documentation reconciliation, not a new gameplay slice, balance choice, reordered implementation sequence, remote push or publication.

ROADMAP.md is the canonical execution/status index. R1C1-R1C2 are implemented/native-verified with remaining owner regression waived by C89. R2C1-R2C3 and R3C8 are implemented; outstanding rendered acceptance is consolidated in TEST_v0.2.34.md, not passed or waived. R1C3 remains partial, with client pauses unresolved. C104 settles R3C8 recipes/layout/tuning independently of the still-planned offensive-module contract.

R2C4 concertina feasibility is the earliest unfinished content checkpoint in phase order, subject to the slowdown discussion. Phase 3 may proceed independently through R3C1 head selection or R3C4 module contract/battery baseline. The documented module sequence remains R3C4 -> R3C5 -> R3C6 -> R3C7. Initial Blow/Execute were already scheduled under R3C6; the assistant suggested prioritizing them without an approved reorder. No next gameplay patch is selected by this sync. Stable checkpoint IDs, historical evidence, Building deferral, optional scope and final Cure-simulation phase remain intact.

## C106: 0.2.34 feedback, crafting/Building organization and three module rows (2026-10-08)

Owner reports Test Completed and says unmentioned checks passed "(I think)". Record tentative owner-reported acceptance separately from log proof. Always inspect console.txt after owner testing. This capture confirms both 0.2.34 entries and no post-startup errors; zombie forward trips visibly overshoot beds and fail acceptance. Detailed disposition and captured-console hash are in TEST_v0.2.34.md. Do not repeat the full old test.

Owner requests crafting categories Normal, Reinforced and Packed, corresponding Building reintroduction, and three module rows. These supersede the installed recipe-family presentation, indefinite Building deferral and two-row layout direction; capacity changes were not requested. Working recommendation is six/six/four slots with the existing 16-slot maximum. Clarification is pending on whether Building places crafted items or consumes raw materials; Packed transport bundles must first be unpacked for placement. Do not infer a new packing operation for every item or alter recipe costs merely to populate categories.

Owner asks whether panel/bed Type naming is native and why Item appears. Inspection shows both use ItemType=base:normal and DisplayCategory=Material. Native animal traps also use base:normal but DisplayCategory=Trapping. Item is our internal script-ID suffix distinguishing portable items from world entities; it is not a native type requirement or normal localized name. Preserve IDs pending any explicit migration decision; player-facing category changes need not rename IDs or set native hunting-trap behavior. Screenshot group IDs are native debug-mode annotations.

Investigate the zombie-only custom Bob_RunStumble node, animation displacement and delayed on-floor detection before selecting a bounded short-trip correction. Current damage requires a fresh fall while actually on the bed; do not hide overshoot by automatically damaging actors who land elsewhere, freezing all zombies or changing potato knockdown. Installed AnimNode exposes useDeferredMovement, but a specific XML/runtime correction and rendered behavior are not verified by inspection alone. New roadmap content-track decisions remain postponed by owner direction.

## C107: approved Building fallback, 4/6/6 layout and feedback repair (2026-10-08)

Owner selected 4/6/6 after confirming unlock totals 2/4/8/12/16, asked to use crafted items before falling back to the crafting recipe, then explicitly said "Approved. Go ahead and patch." Implement 0.2.35: native Normal/Reinforced/Packed crafting categories; one Building route per defense using an exact carried item first, otherwise the original recipe and its actual output, followed by five-second placement. Preserve recipe skills/tools/materials/time/XP and exact turret contents; no recursive ingredient crafting, duplicate charge or placement XP. Cancelled placement retains completed output. Packed remains crafting-only. Remove the superseded collapsible family adapter.

Three Manage rows are 4/6/6; capacities and saved values remain unchanged. Correct zombie-only bed-trip displacement while retaining native recovery and actual-on-bed damage checks. Preserve internal item IDs and player/weapon behavior. Prior tentative owner passes remain as recorded by C106; run only TEST_v0.2.35.md after local checks. Local patch/install authorized; no GitHub push, PR or Workshop upload. Roadmap new-content choices remain postponed.

## C108: mirror every update and versioned test findings (2026-10-09)

Owner: "A dev push to GitHub should be posted every update, and test findings for those versions should be posted on the GitHub as well." This is standing authorization and a required handoff step for completed project updates, including documentation-only changes and test results without a following patch. Commit and mirror through root OMH.cmd; do not require another push approval. Include eligible immutable test tags and readable version-specific findings with actual evidence/pending status. Inspect console.txt after owner testing; do not claim unrun checks passed.

Supersedes C96's owner-run-unless-requested mirroring restriction and earlier patch-specific no-push statements for this development synchronization. Preserve the existing branch/draft-PR route into dev, remote verification, immutable tags, clean intended commits and separate merge/official-release/Workshop authorization. No gameplay change or version bump. Current catch-up includes installed 0.2.35 and already-recorded earlier test findings; 0.2.35 gameplay acceptance remains pending.

## C109: 0.2.35 owner findings and proposed correction scope (2026-10-09)

Owner clarifies Normal/Reinforced/Packed meant dropdown/group names, not top-level categories; reports continued forward zombie launch, one-placement Building interaction, and missing zombie trip/spike impact sounds. See TEST_v0.2.35.md for native inspection and captured-console evidence. These are reported failures/requirements, not proof of unmentioned passes or approval of a chosen replacement animation/audio implementation.

Proposed next correction: restore OMH parent categories with expandable tier/pack groups; evaluate a native forward collapse instead of Bob_RunStumble; keep Building placement active while rebinding each actual item or original-recipe result; use native ZombieTrip/BodyHitGround and crafted-spear impact audio once per appropriate event. Preserve recovery, damage, recipe costs and player state. Native clips/sound registrations exist, but rendered displacement and audible suitability remain unverified. No gameplay edits/version bump in this review. C108 authorizes immediate findings synchronization.

## C110: approved tier groups, zombie collapse, continuous Building and audio (2026-10-09)

Owner approved the C109 correction scope and explicitly distinguished player trips from zombie forward-collapse. Implement 0.2.36: restore OMH parent categories and use Normal/Reinforced/Packed expandable recipe groups; keep Building active with exact carried-item rebinding and original-recipe fallback on the next placement click; use native zombie forward-collapse and trip/landing/spike-impact audio. Preserve player movement, actual-on-bed damage, recovery, costs and item contents. Packed remains crafting-only. Local validation/install and C108 development synchronization apply; no automatic merge, Workshop publication or new roadmap content. Headless checks do not establish rendered/audio acceptance; use only TEST_v0.2.36.md.

## C111: durable per-turn context and semantic review (2026-10-09)

Owner challenges the repeated promise to check consistency and explicitly requests updating the documentation consulted every turn. Add a short review section near the top of project AGENTS.md, a workspace routing pointer and a current-status reminder. Require a fresh read of that section and CURRENT_STATUS each project turn and after compaction, relevant decision/checkpoint review before recommendations or changes, and player-workflow/semantic review before handoff. Persist corrections and unresolved findings with their real approval and acceptance status; retain C108 documentation mirroring. This is process/documentation authorization, not a gameplay patch.

Owner identifies Normal under OMH: Turrets as redundant and proposes Turret Base outside groups with Modules and Heads collapsibles. Recommendation also puts complete turret recipes alongside the base, includes expansion kits in Modules, keeps Normal/Reinforced/Packed for Traps, and leaves only placeables in Building. Record as proposed correction, not approved or implemented. See TEST_v0.2.36.md for the scoped owner finding and console review; no completed test or unmentioned passes inferred.


## C112: approved turret grouping and cross-system review (2026-10-09)

Owner approves the C111 grouping correction and explicitly asks for discussion of current issues across audio, visuals, gameplay and code. Implement 0.2.36.1: base/complete turret recipes at root, Heads and Modules (including expansion kits), trap Normal/Reinforced/Packed retained, Building turret base at root. Preserve recipes, items, costs, timing and combat. Review relevant neighboring behavior and document evidence-backed findings and recommendations in REVIEW_v0.2.36.1.md; this does not approve all proposed fixes or new content. Synchronize stale art guidance and the durable review checklist. Continue C108 local validation/install and development mirror; no merge or Workshop publication. TEST_v0.2.36.1.md replaces the uncompleted 0.2.36 checklist, retaining its pending rendered checks.


## C113: review repairs and elapsed-time choice (2026-10-09)

Owner requests fixing all actionable findings discussed after 0.2.36.1 and asks whether anything requires discussion. Implement automatic/manual range feedback, explicit alternate-method recipe naming and accurate output descriptions, bounded native barb contact audio, redundant overlay-work reduction and aggregated render diagnostics. Owner explicitly selects counting elapsed active time after stalls, at most one due action per update without backlog bursts, excluding pause/offline time. Implement shared pause-aware observation with existing persisted remaining-time restoration. Preserve balance, crafting inputs, item IDs and SP scope. Existing forward-collapse remains subject to rendered acceptance; do not invent a new animation fix or claim client stalls resolved without workload evidence. Broader documented boundaries such as multiplayer/final art/player barb injury remain roadmap work, not incidental fixes. Version 0.2.37; TEST_v0.2.37.md replaces older outstanding checklists. C108 requires local install, immutable test tag, development mirror and versioned runtime findings.


## C114: complete-turret recipe removal request and naming discussion (2026-10-10)

Owner requests removing Potato Turret and Potato Turret (Without Tire Pump) crafting shortcuts because players can assemble the base/head manually. Owner asks to discuss shorter native-style names, possibly Improvised for the alternate head method and another word for starter modules. This turn records the requested removal and naming proposal only; no gameplay patch or naming approval is claimed. Keep base/head crafting, manual assembly, existing items and Building's base-recipe fallback.

Installed 42.21 English Recipes.json includes Make Improvised Flashlight, Make Improvised Gas Mask and Make Improvised Screwdriver, alongside Make Makeshift Radio and Make Makeshift Walkie Talkie. Vanilla uses both adjectives; it does not establish a universal term for alternate recipes. Recommendation pending owner choice: Potato Launcher Head (Improvised) for the pump-free recipe only; Makeshift Detection Module, Makeshift Firing Module and Makeshift Expansion Kit for the weaker starter items. Both head methods still output the same ordinary Potato Launcher Head; retain an explicit tooltip describing the alternate materials and identical result. Names alone do not explain the distinction between a recipe method and an item tier.

Current pump-free head requires Mechanics 4 versus 2, six Scrap Metal versus two, and recipe time 250 versus 200. It removes the Tire Pump requirement, not skill/material difficulty; do not reduce costs or stats under a naming request. Makeshift is especially consistent with vanilla crafted electronics. Apply any later approved rename across recipes, inventory names, management labels and tooltips while preserving internal IDs. Removing complete crafts also needs cleanup of their special output callback, translations and tests; do not retain an empty group or remove the separate component workflow. No new test result, version, package or Workshop-note change this turn. C108 development documentation mirror applies.


## C115: naming approved for bundling; next content discussion (2026-10-10)

Owner approves the C114 naming scheme and asks what next update can include it. Queue removal of both complete Potato Turret craft shortcuts, recipe-only Potato Launcher Head (Improvised), and Makeshift Detection Module / Makeshift Firing Module / Makeshift Expansion Kit across player-facing surfaces. Keep the standard head output, internal IDs, existing items, costs and balance. Bundle the cleanup with the next selected patch rather than installing a naming-only build now. Approval is recorded; implementation remains pending.

The canonical next unfinished content checkpoint remains R2C4 concertina movement feasibility, alongside ongoing R1C3 performance evidence. Recommend combining the cleanup with concertina only after approving its movement contract and proving native feasibility. Proposed distinction: contact damage plus localized, non-stacking slowdown only while touching the wire, with no lingering effect. This is a recommendation, not owner approval or engine proof. C81's concern about undermining Horde Night zombies still requires an explicit decision; damage-only concertina would overlap Barbed Panel's role. Footprint, player effects, damage/wear, recipe/tools/skills/XP and service details remain to be settled after the core role choice. New heads and offensive modules remain the documented independent Phase 3 alternatives, not a silently reordered next patch. No gameplay/version/test change in this discussion; C108 mirror applies.


## C116: contact-only slowing, Sandbox sorting and recap format (2026-10-10)

Owner approves contact damage plus non-stacking slowdown while touching concertina, asks for the same behavior as Barbed Panels, and asks whether panels already slow. Current code does not: BarbRuntime applies timed damage/audio/wear, with no movement change. Record adding the requested contact slowdown to both as the proposed combined patch scope; do not claim it exists in installed 0.2.37. Owner delegates implementation method, preferring native temporary movement scaling without saved original-speed restoration. Reduce current movement by a divisor only during actual contact, end on exit, and preserve other speed effects. The contextual approval includes Horde Night zombies; the prior slowing-turret exclusion remains. Recommend divisor 2 (half speed), not yet owner-approved balance. Concertina footprint, player behavior, durability and recipe still need decisions and native zombie feasibility remains unproven. This turn is discussion/read-only investigation, not a gameplay patch.

Owner reports uncertain Sandbox header sorting and requests better organization within categories. Confirmed: CapacityImprovisedModuleBonus, CapacityImprovisedAmmoBonus and ImprovisedFiringFailure are omitted from SandboxUI header mappings and fall into the final section; the Operation heading contains actual mojibake. Queue semantic grouping/order and heading cleanup across applicable pages, preserving option IDs, values and package-specific visibility. Detailed evidence and proposed scope: checkpoints/R2C4_CONCERTINA.md. No owner test was reported this turn; no new console acceptance claim.

Owner establishes future update recaps: feature-name-only bullet points, with additional prose only for important information or decisions. Persist in the per-turn project agreement. C114/C115 removal/naming remains approved and bundled; C108 documentation mirror applies. No implementation, new test result, version bump or Workshop changelog reset.


## C117: half-speed contact default approved (2026-10-10)

Owner answers "Approved" to the explicit half-speed default question. Set the planned zombie contact divisor to 2 for Concertina Wire and Barbed Panels, including Horde Night zombies, without stacking or lingering effects. Preserve other movement modifiers and do not infer engine feasibility or implementation from this approval. Existing cleanup/naming/Sandbox scope remains bundled. Installed 0.2.37 is unchanged.

Propose the remaining concertina defaults together for owner review: one-tile freestanding coil on clear floor; 50 independent HP with one wear per damaging activation; existing panel-style 10 zombie damage every two seconds; craft from one Barbed Wire and two Wire with retained pliers, ten-second base crafting, no skill requirement or crafting XP; five-second placement/pickup, ten-second free repair, no service XP. Player proposal is the same half-speed contact reduction without introducing injury in this first slice, matching panels' existing no-player-injury scope; this is not approved by the zombie-speed answer. These are proposed defaults, not approved recipes or implementation. Native movement feasibility remains required. C108 mirror applies; no new test outcome or version bump.


## C118: Bed Spikes-style player injury and independent placed spike tiles (2026-10-10)

Owner rejects the proposed no-player-injury treatment for concertina/panels and requests the same treatment as spike flooring. Current BedPlayer rules are the reference: walking does not roll a scratch/trip; running/sprinting rolls a 20% scratch chance on entry; sprinting additionally rolls a 20% trip chance; a fresh landing on spikes produces one environmental cut; god mode avoids injury and noclip/ghost bypasses custom traversal. Apply this requested player-treatment direction to both wire and panels while preserving their actual contact geometry and native door/window/fence movement. It does not mean repeatedly inflicting fall wounds while already prone. Numerical values reflect current defaults, not a new unrelated balance change. C117's other proposed concertina defaults are not implicitly approved by this correction.

Owner also requests two separately durable traps from spike placement so they do not break together. Context is interpreted as Bed Spikes, including reinforced beds, not Spike Barriers. Current BedSpikes stores one health record for both tiles, BedRuntime retires the whole record on depletion, and BedService requires both parts and returns one item deploying two tiles. Requested direction is independent tile health, wear, breakage and servicing with the original two-tile placement intent retained. A one-tile survivor must never recover into an item that creates two tiles.

Propose 50 basic / 100 reinforced HP per tile (rather than silently doubling the existing 100/200 total), retaining six wear on the tile receiving a fall and 20/50 fall damage. This preserves aggregate nominal durability, though six-wear rounding changes maximum damaging falls from 17/34 shared to 18/34 across evenly used independent halves. Propose one current-cost craft producing two single-tile inventory units; pair placement consumes two units, each pickup returns one, and a lone recovered unit can place one. Per-unit weights would be 1.5/2 to retain the current total 3/4. Per-unit reinforcement would consume one plank/four nails and grant 15 XP, retaining the existing pair cost/XP and Carpentry 3/hammer requirement. These inventory, numerical and recipe consequences require owner choice before implementation. Do not introduce new Bed Spikes packing recipes: none currently exists. Adjacent independent tiles must not add player entry rolls or duplicate damage per fall merely because IDs differ; retain zombie recovery protection and current tile-based trip eligibility.

Discussion and code inspection only. No gameplay patch, new test outcome, migration promise or version bump. Continue bundling C114-C117 and mirror the record under C108. Fresh-world policy remains; existing saves are not silently converted during this discussion.


## C119: approved combined plan and mandatory GitHub planning handoff (2026-10-10)

Owner: "Anytime we discuss and confirm plans, they should reflect on our GitHub under some planning section, possibly provided by OMH: Turrets & Traps - Planning chat in codex. All approved." Add a persistent Planning entry point, required same-turn planning synchronization and explicit proposed/approved/implemented/verified distinctions to the existing C108 pipeline. Plans discussed here or in the named Planning chat must be reconciled into repository records and pushed, not left only in chat. Keep GitHub as the shared handoff; the named chat is a planning surface, not an automatically synchronized authority or a required intermediary. This does not create a scheduled automation, authorize automatic merges, or require unsolicited cross-chat messages.

"All approved" settles the current combined C114-C118 plan, including the remaining concertina defaults and independent Bed Spikes inventory/durability consequences. Concertina is one tile, freestanding on clear floor, 50 HP/one wear per damaging activation, panel-style 10 zombie damage every two seconds, one Barbed Wire + two Wire, retained pliers, ten-second base craft/no skill gate/no XP, five-second placement/pickup and ten-second free repair/no service XP. C118 injury rules replace the rejected no-player-injury proposal. Half-speed contact is shared by wire/panels, non-stacking and only during actual contact. Bed Spikes are two independently durable tiles (50/100 HP each, six wear on the hit tile, 20/50 fall damage), craft two single-tile units at current pair cost, place pairs by consuming two, recover/redeploy one tile without duplication, weight 1.5/2 per unit, reinforcement one plank/four nails/15 XP with retained hammer and Carpentry 3. Preserve neighboring-tile injury-roll protection, per-fall damage and recovery. Include naming/complete-recipe cleanup and Sandbox organization. No further design approval is required for these settled values.

Approval does not establish native zombie slowdown feasibility, migration support, rendered acceptance, or a shipped patch. The present pipeline update records the approved implementation queue; installed 0.2.37 remains unchanged. Checkpoint brief owns the detailed contract; PLANNING.md is the discoverable status/index, DECISIONS.md preserves provenance, ROADMAP.md owns phase order, and CURRENT_STATUS.md owns runtime handoff. Use the actual active PR branch when dev is older. Read-only inspection found the named Planning chat last read 4b9b1c9; do not present that old chat answer as the latest project state. No message was sent to that chat in this update.


## C120: implement the approved combined patch (2026-10-10)

Owner: "Approved for patch". Proceed with the full settled C114-C119 bundle, local verification/install and the standing C108/C119 GitHub mirror. No new design approval is needed. Version 0.2.38 implements Concertina Wire, shared contact-only movement division/player injuries, independent Bed Spikes tiles/inventory, semantic Sandbox organization and the approved crafting/naming cleanup. Native implementation scales pending displacement before collision resolution, not persistent speed; native climbing/falling states are preserved. Gameplay acceptance, dense-client pauses and external movement-hook compatibility remain distinct from native/unit checks. Fresh worlds remain required; no automatic merge or Workshop publication. See PATCH_v0.2.38.md, TEST_v0.2.38.md and RELEASE.md for final verification/install evidence.

## C121: 0.2.38 mixed-defense lag report and proposed audio follow-up (2026-10-10)

Owner: "Looks like it's functioning, but there was some lag when using Spike Beds, Concertina, and a Turret." This is provisional general functional feedback and a performance failure, not approval for new gameplay changes. Captured both loaded 0.2.38 entries; measured update gaps reach 1,077 ms and the setPitch interval reaches 674 ms. Detailed evidence/limits are in TEST_v0.2.38.md. Recommend removing runtime per-play pitch variation from effects/reload while preserving clips, selection, volume and hearing, plus gated aggregate reload/trap timings. Reduced pitch variation is the tradeoff. Proposal awaits approval under the test-findings discussion rule; package/version/tag remain unchanged. C108/C119 authorize mirroring these findings/planning without a new patch.

## C122: preserve pitch variation and optimize again (2026-10-10)

Owner: "We should strive to keep the pitch changing, isn't pitch differences in zomboid native to sounds? We should try and optimize again." This authorizes the focused optimization pass with pitch variation preserved, superseding C121's removal-of-variation proposal. 0.2.38.1 uses native clip pitch/random selection for all owned file sounds, retains 101 values from 0.950 to 1.050 and existing sample weighting, and removes the noisy emitter setter from effects/reload. Existing FMOD events retain authored behavior; unrelated sound scripts are unchanged. The same pass rejects unoccupied Concertina tiles before world resolution, reuses the nearby bucket, and adds aggregate reload/trap timings. No balance or content change is authorized by this correction. Native parser/queued-pitch proof and focused tests are recorded in PATCH_v0.2.38.1.md and TEST_v0.2.38.1.md; owner performance acceptance remains open. C108/C119 require the development mirror, not a merge or Workshop release.

## C123: positive lag result in 0.2.38.1 (2026-10-10)

Follow-up: "Yea seems fine," then "Why are we still playing if it works?" Close the current owner lag test as accepted for the reported issue. The continued "Test now" handoff was unnecessary; no further play is required. Retain measured limitations without creating an indefinite testing obligation. Broader R1C3 work remains separate; no new patch is authorized.

Owner: "Seems like lag is gone." Console capture confirms the loaded version and supports substantial audio improvement: 3-ms audio max versus 674 ms before, and 2-ms bed/barb callback maxima. Largest active-update gap remains 368 ms; the firing sample has 11 shots versus 58 before. Record a positive tentative result for perceived lag in this run, not blanket performance/audio acceptance. No repeated checklist, new code, publication or roadmap expansion is authorized. Keep residual performance and existing authority scope in R1C3; detailed evidence is in TEST_v0.2.38.1.md. C108 requires mirroring this result.


## C124: accurate next-patch handoff and roadmap reconciliation (2026-10-10)

Owner asks what patch they are waiting for and requests the current roadmap/checkpoints. No next patch is selected or underway; the prior Wait for a patch label was misleading. C123 closes the current lag test. Reconcile the stale 0.2.37 status table and pre-fix lag wording without promoting unmentioned content checks to passes. Recommend R3C4 offensive-module contract/battery baseline next; R3C1 new-head selection is an independent alternative. Retain R3C4 -> R3C5 -> R3C6 -> R3C7 order and completed R3C8 implementation. This records a recommendation, not approval or new gameplay. No additional owner test is requested. C108/C119 require mirroring this correction.


## C125: module planning track selected (2026-10-10)

Owner: Modules. Select R3C4 contract/battery baseline discussion, preserving R3C5 -> R3C6 -> R3C7 order and deferring new-head selection. This does not approve unresolved numbers, recipes or implementation. The checkpoint brief records the current ammo/stack/Fragment choices and their tradeoffs; recommendations remain proposals. Installed 0.2.38.1 and the completed lag test are unchanged. C108/C119 mirror applies.


## C126: Splitter/Fragment stacking selected; magazine capacity question (2026-10-10)

Owner selects 2B slot-limited Splitter stacking and 3A fixed-five Fragment damage stacking with a cap. These supersede the four-Splitter proposal and fragment-count stacking alternative. Owner asks about a Mag Size module to support paid Splitter children (1B); ammo choice and module scope/tuning remain open. Read-only source/native-Lua review and proposed +2 ready rounds per Magazine Module are recorded in R3_OFFENSIVE_MODULES.md. Native firearm capacity lifecycle is not proven, and no gameplay implementation, recipe, numerical cap or test is approved here. Mirror under C108/C119.


## C127: magazine percentage-growth direction (2026-10-10)

Owner requests multiplicative capacity with upward rounding and suggests linear +25% per module. Record ceil(base * (1 + 0.25 * count)) as the working formula, replacing the assistant's flat +2 proposal. Round once; do not compound or grant a hidden minimum increase per stack. The checkpoint records small-magazine plateaus and the five-module requirement for base-1 capacity to reach three. Exact 25% remains a suggested value pending design settlement; no implementation or Splitter ammunition choice is inferred.


## C128: minimum one-round magazine gain (2026-10-10)

C128: owner requires at least one added round per Magazine Module, explicitly base 1 plus two modules = 3. With the working linear 25% rate, use ceil(base + count * max(1, base * 0.25)), rounded once from the unmodified base. This supersedes C127 small-magazine plateaus. Examples for 1/2/3/4 modules: base 1 -> 2/3/4/5; base 7 -> 9/11/13/14; base 14 -> 18/21/25/28; base 30 -> 38/45/53/60; base 60 -> 75/90/105/120. No compounding or per-module rounding. Native capacity lifecycle, Splitter ammo rules and other R3C4 choices remain unresolved; no gameplay patch or test is authorized by this arithmetic clarification.


## C129: 35-percent capacity and one-round ammo exception (2026-10-11)

Owner selects 35% linear capacity per Magazine Module, minimum +1 with final rounding, superseding C127/C128's 25%. Owner requests a one-round ammo exception; clarify effective one-round capacity versus any last loaded round before implementing. Context is Splitter extra-round charges, preserving normal primary-shot consumption. The checkpoint documents both interpretations and the last-round incentive tradeoff. No patch authorization inferred.


## C130: last-loaded-round Splitter exemption approved (2026-10-11)

Owner selects B: any weapon with one loaded round remaining gets the full Splitter volley for that round, irrespective of magazine capacity. Deliberate one-round loading was explained and is accepted. Consume the primary round; never fire with zero. Do not substitute the recommended capacity-one restriction. Behavior with two or more insufficient rounds remains open; full volley consuming remaining rounds is a new recommendation, not approval. No code/package/test change.


## C131: insufficient-ammo full volley approved (2026-10-11)

Owner selects A: fire the full configured Splitter volley when any ready ammunition remains; consume the lesser of ready rounds and normal volley cost. Four Splitters produce five projectiles for five, two or one consumed rounds when those are the respective ready totals. Zero cannot fire. This generalizes C130 without a capacity restriction or reserve-ammunition charge for the shortfall. Remaining R3C4 rules/native proofs are separate; no gameplay patch approval inferred.


## C132: paired 1x2 Concertina requested (2026-10-11)

Owner requests 1x2 Concertina similar to Spike Barrier, explicitly rejecting independent Bed Spikes halves. Queue one carried item, paired placement, shared durability, whole-trap repair/pickup/depletion. Retain existing recipe, weight 2, 50 total HP and contact rules; no balance change was requested. Prevent seam-based extra activations/slowdown and duplicate refunds. Exact implementation and verification belong to the upcoming patch; no old-save migration or change to independent Bed Spikes is implied. See R2C4_CONCERTINA.md; R3C4 module choices remain open.


## C133: approve paired Concertina implementation (2026-10-11)

Owner: "Approved" after the C132 paired-wire recap. Implement the 1x2 shared-identity/durability/service conversion now, preserving the settled recipe, weight 2 and total HP 50. Module contract choices remain separate and incomplete; this does not authorize invented Fragment tuning or unsupported native magazine behavior. Local validation/install and C108 development mirroring apply. See PATCH_v0.2.39.md and TEST_v0.2.39.md for implementation and evidence.


## C134: Magazine requested; discuss Splitter and module scope before patching (2026-10-11)

Owner: "Add the new module as well", then "Check for splitter too. We should discuss the rules of possible modules to add this turn". Interpret the singular new module as Magazine from C126-C131. The later instruction requests discussion before implementation, while retaining the intended module addition. Inspect active fb51d09 and fetch origin; no gameplay edits, version bump, tests or installation in this discussion. Existing growth/ammo/stack decisions remain approved; new choices below are recommendations only. Record/mirror this handoff under C119. See R3_OFFENSIVE_MODULES.md C134.


## C135: module scope, ammo fallback, Splitter coverage/effects/power selected (2026-10-11)

Owner selects 1B, 2A with reserve -> player inventory -> floor fallback, 3A, 4A and 5A from C134. Include Magazine, Splitter and Fragment in the intended patch, with Fragment tuning still to settle. Do not retain C134's reject-on-full-reserve policy: any rounds that cannot enter reserve go to player inventory, then floor if inventory is unavailable/full. Preserve every round. Splitter fan may leave the targeting cone, retains range/wall checks, caps total fan at 180 degrees by tightening high-stack spacing; children deal direct damage without extra splash, knockdown or triggered module effects. Splitter adds 25% of base firing power cost per copy; Magazine has no extra draw. No change to C129-C131 capacity/ammo rules. Installed 0.2.39 remains unchanged during this design discussion.

Installed B42.21 ActionManager.lua Actions.addOrDropItem adds an item to character inventory, compares capacity weight with effective capacity, then removes/drops it on the current square if over capacity. ISCraftAction.complete calls it. This confirms a native inventory-to-floor mechanism, not a complete turret transaction or a generic arbitrary-failure handler. Implement reserve-first routing and valid-destination/replay/ammo-conservation checks around it. See R3_OFFENSIVE_MODULES.md C135 for the remaining Fragment proposal. Inspected 8c3f396 and fetched origin.


## C136 - approved module patch (2026-10-11)

Owner: "Approved." This approves the complete C135 Fragment baseline alongside Magazine and Splitter, and authorizes implementation/verification/install. No further gameplay decision is required for this slice. [0.2.40 patch](PATCH_v0.2.40.md) implements the selected rules; automated/native/package verification and tagged installation pass. [Combined test/evidence](TEST_v0.2.40.md) includes the held paired-Concertina check. R3C4 contract is settled for this slice; R3C5 is implemented pending verification and rendered acceptance. R3C6 stays next for later discussion; R3C7 combined balance/endurance remains pending. Earlier open-choice paragraphs are historical and superseded by this approval.

## C137 - Enhanced modules, cadence/placement/volley corrections and LootLab (2026-10-11)

Owner reports M4 about 0.75 shots/sec and M16 about 0.9 with Firearms, a placement stop after many Spike Barriers, and incomplete two-Splitter visuals. Requests OMHTT + Trap/Turret/Module item families, with no old-save migration, and explicitly selects "Two modules; keep Rapid-Fire boost" for the proposed Enhanced Firing/Detection defaults. Subsequently requests Makeshift/Small/Medium/Large reserve bonuses +100/+200/+400/+650 and "Make sure to update lootlab with the new loot". This authorizes the combined corrective/content patch, local install, GitHub development mirror and corresponding hosted LootLab catalog refresh. No new crafting recipes, multiplayer enablement or Workshop publication.

Implemented 0.2.41: Enhanced Firing replaces the Firing role (100% versus normal 75% native-derived firearm cadence at defaults); Enhanced Detection replaces Detection (3x turn speed, 0.10-second scan interval). Both are loot-only, nonstacking by role, with Large Expansion's exact weight and six eligible pools. Rapid-Fire retains its bounded boost; potato cadence remains unchanged. Automatic-capable mounted guns use their Auto capability without changing the item's selected fire mode. Background target scans no longer hold an otherwise ready retained-target shot. Actual cadence still depends on turning, reloads and workload.

Real barrier placement no longer uses the diagnostic 64-tile registry limit; diagnostic placement keeps its limit. Splitter/Fragment tracer batches are presented together after bounded ray resolution and clipped to visible space; primary/side damage remains independently validated. The family ID rename deliberately requires a fresh test world. Existing known loot weights/global multipliers remain unchanged; new loot adds new rolls, so total module finds can increase.

Native capacity caveat: B42 clamps ordinary bag storage to 50 and world storage to 100 weight. The existing native limits remain in force; these bonuses are count ceilings, not a guarantee that any ammunition mass fits. Native proof fits 750 pistol rounds and stops at 228 potatoes in a portable test turret. A proposed separate storage redesign was offered for discussion; it is not approved or implemented. No physical ammo weight is reduced or converted into virtual ammo.

Owner follow-up reports the handheld M4/M16 also fire slowly and asks whether T&T modifies handheld weapons. Source review finds no writes to fire mode/recoil delay/cyclic rate or player attack timing. A native Firearms fixture checks those properties before and after feeding/firing all 51 supported guns; they remain unchanged. Mounted operation does mutate real ammo/chamber state. Firearms defaults these two rifles to Single and exposes Auto; selected mode is a diagnostic check, not a confirmed explanation of the owner's handheld behavior. No handheld gameplay change is authorized or included.

[Patch](PATCH_v0.2.41.md) | [Verification and focused owner test](TEST_v0.2.41.md). R3C5 acceptance remains open; R3C6 remains later discussion. Branch inspected at 7a9cf388; origin/dev was fetched and is an ancestor; only existing draft PR #1 was open. Rendered/audio acceptance remains distinct from automated/native verification.

## C138 - owner test complete and console review (2026-10-11)

Owner: "Test Complete." Close the requested 0.2.41 test round with no issues reported; do not infer separate attestations for every checklist item or request a repeat. No new gameplay is authorized by completion.

Capture `20261011-143314-8532`, 2026-10-11 14:33:14 -04:00; SHA-256 `492B23B4E8B32A79F76982366FC885317F959D71BA4742556CB64B52DB25FB0C`. Both installed markers and live diagnostics identify 0.2.41, game 42.21. Seventy-four summary windows record 154 firearm shots. Effective configuration changes from 296.296 to 222.222 ms firing intervals and from 100/two to 750/sixteen ammo/module capacity. These support Enhanced Firing/Large Expansion configuration, not sustained measured RPM.

No exception/stack trace or `status=Limit` appears. Nineteen engine ERROR lines concern fonts, fluid names, native recipe icons, map data or vegetation tiles; no OMHTT exception found. This is not a whole-console clean claim. Maximum active-update gap is 331 ms; firing work peaks at 4 ms, shot/reload audio at 1 ms and effect/head rendering at 2 ms. The gap's cause is unassigned; retain under R1C3 without a repeat test or universal performance clearance.

The capture does not independently prove the modded M4 case, >32-barrier placement, every side tracer, paired-Concertina servicing or authenticated LootLab appearance. Unreported specifics and handheld slowdown remain distinct from the completed round. Reviewed summary: diagnostics/v0.2.41/owner-test-20261011.json; raw console stays local. R3C6 Piercing/Initial Blow/Execute/Impact is next for discussion, not approved implementation. Branch inspected at 29820ad; origin fetched; draft PR #1 remains the only open PR.

## C139 - R3C6 choices requested (2026-10-11)

Owner: "Give me the choices and your recommendations for Piercing, Initial Blow, Execute, and Impact." Offered [four A/B behavior choices](checkpoints/R3_OFFENSIVE_MODULES.md#c139---r3c6-choices-offered-not-approved-2026-10-11), recommending capped attenuating penetration, >=90%-HP Initial Blow, <=25%-HP Execute and stackable first-shot Impact chance. These numerical defaults are unapproved proposals. Shared compatibility/child-effect/reload/health-source rules and remaining loot/power/endurance choices are explicit in that record. Native maximum-health compatibility and standing stumble need proof; no engine capability is inferred from approval. Installed 0.2.41/test completion unchanged; no gameplay, version, test, install or Workshop change. Active f6ca54d inspected; origin fetched, existing PR #1 only. Record/mirror planning under C119.

## C140 - uncapped module selections and Impact reconsideration (2026-10-11)

Owner selects 1B, Initial Blow >=90% HP/+25% per copy without cap, Execute instant death at <=7% HP with +7 percentage points per copy, and 4A while asking for a better unlimited-stacking approach. [Current contract](checkpoints/R3_OFFENSIVE_MODULES.md#c140---selected-uncapped-rules-and-revised-impact-proposal-2026-10-11) records selected rules versus the proposed Impact diminishing-return curve (60% first copy, each additional removes 25% remaining failure chance). Existing physical slot limits remain; no blanket removal of unrelated module caps. Explicitly raise that 14 Execute copies reach 98%, 15 reach 105% and therefore full-health execution; preserve the owner's linear rule without imposing a new cap. Recommend lethal damage equal to actual remaining HP through the existing death route, not magic 9999 damage. Revised Impact probability awaits selection; health/stumble proofs and loot/power/endurance tuning remain open. No gameplay/version/install/test/Workshop changes or new patch approval. Inspected 15e1414, fetched origin, draft PR #1 only.


## C141 - module capacity as percentage balance (2026-10-11)

Owner asks how to tune percentages to avoid 100% at sixteen modules. [Revised proposal](checkpoints/R3_OFFENSIVE_MODULES.md#c141---slot-budget-percentage-proposal-2026-10-11): Impact retains 60% first-copy benefit and adds two percentage points per extra copy (90% at sixteen); Execute would change from the selected seven to three HP-threshold percentage points per copy (48% at sixteen). These replacement values are not approved; preserve C140 selections until chosen. Initial Blow +25% damage and Piercing remain selected and unchanged. Standard automation leaves fourteen effect slots, and Sandbox can exceed the standard sixteen-slot budget; no claim of an unlimited below-100% linear curve. No gameplay patch authorized. Installed 0.2.41/C138 test completion unchanged; planning-only GitHub mirror required.


## C142 - Execute first-copy threshold proposal (2026-10-11)

Owner proposes Execute at 10% HP for the first copy, +2 percentage points per additional copy. Recommended: more useful first-copy finishing and 40% at sixteen, compared with the prior proposed 48%. Impact remains proposed at 60% first/+2 points per extra (90% at sixteen). Numerical settlement/patch approval still pending; Initial Blow and Piercing unchanged. [Contract and arithmetic](checkpoints/R3_OFFENSIVE_MODULES.md#c142---execute-base-plus-increment-proposal-2026-10-11). Share Impact's stacking pattern only, not its first-shot restriction or probability semantics. Execute remains a deterministic kill on a successful eligible primary hit. No gameplay/version/test/install change; C119 planning mirror required.


## C143 - Execute and Impact percentage approval (2026-10-11)

Owner: "Approved", answering the explicit C142 numerical settlement question. Owner approves Execute at 10% HP for the first copy/+2 percentage points per additional copy, and Impact at 60% chance first/+2 points per additional copy. Sixteen copies yield a 40% Execute threshold or 90% Impact chance. Initial Blow and Piercing remain selected and unchanged. These percentage choices are settled; do not ask for their approval again. Remaining compatibility/loot/power details and native feasibility are still open; this approval answers the numerical choice, not an unoffered complete patch. [Approved contract](checkpoints/R3_OFFENSIVE_MODULES.md#c143---execute-and-impact-percentages-approved-2026-10-11). Installed 0.2.41/C138 unchanged; no new gameplay or test claim.


## C144 - approval to proceed and concrete remaining power choice (2026-10-11)

Owner: "Approved" after the C143 handoff. Owner approves proceeding after C143. R3C6 combat foundations are implemented in Source and pass 5,155 Kahlua assertions; native health/stagger method feasibility also passed in an isolated 42.21 probe. This is an unfinished development checkpoint, not an installed patch. A concrete power-cost question is pending: slots alone (recommended) versus +25% base firing power per new-module copy. Loot-only weight 2.5 alongside Splitter/Fragment was offered with that question. Item/loot/Sandbox/LootLab integration, complete native validation and packaging/install remain outstanding. [Scope and evidence](checkpoints/R3_OFFENSIVE_MODULES.md#c144---approved-implementation-progress-and-power-choice-2026-10-11). No gameplay values are inferred from the unanswered power question; installed 0.2.41/C138 unchanged.


## C145 - global module-count power direction and calculated proposal (2026-10-11)

Owner selects a global module-count power rule with per-type multipliers, initially equal, and requests a recommendation/calculated endurance. Proposed defaults: 0.005% battery charge per firing cycle; +5% of base cost per installed module; all type weights 1; no battery idle draw; generator base 0.0001 native fuel units/cycle with the same multiplier. These numbers await approval and replace the old C144 A/B question. C144 combat foundations remain committed/tested but uninstalled; no gameplay changes in this calculation turn. [Formula, counting scope, native fuel evidence and workload estimates](checkpoints/R3_OFFENSIVE_MODULES.md#c145---global-module-power-model-and-endurance-proposal-2026-10-11). Direction is confirmed; numerical defaults and counting exclusions are recommendations. Replace old Splitter/Fragment surcharges instead of doubling them; preserve saved custom settings explicitly. No new gameplay/test/install change.


## C146 - damage/range power scaling direction (2026-10-11)

Owner adds damage/range scaling to the global module-count power rule so stronger, longer-range weapons cost more per shot. Recommended weapon factor: max(1, sqrt((D/80) * (R/15))), using ordinary pre-module head damage and capped pre-module maximum range. Retain proposed 0.005% battery base, +5% per weighted module, equal initial weights and zero idle; numerical defaults remain proposed. At sixteen modules, vanilla M9 costs 0.009% per volley and MSR788 0.020785% (about 11,111 versus 4,811 volleys/full battery). C144 combat foundations are committed/tested but uninstalled; full integration and packaging remain outstanding. Installed 0.2.41/C138 unchanged. [Formula, scope, native stats and endurance](checkpoints/R3_OFFENSIVE_MODULES.md#c146---weapon-damage-and-range-power-proposal-2026-10-11). Owner confirms damage/range-dependent battery cost; the square-root shape, 1x floor, pre-module inputs, reference constants and generator extension are recommendations awaiting settlement. Higher cost per shot does not guarantee higher cost per kill. No new gameplay/version/test/install change.


## C147 - power defaults approved; complete the module patch (2026-10-11)

Owner: "Approved" in response to C146. Approves the complete battery formula, 1x weapon floor, pre-module damage/range inputs, equal per-type weights/counting exclusions, 5 percent per working module, 0.005 percent battery base, zero idle, and 0.0001 generator base with the same multipliers. No repeat numerical approval required. Continue C144-authorized integration, validation, installation and C108/C119 mirror. See [0.2.42 patch](PATCH_v0.2.42.md) and the versioned test record for implementation and evidence.

C147 completion: 0.2.42 is installed and verified from immutable test/v0.2.42 / 2354a7ff3ed4ef174a0bbeb4d7d0051a620bc5d7. R3C6 implementation is complete; R3C7 owner verification is pending. [Release](RELEASE.md) and [test](TEST_v0.2.42.md) preserve actual evidence and limits. Hosted LootLab matches the new catalog.


## C148 - optimization investigation during the 0.2.42 owner test (2026-10-11)

Owner requests an optimization investigation and inventory of per-tick work while testing. Read-only gameplay audit authorized; no new optimization patch approval inferred. [Audit and proposed sequence](PERFORMANCE_AUDIT_v0.2.42.md) records nine OnTick registrations, two pause-aware, three zombie, two player and five render callbacks (21 unique with both packages), eight workers inside the existing scheduler, and 15 demand-driven UI/action method declarations. Recommend reducing barrier reconciliation, repeated barbed object discovery and duplicate turret stat resolution before broader rendering/queue cleanup or target-index redesign. Keep actor-update movement/landing/strike timing, pause semantics, independent packages and fresh shot validation. No measured speedup or current-lag attribution; the available console snapshot is startup-only. R1C3 investigation continues alongside pending R3C7; installed 0.2.42 and its owner test are unchanged. C108/C119 requires this planning evidence to be mirrored to GitHub.


## C149 - retain optimization scope; match fast bounded ammo transfers (2026-10-11)

Owner: keep C148 for the next update; transferring roughly 600 rounds into turret inventory freezes while Manage transfers individually. Requests fast, matching rates through both interfaces. Next-update direction confirmed; no immediate patch/install during testing. [Investigation and implementation contract](PERFORMANCE_AUDIT_v0.2.42.md#c149-bulk-ammo-transfer-follow-up-2026-10-11) prioritizes ammo transfer before the five retained optimization offers. Native light-item groups cap at 20, but queue merging and repeated OMH full-container validation are not time-budgeted. Manage disables merging explicitly; pending-item accounting must be adapted when unifying paths. Preserve native item/weight/reach/interruption rules, live ammo consumption, no duplication, and bounded work. Console confirms 0.2.42 and 343/542/563 ms gaps in transfer windows; correlation is not isolated causal profiling. [Versioned finding](TEST_v0.2.42.md#c149-owner-finding-bulk-ammo-transfer-freeze-2026-10-11). No gameplay files or acceptance result changed; R3C7 remains open with this finding.


## C150 - ammo-saving module, battery clarity and compact Manage discussion (2026-10-11)

Owner requests two shots per consumed round with increasing module stacks, naming alternatives, clearer battery costs/endurance and narrower Manage cells with battery/expansion in the two unused first-row cells. After a structured question, owner explicitly requests 1A/1B/1C reply options instead and says discussion is still needed. No option was selected; no patch approval inferred. [Contract and exact options](checkpoints/R3_AMMO_SAVER_MANAGE.md) recommends Ammo Saver, existing ammo-cost discount (including Splitter), adaptive display-only rounding plus battery-tooltip remaining volleys, and battery/expansion in the two gaps (1A/2A/3A/4A). Linear uses-per-round=count+1, normal per-volley power and anti-reset persistence are proposed rules, not silently settled. Rounding UI leaves consumption unchanged; game days are a workload-dependent estimate, not a remaining-life guarantee. C149 transfer fix remains first priority and C148 optimizations stay queued. Persisted the requested discussion format in AGENTS. Installed 0.2.42/R3C7 acceptance unchanged; decision needed in conversational options, not another question form.


## C151 - Conservation Module and Manage selections (2026-10-11)

Owner selects 1D Conservation Module, 2A existing-ammo-cost discount (including Splitter), asks to combine 3A+3B battery information, and selects 4C because battery/expansion beside the modules would be confusing. [Updated contract](checkpoints/R3_AMMO_SAVER_MANAGE.md#c151---selected-name-splitter-accounting-hybrid-battery-tooltip-and-separate-utilities-2026-10-11) records the combined tooltip: rounded cost, remaining volleys, labeled real-time continuous-firing estimate and zero idle drain; charge remains visible. Display rounding changes no actual consumption. Battery/expansion stay above; narrow the window/cells and retain 4/6/6 with empty end gaps. Do not revive 4A or alternate module names as unresolved choices. This is design discussion/selection, not an immediate patch/install request. C149 transfer fix stays first; C148 retained; installed 0.2.42/R3C7 acceptance unchanged.


## C152 - module benefit list requested (2026-10-11)

Owner requests each module and its current benefit in the blue-marked lower-right Manage details area. [Presentation contract](checkpoints/R3_AMMO_SAVER_MANAGE.md#c152---installed-module-benefit-list-in-manage-2026-10-11) recommends grouped duplicate counts, effective combined effects from actual settings/head, visible inactive/broken/capped reasons and a fixed-height scrollable list. Preserve C151 utilities above the modules, narrower window and 4/6/6; constrain left-side text to avoid overlap. Reuse existing 200 ms refresh/cached rows, no new tick handler. This adds requested next-update UI scope, not an installed fix or test pass. C149 correction remains first and C148 optimizations stay retained.


## C153 - short module effects, individual-row hover explanations (2026-10-11)

Owner directs concise Installed Modules rows such as `<14% HP` / `+2 Shots`, with explanations on module descriptions and hovering each individual list row. [Updated contract](checkpoints/R3_AMMO_SAVER_MANAGE.md#c153---compact-installed-modules-labels-and-row-tooltips-2026-10-11) replaces C152 descriptive sentences with name/count/compact effect; conditions go to each row's tooltip. Use inclusive `≤14% HP` to match actual Execute logic, not a gameplay change. Retain brief inactive/capped/broken flags, current values, grouped counts, scrolling and existing UI refresh. Next-patch design correction only; installed 0.2.42 and owner-test state unchanged.


## C154 - combined implementation approved (2026-10-11)

Owner: "Approved. Go ahead and patch all of this, including the ammo transfer fix and optimizations." This authorizes C148-C153 as the combined 0.2.43 patch: fast bounded transfers through both interfaces; the five recorded maintenance/cache/stat/render/queue optimizations; Conservation Module; narrower Manage; battery endurance tooltip; compact Installed Modules list with individual row details. Native verification, local install and the standing C108 development mirror follow. Owner acceptance remains pending; no Workshop publication or merge. Conservation is loot-only with the existing offensive-module weight (2.5), normal module weight (0.3), and ordinary power load (1); no recipe.


## C155 - Manage presentation, target cycling and Synergy discussion (2026-10-11)

Owner requests segmented/dimmed UI regions, left-name/right-effect Installed Modules rows, automatic Horde Night rarity colors, remaining bars, reload-aware concise battery text without tick calculations, Once each Filter priority and a possible rare Synergy module. Explicit request: "Let's discuss. Show image examples and options." [Full contract/options](checkpoints/R3_MANAGE_RARITY_SYNERGY.md) recommends 1A inset panels, 2A log-spaced positive catalog weights, 3A one fired shot per round member, 4A cached reload-aware per-shot estimates, and 5A one extra nonrecursive Fragment burst per Synergy per shot. These defaults and Synergy tuning remain proposals. Source/package/install unchanged. No completed owner test or acceptance inferred; console findings recorded against 0.2.43.


## C156 - selected Manage design, full rarity spectrum and single-copy Synergy (2026-10-11)

Owner selects 1B, 2A with the missing ultra-easy/ultra-hard colors, 3A, 4A, and custom 5D: "It will be only 1 instance allowed, but it's 100% chance." Record one installed Synergy per turret and guaranteed activation on eligible hits; this supersedes stackable burst allowances and chance-based Synergy. Horde Night endpoint constants are verified as #82AEFF and #420D82, yielding seven rarity stops. [Selected contract](checkpoints/R3_MANAGE_RARITY_SYNERGY.md#c156---selected-options-and-full-palette-2026-10-11) retains no-recursion recommendations and explicitly asks 6A Fragment-only versus 6B broader offensive interaction scope. No repeat of settled choices; no gameplay changes/install or inferred test acceptance.


## C157 - Martyrdom, Tack and broader Synergy selected (2026-10-11)

Owner selects 6B. Martyrdom Module: zombies pop on death with nearby damage; stacks increase AoE distance; loot weight 1.5. Tack Module: first shot on a new target drops tacks with barbed-wire-style slowdown/DoT; stacks increase AoE distance; loot weight 1.5. Owner explicitly includes Splitter and Fragment as Synergy trigger sources, and sets Synergy loot weight 1.0. Preserve one installed Synergy and 100-percent eligible activation. [Updated contract and proposed tuning](checkpoints/R3_MANAGE_RARITY_SYNERGY.md#c157---broader-synergy-martyrdom-and-tack-2026-10-11) distinguishes selected content from proposed death attribution, damage, radius curve, Tack lifetime and terminal-effect rules. Prior fragment-only scope and weight 1.5 for Synergy are superseded. No gameplay implementation or test acceptance inferred.


## C158 - module tuning selected; minor player injury discussion (2026-10-11)

Owner selects 1A, 2A with 20-radius noise, 3A with retrigger after the ten-second lifetime, 4B, and 5B. This confirms terminal death/Tack effects, Martyrdom on eligible turret kills, ten-second Tack fields that rearm the same zombie after expiry, linear +.25 radius stacking, and player interaction. Owner asks for explosion damage status options, suggesting a minor bruise. [Current contract](checkpoints/R3_MANAGE_RARITY_SYNERGY.md#c158---selected-module-tuning-and-player-injury-options-2026-10-11) proposes 6A minor blunt damage/pain, 6B native scratch, 6C soreness only, plus 7A one-second player injury protection versus 7B every burst. No dedicated native Bruise flag/status found in installed BodyPart/UI evidence; native runtime verification still required. No gameplay patch or implied 0.2.43 test pass.


## C159 - injury choices finalized; optimized implementation readiness (2026-10-11)

Owner selects 6A and 7A, emphasizes optimization because Synergy can get dicey, and asks "Are we ready to implement? Recap." This settles minor blunt injury (proposed 2 limb body-part damage plus 5 pain) and one active-second player-only burst protection. [Final contract](checkpoints/R3_MANAGE_RARITY_SYNERGY.md#c159---design-ready-for-implementation-2026-10-11) consolidates C155-C158 and requires incremental bounded effect jobs, admission/back-pressure, local Tack indexing, per-shot snapshots, terminal DoT/death damage, cached UI and measured multi-turret stress/native persistence tests. No owner-design question remains; technical proof remains implementation work. Readiness/recap only this turn; no gameplay patch, installation or inferred 0.2.43 test pass.

## C160 — 0.2.44 implementation approved (2026-10-11)

Owner says “Approved.” after C159 readiness/recap. Implement the complete Manage, rarity, Once each, Synergy/Martyrdom/Tack bundle and its bounded processing contract. Local verification, package independence, LootLab and C108 mirror remain required. No owner gameplay acceptance or publication is implied.


## C161 - owner findings, delayed effects and rarity-power discussion (2026-10-12)

Owner requests simpler percent/in-game-time battery text, slider/status polish, investigation of distant accuracy, .75-second Martyrdom and .5-second Tack delays with auditioned native sounds, 67-percent packed turret weight compression, range-end Fragment with .25-second delay and existing suppressed pistol audio, Piercing on all guns including shotguns, and a four-field Feature/Stackable/Battery Drain/Rarity tooltip format. Rarity and drain should be linked over 1.1x-3.0x. Owner invites choices where something is off; sound selection is explicitly requested through the existing HTML audition workflow. The layout picker selects Inset panels. [C161 contract](checkpoints/R3_EFFECT_POLISH.md) records exact requests, confirmed errors, recommended interpretations and numbered alternatives. Current 5-percent additive module surcharge is not retroactively a rarity multiplier. Fragment endpoint, power interpretation and far-range balance require discussion; no gameplay implementation is claimed this turn.

Console review confirms 1,355 Tack marker null-module exceptions in the captured 0.2.44 SP slice. The first failing startup is absent. Current native Lua search-path evidence supports early client-to-server require as the cause; ordered startup proof belongs in correction. Earlier automated evidence is retained with this explicit coverage failure; owner acceptance remains open. Local audio picker renders six native candidates plus the existing suppressed M9 reference. C108/C119 requires mirroring these findings and plans now.


## C162 - additive power clarification; accuracy, Fragment and Tack selections (2026-10-12)

Owner says "1C ... start at 1.0, and each module adds between 0.1x - 2.0x", selects 2A/3B/5B, and requests more Martyrdom sounds because the initial choices are too extreme. [Updated contract](checkpoints/R3_EFFECT_POLISH.md#c162---selected-rules-and-expanded-martyrdom-audition-2026-10-12) records the additive formula and its equivalence to previous 1B: sixteen cheapest/highest-cost copies give 2.6x/33x, before the retained weapon factor. Suggested interior rarity increments are recommendations. Shotgun shared aim roll/current far defaults, terminal-stop Fragment and MetalworkingPunchDrop Tack audio are selected. Five new native previews (4D-4H) replace the rejected Martyrdom set. Sound choice remains open; no gameplay install/test acceptance or publication is implied.


## C163 - Martyrdom sound selection and early playback (2026-10-12)

Owner says "4G, but play it slightly before they pop so the impact is timed correctly. The file has some attack to it." Select native AttackStomp and begin its audio before the .75-second death-to-pop deadline. [Current contract](checkpoints/R3_EFFECT_POLISH.md#c163---martyrdom-stomp-selection-and-audio-lead-2026-10-12) proposes a .20-second lead based on the existing capture's .182-second peak / .209-second RMS attack relative to audible onset. This offset is initial calibration, not an owner-specified exact value or verified rendered synchronization. Damage/pop/AI noise remain at .75 seconds; no new gameplay implementation, install or test pass is claimed. C162 choices remain, and no sound selection remains open. Commit/mirror these planning changes under C108/C119.


## C164 - immediate LootLab colors, shapes and sticky controls (2026-10-12)

Owner requests new-module colors, proposes per-type shapes, then requests sticky Show/Hide All and says "Fix that this turn, and recap the next patch." This authorizes the small hosted UI update. Implemented 28 stable ID-keyed colors with future fallback, five family shapes across map/list and sticky visibility controls below the responsive sync banner. No loot/model/account/gameplay tuning changes. [Implementation and evidence](checkpoints/R3_EFFECT_POLISH.md#c164---lootlab-appearance-and-scrolling-correction-2026-10-12). C161-C163 gameplay patch remains pending separately. No new final art, mod install or Workshop publication.


## C165 - approved correction patch and packed-pickup clarification (2026-10-12)

Owner says "Approved" after the C164 recap, authorizing implementation of C161-C163. The seven interior rarity surcharges follow the proposed .1/.2/.4/.7/1/1.5/2 table as implementation tuning. [0.2.45 patch](PATCH_v0.2.45.md) implements the effects, startup, accuracy/Piercing, descriptions, additive power and UI changes. Automated verification is separate from owner acceptance; C108/C119 mirror remains required.

During native weight verification the bag flag proved equipped-only. The owner clarified that reduction means after pickup, then confirmed automatic packing when clicking Pick Up, the normal contents summary, and unpacking through the existing placement action. This approves that flow, not a Java dependency or lossy item reconstruction. The ordinary-Lua native snapshot restore route failed because ByteBuffer is not exposed, and reflection is debug-only. Packed-weight implementation is withheld pending reliable exact-item preservation; the rest of the correction patch proceeds independently. Earlier assistant wording that packing would simply restore everything preceded this proof and is corrected here. The requested weight reduction remains approved and unfinished, not silently replaced by equipped-only reduction.


## C166 - Endurance, safe packing, efficiency and rarity choices (2026-10-12)

Owner reports battery drain works but the late-game turret lasts about 1.5 in-game minutes. Latest saved Battery use is 0.1, twenty times the shipped .005 default; log confirms 4.07965% per shot. Console also confirms repeated inventory rarity-tooltip errors at TurretMenu.lua:24. Battery acceptance is partial; the rest of the patch is not cleared. [Evidence and numbered options](checkpoints/R3_POWER_PACKING_OPTIONS.md) cover safe pickup alternatives, six-hour endurance tuning, Power Efficiency and seven rarity names. These are discussion proposals, not new gameplay approval. Packing remains unfinished. **Decision needed** on the four choice groups; no repeat test requested while discussing the corrective patch.

## C167 - Selected packing, module weight, Regulator and rarity (2026-10-12)

Owner selects 1C (full automatic packing), adds module item weight .3 -> .2, selects 3B named **Regulator Module**, and 4A **Abundant / Common / Uncommon / Rare / Epic / Legendary / Mythic**. Packing remains a native feasibility task; this does not authorize an added Java dependency or lossy restoration. The revised power proposal is base **.0008%** with **+.1x to +1x per module**, explicitly submitted for evaluation. [Updated contract and calculations](checkpoints/R3_POWER_PACKING_OPTIONS.md#c167---selected-directions-and-revised-power-evaluation-2026-10-12). With the tested weapon/day/cadence, sixteen highest-cost modules give only 3.54 hours before reloads, so the prior six-hour target needs qualification or lower base drain. **Decision needed:** retain .0008 for stronger power tradeoffs, or use .00045 for about 6.3 hours on that high-cost reference build. No gameplay patch or saved-setting change this discussion; existing tooltip defect remains queued.

## C168 - Approved endurance, Regulator, weight and rarity update (2026-10-12)

Owner: "2B Approved to update." This selects .00045% base battery cost and the .1-1.0 additive rarity range from C167. Interior increments .1/.15/.25/.4/.6/.8/1.0 follow the presented recommendation. Approves implementation of Regulator (+25% endurance/copy), module weight .2, selected names, tooltip correction and safe packing investigation. [0.2.46](PATCH_v0.2.46.md) implements all except full packing, which remains blocked by unproven native exact-item restore. No dependency or lossy workaround is approved. Regulator uses Rare default weight 5.5, utility loot pools, battery-only benefit and zero own surcharge as the discussed supporting defaults. The identified closed test save's Battery use may be corrected from .1 to .00045 with a backup; unrelated settings and other worlds remain unchanged. No universal six-hour guarantee is claimed. LootLab catalog/migration is deployed and verified; no Workshop upload.

## C169 - Packed turret blocker and simple alternatives (2026-10-12)

Owner asks what still blocks packed weight reduction and for the simplest safe options. Rechecked installed 42.21 InventoryContainer weight methods and InventoryItem.isFakeEquipped, plus the recorded ordinary-Lua buffer failure. The native special case is key-ring-specific, not a general equip flag. [Options and recommendation](checkpoints/R3_POWER_PACKING_OPTIONS.md#c169---simplest-safe-packing-alternatives-2026-10-12): 1A native equipped carry case recommended for simplicity if a slot is acceptable; 1B lighter base only; 1C retain exact automatic ordinary-inventory packing and investigate a concrete native bridge before dependency approval. No alternative selected, no gameplay implementation, no new test requested. Original full packing remains approved but technically unfinished; do not imply the failed route proves all native approaches impossible. C108/C119 planning mirror applies.

## C170 - Abandon packed-weight reduction; focused test (2026-10-12)

Owner: "I guess we'll just have to abandon the idea. What's my short test?" Cancels the packed-turret weight-reduction feature and its feasibility work. Keep existing exact-item pickup/placement at full contents weight; do not substitute C169 alternatives. Module weight .2 and all other installed 0.2.46 changes remain. Current planning/roadmap are updated; historical failures remain recorded. Provide the complete short five-step 0.2.46 test, then inspect console.txt after the owner reports completion. No test acceptance, new patch, gameplay edit or version bump is implied. C108/C119 documentation mirror applies.


## C171 - Direct LootLab weights and ongoing 0.2.46 findings (2026-10-12)

Owner requests direct component weights in LootLab and annotates the battery estimate remaining in minutes. Implemented/deployed direct-weight controls with unchanged saved tuning/schema and compatible Sandbox export; 77 API/page tests plus model/browser checks pass. [Contract/evidence](LOOTLAB_DIRECT_WEIGHTS.md). Confirmed minutes-only formatting and console tooltip/capacity issues are recorded for the next game correction, not silently patched or accepted. No game balance/code/version change, no database tuning write, no new gameplay acceptance. C170 packing cancellation remains. C108/C119 mirror applies.


## C172 - Sticky LootLab map and bottom statistics (2026-10-12)

Owner requests that the map follow while scrolling and statistics move to the page bottom. Implements/deploys a bounded CSS-sticky desktop/tablet map with toolbar and full-width bottom statistics, including summary metrics and tables. Narrow phones retain normal map flow to avoid covering controls. [Behavior and evidence](LOOTLAB_SCROLLING_MAP.md). Browser layout/weight suites and all 77 API/page checks pass. No saved tuning, game code/version, database or pending C171 game-fix status changes. C108/C119 development mirror applies.


## C173 - Module pack, rolling reveal and supplied loot weights (2026-10-12)

Owner requests a new card-pack-like item using all module weights, an optional default-on CS2-style roll with Manage module icons/text/rarity-colored foreground and background, combined with battery hours/minutes formatting. Requests using the attached LootLab tuning and confirmation before one more support requirement. Validated all 29 exported entries; recorded exact original JSON/hash and effective weights, including Regulator 6, Firing/Detection 15 and Martyrdom/Tack 2. [Plan](checkpoints/R3_MODULE_PACK.md). This turn records the approved direction; no implementation until remaining support and pack details are discussed. Normalize relative pack selection rather than equating it with independent container loot rolls; committed-outcome visual reveal and migration avoiding double-applied weights are recommendations to verify. C171 defects stay queued. C108/C119 planning mirror applies.


## C174 - Project Viewpoint feasibility inquiry (2026-10-12)

Owner asks whether first-person mod support is realistic before moving it to another chat. Read-only inspection finds installed Viewpoint 0.1.6 for PZ 42.21, mouse world-coordinate helpers and native context-menu harvesting; OMHTT retains isometric selection/overlay assumptions and an unproven native 3D render hook under Viewpoint. [Evidence and proposal](checkpoints/VIEWPOINT_COMPATIBILITY.md). Recommend a separate optional adapter prototype for one turret and trap, preserving dependency-free core packages. Full rendering/performance support remains unverified; no implementation, dependency change or chat creation authorized. C173 pack/weights/battery planning stays separate and its remaining choices are unresolved. C108/C119 mirror applies.


## C175 - Module-pack/hour patch approval and weights reaffirmed (2026-10-12)

Owner approves the hour patch and module pack, explicitly adds the new weights, and then invites questions/options first. Scope approved: adaptive battery hours/minutes, weighted pack/reveal, all 29 supplied effective weights. [Remaining material choices and proposed defaults](checkpoints/R3_MODULE_PACK.md#c175-approval-and-remaining-choices): reward count, additional versus replacement loot, expansion-kit eligibility. These choices are not settled by feature approval. No gameplay/package change this turn; Viewpoint stays separate and C171 findings remain pending. C108/C119 planning mirror applies.


## C176 - Three-reward packs, supplemental loot and zombie bodies (2026-10-12)

Owner selects 1B/2A/3A: three independent draws with duplicates, packs alongside loose modules at container weight 1.0, and all 29 exported entries including expansion kits. Adds more-frequent pack finds on zombie bodies. [Contract and final rate choice](checkpoints/R3_MODULE_PACK.md#c176-selected-pack-rules-and-zombie-body-loot). Recommend separately configurable 1% per eligible body, with 0.5%/2% alternatives; numerical rate not yet approved. Container weights and corpse probabilities are distinct. Existing hour/weight/pack approval persists; do not require generic reapproval after the rate choice. No gameplay patch or test claim this turn.


## C177 - Fifteen-percent corpse packs and 0.2.47 implementation (2026-10-12)

Owner: "should be way more common, like 15%". Select 15% independent once-per-body pack chance, including turret kills, separate from container weight 1.0. Existing approval covers three rewards, duplicates, all 29 entries, optional reveal, supplied weights and battery hour/minute fix. Implemented with native inventory transactions and event timing evidence; [final contract](checkpoints/R3_MODULE_PACK.md#c177-15-percent-body-rate-and-implementation), [patch](PATCH_v0.2.47.md), [test](TEST_v0.2.47.md). C171 inventory tooltip correction is included; capacity warnings remain open. Saved tuning preserved; rarity/power follow loaded weights. LootLab deployed with loose-module-only estimate note. No further design gate, Workshop upload, Viewpoint implementation or packed-turret weight reduction.


## C178 - Review of 0.2.47 performance and new features (2026-10-12)

Owner requests a double-check of optimizations/performance and concerns. [Audit](AUDIT_v0.2.47.md) records confirmed tooltip allocation, small-viewport reveal overflow and empty-reward-pool acquisition issues; recommends a small corrective patch with unchanged balance. Review/test/documentation only; no gameplay patch approval inferred. Source/Contents and installed test/v0.2.47 unchanged. 16,084 combined assertions pass; current console is still 0.2.46. C108/C119 mirror applies.


## C179 - Record audit concerns and reaffirm Alex guidelines (2026-10-12)

Owner: "Note this down and confirm Alex’s guidelines are being followed, including no Pcalls". Record the C178 corrections without inferring gameplay patch approval. Direct scans confirm zero pcall/xpcall tokens in owned source, packages and installed copies; retain validator enforcement and add a concise per-turn reminder. Full compliance is qualified: tooltip wrapping/caching and new-pack inline-conditional style gaps remain. [Evidence and pending scope](AUDIT_v0.2.47.md#c179---alex-guideline-confirmation-and-queued-work). No package/version/install/balance change; C108/C119 mirror applies.


## C180 - Implement the remarked audit corrections (2026-10-12)

Owner: "Go ahead and solve the remarked issues". Explicitly authorizes the focused C178/C179 corrective patch, validation, installation and standing GitHub development mirror. Implemented as 0.2.47.1: cached tooltip wrapping; viewport-bound reveal with wheel/arrow scrolling and fixed Skip/Close; native script display metadata instead of temporary items; cached weighted pool/loaded eligibility; suppress empty-pool acquisition; clean new pack non-guard inline conditionals. Preserve pack rates, draws, weights, transaction safety and SP-only scope. [Patch](PATCH_v0.2.47.1.md), [test/evidence](TEST_v0.2.47.1.md). C171 capacity warning investigation is separate and remains open; no unsupported claim of resolution. No Workshop upload or hosted-tool change.


## C181 - Capacity diagnosis, pack presentation and LootLab tiers (2026-10-12)

Owner asks to investigate warnings, clean the reveal to match Manage, replace bottom controls with one green Collect button, check the rarity spread, provide sound-choice HTML and create a tier-assignment section in LootLab. Implement the directly requested UI/tier workflow and the confirmed capacity correction as 0.2.47.2. No additional gameplay balancing or sound selections inferred. Collect closes the already-secured rewards, including during rolling, without another grant. All 29 supplied defaults use seven bands; the current saved all-one values use six. Tier drafting never resets saved values automatically. Sound/particle candidates are reviewable in art/PACK_AUDIO.html; await choices before runtime playback. [Contract and findings](PACK_POLISH.md). C108/C119 development mirror applies; no Workshop upload.

## C182 - Pack cues, four-second fade and tier reopening (2026-10-12)

Owner selected 1B with native pitch variation, 2B, 3C, and 4B with a four-second fade; requested immediate tier color/rarity refresh and reopening assignments for equal weights. Implement native object-rotation/pickup cues and pulse only; owner-created rarity files are not supplied. Additional randomized pitch remains an explicit engine limitation, not a completed requirement: current EventSound does not apply clip pitch and FMODSoundEmitter.setPitch writes all sounds. Keep native events unchanged rather than affect other UI audio. See PACK_POLISH.md and TEST_v0.2.47.3.md. Tier assignments are derived without retuning weights; same-page confirmed tier values are retained. Colors remain actual game formula results; component map identity colors stay separate. No account schema/default changes or particles.

## C183 - Persistent LootLab tier weights (2026-10-12)

Owner corrects the C182 session-only limitation: tier weights must remain saved after refreshing or reopening LootLab. Implement account-backed persistence using the existing versioned settings JSON, with browser storage in the local copy. Save only on Confirm; maintain Cancel, exact module weights, automatic matching groups, per-field conflict merging and offline recovery. Old clients must not delete new tier metadata. No new database table/migration, gameplay version, local install or Workshop publication. Deployed and verified; details in LOOTLAB_TIER_PERSISTENCE.md.

## C184 - Diagnose inconsistent tier and card rarities (2026-10-12)

Owner reports yellow cards in orange rows and green cards in yellow rows. Confirmed cause is separate manual tier labels and the unchanged logarithmic runtime classifier, not demonstrated stale saved weights. Record this as unresolved semantic acceptance. Recommend shared saved tier-weight rarity anchors in LootLab and the mod (1A); alternatively derive fixed tier weights from the existing classifier (1B). The first changes rarity-based power costs; the second restricts custom tier weights. No new gameplay/site change approved by this question. See LOOTLAB_TIER_PERSISTENCE.md#c184-rarity-row-conflict-2026-10-12.

## C185 - Approved shared rarity anchors (2026-10-12)

Owner: "1A". Approves C184 option 1A: saved tier weights define rarity across LootLab and the mod, including existing rarity battery surcharges. Implement in 0.2.47.4 with geometric midpoint boundaries (ties rarer), positive strictly descending anchors, Sandbox export, automatic compatibility and explicit invalid-setting handling. No new loot/default weights or account data writes authorized. [Contract](LOOTLAB_TIER_PERSISTENCE.md#c185-shared-rarity-anchors-2026-10-12). Inspected active branch 3f8e32d and fetched origin; no incoming planning change. Automated verification, deployment/install and owner acceptance remain separate.

## C186 - Owner rarity audio received and next-update recap (2026-10-12)

Owner supplied seven named rarity WAVs in Audio/Turrets & Traps and requested a recap. Record files received for the already selected C182 custom-audio option; next work is Module Pack rarity reveal audio. Highest-rarity-only playback remains the recommended integration to avoid layered fanfares, using C185 cached classification. Inventory/format inspection only this turn; no gameplay/version/install changes or audible acceptance. Existing inset-panel layout selection is consistent with installed UI, not new scope. [Contract](PACK_POLISH.md#c186-owner-rarity-sounds-received-2026-10-12).

## C187 - Requested current LootLab weight check (2026-10-12)

Owner expects a couple Mythic items and requests confirmation of the next patch. Saved weights cannot yet be verified: available browser is signed out and auto-review rejected the read-only database access path pending explicit account authorization. Requested permission or an export. Do not claim Mythic assignments from old defaults. C186 custom rarity audio remains next; no implementation/version/install changes this turn. [Details](PACK_POLISH.md#c187-current-weights-check-2026-10-12).

## C188 - Authorized read and verified current LootLab weights (2026-10-12)

Owner: "Approve read-only check" for the explicit C187 account/database query. SELECT succeeded with one row read and zero writes, revision196 at 2026-10-12 22:26:27 UTC. Four Mythics at weight1: Autoloader, Enhanced Firing, Enhanced Detection, Synergy. All seven anchors20/18/14/10/6/3/1 are valid and populated. Record the exact snapshot for the next sound/weight patch plan; no gameplay/default/site mutation performed. Do not imply that read approval installed the values or authorizes unrelated global loot changes. [Contract](PACK_POLISH.md#c188-verified-saved-weights-2026-10-12).

## C189 - Approved custom audio and saved loot defaults (2026-10-12)

Owner: "Approved." This approves the C188 combined patch: the verified saved weights/anchors and C186 seven custom rarity sounds with one highest-rarity cue. Rechecked revision 196 unchanged immediately before implementation. Source branch codex/performance-barbed-audit at f58d354 was reconciled with fetched origin. No additional owner decision is required.

Implemented in 0.2.48. New-world Sandbox defaults, LootDefinitions fallback and LootLab reset/default baseline use all 29 exact C188 weights and anchors; original item base weights remain intact. The global module multiplier is 1.011111111111111. Unrelated material rates, pack corpse chance, recipes and existing saved Sandbox values are unchanged. Old account scenarios migrate baseline identifiers without silently adopting defaults; legacy missing tier metadata retains automatic classification. Current 0.2.47 browser clients can save their complete existing settings without losing values; malformed/missing component fields are rejected. No account row or schema was written by deployment.

All seven original PCM WAV files are copied byte-for-byte, preserving original level differences. Native UI sound scripts use one non-looping non-spatial clip per tier. Highest actual reward rarity is cached at panel creation; at the existing four-second settle, the pickup selection cue and one rarity cue play. Both owned handles stop on Collect or replacement. Early Collect skips unfinished reveal audio and preserves already granted rewards. Disabling the rolling UI retains its existing halo behavior. No new tick handler, per-frame item allocation, global pitch mutation, particles or zombie-hearing event. Native tick pitch variation remains unresolved as documented under C182.

Rarity-linked battery surcharges follow the new anchors: .1/.15/.25/.4/.6/.8/1; Regulator retains its battery-only reduction without a surcharge, and separate expansion kits remain exempt. This is a consequence of approved rarity tuning, not a new drain formula. Existing worlds require explicit Sandbox import to adopt the new weights and anchors.

Performance and validation: 16,166 assertions; 117 Lua/translation files compile; native parser/FMOD UI handles play/stop all seven sounds in a muted probe. Pack tests cover every highest-tier choice, exactly one reveal cue, early Collect, replacement and long-frame no-burst behavior. The 300-frame probe creates no items or text wraps. Changed shipped Lua retains Alex's annotations/guard-only style and introduces no pcall/xpcall. Native persistence/package results and owner acceptance are recorded in TEST_v0.2.48.md, not inferred from mocks.

Balance observation: LootLab's full-retention default model estimates 70.0% one/two-component and 15.1% five-plus-component hauls among successful containers. This exceeds the previous test fixture's under-10% assumption because the owner changed weights. Preserve the explicit approved tuning; report measured estimates without treating them as guaranteed in-game loot or global vanilla spawn changes. The saved scenario's .7 retention is simulator-only.

## C190 - Staggered, longer and faster-opening pack reels (2026-10-12)

Owner explicitly requests offsetting each roll, bottom last, extending roll time and increasing initial speed. Implemented in 0.2.48.1 as a presentation-only correction: each row starts 350 ms after the previous one and rolls for six seconds. Relative to panel opening, starts are 0/0.35/0.70 seconds and stops are 6/6.35/6.70 seconds. Travel increases from 13 to 39 card widths with the same cubic ease-out, yielding twice the initial velocity while allowing a longer slowdown. Each row expands onto its already granted winner and begins its four-second pulse independently.

One shared rotation-tick stream remains limited to at most one sound per 100 ms. Selection and the one cached highest-rarity cue wait until the bottom reel finishes. Collect/replacement still stops both owned handles; early Collect keeps all three already granted rewards. Long frames skip missed ticks rather than replaying them. The rolling toggle, loot weights, reward selection, three independent draws, sounds themselves and gameplay remain unchanged. With C189 defaults, Mythic odds remain 1-(269/273)^3 = 4.3315% per pack.

The three reel tables cache position/crossing/settlement scalars. Their 42 card entries reuse the existing per-type card metadata; only visible card indices are iterated during drawing. No per-frame items/text wrapping/tables, new event handler, protected call, global sound modification or new asset. Changed Lua follows Alex's annotations, four-space and guard-only inline rules. The existing getTimestampMs/ISPanel/sound API paths were validated in C189; no new native API is introduced.

Verified with 16,180 assertions and 117 Lua/translation compilations. Focused coverage includes staggered starts/stops, initial speed comparison, exact winner, per-row pulse, final-only cue, early collection, replacement and a 20-second frame jump without backlog. A 500-frame render probe creates no items or text wraps; small-viewport controls remain in bounds. Initial test failures were stale 16-card/four-second expectations, updated to the requested behavior. Native package/save/restart results and installation are in TEST_v0.2.48.1.md. Rendered pacing remains owner acceptance, not inferred from mocks.

Inspected branch codex/performance-barbed-audit at 8b089b7, fetched origin and checked the sole open draft PR #1 before edits. This stays within R3C7 pack polish; no new phase or broader combat retest. LootLab remains on its verified C189 deployment and unchanged 0.2.48 loot baseline.

## C191 - Owner accepts reels; two timing refinements queued (2026-10-12)

Owner: "Works well! Let's do 0.15s apart and adjust the rarity sound to be .25s earlier. It has some lead in. We'll add this to the next patch. What's next on our checkpoints?" Accept the reported 0.2.48.1 reel behavior; record these exact refinements as approved for the next patch, not authorization to install another patch during this discussion.

Queued: change row spacing from 350 to 150 ms, retaining six seconds per reel and the current twice-faster opening. Start times become 0/.15/.30 seconds and stop times 6/6.15/6.30 seconds. Play the existing one highest-rarity sound 250 ms before the bottom reel's scheduled stop, at 6.05 seconds after opening, to align its authored lead-in. Keep the selection cue at final settlement, independent four-second row pulses, one bounded tick stream and Collect/replacement cleanup. A skipped threshold must trigger at most one cue; no catch-up burst. Reward rolls, weights, Mythic odds and audio files remain unchanged. Implementation is pending.

Console capture 20261012-195320-4179 confirms 0.2.48.1 and ten completed pack actions. No ERROR/Exception/stack trace occurs from the first pack opening through capture; recorded active-update gaps in that segment peak at 54 ms. Earlier log errors include fonts/fluid scripts and Firearms translation formatting, so this is not a whole-console-clean claim. No OMHTT pack exception found. This supports the owner's pack result, not a combat stress certificate or acceptance of every historical checklist. No repeat pack test is requested now. [Versioned result](TEST_v0.2.48.1.md#c191-owner-result-and-console-review-2026-10-12).

Roadmap reconciliation: R3C4 contract/baseline, R3C5 Magazine/Splitter/Fragment and R3C6 conditional/Piercing content are already implemented; don't propose redoing their choices. R3C7 combined balance/endurance/lifecycle is still the open module-track checkpoint; this pack slice is now owner-accepted, with two queued polish changes. R1C3 performance/authority remains parallel work, and previously accepted lag improvements stay accepted. The next documented new-head content path is R3C1 selection -> R3C2 prototype; Ballista remains the shortlist's recommended first candidate, not an approved implementation. Rotary Blades/Bat are alternatives. Nail Scatter overlaps the since-implemented Tack module and requires a renewed distinct-role discussion before selection. R4C1 signal contract precedes R4C2 connected traps; R5 integrated MP/integrations/release and R6 Cure simulation stay later. Phase order is flexible, not an automatic requirement to finish every old test before discussing new content.

Updated stale roadmap checkbox/table wording for already implemented C106/R3C4-R3C6 work without claiming all rendered acceptance. Inspected c898bf1 on codex/performance-barbed-audit, fetched origin and checked the sole open draft PR #1. Documentation/test findings only: Source, Contents, installed version, test tag, hosted site and Workshop draft are unchanged.

## C192 - New turret-head track selected; shortlist requested (2026-10-12)

Owner: "I guess it's time to start working on New Turret Heads, provide our list". Move active content discussion to R3C1 selection, followed by R3C2 prototype. Present the seven documented candidates without treating this as selection/approval of any head. Recommend Ballista first for implementation fit, with Rotary Blades as the strongest mechanical alternative and Rotary Bat sharing that mechanism. Scrapshot and Nail Scatter need distinct-role review against existing modules; Grenade lobber and Arc emitter stay later options. Correct historical shortlist statements superseded by implemented Tack and endpoint Fragment. C191 pack timing polish remains approved and queued. R1C3/R3C7 stay open, with accepted test findings preserved. No source/version/install/Workshop change or new test request.

Inspected 283abb8 on codex/performance-barbed-audit and fetched origin; sole open draft PR #1 targets dev. Current details: TURRET_HEAD_PROPOSALS.md#c192-active-new-head-selection-2026-10-12.

## C193 - Ballista, Rotary Blades and Rotary Bat selected (2026-10-12)

Owner: "Let's create 1A 1B and 1C." Approves development scope for all three selected heads, superseding C192's unselected state. R3C1 roster selection is complete for this bundle; ammunition, coverage, player danger, compatibility, recipes and exact tuning remain unresolved. Record concrete A/B choices and recommend one shared rotary system alongside a Ballista projectile extension. Read-only code inspection confirms firearm-versus-potato assumptions in TurretStats/TurretVolley that require explicit head compatibility. Do not silently inherit potato splash or firearm-only Piercing assumptions. No recipe or gameplay changes this turn; the project requires owner review of materials/tools/skills/XP. Final art restrictions remain. C191 queued timing refinements are retained for the next patch.

Inspected 051e41b on codex/performance-barbed-audit and fetched origin; sole open draft PR #1 targets dev. Contract: TURRET_HEAD_PROPOSALS.md#c193-three-head-development-scope-2026-10-12. No version/install/test/publication change.

## C194 - Spear ammunition, directional rotary heads and player contact confirmed (2026-10-12)

Owner chooses C193 1B/2B/3A/4B and explicitly asks to discuss what module adaptations are possible. Confirm crafted-spear Ballista ammo, forward rotary sweep with 360 upgrade, and player injury on moving contact. Explore melee equivalents; no blanket approval of invented effects. Recorded an evidence-based candidate compatibility matrix and three grouped choices in TURRET_HEAD_PROPOSALS.md#c194-confirmed-head-rules-and-module-adaptations-2026-10-12. Recommend attack sequences for cycle modules, bounded extra-stroke/cleave/proc adaptations, and deferring Range/Accuracy until meaningful visible mechanics exist. All mappings remain proposals; recipes/tuning/native rotary proof remain open. C191 timing polish remains queued. Inspected 6ec09e7 and fetched origin; sole open draft PR #1 targets dev. Documentation only.

## C195 - Continuous physical rotary heads; ten modules initially unsupported (2026-10-12)

Owner selects C194 1B/2B/3A. Confirm continuous swings without magazine/reset mechanics; Magazine/Reload/Autoloader/Impact unsupported. Defer Fragment/Tack/Martyrdom/Synergy for the physical-melee-first prototype. Range/Accuracy remain incompatible initially. These restrictions are rotary-specific, not changes to existing heads or automatic Ballista restrictions. Continuous attacks do not imply idle spinning. Remaining physical adaptations, baseline tuning, player injury severity, recipes and spear lifecycle still require settlement; do not treat unnumbered earlier proposals as approved. Recorded in TURRET_HEAD_PROPOSALS.md#c195-continuous-physical-rotary-scope-2026-10-12. C191 pack timing remains queued. Inspected 98dffb6, fetched origin and confirmed sole open draft PR #1. Documentation only; installed 0.2.48.1 unchanged.

## C196 - Splitter excluded from rotary heads (2026-10-12)

Owner explicitly removes Splitter and favors avoiding forced module adaptations. Apply this to Rotary Bat/Blades; preserve existing projectile-head behavior and prior rotary exclusions. Recommend also excluding Piercing/Conservation (1A), with retaining their adaptation discussion as 1B; not yet approved. No head selection, recipe or gameplay implementation is repeated or assumed. Contract: TURRET_HEAD_PROPOSALS.md#c196-simpler-rotary-compatibility-2026-10-12. Inspected 736acd2, fetched origin and checked sole open draft PR #1. Documentation only; installed 0.2.48.1 unchanged; C191 pack timing stays queued.

## C197 - Inherent multi-target Bat/Blades; Piercing and Conservation excluded (2026-10-12)

Owner approves C196 1A and clarifies both rotary heads are always piercing. Confirm inherent multi-target physical sweep contact, without module-gated extra victims. Piercing and Conservation are excluded alongside prior rotary exclusions. Do not infer wall penetration, invisible reach, an arbitrary victim cap or projectile damage falloff. Recommend once-per-victim-per-stroke for frame-independent damage, subject to contact/cadence proof. Stats, recipes and other remaining head rules are still open; no gameplay implementation. Contract: TURRET_HEAD_PROPOSALS.md#c197-inherent-rotary-multi-target-contact-2026-10-12. Inspected 81b349e, fetched origin and checked sole open draft PR #1. Installed 0.2.48.1 unchanged; C191 timing queued.

## C198 - Starting combat-stat choices presented (2026-10-12)

Owner requests the next decision. Propose Ballista120/4s versus180/6s at18tiles, Bat20/1.5s/40%shove versus30/1.5s/20%, Blades40/1.5s versus25/1s with10%shove; both rotary heads reach1.25tiles subject to visual/contact proof. Recommend1A/2A/3A, once per victim per stroke and shared five-second reaction protection. All are unapproved starting test values, not measured balance; player injury severity is separate. Preserve current multi-target/module exclusions and C191 queued timing. Full semantics/tradeoffs: TURRET_HEAD_PROPOSALS.md#c198-starting-combat-stat-choices-2026-10-12. Source potato defaults checked; inspected19b3871, fetched origin and sole open draft PR#1. Documentation only.

## C199 - Heavy Ballista, Bat2A correction and two-arm rotary motion (2026-10-12)

Owner selects heavy Ballista1B with stronger-than-native-rifle requirement, Blades3A modified to1s, and initially Bat2B. Same-turn correction explicitly changes Bat to2A:20 damage/1.5s/40% shove. Blades40/1s/10%; Ballista selected180/6s/18tiles. Owner requires opposite front/back arms, both swinging without360 and spinning with360; supersedes front-only coverage and safe-rear assumptions. Native rifle scripts and current mod conversion establish160 strongest default mounted-rifle ordinary damage,640 at4x crit. Recommend240 Ballista base (not yet approved) and shared per-victim cadence across both rotary arms (not yet approved); expose alternatives and limits. Full evidence/options: TURRET_HEAD_PROPOSALS.md#c199-selected-stats-and-opposite-rotary-arms-2026-10-12. Inspected5a00327, fetched origin, sole open draft PR#1. Documentation only; existing build and C191 queued polish unchanged.

## C200 - Ballista240, reduced accuracy and independent25RPM rotary arms (2026-10-12)

Owner approves C1991A/2B, requests less accurate Ballista and high battery draw for rotary heads at25RPM. Confirm240damage Ballista and independent arm contact; shared cross-arm damage lockout is rejected. State interpretation:25RPM for360 spin, prior non360 swing intervals retained. Derived2.4s/revolution and1.2s between opposite-arm passages; do not claim doubled per-second damage. Propose accuracy75/45% versus85/55%, and active-motor baseline life3 versus6in-game-hours before module/Regulator effects. Recommendations are1A/2A, not approvals. Motor-time billing is proposed; rates/timebase remain to verify. Contract: TURRET_HEAD_PROPOSALS.md#c200-independent-arms-at25rpm-and-ballista-accuracy-2026-10-12. Inspected7d0c13f and fetched origin; sole draft PR#1. Planning only; installed build unchanged, C191 timing queued.

## C201 - Convert25RPM to non360 angular swing rate (2026-10-12)

Owner annotation corrects C200: "Convert the25RPM to the rate without360." Replace retained Bat1.5s/Blades1s with150degrees/second in both modes. Proposed90degree non360 arc gives0.6s each way,1.2s out/back; two opposed arms move together. Full rotation remains2.4s/revolution with1.2s opposite-arm passages. Explain focused-sector contact can occur more often at equal angular speed, and verify reversal deduplication. Exact arc is still working geometry, no rendered proof. Annotation addresses speed, not approval of the quoted motor-charge recommendation. Accuracy/power options remain unselected. Contract: TURRET_HEAD_PROPOSALS.md#c201-shared-angular-speed-for-swing-and-spin-2026-10-12. Documentation-only correction after eb4b00e; mirror with C200, preserve C191 queued timing.

## C202 -45degree front/rear arcs; sides require360 (2026-10-12)

Owner corrects90degree assumption to45degrees at the front and back, with no side hits without360. Record45degree total sectors centered on opposing placement axes, plus/minus22.5degrees. Approved150degrees/second gives0.3s each direction/0.6s out-back;360 remains25RPM. Narrower oscillation concentrates repeated contacts; document the arithmetic and reversal-deduplication risk without silently adding a forbidden shared damage cooldown. Contract: TURRET_HEAD_PROPOSALS.md#c202-45degree-front-and-rear-arcs-2026-10-12. Same-turn correction after36b5773; documentation only, queued C191 unchanged.

## C203 - Accuracy and battery options with verified formula arithmetic (2026-10-12)

Owner requests options/recommendations. Propose Ballista hit chance75/60/45%(1A),85/70/55%(1B) or65/50/35%(1C) close/half/full18tile range. Recommend rotary6in-game motor-hours(2A), versus3(2B) or12(2C), before module/Regulator/speed modifiers;6hours at3x drain becomes2, or2.5with one Regulator. This revises C200 recommendation based on surcharge impact. Propose Ballista0.05%/shot(3A), current formula0.000853815%(3B), or0.10%(3C), calibrated at240damage/18range before modules. Current formula verified from TurretStats and normalized charge debit; no implemented Ballista claim. Recommend1A/2A/3A. Current FirearmAccuracy close-point boost needs a separate Ballista endpoint path. Motor-time/activation/speed charging rules are proposed, not approved. Full details: TURRET_HEAD_PROPOSALS.md#c203-accuracy-and-battery-options-2026-10-12. Inspectedf203255, fetched origin, sole draft PR#1. Documentation only, installed build unchanged and C191 queued.

## C204 - Accuracy and battery approved; Ballista0.025% per shot (2026-10-12)

Owner selects C2031A/2A and3A modified to0.025%. Confirm75/60/45% Ballista hit chance close/mid/max,6in-game rotary motor-hours baseline before modifiers with proposed moving-motor charging/automatic stop rules, and0.025 percentage points per Ballista committed shot at240damage/18tiles.4000 shots per full battery before modifiers; preserve existing damage/range and rarity/Regulator scaling. Supersedes proposed0.05%. Contract: TURRET_HEAD_PROPOSALS.md#c204-approved-accuracy-and-battery-2026-10-12. Durability/injury/recipes/spear lifecycle and remaining compatibility details stay open. Inspected889f8f0, fetched origin, sole draft PR#1. Documentation approval only; installed build unchanged; C191 timing queued.

## C205 - Durability, repair, player injury and recipe proposals (2026-10-12)

Owner requests options for all four subjects. Recommend1A separate100-condition heads with Ballista2000-shot/Bat12-hour/Blades18-hour active-use life;2A10second free full Repair Head preserving existing base-repair distinction;3A2limb-damage/+5pain Bat and native laceration Blades, shared2second player-only injury guard;4A three separate native-material head recipes with explicit costs/tools/skills/XP. Alternatives offer longer/no operation wear, material50% repair, harsher injuries or EngineParts scavenging requirement. Installed materials and existing repair/injury code inspected; no claim recipes or new contact work are native-verified. All detailed defaults remain proposed: TURRET_HEAD_PROPOSALS.md#c205-durability-repair-injury-and-recipes-2026-10-12. Inspected e4c8817 and fetched origin; sole draft PR#1. Documentation only, no patch/install, C191 timing queued.

## C206 - Potato-style base maintenance, approved injuries and mount clarification (2026-10-12)

Owner conditionally selects no new head wear, explicitly says only the base is the concern, approves C205 3A injuries and 4A recipe direction while requiring rotary mounting materials. Source confirms Potato has ConditionMax100 metadata but no operational wear; only base Repair and native firearm wear currently exist. Record new-head no-wear/no-Repair-Head behavior, unchanged firearm/base rules, moderate guarded player injuries, and integrated mount versus separate Rotary Mount options. Existing common mechanism materials already provide the proposed mount; exact presentation remains pending. Native CircularSawblade entries are broadly present in tool/carpentry pools, weighted 2-8 typically in the checked garage/shop pools and 20/10 in two factory pools; weights are not spawn percentages. Full contract: TURRET_HEAD_PROPOSALS.md#c206-base-only-maintenance-and-rotary-mounting-2026-10-12. Inspected563d891 and fetched origin; sole draft PR#1. Documentation only; no gameplay/test/version/install changes, C191 timing queued.


## C207 - Integrated mounts, Ballista nails and implementation approval (2026-10-12)

Owner: "1A, we should also add nails to the ballista. I think we're far enough to start this patch. You're approved to begin." This authorizes the C206 integrated mount option and implementation. Eight nails is the selected implementation quantity, not a separately quoted owner number. No separate mount item, redundant complete-turret recipe, new head-wear system or final art.

Implemented0.2.49 with all prior selected head rules and C191 pack timing. Exact implementation defaults, Filter exclusion, tests and remaining rendered limitations are in [the current contract](TURRET_HEAD_PROPOSALS.md#c207-approved-integrated-mounts-and-implemented-prototypes-2026-10-12). Inspected4518077 and fetched origin before work. Alex guidelines applied: no shipped pcall/xpcall/ipairs/next; new non-guard inline conditionals expanded, helpers imported, SP guards preserved and contacts budgeted/cached. Automated/native results are distinct from owner acceptance. No sibling project, hosted LootLab, account weights, Workshop or official release changes.


## C208 - Owner test deferred and next-head advice (2026-10-13)

Owner cannot test0.2.49 now and asks whether to add heads. Recommend one design discussion first, with Grenade Lobber1A, Scrapshot1B, Arc Emitter1C and Nail Scatter1D/defer. Reasons, overlap and native-proof gates are recorded in [the contract](TURRET_HEAD_PROPOSALS.md#c208-next-head-options-while-testing-is-deferred-2026-10-13). No new head selected or approved; current build and R3C2 acceptance remain unchanged. Fetched origin at72806fe; sole draft PR#1. Planning-only update under C119/C108.


## C209 - Grenade Lobber and Scrapshot selected for design (2026-10-13)

Owner selects C2081A/1B. Both heads enter discussion; no implementation or specific ammo/collateral contract approved. [Initial choices](TURRET_HEAD_PROPOSALS.md#c209-grenade-lobber-and-scrapshot-design-2026-10-13) recommend native PipeBomb feed, impact detonation, loose ScrapMetal feed and actor-only blast collateral. Native script confirms PipeBomb identity only; trajectory and explosion behavior need proof. Installed0.2.49 owner test remains deferred; no code/version/test-result changes. Fetched origin0a58373; sole draft PR#1 into dev.


## C210 - Multi-payload ammunition, landing fuse and improvised balance concern (2026-10-13)

Owner confirms C2091C/2B/3A/4A and raises possible improvised explosives becoming dominant outside turrets. Confirm multiple payloads, short fuse after landing, loose ScrapMetal and actor-only/no-fire/no-structure turret blast. Propose turret-only Improvised Shell1A, weak throwable1B or native-only1C; no new shell or numerical balance approved. Native Aerosolbomb ignition metadata requires turret-specific no-fire behavior without editing handheld scripts. [Contract and proposed roster](TURRET_HEAD_PROPOSALS.md#c210-payload-rules-and-improvised-ammunition-balance-2026-10-13). Fetchedc6042cf and checked sole PR#1. Planning only;0.2.49 test remains deferred.


## C211 - Cloud ammo roster, priority, fallback and corrected fuse (2026-10-13)

Owner asks for an explainable turret-only shell and visible additional loaded ammo for future supported ammo mods. Selects **2B** player-controlled priority, then **3B** stop on preferred-ammo exhaustion unless **Use next ammo type** is enabled (default OFF). Later selects **1A** roster (Improvised Shell/Aerosol Bomb/Pipe Bomb) and first **2C**, immediately correcting to **2A I meant**: the approved fuse is **two seconds after landing**, not three. The shell requires the launcher's powered arming system and cannot be thrown by hand. Exact damage/radius/recipes are still open. C210 actor-only blast and no fire/structure damage persist. [Full contract](TURRET_HEAD_PROPOSALS.md#c211-cloud-ammunition-decisions-and-pc-handoff-2026-10-13).

Owner explicitly requests continuing planning here and updating GitHub every time until the PC chat picks it up, reaffirming C108/C119. This record consolidates the intervening Cloud selections that had previously only been acknowledged in chat. Branch `planning/lobber-ammunition` starts from active `codex/performance-barbed-audit` checkpoint `63c32db`, including current dev. PC must fetch/reconcile the planning commits. No gameplay implementation approval, new version, owner test, or publication claim.

## C212 - Proposed Lobber engagement envelope and cadence (2026-10-13)

Present next choices: 1A recommended 6-18 tiles versus 1B 8-24 tiles; 2A recommended six-second base launch interval versus 2B eight seconds. The approved two-second post-landing fuse is independent. These are recommendations, not owner-selected numbers or verified native capabilities; blast safety, reload/modifier interactions and power remain to settle. [Options and tradeoffs](TURRET_HEAD_PROPOSALS.md#c212-proposed-lobber-range-and-cadence-choices-2026-10-13). Preserve installed 0.2.49 and deferred acceptance.


## C213 - Lobber 6-18 tiles and two-second firing interval (2026-10-13)

Owner: "1A / 2 - 2seconds". Confirms C212's 6-18-tile range and supplies a two-second base launch interval instead of either proposed six/eight-second option. C211's two-second post-landing fuse remains separate and unchanged. This is design approval, not authorization to implement a patch. [Contract and proposed payload balance choices](TURRET_HEAD_PROPOSALS.md#c213-approved-lobber-range-and-two-second-cadence-2026-10-13) record 30 theoretical base launches/minute, overlapping payload considerations, proposed 1A restrained versus 1B heavier zombie damage at 2/3/4-tile radii, and 2A linear versus 2B inner-half full-damage falloff. These next choices remain unapproved; player injury and all other unresolved contracts retain their gates. Inspected planning checkpoint 530c07c and checked remote branches (development still 63c32db). Documentation only; 0.2.49 test remains deferred.


## C214 - Request for stock Pipe Bomb and Aerosol Bomb damage (2026-10-13)

Owner asks for native damage, selecting none of C213's proposed balance values. Existing installed-game script evidence records ExplosionPower/ExplosionRange 90/7 and 70/6 respectively, not measured HP loss. [Clarification and native follow-up](TURRET_HEAD_PROPOSALS.md#c214-native-explosive-baseline-question-2026-10-13) prevents interpreting those fields as direct damage or presenting proposed turret numbers as native parity. Actual damage conversion remains a local evidence question; no game-dependent tests ran in Cloud. Inspected b667d02; remote development remains 63c32db. Documentation only.


## C215 - Investigate native explosive damage conversion (2026-10-13)

Owner: "Figure out what the damage values equate to". Investigation retrieves pinned public 42.0 source and compares committed 42.20 character bytecode; neither establishes 42.21 bomb health loss. Historical capped power/random Hit input and its additional downstream modifiers are documented, not represented as current health damage. [Findings and exact local evidence needed](TURRET_HEAD_PROPOSALS.md#c215-explosion-damage-trace-and-version-mismatch-2026-10-13). Current damage options remain unselected; no gameplay change, native execution or test-status change. Inspected ff3c75a and remote branches; active development remains 63c32db.


## C216 - Assign native damage answer to PC and continue independent planning (2026-10-13)

Owner: "Well note that down so it'll be answered once the PC has the decompiled code. What else shall we discuss". C215 becomes an explicit PC follow-up; damage/radius/falloff remain unselected. Present proposed chambered-ammo switching (1A finish chambered round; 1B recommended pause and explicitly unload/reload safely) and fallback recovery (2A recommended return to preferred at next reload/selection; 2B exhaust fallback first). [Full choices and item-preservation rules](TURRET_HEAD_PROPOSALS.md#c216-pc-damage-follow-up-and-ammo-switching-discussion-2026-10-13). No answers to these options inferred. Inspected 0c42c32 and unchanged remote development 63c32db. Planning only, mirrored under standing authorization; no game tests or new implementation approval.


## C217 - Approve safe switching and return to preferred; propose Scrapshot pattern (2026-10-13)

Owner: "1B / 2A" in response to C216. Confirm explicit safe unload/reload after a conflicting player priority change, preserving exact unspent ammunition, and return to preferred ammo at next normal reload while fallback is enabled. Preserve chambered and in-flight identities and default-OFF fallback. [Contract and next Scrapshot choices](TURRET_HEAD_PROPOSALS.md#c217-ammo-switching-selected-and-scrapshot-pattern-options-2026-10-13) distinguish approved ammo behavior from new recommended 1A 6-tile/60-degree spread and 2A one-scrap/three-second volley proposals. Alternatives are 8-tile/35-degree spread and one-scrap/two-second volleys. No pellet count/damage, energy, recipes or implementation approved. Native explosive damage remains the PC's follow-up. Inspected 838f055 and remote development 63c32db; documentation only.


## C218 - Scrapshot spread accepted; challenge unnecessary new mechanics (2026-10-13)

Owner: "1A - Why did we deviate from our spread? I'm down for 60, but we're inventing things that don't need to be. Just suggest if you think it'd be good. 2 - Why are we using volley and every however many seconds? This doesn't make sense." Record the selected C217 1A range/spread, with no approval of ammo quantity or either firing interval. [Read-only comparison and corrected recommendation](TURRET_HEAD_PROPOSALS.md#c218-scrapshot-consistency-correction-and-plain-firing-terms-2026-10-13) distinguishes existing shotgun target/pellet handling, Splitter spread and shared cooldown/reload logic. Recommend ordinary shot terminology and shared firing machinery, not an extra volley delay. Explain any proposed deviation before implementation. Inspected a8fdba2; remote development remains 63c32db. Only planning Markdown changed; no code execution tests or gameplay approval.


## C219 - Scrapshot two seconds with no magazine/reload; Lobber 3.5 seconds (2026-10-13)

Owner: "Let's do every 2 seconds, and a reload isn't necessary since there's no mag. We'll change grenade launch to 3.5 seconds". Confirm Scrapshot two-second base shot interval and no magazine/reload cycle. Replace Lobber two-second launch interval with 3.5 seconds; keep its separate two-second post-landing fuse and prior mixed-ammo handling. [Contract and proposed next steps](TURRET_HEAD_PROPOSALS.md#c219-scrapshot-direct-feed-and-revised-lobber-firing-interval-2026-10-13). One scrap per shot and shared total fragment damage are recommendations, not selected by this timing answer. Magazine-dependent module exclusions still need explicit compatibility review. Native explosive damage remains a PC follow-up; no gameplay implementation or test approval. Inspected 6dc7044 and unchanged development remote 63c32db. Planning-only GitHub update.


## C220 - Approve Scrapshot consumption, shared damage and three module exclusions (2026-10-13)

Owner: "Approved, what's next to discuss?" Approves the preceding one Scrap Metal per shot, shared total fragment damage, and Magazine/Reload/Autoloader exclusions. Does not settle Impact or other unpresented module choices. [Contract and next damage choices](TURRET_HEAD_PROPOSALS.md#c220-scrapshot-feed-and-module-exclusions-approved-damage-choices-2026-10-13) recommend six fragments sharing 120 total zombie damage (20 each), versus six sharing 180 (30 each); these new numbers await selection. Other selected timing/range/feed behavior remains; no new implementation approval or test outcome. Inspected c5189aa and unchanged remote development 63c32db. Planning Markdown only, committed and mirrored under standing authorization.


## C221 - Scrapshot six fragments, 15 damage each (2026-10-13)

Owner: "1A - 15 damage per fragment". Retain six fragments from C220 option 1A and replace 20 damage each with 15, for 90 total base zombie damage per shot. [Contract and next compatibility recommendation](TURRET_HEAD_PROPOSALS.md#c221-scrapshot-six-fragments-at-15-damage-each-2026-10-13). Preserve the shared shot budget and earlier feed/range/spread/timing approvals. Recommend additionally excluding Impact because no empty-reload trigger exists; do not infer approval of that new recommendation or other modules. No gameplay patch approval, native execution or new test result. Inspected 2d12c1c and unchanged remote development 63c32db; planning update only.


## C222 - PC pickup of Cloud planning C211-C221 (2026-10-13)

User requests checking GitHub progress. Fetched origin/planning/lobber-ammunition at5b623ef and inspected all ten new documentation commits; imported them into active development under C119, preserving approvals and superseded values. [Consolidated handoff](TURRET_HEAD_PROPOSALS.md#c222-pc-planning-reconciliation-2026-10-13). Only draft PR#1 exists; no PR merge or gameplay changes. Native explosive-damage trace remains an explicit PC follow-up. No new design approval or test result;0.2.49 acceptance stays deferred.


## C223 - PC explosive damage proof and consolidated remaining choices (2026-10-13)

Owner requests discussion including the damage issue and other remaining decisions. Inspected development38b5e397 and fetched origin. Read installed42.21 bytecode; isolated native execution verifies explosive/non-melee classification, zero ExtraDamage and four deterministic damage-boundary health deltas. First run timed out during startup; second completed successfully. Full explosion/player/trajectory behavior is not tested. **C223 / native damage answered; remaining head choices (2026-10-13).** Installed42.21 bytecode plus a stock-first real-item/native-health probe establish ordinary zombie damage potential: Aerosol350-<700/radius6, Pipe450-<900/radius7 on OMH's scale, before overkill clamping. No native distance falloff; player injury is separate. Full blast scene/trajectory remains unverified. [Evidence](NATIVE_EXPLOSIVE_DAMAGE.md) | [Options and complete remaining agenda](TURRET_HEAD_PROPOSALS.md#c223-pc-damage-findings-and-remaining-decision-agenda-2026-10-13). Tuned damage/falloff, Scrapshot victim allocation/Impact, module matrix, injury/accuracy, feed/power, recipes and feedback remain proposals. No gameplay patch approved;0.2.49 owner test remains deferred.

Options1A/1B/1C,2A/2B,3A/3B and4A/4B are recommendations only. Preserve C211-C221 approvals; no source/version/install/owner-acceptance changes. Planning/evidence mirrored under C108/C119.


## C224 - Lure, head revisions and built-in magazine discussion (2026-10-13)

**C224 / head feedback and expanded design (2026-10-13).** Owner requests Lure,90-degree front/rear rotary sectors and longer mount reach, narrower/longer-range Ballista with a travelling spear, wider/more Scrapshot fragments and built-in magazines (capacities pending). Multiple fragments per victim accepted; linear blast falloff conditional on final damage choice. Native bomb strength remains under discussion. Ballista's instant bullet path and100-weight container versus100-ammo mismatch confirmed in code; console0.2.49 shows full-transfer rejection consistent with reported44 spears. [Findings/options](TURRET_HEAD_PROPOSALS.md#c224-owner-head-feedback-lure-and-magazine-redesign-2026-10-13) | [Partial owner test](TEST_v0.2.49.md#c224-partial-owner-findings-and-console-review-2026-10-13). No gameplay patch yet; rotary magazine exception, exact values and native trajectory/storage proof remain open.

Owner annotation questions native strength and raises scarcity; not an approval of C2231C. C2232A conditionally selected and3A selected with expanded width/count requested.4C reopens Scrapshot no-reload/exclusions; do not implement Impact exclusion. Present new groups1-6 in the linked contract, clearly proposed. Recommend ammo-free rotary exception and preserving native firearm capacities; not settled by all-head wording. No final art, source, tools, package or version changes. Console reviewed read-only and small filtered evidence retained. Existing test status becomes partial findings, not blanket acceptance. Fetched origin; starting commit c3a2f1e.


## C225 - Approve revised head values and review earlier-head modules (2026-10-13)

Owner:1A with150 damage/radius4 expensive Shell;2B with volume/range control and OMH Horde Night sound;3B;4A;5A;6B; asks to consider modules on previous heads. **C225 / head revisions selected; module review open (2026-10-13).** Owner selects native bomb strength/radii plus linear falloff; Shell150/radius4 with expensive crafting; repeating/manual Lure with adjustable volume/range and Horde Night attraction audio; rotary2-tile reach/90-degree sectors; Ballista45-degree FOV/24-tile range/24tiles-sec; Scrapshot90degrees/8x15; magazines Potato3/Ballista5/Lobber3/Scrapshot10. [Confirmed values, audio evidence and module choices](TURRET_HEAD_PROPOSALS.md#c225-selected-revisions-and-previous-head-module-review-2026-10-13). Previous-head module review finds inactive Potato Piercing still accepted/charged; rotary Tack/Martyrdom and linked Lure control are proposals. Reload/power/recipes, explosive module rules and native lifecycle proof remain open. No gameplay patch or test-status change.

C2246B applies to ammo-using custom heads, with native firearm capacities preserved and no rotary ammunition. Built-in counts do not fix reserve-weight limits. New options1A/1B/1C rotary effects,2A/2B Potato Piercing and3A/3B Lure control are recommendations only. Final recipes/acquisition/numerical Lure limits and broader module matrix remain unapproved; no patch authorization inferred. Source review and owned audio discovery only, no game tests or sibling edits. Inspected a45f57b and fetched origin; mirror under C108/C119.


## C226 - Rotary effects, Potato per-contact effects and5-20tile Lure (2026-10-13)

Owner: "1A /2B - It'll apply on all zombie contacts. /3A -5 to20tiles." **C226 / module and Lure selections (2026-10-13).** Owner approves rotary Tack+Martyrdom, working Potato Piercing with splash/knockdown chance at each directly contacted zombie, and linked Lure loudness/range bounded5-20tiles. [Interpretation, existing effect guards and next Lobber module choices](TURRET_HEAD_PROPOSALS.md#c226-rotary-effects-potato-contact-behavior-and-lure-range-selected-2026-10-13). Retain splash-versus-direct distinction and no recursive effects; exact splash scaling/overlap needs explicit balance review. New Lure default remains unselected. Lobber Conservation/Splitter options are proposals, not part of this approval. No gameplay patch, version or test-status change.

Selection references C225 response: rotary Tack+Martyrdom; Potato penetration with splash/direct-contact knockdown; linked sound/range slider. No grant of splash-recursive knockdown or unbounded contacts. Retain existing module semantics pending final explicit detail; no automatic Synergy/Fragment expansion. Future Lobber option1A is a new recommendation, not the selected rotary1A. Inspected969f639 and fetched origin. Planning only; no code, runtime test, assets, install or sibling changes. Mirror under C108/C119.


## C227 - Approve both Lobber ammunition modules (2026-10-13)

Owner: "1B", referring to the immediately preceding C226 Lobber ammunition-module options. **C227 / Lobber Conservation and Splitter selected (2026-10-13).** Owner chooses C2261B: both modules supported, existing Conservation scaling,50%side-grenade damage and Splitter ammo rules including the last-round exception. Payload blast radius/falloff and two-second landing fuse retained. [Approved behavior and remaining gates](TURRET_HEAD_PROPOSALS.md#c227-lobber-conservation-and-splitter-approved-2026-10-13). Mixed-payload accounting and other modules/reload/power/recipes/injury remain open; no gameplay patch or test-status change.

Do not mistake this answer for older rotary/Potato choices. Scarcity tradeoff accepted; no new recursive secondary effects, payload conversion or gameplay implementation authorized. Read f416cd8, fetched origin, recorded documentation only. Standing C108/C119 mirror required.


## C228 - Combined patch recap and Module Pack completion flow (2026-10-13)

Owner explicitly requests Skip while rolling, Collect only after finished, and rarity audio only at roll completion including Skip, not Collect. Also says "Let's approve a new patch. Recap the new update." **C228 / combined next-patch recap and pack-flow correction (2026-10-13).** Owner requests approving the new patch and its recap, adding neutral Skip during rolling, green Collect after completion, and one rarity cue at natural/Skip completion, never triggered by Collect. This supersedes the250ms-early cue trigger. [Combined scope and remaining choices](TURRET_HEAD_PROPOSALS.md#c228-combined-patch-scope-and-pack-flow-correction-2026-10-13) | [Pack contract](PACK_POLISH.md#c228---skip-then-collect-and-completion-owned-rarity-audio-2026-10-13). Exact recipes, remaining module/ammo rules, reload/power and player injuries remain unset; no gameplay build/install/test-status change in this recap.

Source review confirms always-green Collect and early cue; it does not prove a collect-triggered playback call because close currently stops audio. Record observed versus inferred separately. Settled features remain in requested patch scope; do not infer unselected numerical recipes or module propagation. Inspected34c8e19 and fetched origin. Documentation only, mirrored under standing authorization.


## C229 - Consolidated choices requested before patching (2026-10-14)

Owner: Provide the choices and your recommendations for everything we still need to settle before patching.

**C229 / consolidated pre-patch choices (2026-10-14).** Owner requests all remaining choices and recommendations before implementation. [Twelve decision groups](NEXT_PATCH_CHOICES.md) cover mixed ammo, new-head effects, Potato splash overlap, reloads, power, Lure acquisition, exact recipes, player injuries, aiming/travel and the Ballista weight constraint. All A options are recommendations, not approvals; 12A corrects capacity presentation without increasing physical storage. C225-C228 approvals remain intact. No gameplay/version/install/test-status change.

Inspected active development15e8b63 and fetched origin. This is a proposal slate, not selection of all A defaults. Preserve prior accepted scarcity/module exceptions. Engine feasibility and bounded scheduling are implementation obligations, not owner decisions. Planning documentation only; mirror under C108/C119.


## C230 - Owner choices and native-component recipe reproposal (2026-10-14)

**C230 / selections recorded; recipes, mini grenades and spear expansion open (2026-10-14).** Owner selects C2291A/2A with Lobber Fragment mini grenades/3B/4A/5A/6A/7B/9A with two Scrap Metal/10A/11A/12A with40 spears. [Selections, native storage evidence and three revised choices](NEXT_PATCH_CHOICES.md#c230-owner-selections-and-revised-recipefragment-proposals-2026-10-14). Recipes return for native donor and improvised alternatives. Kits currently increase count, not placed weight capacity; native above100 world-container capacity warns rather than hard-clamps, and larger safe storage remains unproven. No gameplay/install/test-status change.

User explicitly asks cheaper common-material routes without rarer donor components and asks whether kits bypass spear weight. Preserve recipe alternatives as proposals, same-output recommendation not approval. New options1A/B mini count,2A/B donor recipes and3A/B immediate spear expansion policy are distinct from the old C229 numbers. Native evidence corrects any inference that100 is an absolute Java clamp. No protected calls or shipped code added. Fetched/reconciled2a1b7cf; standing C108/C119 mirror applies.


## C231 - Mini grenades, pump recipes and Void Module direction (2026-10-14)

**C231 / mini grenades and recipes selected; Void storage proposed (2026-10-14).** Owner selects C2301A and2B, replacing storage option3 with a roughly75% ammo-capacity reduction and portable Void Module holding permanently converted weightless ammo by type. [Approved direction, tradeoffs and remaining choices](VOID_MODULE.md). Reduction scope, normalization, conversion interaction, removal and rarity remain proposals. Preserve five-mini behavior, pump/improvised same-output recipes and earlier unrelated approvals. No gameplay/install/test-status change.

Owner explicitly selects1A/2B from C230 and proposes3C with approximately75% reduction, infinite non-withdrawable turret ammunition stored on the module, active compatible-ammo display and all-types tooltip. Record their preference for a unique donor without reopening the accepted pump recipes. All Void implementation mechanics/numeric reduction scope remain unapproved proposals; no virtual storage feasibility proof claimed. Inspected7ffbdff and fetched origin. Preserve the distinction between unlimited storage and finite consumed ammunition. Documentation only; mirror under C108/C119.


## C232 - Selective caps, potato/spear compatibility and compact decisions (2026-10-14)

**C232 / selective ammo limits and Void controls selected (2026-10-14).** Owner replaces blanket75% cuts with selective ammo maxima, allows rotten/variant potatoes and requests modded-spear support; selects manual Void beside Ammo, safe module removal and Mythic rarity. Magazines remain. [Native classification evidence and compact remaining choices](VOID_MODULE.md#c232-selective-capacity-broad-ammo-families-and-compact-decisions-2026-10-14). Exact caps, donor-stat normalization and prepared-potato scope remain proposals. Compact decision-table preference added to AGENTS.md. No gameplay/install/test-status change.

User selects1C (type-sensitive maxima), overrides rotten-potato exclusion and broadens ammo-family intent, then3A/4A/5A from C231. Category-based spear discovery is grounded in installed native XpUpdate.lua; potato identification requires explicit family registration, not Vegetables or English names. Standardized ammo stats remain proposed, not inferred from the variant request. Existing approval of module recipes and mini grenades stands. Fetch/review ecff49d; documentation/instruction-format update only, mirrored under C108/C119.


## C233 - AoE-aware capacity, donor stats and separate decision blocks (2026-10-14)

**C233 / damage-aware ammo limits and attenuated stats (2026-10-14).** Owner asks capacity balance including AoE, replaces Shell wording with grenade, selects retained donor ammo stats with reduced contribution for future alternate-ammo support, and approves whole-potato scope. [Capacity/scaling proposals and native evidence](VOID_MODULE.md#c233-ammo-balance-attenuated-stats-and-separated-decisions-2026-10-14). Vegetable/produce launcher remains an exploration idea. Separate decision blocks with thoughts/options now supersede combined tables in AGENTS.md. Exact capacity and scaling values remain proposals; no gameplay/install/test-status change.

Owner gives40/40/250 as illustrative targets, not a fixed approved balance table. Selects2B with attenuated relative damage contribution and3A whole potato boundary. Preserve relevant ammo state in Void rather than flattening contrary to the selected direction. Naming correction affects Improvised Grenade display, not native shotgun shells or handheld availability. Later steering explicitly rejects the combined decision-table format: separate each topic, thoughts, options and blank line. Proposal arithmetic uses stated hypothetical crowd density, not fabricated gameplay testing. Inspected714170c/fetched origin; documentation only, mirror required.


## C234 - Shared bomb capacity, Makeshift naming and25%ammo-stat contribution (2026-10-14)

**C234 / shared explosive capacity and Makeshift Bomb confirmed (2026-10-14).** Owner rejects per-explosive-type quotas, chooses Makeshift Bomb naming and approves25%of relative donor-stat difference. [Settled rules and final capacity choice](VOID_MODULE.md#c234-shared-explosive-capacity-and-makeshift-bomb-2026-10-14). One shared bomb count replaces subtype limits/weighted mixing;40 versus20 total bombs remains proposed. No gameplay/install/test-status change.

Owner answers1 by annotation correcting explosive subtypes, and2A selecting C233 stat scaling. Each supported bomb counts1 within a common allowance; no separate subtype quota or weighted mixture budget. Numerical40/20 choice still proposed, not fabricated approval. Makeshift Bomb is turret-only with unchanged selected recipe/damage; supported payload verification is not waived for arbitrary mod items. Fetched9ec9acb; docs only, standing mirror required.


## C235 - Final ammo capacity and combined patch readiness (2026-10-14)

**C235 / final capacity selected; ready to implement (2026-10-14).** Owner selects1B:40 spears,20 shared launchable explosives in any mixture,250 ordinary firearm base rounds. [Combined readiness and verification gates](VOID_MODULE.md#c235-final-capacity-selected-ready-for-implementation-2026-10-14). Last presented balance choice settled; remaining work is native integration/validation, not further generic design approval. Installed0.2.49 unchanged; no gameplay/install/test-status change in this readiness turn.

Owner:1B; Are we ready to patch? This answer selects C2341B, not an earlier alternate option with the same label. Confirm readiness of design; do not misreport a built/installed patch or seek repeated general approval. Preserve prior engineering gates, supported-mode restrictions and publication boundaries. Current response is a documentation/readiness handoff; no gameplay changes this turn. Fetchedfb1dc39; standing mirror required.

## C236 - Combined patch approval, deferred tests and multiplayer verification (2026-10-14)

**C236 / implementation approved; first development checkpoint and MP audit (2026-10-14).** Owner approves the combined C235 patch and requests multiplayer verification while deferring player tests. Pack Skip/Collect/completion audio and isolated ammo/Void foundations are implemented and regression-checked; the full patch is unfinished and not installed. [Progress and remaining integration](PATCH_C236_PROGRESS.md) | [MP audit](MULTIPLAYER_AUDIT_C236.md): existing production turret/trap paths remain SP-only; multiplayer compatibility is blocked, not passed.18,229 assertions and package checks pass; no live MP/owner acceptance. Installed0.2.49 and its immutable tag/evidence remain unchanged.

Owner: "Approved." Then: "Also verify Multiplayer compatibility. We won't be testing yet though." Approval covers C235 combined implementation, with verification added and live testing deferred. No new generic planning approval is needed. The audit confirms production remains SP-only; full multiplayer support requires a separate deliberate port. Preserve supported-mode guards and do not equate headless loading, native table serialization or foundation debug transport with live gameplay support. Mirror this incomplete source checkpoint under C108/C119; no installation, new immutable tag, Workshop upload or PR merge.

## C237 - Multiplayer was always required; correct the premature stop (2026-10-14)

Owner: "Okay, we knew this was for multiplayer from the beginning. Why have we stopped? What's needed."

Reaffirms original multiplayer intent rather than requesting a new optional feature. P1C1 already required dedicated-server lifecycle agreement; R5C1 is integrated proof, not permission to defer architecture. SP-first production prototypes accumulated authority debt. C236 incorrectly framed that known unfinished work as a reason to stop and as requiring fresh generic scope approval. Correct that interpretation without removing protective guards or inventing live compatibility evidence.

The C235 combined patch remains approved. Recommend establishing the common server-authoritative lifecycle and exact-item transactions first, then wiring Void/new heads and trap effects through shared rules. Details and acceptance gates are in MULTIPLAYER_AUDIT_C236.md, C237. No additional balance decision is needed for the identified gaps. Owner testing stays deferred; native/automated development can proceed. Optional sibling integrations and publication remain separate. This turn changes records only; no new gameplay, installation or test result. Fetched origin; no newer origin/dev commits than the active development history. Mirror under C108/C119.

## C238 - Horde Night integration and Score Divider patch preparation (2026-10-14)

Owner: "This mod is supposed to work with OMH: Horde Night, and it'll be allowed to be used with a Score Divider. We need to make sure it's safe to add and score. Brush up on Horde Night, and prepare a patch for Multiplayer integration."

Confirms intended Allowed-with-divider policy and coordinated MP integration preparation. This supersedes treating Horde scoring as merely an unrelated future suggestion. It does not select O07's proposed x0.20, the unresolved usage/outsider rule Q07, or a gameplay-settings baseline. MULTIPLAYER_HORDE_PATCH.md records reviewed current sources, required coordinated work and choices: recommend1A divide by5,2A enabled-world run marking,3A reviewed gameplay defaults initially. These are recommendations, not owner selections. One modifier for either/both packages and multiplicative composition preserve C09; no effect on actual kill counts or Trait XP. Shared-XP recipients/percentage and Cure simulation remain separate.

Fetched both repositories and inspected the required related chats plus current Horde release-preparation work. No incoming main/dev changes were missing; no sibling conflict or edits. Existing Horde native-Kahlua settings/persistence/score suite passes149 assertions, not new integration or live MP acceptance. Core schema5 and website validator lack T&T reduction support; T&T's after-death callback is too late to establish assistance for a terminal Horde kill. Preparatory specification addresses authority, exact-once deaths, attribution, persistent eligibility, historical scores, schema arithmetic, website parity and bounded replication. MP/C235 implementation remains authorized and unfinished, with owner tests deferred. No runtime changes, install, new tag, merge, publication or sibling push. Mirror these planning records through the standing T&T pipeline.

## C239 - Score Divider, opt-in and harder settings selected (2026-10-14)

Owner: "1A / 2B / 3B", referring to C238's final choices. Confirms divide by5 (retain20%), explicit per-run opt-in rather than automatic world-wide scoring, and default-or-harder settings audit in the initial integration rather than defaults-only. O07's numerical proposal is now approved; historical options remain provenance, not outstanding choices.

Update MULTIPLAYER_HORDE_PATCH.md, integration contract and current roadmap/status accordingly. One T&T factor applies for either or both packages, composing with other approved modifiers; no kill/XP division or retroactive rescoring. Consent must belong to the authoritative receiving run, with normal run-configuration permissions. Recommend gating special assistance by that consent; investigate native physical obstruction and Lure attraction before promising complete isolation. Do not force opt-in from a foreign device, silently select the rejected world-wide policy, or claim unknown settings are harder. No new owner decision is requested until a concrete unresolved behavior or native limitation is established. Shared-XP rules remain separate.

This turn records the selections and inspects existing Horde run configuration and T&T contact paths. No runtime/sibling edits, tests, installation or new MP acceptance. Fetched origin; no missing origin/dev commits. Independent approved MP/content work remains outstanding; player tests stay deferred. Standing T&T development mirror applies.


## C240 - implementation authorized; ordinary collision neutral (2026-10-14)

Owner: "Approved. Go ahead and implement the multiplayer patch with the Horde Night integration. We'll test later." Follow-up explicitly selects **1A: ordinary native collision is neutral; active effects require receiving-run opt-in**. Preserve C239 /5, per-run consent and default-or-harder audit. Gameplay acceptance remains deferred, not a development blocker. [Working implementation and evidence](PATCH_C240_PROGRESS.md).


## C241 - multiplayer catch-up implementation reaffirmed (2026-10-14)

Owner: "You need to ensure that we're caught up on Multiplayer implementation. You're approved to complete as much as possible." Continue approved production authority and native verification now, retaining C235/C240 scope and deferred owner testing. No new generic approval gate or change to the settled Horde policy. [Implemented lifecycle and remaining work](PATCH_C241_PROGRESS.md).

## C242 - continue multiplayer implementation without the owner test (2026-10-14)

Owner: "Keep going with the remaining multiplayer implementation. You're already approved, so complete as much as possible without waiting for me to test." Continue C235/C240/C241 implementation; do not request another generic approval or treat deferred owner testing as a development blocker. [Implemented inventory/Manage checkpoint, native findings and remaining work](PATCH_C242_PROGRESS.md). This checkpoint introduces no new balance choice, release approval or acceptance claim. Preserve the established Horde policies and remaining content work. Development source is mirrored through the standing T&T pipeline; sibling manual-mirror restrictions remain.

## C243 — complete approved MP work and mirror progress (2026-10-14)

Owner explicitly authorizes ALL multiplayer integration patches and requests continued completion without waiting for owner testing, plus a GitHub push. This preserves C235 content and the C239/C240 scoring policies; it does not certify unsupported engine behavior. Implemented feed/power/trap service progress and remaining authority work are recorded in [C243](PATCH_C243_PROGRESS.md). Existing sibling Horde integration may be mirrored as development under this explicit request, without updating its older release tag or publishing. No new generic approval gate.


## C244 — continue zombie combat synchronization and remaining MP work (2026-10-14)

Owner: "Why are we stopping again? Keep going with zombie combat synchronization and the remaining multiplayer work. You're already approved. Finish as much as possible and push it to GitHub." Continue implementation, verification and the development mirror under existing authority; no player-test or generic approval gate. [C244 implementation and evidence](PATCH_C244_PROGRESS.md) separates working barrier lifecycle from the experimental combat receipt path and its unresolved native ownership/async attribution cases. This does not change gameplay balance or certify MP completion.


## C245 — continued ownership handoff and multiplayer implementation (2026-10-14)

Owner explicitly requests resolving combat handoff, finishing remaining MP work, and pushing progress without another approval or test gate. Continue within C235/C240 scope. [C245 implementation and evidence](PATCH_C245_PROGRESS.md) records the completed Panel lifecycle/server-loot work and ordinary handoff recovery, without concealing the disconnect-after-apply and native packet/consent limitations. No balance choice, install, merge or release is inferred. C245 also corrects the C244 native fixture evidence: completion markers had not ruled out logged callback exceptions.


## C246 — complete the approved multiplayer implementation (2026-10-14)

Owner: "Complete multiplayer support." This reiterates the prior approvals to implement all multiplayer/Horde integration and push progress without waiting for owner testing. Implemented the remaining existing-roster paths and conservative consent-safe attraction admission; no new balance choice or content recipe is inferred. [Final behavior, evidence and limits](PATCH_C246_MULTIPLAYER.md). R1C3/R5C1 implementation and connected acceptance are distinct. Full C235 new-content/Void integration remains approved and unfinished; do not discard it, split the combined release, or call zero-client probes multiplayer acceptance.

## C247: complete content bundle on multiplayer authority (2026-10-15)

**C247 / 0.2.50 content bundle implemented and validated (2026-10-15).** Complete C235 content is integrated with C246 authority: Lobber/Makeshift Bomb, Scrapshot, Lure, Void, head magazines/ammo families, revised Ballista/rotary/Potato contacts and pack flow. 20,401 assertions, native recipes/virtual-firearm transactions, write/read and independent packages pass. Connected MP and rendered owner acceptance remain pending. [Patch](PATCH_v0.2.50.md) | [Verification](TEST_v0.2.50.md). Packaging/install and dev mirror are the final delivery steps; no Workshop publication.

The metal-saw tool uses the current native tag, not a nonexistent Hacksaw identity. Void uses private descriptor/debt state with compact replicated counts and bounded inspection; no new withdrawal or weight workaround. Scrapshot serializes same-shot contacts per victim across owner receipts. Approved tuning and cumulative unpublished notes are preserved.


## C248 — future work after the combined patch (2026-10-15)

**C248 / post-0.2.50 roadmap reconciliation (2026-10-15).** Owner is away from the PC and asks about future work; no gameplay results or new implementation approval are inferred. 0.2.50 is installed and mirrored at `7e2c099cc4917c4266c8f4722265f324beaf3851` with immutable `test/v0.2.50`. Next documented content track is R4C1 connected-control design, followed by triggered hazards/sensors/optional turret receiver. Recommend discussing R4C1 now while retaining focused 0.2.50 corrections, R1C3/R3C7 measured performance/balance and R5C1 connected acceptance. R5C2 coordinated Horde deployment/end-to-end scoring remains distinct from the deployed LootLab catalog; shared Trait Shop XP remains separate. Release assets/polish follow; Cure simulation stays last. This records a recommendation, not approval to implement Phase 4. [Current checkpoint table](ROADMAP.md#current-checkpoint-status-and-next-work).

Corrected stale current-table entries for head/content implementation, the pack audio queue, MP authority and Horde scoring. Historical checkpoint narratives remain historical; no old test was promoted to a pass, gameplay version changed, or new content implementation authorized.


## C249 — R4C1 preparation and choices (2026-10-15)

**C249 / R4C1 discussion prepared (2026-10-15).** Owner requests preparing and discussing connected controls. [Six proposed choices and multiplayer/performance constraints](checkpoints/R4C1_CONNECTED_CONTROLS.md): input power, plate detection, bounded links, cycling, access and recovery. Existing button-pulse/plate-held behavior is retained; choices are recommendations, not implementation approval. Recipes/service/ownership details follow; damaging receivers remain R4C2. Installed 0.2.50 and pending acceptance are unchanged.


## C250 — selected controls and external-mod investigation (2026-10-15)

**C250 / R4C1 selections and external-mod research (2026-10-15).** Mechanical inputs, editable local/controller targeting, 20-tile links with 32 inputs/outputs, receiver-specific held-signal behavior, controller-based faction-base access and one-second recovery selected/amended. Filter scope, base boundary and controller lifecycle remain open. [Current selections and researched mod candidates](checkpoints/R4C1_CONNECTED_CONTROLS.md#c250-selections-and-compatibility-research-2026-10-15). Recommend standalone controls with optional verified adapters; no dependency or gameplay implementation approved by this discussion. Installed 0.2.50 unchanged.


## C251 — independent controls and proposed controller rules (2026-10-15)

**C251 / standalone controls with optional integrations approved (2026-10-15).** Owner agrees to our own system with support for other mods. Specific adapters remain unverified; no required dependency selected. [Next controller choices](checkpoints/R4C1_CONNECTED_CONTROLS.md#c251-independent-controls-approved-controller-choices-proposed-2026-10-15): trigger/target filters, base boundary, assignment, controller-loss policy and local overrides. These recommendations await selection; no gameplay or installed-build change.


## C252 — controller radius, Horde consistency and personal ownership (2026-10-15)

**C252 / controller radius and placer-ownership discussion (2026-10-15).** Owner selects receiver-side filtering, 20-tile controller radius, persistent ownership after controller loss and local targeting overrides. Proposes placer-owned devices with faction/public sharing. [Horde consistency evidence and two remaining ownership/access choices](checkpoints/R4C1_CONNECTED_CONTROLS.md#c252-targetingradius-selections-and-placer-ownership-discussion-2026-10-15). Recommend management radius separate from ownership; Horde identity/consent remain separate from territory. No reusable base-area API identified in inspected local runtime. Sharing details remain proposals; installed 0.2.50 unchanged.


## C253 — public inspection, selected-group writes and native range marker (2026-10-15)

**C253 / read/write sharing confirmed; native range graphic identified (2026-10-15).** Everyone may inspect; Private/Faction/Public determines device writes, with placer ownership retained. Public is not limited to operation-only. Native Horde Manager uses the existing world circle marker API; straight links need separate matching rendering. [Selected access and native evidence](checkpoints/R4C1_CONNECTED_CONTROLS.md#c253-readwrite-sharing-selected-and-native-selector-reviewed-2026-10-15). Radius calibration/rendered acceptance and remaining device recipes/lifecycle design are pending. No gameplay or installed 0.2.50 change.


## C254 — range/FOV styling and next device choices (2026-10-15)

**C254 / native-style range/FOV visuals and device choices (2026-10-15).** Owner requests native-style visuals for ranges and FOV. Full native circles are available; angular sectors require separate matching geometry. Found stale rotary/Ballista visual-cone selection in current TurretRange.lua; preserve combat rules while correcting display in planned work. [Evidence and proposed placement/recipes/power/service/link choices](checkpoints/R4C1_CONNECTED_CONTROLS.md#c254-native-style-rangesfov-requested-device-choices-proposed-2026-10-15). Choices await selection; no gameplay/install change.


## C255 — installable controller and approved device specifications (2026-10-15)

**C255 / control-device specifications selected (2026-10-15).** Owner approves floor plates, wall buttons and a ham-radio-like installable controller; C2542A recipes/skills/XP, grid/generator plus small-battery fallback, 100 HP/free service and material-free links selected. [Exact selections, native radio evidence and two remaining controller choices](checkpoints/R4C1_CONNECTED_CONTROLS.md#c255-device-specifications-selected-2026-10-15). Battery endurance/outage behavior remain proposals. No gameplay/install change.


## C256 — controller endurance and outage selections (2026-10-15)

**C256 / controller power settled (2026-10-15).** Owner selects 48 in-game hours per full backup battery and independent device operation during controller outages. Grid/generator takes priority; settings, direct signals and ownership persist, with receiver resource rules intact. [Confirmed contract](checkpoints/R4C1_CONNECTED_CONTROLS.md#c256-controller-power-choices-confirmed-2026-10-15). Receiver-specific pulse/held/OFF responses and R4C2 content remain to discuss; native integration remains to implement/verify. Installed 0.2.50 unchanged.


## C257 — present decisions directly; receiver options (2026-10-15)

**C257 / concrete receiver choices supplied (2026-10-15).** Owner requests actual choices whenever decisions remain; recorded in AGENTS.md. [Four proposals](checkpoints/R4C1_CONNECTED_CONTROLS.md#c257-concrete-receiver-choices-presented-2026-10-15): projectile-head held response, rotary held response, optional inhibition and first Poke Floor/dart design. No new selection or gameplay change; controller power choices remain settled.


## C258 — unified activation, controller wording and Poke Floor (2026-10-15)

**C258 / unified signal activation and Poke Floor selected (2026-10-15).** Owner chooses sustained operation for all head types while powered by inputs, one-cycle button activation, optional controller "allow turning" and Poke Floor as the next receiver. [Selections and three material clarifications](checkpoints/R4C1_CONNECTED_CONTROLS.md#c258-unified-powered-activation-and-poke-floor-selected-2026-10-15): energy source versus switching, ON/OFF versus rotation wording, and connected-only versus all-turret scope. No per-device held-default re-selection needed; no gameplay/install change.


## C259 — owner test findings, UI direction and Detection clarification (2026-10-15)

**C259 / 0.2.50 owner findings and correction discussion (2026-10-15).** Owner completes the test with alternate-ammo rejection, Void reload stall, UI/FOV defects and requested Manage/pack/tooltip improvements. Captured SP0.2.50 console and installed manifests; confirmed the stale exact-ammo transfer check, tooltip title fallback, Expansion dimming and preview-cone mismatch. Void stall is log-confirmed; its root cause remains under investigation. Initial native weight audit and Scrapshot spread/damage comparison are recorded. [Full findings and two concrete choices](TEST_FINDINGS_v0.2.50.md). C2581A receiver power-switch semantics selected; Detection explanation and linked-only signal recommendation remain discussion. No gameplay/install change, blanket test acceptance or connected MP pass. Prioritize corrective work before new connected-control content; retained R4C1/Poke Floor planning is not dropped.


## C260 — Scrapshot320 and separate Firing/Detection roles (2026-10-15)

**C260 / Scrapshot damage selected and directional Firing clarified (2026-10-15).** Owner selects eight40-damage pellets (320total) and explains the original Firing/Detection separation for triggered traps. Existing turret fire/manual paths still require target acquisition; the coordinate/direction ray engine supports a feasible forward-shot implementation, not an already-working trigger mode. Recommend retaining separate modules: Firing actuates, Detection acquires/aims. [Contract, evidence and remaining behavior proposals](checkpoints/R4C1_CONNECTED_CONTROLS.md#c260-directional-firing-and-scrapshot-selection-2026-10-15). Preserve current90-degree Scrapshot spread because no spread change was selected. No Autonomy merge, all-turrets trigger requirement, gameplay edit or install inferred.


## C261 — blind forward firing and separate landing distance (2026-10-15)

**C261 / blind firing and separate Lobber distance confirmed (2026-10-15).** Owner selects C260 **1A and 2B**: triggered Firing-only operation shoots forward and spends normal ammo/power even without a target; Lobber gets a separate landing-distance control instead of reusing Engagement Range. Firing and Detection remain separate. [Confirmed contract](checkpoints/R4C1_CONNECTED_CONTROLS.md#c261-blind-firing-and-lobber-distance-confirmed-2026-10-15). Scrapshot remains selected at eight40-damage pellets/320total with its existing90-degree spread. Design selections recorded; installed0.2.50 and outstanding correction/MP acceptance status unchanged.


## C262 — implement the approved correction patch, 2026-10-15

Owner: “Approved. Go ahead and implement the patch with all the fixes and confirmed changes. Keep multiplayer in mind and push it to GitHub.” Implements C259 findings plus C260/C261 selections; see [0.2.51 patch](PATCH_v0.2.51.md) and [verification](TEST_v0.2.51.md). No new balance/recipe choices are inferred. Scrapshot stays eight40-damage pellets with its existing90-degree spread; Firing/Detection remain separate. The Void stall is now traced to mixed wall/active clocks, not assumed to be a depletion issue. Native placed capacity remains100 and the logical head caps remain40spears/20bombs; physical weight still applies. R4C1 physical devices remain recorded next, following the C259 correction priority. Approval is implementation authority, not owner or connected multiplayer test acceptance.


## C263 — owner correction report and Load Order mockup, 2026-10-15

Owner reports loud Makeshift explosions, asks Lobber to wait for detonation, requests Large Expansion scrap around80 and other metal scraps, shared Ammo/Void Load Order menus with arbitrary ordering, equal widths and more height, head reload sounds, white unwrapped descriptions except rarity, and plain rotary RPM. [All eleven findings, captured evidence and concrete choices](TEST_FINDINGS_v0.2.51.md). Proposed sound/cap/family/reorder semantics are not selections. Existing installed0.2.51 remains unchanged. This is a correction discussion under the project agreement, not a blanket gameplay approval or successful owner acceptance.


## C264 — correction selections and owner timing revision, 2026-10-16

Owner selects C2631B/2A/3B/4A: single-firecracker Makeshift audio,20/30/40/60/80 scrap reserve progression, gold/silver compatibility and order changes at next reload. Requests one shared Load Order control, mockup layouts, per-ammo bonus display and mixed-magazine feasibility. Rejects an explosion-completion firing gate; prefers shorter fuse and longer shot delay. [Selections, native/code evidence, inspected layouts and outstanding choices](TEST_FINDINGS_v0.2.51.md#c264--selections-shared-button-layouts-and-timing-revision-2026-10-16). Layout, mixed magazine behavior, exact timing/module treatment and numeric scrap bonuses are proposals. No gameplay patch or acceptance inferred.


## C265 — final correction selections and revised Manage preview, 2026-10-16

**C265 / correction selections settled (2026-10-16).** Shared Load Order header selected with Magazine below equal-width Ammo/Void, Power beside Battery, next-load/type-count feedback and requested manual Reload. One ammo type per magazine retained. Lobber fuse1.25s/base interval5.5s selected with normal speed upgrades and no new timing cap; upgraded shots may overlap prior explosions. Scrap bonuses selected at0/5/10/15%. [Contract, reload safety and touch-tested preview](TEST_FINDINGS_v0.2.51.md#c265--layout-reload-and-final-correction-selections-2026-10-16). No gameplay/install change;0.2.51 remains installed. Corrective implementation precedes retained R4C1 devices.

Owner selects1A/2B/3A without cap/4A and requests Reload. Next-load versus actual next-shot wording and safe reload semantics are recommendations, not claims of shipped functionality. The previous preview failed on the owner's mobile; new emulated touch checks pass, actual app remains unverified.


## C266 — Expansion belongs in Equipment, 2026-10-16

**C266 / final layout correction (2026-10-16).** Expansion belongs in Equipment with Head and Battery/Power. Magazine spans the row beneath equal-width Ammo/Void. Owner still cannot manipulate the preview on mobile; provide a static preview and do not claim touch support is fixed. [Corrected layout](TEST_FINDINGS_v0.2.51.md#c266--expansion-in-equipment-and-mobile-preview-2026-10-16). C265 gameplay selections remain unchanged; installed0.2.51 unchanged.

Owner: "Expansion should be on Equipment. I do prefer that." Reports continued inability to manipulate on mobile, and says the corrected mockup should settle the layout. This supersedes C265 Magazine/Expansion pairing; preserve its other selections. No source patch or installed-build acceptance inferred.


Owner follow-up (2026-10-16): "I like the new design"; corrected C266 layout accepted and patch recap requested. This accepts the design, not installed gameplay or actual mobile interaction. C263-C266 corrective scope is unchanged.


## C269 — owner clarifies fire signal and plate gating, 2026-10-16

**Historical: C270 supersedes the separate gate and aiming-while-OFF interpretation below.**

Owner says Firing requires a fire signal supplied by a pressure plate or Detection; an unpressed connected plate prevents firing while Detection continues aiming. Requests Detection-equipped turrets as signal sources for connected traps. Selects2A subject to this model and3A repeating Poke Floor strikes. [Confirmed semantics, recommended sensor output and remaining empty-target choice](checkpoints/R4C1_CONNECTED_CONTROLS.md#c269-fire-requests-and-firing-permission-2026-10-16). Do not interpret this as selection of C2681A/1B or an OR of all signal sources that lets Detection bypass an OFF plate. No implementation or test acceptance inferred.

## C284 — controller and turret Manage mockups requested, 2026-10-16

Owner requests both menus. [Interactive preview scope, static screenshots and browser verification](checkpoints/R4C1_CONNECTED_CONTROLS.md#c284-paired-controller-and-turret-manage-mockups-2026-10-16). Preserve selected inset panels/shared header and C283 capacities; sample UI values and local simulated actions do not establish game behavior. No further choice or gameplay approval inferred; no source/install/version changes.

## C283 — storage route and all expansion tiers approved, 2026-10-16

Owner selects1A/2A. [Approved complete contract](checkpoints/R4C1_CONNECTED_CONTROLS.md#c283-storage-route-and-full-expansion-progression-approved-2026-10-16): controlled over-capacity real-item storage and native two-hand pickup for turrets/controller, controller capped500, full C282 ammo progression. Replaces controller compartment proposal; full weight and existing ownership/source rules retained. No further scope decisions; technical verification remains. Planning approval recorded without gameplay/test implementation claim.

## C282 — remaining storage/progression choices presented, 2026-10-16

Owner asks what else needs deciding. [Two proposals and complete fixed tier table](checkpoints/R4C1_CONNECTED_CONTROLS.md#c282-remaining-decisions-scoped-to-storage-and-expansion-progression-2026-10-16). Recommend1A controlled real-item storage/heavy pickup for turret/controller (controller retains500), and2A full expansion progression with unchanged no-kit defaults. No selections or new implementation authorization inferred. Established controls choices remain settled; technical verification is not another design gate.

## C281 — Large ammo defaults approved; heavy-storage path clarified, 2026-10-16

Owner accepts C280's default proposals and asks how heavy lifting permits over100 weight. [Approved counts and corrected native evidence](checkpoints/R4C1_CONNECTED_CONTROLS.md#c281-ammo-defaults-approved-controlled-over-capacity-storage-investigation-2026-10-16). Current native AddItem skips room admission; ISEquipHeavyItem uses exact-item server completion/both hands. Recommend investigating a scoped over-capacity real-item transfer path rather than claiming compartments are mandatory. Not proven safe in complete MP/save/carry lifecycle; controller architecture replacement remains to reconcile. No gameplay or test acceptance claim.

## C280 — fixed balance selected; head and firearm estimates, 2026-10-16

Owner selects1B and clarifies this is balancing, not exact programmed endurance. [Fixed reference, source-derived estimates and proposed limits](checkpoints/R4C1_CONNECTED_CONTROLS.md#c280-fixed-balance-selected-and-per-head-ammunition-estimates-2026-10-16). No automatic day-length/RPM capacity scaling. Rounded Large proposals and lower-tier progression remain unselected; no Void removal, battery rebalance or native-weight bypass. Estimates include ordinary reload/cadence and are not runtime acceptance. No gameplay change.

## C279 — eight in-game hours of ammunition, 2026-10-16

Owner requests most turrets sustain eight in-game hours without additional modules besides expansions. [Target, source-derived timing and remaining day-length choice](checkpoints/R4C1_CONNECTED_CONTROLS.md#c279-eight-in-game-hours-of-ammunition-requested-2026-10-16). Large Expansion is the working interpretation; ordinary reloads included, battery/durability separate. Recommend world-day-length-aware capacity; fixed90-minute-day baseline is an alternative, neither selected yet. Current native Apocalypse/bytecode mapping verified; no claimed installed-world setting or heavy-storage feasibility. No gameplay/test change.

## C278 — higher ammo maximum and overweight feedback requested, 2026-10-16

Owner says to increase the maximum with an overweight warning icon and asks for the original Large Expansion amount. [Historical counts and feasibility distinction](checkpoints/R4C1_CONNECTED_CONTROLS.md#c278-increased-ammo-maximum-and-overweight-warning-requested-2026-10-16). Increased physical allowance/weight feedback is the requested direction, but no exact count or Void retirement is approved. Original0.2.18 potato total300; familiar0.2.41 total750; current firearm default900. Current stock getter rechecked: ordinary placed100/carried50 limits remain hard limits, not just warnings. Fetched origin; no gameplay or acceptance change.

## C277 — native heavy carry selected; ordinary capacity questioned, 2026-10-16

Owner selects C2761A and asks about normal turret expansion, Void redundancy and realistic uptime. [Selected pickup rule, verified current defaults and capacity/runtime proposals](checkpoints/R4C1_CONNECTED_CONTROLS.md#c277-heavy-carry-selected-normal-turret-endurance-discussion-2026-10-16). Heavy carrying is selected for controller transport; storage/carry persistence still requires proof. Recommend increasing physical reserves while keeping Void optional; no new ammo limits, Void removal or automatic resupply approved by the question. No implementation/test claim.

## C276 — two-handed heavy carry feasibility question, 2026-10-16

Owner asks whether native fridge-like carrying allows over100 controller weight. [Current Lua/bytecode evidence and1A/1B choices](checkpoints/R4C1_CONNECTED_CONTROLS.md#c276-native-two-handed-heavy-carrying-investigated-2026-10-16): recommend the distinct native heavy-item action when ordinary pickup does not fit; contents retain full weight and forced-drop/lifecycle integration needs proof. Question does not itself select heavy-carry expansion or establish a working five-compartment portable controller. C275 remains selected pending this choice; no gameplay change.

## C275 — 500 capacity and loaded pickup selected, 2026-10-16

Owner selects1A/2B from the capacity/pickup choices:500 nominal total controller storage; allow loaded pickup when the player can carry the controller and contents at full weight, no reduction. [Contract](checkpoints/R4C1_CONNECTED_CONTROLS.md#c275-500-capacity-and-full-weight-loaded-pickup-selected-2026-10-16). Supersedes recommended empty-only pickup; exact-item carry persistence and native limits require implementation verification. No new gameplay/test claim.

## C274 — stockpile plus player transfers; per-head numbering, 2026-10-16

Owner selects1B with direct player-inventory transfers also allowed and asks for storage sufficient for multiple turrets, then selects2B per-head automatic numbering. [Confirmed choices, capacity evidence and proposals](checkpoints/R4C1_CONNECTED_CONTROLS.md#c274-shared-controller-stockpile-and-per-head-numbering-2026-10-16). Recommend500 nominal total across five native compartments;1000 alternative. Neither capacity nor empty-before-pickup recommendation is selected. Correct earlier C230 setter-only conclusion: current native getCapacity caps ordinary containers at100. No gameplay or test acceptance inferred.

## C273 — full controller management and names requested, 2026-10-16

Owner requests all turret Manage functions from the controller, specifically adding/removing modules and changing heads. Requests a top name bar, head-name/count defaults on placement and retention of custom text. [Expanded contract, current adjacency evidence and concrete choices](checkpoints/R4C1_CONNECTED_CONTROLS.md#c273-full-remote-manage-and-turret-names-requested-2026-10-16). Player versus controller inventory and shared versus per-head stable numbering are proposals. No implemented feature or test acceptance inferred; selected plate power/fire behavior is unchanged.

## C272 — controller explanation and menu requested, 2026-10-16

Owner asks for controller purpose and a menu mockup. [Explanation, proposed menu and browser-only verification](checkpoints/R4C1_CONNECTED_CONTROLS.md#c272-controller-purpose-and-menu-proposal-2026-10-16). No new gameplay choice, final art, implementation or test acceptance inferred. Controller management remains separate from direct signal operation and existing device ownership.

## C271 — R4C1 readiness confirmed, 2026-10-16

Owner asks whether more discussion is needed before pressure-plate/control implementation. [Readiness assessment](checkpoints/R4C1_CONNECTED_CONTROLS.md#c271-r4c1-design-readiness-2026-10-16): existing selected controls, recipes/access/lifecycle and C270 power/fire rules suffice for R4C1. Engineering verification remains; do not turn it into more owner design gates. Separate R4C2 Poke Floor balance/recipe is not included or blocking. No source change, installation or test claim in this readiness turn.

## C270 — plate uses the existing Manage power switch, 2026-10-16

Owner corrects the firing-permission interpretation: pressing a plate supplies fire and switches the connected device ON; release switches it OFF, so it does not aim. [Current contract](checkpoints/R4C1_CONNECTED_CONTROLS.md#c270-plate-toggles-actual-device-power-2026-10-16). Replace the separate firing gate with existing device power behavior; keep normal resource accounting and selected repeating Poke Floor. Withdraw C269's default target-presence restriction on external fire requests. Documentation-only clarification, not gameplay implementation or test acceptance.

## C268 — planning resumed; owner test deferred, 2026-10-16

Owner cannot test now and requests resuming planning. No test pass/failure or new gameplay approval is inferred. R4C1 is next; preserve all settled C253-C261 choices. [Three current proposals](checkpoints/R4C1_CONNECTED_CONTROLS.md#c268-planning-resumed-and-next-choices-2026-10-16) address signal-mode scope, safety/rotation wording, and the first R4C2 Poke Floor's held behavior. Recommendations are 1A/2A/3A, not selections. Installed 0.2.52 remains unchanged and pending rendered/connected-client acceptance.

## C267 — correction patch implementation approved, 2026-10-16

Owner: "Approved" following the C263–C266 patch recap and accepted corrected Manage design. This authorizes implementation, verification, local installation and the standing C108 GitHub mirror. **C267 / 0.2.52 corrective patch (2026-10-16).** Owner explicitly approves the C263–C266 recap. Implemented the accepted Equipment/Ammunition layout, shared per-head Load Order, safe manual Reload, next-load/next-shot summaries, eight scrap types and bonuses,20/30/40/60/80 scrap limits, quieter Makeshift blasts,1.25-second Lobber fuse/5.5-second base interval, head reload audio and unwrapped white descriptions except rarity. [Patch](PATCH_v0.2.52.md) | [Verification and short test](TEST_v0.2.52.md). Automated/native checks are recorded separately from pending rendered/connected-client acceptance. R4C1 physical inputs/controller remain next. No Workshop publication or main merge.

Preserve one ammo type per magazine, normal speed upgrades without a detonation gate, private server accounting and pending connected acceptance. The approved work does not include R4C1 physical controls, new recipes or a Workshop upload.


## C314 — Approved Controller corrections and Siphon patch (2026-10-18)

Owner: “Approved to patch.” Authorizes implementation, verification, local installation and the standing development mirror for all settled C310–C313 changes. [Implemented contract](CORRECTIONS_C310.md#c314--patch-approved-and-implemented-2026-10-18). Version 0.2.54 includes Siphon with the exact “shot’s” wording, Synergy-gated secondary refunds, actual rotary pass energy, one half-damage Martyrdom follow-up generation, Grouped Controller, plate/UI/aim/link/swap fixes and LootLab catalog integration. No Workshop upload or merge authorized. Hosted LootLab deployment is pending Cloudflare authentication; playable build verification and installation are independent. See [test record](TEST_v0.2.54.md) for actual evidence and acceptance limits.


## C315 — Siphon rarity and remote input assignment

Owner-approved correction: Legendary Siphon at loaded weight 3; automatic placement assignment of buttons/plates to a writable Controller in range, retaining explicit receiver links and authoritative access rules. [Contract and provenance](CORRECTIONS_C310.md#c315--siphon-rarity-and-automatic-input-assignment-2026-10-18). Official Cloudflare setup and beta cf installation were also explicitly requested.


## C316 — Controller map and connection views under discussion

Owner requests preserving the current menu/Stockpile and discussing map-based connections and a clickable hierarchy, then proposes Inputs/Outputs lists. No implementation approved. [Preserved baseline, native evidence and numbered options](CONTROLLER_MAP_C316.md). Current installed build remains 0.2.54.1.


## C317 — Controller layout direction selected

Owner selects 1B / 2B / 3A: Triggers / Defenses, simultaneous lists beside the map, Grid / Native Map toggle. Stockpile and existing 0.2.54.1 baseline stay preserved. [Contract and concrete preview](CONTROLLER_MAP_C316.md#c317--direction-selected-and-interactive-layout-prepared-2026-10-18). Production implementation is not yet approved at this checkpoint.

## C318 — Visual approved; unique names and Button interaction required

Owner: “I approve the visual,” with compact Connections and head subtitles. Also requests unique turret/trap names, duplicate numbering, first Button #1, left-click activation and a temporary light-switch graphic. [Approval, source audit and next-patch requirements](CONTROLLER_MAP_C316.md#c318--visual-approved-identity-and-button-corrections-2026-10-18). Preview refined and verified; installed 0.2.54.1 remains unchanged. Current source does not yet meet the requested numbering/activation rules. No additional visual approval requested; no native or connected multiplayer test of unimplemented corrections claimed.

## C319 — Taller Controller; right-column details and separated actions

Owner requests Selected Device beneath Stockpile and Connections extended to the bottom, permits additional height, and corrects the mixed Open Manage/Set Aim/View Connections/Unassign row. Restore Controls, Connections, and Access & Assignment groups from the accepted Grouped design. Matching preview input sets list width to 43%. [Updated layout and verification](CONTROLLER_MAP_C316.md#c319--right-column-details-and-restored-action-groups-2026-10-18). Preview and planning only; C318 gameplay corrections remain pending.

## C320 — Details span beneath Map and Stockpile; Connections scrollbar

Owner clarifies that Selected Defense must extend beneath the Map as well as Stockpile, and requests a Connections scrollbar similar to Stockpile. Matching preview input sets list width to 40%. [Corrected layout and scrolling verification](CONTROLLER_MAP_C316.md#c320--details-beneath-map-and-stockpile-scrollable-connections-2026-10-18). Preserve separated groups and all prior gameplay requirements; installed build unchanged.

## C321 — Stockpile to the far right; Map expands above details

Owner moves Stockpile into a full-height right column beside Selected Defense and asks the Map to fill Stockpile's former upper-row space. Connections remains left with its scrollbar; details sit beneath the expanded Map. Preserve separated action groups and all gameplay requirements. [Updated preview and verification](CONTROLLER_MAP_C316.md#c321--full-height-stockpile-on-the-right-wider-map-2026-10-18). Planning only; installed build unchanged.

## C322 — Add resizing to both menus; recap the upcoming patch

Owner requests adjustable Controller and Manage menus that compact/expand safely, including smaller module tiles, then asks for agreement and a recap. Native resize and layout persistence mechanisms are verified in installed source; current menu layouts need geometry-aware reflow. Record readable minima, responsive sections, saved client geometry, retained controls/slots, bounded list scrolling and no per-tick scans. [Contract, evidence and recap](CONTROLLER_MAP_C316.md#c322--resizable-controller-and-turret-manage-menus-2026-10-18). This is a requested patch requirement; no gameplay implementation or runtime acceptance is claimed this turn.

### C323 - Controller map and resizable menus approved (2026-10-18)

Owner explicitly approves C318-C322. See [approved scope](CONTROLLER_MAP_C316.md#c323--implementation-approved-2026-10-18). Installed 0.2.54.1 remains the rollback baseline; approval is not a test result.


C323 implementation note (2026-10-18): 0.2.55 implements the approved map/layout/resize/naming/Button scope. Native Map uses visited-world map data, not live satellite imagery. Compact Controller widths retain the existing attached Stockpile page. Passive traps receive names without adding a signal-receiver contract. Validation/release evidence: [TEST_v0.2.55.md](TEST_v0.2.55.md).

## C324 — Controller error storm, scrollbar correction and in-game map (2026-10-18)

Owner reports freezing/exiting with many errors and a scrollbar in the screen interior, accepts the in-game map as the default/only normal view, then suspects one overloaded CPU core. Continue the approved corrective work without another approval gate. The captured 0.2.55 console contains 454 identical `ControlGraph.update` failures; native dispatch passes the graph itself to a helper expecting its Controller parent. CPU utilization was not captured and the final exit cause is not established. Native deferred-anchor testing also reproduces scrollbar displacement during explicit reflow. Rename the helper, keep section scrollbars in their panels, and remove the Grid toggle/drawing. Preserve existing server-authorized actions and native Stockpile. [Patch](PATCH_v0.2.55.1.md) · [Evidence and acceptance](TEST_v0.2.55.1.md). Record the failed owner test separately from prior automated passes.


## C327 — shared Controller organization approved (2026-10-18)

Owner selects 1A and approves the C326 patch. Shared named groups and device ordering persist per Controller; collapse state stays local. Server checks permissions, identity and revision; stale edits fail instead of overwriting. Row dragging sorts; port/map gestures connect. Full implementation and delivery are documented in [0.2.56](PATCH_v0.2.56.md).


## C328 — owner test and corrective discussion (2026-10-18)

Owner requests strict module ordering, one centered Unavailable label with Expansion guidance, menu alignment/native chrome, map disconnection and finishing a triggered action before automatic power-down. [Audit](CORRECTIONS_C328.md) records confirmed bugs and proposed behavior. Module sorting and lock semantics remain open; no gameplay implementation is claimed or approved by the audit.

## C329 — four-column modules and native keep-open lock (2026-10-19)

Owner response to C328: rejects the 4/8/4 appearance in favor of 4/4/4/4 and chooses 2B. Adopt four centered, aligned rows of four; retain saved module order rather than inventing automatic sorting. Use native-style keep-open locking, distinct from pin/collapse and without overriding reach/access authority. Remaining corrective scope stays in [C328](CORRECTIONS_C328.md). Planning selections only; installed 0.2.56 unchanged. No further design choices required before patch approval.

## C330 — Approved corrective implementation (2026-10-19)

Owner: "Approved." Authorizes C328/C329 fixes, 4/4/4/4 saved-order geometry and native keep-open locking. Implemented as 0.2.56.1; see [patch](PATCH_v0.2.56.1.md) and [test/evidence](TEST_v0.2.56.1.md). No new recipe, loot, damage or permission decision. Installation and standing C108 development mirror follow verification; owner/rendered/connected acceptance stays pending.

## C331 — Testing deferred; existing next checkpoint retained (2026-10-19)

Owner: "Unable to test, what’s the next checkpoint?" No test result or gameplay approval. R4C2 Poke Floor remains next, followed by the separate dart emitter slice. [Status handoff](checkpoints/R4C1_CONNECTED_CONTROLS.md#c331--next-checkpoint-confirmed-while-testing-is-deferred-2026-10-19).

## C332 — Poke Floor content choices requested (2026-10-19)

Owner: "Anything need to be discussed with poke floor?" [R4C2 proposal](checkpoints/R4C2_POKE_FLOOR.md) records seven choices and recommendations. This is discussion authorization only. No new numerical balance, recipe, module host or gameplay implementation is approved; existing pulse/held behavior remains selected.

## C333 — Poke Floor selections; Controller car-battery fallback (2026-10-19)

Owner selects C332 1A/2B/3A/5A/6B, requests an improvised recipe and evaluates Tire Pump substitution. Bed Spikes-style traversal/scratch eligibility must request visible activation before the actual injury. Traps have no modules. Owner adds Controller car batteries, sequential spares and connected-device fallback; Siphon cannot affect the Controller. [Detailed provenance, source findings and remaining choices](checkpoints/R4C2_POKE_FLOOR.md#c333--owner-selections-and-shared-fallback-power-2026-10-19). Do not infer a second injury roll, unlimited stockpile, shared mains coverage or Controller-energy Siphon refund. No new gameplay version or implementation/owner acceptance claim.

## C334 — Self-triggering Poke Floor supersedes external activation (2026-10-19)

Owner selects C333 1A Tire Pump/improvised recipe and 3A local-before-Controller battery priority. Explicitly rejects external/manual Poke Floor activation: it triggers itself. [Updated contract and remaining zombie occupancy choice](checkpoints/R4C2_POKE_FLOOR.md#c334--self-triggering-poke-floor-recipe-and-power-order-selected-2026-10-19). No gameplay implementation or acceptance claim; other signal receivers are unchanged.

## C335 — Poke Floor repeated occupancy selected; turret power idea (2026-10-19)

Owner selects C334 1A repeated zombie occupancy, then tentatively considers requiring turret car batteries rather than building electricity. Repetition is selected; battery-only turret operation is not yet selected or implemented. [Source-backed recommendation, tradeoff and choices](checkpoints/R4C2_POKE_FLOOR.md#c335--repeating-zombie-contact-selected-battery-only-turrets-proposed). Retain Controller fallback, local-before-bank ordering and no Controller Siphon refund. No automatic charging or new power balance is inferred.

## C336 — Optional grid connection module proposed (2026-10-19)

Owner asks whether a module could enable grid connection. [Proposal and choices](checkpoints/R4C2_POKE_FLOOR.md#c336--grid-module-proposal-2026-10-19) combine battery-default turrets with an optional one-slot supply upgrade. Supply scope and rarity/loaded weight remain unselected; no charging, trap module slots, Controller Siphon refund or implementation approval is inferred. Installed 0.2.56.1 remains unchanged.

## C337 — Grid Module mains/generator support and Mythic rarity (2026-10-19)

Owner selects C336 1A and replaces the proposed Epic/Rare rarity with Mythic due to reduced upkeep. [Confirmed design and remaining loaded-weight choice](checkpoints/R4C2_POKE_FLOOR.md#c337--grid-module-mythic-rarity-selected-2026-10-19). Recommend weight 1, not yet numerically approved. No gameplay implementation approval inferred; installed 0.2.56.1 unchanged.

## C338 — Inherit assigned rarity weight; preserve LootLab overrides (2026-10-19)

Owner confirms Grid Module weight 1 and rejects redundant weight decisions. Rarity selection automatically authorizes its assigned weight, unless the owner changes it in LootLab. Preserve those tier/item overrides. [Contract](checkpoints/R4C2_POKE_FLOOR.md#c338--assigned-rarity-weights-confirmed-2026-10-19). Updates C315 process, not gameplay; Grid Module is settled as Mythic / 1.

## C344 — Compact management correction approved and implemented (2026-10-19)

Owner explicitly approves the C342 1A/2A/3A selections and proposed retired-trigger reconciliation. 0.2.57.2 implements native Small-font chrome, narrower balanced Manage, inline Details with a visible-content height minimum, and authoritative removal/restart cleanup without dropping temporarily unloaded links. If the viewport cannot fit Details at all, opening it is refused with an explanatory status; the main controls stay visible. C343 module categories remain a separate undecided proposal. [Patch](PATCH_v0.2.57.2.md) / [tests](TEST_v0.2.57.2.md). Native write/read, all three independent package selections and 25,867 assertions pass. Installed from immutable test/v0.2.57.2 with 308 source and 402 package/install/archive hashes verified; no Workshop upload or merge. Rendered/connected acceptance remains pending. Exact five-second native MP placement remains open.

## C370 — next build approved (2026-10-20)

Owner: “Approved” after clarifying that update/patch approval was the intended checkpoint and no further decisions remained. Proceed with settled Tether, service/condition/timing, Poke 45 and tooltip scope. Lever content details remain unselected and are explicitly excluded rather than invented. [Build contract](PATCH_v0.2.59.md). Implementation/native verification are in progress; installed 0.2.58 remains the rollback baseline until verified tagged installation. No Workshop publication or merge authorized.

C370 delivery: 0.2.59 is implemented and installed from immutable test/v0.2.59 / c376cbb6c912e9aee6c367ac41eac386673161f2. 26,119 assertions, native write/read and all package selections pass; 320 source and 419 installed/archive files match and both prior backups verify. [Release evidence](../diagnostics/v0.2.59/local-release.json). Rendered/connected acceptance is pending. The development mirror follows C108; no merge or Workshop upload.

## C371 — Owner test failure and consumption spectrum proposed (2026-10-20)

Owner reports failed Tether placement/non-flush preview and requests the full OMH consumption spectrum. Read-only native inspection confirms missing local player binding in shared PlacementAction. [Diagnosis, verification gap and actual choices](TETHER_PLACEMENT_C371.md): 1A fixes plus seven fixed bands recommended; 1B placement/alignment first. Labels/cutoffs remain proposed. Test Complete does not approve the next patch; no gameplay/install changes.

## C372 — Room for targeted battery increases (2026-10-20)

Owner asks whether higher consumption is justified for any heads. [Source-based comparison and concrete choices](BATTERY_BALANCE_C349.md#c372--targeted-head-increases-discussed-2026-10-20) recommends 1A Blades/Lobber x1.5; 1B Blades x2 and Lobber x1.5 is the stronger alternative. Other heads, surcharges and saved tuning remain unchanged. Neither selected; C371 scope remains pending. Planning only.

## C389 -- Approval and implementation (2026-10-21)

**C389 / Full targeting and 1C approved (2026-10-21).** Owner confirms "Yea": C388 values and C387 safeguards are approved. Implementing Controller defaults/defense overrides, deliberate player acquisition, shared reduced turret injuries and independent Sandbox multipliers. No further design decision remains. Installed 0.2.60 stays unchanged until verification and tagged installation; connected/rendered acceptance remains pending. [Contract](TARGETING_AUDIT_C386.md#c389--approval-and-implementation-2026-10-21). **Wait for a patch.**

C389 verification: the full approved implementation passes 26,293 assertions, native write/restart and all three independent package startup selections. [0.2.61](PATCH_v0.2.61.md) retains the selected numbers, state persistence and server protection rules. No connected/client-rendered acceptance is claimed. Tagged installation and the C108 mirror follow; no Workshop publication or merge.

C389 delivered: immutable `test/v0.2.61` / `1cf3889e8bf96987627de66a4ed865977927012c` installed with 334 source / 445 package/archive/install hashes and both 0.2.60 backups verified. C108 development mirror follows on the existing branch/PR; no Workshop upload, merge or new live-client acceptance.


## C390 - Owner test audit, sound audition and next-build discussion (2026-10-21)

**C390 / 0.2.61 owner test audited (2026-10-21).** Owner completed an SP session and reports functional progress with remaining presentation, sound, control-list and player-damage issues. [Audit and concrete choices](AUDIT_C390.md) records all findings: screen-overlay tether with no fall phase; white/missing laser beam and requested fixed 10 tiles; Lever mounting/master-enable request; scroll/collapse/clipping/group access; Controller defaults return action; missing/stale tooltips; absent per-head Sandbox grouping/range option; and dynamic rarity art. Native code shows M4 4 limb damage yields about 0.8–1.2 overall-health loss before armour, with no friendly/hostile split. A local sound audition contains 32 choices / 26 distinct native captures; its builder is mirrored, game audio stays local. Proposed choices: **1A native bounded visuals (recommended) / 1B approximate sprites / 1C full physics; 2A hostile 3x damage + 2x wounds (recommended) / 2B 2x + 2x / 2C 4x + 2x**, friendly baseline unchanged; **3A 50-tile radius (recommended) / 3B 40 / 3C 75**, with Sandbox. Multiple Levers proposed as all-ON master gates. These proposals are not new patch approval. Installed 0.2.61 unchanged; live connected PvP remains pending. **Decision needed.**

Owner supplies new Performance/Expansion rarity art and requests automatic consistency with Sandbox rarity. Explicit corrections include fixed laser range, master Lever behavior, compact Connections with Assign to Group, persistent Controller settings access and module removal guidance. User asks for audit and native sound HTML; this authorizes those artifacts, not the next gameplay build. Preserve current tag/install and cumulative Workshop draft. Full source evidence, unresolved rendered feasibility and proposals: [C390 audit](AUDIT_C390.md).
