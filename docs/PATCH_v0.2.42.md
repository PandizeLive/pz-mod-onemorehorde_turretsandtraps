# 0.2.42 - Offensive modules and unified firing power

C147 owner approval settles the C146 formula, including generator firing consumption. This completes the C144-approved module implementation; installed state and evidence are tracked in CURRENT_STATUS.md and TEST_v0.2.42.md.

- Piercing Module
- Initial Blow Module
- Execute Module
- Impact Module
- Module-weighted firing power
- Weapon damage/range power scaling
- Manage firing-cost display
- LootLab module catalog

Piercing supports single-projectile firearm heads: one additional aligned victim per copy, 70 percent damage retained per successive hit, blocked by walls. Initial Blow adds 25 percent primary damage per copy against targets at least 90 percent healthy. Execute kills on an eligible primary hit at 10 percent health for one copy, +2 percentage points per extra copy. Impact has 60 percent first-copy chance, +2 points per extra, only for the first committed shot after empty reload; misses spend entitlement, partial top-ups do not rearm, and a five-second shared victim guard prevents repeated stagger locking. Conditional effects do not propagate into secondary rays/splash. All four are loot-only, weight 0.3, loot weight 2.5 in the Splitter/Fragment pools. Placeholders remain unchanged; no recipes added.

Battery percent per volley = 0.005 * (1 + 0.05 * weighted physical module count) * max(1, sqrt((ordinary damage / 80) * (capped maximum range / 15))). Generator base is 0.0001 native fuel units with the same factors. Damage/range use pre-module weapon stats; equal initial module weights count working ordinary-slot items once, excluding the head, battery and expansion socket. No idle battery draw, target scans or hit-dependent billing. Costs are committed once with a volley, including misses. The formula uses current base Sandbox overrides. The old SplitterPower and FragmentPower options are retired; no saved setting is silently rewritten.

Existing worlds retain previous base costs, commonly 0.1 percent battery / 0.001 generator. To test new defaults, use a fresh world's default settings, or deliberately set those two values to 0.005 / 0.0001. Preserved presets may also carry older values. Fresh-world item identity policy and SP combat scope remain.

LootLab grows to 24 lootable modules, 170 entries and 16 pools. New independent candidates increase total expected module finds in eligible pools; no existing per-item/global spawn multiplier is raised. Old account/scenario values are retained, and missing new module fields default to 1/visible. Hosted release evidence is separate from gameplay installation.
