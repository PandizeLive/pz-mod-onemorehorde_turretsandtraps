# 0.2.47.1 - Module Pack and tooltip corrections

C180 owner approval: "Go ahead and solve the remarked issues". Corrective follow-up to C178/C179; no balance change.

- Cached inventory tooltip layout
- Viewport-safe, scrollable pack reveals
- Empty-reward-pool drop suppression
- Native pack display metadata and reusable reward pools
- Pack-code guideline cleanup

Tooltip layout is cached per panel by description, font and width; native item condition/weight rendering stays live. Reveal height is bounded by the player viewport, with fixed Skip/Close and wheel/arrow scrolling when needed. Long localized names increase row height instead of being discarded. Names/icons use native ScriptManager Item metadata, so openings create no throwaway inventory items. Current rarity/text is resolved when opening, without a persistent display cache.

ModuleLoot.apply refreshes cached eligibility with loaded settings. Death callbacks do not scan all weights; they still roll once and insert at most one pack. An all-zero pool injects no new packs. Existing unopened packs are kept and work after eligibility returns. Weighted entries are reused when loaded values are unchanged; committed outcomes/rollback/retry behavior remains intact.

The 15% body drop rate, three independently weighted rewards, duplicate eligibility, supplied weights, saved tuning and battery consumption remain unchanged. No pcall/xpcall; pack non-guard inline conditionals expanded. The source/package check and focused audit are required by normal validation. No new tick handler, runtime queue, web deployment or Workshop upload.

[Verification and short owner test](TEST_v0.2.47.1.md). C171's earlier capacity warnings remain separately open; live UI acceptance remains pending.
