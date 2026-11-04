# 0.2.60 approved trigger build - C381

Owner approved the combined C375-C380 package after the consumption-rating clarification. Standing C108 authorizes local installation and the development GitHub mirror. No Workshop publication, merge or LootLab deployment is included; these triggers are crafted-only.

## Scope

- Lever
- Laser Sensor
- Controller-powered triggers
- Trigger consumption tooltips
- Rotary Detection gating

Lever mounts on walls, reuses the native light-switch appearance, toggles with a click and shows a faint green indicator only while ON and supplied. Its placed latch survives saves; pickup clears links and redeployment starts OFF while retaining condition. Crafting matches Button: one Electronics Scrap, one Electric Wire, two Screws, retained Screwdriver/Pliers, Electricity 1 and five XP; weight 0.2 and condition 100.

Laser Sensor is a single wall-mounted emitter with a visible powered beam, four outward directions and adjustable 1-10-tile reach. Walls and closed doors shorten coverage without firing. Living players and zombies, including crawlers and fast crossings, interrupt it; it holds the input while interrupted and releases when clear. Crafting uses two Electronics Scrap, one Electric Wire, one Small Sheet Metal and two Screws, retained Screwdriver/Pliers, Electricity 2, ten XP and 20 seconds; weight 0.5 and condition 100. Wall art remains a functional white development panel.

Button, Pressure Plate, Lever and Laser Sensor now require a powered assigned Controller. Mains/generator supply takes priority, followed by sequential Controller Car Batteries. Additional costs are 0.0001% per accepted Button press, 0.01% per active game hour for Plate/Lever and 0.10% per powered scanning game hour for Laser. Controller idle and receiver costs remain separate. Four Sandbox settings are available in either independent mod entry. Mechanical Poke Floor and passive traps remain independent.

Power outages retain links and suppress signals. Restoration reconciles held inputs without replaying Button presses. OR-input behavior and admitted action completion remain; Detection-equipped turrets still need a target. The rotary Detection gate now reads its actual target-present flag instead of bypassing target acquisition. Plates press down physically even without electricity. New triggers use existing one-second placement/pickup and two-second tool-only Screwdriver repair, with condition-preserving recovery.

Tooltips show the OMH-colored band, exact rate and time basis, Controller source and excluded overhead. Continuous ratings share head thresholds per real unpaused hour and reflect day length/Sandbox tuning: at 60-minute days Plate/Lever are Minimal (0.24%/real hour), Laser Very Low (2.4%). Button is explicitly Minimal per press, not an assumed hourly cadence. No drain was raised merely to force a label.

## Implementation and verification boundary

Signal changes, inventory costs and saved state remain authoritative. Sensors reuse the bounded Controller scheduler and spatial tile buckets; actor events test only nearby beam candidates. Client overlays do not decide hits or spend batteries. Lever uses dedicated sprite identities with native switch frames, avoiding collisions with Button's native SpriteConfig registration. Shared Lua files remain byte-identical across independent packages. Native Sandbox IDs are unique: Traps-only uses fallback keys with the same labels; when both mods load, the common Turrets set controls consumption and duplicate fallback controls are hidden. Fresh-world policy remains; changing enabled package selections is not a tuning-migration promise.

See [verification and owner test](TEST_v0.2.60.md). Native fixtures use installed 42.21 objects with synthetic square lookup, including SP/server Lua construction branches; they do not establish rendered client or connected multiplayer acceptance.
