# 0.2.69 - Barbed contact and garage panels

C478, 2026-10-26. Owner selected C477 option 1B ("One B"): implement the contact correction and garage-door segment support. Swinging double gates remain a separate checkpoint. Horde/Cure 0.6.16.8 and Trait Shop 0.9.1.1 are unchanged.

- Replace the strict perpendicular contact boundary with a 0.001-tile numerical allowance. Preserve the exposed face, one-tile segment span, floor, damage, shared repeat timer and native backing damage. This fixes the native float-coordinate boundary misses reproduced in C477 without making the whole tile a trigger.
- Permit panels on either face of a closed garage-door segment. Each purchased panel covers its selected segment/face, retains its own identity and shares that segment's native health. Opening suspends contact and hides the marker; closing restores both. Suspension keeps the existing binding alive. No added armor or protection from native thumping.
- Use the existing bounded maintenance and sprite synchronization paths. One transparent sprite entry references an unused pixel of the existing BARB atlas; no duplicate bitmap, new artwork, polling timer, full-map scan, cache, or new network protocol.
- Preserve attachment/door state through save/reload, independent face removal, and retirement when the backing breaks. Swinging double doors remain rejected because their moving/replaced leaf lifecycle is not implemented.
- Clarify the garage closed-state rule in the existing item tooltip. No recipe, material, rarity, Sandbox value, item ID or saved tuning changes.

See [verification](TEST_v0.2.69.md). Existing saves can use this patch after restarting; no new world is required for this change. The generic install tooling's historical fresh-world wording does not describe a new migration requirement. Rendered and connected multiplayer acceptance remain pending; previous 0.2.68.3 owner checks stay deferred.
