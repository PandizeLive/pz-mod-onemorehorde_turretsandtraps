# Turret inventory and module plan

Current implementation: **P2C3d1 / 0.2.14** activates Firing, Motion Detection, Filter and 360 with loot-only acquisition and grouped Sandbox tuning. [Exact implemented scope and test](PHASE_2_CHECKPOINT_3D1.md). The six stat-module items remain debug-only storage; effects/gains/caps are d2. Crafting is deferred. Later proposals below remain unimplemented unless explicitly covered by d1.

## Inventory interaction

Each turret has an ammunition area and module slots. Dragging actual components into/out of slots is the intended installation/removal flow; right-click installation menus are superseded. The dedicated window and native timed inventory transfers are implemented in 0.2.12. Working core modules activate from actual container contents; stat modules remain inactive.

Installed component items, ammunition, wear and committed cooldowns must survive saving and pickup/redeployment. Transactions must not duplicate components, discard ammo, reset cooldowns or provide repeated module-swap repair. Tier upgrades restore full condition under C43; module-swap repair policy still needs an explicit decision if presented as an upgrade.

## Ten module roles

| Module | Confirmed role | Stacking / unsettled details |
| --- | --- | --- |
| Firing | Accept FIRE requests and operate the firing mechanism, enforcing ammunition, cooldown and the eventual power requirement | One recommended; power source/consumption TBD |
| Motion Detection | Follow eligible zombies within range and a forward cone, aim, and supply FIRE requests | Stationary zombies remain detectable; no movement/breathing simulation. One recommended; arc/range/turning TBD |
| Filter | Choose Closest, Furthest, Weakest or Toughest target priority | One recommended; Closest default and current-health ranking proposed. Priority is distinct from player/faction eligibility |
| Rapid-Fire | Increase firing rate | Multiple modules explicitly allowed; each consumes module space. Formula, per-copy gain and minimum cooldown TBD |
| Velocity | Increase direct-hit damage; increased direct-target knockdown chance supported as a proposal | Multiple modules explicitly allowed. Damage/chance gains and caps TBD; tiny splash and recovery protection must not be multiplied implicitly |
| Capacity | Increase ammo storage and module space | Single dedicated expansion slot recommended, not owner-final. Reject removal until contents fit the reduced capacity; no deletion/automatic dumping |
| Range | Increase firing and detection reach | Multiple modules explicitly allowed; increments/maximum TBD. Preserve obstruction checks and loaded-area bounds |
| 360 | Expand placement-locked firing/detection coverage to all directions | C56 applies coverage to manual and automatic targeting. One recommended; no extra distance or standalone automation |
| Reload | Reduce reload duration | Proposed for the firearm/reload checkpoint; stacking not yet decided |
| Autoloader | Expensive module removing reload delay | Still consumes ammunition; retaining pump/bolt cycling and firing cadence is the recommended boundary, pending firearm feasibility |

Firing, Motion Detection and Filter are separate. Earlier Smart-Fire/Powered-Firing merger proposals are superseded. Automatic fire needs Firing plus Detection. External button/plate/laser signals can request fixed-direction firing without onboard Detection. Filter alone neither detects nor fires.

Buttons emit pulses; pressure plates remain ON while occupied and lasers while blocked. Device cadence bounds held signals. Multiple signal sources must not multiply firing rate or bypass cooldown. Target retention/hysteresis is recommended to prevent oscillating aim.

## Stack balance and Sandbox controls

Range, Velocity and Rapid-Fire stacking is owner-approved. Recommend additive per-copy bonuses with explicit caps rather than exponential multiplication. A positive minimum shot interval, bounded scan range and knockdown probability capped at 100 percent are implementation safety requirements, not excuses to silently disable stacking. Shared fallen-target recovery protection remains independent of rate and module count. Balance the combined rapid/velocity loadout.

Expose useful controls when each feature actually exists: base ammo/module capacity, capacity bonuses, detection cone/range, rate/damage/knockdown bonuses, range increment and maximum, and any power consumption. Keep categories under the relevant turret/defense and concise tooltips. Do not add inactive settings for planned modules.

## Crafting routes deferred for modules

The earlier wood/Mechanics-1 turret proposal is superseded by C49: metal universal base at Mechanics 2, powered potato head at Mechanics 2/Electrical 1, improvised head at Mechanics 4/Electrical 1. Complete and separate routes have identical material and XP totals. Exact recipes and retained tools are in [P2C3](PHASE_2_CHECKPOINT_3.md#approved-recipes).

Future motion-detection crafting idea (deferred by C57): low-skill assembly using vanilla Base.MotionSensor, plus higher-skill fabrication from raw materials. Electrical is the recommended primary skill; exact ingredients/skill/XP are unsettled. Installed B42 provides MotionSensor and yields it through HomeAlarm dismantling.

## Evidence and delivery

The current potato prototype uses immediate hits, range 6, overlapping two-second reload/cooldown in 0.2.13, direct knockdown chance 70 percent and a shared 3000 ms recovery guard. Those are implementation facts, not approved module bonuses. Velocity cannot affect gameplay projectile speed until real travel-time collision exists; a tracer alone would be cosmetic.

P2C2b finishes barrier selection and distinct reinforced texture inputs. P2C3a-c establishes approved turret recipes, native construction, real ammo/power inventory and exact-item transfers; P2C3d adds module effects, and P2C3e proves multiplayer/performance. Pressure plates, lasers and control-unit linking remain P4; firearm integration and Reload/Autoloader behavior remain P5. No module art is AI-generated.

Acceptance: exact device/item checks at completion, persisted components/resources/deadlines, incompatible-item rejection, no duplicate grants on cancellation/concurrent requests, stack totals reflected accurately, capacity-removal refusal, and dedicated multiplayer proof before enabling that runtime. Current SP prototypes do not establish multiplayer support.

## Next checkpoint proposal after C56

P2C3d1: lock the cone to stored placement orientation, independent of head aim. Apply the same range/angle/obstruction eligibility to manual and automatic shots and display the same effective geometry during placement/selection. C57 confirms a 90-degree default (45 degrees each side), with a short Sandbox control. Firing plus Motion Detection enables autonomous fire; Detection alone can track but cannot fire autonomously; Filter chooses Closest/Furthest/Weakest/Toughest. 360 changes angular coverage only and can expand manual targeting without granting autonomous fire. Removing 360 immediately restores the placement cone and invalidates out-of-cone targets. Existing loaded turrets use their saved base orientation, not last target heading.

Recommend Enable/Disable in Manage to stop autonomous shots while preserving servicing; manual Fire remains a separate deliberate action. Target acquisition must be bounded and staggered across turrets, with a final shot-time range/angle/obstruction/resource check. No wall penetration, unloaded combat or burst catch-up. These d1 details are implemented in 0.2.14 under C59.

P2C3d2: review concrete stack gains/caps, Capacity expansion/removal, Reload/Autoloader effects on the shared potato cycle, and their loot balance. Keep firearm-specific adapters for P5. C57 defers all module crafting, tools, skills and XP; no recipe review blocks core module effects.

The owner holds 0.2.13 visual/balance acceptance for the next combined gameplay test. The held test is combined with the 0.2.14 core automation build.

## Loot-only acquisition — C57

Modules will be found as loot for now. For d1 introduce Firing, Motion Detection, Filter and 360 into suitable current-game distributions; do not distribute inert future-effect modules as normal gameplay loot. Recommend electronics/industrial pools, with the two modules required for automation more available than optional Filter/360. Verify exact native pools and decide conservative weights during implementation. Recommend a useful module loot abundance Sandbox setting with a short tooltip. These are proposed distribution choices, not existing or owner-specified exact spawn weights.

## Owner tuning — C58

Include grouped Sandbox controls with d1: automation toggle, placement cone (90-degree default), bounded detection interval, global module loot multiplier and individual Firing/Detection/Filter/360 loot multipliers. Zero disables new drops; existing items remain. Reuse per-turret combat/storage/power controls. Current-game weighted loot requires honest multiplier labels rather than exact probability promises. Keep individual on/off and Filter priority in Manage. See SANDBOX_OPTIONS_SPEC.md for the planned table. Add stat-module bonuses/caps/loot controls with their functioning d2 effects.
