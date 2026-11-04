# 0.2.64 - Arc Emitter

- Arc Emitter Head
- Electrical chain effects
- Splitter, Piercing and Synergy
- Arc Fragment and Velocity
- Arc Sandbox controls
- Battery consumption label consistency
- Native audio audition

Approved under C421, implementing C403-C420. Arc is craftable, ammo-free and uses the universal turret base. Defaults are 20 damage, six normal contacts, one-second main interval, twelve-tile acquisition, four-tile hops and .02% battery per main shot before modifiers. Only the main discharge is charged. Existing Siphon kill rolls remain unchanged.

Finite chains use shared direct-hit marks and bounded nearest searches. Main chain takes priority; Splitter branches wait at least .1 seconds. Piercing adds diminishing jumps; Synergy extends that to branches. Fragment uses electrical visuals without chaining and may revisit marked victims except its origin. Whole-pulse reservations were replaced with per-contact secondary admission to keep large loadouts functional under shared budgets.

The white jagged segments render through the native world model path with short lifetimes and a bounded presentation ring. This is temporary developer presentation. Final sound and rendered/player acceptance remain pending. The existing supported player damage policy and Horde Night checks apply.

Consumption labels retain the existing qualitative colors and thresholds. Firearm estimates now share the actual overlapping cooldown/reload formula. Inventory ratings are module-free; installed-head descriptions use resolved loadout/payload values. No head costs were rebalanced.

[Short test and evidence](TEST_v0.2.64.md). No Workshop publication or LootLab deployment.
