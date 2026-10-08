# 0.2.32 — crafting and trap repairs

Owner-approved C101, following the 0.2.31 findings. Local development only; owner gameplay acceptance remains pending.

- Craft finished defenses, then use inventory **Place Trap** for Spike Barriers, Bed Spikes and turret bases, **Attach Trap** for Barbed Panel, and **Install Trap** for turret components. Remove OMH entries/categories from Building. Native placement entities remain private implementation details so rotation, footprint checks and exact-item consumption are retained. No second placement material charge or XP award. Existing recipe costs/tools/skills/XP are preserved, including portable reinforcement at the approved two planks/eight nails, retained hammer, Carpentry 3 and 30 XP.
- Barbed Panel replaces inconsistent section/paneling labels. Move its and Bed Spikes' settings into Traps with headings. Fix the barb service module's startup load order so Repair/Remove can resolve it on the client.
- Permit clear-floor Bed Spikes beside fence/wall edges and attached panels; retain obstruction, occupied-tile and between-halves collision checks.
- Recognize beds as native bushes for movement. Custom brush animation now bypasses noclip and ghost mode, uses native foliage speed, and excludes tree injury events. Walking remains safe. Running retains 20% per-entry scratch risk; sprinting additionally has a configurable 20% trip chance. A new landing on a bed causes one environmental laceration; repeated prone updates do not repeat it. This is an authored bush-like risk, not a claim that vanilla ordinary bushes use this percentage.
- Request zombie falls through the native knockdown lifecycle instead of only selecting the sprinter animation. Increase basic/reinforced bed trip chance to 40%; retain 20/50 damage, six wear and five seconds of protection after recovery. Set potato base knockdown to 40%. Existing Sandbox overrides and module bonuses remain respected.
- Use one repeated bed texture and two panel texture states, with all four directional placements retained. Stable native tile IDs remain; a placement arrow shows the panel's exposed side. Functional white test markers only, not final art.

## Verification

3,728 Kahlua assertions pass, including carried-item invalidation, all five trap inventory routes, Building filtering, fence/panel co-placement, noclip/ghost bypass, sprint fall requests and single landing injury. Native recipe, lifecycle, persistence and independent-package evidence is recorded in RELEASE.md after completion. Headless checks cannot certify rendered transitions or frame smoothness. The reported 300–700 ms pauses are still not proven eliminated.

Use the [four-step focused test](TEST_v0.2.32.md). The owner-waived older regression round stays waived.
