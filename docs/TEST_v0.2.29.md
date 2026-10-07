# 0.2.29 owner test: loot review and remaining steps waived

On 2026-10-06 the owner supplied two screenshots of heavily stocked medical containers and asked whether the split increased global loot or whether component jackpots affect ordinary loot. The owner explicitly skips the remaining checklist because much of the underlying gameplay was already proven. Do not request the rest of this regression round again or record unperformed checks as new passes.

## Evidence

Console snapshot: `diagnostics/captures/20261006-201338-1594/console.txt`, captured through OMH.cmd. It records 0.2.29 Traps-only and Turrets-only client startup. The latest world is `Sandbox/2026-10-06_19-55-16`; its mods.txt contains PixelStrikeIndicator, firearmmod and OneMoreHorde_Turrets. These are startup observations, not acceptance of every gameplay scenario.

Both logged worlds report `MedicalLootNew=0.6` and `RollsMultiplier=1.0`. Turrets startup reports `module-loot-summary multiplier=1 pools=16` once. There is no elevated general roll multiplier in these settings. RangedWeaponLootNew is 1.2, independently of medical loot; no OMHTT code writes these vanilla settings.

Comparing annotated test/v0.2.28 and test/v0.2.29, LootDefinitions.lua is identical after ignoring line endings. ModuleLoot.lua changes only the enable gate from Enabled to TurretsEnabled. Its merge adds/removes recognized OMHTT components in sixteen named electronics/mechanics/tool/gun-accessory pools; it does not alter native item weights, pool roll counts, medical/bathroom distributions or global Sandbox loot values.

The global control in ModuleLootRate means all OMHTT loot components, not all game loot. Jackpot is the LootLab label for a five-or-more-component haul produced by the existing rolls/weights; no gameplay jackpot pass boosts a container's other contents. The startup ItemPickerJava.Parse call rebuilds the native tables: installed 42.21 JAR bytecode explicitly clears general and procedural maps before parsing, rather than appending duplicate tables.

The screenshots contain vanilla medical supplies, including scalpels, medical scissors, surgical gear and tongue depressors. Installed vanilla Distributions.lua defines Nurse profession-house loot for bathrooms and other rooms; its NurseTools pool includes these specialist medical items and heavier/duplicate bandage and pill entries. This is a plausible native explanation for medical-rich household containers. The screenshots and available log do not identify the exact assigned building story/container table, so a Nurse house is a hypothesis, not a confirmed diagnosis. No OMHTT loot regression or corrective gameplay change is established.

## Outcome

Keep existing loot tuning. Remaining 0.2.29 owner checks are waived at the owner's request; earlier evidence and native split checks remain intact. Future patches should request focused checks of changed behavior and credible regression risks rather than automatically repeating all historical gameplay. No package changes, publication or fresh broad test round follow from this report.

## Ten-turret performance follow-up (2026-10-06)

Owner reports ten potato turrets with no noticeable lag, requests confirmation of existing performance work and offers for remaining improvements. This is positive observed evidence for that scenario, not a measured GPU/frame-time benchmark or a firearm/max-module density result. This request authorizes review and proposals, not implementation of a new gameplay patch.

Captured the later console through OMH.cmd at `diagnostics/captures/20261006-204724-1703/console.txt`. Fifteen firing-summary intervals cover 152 fire-result events. Thirteen interval maxima are 1-3 ms per firing operation; the two outliers are 893 ms (892 ms in effects/audio) and 273 ms (272 ms in effects/audio). A later audio maximum is 47 ms. These are wall-clock helper timings, not total frame cost, percentiles or proof of sound decoding as the cause. The E.sound helper includes emitter acquisition, playSound, pitch and volume setup. OS scheduling/GC or other interruptions are not excluded. Investigate individual calls and cold-versus-repeated playback before proposing a native-supported mitigation.

Existing safeguards confirmed in source: TurretScheduler has a rotating shared 3 ms soft budget; searches advance in bounded slices; aiming, feeding and impact work have count/time limits; W.contents caches bounded-lived inventory summaries; configuration refreshes coalesce; valid targets are retained; firearm profiles cache by type; Manage refreshes at 200 ms; diagnostic output batches/caps; effects are capped at 64 and drawing has visibility gates. A synchronous native operation can overrun the soft budget.

Remaining offers, in priority order:

- Investigate measured audio-call outliers and mitigate only after finding their cause.
- Gate shot-reaction observation creation/processing behind detailed diagnostics; currently up to twelve observation records are maintained and native zombie state is sampled even with diagnostics disabled. Normal diagnostic mode also emits per-hit observation lines instead of summary-only output.
- Avoid per-tick idle visual animation for unseen heads and stagger renderer housekeeping. Actual drawing already has visibility/floor/distance checks; combat/target orientation must remain correct when returning to view.
- Reuse calculations within a work step where safe. A.step can repeat an identical clearLane check on a retained target, and aiming recalculates contents/profile independently. Preserve the final authoritative inventory/power/obstruction check at shot commit; broader caching needs explicit invalidation for configuration and world changes.
- Optionally measure mixed rapid-fire guns/max-module loadouts and total render/frame cost. Existing shot timing does not cover all rendering and maintenance; this is an additional stress scenario, not a request to repeat the waived full gameplay checklist.

TurretRenderer.lua also defines restoreDraw twice identically. Removing that duplicate is maintainability cleanup with negligible runtime benefit, not a substantive performance improvement. Recommendation: prioritize the audio investigation and diagnostic gating; avoid a speculative scheduler rewrite. No runtime files changed in this review.

## Heavier-load pauses reported (2026-10-06)

Owner subsequently added numerous modules, observed more zombies and reports disruptive pauses estimated at 300-700 ms, possibly outside that range. This supersedes treating the earlier ten-potato-turret observation as sufficient evidence for the heavier workload. Module configuration, exact simultaneous zombie count and frame-time attribution were not recorded, so neither modules nor zombie density alone are established as the cause.

Preserved console through OMH.cmd at `diagnostics/captures/20261006-205415-1899/console.txt`. Later summary intervals contain E.sound wall-clock maxima of 313, 386, 434 and 778 ms, plus 78, 186 and 230 ms outliers. Most firing preparation/combat and direct-hit maxima remain 0-2 ms in those same intervals. At frame 57193, the 230 ms fire maximum is entirely in the effects phase with a matching audio maximum. Other large audio outliers occur while launch-side fire maxima remain 1-3 ms: impact audio uses the same helper, and those delays are outside W.fire's timer. Summary aggregation does not retain individual sound names or align each measurement to a user-observed pause.

Conclusion: repeated stalls inside the audio helper are now a concrete leading suspect, consistent in scale with the owner's experience. Native emitter acquisition, sound playback, pitch/volume setup and external GC/OS interruptions remain unseparated. A soft Lua scheduler budget cannot interrupt a blocked native call. Current logging does not measure all target searches, renderer costs or total frame time, so it does not rule those out.

Recommended corrective scope: split audio-helper timing by operation/sound identity using bounded diagnostics, identify the blocking call, apply a supported mitigation preserving sound variation/volume and zombie-hearing behavior, and gate reaction-observation work behind detailed diagnostics. Validate against the same save/loadout without another full gameplay regression round. Do not reduce zombie numbers, module effects or sound quality as an unapproved substitute. Gameplay changes remain subject to the project's diagnosis/scope discussion rule; no runtime changes were made for this report.
