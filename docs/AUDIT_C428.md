# C428 - Sandbox, feedback and timing audit

2026-10-22. Owner reports new 0.2.64.4 findings and requests a complete settings review, audio/visual corrections, timing audit and progression assessment. This checkpoint records evidence and proposed patch scope. No gameplay, assets, settings, version or installed files are changed.

Inspected `codex/performance-barbed-audit` at cf55134115e056de49fdc7915cb18b0656c07238, fetched origin/dev and checked open PRs; draft PR1 remains the only open PR. Captured current SP 0.2.64.4 console and install identity at `diagnostics/captures/20261022-224045-0945`. No OMHTT exception stack was found in the captured session; unrelated translation, map and clothing-model warnings remain. Owner screenshots/report establish presentation failures regardless of automated tests. Unmentioned checks are not accepted automatically.

## Sandbox inventory and confirmed causes

Reviewed all **221 canonical definitions across eight pages**, their section mappings, translations, independent-package generation and relevant consumers. [Complete inventory](SANDBOX_INVENTORY_C428.md). Compared the current installed 42.21 scripts and Horde Night's `OMH_SandboxSections.lua` section metadata approach. Preserve saved IDs, values and independent Turrets/Traps operation; the inventory is a static review, not proof that every setting has been exercised in all native editors.

| Finding | Evidence and proposed correction |
| --- | --- |
| Potato Sound Volume in Sandbox | Legacy per-head playback gain in `PrototypeEffects.sound` and `TurretReloadAudio.play`; it does not control zombie hearing. Move player listening preferences to one Mod Options page, retain an internal relative mix, and preserve the saved setting through compatibility handling. |
| Potato hearing detached from head | `SandboxUI.groups` puts hearing/volume into a separate Audio section. More seriously, `TurretStats.hearingRadius` uses PotatoHearingRadius for every non-firearm head; firearms use native sound radius. Put each head's attraction setting in that head section, with old shared values carried forward rather than silently resetting them. |
| Potato above shared controls | Hardcoded group order, not a game limitation. Apply the owner's exact order below. |
| Spikes/barbs heading in Turrets | The turret friendly/hostile settings reuse `Sandbox_Title_OMHTurretsTraps_PlayerContact`. These are player-damage multipliers, not trap contact settings. Put them with turret General and label their scope accurately. |
| Inconsistent capitalization | Mixed seconds/Seconds/s, percent/Percent, `Maximum-range`, and even `( Percent)` coexist. Use consistent title case, unit spelling and short labels; keep IDs and saved numbers intact. |
| Enhanced Firing long decimal | Precision formatting only attaches to loot/rarity fields. Extend display formatting to all OMHTT numeric controls. Show 1.33 while preserving the exact loaded 4/3 unless the player edits it. |
| Button scientific notation | Same omission. Show 0.0001, not 1.0E-4 or 0.00. Use two decimal places for ordinary values and enough fixed decimals for small nonzero values; tooltips specify percent per press versus percent per game hour. |
| Automation page | Three options only. Retire Enable Automation as requested; move live cone/scan settings into Turrets > General. Remove its runtime master veto as part of that retirement, while preserving turret ON/OFF, modules, trigger gating and Horde Night permission checks. |
| Forward Cone is not universal | `TurretModules.profile`: general default 90; Ballista overrides to 45, Scrapshot and rotary to 90, 360 overrides all. Setting the shared value to 360 currently also bypasses those fixed cones. Explain the base cone and overrides; do not silently change head geometry during reorganization. |
| Detection Interval is live | Ordinary scans use .25 seconds. Enhanced Detection chooses the lower of the base interval and its .1-second setting. Rotary also uses it. It remains useful for reaction/performance tuning; module options do not make it obsolete. |
| Barbed Contact and Player Contact | They control distinct things: zombie damage/slowdown versus player running scratches/sprint trips. Present clear Shared Contact Rules, then item-specific groups; do not falsely label shared player rules as exclusive to one trap. |
| General poorly scoped | Three entries: two awkwardly labelled package enables and a range-display toggle. Rename the enables clearly; move personal range visibility into consolidated Mod Options. Keep only actual cross-feature policy in top-level General. Do not create extra sidebar pages for individual heads/traps. |
| Duplicate Mod Options | `ClientOptions` registers ID OneMoreHorde_TurretsAndTraps titled OMH: Turrets; `ControlOptions` registers OMHTT titled OMH: Turrets & Traps. Consolidate under one page, preserving both old preference stores and independent-package loading. This is two distinct registrations, not simply duplicate initialization. |
| Volume control coverage | Local FeedbackVolume and DeviceSoundVolume affect device/Arc audio, but ordinary projectile/proc/reload playback has separate paths. A true local master must cover all OMHTT playback without changing unrelated native sounds or attraction radius. |
| Missing mapped settings | Some late additions fall into the unmapped tail, including Rotary Blades/Lobber battery multipliers and Grid/Lure/Void loot entries. Every surviving field must belong to a meaningful section. |
| Misleading Potato enable behavior | Disabling PotatoTurret also stops all module loot/packs in ModuleLoot/TurretModulePack and affects non-custom heads in Turret.cycle. Separate the Potato head toggle from overall turret/loot enable semantics; preserve TurretsEnabled as the package-wide switch. |

Owner-specified order inside **OMH: T&T - Turrets**:

1. General
2. Standby
3. Storage
4. Rotary Bat
5. Rotary Blade
6. Potato Launcher
7. Scrapshot
8. Ballista
9. Arc Emitter
10. Lobber
11. Firearms

General contains shared base health, power policy/base costs, idle sweep, targeting scan/cone and player damage controls. Put head-specific power and attraction beside each head's combat settings; module power scaling belongs under Modules. Storage contains shared capacities with labels that distinguish head-specific storage overrides. Keep the controller/trigger groups together and expansion bonuses under Modules. Traps gets clear shared rules and Spike Barrier, Bed Spikes, Barbed Panel, Concertina Wire, Poke Floor and Tether Dart sections. Native subsection titles follow Horde Night's style without changing sibling code.

## Rarity selectors and compatibility

Recommended: normal controls show a rarity dropdown for every lootable component, grouped by Performance, Automation, Effects, Utility and Expansion Kits; within each group sort Abundant through Mythic, then localized name. Sort when opening/rebuilding the panel, not while the player is editing it. Include Disabled and an advanced Custom state for weights that do not match an anchor.

A tier selection must resolve to that tier's configured weight, and the same result must feed loose loot, packs, tooltip colors, module icons and power surcharges. Rarity changes are balance changes, not cosmetic-only selections. Disabled components must also leave the pack pool. Craft-only Makeshift items should not get inert loot controls.

Preserve saved LootLab overrides and presets instead of rounding them into the nearest tier on load. Do not create two independently editable sources of truth. Implementation must cover new-world Sandbox, host editor, live-admin editor, import/export, Traps-only expansion loot and LootLab's existing numeric format. If explicit persisted tier selections are introduced, legacy/custom is the compatibility default; old saves must not be overwritten by new enum defaults. Editing an anchor must keep explicit tier assignments aligned. This turn does not deploy LootLab or convert settings.

## Audio and visuals

**Fragment:** `TurretVolley.tick` unconditionally plays OMHTTSuppressedM9Shoot once per Fragment group. Retain that cue for firearm fragments; resolve the originating head's firing cue for other heads and attenuate the burst. Emit once per burst with existing rate limits, not five copies. Head audio metadata should support third-party adapters instead of hardcoded weapon lists.

**Arc impact:** `TurretArc.complete` already emits ArcHit on confirmed positive damage; `TurretArcAudio.receive` selects DismantleFailed. Playback gain .12 and four starts/100 ms make it quiet and can coalesce simultaneous impacts. Preserve this sample, raise its usable level, keep a bounded overlap policy, and distinguish sound-event timing from damage confirmation.

Measured current assets/native diagnostic captures with production relative gains, mono-averaged stereo, 50 ms RMS windows and an ungained -50 dBFS activity gate. These are reference **dBFS**, not calibrated in-game SPL/LUFS or a distance/occlusion guarantee. Native event capture and file playback have different spatial processing. [Measurement evidence](evidence/c428-audio.json).

| Reference cue | Active RMS dBFS | Peak dBFS |
| --- | ---: | ---: |
| Arc firing, gain 1.3 | -35.70 | -15.23 |
| Arc impact, gain .12 | -43.78 | -20.42 |
| Potato first firing clip, script .7 and playback .35 | -30.55 | -12.22 |
| Suppressed M9 file | -22.98 | -5.58 |
| Suppressed M16 file | -24.32 | -5.82 |
| Native M9 reference | -20.15 | -.98 |
| Tether launch | -23.16 | -4.02 |
| Poke strike | -21.95 | -3.74 |
| Rotary movement | -26.11 | -12.69 |

Arc firing is about 11-13 dB below the suppressed firearm files; the impact is lower still. The prior doubling was insufficient. Normalize/adjust the firing family toward a comparable reference (roughly within 3 dB), check peaks and simultaneous chains, and keep quieter secondary/reset/switch cues intentionally below primary attacks. Retain Suppression's audible benefit and keep audio volume independent from zombie hearing. A measured gain is not a substitute for the owner's final spatial listen.

**Arc appearance:** the new texture contains pale core/alpha falloff, but the native basicEffect shader multiplies color by ambient/directional lighting. It is not emissive, and no IsoLightSource exists for the Arc. Crossed transparent planes in the opaque item path can also expose depth/blending seams. The screenshot rejects current rendered acceptance. Fix through an emissive white core and correctly composited feathered blue halo in world space; verify transparency/depth from both camera directions. Texture color alone cannot guarantee a glowing white core under this shader.

**World light:** requested scope is a small, brief pooled light around discharge/near impacts, not one light per segment or branch. Recommend a global cap of four active lights per client, local light/flash disable and intensity controls, and cleanup on expiration/unload/reset. Installed IsoLightSource has native color/radius/lifetime methods; Lua exposure and chunk-light updates still require a native implementation probe. Do not claim GPU or performance success in advance.

**Laser:** `ControlTriggerView.render` draws through OnPreUIDraw; it cannot be occluded by actor depth. `ControlBeam.length` shortens at world obstacles, while `ControlSensor.step` only records actor occupation and leaves full beamLength. Move the beam to native world rendering and use the nearest intersecting live actor as its visual endpoint, reusing the bounded sensor scan. Keep configured detection reach, defaults/off preference and opacity control. Do not scan every actor per rendered segment. Standing/crawling targets, walls, camera depth and multi-client snapshots need verification.

## Timing audit

The requested confirmation is **no: gameplay does not consistently follow fast-forward today**. The full-source time-call search identifies 91 files; the subsystem review separates simulation, presentation, authority and performance clocks. The shared ActiveTime.step only accumulates unpaused wall milliseconds; it never applies speed. Source evidence establishes this defect; no exhaustive runtime fast-forward pass is claimed.

| System | Current behavior | Correction boundary |
| --- | --- | --- |
| Placement, pickup, repair | Custom SP actions advance using native multiplier/time-delta ratio; MP getDuration uses native action duration | Preserve and verify all action families, cancellation, fast-forward and pause; do not replace with wall sleeps |
| Native crafting/building | Native timed actions | Keep native scaling; inspect custom placement interception separately |
| Turret fire/reload/rack/turn/standby | TurretClock built on ActiveTime | Simulation-speed clock, preserving normal-speed durations |
| Arc hops, Splitter/Fragment, Martyrdom, ordnance fuse/travel | TurretClock deadlines | Same simulation timeline; bounded processing, no catch-up damage burst on wake |
| Tack lifetime, arming, contact and saved remainder | TurretClock; server sends relative remaining times | Expire with simulation time, correct client interpolation and save/load; do not leave old fields active after a time skip |
| Tether and Poke cycles | Separate ActiveTime clocks capped to 250 ms per update | Account for skipped time safely; simply multiplying then discarding excess would lose time |
| Bed recovery and barbed contact | ActiveTime in BedSpikes/BarbSections | Simulation-time contact/protection intervals |
| Knockdown, some injury guards, trigger recovery | Direct wall timestamps in combat/controller code | Distinguish gameplay protection durations from anti-replay/network safety timers |
| Controller idle/held-trigger power | World-age hours | Already speeds up; retain elapsed-time accounting and supply rules |
| Rotary motion versus energy | Motion uses TurretClock; energy uses world-age hours | Currently charges faster during fast-forward without equivalent motion speed; align their simulation basis |
| Lure interval | TurretClock | Scale gameplay attraction cadence; avoid overlapping catch-up sound bursts |
| Client Tether interpolation/Tack snapshots | Wall/relative clocks | Must agree with server speed and pause; stale-network cleanup remains real-time |
| Sound tails, UI animation, notification fades | Presentation time | Keep real-time readability and playback; separate from gameplay deadlines |
| Discovery, caches, network leases/retries, anti-replay, profiling/draw budgets | Wall time | Keep wall time; speed must not multiply CPU budgets or prematurely expire network work |

Interpretation: a nominal ten-second Tack lasts ten seconds at normal speed and about 1.67 wall seconds at 6x, subject to the engine allowing that speed. Do not reinterpret it as ten accelerated world-clock seconds at normal speed. Sleep/large jumps must expire fields and advance state safely without recreating every missed attack. Server authority, remaining-time persistence, Horde Night permissions and bounded work remain requirements. A blind global ActiveTime replacement would also change audio cleanup/UI and is inappropriate.

## Progression and remaining decisions

[Current progression analysis](PROGRESSION_C428.md) distinguishes recipe/loot math from calendar estimates. No new recipe, loot, battery or combat defaults are approved by an audit request.

1. **Corrective scope:** 1A recommended - settings/Mod Options cleanup, head-correct audio and mix, Arc/laser rendering, bounded light and the simulation-clock correction together, in independently verified internal slices. 1B - settings/audio/visual fixes first, then the known timing defects in a second patch.
2. **Loot controls:** 2A recommended - category/tier/name dropdowns with Disabled and compatibility-preserving Custom values, consistent with LootLab. 2B - tier-only controls and an explicitly reviewed conversion of old custom weights. 2B changes saved balancing and is not recommended.
3. **Progression direction:** 3A recommended - keep starter traps accessible; design distinct advanced skill/component/unlock steps and review pack supply before changing numbers. 3B - retain current soft progression and chiefly tune acquisition probabilities. The next progression proposal must include concrete costs/gates and scenario comparisons; neither choice silently authorizes a new loot item or numerical rebalance.

Installed build remains 0.2.64.4. This is an audit/planning checkpoint, not another owner test request. **Decision needed.**
