# P2C2 collision feasibility follow-up

## Resolution: superseded by C40

The owner subsequently approved shared native front-and-end collision with an open rear and outermost-only caps. Version 0.2.6 implements that scope in [the outline checkpoint](PHASE_2_CHECKPOINT_2_OUTLINE.md). The actor-specific centered/diagonal experiment below is closed without implementation; its historical findings remain valid for that rejected approach. No Java dependency or game patch was introduced.

## Historical requirement and status

On 2026-09-27 the owner clarified: zombie collision must remain the full occupied block. They asked whether player collision can instead be centered with diagonal connections. This supersedes treating the shared native edge implementation as the accepted final collision model. It does not authorize a Java dependency, a game installation patch, or global collision toggles.

Existing 0.2.5 supports cardinal tile-edge segments and perpendicular edges sharing a tile. It neither centers those segments nor bridges separated diagonal endpoints. Moving a debug line would not move the collision. Existing geometry is unchanged in the independent 0.2.5.1 source corrections; do not install them as a solution to this requirement.

## Installed engine evidence

Evidence uses B42.20.4 b0bbce05d5, with loose classes ahead of projectzomboid.jar. Current decompiled classes are retained in `diagnostics/captures/20260927-145648-1661/native-code/`; additional current javap inspection checked the rendering event order and exposed player movement methods.

- `IsoThumpable.TestCollide`: blockAllTheSquare rejects entry by both players and zombies. North/west edge geometry also serves both. The player-specific exemption is No Clip, which is unsuitable for normal barrier traversal.
- `IsoThumpable.TestPathfindCollide` and both `SquareUpdateTask` implementations derive grid/pathfinder obstacles from native object/tile flags. Adding an independent Lua line does not register an actor-specific navigation obstacle.
- `IsoMovingObject.collideWith`: OnObjectCollide is a notification; its Lua return is not used to choose collision geometry or cancel the native TestCollide result. Temporarily changing shared flags inside it would affect other actors/path caches and is not an acceptable solution.
- `ClimbOverFenceState.setParams`: native vaults store integer start/landing squares one cardinal tile apart. `execute` constrains the lane and slides across that tile boundary. A centered or diagonal crossing is not a configurable origin/direction for this entry point.
- `IsoMovingObject.checkHitHoppable`: adding low-fence flags can allow zombie climbing. Combining tall/low flags is not a player-only switch.

Conclusion: no supported per-actor custom shape setter was found in the inspected ordinary Lua/native thumpable route. This is a limitation of that route, not proof that an engine extension could never implement the design. Full-tile zombie blocking alone is straightforward; independently centered/diagonal player collision with aligned native-style vaulting remains unproven.

## Recommended gate before further geometry changes

1. Prove one isolated barrier can block zombies across both occupied tiles while resolving player movement against a separate center segment, without moving the object, toggling shared passability, No Clip, or positional correction jitter.
2. Prove normal Interact/run/sprint inputs, visible vault alignment, native trip outcomes and safe landing for both faces, then one diagonal connection. Do not confuse a screen diagonal (ordinary cardinal isometric edge) with a diagonal in world coordinates.
3. Prove player action pathfinding, zombie thump targeting, deletion, reload, and two nearby actors agree with the shapes. Multiplayer needs a separate authority/observer gate.
4. Stop and review scope if this requires a Java/loader dependency or replacement traversal system. Recommend preserving Workshop compatibility rather than silently introducing an engine patch. No such dependency is currently approved or installed.

Independent overlay/input/contact corrections are recorded in [the 0.2.5 test review](TEST_v0.2.5.md). They do not pass this geometry gate. Final artwork remains owner-sourced; no new visual design was created.
