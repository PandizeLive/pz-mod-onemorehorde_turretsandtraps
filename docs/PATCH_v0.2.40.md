# Patch 0.2.40 - Magazine, Splitter and Fragment

Owner approval C136 accepts the C135 Fragment baseline and the complete selected module patch. R3C4 rules are settled for this slice; R3C5 implementation passes automated/native/package verification; owner acceptance is pending. R3C6 remains later work.

- Magazine Module
- Splitter Module
- Fragment Module

Magazine capacity is ceil(base + count * max(1, base * .35)), excluding a firearm's separate chamber. Firearm extensions earmark real rounds already inside the turret; they retain native weight and persistence. Capacity/head/magazine removal unmarks those rounds directly into their existing reserve storage. Because neither item ownership nor occupied storage changes, this first-choice destination cannot overflow; player/floor fallback is never needed for these surplus rounds. Native guns and removable magazines keep their ordinary capacity.

Splitter adds one direct ray per copy at 50% of the resolved primary whole-shot damage. Aim-relative paired 15-degree steps alternate the outer odd side; high stacks compress into 180 degrees. Any ready round permits the complete volley, consuming min(ready rounds, 1 + copies). Children may leave the targeting cone, but respect walls/range. No child splash, crowd control or recursion.

Fragment creates five radial rays on the first primary zombie hit, including a kill. Damage is 20% each, +5 percentage points per extra copy, capped at 40%; radius four tiles, independent of Range. Directions remain at least 30 degrees apart. Exclude the primary victim and damage each secondary at most once per burst. Shotguns trigger once per volley, not per pellet. Critical multiplier is shared with the primary.

Firing battery/fuel cost is base * (1 + .25 * Splitters + .25 * Fragments). Magazine has no surcharge; Fragment adds no ammo cost. At default base battery drain, zero/one/two/eight offensive copies give approximately 1000/800/666/333 volleys per full battery, before other conditions. No idle cost. Grid power retains its existing handling.

All three are loot-only standard modules, 0.3 weight and existing technical cube icons, with per-module loot multipliers and grouped Sandbox effect controls. Magazine uses weight 5; Splitter/Fragment 2.5 in eligible component pools. Vanilla/global loot rates are unchanged. The hosted LootLab remains its explicitly labeled 0.2.28 baseline; a future site data refresh must include these new entries.

The shared child queue caps committed/reserved rays at 256 and processes at most 128 steps within its one-millisecond share of the aggregate scheduler. A saturated queue delays new module volleys before spending resources. Rays only affect loaded space. Like existing in-flight potato shots, uncompleted effects are runtime-only and are discarded on quit/reload; spent ammo is not replayed/refunded. This is not persistent projectile simulation. Rendered timing and dense-workload acceptance remain owner checks.

Automated/native evidence and the one combined owner checklist live in [TEST_v0.2.40.md](TEST_v0.2.40.md). No multiplayer enablement, new module recipes, new heads or Workshop publication.
