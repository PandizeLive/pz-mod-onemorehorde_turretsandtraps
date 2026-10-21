# R4C3 - Laser / beam sensor

## C376 - Discuss before build approval (2026-10-21)

Owner asks whether to discuss the laser now or approve Lever first. Recommend continuing laser design now, retaining the settled C375 Lever scope, and considering a combined build once content and native feasibility are settled. This is a recommendation; no combined implementation, merge or publication is authorized by the process question. 0.2.59.1 remains installed with owner testing deferred.

Existing DESIGN.md specifies an obstruction sensor: ON while blocked, OFF when clear. It does not identify friend from foe; receiver targeting/damage policy remains separate. Use current trigger links, permissions, OR contributions and finish-current-action behavior. Passive hazards/Poke Floor do not become signal receivers. Sensors remain non-thumpable under the existing owner rule; no trap modules.

### 1 - Physical setup

**1A (recommended): emitter plus passive reflector**, placed across a passage as one logical Controller input. Clearly defines the monitored segment and requires no second powered endpoint. Costs and native paired-placement/alignment support still need review; this is not an existing native-system claim.

**1B: one wall-mounted unit with a straight detection line**, simpler setup and fewer parts, with the endpoint defined by its configured range/geometry rather than another placed object. Exact static-obstruction and range rules must be settled if chosen.

### 2 - Visible beam

**2A (recommended): faint beam visible during powered operation**, making the monitored line understandable in ordinary play. No light while unpowered; showing beam state/where an obstruction cuts it remains part of implementation verification.

**2B: beam visible only during setup/selection**, reducing visual clutter but making its operating line less obvious afterward.

No beam color/final artwork, range, battery cost, ingredients, skill or XP is selected. Current authorization remains owner-supplied final art and functional technical placeholders only. Before implementation, settle power, maximum reach, mounting/axis restrictions, static obstruction versus moving occupants, fault/unload behavior, player interaction/collateral and a coherent recipe/service contract. Preserve the distinction between an interrupted valid beam and a failed/unpowered/missing endpoint; losing an endpoint must not invent persistent fire. Runtime proof needs bounded local checks, fast crossings, crawlers, door/wall obstruction, lifecycle cleanup, save/load and server-owned synchronization. These are verification requirements, not passed tests.

The prior Lever patch can remain separate if the sensor needs more investigation. No need to force a Lever-only approval before discussing it. New choices 1/2 are unselected.
