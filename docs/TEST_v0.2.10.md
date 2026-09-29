# Owner test — 0.2.10

2026-09-29: owner completed the hybrid probe test and reported flickering. Visual acceptance failed. Do not treat native import/serialization checks as proof of a usable rotating renderer.

Captured console and installed identity: `diagnostics/captures/20260929-014849-1698/`. The console confirms 0.2.10 on 42.21, two probe creations, native model `Base.OMHTTProbeHead`, 3D ground items enabled, height/scale adjustments and changing yaw during spin. No OMHTT exception appeared in the inspected error contexts. Logs do not establish the cause or exact timing of flickering, nor prove all other visual test steps passed.

The owner requested a return to the usable turret objective and collision for the base. Next delivery should combine meaningful turret integration and outstanding usability corrections; do not ship another isolated calibration release merely to transfer implementation testing to the owner. Keep automated/native checks internal and reserve a short combined owner test for visible behavior that cannot be established headlessly.

The intended base collision is a blocking one-tile turret footprint for players and zombies, with adjacent servicing and zombie thumping. Preserve sight through it; no implicit tall-wall or fence-vault behavior. Native placement, pathfinding, servicing and existing-object migration must be checked together. The separate debug probe is not the gameplay target.

Outstanding work: resolve model flicker and safe head ownership, integrate a tile base/model head into the actual turret, correct the barrier preview leak, implement OMH: Traps / OMH: Turrets categories and usable inventory access, and settle/implement the shared ammo-magazine-reload-cooldown system. Previously proposed 85 total ammo, overlapping timers and two-tool recipe remain recommendations, not silently approved values.
