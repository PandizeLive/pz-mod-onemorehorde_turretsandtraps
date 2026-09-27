# P2C2 outline correction — 0.2.6

Status: implemented and validated; rendered single-player acceptance pending. Owner approval: C40 in [Decisions](DECISIONS.md). This replaces C39's separate actor collision proposal and includes the uninstalled 0.2.5.1 corrections.

## Behavior

- Each barrier remains a 1x2 item with independent identity and shared condition across its parts. Native collision follows its front and exposed end caps. The rear is open to players and zombies.
- Touching straight runs only have caps at their outer ends. Perpendicular front edges may meet without an internal divider. A real gap remains open. Removing or destroying a barrier restores newly exposed neighboring caps.
- White technical edge markers, placement lines and the optional cyan collision overlay show the actual native edges. The existing arrows remain developer footprint/facing markers. These are functional placeholders, not art direction.
- Native Interact/run/sprint inputs use the low-fence action and native trip calculations. Automatic input reach follows the installed player's collision feeler; held movement still works when a wall stops displacement. Root-motion run/sprint contact is tracked without requiring the context-climb animation flag.
- Front vaults roll the existing Sandbox scratch denominator once at contact. Rear and end-cap vaults add no spike scratch; native trips remain possible. This does not turn the barriers into zombie-climbable low fences.
- Retaliation applies to outside front/end thumps; inward faces are safe. Basic damage remains 10 and maximum durability 100, both configurable. Pickup and tool-free Repair remain ten seconds; pickup returns full condition. Recipes, XP and bundle weights are unchanged.
- Existing edge-v1 construction migrates while preserving ledger identity and condition. Correcting the facing boundary can change the joins in old east/south layouts; no automatic repositioning is performed. Legacy full-square diagnostic placements still require pickup/redeployment.

## Implementation and current engine evidence

Geometry is shared by preview and runtime. The two visible footprint objects retain construction identity but become passable/non-thumpable. Owned native edge objects provide collision, vault selection and thump targets. A topology cache uses the persistent registry, including unloaded neighbors; only changes rebuild it. Reconciliation uses the existing bounded scheduler, not a world scan per device. Removal guards distinguish intentional topology cleanup from native destruction.

Evidence uses the installed B42.20.4 b0bbce05d5 classes with PZ Optimizer, loose classes before the jar. Current decompiled evidence is retained under `diagnostics/captures/20260927-145648-1661/native-code/`; render/input follow-up is recorded in [the 0.2.5 review](TEST_v0.2.5.md). The PZ modding, Lua best-practices and B42 multiplayer skills were reviewed. No sibling project or game installation is modified.

- `IsoThumpable.TestCollide` supplies cardinal native boundaries. Front direction determines which boundary anchors a helper; no centered or world-diagonal shape is claimed.
- The C++ pathfinder's `SquareUpdateTask.hasWallThumpableN/W` returns the first eligible thumpable's orientation. At a square containing both axes, corner helper sprites expose both wall metadata directions while retaining only their own tall-hoppable/collision direction and native `north` value. This preserves directional thump ownership. Native probes cover both insertion orders and both Java/C++ pathfinders.
- `IsoMovingObject` uses a 0.5 default feeler. The adapter uses the live feeler plus 0.02 rather than the former 0.45 cutoff.
- Native `vaultOverRun.xml` / `vaultOverSprint.xml` use root motion with `ClimbFenceStarted=false`; their native run/sprint variables and successful between-sample landings settle contact once.
- Screen-space diagnostics run in `OnPostUIDraw`, after the world pass. Overlay logs include world floor/position, projected coordinates, camera and zoom. Input refusals are throttled and include native state/reach; helper creation logs owner, edge, role and health.

## Verification

- 1,433 Kahlua assertions; 24 runtime modules; 103 native JSON translation keys; 23 packet serializations. Package manifest: 77 files.
- Geometry/runtime regressions: all four headings, three-item runs, perpendicular joins, actual gaps, middle removal/replacement, neighbor unloading, helper destruction/orphan cleanup, independent durability, repair, ledger reload and bare-coordinate legacy migration.
- Native probe: four cardinal vault directions, twelve run/sprint parameter cases, and two corner insertion orders with both pathfinders and exact directional thump ownership.
- Dedicated native write/read smoke: 44.4/43.5 seconds, no connected player; 20 texture identities across five pages and 20 native objects restored with owner, orientation, collision and 37/200 condition preserved.
- Logs/manifests: `diagnostics/v0.2.6/`. Test doubles and headless probes do not prove rendered alignment, live native animation transitions, zombie behavior at every join, multiplayer or user acceptance. Gameplay remains SP-only.

## Owner test

1. Restart PZ; confirm **0.2.6** in the OMH developer menu. Use a disposable SP save, No Clip/God Mode off, Diagnostic Logging and Show Collision on. Building Cheat is fine.
2. Build a three-barrier straight run, then test rotated facings. White/cyan edges should match at different zooms: one continuous front, only two outer caps, and an open rear.
3. Make a perpendicular join with front endpoints touching. There should be no internal cap. Leave a separate real gap to confirm it stays open. Try Interact, Shift/run and Alt/sprint across fronts and caps with clear landing space.
4. Set Vault Scratch Chance to 1: front contact should scratch once; rear/cap traversal should not add a spike scratch. Set 0 to disable scratches, then restore 5. Native trips are independent.
5. Pick up the middle section: after ten seconds, surviving ends should be capped. Rebuild it to remove those internal caps. Damage a section and check that tool-free Repair restores it in ten seconds without endless walking.
6. Bring zombies to front and outer caps: they should block/thump and take 10 per registered thump. The open rear should permit entry; inward edge attacks should not retaliate. Check a corner and destruction for stray blockers.
7. Damage a barrier, save/reload, and verify its condition and connected outline. Pick it up and check all its edges disappear. Exit the save and report **Test Complete** so the logs can be reviewed.

Handoff: **Test now** only after the tagged local installation is verified in [Release state](RELEASE.md).
