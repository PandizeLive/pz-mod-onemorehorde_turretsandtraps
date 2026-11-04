# C438 - Tooltip consistency, expansion replacement and stacking audit

**C444 update (2026-10-24):** Owner selects C443 **1A**. The selective table and combined correction scope are implemented in [0.2.66](PATCH_v0.2.66.md); [verification and delivery](TEST_v0.2.66.md) distinguish automated evidence from pending owner acceptance. Earlier proposal/status wording below is historical.

**C439 update:** [Rarity-first 1B is selected; stack-cap policy is superseded](MODULE_STACKING_C439.md). The historical C438 diagnosis and measured arithmetic below remain valid for installed 0.2.65. The recommendation to retain existing bonus caps is superseded by the owner's stacking-based balance direction.

Date: 2026-10-24. Installed/tested version: **0.2.65**, immutable `test/v0.2.65`, source `8a977bc60ea4845646f8bfb20a8eb7d7cd4b5f19`. Investigation began on documentation HEAD `659315bdb98d0f5a76fdd0c032b01dc369a9bd47`, branch `codex/performance-barbed-audit`. Origin/dev and the existing development PR were checked; no incoming decision conflict found.

Status: owner feedback and requested behavior recorded; source diagnosis and numerical comparison completed. **No gameplay, package, installed build, version or Workshop changes.** The project test-feedback discussion rule applies before implementing this next scope. Sorting remains a concrete choice; the tooltip and inactive-storage directions below do not need another questionnaire.

## Owner directions

- Color trigger Battery Consumption ratings with the existing OMH spectrum. Remove raw cost/unit, Power Source and Additional Draw lines; do not change consumption.
- Use a readable grey `Feature:` description across OMHTT items, including heads and modules. Preserve grey across every wrapped continuation line. Keep Damage and Health separate where relevant.
- Expansion kits use readable grey `Controller:` and `Turret:` benefit rows, without a redundant Feature row. Retain useful rarity information.
- Review descriptions for useful player behavior, removing implementation/service clutter. Poke Floor example becomes "Feature: Pressure-operated floor spikes that repeatedly stab targets." **Current default damage remains 45, health 200.** The owner's illustrative 50 is not treated as a separate balance approval; display actual loaded settings.
- Permit modules in unavailable expansion slots, greyed out and labelled Unavailable, with no active benefits. Allow expansion replacement; move only excess ammunition to player inventory, then floor if full.
- Report unsupported-head modules explicitly in the yellow feedback area.
- Compare 16 Rapid Fire against 16 Velocity. Audit request does not authorize changing their balance.

## Confirmed causes and tooltip scope

`ControlTooltip.lua` wraps a plain description and colors only visual line index 1 grey. Wrapped lines therefore become white. `ControlItemDescription.lua` requests `ControlConsumption.description(kind, false)`, discarding the returned color; that plain string includes all four unwanted consumption/source lines. Head consumption already has a separate colored renderer in `TurretItemTooltip.lua`.

Expansion kits currently participate in both the control-description footer and the turret-description footer. Their generic Feature/Stackable/Drain output overlaps ownership of the tooltip footer. The outer redraw can cover prior footer content; this is a source-supported explanation for the dark controller line, **not a newly rendered reproduction**. Use one semantic row/layout owner with explicit colors rather than string-index color rules. Cache by description/settings/font and preserve independent Traps/Turrets packages.

Audit coverage: traps, triggers, Controller, turret base and installed contents, custom/firearm heads, modules, expansion kits, packs, Makeshift Bomb and manuals. Relevant files are `ControlTooltip.lua`, `ControlItemDescription.lua`, `ControlConsumption.lua`, `TurretItemTooltip.lua`, `TurretDescriptions.lua`, `Turret.lua`, and EN `UI.json`/`Tooltip.json` under `Source/42.20/media/lua`.

Concrete copy corrections to include in the proposed patch:

- Bed Spikes should explain their effect on zombies as well as the meaningful careful-walking rule; barrier text must retain the safe rear distinction.
- Poke uses the requested short repeated-spike description. Tether retains the automatic-versus-linked activation distinction, without unnecessary placement/service prose.
- Button, Lever, Plate and Laser retain their distinct activation behavior. Lever OFF veto is meaningful information. Laser beam colors are optional presentation and should not dominate its feature description.
- Fragment's "bullet endpoint" wording is wrong for nonfirearm heads. Enhanced Firing's "firearm cadence" wording is too narrow. Accuracy's firearm-only wording omits supported Ballista use. Module Pack can award kits, which its description currently omits.
- Display loaded effect values instead of misleading hardcoded numbers where Sandbox tuning changes the benefit. Preserve native manual learned-recipe presentation rather than replacing it with an invented stat block.
- Base contents remain useful; add a concise grey feature rather than deleting the contents summary. Existing native fallback descriptions must agree with the custom tooltip when that fallback is used.
- Damage/Health are meaningful for traps and heads; do not invent meaningless damage/health rows for every module, manual or trigger.
- Kit turret ammo bonuses depend on the head. Use truthful generic capacity wording in inventory where no target head exists; show concrete projected effects in the receiving device UI. Controller tier benefits are +10 range/+100 weight per tier at defaults, with loaded Sandbox settings respected.

## Expansion replacement and unavailable slots

The present code has no complete kit replacement transaction: `Turret.accepts` rejects a kit if any kit is installed, while `Turret.canRemove` checks capacity with **no** kit installed. `TurretSlot` only passes an occupied module slot to the existing replacement action. The incoming kit's final capacity is never evaluated as a single swap.

`Turret.contents` currently activates all healthy compatible installed modules, without applying a slot limit. Merely allowing insertion and changing slot colors would therefore produce hidden active effects and battery drain. Authoritative content resolution must distinguish stored modules from active modules before UI insertion is relaxed.

Recommended implementation contract:

1. Keep the configured maximum physical module count (16 with current defaults), with the current kit determining active capacity (2/4/8/12/16). Native physical weight limits still apply. Inactive storage is not unlimited.
2. Persist module activation priority by exact item identity. The active subset, its ordering and the unavailable subset must survive save/load and synchronization. Inactive copies provide **no stats, automation, Siphon, power access or battery surcharge**. Existing in-flight actions retain their captured rules.
3. Sort the active and unavailable groups for presentation only. Sorting, rarity changes in LootLab or names must not decide which module silently turns off. Use an explicit drag swap between active/unavailable modules to change priority. Preserve existing installed priority on adoption.
4. Replace a kit as an authoritative exact-item operation with a preview of final capacity. Respect reach/access, favorites, ownership and current inventory state. Return the old kit safely; never destroy or duplicate it.
5. Evacuate only ammunition that exceeds the replacement's actual final capacity. Prefer player inventory; drop remainder at the turret square when full. Use bounded transfer batches. Keep charge, condition, ammo types, chamber/clip contents and fractional Conservation debt valid. Preserve Void contents/debt; do not convert virtual contents into duplicated physical ammunition.
6. Downgrading can deactivate Magazine, Void, Firing or Detection, not just numerical damage bonuses. Recompute their actual storage/operating consequences and display the unavailable state. Transfer failures must not leave a half-applied kit swap.
7. Keep Controller stockpile replacement behavior separate: the request is turret ammo overflow, not automatic dumping of the Controller stockpile. An adjacent existing module-swap check hardcodes Controller capacity 500; correct it to the actual loaded expansion capacity within the same transfer validation audit.
8. Check `TurretHeads.supports` before generic capacity failure in both client feedback and authoritative rejection. Use the specific head/module incompatibility reason in yellow feedback for normal insertion and swaps.

The operation requires targeted persistence, overflow and authoritative transfer tests; a successful local UI mock alone would not establish connected-client acceptance.

## Sorting choice

**1A - Category, then rarity, then name (recommended).** Performance, Automation, Effects, Utility; highest rarity first within each category, alphabetically within equal tiers. Expansion kits remain in their dedicated slot. Sort active and unavailable groups independently and preserve activation priority.

**1B - Rarity, then category, then name.** Highest rarity first, producing stronger color bands; related functions are separated across tiers. The same independent activation priority applies.

Neither order has been selected by the owner. Recommendation favors finding related functions; 1B favors visual color grouping. Avoid a large new filtering UI for a 16-slot grid.

## Rapid Fire versus Velocity

Executed the shipped `TurretStats.resolve` and `TurretBatteryEstimate.duration` under the stock game's Kahlua runtime with all **240 numeric/boolean source Sandbox defaults** loaded. Gun fixtures use the installed Firearms B42 M4/M9 script properties, with effective M4 damage/cadence/reload/rack cross-checked against the captured 0.2.65 session. This is a theoretical steady-fire calculation, not a measured live combat benchmark. Source execution exits 0; raw probe and output remain local in `diagnostics/c438/`.

At defaults:

- Rapid Fire gives +25% firing rate per copy, capped at +200% (3x cadence) at **eight copies**, subject to head timing/minimum interval and reload. Rack time also benefits where applicable.
- Velocity gives +20% damage per copy, capped at +100% (2x damage) at **five copies**. Extra copies can still increase knockdown where that head's implementation consumes the knockdown stat, up to its cap.
- Copies beyond the benefit cap still contribute module battery surcharge. Rapid Fire is Common (+0.25 base cost each); Velocity is Rare (+0.75 each), so these sixteen-copy loadouts have **5x versus 13x per-action module load** before other energy rules. Faster firing, head-specific damage-cost factors and rotary motor accounting prevent interpreting that ratio as a universal battery-lifetime comparison.

| Head | Base raw DPS | 16 Rapid Fire | 16 Velocity | Rapid multiplier | Velocity multiplier |
| --- | ---: | ---: | ---: | ---: | ---: |
| Potato Launcher | 17.50 | 31.50 | 35.00 | 1.80x | 2.00x |
| Ballista | 40.00 | 85.71 | 80.00 | 2.14x | 2.00x |
| Scrapshot | 152.38 | 355.56 | 304.76 | 2.33x | 2.00x |
| Arc Emitter, per chain victim | 20.00 | 60.00 | 40.00 | 3.00x | 2.00x |
| Rotary Bat | 33.33 | 100.00 | 66.67 | 3.00x | 2.00x |
| Rotary Blades | 66.67 | 200.00 | 133.33 | 3.00x | 2.00x |
| Lobber, nominal payload | 27.27 | 58.70 | 54.55 | 2.15x | 2.00x |
| M4, installed Firearms B42 | 436.30 | 536.57 | 872.59 | 1.23x | 2.00x |
| M9, installed Firearms B42 | 145.78 | 295.17 | 291.56 | 2.02x | 2.00x |

Method (description corrected C442; numerical results unchanged): `damage * magazine * 1000 / duration(stats, head, magazine + 1)` for one complete steady magazine cycle, including reload and rack delays; Arc uses damage divided by its shot interval. This was not a large-shot-count simulation. Rotary uses its default 90-degree sweep hit cadence against a continuously available victim. Lobber is nominal direct payload scaling, not an explosion-falloff/AoE encounter simulation. Fragment, Splitter, splash, knockdown, accuracy, crits, armor, overkill, acquisition, turning and target scarcity are excluded. No Enhanced Firing or other modules are installed in these comparisons. Sixteen modules fill all default slots, so this is not an autonomous Detection/Firing loadout.

Conclusions:

- **Not equal across heads.** M4 quickly reaches its minimum firing interval; Velocity yields about 63% more raw DPS than sixteen Rapid Fire. M9 is approximately equal. Arc/rotaries favor Rapid Fire for raw damage throughput; Ballista/Scrapshot/Lobber differ less after reloads.
- Raw DPS is not kill throughput. Once a hit already kills, extra Velocity damage can be wasted while faster firing remains useful. Ammo efficiency, control, power and rarity are separate benefits/costs.
- Arc's main-contact code does not consume Velocity's knockdown stat; Lobber's contact code uses Impact rather than that stat as well. Do not advertise universal Velocity knockdown or assume all sixteen copies add useful control. Changing this behavior would require separate balance scope; truthful descriptions are part of this audit.
- Recommend keeping their distinct roles rather than forcing sixteen-copy DPS parity, and making caps/head applicability visible. A rebalance is a separate discussion, not a prerequisite for the tooltip/kit fixes.

## Evidence and handoff

Captured `C:/Users/bandi/Zomboid/console.txt` for the owner session: 0.2.65 SP diagnostics, failed module-transfer admissions and tested head-stat output. No OMHTT-attributed exception stack was found in the inspected log. Existing vanilla/map and Firearms translation/model warnings do not explain the deterministic tooltip/capacity defects. This is not a clean-console or all-features acceptance claim.

Console snapshot, hash/provenance, source probe and output are local under `diagnostics/c438/`. [Versioned feedback](TEST_v0.2.65.md#c438-owner-feedback-2026-10-24) preserves owner-reported failures separately from previous automated checks. New rendered, multiplayer and gameplay acceptance has not been claimed.

**Decision needed:** choose 1A or 1B sorting and confirm the presented corrective scope under the project's discuss-before-patch rule. No numerical rebalance is proposed or applied.


## C440 - Module icons overlap labels after Details or resizing (2026-10-24)

Owner reports module icons drawing behind text when opening Details or resizing Turret Management. Add to the same pending corrective scope; no new visual-design choice is required. Rarity-first sorting stays selected. C439 additive/diminishing stacking choice remains open.

Confirmed source cause: `TurretManageGeometry.apply` reduces module tile height to as little as `lineHeight + 8` when vertical room is limited. In `TurretSlot.prerender`, `narrowModule` changes the name position to x=24/y=4, but a populated icon still draws at the tile's horizontal center/y=3. Only the empty-slot hint switches to the left. At line height 16, tile 108x24, the real icon rectangle is x=48..60/y=3..15 and the text clipping rectangle is x=24..104/y=4..24: **132 square pixels of overlapping layout area**. This is deterministic source-coordinate evidence, not a new rendered screenshot or native-font glyph measurement. Local calculation: diagnostics/c440/layout-evidence.json.

Related reflow risk: `TurretManageLayout.refresh` calls geometry before wrapping the current Details lines; geometry consumes the previous `detailLines` count and its cache key omits that count/font metrics. Verify current text measurement and final window dimensions are used in one consistent reflow, including repeated Details toggles and both resize axes. This is an additional code-review concern, not a separately reproduced visual failure.

Correction contract: derive icon bounds and label bounds together. In compact rows use a left icon with a reserved text inset; in taller tiles use separate icon and label bands. Keep populated, empty and stored-unavailable slots consistent; scale/clamp icons and clip/ellipsize names within the cell, preserving full hover text. Retain the selected four-column grid and rarity-first ordering. Recompute from current dimensions/font/Details content without stale offsets or per-frame full remeasurement. No owner artwork changes.

Verification planned with the patch: populated/empty/unavailable slots across the compact threshold, several font heights, repeated open/close Details and grow/shrink widths/heights; assert nonoverlapping rectangles and valid clipping, then include a short rendered owner check. Existing geometry tests did not prove icon/text separation. No source/package/version/install changes or new rendered pass this turn.
