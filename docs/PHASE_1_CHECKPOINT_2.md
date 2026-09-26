# Phase 1 checkpoint 2: directional 1x2 Spike Barrier

Version: `0.1.6`. Date: 2026-09-26. Owner requested a safe rear face and a 1x2 footprint after the completed `0.1.5-p1retaliation` test. The side ends are included under the owner's gameplay allowance. This remains an SP combat prototype; final construction is a later checkpoint.

## Completed player test review

Captured [console.txt](../diagnostics/captures/20260926-024551-7245/console.txt) before changing the installed package. [Metrics](../diagnostics/captures/20260926-024551-7245/review-metrics.json) preserve the 663 structured events. Exact loaded version: `0.1.5-p1retaliation`; game header: B42.20.4 b0bbce05d5. One SP session, 14 translation probes with zero missing strings, zero suppressed diagnostics and no OMHTT exceptions.

- 81 barrier strike records: 75 full hits at approximately 20 damage and six finishing hits limited to remaining HP. Six barrier kills; optional Pixel Indicator received actual damage at scale 100.
- Five successful potato shots from six attempts. Four full 50-damage hits and one finishing hit; the extra attempt was an empty turret. Four requested knockdowns reached the floor by their final observation. Samples show StaggerBackState and native fall/ground states with physics reactions disabled, matching the owner's positive report.
- Displacement includes animation/root movement and reaches roughly 1.4 tiles in one sample. It does not establish a precise quarter-tile impulse. The owner reports the result is working well; this patch retains the accepted reaction settings.
- All 24 texture-readiness observations resolved. Five marker-wait warnings followed gaps of roughly 45-72 real seconds and later resumed; the capture does not prove their cause. Do not mislabel them as known animation failures or proven pause behavior.
- The test exposed the missing facing restriction: the old code validated the attacker and target but never classified the attacked face. No new client save/reload acceptance is inferred from this run.

## Behavior

The barrier occupies two tiles across its width and one tile in depth. Existing white technical arrows indicate the dangerous front. Front and both short ends retaliate for 0.20 native HP (20 at Pixel Indicator scale 100); the rear face is safe. Rear-corner ties are safe. Face classification uses distance to the rectangular footprint's faces, so a side-end attack can remain hazardous slightly behind the centerline; a rear-face attack does not. Suppressed rear strikes still consume their marker, preventing delayed damage when a zombie walks around the object.

Two native IsoThumpable objects share one persistent device record, condition and identity. Secondary slots reference the primary slot by coordinate key, not serialized Lua table identity. Inspection/removal from either tile resolves the same device. Rotation retains the original anchor tile and validates the destination tile before moving the second half. Both arrows and both collision objects turn together; blocked, occupied or unloaded destination tiles reject the rotation.

Wear on either half reduces one common 100-point durability pool. Concurrent loss on both halves is summed once. Rotation does not heal the device. Destroying/removing either half retires the device and removes its partner. If that partner is unloaded, a persisted exact-ID cleanup record removes it when its square loads, preserving unrelated objects. Ambiguous duplicates fail closed rather than deleting an arbitrary object.

Existing one-tile barriers expand when their adjacent required tile is loaded, clear and within the ledger limit. Their ID and remaining condition are preserved. Blocked expansion leaves the original barrier intact and emits `barrier-expansion-deferred`; clearing the space allows a later bounded update to expand it. Fresh placement requires both tiles; it cannot leave a half-built barrier. The 64-slot prototype limit counts physical tiles, including retained lifecycle slots.

Native evidence: installed `media/lua/server/BuildingObjects/ISDoubleTileFurniture.lua` (`create`, `setInfo`, `removeFromGround`) establishes separate native objects on adjacent squares with AddSpecialObject/transmit operations. This implementation adds exact-ID pairing rather than copying vanilla's first-thumpable removal search. Existing verified B42 blocking/hoppable flags and marker animation remain unchanged. No new artwork was generated.

## Verification and scope

The [validation log](../diagnostics/v0.1.6/validation.log) records 175 passing assertions, 11 compiled Lua modules, 56 native translations, and 23 packets (maximum 389 bytes). It checks native Kahlua compilation, JSON translations, animation parsing, save-table serialization, command packets and behavioral fixtures. The fixtures cover all four orientations, safe rear corners, rear-to-front marker reuse, simultaneous wear, blocked rotation, either-half operations, persistence, unloaded partner cleanup, replacement identities and legacy migration. World objects are doubles; live collision/pathing and paired destruction need player acceptance. The standalone native fixture's file-GUID-table warning remains unrelated to the actual loaded mod.

[Server smoke](../diagnostics/v0.1.6/server-restart-console.log) proves the final candidate loads, resolves translations, saves and shuts down in 39.2 seconds with no connected player. [Release-tool fixtures](../diagnostics/v0.1.6/release-tools.log) also pass tag/branch checks, read-only readiness, backup/preservation and rejection cases. It does not certify multiplayer gameplay. Combat guards remain SP-only. Previous fast-forward/strike-marker coalescing and final-breaking-strike limitations remain tracked in [the original retaliation record](checkpoints/P1_RETALIATION_RECORD.md).

Changed areas: shared geometry/markers; barrier lifecycle and face filtering; authority routing; package identity/version text; regression fixtures; stable release menu and numeric-version tooling. Potato cadence, damage, knockdown, components, rewards and recipes are unchanged. See [release process](RELEASE_TOOLS.md), [release notes](PR_v0.1.6.md) and [manifest](../diagnostics/v0.1.6/manifest.json).

## Owner test

1. Restart PZ, enable **OMH: Turrets & Traps**, and load an SP test save with Foundation Test Controls enabled. Confirm the developer menu reports **0.1.6**; use normal game speed and Pixel Indicator scale 100.
2. Place a barrier in clear space. Expect two adjacent arrow tiles, both blocking walking/vaulting. Existing barriers expand only where the required space is clear.
3. Have zombies thump the arrow-facing front, a side end, and the rear. Front/sides should show **20** damage; the rear should show none while still damaging the barrier.
4. Inspect either half and rotate it in clear space. Expect both arrows and the second tile to move; repeat beside an obstruction and expect refusal without losing a half or healing it.
5. Save/reload, inspect either half, then destroy/remove one. Expect shared condition to persist and both halves to disappear, with neighboring objects preserved. Fire one potato as a quick 50-damage/stumble regression.
6. Stop and report **test complete**. I will capture console.txt and review facing decisions, both-tile state, wear, cleanup and errors before checkpoint acceptance.
