# P2C2b — barrier selection and reinforced texture inputs (0.2.8)

Approved by C45. Implementation prepared; final local installation evidence is in Release state. The owner waived the separate 0.2.7.1 test round and reports reinforcement worked well. No module runtime, recipe change or native furniture pickup integration is included.

## Changes

The old menu relied on individual objects returned by the native picker and selected only the first slot from unmarked floor objects at corners. Selection now collects exact complete barrier identities from picked visual/helper objects and at most nine loaded squares around the mouse projected to the player's floor. Footprint fallback is limited to 0.2 tile outside the 1x2 rectangle. Both parts deduplicate; shared corners produce separately numbered choices; each action revalidates its exact identity. No distant nearest-barrier search, world scan or periodic picker loop.

Hovering the barrier entry or its actions highlights both visual parts. Native onHighlight callbacks clear the highlight when moving between options or hiding the menu. The helper collision objects are not highlighted or mutated. Selection logs include projected coordinates/floor, native picked count, candidate count and misses; menu logs identify the chosen barrier and native/fallback source.

Reinforced world sprite IDs 20-27 now map to four independent OMHTT_ReinforcedBarrier0..3.png texture pages. The basic pages retain IDs 0-15; helper IDs 16-19 remain unchanged. Reinforced inventory/bundle icons and building UI icon are separate too. Existing placeholder PNGs are copied unchanged; no final artwork or design direction is created. Upgrade, placement preview, recovery/deployment and reload continue using the same reinforced entity/IDs.

## Current engine evidence

Installed B42.20.4 b0bbce05d5, loose classes before jar. Vanilla DebugContextMenu.pickSquare projects scaled mouse coordinates through IsoUtils.XToIso/YToIso. Vanilla ISContextMenu.checkHighlightedOption/callOptionHighlightFunction dispatch onHighlight(menu, active, ...); hide paths clear the highlighted option. ISWorldObjectContextMenu's world-item highlight uses the same indexed setHighlighted, setHighlightColor and outline methods. Existing BarrierSprites.entity/name and SpriteConfig maintain tier/part identities.

Regression fixtures cover floor-only corners, repeated picked halves, empty picker fallback, bounded edge tolerance, distant misses, exact helper ownership, different floors, unloaded/removed objects, distinct menu choices, paired highlight on/off and miss diagnostics. Native texture-pack validation checks separate pages alongside 28 serialized identities. Rendered cursor accuracy, zoom and highlight appearance still require an in-game observation.

## Verification

1,502 Kahlua assertions pass, with 25 runtime modules, 122 native translation keys, 23 packet serializations and 83 packaged files. Native write/read probes passed in 34.5/37.7 seconds. The read run verifies all 28 sprite-to-page mappings, eight separate basic/reinforced image pages plus the collision atlas, native indexed highlight/outline on/off methods, and persisted health/tier/collision identities. Rendered acceptance remains pending.

## Owner test when ready

1. Restart PZ and confirm **0.2.8**, with Diagnostic Logging enabled in an SP test save. Existing barriers should remain intact.
2. Right-click both halves and near their outlines at two zoom levels. The barrier menu should open without pixel hunting; empty ground farther away should not select it.
3. At a shared corner, hover each numbered barrier entry and its actions. Only that barrier's two parts should highlight; closing the menu should clear it.
4. Use Pickup on one joined section and redeploy it; check the remaining section is still selectable. Reinforce a basic barrier and save/reload: tier remains reinforced, with the temporary appearance intentionally unchanged. Report **Test Complete** when finished.

## Follow-up

Turret inventory/modules remain next-phase work. See MODULAR_TURRETS.md for eight roles, approved stacking and unresolved recipes/bonuses/power. Native furniture Install/Pickup stays deferred. No remote or Workshop upload.
