# C293 — stockpile clarification, capitalization and audit corrections

Owner request, 2026-10-17: confirm that stockpiles hold turret/trap supplies only, check UI capitalization, and consider solutions to the five C292 findings. This records the review and recommended implementation, not a new installed patch or test acceptance. Installed version remains 0.2.53.3. [Underlying reproductions](AUDIT_C292_v0.2.53.3.md).

## Stockpile contract and clarification

The restriction remains defense supplies only: compatible heads, modules, expansion kits, ammunition and supported alternative ammunition, batteries, traps and control devices. Do not expand it to ordinary clothing, backpacks, general food or household storage.

The two audit examples describe different operations:

- **Backpack:** the player withdraws an allowed module from the stockpile into a backpack they are carrying. The bug loses that selected destination and sends it to main inventory. It does not concern depositing a backpack in the stockpile.
- **Clothing:** an unrelated item already present from the earlier unrestricted build encounters a missing native transfer callback when the player tries to inspect/retrieve it. New clothing deposits are rejected. Preserve recovery of existing items; do not delete them or enable new deposits to solve this.

Current `ControlDefinitions.storable` checks the OMHTT defense families, native batteries, the Ammo display category and the turret's supported-item classifier. Both incoming native transfers and server completion use admission checks. Keep the same admission predicate at every entry point and preserve Traps-only operation without requiring Turrets. The category-based ammunition allowance is broader than the currently mounted head by design: a shared stockpile serves multiple devices. Do not make stockpile acceptance depend on one selected head.

## Capitalization review

Recommendation: use title case for button/context actions, panel/container titles, and short field labels; keep explanatory sentences and Sandbox setting descriptions in sentence case. Preserve proper item/module names, acronyms and units. This is a presentation cleanup, not a rename of script IDs or a global automatic title-case transform.

Confirmed inconsistent English strings and their intended forms:

| Surface | Current text | Recommended text |
| --- | --- | --- |
| Controller button | Open stockpile | Open Stockpile |
| Native container title | Controller stockpile | Controller Stockpile |
| Remote Manage destination toggle | To stockpile / To inventory | To Stockpile / To Inventory |
| Controller actions | Use as input / Link input / Unlink input / Clear input links | Use as Input / Link Input / Unlink Input / Clear Input Links |
| Device context menu | Place device / Device controls / Press button / Pick up | Place Device / Device Controls / Press Button / Pick Up |
| Trap/turret context actions | Pick up / Pick up turret / Remove barbs | Pick Up / Pick Up Turret / Remove Barbs |
| Manage priority | Once each | Once Each |
| Manage ammunition fields | Next load / Next shot | Next Load / Next Shot |
| Manage short fields | Fire rate / Drop here | Fire Rate / Drop Here |
| Void action | Store reserve in Void | Store Reserve in Void |
| Construction action | Craft and place | Craft and Place |
| Client option | Module pack animation | Module Pack Animation |

Sources: `Source/42.20/media/lua/shared/Translate/EN/{UI,IG_UI,ContextMenu}.json`, `client/OMHTT/ControlManage.lua`, and the corresponding active UI consumers. Controller construction also contains hardcoded initial titles that are subsequently replaced by layout/refresh. Use the same translation key when creating and updating each control, including the remote destination toggle, rather than maintaining two competing labels.

Reviewed neighboring pack, Load Order, Details, crafting-category, Sandbox-page and tooltip-field labels. Existing `Collect`, `Skip`, `Open Next`, `Load Order`, `Reload`, `+ Details`, `Installed Modules`, `Feature`, `Stackable`, `Battery Drain`, and rarity names already fit; retain them. Do not capitalize prose such as "Select a plate or button to connect." Debug/test descriptions are not player-facing menu headings and need not become title case. Re-measure buttons after text changes instead of assuming uppercase letters fit existing widths.

## Recommended solutions to the five findings

1. **Honor withdrawal destinations.** Pass the exact carried destination bag through the native timed-action arguments, using the existing turret transfer destination pattern. Re-resolve and validate it on the server at completion: still carried by this player, item allowed, room available, source item still present, current controller access valid. Main inventory remains the normal default; do not silently substitute it when an explicitly chosen bag becomes invalid. Preserve exact items and rollback on failed insertion. This does not change stockpile admission.

2. **Preserve native action callbacks.** Support the native `setOnComplete` contract in the replacement action. Run the callback once only when the transfer has succeeded and the client has the confirmed destination state; failed/cancelled actions must not open follow-up UI. Keep callback functions client-local rather than trying to serialize them. Reuse the established turret-transfer adapter where suitable, with a specific failure-path test rather than assuming it is correct in every mode.

3. **Refresh automatic names from head changes.** Use the existing Manage equipment summary or an inventory/head revision to invalidate the gray automatic-name placeholder. Include unassigned turrets, empty heads, controller assignment changes and custom-name clearing. Avoid calling the full contents aggregator from each text-entry update; custom names must remain untouched.

4. **Budget the whole controller list update.** Replace full inventory summaries used only for names with lightweight head metadata/a cached label, invalidated by equipment changes. Spread both discovery and row finalization over the existing work budget. Keep the previous complete list visible until its replacement is ready, and preserve selection by device identity. Check the generic Controls title too, since it uses the same resolver. Do not add another per-tick world or inventory scan.

5. **Make remote-session renewal bounded.** Share one renewal state per player/controller/target across both open windows. Renew through a small server-validated request independent of the long inventory-action queue, with rate limiting and bounded retry; do not enqueue one timed action every five real seconds. Retain the existing server lease, ownership/faction, range, assignment and controller-power checks. Reject stale/wrong identities, stop renewing closed sessions, and avoid SP pause backlog. Mutating item transfers remain server-authoritative timed actions.

These are compatibility, presentation and performance corrections within the existing design; they require no new balance, recipe or gameplay choice. Do not solve the callback issue by allowing clothing, the destination issue by forcing all items into main inventory, or the lease issue by trusting client access indefinitely.

## Verification plan and status

- Convert C292's adverse-path assertions into expected-behavior regression checks; its current diagnostic deliberately confirms the defects.
- Exercise allowed withdrawals into carried bags, full/removed/restricted bags, unauthorized requests, legacy-item recovery, successful/failed/cancelled callbacks and exact-item preservation. Verify top-level native serialization for the destination identity and Traps-only independence.
- Exercise head swaps with/without a controller, empty/custom names, and name-cache invalidation. Measure maximum per-update discovery/finalization work with many loaded turrets; do not claim frame-time improvement from a call-count test alone.
- Exercise duplicate windows, long action queues, pause/resume, retries, closure, removal, range/access/power changes and stale multiplayer requests. Verify bounded request state and no inventory-action backlog.
- Review actual controls using the corrected translations, narrow sizes and large fonts. Existing pack/Load Order actions and approved category/group meanings must remain unchanged.

This turn checked source/translation consumers and reconciled `origin/dev` plus active PR #1. It does not rerun or replace the C292 runtime evidence, and does not establish rendered or connected-multiplayer acceptance. No production source, generated package, version, installation, test tag or Workshop changelog changed. Corrective work remains before the held owner test and R4C2. **Wait for a patch.**
