# C399 - Performance and lifecycle hardening

Owner selected C398 **1A** on 2026-10-22. This authorizes the existing-contract performance/lifecycle pass; it does not change balance, add content or establish rendered/connected acceptance. Owner testing remains deferred.

## Confirmed findings and corrections

- `ControlDiscovery.tick` previously restarted `pairs(pending)` and stopped after 64 candidates. Persistent unresolved candidates could starve later devices. The failing Kahlua reproduction seeded 256 candidates and failed to discover a ready later device after four updates. A FIFO retry queue now gives each candidate a turn, capped at 64 per 250ms update. Metadata is checked before timeout eviction. Removed/expired candidates release queue references; removal/re-add does not duplicate work. Queue memory scales with pending candidates; this is not a globally fixed memory bound.
- `ControlExpansion.item` repeatedly called native `ItemContainer.getItemWithID`, whose current 42.21 bytecode searches the inventory list. A weak exact-item cache now checks identity and current container before reuse. Removal, replacement or a changed container invalidates it. Missing items are not negatively cached.
- Client capacity/range previously depended on inventory arrival even when the server had already published the expansion grade. Clients now use that published grade. Server/SP still derive it from the actual installed item; no client-authoritative capacity was introduced.
- `ControlPanel.scan` registers its own Controller immediately so assigned-device host lookup does not wait for the spatial scan to reach the center tile.

## Evidence

The focused fixture is `tools/tests/performance_c399.lua`, included in the normal Kahlua validation pipeline. The initial failure is retained locally in `diagnostics/c399/before.log`.

- 256 pending candidates: all receive a turn within four updates; at most 64 state reads per update.
- 12,800 repeated capacity/range queries: one inventory lookup for an unchanged kit. Exact-item removal and late client inventory cases pass.
- Removal, re-add, metadata arriving at expiry, unresolved expiry and queue draining pass.
- 320 mixed devices across eight families: each receives one scheduler dispatch across five updates, at most 64 per update. Expensive device bodies are test doubles; this measures fairness and dispatch count, not full combat cost.
- Existing exact-kit replacement/rollback/overfull/pickup/redeploy and heavy Controller persistence fixtures remain in the full validation/native suite. See the version test record for final results.

Current-game evidence is the installed 42.21 `projectzomboid.jar`, including `ItemContainer.getItemWithID`, `InventoryItem.getID` and `InventoryItem.getContainer`; historical decompiled sources are not the compatibility proof.

## Remaining limits and next investigations

This is a corrective slice, not closure of R1C3 or R5C1. No FPS gain, worst-case combat latency, rendered fix or connected multiplayer pass is claimed. Native probes have zero connected clients.

The Controller warm-cache seed still considers only the first 64 global known objects before spatial discovery. Large caches and assigned out-of-range devices need a separate fair/priority lookup reproduction. Continuous dirty receiver work may compete with ordinary scheduler work; the mixed fixture does not simulate a permanent dirty backlog. Connection row construction under very dense scenes also needs measured client evidence. These are follow-up investigations, not confirmed additional fixes or owner decisions.

Balance, sounds, art, Horde Night integration and LootLab tuning remain unchanged. The 0.2.63 visual checklist remains deferred.
