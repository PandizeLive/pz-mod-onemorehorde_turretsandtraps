# P2C3d2: active stat modules, 0.2.17

C63 approved. Reload also stacks. Use Reload and Fire rate in the interface; avoid redundant explanations. Implementation complete; installation/native restore evidence is tracked in RELEASE.md. Owner acceptance remains pending, including the entire held 0.2.16.1 test.

## Effective tuning

These are adjustable implementation defaults, not separately owner-selected balance values. All working copies count; broken modules occupy storage without effects.

| Module | Default per copy | Default cap |
| --- | --- | --- |
| Rapid-Fire | +25 percent firing speed | +200 percent speed; 0.25-second interval floor |
| Reload | +25 percent reload speed | +200 percent speed; 0.25-second reload floor |
| Velocity | +20 percent direct damage; +5 knockdown percentage points | +100 percent damage; 90-percent knockdown, without reducing a higher base chance |
| Range | +2 tiles for detection and firing | +10 tiles; hard maximum total range 30 |
| Capacity | +100 total potatoes and +4 regular module slots | One dedicated socket; copies do not compound |
| Autoloader | Zero reload delay | Presence-based; firing interval and all other requirements remain |

Speed formula: base time / (1 + summed bonus / 100), bounded by the bonus cap and a floor that never makes the base slower. At default two-second timers, two copies give 1.33 seconds. Manage shows Reload in seconds and Fire rate in shots/second, using the independent firing interval. The existing Sandbox firing setting remains seconds per shot and keeps its save key. Reload/cooldown continue to overlap; one-round sustained cadence is limited by the slower timer and target acquisition/aiming. Autoloader makes Reload modules redundant while installed; no extra tooltip prose is needed.

Capacity occupies its own socket, leaving all regular slots usable. Broken/legacy duplicates remain recoverable. Reject removing the last working Capacity while ammo or regular modules exceed the resulting limits. Shrinking Sandbox capacity or breaking a Capacity module preserves existing items but rejects new deposits beyond the limit. Packed weight includes every actual item, including expansion. Capacity does not enlarge the magazine.

All effects feed shared stats for manual fire, automatic fire, aiming validation, range visualization, storage and Manage. Splash remains the configured percentage of modified direct damage. Knockdown retains the shared recovery guard. Module changes preserve remaining timer progress; no ammo or power is spent while turning. No physical-projectile speed change, crafting, firearm adapters or multiplayer certification.

## Settings, loot and evidence

OMH: T&T - Modules has Rapid-Fire, Reload, Velocity, Range and Capacity headings. Expose per-copy gains, caps, timer floors, knockdown bonus/ceiling and storage expansion. Existing Loot page gains six per-module multipliers. Default native pool weights: Rapid-Fire/Reload/Velocity/Range 0.5 each, Capacity 0.25, Autoloader 0.1; global and per-module multipliers apply, zero suppresses new drops. Existing generated containers and owned modules remain. Restart after Sandbox changes for consistent cached displays and loot.

Grounding: installed 42.21 ISInventoryTransferAction.isValid/transferItem and ISInventoryPane drop handling retain native timed transfers. Acceptance and final transfer guards enforce logical slots; native ItemContainer.isItemAllowed and actual module conditions are checked in the smoke probe. Historical ItemContainer.java is discovery only. The native loot parser retains 40 entries across four existing pools; no new pool guesswork. Combat authority remains SP-only.

Regression coverage: shared stats, stack caps/floors, zero bonuses, timer changes without reset, actual automatic shot damage/cadence/ammo, Capacity recovery and commit-time rejection, grouped settings, visible stats and module loot. Native checks cover actual module classification, saved base settings, acceptance, exact stacked modules, charge/condition/weight and head-cycle metadata through world and packed save/restore. Gameplay/GPU acceptance stays separate. Final validation: 2,121 assertions, 43 Lua files, 344 native translations and 110 package files; native write/read passed in 42.3/39.1 seconds.

## Complete combined owner test

Use debug item spawning for modules, potatoes and a charged car battery; swap modules between checks as needed. Existing saved Sandbox values remain authoritative.

1. Restart and confirm 0.2.17. Check all OMH: T&T page prefixes, four Potato Turret headings and five Modules headings. Set Turn speed to 30 for an obvious aiming check.
2. Inspect the head/base at several angles and zooms, including near a wall: head sits correctly above its base and surrounding objects still occlude normally. Manage opens without forcing inventories open.
3. Install Capacity in its own socket: defaults become 200 potatoes and eight regular slots. Exceed the base ammo or slot count and try removing Capacity: it must refuse. Remove the excess, then recover it normally.
4. Install two Rapid-Fire and two Reload modules. At default tuning expect 0.75 shots/second and 1.33-second reload. Remove copies: values fall back, items remain, and swapping cannot create a free shot. Autoloader should show zero reload while preserving fire-rate limits.
5. Swap in two Velocity and two Range modules: defaults become 49 damage and 10-tile range. The visible range matches targeting, walls still block, and the fixed forward cone remains until a 360 Module is installed.
6. With Detection, Firing and power, test a target away from the current head angle: smooth turn, then fire. Remove power mid-turn: tracking stops. Check Detection naming and the short 360 tooltip.
7. Disable automation; click Fire once at an off-angle target: exactly one shot after turning. Try again and walk away: cancellation spends nothing. Check the higher brown projectile, larger brown splat and splat2 sound.
8. Pick up with a partially charged battery and installed modules; hover its tooltip without errors. Redeploy and save/reload: exact contents, charge, effective stats and weight remain. Send Test Complete and any visual/audio issue.
