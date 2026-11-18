# C360 — Native tether investigation

Owner selected C359 1B: investigate actual physics and proceed if feasible. The proposed nail-as-hitched-vehicle approach is investigated, not accepted as a proven implementation. This is conditional authorization for the physical approach; it does not select the previously offered scripted fallback.

## Conclusion

A nail-shaped vehicle could plausibly use vehicle rigid-body physics and a towing constraint. That is not a demonstrated retractable dart trap. The inspected stock API does not provide the required arbitrary-object rope creation and adjustable winch length through ordinary Lua. Making both endpoints vehicles introduces vehicle persistence, collision and multiplayer simulation ownership. Do not implement this as the production trap on the strength of the towing API alone.

This is not a proof that all native extensions or custom physics implementations are impossible. It is a negative feasibility result for treating stock vehicle towing as a ready-made, maintainable implementation of the selected trap.

## Current installed evidence

Inspected the installed `projectzomboid.jar` with JDK 17 `javap -c -p`, rather than treating the older decompile as current proof:

- Build reported by the isolated native runtime: **42.21**.
- JAR SHA-256: `e1a69eb743ede60b213a0fe7f8b83d4fcab773036d256cc4543a336f3b058a33`.
- `Bullet.addRopeConstraint(int,int,float,float,float,float,float,float,float)` exists in the Java/native surface.
- `BaseVehicle.addPointConstraint` takes another `BaseVehicle`, not a wall object, projectile item or zombie. Its current bytecode supplies two vehicle IDs, two attachment positions and a constant final `1.5f` parameter to `Bullet.addRopeConstraint`. The inspected native declaration does not name that parameter; do not present its exact units/meaning as proven from this evidence.
- The inspected Bullet method surface has creation/removal and `setConstraintERP`; no exposed rope-length or winch setter was found. ERP is solver error correction, not a demonstrated reeling API. Changing script attachment offsets or repeatedly destroying/recreating joints would be additional untested workarounds, not proof of a reel.
- The native constraint-creation block is guarded by `!GameServer.server`. The dedicated server maintains towing relationships and sends attach/detach state, while vehicle simulation uses its own authorization machinery. This does **not** mean vanilla towing lacks multiplayer; it means a trap must not assume that a server-created towing relation supplies server-simulated projectile physics.
- Vehicle towing partners and attachment IDs are retained in vehicle state, and reconnection/authorization code is involved. A miniature vehicle does not bypass these systems just by having a nail model.
- The inspected animal-leash alternative draws a line (`IsoAnimal.drawRope`) and restricts movement by distance (`canGoThere`, 15-unit comparisons). It does not supply an arbitrary retractable rope solver.

Public reference corroborating the vehicle-typed API: [BaseVehicle.addPointConstraint](https://projectzomboid.com/modding/zombie/vehicles/BaseVehicle.html). Installed bytecode remains primary for current behavior.

## Isolated runtime check

Reproduction: run `tools/probe_tether_api.py` using the workspace Python. It creates its own local-only server cache under `diagnostics/tether-feasibility`, loads only a small API probe package, and shuts down after reporting. It does not touch the player's save, install a gameplay patch, or insert vehicles into the world.

Completed in **46.1 seconds**, followed by clean shutdown:

```text
[OMHTT-TetherAPI] game=42.21
[OMHTT-TetherAPI] Bullet=nil WorldSimulation=nil luajava=nil
[OMHTT-TetherAPI] vehicle=true addPointConstraint=function canAttachTrailer=function breakConstraint=function applyImpulseGeneric=function
[OMHTT-TetherAPI] completed=true spawnedObjects=0 physicsSimulationTested=false
```

This verifies the ordinary server Lua API surface and construction of an unattached vehicle object. It does not prove projectile-scale stability, actual rope forces, cable rendering, retraction, save/reload of a working trap, or connected-client behavior. No physical swing or in-world nail test was performed. The absence of the named globals does not rule out all imaginable Java bridges; adding such a dependency is outside the selected ordinary mod implementation.

Local raw evidence: `diagnostics/tether-feasibility/result.json`, `native-api.log`, and class bytecode dumps. These cache files are ignored; the reproducible probe and this summary are committed.

## Recommendation and decision

Do not ship a vehicle disguised as a nail. Recommend returning to a small scripted prototype: first-hit collision, a visible tether, full retrieval/reset and authoritative cycle state. This can preserve the selected gameplay without claiming physical tension or zombie pulling. Knockdown remains TBD.

- **1A (recommended):** authorize the scripted launch/retract prototype.
- **1B:** defer the retractable trap; retain this investigation for a future native/custom-physics approach.

Neither fallback is selected by the current message. Conditional physical-path authorization is recorded; its feasibility condition has not been established. No gameplay changes, new dependencies, final art, recipe, balance values, installation or Workshop publication. Version 0.2.58 is unchanged.
