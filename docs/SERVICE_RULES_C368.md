# C368 — Category service times, single-item repairs and condition retention (2026-10-20)

Owner replaces the preceding service rules. The later explicit category timings supersede the opening general ten-second repair statement:

| Category | Placement | Pickup | Repair |
| --- | --- | --- | --- |
| Traps | 2 seconds | 2 seconds | 4 seconds |
| Buttons, Levers, Pressure Plates | 1 second | 1 second | 2 seconds |
| Turrets and Controllers | 5 seconds | 5 seconds | 10 seconds |

These times are selected at normal game speed and must follow fast-forward. Crafting and reinforcement durations are not placement/repair durations and are not changed by this instruction. Lever and Tether remain planned content and must inherit the appropriate category when integrated. C369 selects Controller 5/5/10 as base equipment (2A).

Repairs consume exactly one item of one material type, except Buttons/Levers/Pressure Plates consume no material. Each repair uses one retained tool; no multi-tool sets. The interpretation of one material plus one retained tool is made explicit in the proposed mapping below. All are full-condition repairs; no skill/XP change was requested. Missing requirements and duration must stay visible through the C367 common tooltip format and match authoritative validation/consumption. C367's other free-repair policy is superseded once these selected rules are implemented.

## Specific repair mapping — selected 1A in C369

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

The next implementation is broad enough to warrant medium reasoning and a focused checkpoint; if the combined integration is estimated above 25 minutes, recommend Fast before starting it. **C369 selects mapping 1A and Controller timing 2A.**


## C369 — Approved mapping and implementation (2026-10-20)

Owner reply: **1A / 2A**. No repair material/tool or Controller timing decision remains. The table above is authoritative. Earlier proposal and audit paragraphs are historical evidence, not current free-repair behavior.

Implemented in source and generated packages, not installed:

- `ControlRepair` holds one profile per device family. Tool tags use installed `ItemTag.HAMMER/PLIERS/WRENCH/SCREWDRIVER`; the tool must have positive condition. Paid repairs select exactly one non-favorited material in the main player inventory. Tool searches include carried containers. Tooltip and action checks use the same policy; final SP/server commit rechecks and consumes the material, removes it from hands, and synchronizes MP removal. Triggers retain their tool without consuming material. No skill or XP change.
- All existing custom repair paths apply that policy. Independent barbed panels require only Pliers for repair; existing attachment/removal tool requirements and support-owned health are unchanged. Turret repair affects its base, not its installed gun.
- Custom pickup/repair actions use 2/4 seconds for traps, 1/2 for Button/Plate, 5/10 for turrets/Controller. SP follows game-speed elapsed time. Native MP service duration is reconstructed from the authoritative device kind. Reinforcement remains ten seconds; recipes/crafting are unchanged. Lever/Tether profiles are staged for integration and are not playable additions.
- `DefenseNames.pack/restore`, which already carries exact-item private recovery metadata, now carries exact health plus item family. Native condition remains a display value; repeated pickup cannot round health upward or repair it. Bed deployment selects the matching ordinal portable input, including mixed fresh/damaged inputs and reverse native callbacks. Barrier and Wire callbacks restore one shared health value for both parts. The private global store persists across saves. Turret private packing is retained; Controller/Poke/trigger packing adds exact `carriedHealth` rather than restoring from rounded item condition. Public item metadata is not authoritative.
- Full-condition-only five-barrier bundle inputs remain restricted. Barbed panel removal still does not return an item. Native firearm repair is unchanged.

Validation: `diagnostics/service-C369.log` records **26,069 assertions**, 256 Kahlua/translation files, 1,117 native translation keys and 27 packet fixtures. Tests exercise exact material counts, missing/broken tools, favorites, client mutation rejection, authoritative removal, cancellation/replay, category timing and SP 1/5/30x fast-forward, repeated 37-HP recovery, native table serialization and mixed Bed inputs. Native server write and fresh-process read pass (`diagnostics/service-C369-native-write.txt`, `diagnostics/service-C369-native-read.txt`). The native fixture verifies reversed mixed Bed callbacks, server repair consumption and intact turret/controller contents. The restart checks the private 13/50 Wire condition before replacing fixture data, plus Poke carried health 123 and Controller redeployment at 37 despite forged public metadata. These are synthetic-square, zero-client probes. Traps-only/Turrets-only dependencies close; all 86 shared files match. No connected player or rendered acceptance is claimed.

### Remaining placement timing work

The installed `zombie.core.BuildAction` bytecode (42.21 JAR SHA-256 `e1a69eb743ede60b213a0fe7f8b83d4fcab773036d256cc4543a336f3b058a33`) computes `(200 - 5 * Carpentry - 50 if Handy) * 20ms`, ignoring recipe and Lua cursor duration. `ISBuildAction:start` uses a separate `createBuildAction` transaction; its client waits for server completion. `BuildAction` has no Lua getDuration callback. Changing only recipe times or the visible bar cannot fix this.

Current source therefore implements category **SP portable placement**, not exact MP placement. This is unfinished original scope, not a new owner decision. The next implementation checkpoint must replace the OMH portable placement transaction with a category-timed authoritative action while preserving native BuildLogic consumption, geometry/permission validation, exact selected items, cancellation and paired-object callbacks; vanilla building/crafting must remain untouched. Validate actual server duration and serialized constructor arguments before installation. Do not describe this checkpoint as complete multiplayer placement support.

Installed version remains the immutable 0.2.58 baseline. C369 is a development source checkpoint; no version bump, test tag, installation, merge or Workshop upload. Tether/Lever integration remains independently unfinished. **Wait for a patch.**


### Validation provenance and limits

- Full validator: **26,069 assertions**, 313 source files and 409 packaged files; package checks pass. Its checkpoint manifest/log were copied to `diagnostics/service-C369-manifest.json` / `service-C369-full-validation.log`; the tracked installed-release 0.2.58 manifest/log were restored unchanged. Source test results do not replace the immutable installed build evidence.
- First native restart attempt failed in the new test fixture: its synthetic Bed pair was left registered from the write run and redeployed at the same coordinates. Production correctly rejected the duplicate. Corrected fixture uses unique locations and retires both temporary records; the saved-condition assertion now runs before creating replacement fixtures. The subsequent fresh-process read passed. Failure log: `diagnostics/service-C369-native-read-fixture-failure.log`.
- Installed `NetTimedAction` calls Lua getDuration then native adjustMaxTime and multiplies by 20ms. Profile values use 50 units/second. Native MP moodle/injury/temperature penalties remain native behavior; timing assertions describe the base duration. Exact category MP **placement** is still not implemented, and no connected player participated.
- No changed game installation, Workshop upload, merge or new release tag. The implementation checkpoint is mirrored on the existing development branch/PR under C108; pending source remains distinct from installed 0.2.58.

## C370 — integrated 0.2.59 implementation (2026-10-20)

Owner approved the next build. [Patch](PATCH_v0.2.59.md) integrates the settled repair rules and replaces portable native BuildAction with an allowlisted shared timed action. Installed native NetTimedAction proves 1,000/2,000/5,000 ms durations and exact serialized constructor arguments; fourteen native deployment recipes consume the selected input references. SP simulation tests cover 1x/5x/30x timing. Worn barriers now pass deployment validation; pack recipes still require full condition to prevent healing through packing.

Native write/fresh-process read pass with private carried condition and mixed independent Bed callbacks preserved. These are zero-client synthetic-world fixtures with real engine objects, not rendered/connected acceptance. Installation is tracked in [TEST_v0.2.59.md](TEST_v0.2.59.md).
