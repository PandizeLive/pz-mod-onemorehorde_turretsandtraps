# 0.2.26 — cadence, engagement range and normalized loot

C77 implements the owner's approved combined patch. Single-player only; multiplayer authority remains a later gate.

## Changes

- Automatic firearm timing uses the installed FirearmAuto/FirearmDefault animation path: rifle small clip 1600/4800 seconds, speed 1.5, multiplied by a positive native CyclicRateMultiplier (otherwise 1). The complete clip is a conservative cycle reference, not a claim of exact player rounds per second. M16 at cyclic 1 and the approved 0.75 global rate resolves to roughly 3.375 shots/second instead of 2. Semi-automatic guns retain the existing recoil-delay estimate. Pump/bolt time is a concurrent minimum, not an additional delay; reload remains separate. Rapid-Fire remains subject to its existing adjustable minimum.
- Acquired targets have a firing deadline independent of the detection interval. Searches remain incremental, at most four turret entries and two milliseconds per scheduler tick. This is not certification of total frame time at horde scale.
- Manage adds Engagement range in whole tiles, plus Max. Target selection, shot eligibility and coverage share the cap. Max follows the head/modules; a numeric cap cannot exceed their actual range. Selection survives world save, pickup and redeployment.
- Firearm accuracy adds the installed native sightless/sight-band distance formulas and combat configuration values. CombatManager is not exposed to Lua, so these two small formulas are adapted; sixteen comparisons against the actual Java methods pass. This uses settled stationary aim with the existing turret aim-level/stat policy. It does not execute player moodles, movement, aim buildup, recoil or the full native firing pipeline. Close range and a weapon's useful sight band generally improve accuracy over distant shots; closer is not universally a monotonic bonus for every sight band.
- Ammo transfers no longer reset the acquired target or refresh unchanged visuals. Configuration refreshes coalesce per turret, at most four/one millisecond per tick. Inventory summaries expire after 200 ms or count changes, with explicit invalidation on managed transfers/configuration and live chamber counts. Exact inventory acceptance/commit guards remain.
- Normal diagnostics summarize events and maximum measured stage times every five seconds. Detailed logging opts back into individual bounded combat records; transfer details are opt-in. Native game Action traces are outside this toggle.
- Loot weights incorporate 4.5 overall times the approved per-component multipliers. New base weights: Firing/Detection 27; Small Expansion 6.75; Filter/Rapid-Fire/Reload/Velocity/Range/Accuracy 4.5; 360/Suppression/Critical/Medium Expansion 2.25; Large Expansion/Autoloader 1.35. All multipliers now default to 1. Pool scales and subsets are unchanged.
- This normalization intentionally introduces ModuleLootRate/LootRate<component> Sandbox keys, so old 6x/3x overrides cannot multiply the new weights again. Existing worlds adopt the normalized 1x controls for newly generated loot; already generated items are untouched. FirearmRateMultiplier similarly replaces the old cooldown-multiplier setting.
- Hosted/local LootLab uses the same weights and new export keys. Old scenarios and offline drafts convert their multipliers to preserve effective item weights; the owner's revision-90 scenario is separately reset to the explicitly requested 4.5-equivalent/1x normalized rates. Other seed, visibility and model assumptions remain. Production write must use a revision condition.

No Precision Fire, accumulating recoil/recovery, Rapid-Fire recoil bonus, damage inflation, new recipes or multiplayer enabling.

## Evidence and limits

3,137 Kahlua assertions, 53 runtime/translation files, 460 native translation keys and 149 package files pass. Installed 42.21.0 native accuracy parity is verified directly. The fast-target fixture fires ten times in one second despite a five-second detection deadline. Native persistence covers the range cap along with actual weapon/ammo/charge state. Final smoke/install/deployment outcomes are recorded in RELEASE.md.

LootLab's 256-world model predicts approximately 2,630 countywide components, 83.17% one/two-component successful finds and 2.61% five-plus jackpots. This is a new-world estimate, not exact future spawn locations. All 71 website API/page tests pass before final deployment. Headless checks cannot certify client rendering, audio or frame smoothness.

## Quick combined test

1. Restart and confirm **0.2.26**. Check firearm rate **0.75**, loot multipliers **1**, and Detailed logging off. Existing test saves get the new normalized loot controls.
2. Supply an M16 with magazine, ammunition, battery, Detection and Firing. It should fire faster than the old two shots/second, then reload normally. Try one Rapid-Fire module; its minimum cooldown remains tunable.
3. In Manage, set Engagement range to **3**, then **Max**. Coverage and eligible targets must match; targets outside the cap must not cost ammo. Save/reload and pick up/redeploy a supplied turret with the cap set.
4. Compare repeated firearm shots on nearby and distant groups, and check a pump/bolt gun through several rounds. Damage/criticals remain native-derived; distance affects hit chance. Potato retains two-second timing.
5. Transfer a stack of ammo into an active turret. Check target continuity and responsiveness; report any visible firing stutters. Console should show brief five-second summaries instead of one record per bullet.
6. Refresh hosted LootLab: multipliers should be **1** with the baked weights. Large five-plus circles remain. Change one setting and verify it syncs to another device; Set to Default restores this baseline.

Report Test Complete when ready; no separate test rounds are required.
