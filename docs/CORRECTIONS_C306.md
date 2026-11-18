# C306 — R4C1 feedback and next-patch scope

2026-10-17. Owner says the current patch appears to work and confirms pressure-plate activation. Linking was confusing; zombies thumped the plates. Owner requests a Controller action to select a turret, click a world point and aim toward it. Include these in the next patch; this turn records findings and design, without installing another build.

**C308:** Owner subsequently says "Patch". Implemented in [0.2.53.10](PATCH_v0.2.53.10.md); [verification/delivery](TEST_v0.2.53.10.md) tracks acceptance separately.

## Findings and scope

- **Pressure plates:** apply native pass-through, non-thumpable behavior to new and already-placed plates, including registration/reload and multiplayer replication. Use this as the rule for future passive beam/laser and other sensors. This does not change Controller durability or make every defense invulnerable. Preserve occupancy, signals, player pickup/repair and exact persisted identity. `ControlWorld.create` currently sets `setCanPassThrough(true)` and `setBlockAllTheSquare(false)`, but never `setIsThumpable(false)`. Installed 42.21 `media/lua/server/Traps/BuildingObjects/TrapBO.lua:19` uses that third setting for native pass-through snares. This supports the proposed correction; persistence/client application still need implementation checks.
- **Linking clarity:** retain the existing source-to-receiver flow, with an obvious selected source, explicit next step, and confirmed linked/unlinked state. Recommend contextual Connect/Disconnect rather than equally enabled contradictory actions. This is a UI recommendation responding to the reported confusion; no circuit model redesign or additional setup cost.
- **Controller aiming:** add a world-direction picker for the selected authorized turret, with a directional/FOV preview and cancel. Clicking chooses direction only; it must not shoot or manufacture a target. Validate Controller access/range and exact device identity on the server. Reuse bounded turning/presentation and publish changed direction; no permanent cursor scans or client authority. Preserve the power rule: an OFF turret does not physically turn. A saved direction can take effect when it is powered.

## C307 — confirmed aiming behavior

Owner selects **1A** on 2026-10-17 for the next patch. This resolves the aiming choice; it does not install a new build.

**1A — Set Facing (selected):** save a new normal firing direction and rotate its firing/detection sector with it. Detection continues acquiring targets within that sector; Firing-only shots follow the new forward direction. A 360 module keeps full coverage. This is useful for trigger-based installations without another aim-mode toggle.

**1B — Manual Aim Lock (not selected):** hold the selected direction and suspend automatic target tracking until the player explicitly restores automatic aiming. Adds another state/control and must explain why Detection is not tracking.

Implementation checks for the selected behavior: current `TurretModules.profile` derives sector heading from `baseFacing/facing`, whereas `TurretAim` animates `aimDegrees`. Merely setting the visual head angle would leave fixed-facing fire/FOV pointed elsewhere. The implementation must make gameplay direction, aiming and world preview agree. Current aim requests take zombie targets and may fire on arrival for manual requests; do not reuse that firing callback for a direction-only picker.

## Checkpoint reconciliation

R4C1 is implemented but still has these corrective items; owner reports SP activation working, not full connected acceptance. Complete the plate correction, clearer linking and selected Controller aiming behavior before declaring this slice complete. No repeat of previously accepted UI work is required just to advance planning.

The documented next content checkpoint is **R4C2**, selected **Poke Floor first**, then the **fixed dart emitter** as a separate slice. Held Poke Floor signals repeat legal strike cycles; its damage, cycle tuning, power/wear, injuries and recipe/skills/XP remain a content-design contract to settle before implementation. **R4C3** then covers beam sensors/control extensions; the Controller foundation is already delivered. The optional turret receiver from **R4C4** is already integrated in R4C1 and should not be presented as wholly missing. Future receivers/adapters need their own independent-package checks. **R5C1** connected dedicated/listen acceptance remains pending separately; deferred owner testing does not block authorized development.

## Evidence

[0.2.53.9 owner test record](TEST_v0.2.53.9.md#c306-owner-feedback-2026-10-17) and [console review metadata](../diagnostics/v0.2.53.9/owner-review-20261017.json). Console confirms SP 0.2.53.9 through frame97167, sequence7287. No T&T Lua exception found in the captured session; unrelated native asset/map and Firearms translation warnings remain. This is behavioral feedback plus source inspection, not a new patch, native reproduction of zombie targeting, or multiplayer test.
