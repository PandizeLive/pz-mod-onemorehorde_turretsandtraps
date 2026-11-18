# C367 — Repair requirements and presentation audit (2026-10-20)

**C368 update:** The costs/times below document the audited implementation, not the new selected rules. [Category service rules and condition audit](SERVICE_RULES_C368.md) supersede them for the next patch: traps 2/2/4 seconds, triggers 1/1/2, turrets 5/5/10, one material except tool-only triggers, one retained tool. Material/tool identities and Controller classification await the listed choices.

Owner selects C366 repair **1A** (one Scrap Metal for Tether), revises Tether to 30 impact damage plus 15 pull damage after a 0.75-second hold, lowers Poke Floor to 45 damage, and requests a complete repair audit with uniform requirements presentation. This is not approval to replace every existing free repair with a material cost.

## Actual repair paths

All existing OMHTT repair actions below restore full condition, grant no repair XP and require no skill level. Durations are seconds at normal game speed; the existing timed actions follow game-speed changes. Materials are consumed at successful authoritative completion, not when opening the menu.

| Repair target | Consumed | Retained tools | Time | Existing UI before this correction |
| --- | --- | --- | --- | --- |
| Spike Barrier, basic/reinforced | None | None | 10 s | Duration only |
| Bed Spikes, basic/reinforced, selected tile | None | None | 10 s | No repair-entry tooltip; inventory description mentions free service |
| Concertina Wire | None | None | 10 s | Free service explained on removal, not Repair |
| Barbed Panel with independent condition | None | Usable Hammer + Pliers; carried bags accepted | 10 s | Repair disabled for missing tools; requirements only on removal |
| Turret base, any head | None | None | 10 s | SP duration only; MP no repair tooltip |
| Controller, Button, Pressure Plate | None | None | 10 s | No repair tooltip; option appears when damaged |
| Poke Floor | 2 Scrap Metal | None | 10 s | Material cost embedded in button; missing time/prerequisites |
| Tether Dart Trap, selected but not integrated | 1 Scrap Metal | Screwdriver, Pliers, Wrench/Pipe Wrench | 5 s | No playable device/menu yet |

Sources reviewed: `BarrierService`/`BarrierServiceAction`, `BedService`/`BedServiceAction`, `BarbService`/`BarbSupport`/`BarbServiceAction`, `TurretWorld.repair`/`TurretPickupAction`, `ControlAction`, `ControlPokeAction`, and every client Repair option. Repository-wide repair/fixing and health-write searches found no additional custom repair recipes.

Exceptions matter:

- Panels sharing a supporting structure's health do not offer independent OMHTT Repair. Repair the backing through its own supported game/mod mechanics; OMHTT must not promise every backing type has a repair action.
- A turret repair restores the base, not its firearm. Native firearms retain native/mod-provided inventory repair rules. Installed game `media/scripts/generated/fixing.txt` includes separate gun fixers (for example pistol plus Aiming 3); this audit does not replace those external rules or infer every modded gun is repairable.
- OMHTT modules, expansion kits and custom heads have no separate OMHTT repair recipe/action. Battery charge is replenishment, not this repair system.
- Poke must be disarmed, retracted and directly reachable, with write access. Scrap selection currently accepts only non-favorited `Base.ScrapMetal` loose in the main inventory, not scrap substitutes, bags or the Controller stockpile. The tooltip now states that exact limitation. Changing supply sources is separate from displaying them honestly.
- Other existing proximity, ownership, health and tool guards remain in their authoritative actions. Free repair costs were not changed as part of this UI audit.

## Implemented in source and generated packages

One shared requirements/duration catalog and one native repair-tooltip formatter cover every existing custom Repair entry, including the SP and MP turret menus. Every tooltip shows materials consumed (explicitly None where free), retained tools, skill requirement, duration and result. Poke shows eligible/required scrap counts, disarm/retraction/access and material-source requirements. Barbed Panels explain missing usable tools. Turret result text explicitly limits repair to the base. Poke's label is now simply Repair, matching the other entries.

Poke's authoritative item selection and its tooltip use the same selector; action constructors take the catalog's unchanged durations. Tooltip work happens when creating the context menu, not on a new update loop. Server completion still revalidates current inputs. Both independent packages include the helper modules; no new network arguments or mutation authority are introduced.

Poke damage default and runtime fallback are **45**. Explicit saved Sandbox overrides remain unchanged, including a saved value of 50; changing the default does not overwrite player tuning. Its 1.5-second repeat and multi-target strike remain, giving an ideal 30 DPS per continuously present zombie.

## Tether combat revision, selected and pending integration

Tether now deals **30 on outbound impact**, remains embedded **0.75 seconds**, then deals **15 once on pull to that same still-valid living zombie**. No damage to another victim on return, no piercing, AoE, immobilization or knockdown. Existing normal player-collision injury remains a single trap injury, not silently expanded into a second player wound. A dead/missing victim cannot award a second hit or kill; this needs authoritative victim tracking and hold presentation in the actual integrated trap.

Retain six-tile reach, 12 tiles/s outward, four returning, 0.4-second reset, 100 condition, one wear per completed cycle, four weight and the selected craft recipe. A successful cycle's ideal duration is `1.15 + d/3` seconds: roughly 1.48/2.15/3.15 seconds and 30.3/20.9/14.3 DPS at 1/3/6 tiles of travel. This is modest single-target sustained output, with useful 45-damage bursts, not a guaranteed very slow point-blank cycle. Misses do not embed in a target and retain the no-hold 2.4-second maximum-distance cycle. Motion, interruptions, collision and scheduling affect actual results. No integrated hold/pull runtime acceptance is claimed by the repair tests.

## Verification and delivery limits

- Installed Kahlua suite: **25,945 assertions passed**, including eligible scrap counts/exclusions/capping, Poke action/tooltip exact-item agreement, all repair profiles, missing-tool explanation, disabled-option tooltip binding and existing timing/authority fixtures.
- **256** runtime/translation files compile; native JSON loads **1,111** translation keys; existing 27 packet fixtures pass. Raw local output: `diagnostics/repair-C367.log`.
- Package dependency closure and independent selection checks pass: 25 reviewed optional dependencies, 169 unique Sandbox options, 86 identical shared files.
- Initial added test exposed that the harness had not loaded `ControlPokeAction`. Registered it explicitly, then reran successfully. This was a test-harness failure, not an observed game crash. Existing native Guid-table fixture warnings remain.
- Source/UI call-site audit covers all seven menu files. Rendered tooltips and connected-client acceptance remain pending; test doubles do not establish those results.

Installed immutable 0.2.58 remains unchanged. This source checkpoint and C365 tooltip correction await the integrated gameplay patch; no retag, Workshop upload or live LootLab change. Tether's revised combat is recorded, but full device/lifecycle/render/network integration remains unfinished. No further repair-cost selection is required. **Wait for a patch.**
