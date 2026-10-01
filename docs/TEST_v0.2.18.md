# 0.2.18 owner test

Owner reports inventory Install did nothing, Expansion Kit types still said ModuleCapacity, Standard should be Medium, projectile invisible and splat offset. Requests actual shot travel delay and supplies replacement thump/splat audio with random pitch. Other previous behaviors are not newly certified by this report.

Capture: diagnostics/captures/20260930-225142-4179. Console contains failed early requires for BuildingObjects/ISBuildingObject and ISBuildIsoEntity. No turret-install-preview event was found. Native BuildLogic separately reproduces a false return for an already-selected item; verification must inspect the actual selected input. Recorded damage and visual impact occurred in the same frame before this repair.

C66 approves [0.2.19 repair and focused test](PHASE_2_CHECKPOINT_3D3_REPAIR.md). Do not mark the failed 0.2.18 Install/projectile checks passed.
