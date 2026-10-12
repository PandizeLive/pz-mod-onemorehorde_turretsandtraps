# C183 - Persistent LootLab tier weights

- Persistent tier weights
- Cross-device tier settings
- Offline tier-save recovery

Confirmed tier values live in the existing account scenario's optional `tierWeights` object, keyed by the seven rarity names. Settings without the field initialize null values and derive starting centers from their existing module weights. Confirm saves all seven effective values; opening/canceling makes no save. Matching module assignments are rebuilt from weights, not another duplicated assignment store. Personal module overrides retain their exact saved weights.

The existing per-field settings sync merges unrelated tier/module edits and retains confirmed offline changes in account-scoped browser drafts. Tier changes made in another session are checked at Confirm; changed matching fields reject stale overwrites. Old client PUTs that omit tier metadata preserve the saved values. New scenario export/import retains tiers; old exports remain accepted. Set to Default clears tier values along with other settings. Local HTML copies store confirmed settings in localStorage and do not claim account sync. No database schema change or deployment-time owner data write.

## Validation and deployment

82 API/page tests pass, including two-client merging, account isolation, old-row compatibility without rewriting records, old-tab preservation, malformed input rejection, export/import parity, offline recovery and reset. Real Edge testing confirms custom tier 4.25 survives page.reload and the module returns to that row; drag/drop, live rarity, Cancel, direct weights and existing export checks pass without page errors. Native game checks were not rerun: Source/Contents are untouched and installed 0.2.47.3 remains valid.

Deployed Worker `01b226e9-cd75-42f6-bada-d8b33c008d27` from the isolated C182 release plus [reviewable backend patch](../diagnostics/lootlab-c183/worker.patch). Deployed bytes, protected asset/settings routes and unchanged public endpoint availability verify. [Evidence](../diagnostics/lootlab-c183/release.json). Website checkout's unrelated edits remain untouched. Current isolated source is diagnostics/lootlab-c183/loot-release/source/cloudflare-api; future web patches must start there, not the older C182 backend.

## Short owner test

1. Refresh LootLab to load the fix and open Plan with tiers.
2. Change a tier weight; Confirm weights and wait for Saved across devices.
3. Refresh and reopen the Tier List: the tier weight and matching modules remain.
4. Close/reopen LootLab: the values remain. Cancel a draft edit and check it was not saved.

No game restart needed. Owner browser acceptance remains pending; automated checks do not imply a live owner-account write.
