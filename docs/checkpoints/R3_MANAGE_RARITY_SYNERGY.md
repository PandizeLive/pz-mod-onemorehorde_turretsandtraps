# C155 - Manage boundaries, rarity, Once each and Synergy discussion

## C156 - selected options and full palette (2026-10-11)

Owner selects **1B Header bands**, **2A logarithmic rarity with both extreme colors**, **3A one fired shot per target**, **4A cached per-shot/count/reload-aware time estimates**, and **5D one installed Synergy module per turret with 100 percent activation chance**. The earlier five-color recommendation and stackable Synergy burst allowance are superseded. Selection settles those design choices; this discussion turn does not install a gameplay patch or mark 0.2.43 accepted.

The selected rarity palette has seven stops: pale blue `#82AEFF` (EASIEST_DETAIL), cyan-blue `#73CCFF` (cozy), green `#59E666`, yellow `#FFFA4D`, orange `#FF9433`, red `#FF2E2E`, deep purple `#420D82` (EXTREME_DETAIL). The highest positive loaded loot weight maps to pale blue/commonest; the lowest maps to purple/rarest. Preserve the logarithmic normalization; round to seven stops instead of five. Dim surface tint and lightened text must preserve readability, especially for the dark-purple endpoint. No Horde Night runtime dependency.

Interpret 5D as one **installed module**, not one proc per shot: every eligible successful secondary hit activates its allowed interaction. Do not silently retain 5A's one-extra-burst ceiling. Recommended safeguards remain no recursive proc generations and bounded scheduled work; these are not a reduction in the selected 100 percent chance. Higher effect counts may increase queue latency and require a measured admission policy before implementation can promise performance.

**Remaining interaction-scope choice:**

- **6A recommended: Fragment only for the first Synergy version.** Successful Splitter/Piercing hits trigger Fragment when that module is installed. Source-hit damage scaling carries forward; Fragment children cannot trigger additional module chains. Existing primary-hit effects keep their existing rules.
- **6B: Broader offensive interactions.** Extend eligibility to effects such as Execute, Initial Blow and Impact as well. The eligible effect matrix and per-hit/per-shot rules must be discussed; 100 percent Synergy eligibility does not automatically convert Impact's own chance to 100 percent or remove other conditions.

The new 5D rule materially increases the number of effects compared with 5A; no duplicate-install exploit, effect dropping or recursive chaining is assumed approved. Large Expansion-equivalent loot weight/pools remain the existing rarity proposal. Current preview's Header bands selection is consistent with 1B; its old five-stop colors are superseded by this correction.

2026-10-11. Discussion only; installed 0.2.43 and its immutable test tag are unchanged. Owner requests visual examples and options, not implementation. Current branch inspected: `codex/performance-barbed-audit` at `02e7ed19d15c0997e5e1a0d4f6e4cedf779b3e77`; origin fetched. Follow-up choices belong here and in DECISIONS before patching.

## Confirmed requests

- Borders/background dimming separate equipment, module slots, status, Installed Modules and engagement range.
- Installed Modules gets a bounded background with names left and compact effects right; existing per-row explanations remain on hover.
- Manage module colors derive automatically from minimum/maximum loaded loot weights and follow Horde Night difficulty colors: blue, green, yellow, orange, red. Dim backgrounds and lighter text.
- New Filter priority, Once each: nearest eligible target starts the round; subsequent selections minimize turret rotation regardless of distance, then repeat after the round.
- Native-style remaining bars beside battery percentage, reserve and magazine counts.
- Simpler battery text with reload time when Autoloader is absent; no tick-driven estimate recalculation. Clarify volley terminology.
- Discuss rare Synergy module, roughly Large Expansion rarity, enabling secondary hits to trigger effects such as Fragment.

## Evidence and important boundaries

- `TurretBenefits.battery` currently estimates count times cooldown only. `TurretManage.refresh` rebuilds its text every 200 ms while open. A volley means one primary firing action plus side projectiles, not a magazine or one physical round.
- `Firearms.update` reloads detachable magazines in one interval, internal magazines per round, and retains chamber/rack delays. Autoloader zeroes reload time in `TurretStats.resolve`; it does not remove every chambering delay. The estimate must model the existing head cycle and overlapping cooldowns, not blindly add one reload to every shot.
- Native `ISUIElement.drawProgressBar` exists in installed B42.21 Lua and draws a clamped filled/remaining track. Reuse that primitive; visual equivalence to the inventory tooltip is a rendered acceptance check.
- `LootDefinitions.WEIGHTS`: maximum 30, minimum positive 1.5; Large Expansion and Enhanced modules are 1.5. Current intermediate weights: 7.5, 5, 2.5. Pool eligibility also affects availability; weight color is relative tuning, not a literal drop percentage.
- Horde Night `OMH_DifficultyPalette.COLORS`: cozy (.45,.8,1), easy (.35,.9,.4), normal (1,.98,.3), hard (1,.58,.2), noc (1,.18,.18). Reuse values without introducing a Horde Night dependency. Extreme-detail purple is outside the recommended five-color scale.
- `TurretVolley.finish` applies secondary damage directly; it does not recursively spawn Fragment. Existing 256 queued rays / 128 steps per callback must remain bounded if Synergy is selected.
- `TurretAutomation` already scans incrementally under the shared scheduler. Once each must integrate there; no additional high-frequency scan or per-zombie persistent metadata.

## Options for owner selection

### 1. Section presentation

- **1A recommended: Inset panels.** Thin neutral borders and dim section fills, preserving the current compact layout.
- **1B: Header bands.** Titled section strips with fewer individual equipment outlines and a slightly wider benefit column; consumes more vertical space.

Both include the requested list background/alignment, bars and 4/6/6 slot pattern. Preview values are illustrative, not engine-certified battery duration or final art.

### 2. Automatic rarity colors

- **2A recommended: Logarithmic spacing.** Normalize the positive loaded module catalog weights as log(max/weight)/log(max/min), then round to the nearest of five color stops from blue/common to red/rare. Current example: 30 blue, 7.5 yellow, 5 yellow, 2.5 orange, 1.5 red. Equal weights always share a color; bands need not all be populated.
- **2B: Linear spacing.** Normalize (max-weight)/(max-min). Simpler arithmetic but current low weights cluster orange/red.

Use loaded base weights times per-module Sandbox multipliers, including expansion modules, rather than only currently installed copies. The uniform global multiplier does not affect relative rank. Exclude zero/disabled entries from endpoints and display them gray with a Disabled loot tooltip. Crafted-only entries gray/Crafted; all-equal weights use one neutral fallback. Display rarity separately from broken/inactive labels. Cache at world/settings initialization, not per draw. This does not promise accurate rarity for arbitrary later third-party distribution edits; those would require an explicit supported recomputation route.

### 3. Once each accounting

- **3A recommended: One fired shot per target per round.** A fired miss counts; jam/no-power/cooldown without firing does not. Start nearest, then smallest legal angle from the current heading; ties nearest. Always obey range, cone, line of sight and target rules. Only the selected primary target counts, not incidental Splitter/Piercing victims.
- **3B: One successful primary hit per target.** Same ordering but retry misses; less even coverage and can get stuck focusing an evasive/blocked target.

Recommended round membership: snapshot eligible targets at the round's incremental scan, revalidate before firing, skip dead/invalid targets, admit new arrivals next round so continual arrivals cannot starve repeat coverage. Only mark after a committed firing result. Clear temporary target references on removal/unload/priority change; save/reload starts a new round. Broad-radius snapshot/ordering feasibility remains native/performance work for implementation, not proven by discussion.

### 4. Battery wording and updates

- **4A recommended: Per shot + shots left + estimated firing time.** Label the Splitter rule once in tooltip: a shot includes its side projectiles. Include reloads, chambering, actual magazine/Splitter/Conservation behavior and overlapping timers; Autoloader removes only its actual reload delay. Display seconds for short durations, minutes for longer ones; no false day-scale precision. Four short lines including zero idle drain.
- **4B: Per shot + shots left only.** Simpler and avoids any theoretical time estimate.

Build estimates on hover and invalidate cached results on relevant inventory/module/head/power changes. Existing UI refresh may notice external changes by comparing a small signature, but must not rerun duration calculations on every refresh or register an OnTick estimator. Rendering a cached bar still occurs as part of drawing the visible UI.

Ammo bars: preserve real chamber notation. The current overall ammo capacity includes loaded ammunition; reserve capacity must subtract currently loaded rounds to avoid presenting an extra independent 750-round reserve. Physical weight limits remain separate. Hover should explain shared total capacity without another permanent stat row.

### 5. Synergy scope

- **5A recommended: Bounded extra Fragment bursts.** One Synergy permits one extra five-fragment burst per fired shot; each additional Synergy permits one more. Eligible successful Splitter/Piercing hits compete for this allowance. Requires Fragment and at least one eligible secondary-producing module. Secondary fragments inherit their source hit's damage scaling. One secondary victim can trigger at most once per shot. Fragments never trigger more fragments or new Splitter/Piercing chains. No unlimited recursion, fixed queue budget remains enforced before committing effects. First version does not silently extend Execute/Initial Blow/Impact to all secondary hits.
- **5B: Chance per eligible hit.** Broader emergent behavior, but swingier damage/workload; percentage, stacking curve and burst ceiling would need an additional choice before implementation.
- **5C: Defer Synergy.** Ship the UI/targeting changes first.

Suggested name Synergy Module; alternative names Chain Reaction Module / Catalyst Module. Recommend loot-only base weight 1.5 and Large Expansion's pool eligibility for genuinely comparable availability, ordinary module slot/power load. This is proposed tuning, not already approved. No recipe selected or needed. Performance budgeting may defer shot/effects rather than silently promise infinite chains.

## Acceptance and pipeline

0.2.43 owner screenshots expose UI clarity issues. No Test Complete or transfer/performance pass was reported. Console review is recorded in TEST_v0.2.43.md. R3C7 remains active; R1C3 remains broader performance work. Planning documentation is mirrored under C108/C119; no source/package/version/install changes in this discussion.
