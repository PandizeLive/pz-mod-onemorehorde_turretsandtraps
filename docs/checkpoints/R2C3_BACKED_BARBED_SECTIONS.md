# Wall/fence-backed barbed sections

2026-10-07; C97. Design work only. No gameplay implementation, recipe, artwork or new release has been approved by this checkpoint.

## Confirmed direction

Owner clarifies: "id like the host of the barb to be connected to things like walls and fences. itd be semi freestanding. requires a surface behind it". The device is a supported barbed section against a wall/fence, not the suggested wooden window/door-barricade attachment. It belongs to independent Traps. It cannot be placed in open ground without backing. Final art remains owner-sourced; no new art is produced here.

This replaces the proposed initial window/door host list. Owner subsequently selected "Share the supporting wall/fence health" when offered independent barb durability. Preserve one native support-health pool; attaching barbs must not add HP or repair the support. The selection settles health only, not the other proposed contact/removal defaults in that question. Damage numbers, recipe, slowing, player injury and support-loss recovery remain unresolved.

## Recommended first contract (proposed)

Owner subsequently selects "crossing contact", then specifies barbs always use time-based damage while in contact, with 10 damage every two seconds as working tuning. This supersedes the proposed one-hit-per-crossing and attack-event trigger models. Actual contact while standing, pressing against or crossing the barbs qualifies; an attack animation is not required. This does not grant player injuries or prove a contact-detection API.

- Attach to one explicit, supported wall/fence edge and exposed face. Require a supported floor and backing at completion as well as preview. Recommend one tile-edge section initially; footprint is not inherited from 1x2 Bed Spikes and remains an owner decision.
- **Confirmed health model:** use the supporting wall/fence's current health and native damage lifecycle. No separate barb HP, bonus structural HP, attachment healing or invented pool for a static surface. Extra health wear per damaging barb event is not approved; leave ordinary native attack damage as the baseline proposal. First prove which hosts expose suitable health. Shared health may exclude static map walls and some fences; report that limitation before finalizing the host roster. Do not silently substitute independent durability.
- **Confirmed recurring contact model:** damage zombies on a timed interval while physically contacting barbs, including fence crossings. Working tuning is 10 damage every two seconds. Recommend an immediate first hit and one shared per-zombie interval across adjacent sections, retaining the next-hit time through brief exits/re-entry. Verify contact again before each hit; stop damage when contact ends. Do not add separate thump/crossing hits, per-frame damage or lingering damage after exit. First-hit timing, timer behavior under pause/fast-forward, final balance/wear and protected-side contact treatment remain unresolved. No slow, trip, knockback or smart-target filtering is implied.
- If the backing disappears, stop damage immediately and leave an inert recoverable section. Whether recovery yields the whole section or materials still needs approval. An unloaded backing is unknown, not destroyed: suspend until both relevant squares are loaded and validated.
- Bind to the exact backing object/edge, not merely a coordinate. A replacement wall at the same tile must not silently inherit an old attachment. Handle corners, both faces, duplicate placements, map versus crafted objects and save/reload identity explicitly.
- Avoid a second overlapping blocking collider. Preserve the wall/fence's native traversal, sight and attack selection until a separately approved gameplay change requires otherwise. Host lookup should be indexed by loaded edge; event-driven invalidation and bounded cleanup should replace global scans.

## Native evidence and feasibility gates

Installed 42.21 sources, inspected 2026-10-07:

- `media/lua/server/BuildingObjects/ISBuildIsoEntity.lua:154-162,195-198,618-620` distinguishes north/west wall collision and hoppable/tall-hoppable edges using `props:has(...)`. Nearby square occupancy alone is insufficient to identify backing or its exposed face.
- `media/lua/server/BuildingObjects/ISBuildUtil.lua:363-379` configures native pass-through/hoppable/thumpable behavior. It must not be copied blindly onto an attached object.
- Current `projectzomboid.jar` signatures confirm `IsoThumpable` has health, direction, thumpability and hoppability methods. That does not establish that all map walls/fences are IsoThumpable or that every useful API is exposed to Lua.
- Native window/door barricade actions use `BarricadeAble.getBarricadeForCharacter` and `IsoBarricade`. That route is not the requested wall/fence-backed design.
- Existing OMH Spike Barrier strike markers prove behavior for our own controlled barrier targets, not arbitrary wall/fence contact. They do not satisfy the selected continuous contact model; barb eligibility must be independent of attack animation markers.

First local proof must establish exact support lookup and contact geometry for a small declared host set: at least a player-built wall, player-built low fence and representative map wall/fence. Prove contact while stationary, pressing against a support, crossing and aborting a vault; distinguish actual contact from merely approaching. Thump-only or successful-crossing-only damage does not satisfy the requirement. Do not force zombies into thumping or silently change collision to make the prototype appear to work. If support/contact detection fails for a class, report the limitation before restricting the user's intended roster.

Then verify four orientations and faces, corners, intended protected-side behavior, no duplicate timed hits, stopping on exit, short-contact/first-hit policy, adjacent sections and rapid re-entry, pause/fast-forward, destruction/dismantling, backing replacement, chunk unload/reload, save/load, duplicate action/replay, Traps-only and bounded dense contact costs. Rendered contact/placement remains an owner test later.

## Decisions remaining

Footprint; support-loss recovery; supported first host classes with native shared health; whether reinforcement belongs to the wire or the host; final tuning around the owner's 10 damage/two-second example, first-hit/shared-timer/clock behavior and any extra host wear; protected-side contact treatment; player injury; ingredients/tools/skill/XP and service costs. C94's 2.5x reinforced damage direction applies if a reinforced barb variant is chosen, not automatically to support health or costs. Shared support health and recurring time-based contact damage are settled. Next prove suitable host health/contact paths, then present one concrete construction/service proposal.
