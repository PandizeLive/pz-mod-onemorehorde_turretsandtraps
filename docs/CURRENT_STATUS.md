# Current development and planning handoff

**C174 - Viewpoint feasibility:** optional support is realistic enough for a prototype, but rendering/selection and performance remain unverified. [Evidence and separate compatibility proposal](checkpoints/VIEWPOINT_COMPATIBILITY.md). No implementation or new chat authorized; C173 remains the next content/corrective planning track.


**C173 - next combined patch planning:** module reward pack, optional default-on rolling reveal using Manage icons/text/rarity colors, owner-exported module weights, and battery hours/minutes formatting. [Confirmed direction and all 29 weights](checkpoints/R3_MODULE_PACK.md). The additional support topic is Viewpoint (C174), proposed as a separate workstream; remaining pack rules still need settlement before implementation. C171 tooltip/capacity corrections remain queued; packing reduction stays abandoned.


**C172:** [LootLab scrolling map and bottom statistics](LOOTLAB_SCROLLING_MAP.md) deployed and verified; desktop/tablet map follows the module controls and releases before full-width statistics. Phones retain normal map flow. Saved tuning is unchanged; game findings remain pending.

**C171:** direct component weights are live in LootLab; saved tuning and Sandbox exports preserve their effective values. [Implementation and findings](LOOTLAB_DIRECT_WEIGHTS.md). The ongoing 0.2.46 test reports minutes-only battery display; console also confirms a tooltip formatting exception and repeated capacity warnings. These game corrections remain pending; do not claim full acceptance.

Updated 2026-10-12. Read [AGENTS](../AGENTS.md) and [Planning](PLANNING.md).

**C168 / 0.2.46 installed and verified; owner test pending.** Owner approved revised 2B: .00045% base battery use, additive rarity surcharges .1/.15/.25/.4/.6/.8/1.0, plus C167 packing/weight/Regulator/names. Regulator provides +25% endurance per copy, battery-only, no self-surcharge; all module item weights are .2. Seven names end in Epic/Legendary/Mythic. Inventory rarity tooltip uses exposed UI methods. [Patch](PATCH_v0.2.46.md) | [focused test](TEST_v0.2.46.md).

16,046 Kahlua assertions, 760 native translations, 113 compiled files, native write/read, three independent package selections and 51 Firearms weapons pass. LootLab 0.2.46 is deployed with 29 modules/208 entries; 77 API/page tests and desktop/mobile browser checks pass. Owner/rendered gameplay acceptance remains pending.

**C170: packed-turret weight reduction is abandoned at the owner's request.** Existing pickup/placement keeps actual contents and their full weight. No carry-case alternative, lighter-base change or Java dependency is selected. Remove packing from the active queue; do not reopen it without a new owner request. 0.2.46 remains installed; its focused test is pending.

R3C7 owner acceptance and relevant R1C3 performance work remain open. SP combat/fresh-world identity policy and owner-sourced final art remain. No Workshop upload. The original 0.2.45 inventory tooltip failure is recorded, not erased. The closed test save Battery use was backed up and corrected from .1 to .00045; all other bytes/settings remain unchanged. [Save-setting evidence](../diagnostics/v0.2.46/test-save-setting.json).

GitHub: `codex/performance-barbed-audit`, [draft PR #1](https://github.com/PandizeLive/pz-mod-onemorehorde_turretsandtraps/pull/1). C108/C119 development mirror applies. **Test now: LootLab direct weights.** Game 0.2.46 remains installed from immutable `test/v0.2.46`; C171 corrective findings are pending and acceptance is incomplete. Packed-weight reduction is abandoned under C170.
