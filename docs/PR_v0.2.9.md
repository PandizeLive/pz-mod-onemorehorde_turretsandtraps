# Modular potato turret crafting, storage and power

The potato prototype previously used diagnostic placement and a numeric ammo counter. Players can now craft a universal base and potato head separately or together, deploy a loaded turret through Building, transfer real ammunition/components through inventory, fire using real potatoes and power, and recover it without losing contents or refreshing supplies.

Native item containers preserve battery charge, individual item identities and total carried weight. Registered aiming sprites keep native sprite metadata valid through save/load. The existing P2C2b barrier selection/highlight and reinforced sprite changes remain included in the combined test.

Five approved recipes, a Potato Turret Sandbox page, transfer/power/combat diagnostics, and the complete combined owner test are in [P2C3](PHASE_2_CHECKPOINT_3.md). Module storage is implemented; module effects and multiplayer gameplay are deferred.

Validation targets installed stock B42.21.0. The old installed PZOptimizer compiler override is incompatible with that game update; the isolated native runner supports stock-first class loading without modifying the installation. Player acceptance remains pending.
