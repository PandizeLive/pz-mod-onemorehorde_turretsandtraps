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

## C184 - Rarity-row conflict (2026-10-12)

Owner screenshot shows item weights agreeing with their row: 20 Abundant, 16 Common, 12 Uncommon, 8 Rare, 5 Epic, 2 Legendary. The cards instead label 16 Abundant, 12 Common, 8 Uncommon and 5 Rare. The below-screen minimum is not visible. A read-only fixture using minimum 1 and maximum 20 exactly reproduces all visible labels; no complete account scenario was fetched or modified.

Cause verified in art/loot-tuner/tier-list.js bands() and Source/42.20/media/lua/shared/OMHTT/TurretRarity.lua R.refresh(): cards and game rarity use round(log(max/weight)/log(max/min)*6), while tier lane headings are independent labels. Saving tier weights under C183 never made those weights classification anchors. C182 made calculated labels visible but did not resolve this conceptual conflict; earlier claims of a fixed rarity UI should not imply this mismatch was solved. The latest screenshot is a failed semantic acceptance finding, not a full persistence failure diagnosis.

Recommendation 1A (not yet approved): saved tier weights become authoritative rarity anchors using one consistent rule in LootLab and the mod. Exact tier-weight matches receive that tier; custom individual overrides use the agreed intervening boundaries. Preserve actual chosen loot weights. Implementation must carry the anchors through Sandbox export/import and saved-game settings, keep defaults compatible, and resolve duplicate/out-of-order anchors explicitly. This changes rarity-dependent battery surcharges: a module moved from Uncommon to Rare changes +0.25x to +0.4x under existing surcharge values. Do not silently implement a gameplay change or just repaint the website.

Alternative 1B: retain current game rarity computation and constrain tier weights to computed band centers, so row names and calculated rarity agree. This sacrifices freely chosen per-tier weights. Discuss the rule before patching. No mod/site deployment this turn; GitHub diagnosis/planning mirror only. Existing C183 persistence evidence remains valid and separate.

## C185 - Shared rarity anchors (2026-10-12)

Owner selected **1A**, approving the shared LootLab/game rule and its rarity-based battery consequences. Supersedes C184's pending decision. Exact tier weights select their named tier; between tiers, proportional (geometric) midpoints classify personal overrides. At an exact boundary the rarer tier wins. Changing an unrelated module's minimum/maximum weight no longer changes custom-tier rarity. The seven surcharge amounts remain +0.1/+0.15/+0.25/+0.4/+0.6/+0.8/+1.0; Regulator's existing self-drain exception remains.

Tier weights must be positive and strictly descending from Abundant to Mythic, at most 1,000,000. Drafts may temporarily be invalid while editing; feedback explains the problem, cards show Invalid tiers, and Confirm/Sandbox export reject invalid configurations. Legacy stored values remain loadable for correction. Confirm validates the merged result after concurrent tier edits. All-null website settings and missing/all-zero game settings retain the previous automatic logarithmic classifier. Equal-weight automatic drafts get distinct positive starting anchors rather than an unconfirmable duplicate set.

The existing seven saved account fields remain unchanged. No account data or loot weights are retuned by deployment. Scenario JSON includes tiers; Sandbox export includes RarityWeightAbundant through RarityWeightMythic, requiring mod 0.2.47.4+. Export zeros to retain automatic mode. Apply the excerpt to the game's Sandbox settings and restart; browser saves do not modify game worlds. Native Sandbox options persist through the game's existing setting mechanism; no separate rarity save system is added. Invalid manually entered native tiers log one diagnostic per changed error and explicitly fall back to automatic rarity.

The shared game cache drives Manage, item tooltips, pack rewards and battery surcharges. Boundaries/cache rebuild only during existing rarity refresh, not each frame. Disabled loot is marked Disabled in LootLab; already-owned disabled components remain usable and classify from their base weight, using custom anchors when active. Drop eligibility remains unchanged.

The screenshot's six visible tier values are regression fixtures, not permission to guess unseen owner settings or overwrite their account. Tests use Mythic=1 as an explicit fixture only. Browser tests cover all seven labels, drag/drop, overrides, Confirm/reload, invalid tiers and actual Sandbox download; native probes check option registration and the same rarity/surcharge results. See the versioned test for verified/pending distinctions. Current isolated deployment source moves to diagnostics/v0.2.47.4/loot-release/source/cloudflare-api after verified deployment.
