# P2C2a correction — 0.2.7.1

C43/C44 authorize full repair on upgrade and lighter portable barriers. Installed locally with all 77 files verified against the tag/archive; rendered acceptance remains pending.

## Changes

- Reinforcing restores the configured reinforced maximum immediately, clears accumulated damage, and updates every visual/collision part. At defaults, 70/100 becomes 200/200. Recipe, ten-second action and 30 base XP stay the same.
- Basic/reinforced loose weights are 4/5. Five-item packs are 6.6/8.25, keeping the approved 67 percent reduction.
- Service approaches skip the adjacent collision query once inside the waypoint tile. Native pathfinding must still reach its destination before advancing/servicing. Actual neighboring edges, cancellation and stall timeout remain checked. Failure logs now include target coordinates, total elapsed time and time since movement.

## Player-log and engine evidence

Capture `diagnostics/captures/20260927-205142-4502/` confirms loaded 0.2.7. Approach failures at sequences 117 and 156 occur 283/269 ms after starting, immediately inside their target tiles: (8344.994,12196.564) targeting (8344,12196), and (8347.469,12196.971) targeting (8347,12196). Both meet zero-offset query conditions rather than the three-second stall timeout. Retry at sequence 165 starts service immediately; sequence 205 completes a real-material upgrade consuming ten items with 30 base XP. Sequence 250 completes reinforced pickup. These are partial observations, not blanket P2C2a acceptance.

Current installed B42.20.4 `IsoGridSquare.testCollideAdjacent` consults its collision matrix even for zero offset; it is an adjacent-movement query, not an arrival predicate. Current vanilla `ISWalkToTimedAction` waits for path behavior success. The regression supplies a same-square collision result while native pathfinding is still working and confirms arrival is neither cancelled nor completed early.

Current installed `InventoryItem` bytecode saves a weight override only when customWeight is true. Our normal scripted items do not set that flag; ordinary saved inventory items use the current item definition on reload. No per-tick inventory scan or migration is added.

## Native Install/Pickup feasibility

Current vanilla `media/lua/shared/Moveables/ISMoveableSpriteProps.lua` lines 123, 183 and 1167 onward require moveable properties and native sprite-grid membership; multi-sprite furniture can use a single-item policy. Pickup saves thumpable parameters, transfers components and removes native parts. Placement reconstructs them (`placeMoveable` / `placeMoveableInternal`, lines 1840/1937 onward).

This means the user-facing native controls are feasible in principle, not impossible. Our two visual parts, independent owned collision helpers, ledger retirement and neighboring recapping need a narrow adapter into existing construction/service operations. Turning on IsMoveAble alone would not establish that contract. Recommend a separate checkpoint preserving one item per barrier, tier, ten-second pickup, full recovery and construction validation. Scope remains proposed; this correction does not expose incomplete native controls.

## Verification

1,474 Kahlua assertions pass, including damaged upgrade to full HP, all-part synchronization, subsequent damage persistence, 10-second service and zero-offset arrival regression. 24 runtime modules, 121 native translation keys, 23 packet serializations and 77 package files pass. Native item/pack transactions and serialization passed the installed-engine smoke in 77.3 seconds; results appear in Release state. World/player/UI doubles and headless probes do not prove rendered acceptance.

## Owner test

1. Restart PZ and confirm **0.2.7.1** in the developer menu. Use an SP test save with diagnostics enabled.
2. Check loose basic/reinforced items: weights **4/5**. Pack and unpack five of each: **6.6/8.25** packs, correct tiers, no extra items.
3. Damage a basic barrier, then reinforce it. Expect the full reinforced maximum (**200/200** at defaults), consuming the approved recipe once.
4. From a few tiles away, select Repair or Pickup on different sides. Walking should finish without the former arrival warning; service takes ten seconds and movement cancels it.
5. Redeploy the recovered reinforced item. Check its tier, visibility and collision; save/reload and confirm the same behavior. Report **Test Complete** for log review.

Handoff: Test now only after local installation is verified.
