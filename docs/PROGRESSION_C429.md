# C429 - Selected corrections and starting-character progression

**Current direction, C436 (2026-10-23):** owner selects C435 1C: retain current crafting costs, skills, tools, durations and XP; reject the C431 added components and skill increases. The selected manual knowledge gates remain. Ballista/Rotary Blade manuals are Uncommon, Lobber/Firearms Rare, Arc Epic; normal OMHTT containers plus book/magazine sources, no module-pack manuals. Two-point Turret Specialist starts with all five manuals' knowledge. Keep 7% zombie packs, three module/kit rewards and owner tuning. No progression design choice remains; implementation of this plan and prior corrections is outstanding. Installed 0.2.64.4 is unchanged.

2026-10-22. Owner selects C428 **1A / 2A / 3A**, requests a Forward Cone setting for every head instead of the shared default, asks to consider high starting skills and other craftables/mods such as Angry Turrets, then explicitly adds the difficulty/time of leveling each skill.

[Source fingerprints and arithmetic assumptions](evidence/c429-progression.json) retain the reviewed local versions without redistributing third-party source.

## Settled scope

- C428 combined corrective scope and rarity selectors with Disabled/Custom compatibility are selected. Do not request those choices again. Implementation must preserve LootLab tuning and independent Turrets/Traps packages.
- Replace the visible shared Forward Cone control with a control in each head subsection: Rotary Bat, Rotary Blade, Potato Launcher, Scrapshot, Ballista, Arc Emitter, Lobber and Firearms. Preserve existing effective geometry as defaults (Ballista 45; other listed defaults 90); the 360 module still overrides the selected head cone. Rotary uses its existing opposing sweep geometry, which its tooltip must explain. Existing saved shared settings require explicit compatibility handling, not silent reset. Addon head defaults/metadata must still work.
- C428 3A authorizes progression design, not unreviewed numerical recipe/loot changes. Starting professions, traits, alternate recipes, skill training effort, co-op and modded starts are mandatory comparison cases. Do not balance using level numbers alone.
- Corrective selection is separate from approval of new manuals, changed recipe bills or drop probabilities. No gameplay files, assets, version or installation are changed by this research checkpoint. Installed build remains 0.2.64.4; implementation remains outstanding, not claimed complete.

## Actual current starting characters

Evidence: installed 42.21 `media/scripts/generated/characters/character_professions.txt`, `character_traits.txt` and `CharacterCreationProfession:checkXPBoost`. The creation screen adds profession/trait skill boosts and caps the result at ten. The native values below are not copied from a Build 41 guide.

| Start | Relevant starting skills | Effect on current OMHTT progression |
| --- | --- | --- |
| No relevant starting skill | Electrical/Mechanics/Carpentry 0 | Must train before most recipes; wire can still provide an early defense if supplies are found |
| Electrician | Electrical 5 | Already exceeds Controller 3 and Arc 4 electrical requirements, but does not satisfy Arc's Mechanics 2 requirement |
| Electrician + Vehicle Knowledge | Electrical 5 / Mechanics 1 | Poke available after supplies; only one additional Mechanics level needed for Arc/base/Tether skills |
| Mechanic | Mechanics 4 / Welding 1 | Already meets the mechanical side of every current head; Electrical and sometimes Carpentry remain |
| Carpenter | Carpentry 4 plus other bonuses | Basic and reinforced wooden defenses immediately satisfy carpentry requirements; Ballista still needs Mechanics/Electrical |
| Engineer | Electrical 1 / Carpentry 1 / Masonry 1 | Early triggers/wood defenses, with additional training needed for modules, Controller and advanced heads |
| Modded Electrical 8 start | Scenario, not a verified vanilla combination | Passes all current OMHTT electrical gates; other skills, components, power and ammunition still need evaluation |

No native trait in the inspected current definitions adds Electrical. Vanilla Electrician 5 is sufficient to establish the design problem; do not assert a vanilla Electrical 8 build. Archived SOTO files locally inspected alter Electrician to Electrical 2 and add a +1 hobby trait, illustrating that mods can also lower starts. That old archive is not evidence of the owner's active load order or a current public mod version.

Co-op can split building a base, modules and Controller among specialists, and share found materials. It cannot sum two players' skills to satisfy one recipe's combined requirements. A proposed gate must consider cooperative production without incorrectly adding their skill levels together.

Recommendation: preserve the benefit of choosing a specialist. Do not raise every skill above possible starting values or nerf professions. A level-8 character should be skilled; advanced capability should still require appropriate hardware, discovery and operating supplies. No finite skill requirement can preserve a late unlock against an arbitrary modded level-10 start by itself.

## Leveling effort is not equivalent across skills

Current native `PerkFactory` bytecode gives Carpentry, Electrical and Mechanics the same early XP threshold curve: 75, 150, 300 and 750 XP for the first four levels (1,275 cumulative from zero). The AddPerk initializer multiplies its raw 50/100/200/500 values by 1.5. Identical thresholds do not mean identical play time.

Current native `IsoGameCharacter.XP.AddXP` applies a .25 skill acquisition coefficient without a starting bonus, 1.0 with one starting point, 1.33 with two and 1.66 with three or more for these ordinary crafting skills, before other applicable modifiers. A character who trains from zero does not retroactively acquire a profession starting bonus. The current skill-book definitions offer maximum 3x/5x/8x/12x/16x multipliers for the five two-level bands. Book access/read time, learner traits, per-skill/global Sandbox multipliers and modded XP must be included.

| Skill | Current repeatable sources and constraints | Balance implication |
| --- | --- | --- |
| Carpentry | SawLogs awards 5 base XP and yields useful planks. Building/crafts consume wood/fasteners; wooden OMHTT crafts award 10. Specialist starts and books matter. Do not import old furniture-dismantling guides without checking current Sandbox/cutoffs. | Training can overlap directly with making a base and defense materials. Raising it by a level need not impose the same delay as raising Mechanics. |
| Electrical | Small electronics dismantles award 2 base XP; radio/TV device dismantles declare 10. Each destroys an item and requires a screwdriver; searching/carrying items may dominate action time. Crafted electronics and OMHTT recipes add further routes. | Scarce safe salvage and no starting bonus can make Electrical slow, while a specialist begins beyond current gates. A single supposed average training time is misleading. |
| Mechanics | Vehicle access, tools, part requirements and recipes determine available tasks. Successful part-work XP is keyed to item/vehicle/action, with native records expiring after 24 game hours. Failure paths can separately award 1 XP. Higher skill shortens work. OMHTT adds consumptive crafting XP routes. | Available vehicles/parts and repeat limits matter more than just action count. Do not call all vehicle XP strictly once/day, because failure awards differ. |

Fast-forward reduces waiting through eligible actions; it does not supply vehicles, books, safe loot, components or knowledge. A realistic progression model must distinguish active player effort, normal-speed action duration, game-clock waits and scavenging uncertainty. No measured number of real hours to level 4 is claimed here.

### OMHTT's own XP routes

Current base awards: Poke/Tether 20 Mechanics; base 15 Mechanics; Potato 15 Mechanics + 5 Electrical; Makeshift Firing/Detection/Expansion 15 Electrical each; Button/Lever 5 Electrical; Laser 10 Electrical; Controller 20 Electrical; Arc 10 Mechanics + 30 Electrical. These are base awards, not the final adjusted XP received.

For a concrete sensitivity example, an Electrician with the native +1 Mechanics trait needs 150 additional XP to reach Mechanics 2. At normal XP settings, without learner modifiers, each Poke craft's 20 base XP becomes 60 with a fully read beginner Mechanics book. **Three Poke crafts cover that skill gap**; without the book, eight crafts do. This is arithmetic from current definitions, not an observed playthrough. It still requires three/eight consumed tire pumps, the metal/screws/tools, and book discovery/reading for the accelerated case. It demonstrates why OMHTT crafting cannot be omitted from the progression model.

No XP award was found for ordinary pickup/placement/repair/packing paths in the inspected OMHTT action/service code. One-time barrier/bed reinforcement grants 30/15 Carpentry, respectively. Do not call consumptive crafting an infinite free XP exploit: materials are spent, and no zero-cost recovery loop was established. Review award versus ingredient cost before changing it.

## Current vanilla craft comparisons

| Native craft | Skills and discovery | Physical requirements relevant to progression |
| --- | --- | --- |
| Makeshift Radio | Electrical 1, learned recipe, auto-learn at Electrical 6 | Amplifier, Radio Receiver, light bulb, wire, electronics and aluminum |
| Makeshift Walkie Talkie | Electrical 2, learned recipe, auto-learn at Electrical 7 | Amplifier, Radio Receiver, Radio Transmitter, two bulbs, wire, electronics and aluminum |
| Makeshift HAM Radio | Electrical 3, learned recipe, auto-learn at Electrical 8 | Similar dedicated electronics, with higher material quantities |
| Remote Controller V1/V2/V3 | Electrical 2/4/6; learned; auto-learn 8/9/10 | Remote/cordless phone/pager, electronics, glue and tools |
| Current OMHTT Controller | Electrical 3, known from start | Generic metal/electronics/wire/screws |
| Current OMHTT Arc | Electrical 4 + Mechanics 2, known from start | Generic metal/electronics/wire/screws; battery needed to operate |

Important correction to an overly simple magazine argument: the Electrician profession grants the native radio/remote recipes, and high skill can auto-learn several vanilla recipes. Knowledge is not always a permanent vanilla scavenging gate. Adding AutoLearn at Electrical 8 would not solve the owner's level-8 scenario for OMHTT.

Installed `DismantleMiscElectronics` maps Speaker to Amplifier and HomeAlarm to MotionSensor. Parts also occur in procedural loot. Consequently, requiring an amplifier or sensor creates a targeted scavenging objective but does not, by itself, establish a late-game delay. Avoid equating a named component with a rare component.

## Angry Turrets comparison

Inspected the locally installed original Workshop item 2855343540, `mods/AngryTurrets/media/scripts/AT_item.txt`, `AT_EngineerGettingAngry.lua` and its distribution file. This is the original Build 41 implementation, not a claim of working Build 42 compatibility. No third-party code or assets are copied into OMHTT.

- Each normal Pistol/Shotgun/Sniper recipe consumes a compatible firearm, one Motion Sensor, three Electronics Scrap and three Scrap Metal, retaining a wrench/pipe wrench.
- The recipe definitions have NeedToBeLearn true and no explicit SkillRequired field. One magazine teaches all three. The client profession hook gives all three recipes to an Engineer at game start.
- Its useful acquisition constraint is therefore knowledge or profession plus a donor firearm and sensor, rather than a long skill ladder. This is not automatically stricter than OMHTT: our complete powered modular setup costs more generic hardware and has additional operating needs.
- The [author's description](https://steamcommunity.com/workshop/filedetails/?id=2855343540) presents devastating/one-shot-style defenses and an Engineer shortcut. It is a useful design comparison, not an appropriate damage target for OMHTT's selected balance.
- The separate [Angry Turrets Modified author page](https://steamcommunity.com/sharedfiles/filedetails/?id=3199761264) says it replaces normal turrets with infinite-ammunition Titans. That variant is a poor progression benchmark for a resource-based defense mod.

The locally inspected AT_item.txt SHA256 is `3A94CBEF99C7D73759BDE44A59A9DE985537999108CBA5A84995C56D5FEE2345`. Exact current public-version equivalence is not assumed. Workshop pages were read on 2026-10-22; no subscription/download or third-party modification occurred.

## Proposed direction, not a recipe patch

Keep early wood/wire and useful mechanical routes accessible. Preserve current skill requirements as the baseline while comparing actual effort, rather than raising all levels together. Treat available tools, scarce hardware, learned designs, power/ammo and module acquisition as separate parts of progression.

Candidate directions to cost next:

- Controller: receiver/transmitter hardware fits its control role better than just more generic scrap.
- Advanced sensing: a Motion Sensor is an appropriate candidate, but avoid locking every early automatic turret behind an alarm find; the weak Makeshift route should remain useful.
- Arc: salvaged power hardware is more relevant than a random firearm or extra stacks of screws. A car-battery charger is an existing candidate; its opportunity cost is loss of a useful recharge device. It is not assumed rare without examining its source pools.
- Rotary Blade already has two saw blades; Ballista has rope/bars/planks and several skill gates. Evaluate their actual effort before adding unrelated electronics to every head.
- Selected advanced plans can add discovery beyond starting skills, but introduce loot variance and require new-item rarity/weight selection before implementation. Do not give a profession all OMHTT advanced designs or silently auto-learn them at the same high skill we are trying to test.
- Keep rare-module acquisition as a separate balancing axis. Current C428 pack probabilities remain unchanged; high-kill Horde Night and co-op supply must be included in the next numerical comparison.

Recommended choice for the progression proposal: **1A** physical components plus a small number of advanced-design unlocks, with starters still known. Alternative **1B** physical components/operating costs only, accepting that a well-equipped specialist can reach an advanced head early. Skills-only escalation is not recommended.

Selecting this direction does not authorize arbitrary manual rarities, exact replacement recipes or reduced pack chance. The subsequent cost proposal should compare: zero-skill survivor without books; hobby starts with relevant books; vanilla specialists; Electrical 8/modded starts; and co-op specialists. For each, show unmet skill XP, practical acquisition route, full setup bill, ongoing supplies and uncertainty. Corrective 1A/2A choices need no repeat selection.

**C430 update:** the owner selected 1A on 2026-10-23 and requested more discussion. Components plus selected advanced designs is now the chosen direction. Exact manuals, recipes and loot changes remain proposals below; corrective scope is settled and still unimplemented.


## C430 - Components and advanced designs selected; discovery and pack pacing proposed (2026-10-23)

Historical proposal: C431 initially rejected manual unlocks and selected 7% packs. C432 subsequently reopens manuals conditional on a Turret Specialist trait; its options below govern the current discussion.

Owner: "1A / But let's discuss more". This selects C429's physical components plus a small number of advanced-design unlocks, preserving accessible starters. It requests continued discussion, not implementation of unreviewed recipes or loot changes. No new manual rarity, distribution, ingredient quantity, skill requirement, XP award or pack probability has been approved.

### Recommended progression shape

Progression is a set of useful projects and branches, not a guaranteed day-by-day schedule. Early finds and specialist starts should sometimes accelerate it. A discovered firearm can offer an early alternative to custom heads; its ammunition, battery and modules still matter. Learned custom-head designs do not make every firearm or module a late-game item.

- Keep basic/reinforced wood and wire defenses, Poke Floor and Tether Dart Trap known. Their materials, tools, skills and upkeep remain the gates to cost. Making the slower single-target Tether require a lucky book while Poke stays accessible needs a stronger balance reason than technical complexity alone.
- Keep the turret base, Potato, Scrapshot, Rotary Bat, basic triggers and Makeshift modules known. This retains an obtainable first powered defense and a reason to upgrade later.
- Keep Controller and Laser known, but cost appropriate salvaged control/sensing components in the next recipe proposal. The Controller helps manage existing defenses; a mandatory book would delay that management as well as its power/storage benefits. Keep an affordable Makeshift Detection route rather than requiring a real sensor for every first automated turret.
- Put learned designs on selected advanced heads. Retain native profession advantages without granting every advanced design or an automatic Electrical-8 bypass. Skills remain relevant; selection does not approve raising all skill gates.
- Existing native receiver/transmitter/sensor hardware and the candidate battery charger remain component proposals, not approved ingredient changes or proven rare finds. Evaluate current sources and opportunity cost before assigning quantities. No new bespoke crafting-component subsystem is proposed.

### Decision 1: How many advanced designs?

**1A - Two manuals (recommended).** Working groups: Advanced Turret Mechanisms teaches Ballista, Rotary Blade and Lobber; Arc Emitter Schematics teaches Arc. Apply each unlock consistently to its alternate craft routes. This creates two meaningful discoveries and lets ingredients, skills, ammunition and power differentiate the three mechanical heads. It avoids a separate book hunt for every sidegrade. Both manuals belong to Turrets, preserving the standalone Traps package without a cross-package knowledge dependency.

**1B - Four manuals.** One each for Ballista, Rotary Blade, Lobber and Arc. This makes each find more specific and spreads discoveries across more loot, but duplicates become more frustrating and locating the desired design less predictable. It is not automatically a more realistic or better progression curve.

These are knowledge proposals only. Names are working labels; no art request, recipe implementation, chosen manual rarity or public loot publication follows from this record. New items must receive the owner's selected rarity and its assigned loaded weight under C315/C338 before implementation. Exact manual acquisition/distribution and integration with game/packs/Sandbox/LootLab remain to resolve under that contract; do not silently force literature into the existing module reward pool while costing it. Native learning/persistence and independent-package behavior require verification when implemented. Do not promise a guaranteed late-game date from random discovery.

### Decision 2: Zombie module-pack pacing

Current C428 fresh-default math: 15% pack chance per eligible dead zombie, three weighted module/kit selections per pack. That is 45 expected rewards per 100 eligible kills, not 45 unique/useful items and not a guarantee. At 300 eligible kills the expectation is 135 rewards. Horde Night and co-op accelerate the number of opportunities. Better head recipes alone cannot prevent a found firearm from becoming heavily upgraded early.

Propose changing only the fresh default of the existing zombie pack chance, retaining three selections and the selected rarity-weight/LootLab compatibility rules:

| Option | Pack chance | Expected packs / 100 eligible kills | Expected rewards / 100 eligible kills | Expected rewards / 300 eligible kills |
| --- | --- | --- | --- | --- |
| 2A (recommended starting proposal) | 5% | 5 | 15 | 45 |
| 2B (gentler reduction) | 10% | 10 | 30 | 90 |
| 2C (current default) | 15% | 15 | 45 | 135 |

The recommendation is a candidate for owner selection and later play testing, not a demonstrated optimum. It increases the expected number of kill opportunities needed for a particular outcome by roughly threefold versus 15%, while retaining the feeling of opening a pack with three rewards. Container loot and loose finds are separate sources and remain in the total progression model. No calendar/real-hour claim follows from these expectations. Do not change existing saved Sandbox values, individual module weights or owner LootLab tuning on account of this proposal. Module rarity assignment remains a separate feature already selected in C429.

### Next costing and validation

After these choices, consolidate exact recipe bills, manual acquisition/rarities and crafting XP for review rather than silently selecting them. Compare zero-skill survivors, book-equipped hobby starts, vanilla specialists, Electrical-8 modded starts and cooperative supply. Include repeatable OMHTT crafting XP and the different Electrical/Mechanics/Carpentry training opportunities established above. Skill levels are not interchangeable units of effort; do not raise every requirement uniformly.

The current corrective patch scope remains selected and outstanding. This checkpoint changes documentation only: no code/assets, installed version, Workshop changelog, package, test tag or gameplay acceptance result changes. Installed build remains 0.2.64.4. **Decision needed** for C430 1A/1B and 2A/2B/2C; no repeat decision is needed for the C429 direction or corrective scope.


## C431 - Manual unlocks rejected; materials and skills with 7 percent packs (2026-10-23)

Historical decision: the later C432 owner message reopens manuals with a starting-trait alternative. The selected 7% and the unapproved status of the recipe proposal are unchanged.

Owner: "I don't like the book / manual unlock idea. I think we should focus more on the materials and xp to craft. 2 - 7%".

### Settled corrections to the plan

- Remove the proposed OMHTT learned-design/manual/blueprint requirements from the progression plan. Neither the two-manual nor four-manual option remains open. Do not substitute a renamed schematic or research-item gate. Ordinary native skill books and their XP multipliers remain part of the comparison; the owner rejected OMHTT recipe unlocks, not vanilla skill training.
- Focus on useful physical components and required skill levels, considering the different effort needed to gain Electrical, Mechanics and Carpentry XP. Interpret "xp to craft" as qualifying through normal skill progression, not spending XP as a currency. Review XP awarded by crafting as a distinct quantity; no award changes are selected.
- Select **7%** for the existing zombie module-pack default. Retain three weighted rewards per pack. This supersedes all C430 probability options. Preserve existing saved Sandbox values and owner LootLab tier/individual overrides, as in the proposal the owner answered. Do not silently apply the new default to an existing configured save.
- This choice is settled for the pending patch; no repeat numerical approval is required. No change to container loot or the separate Traps-only expansion-kit path is implied.

### Pack expectations at the selected default

For 100 eligible zombie kills: expected packs = 100 * .07 = 7; expected module/kit rewards = 7 * 3 = **21**, versus 45 at the old 15% default. At 300 eligible kills this becomes 21 packs / **63 rewards**, versus 135. That is a 53.33% reduction in expected corpse-pack rewards, with the same per-pack rarity distribution. Repeats are possible, and not every reward is useful. Containers are additional sources. These are expectations, not guaranteed yields or a real-time progression estimate.

### Concrete material and skill proposal, not yet selected

Recommend the following small first adjustment. All omitted ingredients, retained tools, times, alternate recipes and crafting XP remain at the current definitions. The full current bills are in C428; this proposal deliberately specifies complete revised bills for the affected devices.

| Device | Proposed consumed crafting bill | Skill proposal | Base XP award, unchanged |
| --- | --- | --- | --- |
| Arc Emitter | **1 Car Battery Charger**, 2 Small Metal Sheets, 2 Scrap Metal, 8 Electronics Scrap, 4 Electric Wire, 12 Screws | **Electrical 5 / Mechanics 3** recommended, versus current Electrical 4 / Mechanics 2 | Electrical 30 / Mechanics 10 |
| Controller | **1 Radio Receiver and 1 Radio Transmitter**, 2 Small Metal Sheets, 4 Electronics Scrap, 2 Electric Wire, 4 Screws | Electrical 3, unchanged | Electrical 20 |
| Laser Sensor | **1 Motion Sensor**, 2 Electronics Scrap, 1 Small Metal Sheet, 1 Electric Wire, 2 Screws | Electrical 2, unchanged | Electrical 10 |

Bold parts are additions to current bills. The charger is consumed as salvaged power hardware, not retained as a crafting tool; it does not replace the separate charged operating battery. Using it costs a device that could otherwise recharge batteries. No new proprietary component item or subassembly crafting system is proposed. The existing native items are `Base.CarBatteryCharger`, `Base.RadioReceiver`, `Base.RadioTransmitter` and `Base.MotionSensor`; `Base.Receiver` is a different item and must not be silently substituted.

Retain other current recipe requirements/bills and awards for this first adjustment, including wood/wire defenses, Poke, Tether, turret base, starter heads, Makeshift modules and simple triggers. Ballista already combines Carpentry 3 / Mechanics 3 / Electrical 1 and consumes rope/bars/planks; Rotary Blade requires Mechanics 4 / Electrical 2 and two saw blades; Lobber requires Mechanics 3 / Electrical 2 (pump-free alternative Mechanics 4). Their actual materials/ammunition and separate skills provide different routes. Do not raise every recipe uniformly just to exceed profession starting values. Further cost changes require evidence or an explicit new proposal.

Current source rechecked: `OMHTT_TurretHeads.txt` (Arc recipe/tools/XP), `OMHTT_Controls.txt`, `OMHTT_TurretRecipes.txt`, and the remaining craft `SkillRequired`/`xpAward` declarations. No zero-cost service XP exploit has been established, so do not cut crafting awards merely because crafting can train a skill. More hardware per advanced craft already reduces repeated crafting opportunities for a fixed material supply.

### Why Electrical 5 rather than an automatic jump to 6?

C429 current native perk thresholds were rechecked in `PerkFactory` bytecode: cumulative earned XP from zero is 1,275 at level 4, **2,775 at level 5**, and **5,775 at level 6**. The Electrical 5 to 6 step alone needs 3,000 earned XP. These thresholds are distinct from raw action XP; profession/trait starting bonuses, books and Sandbox multipliers change earnings. Do not present the threshold ratio as a measured training-time ratio.

Electrical 5 / Mechanics 3 rewards the native Electrician start while requiring more mechanical proficiency and dedicated hardware than the current Arc. A modded Electrical-8 survivor still needs the other skill and supplies. Electrical 6 is defensible for a stronger training barrier, but the extra grind is especially costly for characters without an Electrical starting bonus. C429's book/starting-skill/co-op comparisons remain mandatory, and no universal calendar unlock is promised.

**1A - Recommended:** accept the three recipe additions above, with Arc at Electrical 5 / Mechanics 3; other recipes and crafting XP remain as stated.

**1B - Stronger Arc training barrier:** same material proposal and other recipes, but Arc requires Electrical 6 / Mechanics 3.

The owner may revise individual materials or skill values; these choices are reviewable proposals, not approval by silence. Selecting one settles this proposed recipe adjustment, not unrelated new tuning.

### Native component availability and implementation limits

Installed current `media/lua/server/Items/ProceduralDistributions.lua` contains charger entries in CarSupplyBatteries (weight 10), CarSupplyTools (4), GarageMechanics (4), GasStoreEmergency (6) and MechanicShelfElectric (6), among other pools. Receiver/transmitter entries occur in ArmyStorageElectronics, EngineerTools and RadioFactoryComponents; sensors occur in EngineerTools, ElectricianTools and SafehouseTraps. Native `DismantleMiscElectronics` maps HomeAlarm to MotionSensor. Pool weights are not spawn percentages and do not establish a fixed number of garage visits or a rare/late-game guarantee. These provide targeted existing acquisition routes without inventing custom rare loot.

When implementing approved recipe changes, check actual usable-item/condition eligibility, retained tools, inventory consumption and independently loaded packages against the current native craft system. Preserve turret/trap pickup condition, existing multiplayer authority and ordinary skill-book behavior. This is a documentation checkpoint only: no gameplay, source/assets, version, package, Workshop changelog, test tag or test result is changed. Installed 0.2.64.4 remains; the already-selected corrective scope and 7% default are pending implementation. **Decision needed** only for this concrete material/skill proposal.


## C432 - Manuals reconsidered with Turret Specialist (2026-10-23)

Later owner message, received during the C431 handoff: "I think I'll take it back. Manuals may be good. But we'd have to add a trait that starts with them as a 'Turret Specialist'".

### Current direction and important tradeoff

- Reopen learned manuals with **Turret Specialist** as an explicit starting-character alternative. The owner supplied the trait name and condition for accepting the manual direction; exact point cost, learned recipes versus physical books and manual grouping were not specified. Do not treat these details as approved.
- C431's rejection is superseded. Materials and normal skill progression still matter; neither this correction nor a future selection of a trait option approves the C431 Arc/Controller/Laser recipe bills or changed Arc skill requirements.
- The selected **7% zombie module-pack default** remains settled, with three rewards and saved settings/LootLab preservation. No repeat probability choice is required.
- A knowledge-granting trait deliberately bypasses manual discovery. Manuals therefore cannot guarantee a late unlock for every character. Appropriate materials, skills and operation remain the constraints for specialist starts, including the owner's Electrical-8 scenario. Do not conceal this exception while calling manuals a universal progression gate.
- Distinguish knowing a design from meeting its craft requirements. Do not add skill levels, starting XP boosts, free tools, batteries, turrets or combat bonuses to the trait without a separate owner selection.

### Decision 1: Proposed trait benefit

Both draft options cost **two character-creation points**, apply to any otherwise eligible profession while Turrets is enabled, and keep the existing skill/material checks. Two points is a balance starting proposal, not a measured optimum. Final value depends on the scope and availability of the manuals.

**1A - Learned recipes at character creation (recommended).** Turret Specialist begins knowing the recipes taught by the eventual OMHTT advanced turret manuals. No physical manuals or equipment are added. Knowledge is personal; the character can still craft finished heads for teammates if qualified and supplied. This supports a co-op crafting role but does not prevent cooperation from accelerating progression.

**1B - Physical manuals in the starting inventory.** The character receives one copy of each eventual advanced turret manual and learns through ordinary reading. These can be shared, traded or recovered from a corpse, so one specialist can teach a whole group and repeated character creation can add more copies. This is a materially broader starting benefit at the same proposed point cost; no silent substitution between this and 1A.

For implementation, use normal native knowledge/trait systems and verify new-character grant, save/reload and connected-client behavior. Do not implement a repeating inventory grant or per-tick scan. Turrets-only and combined packages should expose the trait; Traps-only must remain independent. Custom trait registration, recipe IDs and duplicate grant prevention need native verification. Trait Shop or another addon granting/removing the trait after creation is a separate compatibility case to audit; do not modify the sibling mod or claim runtime acquisition support without a contract. Normal acquired recipe knowledge should be handled by native persistence, not a custom account-wide unlock.

### Decision 2: Manuals taught or supplied

**2A - Two manuals (recommended).** Advanced Turret Mechanisms teaches Ballista, Rotary Blade and Lobber, including corresponding alternate craft routes; Arc Emitter Schematics teaches Arc. Names are working labels. The trait covers both. Keep basic defenses, Poke/Tether, base, starter heads, simple triggers, Controller/Laser and Makeshift modules known by default, subject to their recipe requirements. This limits book-search friction and retains meaningful material/skill differences among the advanced heads.

**2B - Four manuals.** One for Ballista, one Rotary Blade, one Lobber and one Arc. The trait covers all four. More individually targeted discoveries, with more duplicate finds and a less predictable search for the preferred head. This also increases the value of the trait relative to having only two manuals, so reassess the draft point cost with final loot availability.

Neither option adds modules to traps. New manuals still need owner-selected rarities and assigned loaded weights under C315/C338, appropriate acquisition sources and game/Sandbox/LootLab/pack integration review. Do not silently put literature into the existing module-reward pool. Keep those details visible before final implementation approval rather than inventing them from this discussion.

### Current native evidence

Inspected installed 42.21 `media/scripts/generated/characters/character_traits.txt`: `base:mechanics` (Vehicle Knowledge) costs 3, grants Mechanics +1 and Basic/Intermediate Mechanics recipes through `GrantedRecipes`; `base:gardener` costs 2 and grants Farming +1 and recipes; `base:herbalist` costs 4 and grants PlantScavenging +1 and knowledge. These are comparison points, not proof of OMHTT trait balance. A two-point knowledge-only starting proposal is deliberately below the three-point Mechanics-and-recipes trait.

Native `media/lua/shared/TimedActions/ISReadABook.lua`, `complete`, records learned literature on the character and calls native reading/recipe functions. The ordinary reading path shown does not consume the book; physical starting manuals would be reusable unless a new consumption rule were explicitly introduced. No consumption rule is proposed. Native trait definitions demonstrate the recipe-grant pattern, not successful registration or multiplayer validation of the proposed custom trait.

### Handoff

C431 was committed/mirrored before the later correction arrived; C432 must supersede it in the current records and PR rather than rewriting history or dropping the selected 7%. No gameplay/code/assets, version, installation, test result or Workshop changelog changes. Installed build remains 0.2.64.4. The earlier corrective scope remains selected and outstanding. **Decision needed** for trait delivery **1A/1B** and manual grouping **2A/2B**; numerical recipe/material and manual-acquisition proposals remain unapproved.


## C433 - Specialist knowledge and four manuals selected; default-known recipes (2026-10-23)

Owner: "1A / 2B - What's automatically known of the start?". This selects C432's **two-point Turret Specialist**, personal learned recipes at character creation, and **four separate advanced-head manuals**. No physical starting manuals, skill/XP bonuses or free equipment. Do not ask the owner to choose these details again. The trait grants the knowledge from all four selected manuals, including the Lobber's existing alternate recipe, while ordinary crafting qualifications still apply.

### What everyone knows under the selected plan

| Group | Known without an OMHTT manual or the trait |
| --- | --- |
| Traps and barriers | Spike Barrier, Bed Spikes, their Reinforced variants, Barbed Panel, Concertina Wire, Poke Floor and Tether Dart Trap |
| Starter turrets | Turret Base, Potato Launcher Head, Scrapshot Head and Rotary Bat Head |
| Controller and triggers | Controller, Button, Lever, Pressure Plate and Laser Sensor |
| Makeshift modules/kits | Makeshift Firing Module, Makeshift Detection Module and Makeshift Expansion Kit |
| Other crafting/service | Makeshift Bomb, available reinforcement recipes, barrier packing/unpacking, and existing improvised versions of the listed default-known devices |

Knowing a recipe means no knowledge-unlock requirement, not that a zero-skill naked survivor can craft it. Applicable skills, tools and ingredients still apply. Existing native firearms can still be installed as compatible heads without an OMHTT manual; this does not grant native firearm-crafting recipes. Other modules and larger expansion kits keep their current acquisition paths; this list does not create additional craft recipes or add modules to traps.

For ordinary characters, four manuals separately teach Ballista, Rotary Blade, Lobber and Arc Emitter. For Turret Specialist characters, those recipes are already learned at creation. No vanilla profession receives them automatically in addition to this selected trait. Ordinary native skill books remain unaffected.

### Exact source mapping and current-build distinction

Read-only enumeration of `Source/42.20/media/scripts/*.txt` found **33 craftRecipe definitions**, all currently `needToBeLearn = false`. The four selected manuals would gate these five existing recipe definitions:

- Ballista: `OMHTTCraftBallista`.
- Rotary Blade: `OMHTTCraftRotaryBlades`.
- Lobber: `OMHTTCraftLobber` and `OMHTTCraftLobberImprovised`.
- Arc: `OMHTTCraftArc`.

The other **28 existing definitions** remain known without a manual. This count includes alternate recipes and packing; it is not a count of 28 distinct devices. Confirm the real recipe IDs/native knowledge linkage during implementation. No recipe gate or trait has been implemented by this documentation checkpoint; the installed build still knows all 33 recipes.

### Next concrete choice: manual rarity

Four separate manuals already create four distinct searches. Recommend avoiding an additional steep rarity ladder until the material/skill and acquisition-source proposals are costed.

**1A - All four Rare (recommended).** Same rarity for each individual manual; item-specific ingredients, skills and running costs distinguish the advanced heads. Use the owner's loaded Rare weight when implemented (current source anchor default 10), preserving overrides.

**1B - Graduated rarity.** Ballista and Rotary Blade Rare, Lobber Epic, Arc Legendary. Use each assigned loaded tier weight (current source anchor defaults Rare 10, Epic 6, Legendary 3). This further delays particular designs but makes the two-point starting trait more valuable and the Arc search less predictable.

These are unselected rarities, not fixed spawn percentages or approved new weights. The owner-selected tier carries its assigned weight under C315/C338; no redundant numerical confirmation should follow. Acquisition sources and pack integration remain to review; do not silently dilute the existing three-module reward pool with literature. No manual distribution, new custom component, skill threshold, recipe bill or crafting XP award is approved by the current 1A/2B answer.

### Retained scope and handoff

Keep the selected 7% zombie pack default, three rewards, saved owner Sandbox/LootLab tuning and previously selected corrective work. C431's proposed Arc/Controller/Laser ingredients/skills remain proposals. No code/assets, package/version, installation, Workshop notes or test results changed. Installed 0.2.64.4 remains. Documentation links and recipe enumeration are verification of this explanation, not native custom-trait or multiplayer acceptance. **Decision needed** for the new manual-rarity choice; trait benefit/cost/grouping are settled.


## C434 - Lower manual tiers, literature locations and Firearms; native sensor audit (2026-10-23)

Owner: "1B, but knock them down a rarity and let's include them in book locations and gas station magazine areas. We'll also add a firearms manual. Does the makeshift detection module require a motion sensor? Is that native? How hard are they to find?"

### Selected manual changes

Lower C433 1B by exactly one tier:

| Manual | Selected rarity | Existing source-default tier anchor |
| --- | --- | --- |
| Ballista | Uncommon | 14 |
| Rotary Blade | Uncommon | 14 |
| Lobber | Rare | 10 |
| Arc Emitter | Epic | 6 |

These are the existing assigned tier anchors from `sandbox-options.txt`, not invented item weights or drop percentages. At implementation record/apply the owner's actual loaded corresponding tier weights and preserve LootLab/item overrides under C315/C338. The rarity selection authorizes its assigned weight; do not ask again for a separate numerical approval. The previously proposed Rare/Rare/Epic/Legendary set is superseded.

The owner explicitly authorizes book locations and gas-station magazine areas as manual sources. Current native pools/call sites checked: `LibraryBooks`, relevant BookstoreBlueCollar/BookstoreScience literature and home `LivingRoomShelf`; `MagazineRackMixed` is referenced by native `fossoil.shelvesmag` and other magazine racks. Existing generic book/magazine pools can also serve other appropriate businesses/maps. Do not insert manuals into a gas station's fuel/snack/medical inventory just because the building is a gas station. Use applicable native literature pools, with final distribution verification and normal saved-world loot behavior. This does not promise retroactive stocking of already-generated containers.

A fifth **Firearms manual** is requested. Turret Specialist's selected learned-manual benefit should cover it as well, retaining the selected two-point cost and no free skills/gear. Exact Firearms rarity and how its knowledge is checked are proposed below; do not silently introduce native firearm crafting or a new adapter item.

### Firearms manual proposal and decision 1

Existing compatible guns are installed as heads; OMHTT does not have a firearm-head manufacturing recipe. `Firearms.profile` uses supported firearm/reload metadata and `TurretTransfers.rejection` validates transfers. Therefore recommend a manual teaching **mounting supported firearms as turret heads**, rather than pretending it unlocks an existing craft recipe. Include currently supported addon firearms through the existing adapter checks. Ordinary handheld gun use remains native. An already installed gun can still be operated/reloaded/removed by otherwise authorized users; the proposed knowledge requirement is on mounting a gun, not each shot or ordinary servicing. A specialist can still build for teammates, and this is intentional cooperative production.

This would supersede C433's ungated firearm mounting, while retaining the default-known turret base and Potato/Scrapshot/Rotary Bat routes. The current five advanced-head craft definitions remain the manual-gated recipe set; firearms add a separate installation knowledge check. Before implementation verify a native supported knowledge identifier and enforce permission on all applicable authoritative installation paths, with matching UI feedback, rather than only hiding a client menu item. The inspected `TurretTransfers.lua` has an SP guard and is not by itself production multiplayer authority proof. No native feasibility/runtime success is claimed for the new manual gate.

**1A - Firearms manual Uncommon (recommended).** Same assigned tier as Ballista/Rotary Blade; keeps a discovered firearm a reasonably accessible turret route while adding knowledge discovery.

**1B - Firearms manual Rare.** A stronger discovery delay for all supported firearm heads. Both choices refer to the mounting scope above; materials, tools and existing firearm support rules otherwise remain.

### Module-pack inclusion: decision 2

Book/gas-magazine sources are selected. Whether manuals should also occupy the existing module-pack draws remains unresolved. C315/C338 normally includes new loot items in packs; the literature-only choice below explicitly asks the owner to authorize an exception for these manuals, motivated by keeping the selected 7% pack's module/kit rewards intact.

**2A - Literature loot only (recommended).** Manuals spawn in the selected book/magazine sources and have Sandbox/LootLab entries, but do not enter the existing module-pack reward pool. This preserves the module/kit yield used in the earlier 7% arithmetic and keeps manuals an exploration reward.

**2B - Literature loot plus module packs.** Add manuals to existing weighted pack rewards as well. A manual can replace a module/kit reward; the expected 21 total pack rewards per 100 eligible kills remain, but expected module/kit rewards decrease. The tier pool total and item probability model must be recalculated after integrating the manuals. Do not keep quoting the old 33-item/292-weight probabilities for that expanded pool.

No pack dilution or exception is implemented before the owner's choice. No additional pack item or separate custom loot subsystem is proposed.

### Makeshift Detection: current recipe and native sensor facts

Verified `OMHTT_TurretRecipes.txt`, `OMHTTCraftMotionDetectionImprovised`: **no Motion Sensor input**. Requirements are Electrical 2; consume 3 Electronics Scrap, 1 Electric Wire and 2 Duct Tape uses; retain a screwdriver and pliers. It awards 15 base Electrical XP, and is known by default. This is an OMHTT recipe. The earlier proposal to add a sensor concerned the Laser Sensor, not Makeshift Detection, and even that Laser ingredient change is still unapproved.

The component **`Base.MotionSensor` is native**. Installed `generated/items/normal.txt` declares it (Electronics, weight 0.3). Native `generated/recipes/recipes_electrical.txt`, `DismantleMiscElectronics`, accepts the inventory `Base.HomeAlarm` item and a retained screwdriver, maps it to one Motion Sensor, and also outputs Electronics Scrap. The recipe declares no skill or learned-recipe requirement. The Home Alarm item is distinct from the abstract burglar-alarm flag on a building; do not imply every alarmed house offers a removable component.

Actual installed native procedural distribution entries:

- HomeAlarm: ElectronicStoreMisc and StoreShelfElectronics each include weight-20 and weight-10 entries; PoliceEvidence has weight 20; KitchenRandom has weight 0.5.
- Direct MotionSensor: EngineerTools, ElectricianTools and SafehouseTraps each list weight 8. A BombCache1 junk distribution also lists it at weight 1.

These are relative/raw loot entry weights, not percentages. They support targeted electronics-store scavenging and specialized salvage as practical routes; random household searching is much less dependable. A sensor is not justified as an assured endgame rarity solely because it is a named part. Actual availability depends on town, container assignment, loot settings and other mods; no fixed visit/day count or runtime drop-rate measurement is claimed.

Recommendation: keep Makeshift Detection's current sensor-free starter recipe, and retain a real sensor as the proposed Laser ingredient. This answers the question without interpreting it as approval to alter either recipe.

### Scope and handoff

Source checks are read-only. No new items, trait/knowledge gate, distribution entries, source/assets, version/package/install, test result or Workshop changelog changed. Installed 0.2.64.4 remains. Lower tiers, literature locations and adding the fifth manual are selected; Firearms rarity/mounting details, module-pack inclusion and C431 recipe costs/skills remain proposals. Keep prior corrective scope and 7% selection. **Decision needed** for C434 1A/1B and 2A/2B.

## C435 - Firearms Rare; normal container pools and literature; no pack manuals (2026-10-23)

Owner: "1B / 2A - we'll include the other loot pools. It's a manual, that would be found in tool cabinets as well. Let's keep it in our normal loot pool + the magazine / book locations."

### Selected acquisition contract

C434 **1B** selects the Firearms manual at **Rare**, with knowledge required when mounting a supported firearm as a turret head. Existing addon-firearm compatibility checks apply. Ordinary handheld use, firing/reloading/removing an installed head and other authorized servicing remain unchanged. Turret Specialist covers all five manuals at the selected two-point cost; no free skills, gear or physical manuals.

| Manual | Selected rarity | Existing source-default tier anchor |
| --- | --- | --- |
| Ballista | Uncommon | 14 |
| Rotary Blade | Uncommon | 14 |
| Lobber | Rare | 10 |
| Firearms | Rare | 10 |
| Arc Emitter | Epic | 6 |

Use actual loaded corresponding tier weights and preserve owner Sandbox/LootLab overrides. These anchors are relative weights, not percentages. Rarity selection authorizes its assigned weight.

C434 **2A**, with the owner's explicit correction, selects **normal OMHTT container pools plus literature**, while excluding manuals from module packs. This supersedes the proposed literature-only restriction and grants the manual exception to C315's usual pack inclusion. The existing 7% pack default and three module/kit rewards stay selected; adding manuals must not dilute those draws.

Read-only source check, `ControlLootDefinitions.lua`: the 16 normal pools are ElectronicStoreMisc, CrateElectronics, MechanicShelfElectric, ArmyStorageElectronics, ElectricianTools, GunStoreAccessories, ToolCabinetMechanics, GarageTools, CrateTools, ToolStoreTools, ToolStoreMisc, MechanicShelfTools, GarageMechanics, CrateMechanics, ElectronicStoreComputers and ElectronicStoreHAMRadio. Include manuals in this existing container coverage plus appropriate LibraryBooks, bookstore/home literature and MagazineRackMixed sources verified at C434, including native gas-station magazine racks. Do not infer general fuel/snack shelf distribution or retroactive loot in already-generated containers.

Implementation must distinguish catalog visibility, container eligibility and pack eligibility. Current pool subsets must not accidentally filter manuals out, nor should a shared catalog insertion accidentally add them to pack draws. Retain existing container scaling conventions and tuning; no new manual-specific weight multiplier is selected. Game/Sandbox/LootLab integration remains required, and local catalog work is not hosted publication.

### Remaining recipe adjustment, consolidated

Manual tiers, sources, pack exclusion and Specialist benefits need no further choice. C431's three recipe additions remain unapproved. Recommend its modest Electrical 5 / Mechanics 3 Arc requirement; the new manual and consumed charger make the larger Electrical 6 training increase less attractive. Other skills, retained tools, crafting times and XP awards stay as in the C431 table.

- **1A - Recommended:** add one consumed Car Battery Charger to Arc and require Electrical 5 / Mechanics 3; add one Radio Receiver plus one Radio Transmitter to Controller; add one Motion Sensor to Laser.
- **1B - Stronger Arc skill gate:** the same three ingredient additions, but Arc requires Electrical 6 / Mechanics 3.
- **1C - Keep current recipes:** no new ingredients or skill increases; retain the selected manuals, trait and loot changes.

All additions are on top of existing recipe bills. Makeshift Detection remains unchanged and sensor-free under every option. These are concrete choices for the outstanding recipe proposal, not an inference that today's 1B authorizes C431's unrelated 1B.

### Verification and handoff

Documentation-only selection. No source/assets, version/package/install, Workshop notes or test-result changes. No custom knowledge, distribution, trait or multiplayer runtime validation claimed. Prior corrective scope remains selected and unimplemented. Installed 0.2.64.4 remains. Check documentation links and mirror under C108/C119. **Decision needed** for the recipe choice above; no manual decision is outstanding.

## C436 - Current crafting costs and skills retained; progression design settled (2026-10-23)

Owner: "1C". This explicitly selects C435's keep-current-recipes option while retaining the selected manuals, trait and loot changes.

- Keep all current consumed ingredients, retained tools, required skill levels, crafting times and XP awards. Arc remains Electrical 4 / Mechanics 2; Controller remains Electrical 3; Laser remains Electrical 2.
- Reject C431's additional consumed Car Battery Charger for Arc, Radio Receiver/Radio Transmitter for Controller and Motion Sensor for Laser. Reject both proposed Arc skill increases. These are no longer pending decisions. Makeshift Detection stays sensor-free.
- "Keep current recipes" refers to costs, skills and crafting behavior, not removing the separately selected knowledge requirements. The five advanced-head craft definitions still gain their manual gates; firearms mounting retains its selected knowledge gate and existing supported-gun checks. Do not gate ordinary handheld use or installed-head firing/reloading/removal.
- Retain the five manual rarities and assigned loaded weights: Ballista/Blade Uncommon, Lobber/Firearms Rare, Arc Epic, preserving owner overrides. Existing OMHTT container pools plus literature/gas-station magazine racks are selected; module packs exclude manuals.
- Retain two-point Turret Specialist with personal learned knowledge from all five manuals at creation, no physical manuals/gear/skills/XP bonus. Keep the selected 7% zombie pack default and three module/kit rewards; preserve saved tuning.
- Native skill/material costs, alternative recipes and service behavior are not rebalanced by this selection. Discovery is bypassable through the paid starting trait and cooperative production; do not portray advanced equipment as guaranteed late-game progression.
- C428/C429 corrective scope remains selected and outstanding. No additional design questionnaire or repeat selection is needed. Native implementation, persistence/package checks and player acceptance remain work, not assumed successes.

Documentation-only checkpoint: no source/assets, version/package/install, Workshop changelog or test-result changes. Installed 0.2.64.4 remains. C108/C119 documentation mirror required. **Wait for a patch**; no new build or background implementation is claimed by this record.
