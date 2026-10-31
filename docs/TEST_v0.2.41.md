# 0.2.41 verification and focused owner test

## Short owner test

1. Restart into a **fresh** SP test world and confirm **0.2.41**. Spawn search should group types by `OMHTTTrap`, `OMHTTTurret` and `OMHTTModule` without old duplicates.
2. With Firearms enabled, mount M4 or M16. Compare normal versus Enhanced Firing, then add Rapid-Fire. Swap Detection for Enhanced Detection: faster turning/reaction; duplicate roles must be rejected. Separately compare handheld Single/Auto only if investigating the reported handheld slowdown.
3. Fit two Splitters, fire repeatedly into open visible space: center + both side tracers together. Try a wall/fog edge and a small moving group: no shots through solid walls or visible rays beyond fog. Confirm ammo/power still decrease and retained targets keep firing.
4. Check Expansion totals **200/300/500/750** and slot progression. Place more than 32 Spike Barriers, recover/redeploy several, and confirm placement continues. Native inventory weight can fill before the count ceiling.
5. Save/reload once and check the turret's modules/ammo/charge. If the paired-Concertina check is still untested, confirm either tile selects/services the same 1x2 trap. In LootLab, confirm the five new modules appear and prior tuning remains.

Report only failures or "passed". Capture console.txt and installed markers after the owner result. Do not reopen the accepted 0.2.38.1 lag checklist or infer acceptance of unmentioned checks.

## Automated/native evidence

- 5,083 Kahlua assertions; 96 runtime/translation files; 23 packet serializations; 625 native translation keys. Native game fixtures use stock-first B42.21 classes. Test doubles are not rendered acceptance.
- Traps-only/Turrets-only/both startup pass (62.8/52.3/59.1 seconds). Source 190 files, packaged 230 files. Native write/read pass in 50.1/51.2 seconds and verify real recipes, items, ammo/weight, service and persistence; final logs accompany the release record.
- Firearms integration: 51 supported guns, 153 conserved shots, two cap guns excluded. M4 and M16 resolve to 296.296 ms normally and 222.222 ms with Enhanced Firing (3.375/4.5 shots/sec) before Rapid-Fire. These are configured adapter intervals, not measured player RPM or a guaranteed runtime rate.
- Each supported gun retains its original fire mode, recoil delay and cyclic-rate multiplier after feeding/firing. No T&T handheld firing-speed mutation found. The owner's handheld slowness remains undiagnosed; inspect selected Single/Auto mode before assigning a cause.
- Large Expansion accepts 750 real pistol rounds and rejects count overflow. Portable potato storage stops at 228 because native weight capacity is 50; logical count remains 750. The initial potato-750 test exposed this limit and was replaced by separate count and native-weight assertions, not a weight bypass.
- LootLab numerical, account-preservation, schema/auth and page checks pass; isolated deployed Worker suite: 73 tests. Twenty modules, sixteen pools, 150 entries, 79 routing rules and 18,630 map candidates. Default modeled successful finds: 82.47% one/two modules, 3.83% five-plus. Estimates exclude physical capacity/story losses.
- Hosted bundle/version, access checks and test evidence: [LootLab release record](../diagnostics/v0.2.41/lootlab-release.json). Twelve anonymous admin paths remain Access protected; both public API checks return 200. Authenticated physical-device appearance remains owner acceptance.

Native harness corrections: visible component count changed from 21 to 23, pool-entry count from 138 to 150, including the outer smoke verifier. Intermediate obsolete-count failures were test expectations, not successful full-suite runs. Final verification is recorded separately. No Workshop publication, MP acceptance or GPU/audio certification.

## Installed checkpoint

`test/v0.2.41` / `9ccc8bce4fc96456da0241f01fb99c40b87d8cce`; root installer verified both packages and backups. [Exact local-release hashes](../diagnostics/v0.2.41/local-release.json). No owner gameplay result yet.

## C138 - owner test complete and console review (2026-10-11)

Owner: "Test Complete." Close the requested 0.2.41 test round with no issues reported; do not infer separate attestations for every checklist item or request a repeat. No new gameplay is authorized by completion.

Capture `20261011-143314-8532`, 2026-10-11 14:33:14 -04:00; SHA-256 `492B23B4E8B32A79F76982366FC885317F959D71BA4742556CB64B52DB25FB0C`. Both installed markers and live diagnostics identify 0.2.41, game 42.21. Seventy-four summary windows record 154 firearm shots. Effective configuration changes from 296.296 to 222.222 ms firing intervals and from 100/two to 750/sixteen ammo/module capacity. These support Enhanced Firing/Large Expansion configuration, not sustained measured RPM.

No exception/stack trace or `status=Limit` appears. Nineteen engine ERROR lines concern fonts, fluid names, native recipe icons, map data or vegetation tiles; no OMHTT exception found. This is not a whole-console clean claim. Maximum active-update gap is 331 ms; firing work peaks at 4 ms, shot/reload audio at 1 ms and effect/head rendering at 2 ms. The gap's cause is unassigned; retain under R1C3 without a repeat test or universal performance clearance.

The capture does not independently prove the modded M4 case, >32-barrier placement, every side tracer, paired-Concertina servicing or authenticated LootLab appearance. Unreported specifics and handheld slowdown remain distinct from the completed round. Reviewed summary: diagnostics/v0.2.41/owner-test-20261011.json; raw console stays local. R3C6 Piercing/Initial Blow/Execute/Impact is next for discussion, not approved implementation. Branch inspected at 29820ad; origin fetched; draft PR #1 remains the only open PR.
