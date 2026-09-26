# Modular turret proposal

Owner ideas: a turret inventory holding motion detection, smart-fire, rapid-fire and velocity modules. This document records a proposal, not implemented content or approval of the numerical defaults below. Keep the single edition and Sandbox toggles. No art direction is introduced.

Recommended interaction: open the turret's service inventory and place actual component items into dedicated compatible slots. General storage can hold ammunition, but an item sitting loose in storage does not activate a module. Start with one sensor, one control, one rate and one velocity slot; final slot count remains a design decision. Limit complexity before introducing tiers or arbitrary stacking.

| Module | Proposed behavior | Tradeoff / unresolved detail |
| --- | --- | --- |
| Motion detection | Detect movement within a bounded arc/range and unobstructed lane | Detection alone does not identify factions or authorize firing at players; power/cost TBD |
| Smart-fire | Enables automatic firing and recognized target filters when compatible detection is present | Recognition requires a suitable sensor/camera; obey server PvP rules and control-unit settings |
| Rapid-fire | Proposed 1.5 shots/sec from the confirmed base of 1 shot/sec | One module, no stacking; faster ammo consumption is inherent, additional wear/power TBD |
| Velocity | Increase direct damage; optionally shorten travel time if simulated projectiles are implemented | Current prototype applies immediate hits, so there is no projectile travel-speed value to upgrade; extra pressure/wear/power TBD |

The current implementation is an instant hit plus impact presentation. It does not establish that vanilla weapons have no ballistics. A travel-time implementation would need moving-target collision, door/wall changes during flight, bounded projectile lifetime, and server/observer synchronization. A visual tracer alone must not be advertised as gameplay projectile speed.

Rapid-fire and velocity multiply effective damage output: balance the combined loadout, not only each module in isolation. Modules must not increase the tiny splash or knockdown chance implicitly. Shared target recovery remains independent of the turret fire rate. Do not make faction filters apply to passive barriers or spikes.

P2C3a acceptance: use B42-native inventory and authoritative timed actions; validate access, exact turret identity, component compatibility and current inventory at completion. Save actual installed components and their condition. Removal, pickup, reload and upgrade swaps preserve ammo, wear and any committed shot deadline. Concurrent install/remove attempts cannot duplicate or destroy items. Disable operation while required parts are removed; restore the base capability when optional rate/damage upgrades are removed. Test SP, then connected dedicated clients before claiming MP support.

Delivery order: repair the current prototype; implement the approved crafting/building preview flow; establish the module inventory contract; add detector/control integration with P4 and firearm compatibility with P5. No component system is included in `0.1.4-p1combat`.
