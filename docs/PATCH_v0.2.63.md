# 0.2.63 - Controller expansion and presentation corrections

Owner-approved C395/C396 scope, implemented under C397. Local development build; no Workshop upload or hosted LootLab deployment.

- Controller expansion kits
- Progressive Controller discovery and checking indicators
- Downward standby head pitch and post-alert firing delay
- Joined tether segment orientation
- Wall-mounted trigger inset correction
- Local laser, feedback-volume and state-marker options
- Larger module icons
- Mechanical Poke Floor servicing
- Compact repair and placeable tooltips
- Consolidated trap Sandbox groups
- Readable loot settings and 1.00 global default

One Controller expansion slot accepts the existing Improvised, Small, Medium and Large kits. Radius/stockpile progress from 10/100 through 20/200, 30/300, 40/400 and 50/500. Base limits and per-grade bonuses are configurable. Exact installed kits survive pickup/redeployment; capacity reductions retain contents and block extra deposits. Removal/replacement cannot leave an overfull stockpile. Loaded assigned devices outside the new radius remain listed with a range warning; assignments are retained and inactive.

Detection-equipped turrets wake for one second, play the alert and wait another .25 seconds before firing. Losing a valid target cancels wake/delay. Standby pitches the head down at its mount; manual/trigger-only operation remains unchanged.

Laser visuals default off locally; enabled visuals default to 25% opacity. The local sound slider controls device feedback cues, not every weapon shot or other mods' sounds. Server gameplay settings remain authoritative.

Poke Floor has no manual disarm requirement. Repair and pickup require retraction; its careful-walking and contact behavior remains mechanical. Item tooltips omit repair and pickup instructions. Repair menus show required material/tool availability and duration.

Poke Floor and Tether settings now sit inside the Traps page. Stable Sandbox IDs and existing saved values are retained. Untouched loot values retain their original precision despite shorter display text. New defaults and the local LootLab dataset use global multiplier 1.00; existing scenarios/overrides are preserved. Expansion kits also register and spawn with Traps alone.

## Evidence and limits

See [test record](TEST_v0.2.63.md). Native code clamps ordinary container capacity reporting to 100; Controller-specific authoritative transfers and UI enforce the larger allowance. No global engine override is used.

The intermittent base transparency is consistent with the game's native occlusion fading for objects with containers. It has not been reproduced visually here; this patch does not force bases opaque or disable global fading. Wall alignment, cable joins/depth, actual standby appearance and listening acceptance remain owner checks. Native math and server probes do not establish rendered acceptance or connected multiplayer compatibility.
