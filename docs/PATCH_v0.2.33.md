# 0.2.33 — crafting organization and movement repairs

Owner-approved C103, addressing the 0.2.32 findings. Development patch; rendered acceptance remains pending.

- Use Pack/Unpack consistently and omit Five from recipe names.
- Group Spike Barrier, Bed Spikes, Potato Turret and Potato Launcher Head recipes into collapsible native list rows. Keep base/reinforced and packing operations as separate selectable recipes. Preserve search/favorite filtering, native mouse/controller controls and unrelated groups. Icon view remains flat. Building remains deferred.
- Replace bed-induced hit knockdown/backward stumble with the native forward Bob_RunStumble clip and explicit landing/completion events. Keep the native bumped/get-up states and existing one-hit-per-fall/recovery protection. Potato impacts retain their approved knockdown behavior.
- Add the missing running brush-through node using native Bob_RunTrees/WalkSpeedTrees. Walking and running brush nodes omit vanilla tree-injury events, preserving the approved safe walking and authored running/sprinting risks.
- Align panel cursor tool handling with Build Cheat and show normal missing-tool feedback; recheck tools before completion. The prior owner's generic invalid-square log did not identify a specific predicate, so the confirmed cheat mismatch is not claimed as the sole cause of that report.
- Use Install Trap for the turret's inventory placement action as well as component installation.
- Set panel/basic-bed/reinforced-bed weights to 2/3/4. Barrier weights remain 4/5, five-item packs 6.6/8.25, Turret Base 6 and Potato Launcher Head 4. Remove a duplicate bed Bush property assignment and duplicate fixture module load.

## Evidence and limits

Current installed 42.21 Lua/XML and JAR are the compatibility references. Native CraftRecipeGroup only provides OPEN_BOX, so the adapter supplies presentation nodes to ISRecipeScrollingListBox for exact OMH recipe IDs; it does not invent a Java enum or repurpose Open Box. Native list controls are exercised in Kahlua with UI/recipe doubles. The cursor fixture executes installed ISBuildIsoEntity validation/create with world/recipe doubles in all four directions, rejecting missing backing and duplicate completion. Native objects/recipes additionally check support validation, exact panel consumption and retained tools.

3,763 Kahlua assertions, native write/fresh-process read, controlled forward landing/get-up transition/cleanup, and Traps-only/Turrets-only/both startup pass. The manifest covers 182 source and 219 packaged files. Installation evidence is recorded separately in [RELEASE.md](RELEASE.md). Automated checks cannot certify GPU animation blending, natural actor recovery or client frame smoothness. The previous pause report remains unresolved. Use the [four-step focused test](TEST_v0.2.33.md); the older waived suite stays waived.
