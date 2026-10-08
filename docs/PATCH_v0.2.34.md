# 0.2.34 — starter modules, expansion and service timing

C104 owner approval, 2026-10-08. Local implementation, validation, test tag and installation are authorized. GitHub mirroring and Workshop publication remain separate.

## Changes

- Fresh defaults: 2 base module slots; Improvised/Small/Medium/Large kits give 4/8/12/16 total slots. Kits replace one another. Existing saved Sandbox numbers retain their meaning and existing contents remain accessible, including over-capacity contents.
- Manage has two rows of eight slots, locked-slot feedback and scrolling for larger custom capacities. Empty slots add no power cost.
- Craft-only Improvised Detection, Firing and Expansion. Detection reaches 75 percent of weapon range after Range bonuses, capped by the engagement slider, with unchanged acquisition speed. Manual fire retains normal range. Standard modules/kits remain loot-based; loot weights are unchanged.
- Improvised Firing has a configurable 15-percent failure per otherwise legal automatic trigger. A failure clicks, consumes no ammunition or shot power, keeps the loaded round and waits the ordinary cooldown. The timer persists on the exact head. Manual shots bypass the failure roll. One module per Detection/Firing role across both tiers.
- Improvised Expansion adds two slots and 25 reserve rounds by default. Standard ammo bonuses remain 50/100/200.
- Placement/pickup is five active seconds for portable defenses and turret bases, including panel attachment/removal. Repair and reinforcement stay ten seconds. Native instant-action debug behavior remains available for placement.
- Aiming reuses the existing bounded inventory-summary cache. Retained automatic targets perform one advisory LOS check per step; a completed multi-tick search and the actual shot still revalidate geometry/resources. This reduces repeated work; the reported 300–700ms client pauses are not proven fixed.

## Approved recipes

All three require Electrical 2, retained screwdriver and pliers, twenty seconds before native skill/moodle modifiers, and 15 Electrical XP.

| Item | Consumed materials |
| --- | --- |
| Detection Module (Improvised) | 3 Electronics Scrap, 1 Electric Wire, 2 duct-tape uses |
| Firing Module (Improvised) | 2 Electronics Scrap, 1 Electric Wire, 4 Screws |
| Expansion Kit (Improvised) | 1 Small Metal Sheet, 1 Electronics Scrap, 1 Electric Wire, 4 Screws |

## Current-engine evidence

Installed 42.21 `ISHandcraftAction:getDuration` multiplies native recipe time by five; `GameTime:getMultiplierFromTimeDelta(1)` gives 48 normal action units per second. Recipe time 192 gives 960 units, or twenty seconds before native modifiers. The native fixture verifies this equality, retained tools, exact consumption and outputs. Placement uses `ISBuildIsoEntity:onTimedActionStart`, preserving native animation, reach, input and construction validation while tracking active real seconds. It signals the underlying timed action, not the Lua Build action cleanup callback: native perform must consume/create before BuildLogic stops. The native wait-for-finished flag prevents trait/fast-forward progress from ending the action early.

Potato failed triggers reference the installed `stormy9mmClick.wav` through a registered sound; firearms use their native click event. No native audio file is copied into the package. [Local audition](../art/IMPROVISED_CLICK.html).

## Verification and remaining acceptance

Kahlua/native results and installation evidence are recorded in [RELEASE.md](RELEASE.md). Tests cover role exclusivity, preserved loaded rounds/power/cooldowns, manual versus automatic range, cached-aim/fresh-shot boundaries, LOS call counts, expanded layout/overflow, service timing, native recipes and fresh-process serialization.

The held 0.2.33 rendered test joins [one six-step owner test](TEST_v0.2.34.md). Rendered movement, high-scale UI readability and dense client frame smoothness remain unaccepted. Building and combat multiplayer remain deferred.
