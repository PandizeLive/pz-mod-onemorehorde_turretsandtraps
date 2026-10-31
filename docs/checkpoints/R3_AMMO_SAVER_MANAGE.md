# Conservation Module and compact Manage contract (C150-C151)

**Current C151 selections:** Conservation Module (1D), discount existing ammo cost including Splitter (2A), combined battery tooltip 3A+3B, and utilities kept above narrower module cells/window (4C). The blue gaps remain unused. C152 adds a current-benefit list in the lower-right details area; C153 requires compact effect labels and explanations on each row's hover tooltip. Detailed selection provenance below supersedes the historical recommendations. Discussion selections are recorded; no immediate gameplay patch/install requested.

2026-10-11. Owner requests a stackable module making two shots consume one round, better battery consumption information, narrower module slots/window, and battery/expansion placement in the two blue-marked gaps in the attached Manage screenshot. Owner then explicitly requests **1A/1B/1C choices in the reply, including name options, rather than a structured question form**, and says discussion is still needed. The unanswered form selected no option. **Discussion only; no implementation approval inferred.** Carry alongside C149 transfer work and retained C148 optimizations; installed 0.2.42 and ongoing R3C7 acceptance remain unchanged.

Read current branch `codex/performance-barbed-audit` at `7142196f175ca8b3a796511f10afae7ba72d53b2`; fetched origin and confirmed open draft PR #1 into dev. Inspected TurretManage/OpenAction, TurretSlot/update, TurretWorld/fire, TurretStats, Firearms/consume and prior R3 power contract. The user-supplied screenshot shows the existing 4/6/6 grid with blank cells at either end of row one. This is a layout request, not a new test pass/failure.

## Historical C150 choices (resolved/revised by C151 below)

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

## Historical C150 handoff

Recommend **1A / 2A / 3A / 4A**, with the proposed linear uses-per-round stacking and normal per-volley power. Names, Splitter accounting, display variant and layout remain open. Do not treat the owner's request to discuss names/options as implementation approval. C149 transfer freeze remains the first corrective priority; C148 optimization list is retained. No gameplay, item/loot, version, install, published changelog or test acceptance changes this turn. **Decision needed:** discuss/select the options in the reply, without another structured form.


## C151 - selected name, Splitter accounting, hybrid battery tooltip and separate utilities (2026-10-11)

Owner selects **1D Conservation Module**, **2A**, asks whether **3A and 3B can be combined**, and selects **4C** because placing battery/expansion beside modules would be confusing. Treat this as the design selection/request for a combined tooltip, not an answer to a new approval form or an instruction to install immediately during the test.

- **Name:** Conservation Module is selected. Do not keep asking for a name or substitute Ammo Saver/Ammo Efficiency. Its tooltip/short effect description must explicitly say ammunition so the selected broad name is not mistaken for battery efficiency. Internal item type should follow OMHTTModule naming when implemented.
- **Ammo:** selected 2A applies conservation to the existing actual ammo charge, including Splitter and its one-round/partial fallback. Retain the proposed linear two/three/four uses at one/two/three copies as the working design; no different stacking rule was requested. Two Splitters with enough loaded ammo and one copy average 1.5 rounds per volley. Do not change normal per-volley power or Impact's real empty-reload condition. Native chamber/last-round/credit/persistence details still require implementation and verification; this selection is not that proof.
- **Battery:** 3A and 3B can share one tooltip. Keep charge beside the battery. Hover shows adaptively rounded charge cost per volley, remaining battery-powered volleys from unrounded values, estimated continuous-firing duration in real minutes/hours, and zero idle drain. Preserve the active grid/generator indication; battery endurance is conditional on battery operation. Rounding is display-only and changes actual draw by zero. Do not convert to game days.
- **Estimate contract:** clearly label the cadence model. Recommend a reload-aware continuous-firing estimate using current head/magazine/cooldown/rack/reload and conservation configuration, with hypothetical unlimited reserve and available targets. Exclude unpredictable aiming/target gaps, scheduler slowdown and pauses; those extend elapsed lifetime. If a reload-aware model cannot be verified for a supported gun, show an explicit configured-fire-rate estimate with reloads excluded instead of pretending it is sustained throughput. Reuse existing throttled Manage refresh, bounded local computation and no per-tick firing history. Zero-cost/no-head/no-battery states must be explicit. Exact duration text and arithmetic remain unimplemented.
- **Layout:** retain battery, expansion and power controls above the module grid. Narrow the cells and window with font/viewport safeguards; retain 4/6/6 and leave its two end gaps unused. The 4A combined strip/schema is rejected, not the current target. Preserve drag/drop, full-name tooltips, capacity scrolling and separate utility identity.

C149 fast matching/bounded ammo transfers remain first priority; C148 optimizations are retained in the same next-update plan. Conservation acquisition/rarity and technical counter implementation remain to settle with the implementation scope; do not quietly introduce a recipe or alter loot totals. No gameplay code, version, install, Workshop changelog or test-result changes. The design is recorded for the next patch; readiness/approval to execute that combined patch is separate from this discussion response. **Decision needed:** finish discussion/authorize the combined implementation when ready; do not repeat settled 1D/2A/3A+3B/4C choices.


## C152 - installed module benefit list in Manage (2026-10-11)

Owner marks the unused lower-right details area beside the existing turret stats and asks to list every module with its current benefit. Add this requested feature to the next-update Manage scope. This is an informational panel; preserve C151 separate utility slots above the 4/6/6 grid and its narrower-window direction. No immediate gameplay patch/install inferred during the ongoing discussion/test.

Recommended presentation: a fixed-height scrollable list, one row per installed module type, with duplicate count and combined effective benefit. Avoid sixteen repeated descriptions for sixteen identical copies. List all installed types, including inactive ones; distinguish working copies from broken copies so the displayed count cannot imply a benefit that does not exist. Use stable ordering and full-detail hover text for long conditions. Battery and expansion remain separate utility slots, not ordinary module rows.

Examples with default settings and the stated working-copy counts (illustrative, not an assertion about the screenshot's complete loadout):

| Row | Current benefit text |
| --- | --- |
| Execute x3 | Finishes targets at 14% HP or lower |
| Initial Blow x2 | +50% primary damage against targets at 90% HP or higher |
| Splitter x2 | Two extra side shots at 50% damage each |
| Impact x2 | 62% stagger chance on the first shot after an empty reload |

Conservation uses the selected rule when implemented: e.g. x2 gives three firing uses per normally charged round (about 67% ammo saved); apply it to existing Splitter cost rather than say every full volley costs one-third round. No claim that Conservation exists in installed 0.2.42.

Use resolved current configuration and actual Sandbox values, not hardcoded example percentages. Respect head compatibility, active/broken modules, caps and interacting effects: mark Piercing inactive for unsupported heads, show Range's effective gain at the range cap, and avoid claiming a Reload reduction when Autoloader already overrides the timer. Show conditions on Initial Blow/Execute/Impact rather than imply permanent unconditional damage/control. Full explanatory details can live on hover, with short meaningful row text in the panel. State inactive/capped reasons in text as well as subdued styling. No source-code/internal IDs in player-facing rows.

Layout should reserve a right-hand column and constrain/wrap left-side stat/status text so they cannot overlap in the narrower window. Keep engagement slider, action/status feedback and bottom buttons clear. The marked area cannot show ten-plus distinct types at once; use scrolling rather than growing window height or hiding modules. Verify normal/large fonts and 720p/split viewport fit after implementation; exact pixel width/row count is not yet rendered proof.

TurretManage already refreshes effective state every 200 ms and TurretStats exposes combined module effects. Reuse that snapshot, cache formatted rows on relevant configuration/settings changes, and avoid per-frame per-module inventory rescans or new tick callbacks. Some effective contributions/statuses need a presentation helper derived from the same combat rules; existing scalar stats are not proof of a complete ready-made breakdown. C149 transfer correction remains first; C148 optimizations and C151 Conservation/battery/layout remain included. No item/loot/version/install/test changes. **Wait for a patch:** requested list recorded in the next-update plan; implementation is not yet installed.


## C153 - compact Installed Modules labels and row tooltips (2026-10-11)

Owner explicitly shortens C152 rows: examples `<14% HP` and `+2 Shots`; explanations belong in module details and when hovering the individual Installed Modules list rows. **Installed Modules** is the intended list heading. This supersedes the descriptive row sentences recommended in C152, not the underlying effects or grouped duplicate counts.

Use name/count plus a compact effect, for example (defaults, stated working counts): Execute x3 — `≤14% HP`; Splitter x2 — `+2 Shots`; Initial Blow x2 — `+50% Damage`; Impact x2 — `62% Stagger`. Execute is inclusive in TurretConditionalHit.snapshot (`fraction <= stats.execute + .0000001`), so `≤` (ASCII `<=` if required by verified font coverage) is accurate; do not change gameplay to match the owner's illustrative strict-less-than shorthand.

Each row has its own hover explanation with current values and conditions, using the module description as the source of meaning: health requirements, primary-hit restriction, side-shot damage/ammo, empty-reload trigger, eligibility/recovery rules, and cap/incompatibility/broken-copy details as applicable. Do not dump those sentences into the compact row. Keep brief `Inactive`/`Capped`/`Broken` state text visible where needed; explain why on hover. Hover describes that row, not a global panel tooltip or a clicked/opened inventory item requirement. Synchronize with current configuration/settings, reuse cached/throttled UI state, and preserve native item tooltips separately.

Requested for the next patch with C152's scrollable fixed-height list and C151's narrower/separate-utility layout. No new gameplay values, version, install or test acceptance; C149 transfer fix remains first. **Wait for a patch:** compact-label requirement recorded, not yet installed.


## C154 - approved and implemented in 0.2.43 (2026-10-11)

The owner explicitly approved patching the complete bundle, including the transfer fix and five optimizations. [Final behavior](../PATCH_v0.2.43.md) and [test](../TEST_v0.2.43.md) distinguish automated/native proof from pending owner acceptance. Battery time uses the permitted explicit configured-fire-rate model (reloads excluded). Conservation uses existing offensive loot rarity (2.5), 0.3 weight and ordinary power load; no recipe. Prior discussion-only gates in this historical record are superseded.
