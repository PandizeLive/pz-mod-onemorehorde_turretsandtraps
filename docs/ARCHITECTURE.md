# Architecture and feasibility

Reviewed against the current T&T source, Alex's PZ modding/Lua skills, the workspace/project agreements, and [Horde Night architecture](../../pz-mod-onemorehorde_protectthecure/docs/ARCHITECTURE.md); updated for **0.2.25**. Exact installation is recorded in RELEASE.md; rendered acceptance remains separate from automated/native checks.

## Relationship to Horde Night

We follow the same responsibility boundaries, but do **not** yet have equivalent production architecture.

| Principle | T&T today | Remaining gate |
| --- | --- | --- |
| Shared gameplay policy | `Turret`, `TurretStats`, `TurretModules`, `Firearms`, `Barrier` define common rules; potato and conventional native-data guns share the universal base | Do not duplicate these rules in future MP handlers |
| Authority separated from presentation | `TurretWorld`, combat and barrier runtimes own world outcomes; Manage/renderer/effects display them | Gameplay is explicitly SP-only. Several client timed actions perform local validated changes; future server transactions must own them |
| Stable identity and persistence | Namespaced object markers, exact item inventory, scalar saved metadata; separate transient registries | Dedicated reconnect, zombie ownership, observers and transaction replay need proof |
| Bounded/staggered work | Incremental manual search, automation, feeder, impact queues and diagnostic draining | These have separate budgets, not one shared frame ceiling. Aggregate density and render/aim traversal remain unproven |
| Explicit clocks | Magazine servicing uses native Action Time; existing gun/turret deadlines use timestamp milliseconds | Audit pause/sleep/fast-forward behavior before MP. Do not claim world-time parity or silently change balance clocks |
| Series ownership | No duplicate Horde quota, schedule, score, faction progression or Cure simulation engine | Integration adapters are planned, not registered/implemented |

Horde Night's sibling-specific remote, Workshop, paired-package and review workflow does not become a T&T requirement merely through this comparison. T&T uses its own AGENTS.md and root OMH.cmd, with the workspace cumulative-changelog policy.

## Current runtime boundaries

| Concern | Current modules and responsibility |
| --- | --- |
| Definitions and settings | Item/construction scripts, Sandbox declarations, shared `Turret`, `TurretStats`, `TurretModules`, `Firearms`, `Barrier` |
| Placement and recovery | Native construction/Install selection, build callbacks, `TurretWorld`, barrier service/approach actions; commit checks retain exact identity and supplies |
| Resource and weapon state | Actual `ItemContainer` items; `Firearms` owns native chamber/magazine transitions and magazine transactions, `TurretWorld` owns power/world activation |
| Target search and aim | `TurretSearch`, `TurretAutomation`, `TurretAim`; placement orientation fixes coverage, independent head angle follows targets |
| Combat | `PrototypeCombat` handles potato flight/impact; `FirearmCombat` handles supported gun approximations; barrier runtime validates actual thump side/contact |
| Feeding | `TurretWorld.feedTick` advances powered gun/potato cycles; `TurretReloadAudio` follows actual deadlines with bounded cues; no hidden character or separate ammo inventory |
| Interaction | `TurretManage`, `TurretSlot`, `TurretTransfers`, `TurretMagazineAction`, selection/menu/Install modules |
| Presentation | `TurretRenderer`, `TurretRange`, `PrototypeEffects`, damage feedback and collision overlays; visual particles/tracers never deal damage |
| Diagnostics | `Diagnostics` queues detailed events with bounded draining; capture/version/hash evidence via OMH.cmd |
| Foundation prototype | `Foundation*` retains its own bounded request/reply/ledger test shell. Its MP probes do not certify the later SP gameplay |

The `server` Lua directory also executes in SP; its name alone is not proof of MP support. Current guard clauses disable unsupported multiplayer gameplay. Extending authority/transport must reuse decisions and exact transactions, not fork a second combat engine.

### Magazine service and head swapping

The management slot represents the **native installed magazine state on the gun**. Vanilla insertion consumes a real magazine into `containsClip` and `currentAmmoCount`; native ejection creates the matching magazine with those rounds. The chamber is independent and retained. We mirror that behavior in `Firearms`, not a second magazine item hidden in base storage. Original inserted-magazine identity/metadata is not retained by this native model.

The UI's cached magazine icon is presentation-only: it cannot be dragged into inventory. Drop a real compatible carried magazine to insert; right-click the slot to eject. `TurretMagazineAction` handles native duration/animation/interruption and revalidates reach; the shared transaction revalidates current gun, actual source item, magazine type, favorite protection, competing service, and total capacity immediately before mutation. A transient service lock blocks firing/loading/head removal during the action. Repeat completion cannot mint another magazine.

Reserve ammo can stay in the base when removing/swapping heads. Wrong-type reserve remains recoverable and counts against capacity, but never feeds the new head. Gun-loaded rounds travel with the actual gun. Successful head removal cancels pending aim/manual-search work. Expansion removal checks total stored reserve plus gun-loaded rounds.

## Persistence and lifecycle

Engine serialization saves the actual world `IsoThumpable`/container and items. Namespaced `OMHTTTurret` metadata carries device identity, orientation and control state; the actual head item carries cycle metadata. Pickup transfers the actual contents into the portable base, retaining condition, ammunition, attachments and charge. Do not serialize live Java references into ModData or identify a device by sprite alone.

Aim/search/automation/render/service registries hold only session-live handles and retire/revalidate them. Delayed impacts revalidate the target at resolution. Loading/unloading must not recreate missing defenses or replay missed shots. A destroyed base yields two scrap and its exact contents once, without an intact-base refund.

The older P1C1 test ledger uses `OMHTT_Foundation_v1`, per-tile epochs and namespaced exact-object markers. It is not a faction ownership or reward ledger, and must not grow into a second Horde engine.

World defenses outlive a Horde. Do not register them for run-owned cleanup without verifying the core's actual retirement contract; Horde end or faction disband must not silently delete a base.

## Engine reuse and current limitations

Current installed-game evidence is **42.21.0**. Historical 42.20.2 decompilation is a discovery aid only. Verify current vanilla Lua/scripts or JAR signatures/bytecode before relying on an engine API. Alex's rules also require explicit dependencies, stable cached references where appropriate, correct Java/Lua iteration, guarded supported modes, and avoiding exception-driven API guessing.

Spike Barriers now use a see-through native edge outline with front edges and exposed outer caps; rear access is open. Native low-fence controls and reactions are integrated, with directional scratch risk. This supersedes the old architecture text claiming vaulting was blocked. Automatic bed-spike traversal is still planned content, not implemented by the barrier path.

Gun heads are actual HandWeapon items. Native-data admission recognizes conventional reload mechanisms, single-round ammunition consumption and damaging ranged weapons; twenty real vanilla guns pass the native probe. Exact profiles are cached per item type, with one startup ammunition registry scan and no per-shot script scan. Stationary turrets do not invoke the complete character firing/accuracy/animation pipeline. Shared adapters conserve ammo and approximate combat/mechanism timing; arbitrary custom weapon Lua is not executed. Unsupported custom mechanisms and toys are rejected. Base Repair shares the ten-second adjacent service action, restores only base health and preserves the exact gun, supplies and charge.

Rendering uses a static depth-mapped base tile and the installed head via `RenderOpaqueObjectsInWorld`. Guns use the native negative forced-rotation path to apply item XYZ pose, then restore original item rotations. A hidden three-box white support is transient presentation only. Native import/matrix checks are not a rendered lighting/occlusion acceptance test. Current `ISUIElement:drawLine` requires texture and thickness arguments; the gun tracer uses that signature.

## Scheduling and performance

Automation and manual targeting each have bounded candidate/time slices; the feeder processes at most four turrets within one millisecond per tick at 100ms service intervals. Impact and telemetry queues are bounded. These protections help distribute work but their independent allowances add together. Aim/render loops still traverse registered devices, and inventory summaries can repeat between consumers. There is no verified global many-turret frame budget yet.

P2C3e must establish one aggregate work policy with fair incremental cursors, caps for scans/rays/impacts and diagnostics, plus dense mixed-turret measurements. Measure native crossings and full-frame behavior, not just the Lua fire-call duration. Pause/fast-forward tests must prove no free ammunition, unintended catch-up burst or portable-clock refill. Existing clocks are not rewritten by this magazine/UI patch.

## Multiplayer and sibling integration gates

Before MP support, validate every mutation on the authoritative side: player identity, exact target, distance, permission, enabled state, actual inventory and expected revision. Use finite native timed actions or narrow commands; no client-supplied damage/reward totals. Prove death/corpse/loot agreement under actual zombie simulation ownership and two observers. Synchronize compact state/effect facts with replay protection, not entire registries on each shot.

Horde Night retains event ownership, quotas, participants, cleanup, score and simulated populations. Trait Shop retains progression and reward receipts; Cure Defense retains objective-private state through its declared core contract. The proposed defense score penalty and reduced all-member XP pool are not existing API capabilities. Offline reward eligibility is not offline combat. Cure simulation remains last and requires an explicit reviewed core extension; no virtual kill claims or quota writes from T&T.

References: [Integration plan](INTEGRATIONS.md), [Horde Extension API](../../pz-mod-onemorehorde_protectthecure/docs/EXTENSION_API.md), [Trait Shop policy](../../Trait%20Shop/docs/OMH_INTEGRATION.md), [Roadmap](ROADMAP.md). Concertina/slowdown restoration, wiring/beam occupancy, faction receipt delivery and unloaded Cure defense remain future feasibility/authority gates.

### 0.2.22 audio and mounted drawing

TurretStats computes Suppression hearing multipliers from active inventory modules. FirearmCombat/TurretWorld emit the gameplay hearing event; TurretSounds selects one preprocessed native or potato replacement. PrototypeEffects performs spatial playback. TurretReloadAudio keeps transient sound handles and follows the existing feeder budget (four devices / one millisecond per tick, 100ms polling per device); it performs no extra inventory traversal. Audio has no damage authority or persisted emitter IDs. Preprocessing tools are development-only.

Mounted firearm drawing temporarily disables the native static item atlas by preserving/restoring both option value and default, required by the engine's debug-only option semantics. Native item pose is restored too; a reusable recovery record handles an interrupted draw on the next callback. No permanent graphics setting change, Java injection or external loader. Native option/Lua exposure is verified; rendered correctness and dense-turret frame cost still require client evidence.

## 0.2.26 narrow combat/performance adaptation

FirearmAccuracy owns only native distance formula adaptation; Java probe verifies parity with installed CombatManager. TurretStats remains shared stat authority. Engagement cap lives in turret mod-data and TurretModules.profile governs search, shot eligibility and range preview. Automation schedules retained-target shots separately from bounded scans. TurretWorld caches inventory summaries for at most 200 ms, invalidates on transfer/configuration, and coalesces configuration refreshes. Diagnostics aggregates counts/max stage durations unless detailed output is enabled. None of this closes the aggregate scheduler, clock or multiplayer authority gate documented above.

## 0.2.27 approved refinements

FirearmClass classifies conventional guns from native metadata and original script range, with an explicit full-type override table for exceptional metadata. It never reads localized names. FirearmAccuracy retains native formula helpers for parity evidence and uses the native point-blank bonus to anchor a monotonic turret-specific distance curve ending at the configured 60/80 percent. This supersedes applying the severe native quadratic sight-band falloff to mounted guns.

TurretModules profiles cache the resolved stats alongside engagement range; TurretStats.hearingRadius is shared by both emitted sound and the selected amber ring. ClientOptions registers a native PZAPI Mod Options checkbox. No server Sandbox preference is added for noise visibility.

TurretScheduler rotates bounded aiming, manual search, automatic targeting/firing, feeder/configuration and impact/diagnostic workers through a shared 3ms wall-clock ceiling. A running native call is non-preemptible, so one work unit can overrun it. Render/UI and existing barrier/foundation maintenance are outside this combat budget; dense client frame measurements remain necessary. Aiming uses an eight-entry cursor.

TurretClock advances real active seconds, capped at 100ms per tick, without scaling by fast-forward. Pause stops advancement; a long stall cannot produce a backlog of shots. Exact head cycles store the last active timestamp and session identity; process restart rebases remaining reload/rack/cooldown time, preserving ammunition. No unloaded combat or offline progress is simulated. Older cycles without clock metadata retain their existing deadline on their first update.

Projectile obstruction uses installed IsoGridSquare.testVisionAdjacent, rejecting blocked/closed-door/window results and accepting clear/open-door edges. Loaded-path and conservative diagonal corner guards remain; low-fence movement collision no longer blocks bullets. Current native bytecode is recorded in diagnostics/v0.2.27/native-square.txt.

## 0.2.28 discovery and diagnostics

LootDefinitions remains the common source for native injection and LootLab export; four additional themed pools improve coverage without a runtime container scan. FirearmAudit uses the shared scheduler, a fifty-script traversal cap, one transient inspection item per visit and 100ms output pacing. Diagnostics.emit can report budget refusal without dropping a retained audit entry. Firearms.rejection supplies admission explanations; firearm stats/classification are resolved through the existing shared modules. Once-per-session debug work remains SP-only like current combat. World/saved inventory is untouched. No native multi-tile removal hook was added for the unassigned Louisville hang.
