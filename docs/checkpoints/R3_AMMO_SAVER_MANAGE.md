# C150: Ammo-saving module and compact Manage proposal

2026-10-11. Owner requests a stackable module making two shots consume one round, better battery consumption information, narrower module slots/window, and battery/expansion placement in the two blue-marked gaps in the attached Manage screenshot. Owner then explicitly requests **1A/1B/1C choices in the reply, including name options, rather than a structured question form**, and says discussion is still needed. The unanswered form selected no option. **Discussion only; no implementation approval inferred.** Carry alongside C149 transfer work and retained C148 optimizations; installed 0.2.42 and ongoing R3C7 acceptance remain unchanged.

Read current branch `codex/performance-barbed-audit` at `7142196f175ca8b3a796511f10afae7ba72d53b2`; fetched origin and confirmed open draft PR #1 into dev. Inspected TurretManage/OpenAction, TurretSlot/update, TurretWorld/fire, TurretStats, Firearms/consume and prior R3 power contract. The user-supplied screenshot shows the existing 4/6/6 grid with blank cells at either end of row one. This is a layout request, not a new test pass/failure.

## Choices to discuss

### 1. Module name

- **1A Ammo Saver Module (recommended):** shortest clear statement of ammunition savings.
- **1B Ammo Efficiency Module:** explicit ammunition scope, more technical wording.
- **1C Ammo Conservation Module:** explicit scope, longest label; short installed-slot label would be needed.

Avoid plain Efficiency Module because power efficiency is a plausible separate future effect. Do not imply recycling spent casings or crafting ammunition that the implementation does not perform.

Recommended stacking: `uses per round = 1 + working module count`; one copy gives two uses (50% ammo savings), two three uses (66.7%), three four uses (75%), four five uses (80%), sixteen seventeen uses (94.1%). This is strong and approaches but never reaches free ammo at finite counts. Existing slot limits and ordinary per-copy power costs still apply. It does not multiply damage or change actual firing cadence. The owner has requested increasing stacks but has not selected this precise formula from the offered discussion yet. Recommend ordinary loot-only acquisition, normal module weight/slot/power treatment, and matching Sandbox/LootLab integration; rarity and exact identity are not finalized.

### 2. Interaction with Splitter

- **2A Discount the existing ammo cost (recommended):** retain Splitter's current charge, then apply the reuse factor. With two Splitters, sufficient loaded ammunition and one Saver, a three-round volley averages 1.5 rounds instead of three. Preserve the existing partial/one-round fallback; do not charge missing extra ammo retroactively.
- **2B One round covers the whole volley, then apply savings:** one Saver averages 0.5 rounds per full Splitter volley, regardless of Splitter count. Strongly amplifies Splitter and overrides its present multi-round balance for Saver-equipped turrets.
- **2C Save the primary round only:** side-shot rounds retain their full cost. Two Splitters plus one Saver average 2.5 rounds/volley when fully supplied. More restrained but less uniform.

These are long-run averages, not fractional inventory items. A deterministic paid-use/progress counter must retain exact-round ownership and not grant free ammunition through save/reload, head pickup, module swaps, partial top-ups or cross-turret moves. Settle the intended rule before choosing implementation. Existing Firearms.consume performs actual native ammo/chamber changes; potato has a distinct consumption path. Both require native proof, especially chamber-only guns, reload/racking and the last round. Preserve the user's one-round/Splitter fallback without infinite firing after ammunition/legitimate credit is exhausted.

Suggested shared rules: misses count as fired uses; rejected shots do not. Normal battery/generator cost applies to every actual committed volley even when ammunition is saved, and Saver copies add the standard module power load. Extra uses do not rearm Impact; only the existing genuine empty-reload rule does. Secondary projectiles and victims do not independently advance the counter. Do not let the hypothetical runtime display drive authoritative ammo/power state.

### 3. Battery information

- **3A Rounded cost + remaining volleys in battery tooltip (recommended):** show charge next to the battery; detailed hover text includes `0.23% / volley`, `about 298 volleys remaining`, and `No idle drain` for the illustrative exact charge=70%, cost=0.23436% example. Actual values use current charge and unrounded stats. Show active grid/generator source separately; a battery estimate is conditional on battery operation, not an assertion it is currently draining.
- **3B Add a theoretical continuous-firing duration:** same as A plus clearly labeled real-time minutes/hours at configured cadence. Explain whether reloads are included; aiming, target gaps and scheduler delay cannot be predicted. Prefer a tested cycle-aware model before calling it sustained fire. With zero battery drain or no usable head, show an appropriate state rather than divide by zero or invent a duration.
- **3C Convert the theoretical duration to game days:** follows the world's day length and carries the same caveats as B. Least recommended: players may read it as calendar survival time, while idle battery drain is zero and workload varies.

Round **display only**, with adaptive precision: 0.23436% -> 0.23%, but retain 0.005% rather than hide it as 0.00% or 0.01%. Tiny positive values need significant digits or a nonzero bound. Actual battery/generator consumption remains unchanged. Decimal arithmetic: changing the actual cost from 0.23436 to 0.23 would reduce draw by 1.8604%; that is NOT the proposed change. Exact 70% / 0.23436 gives 298 whole volleys; exact 100% gives 426. Do not compute remaining volleys from the rounded cost or rounded charge label. This example uses the owner's stated number, not a recovered hidden value from the screenshot. Saved older base costs can remain higher than fresh 0.2.42 defaults; presentation must not reset them.

### 4. Compact layout

- **4A Battery left / Expansion right in the blue gaps (recommended):** compact utility cells flank modules 1-4; narrow all module cells while retaining the 4/6/6 arrangement. Move head/ammo/magazine/power into a compact top strip where measured text fits. Battery charge and short expansion tier stay visible; details on hover.
- **4B Battery left / power switch right:** expansion stays above. Easier access to power, less consolidation of the upper rows.
- **4C Keep utilities above:** narrow module cells/window only; smallest structural change but leaves the two gaps unused.

4A schematic (not a rendered/native-verified layout):

```
[ Head             ][ Ammo        ][ Magazine ][ Power ]
[ Battery ][ M1 ][ M2 ][ M3 ][ M4 ][ Expansion ]
[ M5      ][ M6 ][ M7 ][ M8 ][ M9 ][ M10       ]
[ M11     ][ M12][ M13][ M14][ M15][ M16       ]
```

Current width is max(800, font line height * 40), clamped to viewport; module width is (window width - 54)/6. Recommend testing roughly 20% narrower at the same normal font (about 640 vs 800), with measured-text/large-font safeguards rather than a hard universal width. Full names remain available through tooltips. The current battery slot is an ordinary ISToolTipInv item tooltip; add turret-specific details locally to this slot, not all car batteries globally. Preserve native drag/drop/right-click, viewport fit, oversized-capacity scrolling, empty/missing battery feedback and active power indication. Reuse existing 200 ms Manage refresh for tooltip calculations/text; add no continuous-fire history scan or new tick handler. Final rendered placement/legibility remains to verify after implementation approval.

## Handoff

Recommend **1A / 2A / 3A / 4A**, with the proposed linear uses-per-round stacking and normal per-volley power. Names, Splitter accounting, display variant and layout remain open. Do not treat the owner's request to discuss names/options as implementation approval. C149 transfer freeze remains the first corrective priority; C148 optimization list is retained. No gameplay, item/loot, version, install, published changelog or test acceptance changes this turn. **Decision needed:** discuss/select the options in the reply, without another structured form.
