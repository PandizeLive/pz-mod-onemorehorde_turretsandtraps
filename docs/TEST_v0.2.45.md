# 0.2.45 - Focused owner test

Owner acceptance is pending. Use SP with OMH: Turrets, optionally OMH: Traps. No repeat of the old construction/crafting checklist is required.

1. Restart and confirm **0.2.45** in the developer menu; load the test turret. Confirm no growing error counter while idle or firing.
2. Hover its battery and a few modules in inventory/Manage. Check `% / shot`, in-game minutes, four short module fields and readable rarity colors. Check the engagement slider stays inside its row.
3. Fire a shotgun near maximum range with Piercing and Fragment. Confirm whole shots can miss, penetration works, and Fragment appears shortly after the final hit/stop or at range end on a miss.
4. Add Tack, Martyrdom and Synergy. Confirm Tack lands after a short pause; deaths pop later, with the stomp impact roughly aligned. Effects must not multiply endlessly or cause disruptive pauses.
5. Save/reload with effects active, then fire again. Confirm effects finish normally and no repeated error spam appears. Report any issue and say **Test complete**; I will inspect console.txt.

Packed weight is deliberately excluded: the approved auto-pack flow is not implemented because native exact-item restoration is not yet proven. Pickup/placement still has its existing weight.

## Automated evidence

Implementation verification passes. The Kahlua suite passes 16,011 assertions, including strict client startup with unavailable server dependencies, .5/.75/.25-second scheduling, captured positions, native table save roundtrips, restored reservations, one shotgun aim roll, shotgun Piercing, all module description fields and terminal Fragment on misses. Native object write/fresh-process read pass in 105.3/126.2 seconds. Traps-only/Turrets-only/both startup pass in 101.3/107.7/67.2 seconds. The Firearms B42 probe passes all 51 supported guns and 153 firing transactions. The manifest covers 203 source and 251 packaged files. These are isolated stock-first 42.21.0 probes, not client frame benchmarks. The final potato miss coordinate correction was followed by the full Kahlua/package validation; native probes do not establish its rendered behavior.

Earlier native runs exposed an obsolete weight assertion and the real packed-buffer limitation; they are not passes. [Packing failure](../diagnostics/v0.2.45/packing-api-failure.log) records `bufferMeta=nil` and unavailable `rewind`. Debug reflection is also unavailable in ordinary play. Rendered sound timing, font layout and crowded-client frame smoothness remain owner checks regardless of headless results.

Installed from immutable `test/v0.2.45`; 203 source / 251 package, installed and archived files match. Both prior 0.2.44 backups verify. [Exact release record](../diagnostics/v0.2.45/local-release.json).

## Partial owner result and console review - 2026-10-12

Owner reports battery drain effects work, but a full late-game turret estimates about 1.5 in-game minutes. Latest console identifies 0.2.45 SP and logs 4.079648422352103% per shot, 250-ms cooldown, 212.5 damage, range 30 and 16 modules. Latest saved base drain is 0.1 versus shipped .005, with ModulePowerBonus 5 and native 90-minute days. No save changes were made. Current maximum per-module surcharge remains +2, not a turret-wide cap. Power balance needs discussion under [C166](checkpoints/R3_POWER_PACKING_OPTIONS.md).

**Failed client check:** repeated `__sub not defined for operands in render` at TurretMenu.lua:24 in the new inventory rarity-color overlay. Native tooltip padding fields are accessed as Lua values; repair their runtime-safe rendering before acceptance. [Captured review](../diagnostics/v0.2.45/owner-20261012/power-tooltip-review.json). Counts are log occurrences, not unique failures; duplicated stack output is possible. Other effects/UI/stress acceptance remains unconfirmed. No repeat checklist requested during this discussion.
