# Wall/fence-backed barbed sections

2026-10-07; C97. Design work only. No gameplay implementation, recipe, artwork or new release has been approved by this checkpoint.

## Confirmed direction

Owner clarifies: "id like the host of the barb to be connected to things like walls and fences. itd be semi freestanding. requires a surface behind it". The device is a supported barbed section against a wall/fence, not the suggested wooden window/door-barricade attachment. It belongs to independent Traps. It cannot be placed in open ground without backing. Final art remains owner-sourced; no new art is produced here.

This replaces the proposed initial window/door host list. Owner subsequently selected "Share the supporting wall/fence health" when offered independent barb durability. Preserve one native support-health pool; attaching barbs must not add HP or repair the support. The selection settles health only, not the other proposed contact/removal defaults in that question. Damage numbers, recipe, slowing, player injury and support-loss recovery remain unresolved.

## Recommended first contract (proposed)

- Attach to one explicit, supported wall/fence edge and exposed face. Require a supported floor and backing at completion as well as preview. Recommend one tile-edge section initially; footprint is not inherited from 1x2 Bed Spikes and remains an owner decision.
- **Confirmed health model:** use the supporting wall/fence's current health and native damage lifecycle. No separate barb HP, bonus structural HP, attachment healing or invented pool for a static surface. Extra health wear per damaging barb event is not approved; leave ordinary native attack damage as the baseline proposal. First prove which hosts expose suitable health. Shared health may exclude static map walls and some fences; report that limitation before finalizing the host roster. Do not silently substitute independent durability.
- Default to exposed-side, discrete damaging contacts tied to a proven native attack/contact event. Never apply a hit every OnZombieUpdate or multiply a single hit across adjacent sections. Damage/cadence/wear are unresolved. No slow, trip, knockback or smart-target filtering is implied.
- If the backing disappears, stop damage immediately and leave an inert recoverable section. Whether recovery yields the whole section or materials still needs approval. An unloaded backing is unknown, not destroyed: suspend until both relevant squares are loaded and validated.
- Bind to the exact backing object/edge, not merely a coordinate. A replacement wall at the same tile must not silently inherit an old attachment. Handle corners, both faces, duplicate placements, map versus crafted objects and save/reload identity explicitly.
- Avoid a second overlapping blocking collider. Preserve the wall/fence's native traversal, sight and attack selection until a separately approved gameplay change requires otherwise. Host lookup should be indexed by loaded edge; event-driven invalidation and bounded cleanup should replace global scans.

## Native evidence and feasibility gates

Installed 42.21 sources, inspected 2026-10-07:

- `media/lua/server/BuildingObjects/ISBuildIsoEntity.lua:154-162,195-198,618-620` distinguishes north/west wall collision and hoppable/tall-hoppable edges using `props:has(...)`. Nearby square occupancy alone is insufficient to identify backing or its exposed face.
- `media/lua/server/BuildingObjects/ISBuildUtil.lua:363-379` configures native pass-through/hoppable/thumpable behavior. It must not be copied blindly onto an attached object.
- Current `projectzomboid.jar` signatures confirm `IsoThumpable` has health, direction, thumpability and hoppability methods. That does not establish that all map walls/fences are IsoThumpable or that every useful API is exposed to Lua.
- Native window/door barricade actions use `BarricadeAble.getBarricadeForCharacter` and `IsoBarricade`. That route is not the requested wall/fence-backed design.
- Existing OMH Spike Barrier strike markers prove behavior for our own controlled barrier targets, not arbitrary fence/wall attacks. Reusing its full target adapter would be an unverified assumption.

First local proof must establish exact support lookup and native zombie behavior for a small declared host set: at least a player-built wall, player-built low fence and representative map wall/fence. A low fence may be crossed instead of attacked; thump-only damage cannot promise crossing damage. Some map surfaces may never offer the required attack event. Do not force zombies into thumping or silently change collision to make the prototype appear to work. If support/contact detection fails for a class, report the limitation before restricting the user's intended roster.

Then verify four orientations and faces, corners, no rear hits, one damage attribution per event, destruction/dismantling, backing replacement, chunk unload/reload, save/load, duplicate action/replay, Traps-only and bounded dense contact costs. Rendered contact/placement remains an owner test later.

## Decisions remaining

Attack-only versus fence-crossing contact damage; footprint; support-loss recovery; supported first host classes with native shared health; whether reinforcement belongs to the wire or the host; damage and any extra host wear; player injury; ingredients/tools/skill/XP and service costs. C94's 2.5x reinforced damage direction applies if a reinforced barb variant is chosen, not automatically to support health or costs. Shared support health is settled. Next prove suitable host health/contact paths, then present one concrete construction/service proposal.
