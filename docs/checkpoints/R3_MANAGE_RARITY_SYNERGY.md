# C155 - Manage boundaries, rarity, Once each and Synergy discussion

## C158 - selected module tuning and player injury options (2026-10-11)

Owner selects **1A terminal death-burst/Tack damage**, **2A Martyrdom on eligible projectile kills**, **3A ten-second Tack lifetime with rearming after expiry**, **4B linear +0.25-tile radius per extra module**, and **5B player interaction**. Martyrdom adds a **20-tile noise radius**. Owner requests options for minor explosion injuries, suggesting a bruise. This settles those choices and supersedes the once-per-zombie-lifetime Tack recommendation; player explosion injury remains a discussion gate.

Selected baseline: Martyrdom 20 zombie damage, base damage radius 1.5 tiles; Tack 10 damage every 2 seconds, half movement in contact, base radius 1 tile and 10 active-second lifetime. Radius stacks only: base + .25 * (workingCopies - 1). Martyrdom noise radius is 20, separate from damage radius and radius stacking. Native zombie-attracting world sound and audible pop are separate paths; provide both with appropriate presentation throttling that does not silently delete attraction events. No fire or wall/floor penetration. Player Tack traversal/injury follows existing barbs; player explosion damage must not reuse the 20-zombie-damage value.

Tack rearming: record next eligibility on the zombie across all turrets. A successful eligible hit drops one stationary field; hits during its ten-second lifetime do not refresh it or create more fields from that zombie. After expiry, the next successful eligible hit may drop another; expiry alone does not automatically spawn a field. This is independent of Once each round boundaries. Preserve elapsed active-time semantics, save/reload behavior and per-zombie deduplication. Dead zombies cannot rearm, but an already dropped field may finish its lifetime.

### Native injury evidence and proposed choices

Installed B42.21 `BodyPart` exposes `AddDamage`, `setAdditionalPain`, `setScratched`, `setCut` and burn APIs. Vanilla timed actions call additional-pain methods, and native ISHealthPanel has scratch/cut/burn treatment routes. No separate Bruise flag/status was found in the current BodyPart API or English health-panel strings; do not promise a named native Bruise wound. A bruise-like effect can instead use minor local body-part health loss and pain. Exact in-engine pain duration/display and local-to-overall health scaling need native verification before implementation values are certified.

- **6A recommended: minor blunt injury.** Proposed 2 health points of damage to one limb body part plus 5 additional pain; no new bleeding wound, fracture, burn, knockdown or infection. These are body-part units, not a promise of exactly 2 percent overall health. Preserve all existing injuries; no bandaging introduced by this effect.
- **6B: light scratch.** One native non-zombie scratch on a limb, with ordinary wound care/bleeding behavior; no added Knox-infection roll. A more visible/treatable health-panel injury, but harsher and less consistent with 'minor pop'. Do not fake a scratch as a bruise or erase pre-existing infection.
- **6C: soreness only.** Proposed +5 additional pain with no direct health damage or wound. Least punishing but does not implement actual health loss.

One remaining crowd-balance choice accompanies injury type: **7A recommended**, at most one Martyrdom player injury per one active second across all turrets; **7B**, every nearby burst can injure the player. Numerous small bursts can otherwise cause large cumulative damage. This proposed player-only protection does not limit zombie burst damage, world noise or guaranteed Synergy activation; it is not implemented or silently assumed approved.

No gameplay patch this turn. Retain C156 UI/targeting selections, C157 loot weights (Martyrdom/Tack 1.5, Synergy 1.0), single Synergy and eligible Fragment interactions. 0.2.43 test disposition remains unchanged. Next discussion is limited to 6/7; do not reopen settled choices.

## C157 - broader Synergy, Martyrdom and Tack (2026-10-11)

Owner selects **6B**, adds **Martyrdom Module** (zombies pop on death, nearby damage, stacks increase AoE distance, loot weight **1.5**) and **Tack Module** (first shot on a new target drops tacks, barbed-style contact slowdown and damage, stacks increase AoE distance, loot weight **1.5**). Owner explicitly requires Splitter and **Fragment** to trigger these through Synergy and changes **Synergy loot weight to 1.0**. Preserve the selected single installed Synergy and 100-percent eligible activation. These numbers are loot-distribution weights, not inventory encumbrance. With current positive weights Synergy becomes the purple minimum; per-world tuning can change that.

This supersedes the 6A recommendation and the prior Large Expansion-equivalent Synergy weight. Header bands, seven-color logarithmic rarity, Once each and cached battery estimates remain selected. New modules and broad interactions are design direction; numerical damage/radii/lifetime/trigger attribution and the chain graph are not yet settled. No gameplay patch or version bump in this discussion.

### Recommended interaction contract (not yet approved)

Without Synergy, new passives use primary projectile hits/kills. With Synergy, Splitter, Piercing and Fragment projectile hits gain the same applicable passives. Preserve Initial Blow's health gate, Execute's threshold and Impact's first-after-reload gate/chance; recommend one successful Impact stagger per original shot, not a new reload entitlement for each secondary.

Prevent repeated effect types within a projectile lineage: Fragment can carry Martyrdom/Tack but never spawn Fragment again, and no secondary recreates muzzle Splitter or Piercing routes. A Splitter/Piercing hit may produce Fragment; those generated fragments may then trigger the new passives. Thus the old blanket 'Fragment children cannot trigger module chains' recommendation is superseded. Synergy's 100 percent is eligibility, not a rewrite of another module's chance or conditions.

**1A recommended:** death-burst and Tack contact damage are terminal (cannot trigger additional modules). **1B alternative:** allow one additional Martyrdom generation, then stop; greater burst workload. Neither permits unlimited death/Fragment/Tack recursion. Fixed work budgets remain, but the scheduler cannot silently discard promised 100-percent activations; bounded admission/deferred work requires implementation measurements.

**2A recommended:** Martyrdom triggers when an eligible turret projectile kills a zombie; one burst, fixed **20 damage**, no fire, no wall/floor penetration. **2B alternative:** an eligible hit marks the zombie, and any later death triggers its one burst. This requires persistent ownership/mark rules and must preserve the actual killer's attribution. Same proposed damage. Both keep stacking limited to radius, not damage.

**3A recommended:** Tack is dropped at the first successful eligible hit position, once per zombie lifetime across turrets; the patch stays on the ground **10 active seconds**, doing **10 damage every 2 seconds** with **half movement only on contact**. **3B alternative:** same rules, **20 seconds**. No refresh on repeated shots. No per-round rearming through Once each. Overlapping patches do not multiply slowdown or DoT; recommend the same contact timer/nonstacking behavior with existing barbs. Generated fields are effects, not collectible constructed wire; no per-tack world object. Save/load/unload cleanup and exact first-hit persistence need native proof; do not claim current barb code already implements temporary fields.

**4A recommended:** base radii **1.5 tiles Martyrdom / 1 tile Tack**, radius = base * sqrt(1 + 0.5 * (workingCopies - 1)), so every extra module adds 50 percent of the base area without a hard stack cap. First three radii: Martyrdom 1.50/1.84/2.12, Tack 1.00/1.22/1.41. **4B alternative:** same base radii, +0.25 tile radius per extra copy; easier labels but area/workload grow quadratically. Radius, not damage/duration, is the requested stacking effect.

**5A recommended:** both new effects damage/slow zombies only. **5B alternative:** Martyrdom also damages players, and Tack uses existing barbed player movement/injury rules (safe walking versus running/sprint risk). Option 5B needs explicit player damage selection; do not silently apply zombie damage values to players. Existing trap behavior is unchanged by either choice.

### Feasibility and content follow-through

Installed `BarbRuntime` currently uses 10/2s and movement divisor 2; `BarbMovement.apply` scales pending displacement rather than storing/restoring base speeds. Temporary Tack needs its own lifetime/spatial index while reusing compatible movement/contact helpers; it must work with OMH: Turrets alone, not introduce a Traps dependency. Use a small reusable marker/decal and batched/cullable presentation, not an item/object per tack; final art remains owner-sourced. Both new modules need loot/Sandbox/tooltip/Installed Modules/LootLab coverage and ordinary slot/power accounting when implemented. Inventory weight, assets and precise pools remain proposed; preserve owner-selected loot weights. Martyrdom audio should be a bounded impact/pop cue with native pitch variation, not a full grenade blast/fire effect.

Planning records updated on `codex/performance-barbed-audit` after fetching origin. 0.2.43 acceptance stays pending; this is not a test completion report. Next discussion: choose 1-5 above, then settle any selected alternative's material rules before implementing.

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
