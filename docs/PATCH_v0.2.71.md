# 0.2.71 - Projectile timing, loading and trap spacing

Owner approved the complete [C525 update](UPDATE_SCOPE_C525.md), then explicitly approved the matching Horde Night baseline change. [Implementation and proof](UPDATE_C526.md).

- Splitter and Fragment projectile identity/travel
- Fragment impact timing
- Rotary motion and snapshot correction
- Tether prediction and timing diagnostics
- Makeshift Bomb loading speed and batching
- Poke Floor stabilizer cross and placement preview
- Poke Floor recipe costs
- Spike Barrier durability
- Refreshed artist handoff

New Poke deployments require five exclusive tiles: center and four cardinal neighbors. The four low bars are traversable, non-damaging stabilizers. One assembled trap is placed, repaired and recovered. Existing Poke placements retain their old footprint until redeployed. Both recipes now require five Metal Bars and ten Screws; other requirements are unchanged.

New default Barrier health is 80, or 160 reinforced. Existing Sandbox values are preserved. Horde Night 0.6.16.10 matches the new baseline without clearing historical run flags.

Server damage, death, XP and Horde attribution remain authoritative. Physical children now travel before impact; Arc spacing and explosive fuses remain intact. The update removes the reproduced rotary prediction freeze, but does not claim that all latency on a live connection has disappeared.

The artist ZIP contains the current meshes/textures, including Tether nail/cable and the Poke stabilizer assembly. Developer models remain placeholders.
