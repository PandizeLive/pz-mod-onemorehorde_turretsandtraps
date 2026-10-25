# C465 - Owner test findings and proposed corrective patch

2026-10-25. Owner reports Test Complete for 0.2.68, with Custom rarity, missing Specialist icon, Horde labels/flags, rotary grounded hits, Controller collision and low XP. This is a failed/partial acceptance round, not approval of another gameplay patch. Installed versions remain T&T 0.2.68, Trait Shop 0.9.1 and Horde/Cure 0.6.16.6. Prior 0.2.67 acceptance remains closed.

## Evidence

- Stable capture: `diagnostics/captures/20261025-125054-8293`, from the owner's `console.txt` last written 12:49:55. All three intended versions loaded in single-player. No new OMH Lua exception stack was identified; absence of a stack does not establish correct payouts/rendering.
- Accuracy Custom generated **2,493** native `DoubleConfigOption.parse` errors for `OMHTurretsTraps.LootRateAccuracy`, `string=""`. The console also contains separate Firearms suppressor-translation formatting warnings and world/vanilla warnings; these do not establish an XP cause.
- Saved world `Sandbox/2026-10-25_12-20-37`: `mods.txt` and explicit console loads agree. Read-only copies of `map_sand.bin` and `global_mod_data.bin` were decoded using the installed 42.21 bytecode's serialization format, with exact end-of-file consumption. Source save files were not edited.
- The saved global ledger is from **12:31:07**, before the combat test completed. It contains the initial zero-XP character and no defense owners yet. It must not be represented as the final XP result. `players.db` is newer, but that does not make GlobalModData current. Console/save timestamps were rechecked and unchanged before handoff.
- Read-only origin fetch: `origin/dev` has no commits missing from current `codex/performance-barbed-audit`; private draft PR 1 remains the only open development PR. Four exact sibling-chat names required by Horde instructions were unavailable in the current thread inventory; local source/contracts were reviewed.

## 1. Custom rarity

`ControlLootUI.attach` creates a second combo next to the native numeric control and only follows its Y changes. Native `SandboxOptionsScreen:onPanelChange` repositions `panel.controls[name]` horizontally, while the separate combo retains its old position. The two controls do not share a maintained row width. The empty-value errors are independently confirmed by console; a blank edit must not be passed repeatedly into native parsing.

**Recommend 1A: retain Custom and repair its layout/validation.** Keep the combo and visible numeric entry within one responsive row, support keyboard/gamepad focus, and preserve the last valid value while an edit is incomplete. Retain imported exact LootLab values until explicitly changed. Verify new-game, server/admin settings and narrow/wide layouts.

**1B: remove direct Custom editing.** Preserve existing/imported custom weights and identify them as Custom; choosing a named tier remains possible. Never snap an imported override to a tier silently. This simplifies the UI but removes useful fine tuning. No selection inferred yet.

## 2. Turret Specialist icon

The native trait registration lacks a dedicated texture. All five manuals already use `MagazineElectronics01`. Installed `CharacterTraitDefinition` exposes `setTexture(Texture)` and uses a trait-specific path plus generic fallback at construction; an inventory item's Icon does not automatically become its trait icon.

**Recommend 2A: reuse the manual icon** at the native trait size. It describes learned knowledge and avoids tiny lettering. **2B: reuse the mod icon** for branding, subject to readability at trait size. Reuse existing artwork; no new art generation or trait cost/knowledge change.

## 3. Horde Run Options

Requested labels are recorded exactly:

- Enable Checkpoints (x1.0)
- Enable Trait Shop (x0.5)
- Enable Turrets & Traps (x0.2)

Remove `assistance (score /5)`. Render the multiplier as a separate colored suffix: grey neutral, red reduction, green any genuine increase. Verify native TickBox sizing rather than inserting unsupported rich-text markup. These are individual option multipliers; enabling both Shop and T&T still produces the existing combined x0.1 score factor. Preserve explanations that disabling an option cannot erase already incurred benefits/flags. This is score presentation, not another XP multiplier.

## 4. Flag diagnosis

The following loaded exact IDs are absent from `OMH_ModWhitelist`:

| Loaded ID | Current initial-mod handling |
| --- | --- |
| `ModLoadOrderSorter_b42` | Mod Added Denied |
| `PixelStrikeIndicator` | Mod Added Denied |
| `3019672735/ModComparer` | Mod Added Denied |
| `firearmmod` | Mod Added Denied |

`RunFlags.isAllowedMod` is an exact whitelist lookup. `DifficultyRuntime.classifyInitialMods` uses its failure to add Mod Added Denied, even when the mod was present from world creation. Each listed mod is therefore sufficient to trigger that current path. This is not evidence that any of them was reviewed and rejected. The older saved run record cannot identify a later UI audit entry. Horde's existing owner policy reserves red Not approved for confirmed exclusions and yellow Unknown for missing reviews; proposed correction must maintain that distinction without auto-approving these mods or rewriting legitimate historical scores.

The saved T&T values have **zero numerical/boolean differences from current source defaults** for the keys defined there. An isolated installed-Kahlua replay of the unchanged production `OMH_DefenseSettings.evaluate`, supplied with the saved settings and both enabled components, returns:

`hardened=true; lessened=true; hasUnknown=true; issues=151`

The policy still cites T&T 0.2.49; C464 added XP options without refreshing the rest. Examples:

| Setting | Saved/current default | Old policy baseline | Result |
| --- | --- | --- | --- |
| Rapid Fire additional bonus | 20 | 25 | Hardened |
| Potato magazine capacity | 3 | 1 | Lessened |
| Fragment damage | 25 | 20 | Lessened |
| Module loot multiplier | 1 | 1.011111111111111 | Unverified coupled change |
| Legacy Potato ammo capacity | -1 automatic sentinel | 100, minimum 1 | Invalid/unverified |

Removed caps and newly added settings cause further unknowns. Both difficulty flags can legitimately coexist for mixed adjustments, but current defaults must not generate this false mismatch. Refresh the complete effective-settings contract, exclude inactive legacy values, and add default-parity checks across Traps-only/Turrets-only/both packages. Preserve actual easier/harder classification and persistent history; investigate narrowly attributable stale-baseline evidence before promising existing-run cleanup. No run reset or flag deletion was performed.

The first standalone replay attempts lacked game-provided Lua helpers in the fixture. Loading the existing fixture bootstrap resolved that harness issue; the recorded production-policy replay above completed. This is a source/settings reproduction, not rendered UI acceptance.

## 5. Rotary ground targets

`TurretRotary.contact` checks actor kind, health, elevation, range, lane and arm crossing, but has no grounded/knockdown exclusion before target activation or direct damage. The reported behavior is source-supported. Proposed correction: exclude prone/knocked-down actors from rotary acquisition and direct arm hits, including grounded getting-up states until standing. Verify standing targets still work and a crowd entirely on the floor does not keep spinning through an invalid target. Previously spawned independent module effects retain their own contact rules.

## 6. Controller placement

Controller `SpriteConfig.OnIsValid` calls `ControlDefinitions.valid`, which only requires a square and `TreatAsSolidFloor()`. The authoritative timed action invokes that same callback but it adds no Controller-specific occupancy rejection. This explains the valid preview over furniture.

Add shared Controller occupancy validation used by preview and final authoritative completion, covering solid furniture/occupied device space while retaining normal floor/wall adjacency. Recheck after the placement delay. Do not apply a blanket rule to intentional floor overlays or wall-mounted triggers. Test clean floor, counter overlap and obstruction introduced during the action.

## 7. XP findings and verification gap

Saved Trait Shop settings are **RewardMode 4 (all sources)**, ordinary zombie XP 2 and Horde zombie XP 5. Shared defense XP is enabled at 50% for both packages. With one eligible owner and Shop earning enabled, that yields **1 Trait Shop XP per ordinary defense kill** and **2.5 per eligible Horde defense kill**. First level costs 100 XP: respectively 100 or 40 such kills from zero, excluding other awards. Faction recipients share one pool; they do not each receive a full reward. This integration grants Trait Shop progression, not native weapon-skill XP.

Horde's unofficial classification is tracked separately from earning permission; an unofficial payout can still be awarded when Shop is enabled. The score x0.2 is not an additional defense XP reduction. The saved pre-combat ledger cannot confirm the current run's Shop toggle or complete paid-kill count. Routine damage summaries count hits, not deaths or payouts. No new payout defect or balance adjustment is established from those logs alone.

Installed native `IsoZombie.onKilled` fires OnZombieDead before `IsoGameCharacter.Kill` marks OnKillDone, so the existing consume guard is not inherently skipping all normal native deaths. The pending corrective scope should include an actual lethal-hit-to-Trait-Shop-ledger test and bounded diagnostic counters for credited kills, payment totals and rejection reasons, plus save/reload. Avoid per-hit log spam and do not silently raise rewards to mask missing credit. Final live payout acceptance remains open.

## Proposed patch and approval boundary

Combine the selected Custom/icon choice, Run Options presentation, reviewed T&T policy parity, Unknown-versus-denied handling, grounded rotary exclusion, Controller occupancy and XP end-to-end verification/diagnostics. Fix a demonstrated XP defect if found; no reward rebalance or blanket mod approval is inferred. Coordinated Horde changes are part of this proposed scope. A broad review/approval of the four external mods is separate from identifying the current flag trigger.

Choices pending: **1A/1B Custom**, **2A/2B icon**, then approval of the combined corrective patch. Recommend 1A/2A. This turn changes documentation only and preserves the cumulative Workshop drafts. No new build, installation or owner retest. **Decision needed.**
