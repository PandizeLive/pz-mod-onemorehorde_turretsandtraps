# 0.2.53.4 — stockpile and controller audit corrections

C294, 2026-10-17. Owner explicitly approved the [C293 corrective plan](CORRECTIONS_C293.md). Implements the five reproduced C292 integration findings and consistent capitalization, preserving the approved defense-only stockpile and existing gameplay.

## Changes

- Stockpile withdrawals preserve the chosen carried bag as a named, top-level timed-action argument. Completion revalidates ownership, reach, bag possession, capacity and item restrictions. Unsupported destinations do not silently become main inventory; failed insertion rolls the exact item back.
- Stockpile replacement actions support native completion callbacks. Callbacks receive the confirmed destination item, including a replacement instance received through multiplayer synchronization. Late confirmation uses at most four checks per 100 ms, a bounded queue and a five-second deadline; its temporary tick handler detaches when empty. Cancelled/failed/unconfirmed transfers do not open follow-up UI. Previously stored unrelated items remain recoverable; new unrelated deposits remain rejected.
- Automatic names follow head changes even without a controller. Server-maintained full-type metadata supplies localized labels without a complete ammunition summary per label. Head changes do not overwrite custom names.
- Controller discovery and row creation share the 64-step/two-millisecond update budget, including crowded squares. The previous complete list remains visible until an atomic replacement, preserving selection by object identity. Finalization no longer loops over every inventory.
- Remote sessions renew through small validated commands instead of the inventory timed-action queue. Open windows share a bounded request cache and retry interval; server requests are rate-limited, acknowledgements must match current identities, and expired sessions remain invalid. Read-only access does not grant write permission. Removed assignments, controller power loss and range/access changes remain authoritative. Local proximity to a turret cannot revive a stale controller-stockpile lease. The obsolete timed-action Remote command was removed.
- Buttons, context actions, short fields and container titles use consistent capitalization, including Open Stockpile, To Stockpile, Controller Stockpile, Next Load, Next Shot and Once Each. Explanatory prose remains sentence case. Initial and refreshed controller captions use the same translation keys.

## Review

No balance, recipe, capacity, weapon, contact effect, sound or art change. Traps and Turrets remain independent packages. Callback retries exist only while a completed client transfer awaits confirmation; no permanent additional per-tick inventory or world scan was introduced. Selected-device detail summaries retain their existing cadence. Work-count tests are not a measurement of rendered frame smoothness.

Current installed42.21 evidence includes native `ISInventoryTransferAction.setOnComplete`, native list-row fields, `NetTimedAction.set` named constructor extraction and `AddInventoryItemToContainerPacket.processClient` replacement-item behavior. The server remains responsible for item mutation; callbacks and UI labels stay client-side. No shipped `pcall`/`xpcall` was introduced. Existing unrelated style debt was not silently classified as fixed.

[Validation and four-step test](TEST_v0.2.53.4.md). Rendered acceptance and connected multiplayer remain pending; zero-client native probes do not establish either. The cumulative Workshop draft is preserved under the new version heading. No Workshop publication or main merge.
