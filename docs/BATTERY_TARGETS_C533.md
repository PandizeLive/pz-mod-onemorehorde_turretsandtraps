# C533 - Selected battery endurance targets

Owner selects approximate **real-time continuous operation with normal Firing + Detection**, following the C532 converted runtime table: Scrapshot 30h, M16/M4 12h, Ballista 8h, Makeshift Lobber 6h, Arc 2h, Rotary Bat 4h, Rotary Blades 3h. Owner explicitly says exact matches are unnecessary and reaffirms decimal limits. Potato is not selected for change.

These are accepted balance targets, not approval of the still-pending C532 combined corrective scope. No gameplay, package, installation, server settings or sibling baseline changed this turn. Implementation belongs in the next prepared update; no additional target-selection question is required.

## Clean candidate settings and results

Existing controls suffice. Preserve module stacking, rarity surcharges, Regulator and the current time bases. Use current Testing settings (90-minute days; ordinary automation combined surcharge 1, enhanced combined surcharge 4). Do not force high-precision constants to match the hour exactly.

| Control | Current | Candidate |
|---|---:|---:|
| ScrapshotBatteryPercent | 0.0025 | 0.001 |
| FirearmBatteryMultiplier | 1.50 | 0.56 |
| BallistaBatteryPercent | 0.025 | 0.01 |
| LobberBatteryMultiplier | 1.50 | 0.65 |
| ArcBatteryPercent | 0.02 | 0.007 |
| RotaryBatteryHours | 6 | 128 |
| RotaryBladesBatteryMultiplier | 2 | 1.33 |

RotaryBatteryHours is a bare-head **game-hour** value, not real hours and not the normal-automation result. Its current 100 maximum would clamp this target. Raise the sandbox/resolver maximum to 200 when implementing; merely changing the default to 128 is insufficient. Other time settings do not need new caps or formulas.

| Head | Normal automation, real time | Enhanced automation, real time |
|---|---:|---:|
| Scrapshot | 29h10m | 9h10m |
| M16/M4 | about 12h | 3h51m |
| Ballista | 8h20m | 2h40m |
| Makeshift Lobber | 5h52m | 1h46m |
| Arc | 1h59m | 36m |
| Rotary Bat | 4h | 1h12m |
| Rotary Blades | about 3h | 54m |

Lobber uses one shared battery multiplier: Aerosol becomes about 3h55m normal/1h10m enhanced; Pipe Bomb becomes about 2h56m/53m. The firearm multiplier also changes other firearm heads proportionally; it is not M16-only. This shared behavior was disclosed to the owner; no new per-weapon option is requested. Potato remains unchanged.

These are power-endurance estimates with replenished ammo, surviving/repaired heads, mechanical reload/rack cadence and no extra modules/refunds. Sustained combat acceptance is pending. Rotary Bat/Blades get roughly 21x/32x the former normal-automation endurance, the largest buffs; subsequent balance checks should compare sustained crowd control with ammo-fed heads, without inventing caps or reducing the selected targets unilaterally.

## Precision, saved settings and integration

C395/C396 explicitly distinguishes ordinary two-decimal display from tiny probability/consumption values requiring sufficient precision. Current SandboxUI.precision preserves untouched stored values, uses two decimals ordinarily and trims extended decimals below 0.01. The simple 0.001/0.007 per-shot candidates avoid zero rounding without long repeating decimals. Do not round all runtime calculations to two decimal places. Summarize owner-facing endurance approximately.

Preserve existing saved customization; changing defaults alone does not update the Testing world's stored settings. Prepare the explicit approved-setting application path during implementation rather than overwrite unrelated sandbox options. Horde Night's matching audit baseline must be reviewed/prepared and receive sibling-edit authorization; the earlier Spike Barrier-only approval is not blanket authorization for these seven values.

## Calculation evidence

[Candidate receipt](evidence/c533-battery-targets.json). Replayed current production TurretStats.resolve and TurretBatteryEstimate.duration with captured settings and installed Firearms definitions. Candidate values are injected in the diagnostic only; resolver bound enlarged to 200 only for the probe. 66 head/build cases calculated; existing 44,152 harness checks pass. This proves the candidate arithmetic, not an implemented patch or connected runtime. Local reproducible inputs/results: diagnostics/c533/battery.lua and battery.log.

**Wait for a patch for these selected battery targets.** C532's separate corrective scope remains awaiting selection. Prior GitHub automatic approval-review destination authorization rejection remains; do not bypass it.
