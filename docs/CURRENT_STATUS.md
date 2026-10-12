# Current development and planning handoff

Updated 2026-10-12. Read [AGENTS](../AGENTS.md) and [Planning](PLANNING.md).

**C168 / 0.2.46 installed and verified; owner test pending.** Owner approved revised 2B: .00045% base battery use, additive rarity surcharges .1/.15/.25/.4/.6/.8/1.0, plus C167 packing/weight/Regulator/names. Regulator provides +25% endurance per copy, battery-only, no self-surcharge; all module item weights are .2. Seven names end in Epic/Legendary/Mythic. Inventory rarity tooltip uses exposed UI methods. [Patch](PATCH_v0.2.46.md) | [focused test](TEST_v0.2.46.md).

16,046 Kahlua assertions, 760 native translations, 113 compiled files, native write/read, three independent package selections and 51 Firearms weapons pass. LootLab 0.2.46 is deployed with 29 modules/208 entries; 77 API/page tests and desktop/mobile browser checks pass. Owner/rendered gameplay acceptance remains pending.

**C170: packed-turret weight reduction is abandoned at the owner's request.** Existing pickup/placement keeps actual contents and their full weight. No carry-case alternative, lighter-base change or Java dependency is selected. Remove packing from the active queue; do not reopen it without a new owner request. 0.2.46 remains installed; its focused test is pending.

R3C7 owner acceptance and relevant R1C3 performance work remain open. SP combat/fresh-world identity policy and owner-sourced final art remain. No Workshop upload. The original 0.2.45 inventory tooltip failure is recorded, not erased. The closed test save Battery use was backed up and corrected from .1 to .00045; all other bytes/settings remain unchanged. [Save-setting evidence](../diagnostics/v0.2.46/test-save-setting.json).

GitHub: `codex/performance-barbed-audit`, [draft PR #1](https://github.com/PandizeLive/pz-mod-onemorehorde_turretsandtraps/pull/1). C108/C119 development mirror applies. **Test now:** 0.2.46 is installed from immutable `test/v0.2.46`; see the five-step test above. Packed-weight reduction is abandoned under C170.
