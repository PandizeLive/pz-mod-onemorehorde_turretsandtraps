# 0.2.47.2 - Short combined check

SP; replaces previous unfinished pack test. Existing saved weights are preserved.

1. Restart and confirm **0.2.47.2**. Hover a carried Turret Base for a few seconds, then place/pick it up; contents should remain intact.
2. Open one Module Pack normally and Collect another before rolling finishes. Each should grant exactly three items, once; the normal reveal ends with three clear selected cards and one green button.
3. In LootLab, drag a module into a tier, edit its personal weight and Confirm. Normal tuning should show that weight. Cancel a second draft and confirm nothing changed.
4. Hover the battery (hours above 60 minutes), save/reload with a pack, and open it. Report Test complete plus issues; Codex checks console.txt for returning capacity warnings/errors. Choose sound options separately from the audition HTML.

## Evidence

0.2.47.1 owner screenshot shows the rolling window; polish requests are not a full test pass. The current console has repeated carried-base maximum-44 capacity warnings. Cause and corrective native evidence: [capacity-evidence.json](../diagnostics/pack-polish/capacity-evidence.json).

16,094 foundation/audit assertions pass, including safe grants, duplicates/retries, empty pool, tooltip caching and constrained viewport/Collect geometry; 117 runtime/translation files and 776 native translation keys pass. Native write uses a 44-capacity six-weight base and has zero InventoryContainer.setCapacity warnings; previous 50-capacity fixture expectation was corrected to the actual native bound. Native write/read pass in 95.9/74.7 seconds; Traps-only/Turrets-only/both pass in 82.3/66.6/69.5 seconds. Final formatting/callback cleanup has no native storage change and is checked by the foundation suite.

Tier model tests cover seven-band defaults, equal/zero weights, unassigned preservation, conflict rejection and bounds. Browser tests pass real pointer drag/drop, keyboard assignment, custom weights, Confirm/Cancel, mobile width, audio playback and zero page errors. 78 backend/page tests pass; 23 focused tests pass after the final editor adjustment. Deployment checks verify the live backend and protected asset route; saved account tuning is unchanged by deployment. Runtime sound/particle acceptance is not claimed.
