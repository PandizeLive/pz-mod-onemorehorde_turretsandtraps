# R4C2 — Fixed dart emitter

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
