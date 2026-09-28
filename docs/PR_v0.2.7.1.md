# Full repair on reinforcement, lighter barriers and service arrival

Reinforcing a damaged barrier now restores its full reinforced durability. Basic and reinforced portable items weigh 4 and 5; their five-item packs weigh 6.6 and 8.25, retaining the 67 percent reduction.

The approach action no longer tests adjacent collision against its own tile after crossing into a waypoint. Native pathfinding still finishes before service begins, and failure logs include destination and timing context. This addresses the two immediate-arrival failures in the 0.2.7 player log.

Validation: 1,474 Kahlua assertions, native script/item/pack probes and package checks; see [checkpoint and owner test](PHASE_2_CHECKPOINT_2A_REPAIR.md). Native Moveables integration remains a separate proposal. Rendered acceptance is pending; no remote or Workshop publication.
