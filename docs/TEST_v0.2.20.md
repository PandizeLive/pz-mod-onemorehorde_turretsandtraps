# 0.2.20 — partial owner test

Owner reports gun sideways, missing-magazine raw key, no dedicated magazine slot, insufficient requirement feedback, reserve preventing head removal, and no gun support. The rest of the test was not completed. Treat this as partial evidence with repair required, not acceptance.

Capture: diagnostics/captures/20261001-174136-1578, captured 2026-10-01T17:41:36.6441664-04:00. Original console SHA-256: 905AF861398B0EDDB9ADB1D16B1A2FC04DD7C3B743C44CFD735E94A80B65D365. Runtime logs identify 0.2.20; capture includes its installed manifest.

The trace records 34 firearm shots (Base.Pistol), NoMagazine responses and rejected head transfers (UnloadFirst). Destruction logs report 17 fallback contents dropped and two scrap. These are observations, not acceptance of every supported mechanism or long-run preservation.

The full console contains 242 occurrences of `expected argument of type Texture, got Double`, through current vanilla ISUIElement.drawLine called by PrototypeEffects.lua:117. The old tracer omitted the texture and thickness parameters. Native font/world-generation startup warnings also appear; they do not explain this mod-owned runtime exception. Recent fire stages around 2ms are not evidence of total-frame smoothness while the render callback repeatedly errors.

[0.2.21](PATCH_v0.2.21.md) repairs the findings and provides one combined short test. Remaining visual, shotgun/rifle, persistence, obstruction/coverage and dense-turret acceptance must not be inferred from the pistol trace alone.
