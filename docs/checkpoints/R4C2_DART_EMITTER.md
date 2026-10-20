# R4C2 — Fixed dart emitter

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
