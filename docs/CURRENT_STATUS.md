# Current development and planning handoff

Updated 2026-10-12. Read [AGENTS](../AGENTS.md) and [Planning](PLANNING.md).

**C168 / 0.2.46 implemented and verified; installation in progress.** Owner approved revised 2B: .00045% base battery use, additive rarity surcharges .1/.15/.25/.4/.6/.8/1.0, plus C167 packing/weight/Regulator/names. Regulator provides +25% endurance per copy, battery-only, no self-surcharge; all module item weights are .2. Seven names end in Epic/Legendary/Mythic. Inventory rarity tooltip uses exposed UI methods. [Patch](PATCH_v0.2.46.md) | [focused test](TEST_v0.2.46.md).

16,046 Kahlua assertions, 760 native translations, 113 compiled files, native write/read, three independent package selections and 51 Firearms weapons pass. LootLab 0.2.46 is deployed with 29 modules/208 entries; 77 API/page tests and desktop/mobile browser checks pass. Owner/rendered gameplay acceptance remains pending.

**Packing remains unfinished, despite approved implementation scope.** The ordinary-Lua native buffer route and generic object loaders still require unavailable buffer positioning/version decoding; no safe arbitrary-item restore path has been proven. Existing exact-item pickup/placement retains full contents weight. No Java dependency, partial item reconstruction or equipped-only substitution ships. Further progress requires a supported native bridge or a separately discussed dependency, not another balance choice.

R3C7 owner acceptance and relevant R1C3 performance work remain open. SP combat/fresh-world identity policy and owner-sourced final art remain. No Workshop upload. The original 0.2.45 inventory tooltip failure is recorded, not erased. Existing test save Battery use needs the approved one-value correction from .1 to .00045; save backup/change evidence will be recorded separately.

GitHub: `codex/performance-barbed-audit`, [draft PR #1](https://github.com/PandizeLive/pz-mod-onemorehorde_turretsandtraps/pull/1). C108/C119 development mirror applies. **Wait for a patch:** tagged installation is being completed.
