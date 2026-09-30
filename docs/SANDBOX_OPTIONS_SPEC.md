# Sandbox options specification

## Implemented through 0.2.7

| Page | Option | Default / range |
| --- | --- | --- |
| General | Enable Turrets & Traps | On |
| Spike Barrier | Enable Spike Barrier | On |
| Spike Barrier | Damage | 10 / 0-1000 |
| Spike Barrier | Maximum Durability | 100 / 1-10000 |
| Spike Barrier | Reinforced Damage | 25 / 0-1000 |
| Spike Barrier | Reinforced Durability Multiplier | 2 / 1-10; multiplies basic maximum |
| Spike Barrier | Vault Scratch Chance | 5 / 0-50, interpreted as 1 in N; 0 disables spike scratches |
| Debug | Diagnostic Logging | On for development |
| Debug | Foundation Test Controls | Off |
| Debug | Show Collision | Off |

Existing option IDs remain unchanged. Categories are native Sandbox pages. Each future implemented defense gets its own page; expose useful tuning settings proactively and keep tooltips short. Native trip chance is not replaced by the spike-scratch setting.

The sections below also contain future proposals; they do not claim implementation.

Status: mixed implemented/planned contract. In 0.2.0, master Enable Turrets & Traps and Enable Spike Barrier are native Sandbox controls, alongside Foundation Test Controls and Diagnostic Logging. 0.2.3 additionally implements Spike Barrier Damage and Maximum Durability. Other controls below remain planned. One edition, grouped native Sandbox pages; preserve owner-authored tooltip wording.

## Groups and defaults

Include Offline Members = ON and basic Spike Barrier Damage = 10 are explicitly confirmed defaults. The one-edition/toggle-menu structure is confirmed. Other defaults below remain recommendations or TBD, even when a preferred value is shown.

| Group | Control | Type / proposed bounds | Default status |
| --- | --- | --- | --- |
| General | Enable Turrets & Traps | Boolean master control | ON test implementation default in 0.2.0 |
| Content | Enable Potato Turret | Boolean | ON proposed when implemented |
| Content | Enable Punji | Boolean | ON proposed when implemented |
| Content | Enable Spike Barrier | Boolean; native construction and retaliation | ON test implementation default in 0.2.0 |
| Balance | Spike Barrier Damage | Integer 0-1000; implemented 0.2.3 | 10 confirmed; zero disables retaliation |
| Balance | Spike Barrier Maximum Durability | Integer 1-10000; shared across both tiles | 100 retained test default |
| Content | Enable Barbed Barricades | Boolean | ON proposed when implemented |
| Content | Enable Concertina | Boolean | TBD after movement prototype |
| Content | Enable Dart Emitters | Boolean | TBD at P4 |
| Content | Enable Poke Floors | Boolean | TBD at P4 |
| Content | Enable Firearm Sentries | Boolean | TBD at P5 |
| Content | Enable Explosive Devices | Boolean | TBD at P5 |
| Connections | Enable Connected Devices | Boolean | ON proposed at P4 |
| Connections | Enable Buttons / Pressure Plates / Beam Sensors | One Boolean per input type | TBD at P4 |
| Connections | Maximum Link Distance / Outputs Per Trigger | Bounded positive integers; limits TBD | Performance-tested values only |
| Operation | Damage / Durability / Ammo Capacity | Bounded per-family tuning where useful | Values TBD after prototypes |
| Operation | Firing / Reset Interval | Positive bounded duration in In-Game Time | Very slow potato cadence; exact values TBD |
| Operation | Potato Knockdown Chance / Splash Damage | Bounded percentage / nonnegative damage | Targets confirmed; numbers TBD |
| Danger | Player Damage / Faction Member Damage | Separate Boolean or closed enum policy | TBD; does not imply target selection |
| Danger | Allowed Controller Target Modes | Server-level supported-mode limits; exact policy TBD | Individual/all-linked controller targeting is confirmed; defaults unresolved |
| Access | Faction Device Access | Closed supported roles | TBD with ownership model |
| Trait Shop | Enable Shared Defense XP | Boolean; requires supported Trait Shop adapter | ON proposed |
| Trait Shop | Defense XP Pool Percentage | Proposed 0-100%, before division | 25% proposed; awaiting owner decision |
| Trait Shop | Include Offline Members | Boolean | ON confirmed |
| Cure Defense | Simulate Defenses | Boolean; requires final-phase adapter | Not exposed until P6; default TBD |
| Scoring | Score Modifier / Eligibility | Read-only status from Horde Night | Proposed x0.20; official integration not implemented |

Expose only implemented controls. Do not display functional-looking toggles for future content. Keep unavailable dependency features visibly explained without building a second settings system. The exact native Sandbox grouping/conditional UI mechanism must be verified during P2C1.

The control unit provides the owner-confirmed in-world individual/all-compatible-linked targeting selector, including players, other factions and no one. Only devices with smarts follow these filters; passive objects remain unaffected. Sandbox controls govern available capabilities and server rules; they do not replace this per-device/group interface. Zombie targeting, combinations, smart-device capability and collateral behavior must be specified before the relevant content ships.

Player traversal defaults are confirmed design behavior, not new optional toggles: automatic jumping over passive bed spikes and no walking into the Spike Barrier. Player vaulting with 20% front scratch risk and safe rear supersedes the earlier vault ban but remains pending a native prototype. Do not add a faction-dependent exception or controller override. A proposed separate global player-damage setting does not alter these traversal requirements or give passive devices target recognition.

## Configuration behavior

Implemented for the 0.2.0 barrier: block native construction and retaliation while preserving objects, collision and condition. 0.2.3 repairs the 0.2.2 service menu: free repair/full-condition pickup take ten active seconds while enabled. Other-content disabling behavior remains proposed: preserve resources and allow safe recovery. An occupied Poke Floor must stop safely rather than freeze mid-animation.

Master OFF follows the same preservation rule. Re-enabling does not refill magazines, repair structures, reset wear, replay pulses, or create catch-up shots. Server settings prevail over client preferences.

Offline-membership changes affect future kill recipient snapshots only. Already-earned XP is not redivided, forfeited, or regenerated by toggling. The same applies to pool-percentage changes: receipts preserve the earning-time rate and provenance.

Danger settings and cosmetic volume/visual settings must not be conflated. A client reducing potato particles does not change authoritative splash damage.

## Official scoring classification

The desired model follows Trait Shop: approved baseline or demonstrated harder settings may remain eligible, while easier rules retain a run-history flag. Exact classifications are unapproved until behavior is implemented and reviewed.

Not every control is monotonically harder or easier. Turning off a barrier may open a route; reducing player damage increases safety; adding offline recipients divides the same pool differently and creates deferred benefits. Evaluate these explicitly rather than blanket-approving all disabled content or smaller values.

Do not expose an arbitrary official score slider. If a custom modifier is later provided, it must have explicit custom/unofficial provenance. Removing the addon or restoring defaults must not erase already-recorded assistance or rewrite completed scores.

## Timing

Use In-Game Time for autonomous operation, power/decay and reset intervals. Use Action Time for player-performed construction and servicing. The basic-barrier service exception uses ten active real seconds for pickup/free Repair in the current SP implementation; movement cancels either action.

## Implemented value changes (0.2.3)

Damage applies to subsequent strikes. Maximum HP reconciliation records outstanding wear on both loaded halves, then preserves remaining percentage with integer rounding (minimum 1 for a living barrier). Legacy records without a maximum assume 100. Incomplete/unloaded pairs wait for both parts. Repair/new deployment use the configured maximum. No settings XP; menus and startup/migration logs expose current values.

Reinforced damage and durability settings affect only reinforced records. Basic maximum changes also affect the reinforced maximum through its multiplier. Reconciliation preserves remaining percentage; upgrading between tiers instead preserves missing HP under C26.

## P2C3d1 automation and module loot — C57/C58 planned

These controls accompany working d1 effects and native loot integration; they are not in installed 0.2.13. Owner confirms 90-degree default coverage and requests direct control over balance. Keep the following labels/tooltips as implementation proposals, not locked owner-authored wording.

| Page | Control | Behavior / short tooltip |
| --- | --- | --- |
| Turret Automation | Enable automation | “Allow automatic firing.” Disabling preserves items and deliberate manual fire. |
| Turret Automation | Forward cone | Default 90 degrees; “Coverage without a 360 module.” Center stays locked to placement. |
| Turret Automation | Detection interval | Bounded positive seconds; “Seconds between target scans.” Does not bypass shot cooldown. |
| Module Loot | Module loot multiplier | “Overall module abundance. 0 disables drops.” |
| Module Loot | Firing / Motion Detection / Filter / 360 multipliers | Separate per-module controls; “Loot multiplier. 0 disables drops.” Combine with global multiplier. |

Use native weighted distributions; a multiplier is not a guaranteed per-container spawn percentage. Verify actual current-game pool integration before choosing numeric weights. Only functioning modules enter normal loot. Settings affect subsequent loot generation; never refill existing containers, remove owned modules or reset resource state. No hardcoded cheat abundance independent of settings.

Reuse Potato Turret damage/range/ammo/module capacity/power and magazine/reload/cooldown controls for automatic shots. Range display must use the same effective range/cone as targeting. Individual turret on/off and target priority belong in Manage, not duplicated global overrides. Debug retains diagnostics and visual controls.

In P2C3d2 expose useful per-copy bonuses and limits for Rapid-Fire, Velocity, Range and Capacity, plus Reload/Autoloader behavior and their loot controls as each effect becomes active. Preserve short tooltips and grouped pages; no speculative inactive options.

## Implemented P2C3d1 / 0.2.14

The previously planned automation/module loot controls now ship: AutomationEnabled=true, ForwardCone=90 (10–360), DetectionInterval=0.25 seconds (0.1–5), ModuleLootMultiplier=1 and each core module multiplier=1 (0–20). Native pages: Turret Automation and Module Loot. Reload after loot changes; no retroactive refill/removal. Potato combat/storage/power settings also govern automatic shots. See PHASE_2_CHECKPOINT_3D1.md for the complete implemented contract; stat-module controls remain deferred.

## 0.2.15 tuning update

Potato defaults: 100 total rounds; direct damage 35; splash percentage 25; radius 1.5; reload/cooldown 2 seconds, overlapping. PotatoSplashPercent is a new setting replacing the former absolute PotatoSplashDamage; old values are not percentages. Existing saved capacity/radius remain intact. IdleSweepSpeed is 0-180 degrees/second, default 30; 0 disables only the animation, not detection. All remain on the potato page. See PHASE_2_CHECKPOINT_3D1_POLISH.md for test overrides on reused saves.

## 0.2.16 organization and turning

All six pages use OMH: T&T - General / Spike Barrier / Potato Turret / Automation / Loot / Debug. Potato settings are grouped under Operation, Storage, Combat and Power without changing saved option keys. PotatoTurnSpeed defaults 90 degrees/second, range 1-360; both automatic and manual shots wait for one-degree alignment. IdleSweepSpeed remains separate and cannot expand detection coverage.

## Implemented stat tuning — C63, 0.2.17

OMH: T&T - Modules groups Rapid-Fire, Reload, Velocity, Range and Capacity controls. Per-copy gains, maximum bonuses, minimum times, knockdown ceiling and Capacity expansion are configurable; the six new working modules also have Loot multipliers. The existing PotatoCooldown save key still stores seconds per shot, labeled Fire rate (seconds/shot). All defaults, bounds and the hard 30-tile range ceiling are documented in PHASE_2_CHECKPOINT_3D2.md. Reload after settings changes; never delete owned items when limits shrink.
