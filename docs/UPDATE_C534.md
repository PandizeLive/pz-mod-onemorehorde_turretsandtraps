# C534 - Empty bursts, pause, construction and battery follow-up

Owner approved C532/C533 option 1A, then separately approved the matching seven Horde Night audit defaults and rotary maximum on 2026-10-31. This is implementation authorization, not connected acceptance. Packaging/install/staging are authorized; no upload or live-server mutation is performed.

## Replaced behavior

- Firearm Splitter/Fragment/Piercing rays emit their contact presentation before waiting on a busy damage recipient. A per-ray flag prevents duplicate presentation when the damage request settles. Original firing timestamps travel with rays; clients expire the original burst rather than restart it when a late packet arrives. Rays older than 250ms are discarded cosmetically. Under high transit latency a tracer may be omitted; damage remains server-authorized and unaffected. Physical projectiles keep their existing flight/contact path.
- Empty/misfire Click packets use an eight-tile, quadratic listener attenuation envelope. Native firearm misfire sounds receive the same warning marker; movement/reload/Fragment audio retain normal native attenuation. The custom click explicitly sets distanceMin=1 below distanceMax=8 instead of inheriting an unsuitable native minimum.
- ActiveTime recognizes native pause and the raw simulation rate (getTrueMultiplier), including multiplayer rate zero. It samples after speed-control handlers, discards paused intervals, and logs pause transitions. Combat, contact reporting, motion, Tether/trigger scheduling and new sounds honor that state. Existing tether reel audio mutes while paused. Active Tether displacement clears its queued native movement on pause; no remote-owner movement is written. Tether display expiry uses the active clock.
- The building hook installs after gameplay classes load, on OnGameStart/OnServerStarted instead of menu boot. Native entity validation derives wall direction from tile properties before checking occupancy. Center-to-arm wall edges are blocked in all four directions; outer stabilizer-end walls are allowed. Full-tile furniture remains excluded from all five reserved tiles. Native validation still applies.
- Seven existing battery controls use the rounded approved defaults; no new settings or blanket rounding of runtime math. Rotary's resolver and Sandbox maximum both rise to 200.

## Battery reference and saved tuning

The approved comparison uses the captured Testing loadout: 90-minute days, normal automation combined surcharge 1, enhanced surcharge 4, unlimited replenished ammunition, no other modules/refunds. Changing loot tiers or server settings changes endurance. These are real-time power estimates, not ammunition capacity or guaranteed combat lifetime.

| Head | Normal | Enhanced |
|---|---:|---:|
| Scrapshot | ~29h10m | ~9h10m |
| M16/M4, captured modded profiles | ~12h | ~3h51m |
| Ballista | ~8h20m | ~2h40m |
| Makeshift Lobber | ~5h52m | ~1h46m |
| Arc Emitter | ~1h59m | ~36m |
| Rotary Bat | ~4h | ~1h12m |
| Rotary Blades | ~3h | ~54m |

The stock game's actual M16 profile measures approximately 13h08m with the same module load; the owner's modded firearm profile measures approximately 12h. The shared firearm multiplier remains the approved 0.56. Potato is unchanged. Aerosol/Pipe Bomb share the Lobber multiplier and become approximately 3h55m/2h56m with ordinary automation.

Existing saves retain their explicit values. Apply only these seven values in the existing world's Turrets Sandbox settings to test the approved balance; preserve other options. No new world is needed.

| Sandbox key | New value |
|---|---:|
| ScrapshotBatteryPercent | 0.001 |
| FirearmBatteryMultiplier | 0.56 |
| BallistaBatteryPercent | 0.01 |
| LobberBatteryMultiplier | 0.65 |
| ArcBatteryPercent | 0.007 |
| RotaryBatteryHours | 128 |
| RotaryBladesBatteryMultiplier | 1.33 |

Horde Night's matching baseline is version 0.6.16.11. Its 610 settings/scoring checks pass, including actual independent package-default neutrality. Saved settings and historical run flags are not rewritten.

## Evidence and limits

The new Kahlua regressions exercise 1/2/5/6/16 busy-recipient bursts, delayed/dead-victim settlement, stale packets, all four inner/outer wall directions, warning distances 0/4/8/20/30, zero-rate pause/resume and the approved battery reference. Five frozen released-code controls fail at their named regressions; corrected production paths pass. The old ActiveTime control has only an API adapter exposing its former native-only pause predicate, not the new behavior.

Native probes cover current game classes, queued Tether movement under an actual zero multiplier, actual head item statistics, grass/fern placement, retained blocking bushes, construction entry points, persistence and independent packages. Final results:44,376 assertions, five frozen-code regressions, native save/read and all three package selections pass. See [the verification record](TEST_v0.2.71.3.md). Connected acceptance remains pending.

Plain grass and the native fern sprite have no BlocksPlacement flag. Blocking bushes do. Do not bypass solid props or remove native collision checks based only on the screenshot. Native tests distinguish these cases; the screenshot's exact selected vegetation/obstacle remains unidentified.

Multiplayer Fast Forwarding sets the multiplier to zero; it does not set the game's native multiplayer pause flag. Native network zombie parsing can still reconcile or teleport a replica from packets. T&T's queued pull is now covered, but the user's remaining zombie sliding is not reproduced with connected clients and cannot be assigned wholly to T&T or MPFF from these tests. No global zombie-freeze hook or third-party change is introduced.

## Publication baseline

T&T item 3828638252 successfully uploaded 0.2.71.2 at 2026-10-31T16:11:04Z. Receipt: diagnostics/workshop/upload-v0.2.71.2-20261031-161021-8137-81143a08/upload-result.json, status confirmed, source 9f83c8e731034417f3863fff92194882ea8de67f. Its published notes are complete; the new cumulative draft covers changes after that snapshot. Horde Night's separate pending draft is retained.

GitHub synchronization remains blocked by the earlier automatic approval-review destination rejection. No alternate push route is used. Owner edits to AGENTS.md, README.md, docs/AMMO_UI_C446.md and docs/RELEASE.md are preserved separately.
