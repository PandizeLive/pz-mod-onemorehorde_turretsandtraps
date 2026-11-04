# Correct carried turret capacity and polish pack collection

The carried turret requested 50 contents capacity despite its native 44 limit, and its tooltip repeated the request every frame. Clamp against native item weight and stop configuring storage during tooltip rendering. Module Pack windows now match Manage's dark panels, settle to full-width selected rewards and use one green Collect button without re-granting items.

Adds a deployed LootLab draft tier editor with per-tier weights, individual overrides, drag/drop and keyboard assignment, explicit Confirm/Cancel and conflict protection. Native sound choices are provided in a local audition; runtime sounds/particles await selection. [Validation](TEST_v0.2.47.2.md) separates automated proof from owner acceptance. No Workshop publication.
