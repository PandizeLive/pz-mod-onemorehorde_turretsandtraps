# 0.2.71.13 device fixes

Turret Bases and Controllers now share their placement rules. Both require clear floor space and reject freestanding furniture and existing defense devices.

Tether Darts can be picked up while armed or retracting. Retraction audio plays locally on each recipient and stops at pickup or the expected end of the return. Existing trigger links continue to control firing.

Mechanical Poke Floors have no inventory. Existing items in an old placed floor are returned to that square during loading. Old portable floors return their contents when deployed.

Private turrets retain read-only inspection for ordinary non-owners and the established admin override. [Verification and multiplayer retest](TEST_v0.2.71.13.md)
