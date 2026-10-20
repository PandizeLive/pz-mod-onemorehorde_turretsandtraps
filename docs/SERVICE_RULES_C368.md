# C368 — Category service times, single-item repairs and condition retention (2026-10-20)

Owner replaces the preceding service rules. The later explicit category timings supersede the opening general ten-second repair statement:

| Category | Placement | Pickup | Repair |
| --- | --- | --- | --- |
| Traps | 2 seconds | 2 seconds | 4 seconds |
| Buttons, Levers, Pressure Plates | 1 second | 1 second | 2 seconds |
| Turrets | 5 seconds | 5 seconds | 10 seconds |

These times are selected at normal game speed and must follow fast-forward. Crafting and reinforcement durations are not placement/repair durations and are not changed by this instruction. Lever and Tether remain planned content and must inherit the appropriate category when integrated. Controller classification is not explicitly supplied; recommend retaining 5/5/10 as base equipment, with the separate choice below.

Repairs consume exactly one item of one material type, except Buttons/Levers/Pressure Plates consume no material. Each repair uses one retained tool; no multi-tool sets. The interpretation of one material plus one retained tool is made explicit in the proposed mapping below. All are full-condition repairs; no skill/XP change was requested. Missing requirements and duration must stay visible through the C367 common tooltip format and match authoritative validation/consumption. C367's other free-repair policy is superseded once these selected rules are implemented.

## Specific repair mapping — proposed, not silently selected

| Target | Consumed item | One retained tool |
| --- | --- | --- |
| Spike Barriers and Bed Spikes, including reinforced versions | 1 Plank | Hammer |
| Concertina Wire and independent Barbed Panels | 1 Scrap Metal | Pliers |
| Poke Floor | 1 Scrap Metal | Wrench |
| Tether Dart Trap | 1 Scrap Metal | Pliers |
| Turret base | 1 Scrap Metal | Wrench |
| Controller | 1 Scrap Metal | Screwdriver |
| Button | None | Screwdriver |
| Lever | None | Wrench |
| Pressure Plate | None | Screwdriver |

- **1A (recommended):** use the material/tool mapping above. Wood defenses use a common wood repair item; metal mechanisms use scrap, and tools match the mechanism. Tether loses its earlier three-tool requirement.
- **1B:** use one Scrap Metal and one Wrench for every material-consuming repair; retain the three trigger tool assignments above. Easier supply standardization, less natural for wooden defenses and wire.

Controller timing:

- **2A (recommended):** retain 5-second placement/pickup and 10-second repair as base equipment.
- **2B:** use trap timings: 2-second placement/pickup and 4-second repair.

These are clarification of unspecified item identities and Controller classification, not a request to reapprove the explicit timings, one-item rule or condition retention.

## Condition audit and required correction

Source inspection confirms the pickup/redeployment loophole rather than assuming all devices already preserve condition:

- **Spike Barriers:** `BarrierService.apply(Pickup)` creates a fresh item and packs its name, but not health. `BarrierFootprint.adoptBuild` initializes full condition. Both basic and reinforced routes need retention.
- **Bed Spikes:** `BedService.apply(Pickup)` likewise creates a fresh named item; `BedSpikes.onCreate` explicitly resets to maximum health. Two consumed tiles must retain their separate conditions, including mixed fresh/damaged inputs and either placement order.
- **Concertina Wire:** `BarbService.apply(Remove)` creates a fresh item; `BarbSections.onWireCreate` creates the paired record with 50 health. Both world halves must restore the same recovered wire condition, not each consume a separate stored value.
- **Barbed Panels:** removal currently returns no item, so that operation supplies no pickup/redeploy shortcut. Do not add material recovery or repair host-shared panels independently as part of this correction. Their backing structure owns shared condition.
- **Turrets:** `TurretWorld.pickup` copies exact state; SP deployment imports it and server deployment imports the private `TurretAuthority.packed` record. Preserve that authoritative path rather than replace it with item-condition rounding.
- **Controller, Button, Pressure Plate and Poke:** `ControlWorld.pickup/created` round through native inventory condition. This generally loses precision rather than healing; preserve exact condition without client-authored authority or cumulative rounding. Keep contents, charge, names and permission behavior intact.
- **Five-barrier bundles:** `Construction.portableInputAllowed` already rejects damaged individual barrier inputs. Keep this full-condition-only restriction until a future bundle design explicitly preserves each member; do not loosen it into an alternate healing route. Normal damaged portable placement must remain possible.

Retention must survive inventory/stockpile transfers, save/load and repeated pickup/place. Only actual repair restores condition; moving a damaged item never heals it. Use authoritative per-item state and exact consumed-item identity in MP. Reject invalid/stale item reuse and do not trust client tooltip/modData as proof of health. Existing names-only state in `DefenseNames.pack/restore` is not sufficient. Preserve destroyed-item handling and native firearms' separate repair rules.

## Implementation and validation boundary

This turn records the selected rule changes and source audit. Gameplay files and installed 0.2.58 remain unchanged; no test pass for the new timings/retention is claimed. C367's 25,945 assertions describe the prior source checkpoint only.

The existing SP `PlacementTiming.apply` hardcodes five seconds and returns on clients. Native `ISBuildAction` clients wait for server action completion (`maxTime = -1`). Updating only the SP cursor would not fulfill multiplayer placement timing. Implement and verify the server/native construction duration path alongside SP; keep unrelated vanilla crafting/building unchanged.

Focused patch validation: interrupted/missing-material repairs consume nothing; successful repairs consume exactly one allowed item and retain one usable tool; all category action times at normal speed and fast-forward; server-authoritative requirement checks; mixed-condition paired Bed placements; shared wire halves; repeated pickup/place/save/load without increased health; intact turret/controller contents and battery charge; and independent Traps/Turrets packages. Rendered and connected-client evidence must remain distinct from fixture tests.

The next implementation is broad enough to warrant medium reasoning and a focused checkpoint; if the combined integration is estimated above 25 minutes, recommend Fast before starting it. **Decision needed: mapping 1A/B and Controller timing 2A/B.**
