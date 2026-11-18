# 0.2.41 - Enhanced modules and turret corrections

Approved scope: C137. Fresh worlds; SP combat. Installation and immutable test tag are recorded in [release evidence](RELEASE.md).

- Enhanced Firing Module
- Enhanced Detection Module
- Automatic firearm cadence correction
- Continuous acquired-target firing during background scans
- Larger Expansion ammo allowances
- Spike Barrier placement-limit correction
- Synchronized Splitter and Fragment tracers
- Searchable Trap/Turret/Module item families
- Current LootLab catalog and saved-settings migration

Enhanced Firing is loot-only and replaces Firing; it scales the normal 75% firearm adapter to 100% at default settings, with Rapid-Fire still applied. It does not change handheld weapon properties or potato cadence. Enhanced Detection replaces Detection, triples turning speed and uses a 0.10-second scan interval. These are requested scan intervals, not guaranteed full-search reaction times; shared bounded work remains. Both match Large Expansion weight/pools and consume one normal module slot.

Expansion bonuses are +100/+200/+400/+650, giving default total count ceilings of 200/300/500/750. Slot progression remains 2/4/8/12/16. Native weight limits remain effective: 50 for portable containers, 100 for world containers; heavy ammunition may hit weight before count. Stored Sandbox overrides are preserved. No ammo compression or virtual reserve.

Two Splitters retain the central shot and both side rays. All firearm volley tracers begin together when bounded collision resolution completes; visible portions remain drawable when endpoints enter fog. A late first rendered frame gets the normal 100-ms tracer display, with a one-second absolute expiry. Collision/range checks and real ammo/power costs remain. Grouped visuals can follow the immediate shot sound by the ray-processing delay; rendered acceptance is pending.

Real Spike Barrier construction, extension and rotation no longer stop at the diagnostic registry limit. Retired identity records still prevent stale actions; maintenance remains bounded. This removes an artificial placement cap, not all practical performance limits.

Spawn types use Base.OMHTTTrap..., Base.OMHTTTurret... and Base.OMHTTModule.... No aliases or migration; old test worlds are outside scope. Visible item names and art placeholders remain.

LootLab now includes Magazine, Splitter, Fragment and both Enhanced modules: 20 lootable modules, 16 pools, 150 entries. Existing multipliers, seed and visibility survive baseline migration; new fields default to 1/visible. No account rows were rewritten. Global loot and existing module weights are unchanged; adding new modules can increase aggregate finds.
