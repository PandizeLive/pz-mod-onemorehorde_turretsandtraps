# C292 — deferred-test audit of 0.2.53.3

Owner request,2026-10-17: “Unable to test this moment. Audit and check for any issues.” This is an audit checkpoint, not a new gameplay approval or acceptance result. Audited installed source commit `9aab2905ab6e003654e1ac1e7f4df1e51ab623b5`, with release documentation at `79188293dca0ae17fe8ff0a7ed9d55ac5a083535`. GitHub dev ancestry and the active development PR were reconciled. Source, packages, version, immutable tag and installation are unchanged.

## Confirmed findings

### 1. Stockpile withdrawals ignore the chosen backpack — P2

`ControlClient.ISInventoryTransferAction:new` receives the destination, but its Controller branch constructs `ControlTransferAction` without passing that destination. `ControlTransferAction:complete` always withdraws to the player's main inventory. Dragging an allowed module into a backpack therefore puts it in main inventory instead; main-inventory capacity also decides admission even if the chosen bag has room.

The reproduction invokes the production constructor hook and completion method. It requests a backpack and observes the exact item arrive in main inventory. No duplication or loss occurred in this reproduction.

Recommended correction: carry the allowed destination identity through native timed-action serialization, re-resolve/revalidate it on the server, and honor its capacity/item rules. Keep unsupported destinations rejected explicitly. Reuse the existing turret transfer destination pattern where appropriate.

### 2. Stockpile replacement actions omit a native completion callback — P2

The replacement `ControlTransferAction` has neither native `setOnComplete` nor callback execution in `perform`. Installed42.21 `ISInventoryPaneContextMenu.onInspectClothing` creates a transfer and immediately calls `action:setOnComplete(...)`. Inspecting a clothing item left in a stockpile from the earlier unrestricted build consequently reaches a missing method. New clothing deposits are correctly rejected, but previously stored unrelated items are expressly allowed to be removed and interacted with.

The reproduction verifies that the action returned through the production native-transfer hook lacks the method. The native caller establishes the failure path; this is not a newly observed player-console error.

Recommended correction: preserve the native callback contract and run it only after a successful, confirmed transfer. Cover failed and cancelled transfers as well as Inspect.

### 3. Automatic names become stale after an unassigned head swap — P2

`ControlNameEntry:refresh` invalidates its placeholder only on `state.numberHead` or `state.number` changes. `ControlWorld.number` returns immediately for turrets without a Controller. Those fields therefore remain unchanged when an unassigned turret gets a different head, while `ControlClient.name` can already resolve the correct new head.

The reproduction changes Potato Launcher to Ballista: the gray placeholder remains Potato Launcher while the normal name resolver returns Ballista Head.

Recommended correction: invalidate using the actual head identity/inventory revision, or pass the already-computed Manage head summary. Avoid adding a full inventory scan to every text-entry refresh.

### 4. Controller list finalization bypasses its performance budget — P2

`ControlPanel:scan` budgets square discovery to64 squares/about2ms. Once discovery finishes, it rebuilds every row in one loop outside that budget. Every unnamed turret row calls `ControlClient.name`, which calls the full `Turret.contents` inventory aggregation just to obtain the head name.

The reproduction supplies32 discovered unnamed turrets and observes32 full-summary calls in one finalization call. With5,000 physical rounds each, those calls imply at least160,000 inventory-item visits, plus aggregation work. This confirms unbounded work concentration; it does **not** establish a measured player hitch duration. Nearby unassigned candidates can also exceed the Controller's32 assigned-output limit.

Recommended correction: read/copy the head label from cached device metadata and finish list updates within the same bounded job. Avoid a new periodic whole-world scan. Separately, opening the generic Controls view on a turret uses the same name resolver in its rendered title, so that path also warrants the lightweight resolver.

### 5. Remote-session renewal can accumulate in the player action queue — P2

Both Controller and remote Manage refresh a session every five real seconds through `ControlClient.remote`, which queues a new `ControlAction("Remote")`. There is no pending-renewal deduplication. In a simulated five minutes with no action-queue progress, remote Manage alone queues60 renewals. The second open window can add more. Native `ISTimedActionQueue.add` appends actions and has no pause deduplication; its tick handler is registered on `OnTick`.

This matters during SP pause or a long inventory action queue: renewals stack behind work and server-side remote leases may expire before a queued renewal is processed. The reproduction confirms request growth, not an observed connected-client timeout. The earlier0.2.53.2 cleared-ControlAction warning remains unexplained; this finding is compatible with queue trouble but does not prove that warning's cause.

Recommended correction: use one bounded, server-validated renewal independent of long inventory transfers, suppress redundant outstanding requests, and avoid accumulating SP renewals while paused. Keep server ownership, range, assignment and live-power validation.

## Verification and limits

- Revalidated all357 installed files against the0.2.53.3 manifest; all match. Shipped Lua has zero `pcall`/`xpcall` calls. Existing older inline-style violations remain; this is not a claim of complete Alex-guideline compliance.
- [Targeted reproduction](../tools/tests/audit_c292.lua) ran on the installed stock42.21 Kahlua/JVM through `KahluaCheck . tools/tests/audit_c292.lua`:205 runtime/translation compilations and20,834 assertions passed, including seven assertions reproducing the five defects. These assertions deliberately confirm adverse current behavior; they do not certify that behavior as correct. The separate82-check module-pack audit was not part of this invocation.
- [Audit output](../diagnostics/audit-c292/verification.log). World/player/network/UI objects in these reproductions are controlled fixtures; installed native source supplies the inventory caller/queue semantics. No rendered game or connected multiplayer pass is claimed.
- The prior full release validator20,909 assertions, native write/read and independent-package startup evidence remain recorded in [0.2.53.3 verification](TEST_v0.2.53.3.md). They were not silently replaced by this audit run.
- Current `console.txt` still identifies0.2.53.2, last written2026-10-17 at03:54 local. There is no new owner0.2.53.3 test to accept or diagnose. No fresh combat, sound or visual acceptance was inferred.

Recommendation: correct these five integration gaps before the deferred owner test and before R4C2. No balance, recipe, art or new feature decision is needed for these corrections. Retain the four-step owner test; do not expand it into another combat checklist. **Wait for a patch.**
