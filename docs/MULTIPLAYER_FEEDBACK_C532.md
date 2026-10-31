# C532 - Connected 0.2.71.2 failures

Owner reports post-empty firing effects, excessive click range, fast rotary drain, multiplayer-pause movement/audio, vegetation placement rejection and native walls crossing Poke stabilizers. Owner clarifies the empty case was **M16, no Void or Conservation, no damage, delayed Splitter visuals**. This does not establish free-ammo damage. Owner additionally confirms zombies still move while paused and does not attribute the cause to T&T.

Status: investigation only. No gameplay, package, install, Workshop, server or sibling edit. Corrective scope awaits discussion/approval. Source and installed build remain 0.2.71.2. Connected acceptance failed; prior automated checks are not evidence that these reported defects work.

## Evidence and reproduced failures

- Local console and SFTP server metadata confirm 0.2.71.2. Active server is Testing, with DayLength=4 (native SandboxOptions mapping: 90 minutes). Captured logs/settings remain local in diagnostics/c532; hashes and calculated results are in [the receipt](evidence/c532-investigation.json).
- Client console lines 654-658 and 1545-1547 show the three BuildingObjects requires failing, then ControlBuildReservation.install indexing a nil ISBuildIsoEntity. The hook registers OnGameBoot; the native classes live under server/BuildingObjects. The previous native tests loaded server classes first and manually invoked installation, missing menu-stage client startup. Lifecycle repair must actually install the gate after dependencies load on both sides, not simply swallow the nil case.
- The operating geometry predicate also blocks the owner's allowed wall beyond an arm end. Replace the edge rule: forbid walls through the center and center-to-arm boundaries; allow outer perimeter walls that do not cut the assembly. Keep full-square furniture occupancy separate. Images 4/5/6 define allowed/blocked/blocked, respectively.
- Firearm TurretVolley.finish checks Damage.available before emitting Ray. Physical child impacts were moved ahead of that wait in C531, but firearm tracers were not. Rays have no original firing timestamp. DefenseEffects.send stamps emission time, and PrototypeEffects.receive starts Ray on arrival. The production-function replay holds six children for a synthetic 1000 ms busy victim, then kills the victim and releases them: six fresh client tracers, no new damage. Exact live wait duration and the share caused by worker contention remain unmeasured. Fix presentation timing without granting client damage authority or discarding legitimate committed damage merely because ammo is now empty.
- OMHTTTriggerClick defines distanceMax=8, volume=.7, but no distanceMin. Native GameSoundClip defaults minimum to 10; FMOD FileSound uses that field. The min/max pair is invalid. Generic delivery reaches listeners within a 100-tile axis box, and the client Click branch has no close-listener cutoff. Firearm misfires can instead select the mounted weapon's native click cue, so both warning paths need positional attenuation and a consistent local cutoff. This is code evidence, not a completed acoustic listening test.
- Poke requires all five squares to pass isSolid/isSolidTrans/BLOCKS_PLACEMENT and obstruction checks. Controller and turret placement also use broad square collision flags. The exact vegetation sprite/flag in image 3 is not established from the picture. Ordinary nonblocking grass should be allowed; identify the object causing rejection and exempt only harmless ground vegetation. Preserve toilets, mailboxes, poles, trees, furniture and real wall collisions.

## Multiplayer pause and the owner's sliding report

The earlier statement that the pause mod "stops game time" was too strong. Installed Multiplayer Fast Forwarding requests setMultiplier(0) on server/client and setGameSpeed(0) on the client. Native GameTime.isGamePaused in multiplayer reads the server empty-player pause condition or GameClient.IsClientPaused; setting the multiplier does not set those flags.

The captured server records x0 at st20,045,805,589 and x1 at20,045,814,289. Within that interval it starts Tether sequence 12, applies dart damage and applies pull damage. Another x0 interval20,045,816,090-20,045,883,891 contains new Tether attacks and Poke damage/death. This is more than a residual sound. The log does not record the effective multiplier/world clock each frame, so it does not establish why the requested zero rate failed to freeze all simulated work.

Actual ActiveTime checks native pause, not the selected multiplayer-pause state. Presentation clocks otherwise use wall time; TurretWorld.empty also uses wall time. ControlAudio accepts and plays reel sounds without a pause gate and never mutes the active loop for pause. A controlled zero-rate/frozen-world replay confirms presentation time advances, empty requests click twice over a real second, and reel audio starts/remains audible.

DefenseDisplacement movement uses ControlClock elapsed time and returns without movement if that clock is frozen; BarbMovement only scales native pending movement. Those facts do not clear T&T: actual logs show continued attack phases and movement may still advance if the effective clock advances. General zombie AI/network interpolation and T&T-driven movement must be compared under the same confirmed pause state. No evidence establishes internet latency as the cause, and no claim is made that every sliding zombie is caused by either mod.

Recommended scope: one effective pause contract for T&T simulation, new damage/motion requests, visual progression and audio, including safe resume without accumulated bursts. Verify native pause and the installed MPFF mode separately; isolate ordinary zombie movement with and without T&T. A repair to the pause mod itself, if needed, is a separate sibling/third-party change and requires its own scope approval.

## Battery lifetime from current Testing settings

**All values below are game hours from a 100% battery during continuous operation**, using current production TurretStats.resolve and TurretBatteryEstimate.duration. Include normal mechanical reload/rack cadence; assume ammunition replenishment and a surviving/repaired head. These are power endurance estimates, not ammo capacity, head durability or observed wall-clock benchmarks. No generator/Controller supply, refunds, extra modules, Regulator or idle time. Rotary uses its actual per-game-hour motor drain, not a fabricated per-shot firing count.

Normal automation means one ordinary Firing and Detection module: combined surcharge 1, total drain 2x. Enhanced means one of each enhanced module: combined surcharge 4, total drain 5x, plus its firing/motor speed effect. Current loot rarity settings affect these costs. Firearms rows use installed Firearms 42.16 definitions where present, native definitions otherwise; they are representative supported firearms, not every third-party weapon.

| Head | No modules | Normal automation | Enhanced automation |
|---|---:|---:|---:|
| AssaultRifle | 143.16 | 71.58 | 22.96 |
| M4 | 143.16 | 71.58 | 22.96 |
| Pistol | 465.00 | 232.50 | 74.34 |
| Pistol2 | 570.14 | 285.06 | 94.79 |
| Pistol3 | 945.38 | 472.68 | 149.41 |
| Revolver | 1160.94 | 580.46 | 196.06 |
| Revolver_Short | 1350.98 | 675.48 | 228.15 |
| Revolver_Long | 1080.78 | 540.36 | 182.52 |
| AssaultRifle2 | 503.52 | 251.75 | 77.31 |
| HuntingRifle | 659.45 | 329.72 | 107.33 |
| VarmintRifle | 617.34 | 308.67 | 96.70 |
| Shotgun | 899.47 | 449.73 | 152.95 |
| DoubleBarrelShotgun | 1371.10 | 685.53 | 259.76 |
| Potato | 1975.30 | 987.64 | 395.05 |
| Ballista | 106.64 | 53.31 | 17.04 |
| Scrapshot | 373.32 | 186.65 | 58.65 |
| Arc | 22.22 | 11.11 | 3.33 |
| RotaryBat | 6.00 | 3.00 | 0.90 |
| RotaryBlades | 3.00 | 1.50 | 0.45 |
| Lobber Makeshift | 81.45 | 40.70 | 12.19 |
| Lobber Aerosol | 54.29 | 27.13 | 8.12 |
| Lobber Pipe | 40.70 | 20.34 | 6.09 |

At the configured 90-minute day, one game hour corresponds nominally to 3.75 real minutes. Bare Bat 6h=22m30s; bare Blades 3h=11m15s. Normal automation gives Bat 3h=11m15s and Blades 1.5h=5m38s. Enhanced gives Bat .9h=3m23s and Blades .45h=1m41s. Additional drain/speed modules shorten these again. This large gap against other heads follows the current formulas and warrants a separate target-endurance decision; no battery balance change is approved here.

## Verification and proposed next patch

[Diagnostic production replay](../tools/tests/feedback_c532.lua): 27 assertions reproduce the released defects; full harness 44,179 passes with those reproductions. This count differs from C531 because it replaces the optional C531 audit, not because shipped code changed. Synthetic network contention, actors and clocks; zero connected clients. Native evidence is installed Lua/bytecode and actual captured client/server logs. No corrected-build or live-success claim.

**1A recommended:** correct child presentation timing, build initialization/edge geometry, harmless-vegetation validation, local warning audio and T&T multiplayer-pause behavior; investigate general paused-zombie movement with a controlled comparison. Test loaded 5/6/16-child volleys through last-ammo and target death, actual client startup, outer/internal/center walls in each orientation, both pause modes and resume. Keep battery tuning separate for an explicit lifespan choice.

**1B:** prioritize Splitter/build/placement/audio repairs; defer pause compatibility. This leaves the confirmed paused-combat problem unresolved and is not recommended.

**Decision needed.** Prior GitHub automatic approval-review destination-authorization rejection remains; do not route around it. Preserve owner edits to AGENTS.md, README.md, docs/AMMO_UI_C446.md and docs/RELEASE.md.
