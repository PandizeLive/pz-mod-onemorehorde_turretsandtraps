# 0.2.47 - Focused owner test

SP; use a fresh test world/defaults to see the new weights. Existing saves keep their custom tuning. No long stress test is required for this patch.

1. Restart and confirm **0.2.47**. Spawn two **OMHTTModulePack** items; open one normally and Skip the other. Each pack should disappear and give exactly **three** items, with readable icons, names and rarity colors.
2. Disable **Module Pack animation** in Mod Options and open one more. Expect three items immediately after the opening action; interrupt another opening by walking and confirm its pack remains.
3. Kill a small group, including some turret kills, and inspect bodies. Pack drops should occur with **15% chance per body**, never more than one per body; a small sample is not expected to equal exactly 15%.
4. Hover modules and the turret battery. Descriptions should fit without new errors; estimates of at least 60 in-game minutes should display **hours**. Confirm LootLab's reset/default weights match your export; reset only if you want to replace your saved tuning.
5. Save/reload with an unopened pack, then open it and confirm three rewards. Reply **Test complete** with issues; Codex will inspect console.txt.

## Automated evidence

Final foundation validation passes: 16,071 Kahlua assertions, 117 compiled runtime/translation files, 775 native translation keys, 23 packet checks, 208 canonical source and 256 packaged files. Focused tests cover weighted boundaries/zero weights, exactly three rewards, distinct duplicate items, grant rollback/same draw on retry, repeat completion, elapsed-time interruption, optional reveal/Skip bounds, 15% chance boundaries, once-per-body guard and minute/hour boundaries.

Native inventory proof grants three real items, allows expansion kits, blocks repeat completion and inserts one corpse pack across duplicate callbacks. Native parser retains 208 loose-module entries plus one pack in each of 16 pools, at their configured scaled weight. Native write/fresh-process read pass in 60.6/58.4 seconds, preserving all three unopened-pack reward names, including duplicates, across serialization. Traps-only/Turrets-only/both startup passes in 48.8/46.2/52.6 seconds, including pack item/settings/loot isolation. GPU animation, actual corpse observations and rendered tooltip acceptance remain owner checks.

LootLab numerical/model tests and 78 API/page tests pass; headless Edge desktop/mobile checks cover saved values, direct edits, Sandbox export, legacy import, defaults and layout. Deployed Worker b267828b-e930-4e46-98d2-7a5ec4f4495b matches the tested bundle; twelve protected routes redirect to Access and two public endpoints return 200. No saved account/database writes. The map does not model packs.

Early validation exposed test expectations tied to old rarity weights and parser/isolation counters that included the new Pack prefix; tests now distinguish 208 modules from 16 pack entries. One validation redirection collided with its own log path; rerunning without that redirect passed. These are tooling findings, not owner gameplay passes. C171 capacity warnings remain open; no 51-gun integration rerun is claimed for this patch's inventory/UI/loot changes.

**Owner acceptance pending.** No new owner console was supplied during implementation.

## Installed handoff

Installed from immutable `test/v0.2.47` / `4a2f0dad29e49b0f9919dc9fb36196b9facf3e12`. All 208 source / 256 tagged/package/installed/archive files and both 0.2.46 backups verify. [Installation evidence](../diagnostics/v0.2.47/local-release.json). Restart required; actual client version and owner acceptance remain pending. **Test now.**

## C178 follow-up audit, 2026-10-12

**C178 audit completed:** no new permanent tick loop or tested reward duplication/loss found. Confirmed concerns: per-frame inventory tooltip wrapping, reveal overflow in a 360-pixel viewport, and useless pack drops when every reward weight is zero. [Findings, evidence and recommended corrections](AUDIT_v0.2.47.md). 16,084 audit/suite assertions pass; actual 0.2.47 client performance is unverified because console.txt still records 0.2.46. Gameplay files/install unchanged; corrective patch not yet approved.

No new owner gameplay pass. Optional fault-injection/layout/performance checks reproduce the three concerns while confirming partial-grant rollback, duplicate-event protection and no item/text preparation per reveal frame. See the audit for mock-timing limits. Existing five-step test remains the complete owner sequence.

## C179 static guideline check

101 source / 117 packaged / 117 installed Lua files: zero pcall/xpcall references, no BOMs or tabs. [Evidence](../diagnostics/v0.2.47/audit/guidelines.json). This is a static scan, not a new gameplay test or full style certification; non-guard inline conditionals and C178 caching work remain queued. Source/Contents and installed 0.2.47 are unchanged.
