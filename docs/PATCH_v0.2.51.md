# 0.2.51 / C262 — owner-test corrections and forward firing

Owner approval: “Approved. Go ahead and implement the patch with all the fixes and confirmed changes. Keep multiplayer in mind and push it to GitHub.” This implements the C259 findings and C260/C261 choices. Existing connected-control device plans remain on R4C1; this patch supplies the projectile receiver's forward-firing path, not installed buttons, plates or a controller.

## Player changes

- Alternate spear and explosive loading
- Void reload recovery and ammunition summaries
- Physical ammunition capacity feedback
- Head statistics and colored module stacking descriptions
- Modular Lure controls and attraction-range feedback
- Module Pack reward tooltips and Open Next
- Corrected rotary and Ballista coverage previews
- Scrapshot eight-pellet damage increase
- Firing-only forward shots
- Separate Lobber landing distance

## Findings and implementation

The client transfer gate still compared ammunition with one exact type although the authoritative loader already understood ammo families. Both now use the same classification; recognized modded spears and supported launchable bombs can enter the ammo slot. This does not invent ammunition definitions for unknown mods.

The Void reload stall came from an ammo-transfer callback using wall-clock milliseconds while reloads used the active-game clock. Pausing could leave the new reload deadline far ahead of simulation time. Transfers now use TurretClock, and cycle processing bounds an already-invalid deadline to one ordinary reload/cooldown interval. It does not instantly complete legitimate reloads. Native testing fires twelve stored spears through multiple magazines.

Ammo/Void hover titles no longer inherit Battery endurance. Void displays the equipped head's compatible totals and a bounded type/count preview; its item tooltip also lists stored ammunition. Cached summaries retain no item/actor references and do not expose private serialized inventory. Expansion dimming follows actual removal eligibility.

Head descriptions show Feature, Ammo, Damage, Range and Firerate. Module Stackable lines describe the benefit of another copy; beneficial values are green and battery costs red. The generic Controls button is removed. Lure has a dedicated range row, Play and ten-second Loop; its emitted effect carries a validated range for a short-lived native world marker. Lobber has its own Landing Distance slider and Payload menu. The ammo/Void slots retain their relevant contextual controls.

Pack rewards expose their module tooltip after settling. Open Next (#), beside Collect, uses the existing exact-pack transfer/timed-action/server reward transaction and is disabled when no next pack is available. Clicking repeatedly cannot grant additional rewards locally.

Scrapshot is eight 40-damage pellets (320 total before hit/miss and module effects), retaining its 90-degree spread. Rotary coverage previews now match the selected front/rear 90-degree sectors; Ballista uses its actual narrower cone.

Firing and Detection remain separate. A manual Fire with Firing and no Detection uses fixed facing, consumes a normal cycle even in an empty lane and never searches for a target. A trusted server receiver entry point shares this path. Existing detected automatic firing is retained. Forward rays reuse bounded projectile work, hit ownership, Horde consent, module effects and persistent jobs; launch/impact identities match. Lobber forward shots use the separately validated landing distance. Physical linked inputs and controller activation are still R4C1 work, not a claim of completion in this corrective release.

## Capacity audit

Placed turrets use native capacity 100; a carried turret container has a different native ceiling and must not be used to estimate the placed limit. Displayed physical capacity uses actual contents weight, the selected round's weight and the head's logical cap. With battery, Large Expansion and sixteen modules, native probes confirm 85 Scrap Metal, 40 crafted spears and 20 Makeshift Bombs for the respective heads. Other equipped items/ammunition weights change these figures. Expansion cannot bypass the native weight ceiling; Void remains the approved weightless storage route. No balance caps were silently increased.

## Authority, performance and remaining acceptance

New controls use the existing server-completed timed action and validate head, range, integer/finite input and proximity. Ammo/power/damage/rewards remain authoritative. Lure presentation is cosmetic; it does not run damage or attraction on clients. Cached Void text, bounded previews/marker lifetime, half-second pack-count refresh and release-only slider updates avoid unbounded per-frame work. Shipped Lua remains free of pcall/xpcall.

Automated/native evidence and the short owner test are in [TEST_v0.2.51.md](TEST_v0.2.51.md). Rendered UI/audio and connected multiplayer acceptance remain pending; zero-client dedicated-server probes do not establish two-client behavior. No recipe, loot-weight, LootLab deployment, Workshop upload or main merge is part of this patch.
