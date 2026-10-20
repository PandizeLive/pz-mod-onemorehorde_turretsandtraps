# R4C2 — Tether Dart Trap

## C364 — Tether Dart Trap selected; prototype retired (2026-10-20)

Owner selects C363 **1B / 2A**: damage only, no retraction knockdown; zombie-only autonomous sensing with first-hit player collateral. Owner names the device **Tether Dart Trap**, specifies a placed wall panel with four cardinal placement directions, reports the prototype worked, requests removing the separate debug mod and using its tether mechanic in the actual trap. This authorizes integration; it does not choose the still-unset tuning or crafting costs. One placement shoots one nail away from its supporting wall, not four simultaneous shots. Native and player-built walls remain required. Existing no-ammo/no-battery/no-modules and trigger override rules are unchanged.

### Owner test and cleanup

The captured console loads `OMHTT_TetherPrototype`, runs alongside 0.2.58, and records 13 zombie impact events. Owner reports success; do not infer specific occlusion, every zoom level, or connected multiplayer acceptance. No tether exception is present in the inspected console; unrelated Firearms translation and stock map warnings remain. Raw capture stays local at `diagnostics/tether-trap-C364/owner-console.txt`; its digest and scoped findings are in `diagnostics/tether-trap-C364/owner-test.json`.

The installed directory `C:/Users/bandi/Zomboid/mods/OMHTT_TetherPrototype` was resolved and all six files verified against C362 install hashes, then moved outside the game's mods directory to project-local `diagnostics/tether-cycle/retired-installed-C364`. Removal verified; retirement evidence is `diagnostics/tether-cycle/retirement-C364.json`. No existing gameplay mod or save was modified. A save that still lists the debug mod must have that entry disabled before loading; loaded Lua does not disappear from an already-running session. Frozen prototype source remains solely as regression/reference tooling, not an installed selectable mod.

### Implemented preparatory integration, not a playable release

- `Source/.../shared/OMHTT/TetherCycle.lua` ports the tested launch/retract/reset engine into Traps, requires explicit tuning instead of promoting fixture defaults, and validates cardinal directions and persistent Controller-style IDs in ordered network snapshots.
- `TetherLane.lua` adds first-hit native player collision, excludes protected/dead/floor actors, and keeps autonomous detection zombie-only. It selects a collision; actual injury settlement is not yet wired.
- `TetherMount.lua` resolves all four native build faces through existing wall geometry, requires a real map/player-built wall, and derives the muzzle on the outward side. Floors alone, missing supports and destroyed constructed walls are rejected. This is the checked geometry adapter, not a newly playable Building entry.
- Generated Traps content contains the three modules; Turrets contains none. No event hooks, craft/loot items, damage application, live Controller receiver registration or placement route are activated. Actual world-item lifecycle, Controller wiring, damage/injury settlement and visual bootstrap remain implementation work for the integrated patch. Main installed build remains 0.2.58; no new gameplay tag/install or Workshop changes.

Native 42.21 run: **32 new assertions plus 41 existing prototype assertions pass**, 48.2 seconds, zero connected clients. Real IsoPlayer/IsoZombie/IsoObject/IsoThumpable/IsoGridSquare fixtures verify collateral and four wall faces; cell lookup is isolated. Existing renderer compiles; this does not prove a newly integrated renderer or connected authority. Report and exact source hashes: `diagnostics/tether-trap-C364/result.json`. First attempts exposed fixture mistakes (God-mode capability gate and lowercase native PropertyContainer.set); corrected using current API signatures and rerun successfully. No production error is inferred from those fixture failures.

Package closure/independence verification passes after updating its stale optional turret-only call-site inventory and pressure-plate sprite normalization. These changes repair the test's expectations, not gameplay. Report: `diagnostics/tether-trap-C364/package-static.json`. Generated/source modules match; banned-call/style and no-auto-activation checks pass. Full gameplay/persistence/connected acceptance is still pending.

### Remaining content choices — proposals only

Review before packaging the gameplay integration. The project's crafting rule requires explicit ingredients/tools/skills/XP review. No second approval of the selected name, tether mechanic, wall-facing behavior or collateral policy is requested.

**1 — Starting tuning**

- **1A (recommended):** 35 zombie damage, six-tile maximum reach; preserve the tested travel speeds (12 tiles/second outbound, four returning) and 0.4-second reset, giving about 2.4 active seconds for a maximum-distance miss and faster cycles for nearer impacts. 100 condition, one wear per completed cycle including misses, four weight. Normal trap scratch treatment for a player hit, never knockdown or return damage. Five-second placement/pickup and five-second tool-assisted full repair with no consumed repair materials. These are proposed gameplay defaults, not accepted values from the no-damage fixture.
- **1B:** the same package with 50 zombie damage, making reusable ranged coverage stronger. No second item/variant.

**2 — Mechanical crafting**

Common proposed recipe: two Small Metal Sheets, one Metal Bar for the reusable dart, one Rope, four Screws and two uses of Wire; retain Screwdriver, Pliers and Wrench/Pipe Wrench. One crafted trap, 30 active seconds; no camera, electrical skill, battery, consumable ammo or loot rarity. Assembly/repair tools are the same retained tools. This remains a mechanical abstraction, not a claim that the recipe models a working physical winch.

- **2A (recommended):** Mechanics 2; award 20 Mechanics XP on crafting only.
- **2B:** Mechanics 1; award 10 Mechanics XP, with the same materials/tools.

Crafted-only proposal avoids inventing a loot rarity/weight; future loot inclusion requires owner rarity selection. Tuning and recipe choices remain unselected. The geometry/collision/cycle port and requested debug cleanup are completed; the gameplay release is not. **Decision needed: new 1A/B and 2A/B choices.**

## C363 — Next checkpoint and combat choices (2026-10-20)

Owner asks what comes next after the isolated prototype installation. Recommend continuing R4C2 into a real wall-mounted retractable trap: native/player-built wall placement, Controller receiver integration, persistence, and a complete launch/first-hit/return/reset cycle. Lever remains queued; beam sensors follow the emitter. No new implementation is authorized by this question. Prototype rendered/occlusion and live connected-client checks remain pending; deferred owner testing does not block approved independent work. The main installed build remains 0.2.58 and the separate debug prototype remains 0.0.1.

Settle these two combat rules first; neither is selected:

- **1A (recommended):** one 25% knockdown roll on the struck, still-valid living zombie when retraction starts, with five-second protection from another emitter knockdown. No return damage or zombie dragging. Proposed tuning, not a tested balance result; reuse/verify authoritative reaction routing before shipping.
- **1B:** damage only, no retraction knockdown for the initial integrated trap.
- **2A (recommended):** autonomous sensing detects zombies, but a player crossing the outbound nail can be the first collision and receive the existing trap-style injury treatment. The nail stops there; no player knockdown. Detection does not grant a projectile the ability to pass through a player. Clearly communicate the firing lane. Exact injury integration must be verified in both packages/MP.
- **2B:** zombies-only collision/damage; players neither activate autonomous sensing nor obstruct the nail. Safer around base traffic, less consistent with physical first-hit behavior.

The proposed 25%/five-second values are new suggestions, not inherited fixture settings or approval. These choices do not authorize recipes or silently select the remaining damage/range/cycle/wear tuning. Keep the existing requirement to review the full combat and crafting package before gameplay implementation. No code, tests, installed files, version or changelog changed. **Decision needed: 1A/B and 2A/B.**

## C362 — Prototype installation approved and verified (2026-10-20)

Owner approves local installation. The separate no-damage debug prototype 0.0.1 is installed; six file hashes match the C361 native-tested source. No existing gameplay packages or saves changed, and save activation remains manual. [Install evidence and five-step owner test](../TETHER_PROTOTYPE_C361.md#c362--owner-approved-local-installation-2026-10-20). This is not full R4C2 integration or rendered/multiplayer acceptance. **Test now.**

## C361 — Scripted prototype selected and implemented (2026-10-20)

Owner selects C360 **1A**, approving the scripted prototype. The isolated `tools/prototypes/tether` package now implements authoritative first-hit launch/retract/reset, corrected default-detection/input override and interpolated client tether visuals. No native vehicle workaround, health damage, recipe, final stats or knockdown. [Scope, native tests and pending rendered/connected checkpoint](../TETHER_PROTOTYPE_C361.md): 41 assertions pass; client renderer compiles; exact-source preview ZIP prepared. This is not a gameplay release or proof of GPU/live multiplayer acceptance. Installed 0.2.58 unchanged. **Wait for a patch.**

## C360 — Physical tether investigated (2026-10-20)

Owner selects C359 **1B**, asks us to investigate directly, and conditionally authorizes the physical implementation if feasible. The nail-as-hitched-vehicle suggestion is a hypothesis, not an accepted implementation. [Current-bytecode and isolated-runtime findings](../TETHER_FEASIBILITY_C360.md) verify access to vehicle towing but do not establish a maintainable retractable trap. The ordinary Lua surface lacks direct Bullet access and no winch setter was found; both endpoints are vehicles with vehicle persistence/collision/simulation ownership. A physical swing, rendered nail or connected-client tether has not been tested.

Recommend against shipping a nail-shaped vehicle workaround. **1A:** scripted launch/retract prototype (recommended). **1B:** defer the retractable trap. Neither fallback is selected; do not silently substitute scripted behavior for this request. C358 single-nail and detection/input rules remain selected; knockdown is still TBD. 0.2.58 unchanged. **Decision needed.**

## C359 — Tether feasibility review (2026-10-20)

Owner asks whether the tethered nail is physically possible in Zomboid. Read-only source/API evidence supports a scripted launch/impact/retraction mechanic as a feasible implementation approach, not a tested finished tether. Do not promise native rope physics or claim the engine has no rope constraints.

Verified against the installed projectzomboid.jar using JDK 17 javap: zombie.core.physics.Bullet declares addRopeConstraint(int,int,float,float,float,float,float,float,float); BaseVehicle bytecode calls it and stores constraintTowing. The matching historical 42.20.2 BaseVehicle.java (~10124) shows vehicle IDs and towing attachment points. This verifies vehicle towing support, not a supported Lua API for attaching an arbitrary trap/nail to a living zombie. No Bullet class entry was found in the inspected LuaManager$Exposer bytecode; this is a scoped negative finding, not proof all access is impossible. Public Bullet Javadocs returned 404, so local installed bytecode is the primary evidence.

Existing Source/42.20/media/lua/client/OMHTT/PrototypeEffects.lua (~162-180) interpolates projectile travel and draws a spear/shot line. shared/OMHTT/DefenseLine.lua checks bounded same-floor obstruction; shared/OMHTT/DefenseMotion.lua has authority-routed knockdown. These provide foundations, not full first-hit collision, cable occlusion, tether attachment or new multiplayer acceptance.

Recommendation: server decides the first hit and cycle state; clients animate one nail and a cosmetic cable from emitter to nail, then shorten it as the nail returns. A small visual sag is possible without simulating rope segments. Do not add physics-based zombie dragging, wrapping around corners or snagging. If knockdown is later selected, make it an explicit reaction at retraction, not a force calculated from cable tension. Prototype wall/player occlusion, moving targets, zoom, missed shots and synchronized return before claiming the presentation works. Bound active effects and synchronization to avoid per-frame rope physics or network broadcasts.

**1A (recommended):** approve a small scripted-tether feasibility prototype; report rendered and multiplayer evidence before full implementation. **1B:** investigate true physical tethering first, with no guarantee of supported Lua/native access or acceptable compatibility/performance. Neither approach is newly approved by this question. Existing single-nail, default detection/input override, no-ammo/no-battery/no-modules decisions remain. No gameplay edits, install, version bump or tests claimed; 0.2.58 unchanged. **Decision needed.**

## C358 — Single nail and trigger override (2026-10-20)

Owner selects C357 **1A: one long tethered nail per cycle**. It stops at its first enemy, cannot pierce enemies, and must return fully and reset before another shot. Retraction knockdown remains explicitly TBD.

Owner correction: "Detection is on by default. Connecting to a trigger disables detection and requires an input." This supersedes the C356/C357 requirement for a detected target while linked. Scope is this retractable dart trap; it does not redefine turret Detection Modules or passive mechanical traps.

- No linked triggers: default forward detection starts the normal cycle.
- One or more linked triggers: autonomous detection is disabled. Input requests a straight-ahead cycle even when no zombie is detected; an idle input does not permit automatic firing.
- Button requests one complete cycle. A held Pressure Plate or Lever may repeat only after full retrieval/reset, at the ordinary cycle rate. Input release finishes the current cycle and starts no next one; no queued backlog.
- Removing the last trigger link restores the default autonomous detection mode. Controller assignment alone is not a trigger link.

Keep wall-only placement, no consumable ammunition, no batteries and no turret modules. No new recipe, damage/range/timing values, knockdown behavior or gameplay implementation is approved by this selection. Earlier proposals below remain historical wherever superseded here. Installed 0.2.58 and its pending rendered/connected acceptance are unchanged.

## C357 — Retractable trap replaces consumable darts (2026-10-20)

Owner selects C356 **1A**: autonomous forward sensing without linked inputs; linked Buttons request one detected-target cycle and held inputs enable detected-target cycles. No target means no new shot. Ordinary cadence, finish-current-action, no queued input backlog and no electrical consumption remain the intended rules.

Owner changes the device into a reeling/retractable dart trap: launch long nails, retrieve them to the trap, reload the mechanism and only then fire again. This supersedes ordinary nails as consumed ammunition, ammunition storage/capacity and player refilling. Treat the reusable nails as built-in equipment; neither crafting quantities nor a new loot item is selected. Wall-only placement, no turret modules, no batteries and no dependence on a pressure plate remain settled. Nails do not pierce enemies. A knockdown when retraction starts is explicitly **TBD**, not approved or guaranteed.

Proposed cycle for review: Ready -> Launch -> first impact or maximum extension -> Retract -> Reset -> Ready. Each nail stops at its first victim; recommend solid-obstruction stops, one outbound damage event and no extra damage during return. Trigger release should finish retrieval/reset but start no next attack. Misses still return; death/unload/removal must not leave a trap permanently busy or allow a late duplicate damage event. This represents nail retrieval, not a selected mechanic for dragging a zombie toward the trap. Exact timings, range, damage and player/collateral behavior remain unset.

Recommendation: use cycle time and condition/repair wear to balance reusable attacks rather than adding replacement ammunition. Guaranteed knockdown with unlimited firing could repeatedly lock down a victim, so keep the effect deferred until the basic cycle is tested; prefer a chance-based reaction on the struck, still-valid living zombie if added. No chance value or wear cost is selected.

**1 — Firing pattern**

- **1A — One long tethered nail per cycle (recommended).** Clear first-hit behavior, readable retraction, and a smaller implementation/MP synchronization surface.
- **1B — Three tethered nails fired together.** Each stops independently at its first collision; all must return/reset before the next volley. Wider coverage and potential multi-hit damage require separate balance and collision testing.

These new 1A/1B labels concern firing pattern, not the already-selected C356 input behavior. Neither is selected. After this choice, propose the complete combat and mechanical crafting package, including ingredients/tools/skills/XP, for review before implementing. No camera ingredient, final art, recipe quantity or replacement-ammo system is implied.

Read-only implementation review: shared `DefenseLine.clear` provides existing bounded same-floor obstruction checks, and `DefenseMotion.request` routes authorized knockdown to the actor's simulator in multiplayer. These are reusable foundations, not proof of tether physics, return visuals or a complete emitter. The reusable launch/retract state and first-collision presentation still need native/Traps-only/persistence/connected checks. Temporary technical art only. Planning only; installed 0.2.58 and its pending owner acceptance are unchanged. **Decision needed: firing pattern 1A or 1B; knockdown remains TBD.**

## C356 — Next checkpoint and optional-input decision (2026-10-20)

Owner asks “What’s next” after 0.2.58 delivery. The next content checkpoint remains R4C2 Dart Emitter; Lever remains queued and beam sensors follow the emitter checkpoint. 0.2.58 rendered/connected acceptance stays pending, but unavailable testing does not block design discussion.

Retain C347: walls only (native and player-built), ordinary nails, built-in forward sensing, no battery/grid/Controller energy, optional inputs and no modules. No new gameplay is authorized by this status question.

First unresolved decision: what connecting an external trigger does.

- **1A — Linked triggers arm the emitter (recommended).** With no inputs, use autonomous forward sensing. With inputs, a Button requests one detected-target shot and a held Plate/Lever enables detected-target shots at ordinary cadence. No target means no shot. A connection intentionally changes the operating mode; make that mode explicit in management. Preserve finish-current-action, fault safety and no pulse backlog. The trigger supplies permission to operate, not electrical consumption or a victim.
- **1B — Keep autonomous firing with manual shots.** Forward sensing stays active even with inputs connected; input requests can fire straight ahead without a detected target, at the same ordinary cadence. Releasing a linked input does not disable autonomous shots. This offers manual lane suppression but makes a connected Lever unsuitable as a master on/off switch.

These are proposals, not selections or engine verification. After selection, propose one complete combat/crafting package, including target/collateral policy, range/damage/cadence/capacity, service/wear and ingredients/tools/skills/XP, before implementing. No tentative camera ingredient is settled. The existing turret rotary detection shortcut remains a separate Lever integration check. Installed 0.2.58 is unchanged. **Decision needed: 1A or 1B.**

## C347 — Wall-only autonomous emitter selected (2026-10-19)

Owner selects C346 **1B / 2B / 3B**: wall-mounted only, ordinary nails, and no electrical consumption. Native and player-built walls must both be supported. Owner explicitly corrects the suggested trigger-only behavior: built-in forward target sensing allows autonomous operation without a pressure plate or any external trigger. External triggers remain optional. No local battery, Controller energy debit or grid/generator prerequisite; traps retain no modules.

The suggested camera is tentative flavor, not a selected ingredient or new item. Fixed placement facing remains the proposed firing model; recommend sensing only the unobstructed firing lane rather than detecting targets outside the emitter's ability to hit. This supersedes C346's proposed absence of scanning, not the no-tracking/no-automatic-aim recommendation. Use bounded server-side sensing, not per-frame whole-world scans.

Still to settle: optional trigger interaction with autonomous operation, lane/range/cadence/damage/capacity, player recognition and collateral rules, and the mechanical recipe/tools/skills/XP. Do not silently make a connection disable autonomy or assume a camera grants zombie-only recognition. C346's first choices below are historical and now resolved. The mechanical Poke Floor correction remains queued. No gameplay implementation or installation this discussion.

## C346 — Design discussion opened (2026-10-19)

Owner selects C345 **1A mechanical recipe cleanup** and asks to move to the dart emitter. The Poke Floor correction is settled and retained for the next patch: remove electrical materials/skill/XP, operational energy, repair Building visibility and rename OMH: Controls to OMH: Triggers. No new build/install is claimed by this discussion.

### Existing boundaries

The design assigns this trap the role of firing along a prepared lane (`DESIGN.md`). It is an independent Traps device with no turret modules. Recommend fixed placement facing, no scanning/tracking/automatic aim, and first-hit projectiles stopped by intervening solid obstructions. These implementation details still need owner acceptance/native proof. Controller management should reuse existing assignment/access controls without requiring Turrets content.

Preserve the selected signal model: Button requests one ordinary cycle; held Plate permits normal-cadence cycles; no input stacking or pulse backlog, and already-started safe actions finish on release. Signals do not identify a victim or grant selective targeting. Player/collateral injury policy remains to be explicitly discussed before enabling damage.

Source audit: current ControlWorld.link only accepts Turret receivers, and its receiver/cycle dispatch is turret-specific. Dart emitters therefore require a checked receiver adapter and Traps-only proof, not just another row in the UI. Reuse bounded projectile/collision/authority patterns only where their package and resource assumptions fit. No per-frame whole-world scans. Temporary technical art only, no new final art direction.

### First decisions

**1 — Placement**

Recommend **1A one-tile floor-mounted**, fixed placement facing, usable without a wall. **1B wall-mounted**, saving floor space but requiring clear wall-side placement and projectile clearance on native and player-built walls. Neither selected.

**2 — Ammunition**

Recommend **2A crafted metal darts**, with independent ammo balance and a dedicated recipe to approve. **2B ordinary nails**, simpler supply using an existing item but tying balance to abundant construction materials. No ammunition recipe, quantities, loot entry or rarity is selected; dedicated darts are proposed crafted-only initially.

**3 — Energy**

Recommend **3A local car battery, then assigned Controller bank**, keeping an automatic feeder consistent with powered equipment and preserving the Controller's real battery cost. **3B no electrical consumption**, balancing repeat firing through ammunition and reload time instead; the trap's mechanical reset is abstracted. Neither option implies adding module slots. The Poke Floor's newly selected mechanical rule does not silently apply to all future traps.

After these choices, present one coherent proposed damage/range/cadence/storage, service/durability, player injury and ingredient/skill/XP contract before implementation. Avoid treating suggested defaults as settled. Beam sensors remain R4C3, after the emitter slice. C343 category choices, exact five-second native MP placement and connected-client acceptance remain separate open work.

Status: design discussion only; installed 0.2.57.2 unchanged. **Decision needed: 1A/B, 2A/B, 3A/B.**
