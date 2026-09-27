# Sandbox options specification

Status: mixed implemented/planned contract. In 0.2.0, master Enable Turrets & Traps and Enable Spike Barrier are native Sandbox controls, alongside Foundation Test Controls and Diagnostic Logging. 0.2.3 additionally implements Spike Barrier Damage and Maximum Durability. Other controls below remain planned. One edition, one Sandbox page; preserve owner-authored tooltip wording.

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
