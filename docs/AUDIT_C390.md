# C390 — 0.2.61 owner test and presentation audit

2026-10-21. Owner reports a completed play session with remaining audio, tether/trigger rendering, Connections, tooltip and balance issues. This is an audit and requested local sound audition, **not approval for the next gameplay patch**. Installed 0.2.61 and its immutable test tag are unchanged. Live two-client PvP acceptance is still unproven.

## C393 — complete recap approved (2026-10-21)

Owner says "Approved" to the recap after C392. Implement the recorded audio, standby, tether, trigger, Controller UI/range, player-damage, tooltip, Sandbox and rarity-art scope. Keep implementation verification distinct from rendered or connected-client acceptance. No further approval is needed for this patch.

## C393 implementation

The approved work is implemented in [0.2.62](PATCH_v0.2.62.md). [Verification and owner checklist](TEST_v0.2.62.md) separate automated/native evidence from rendered and connected-client acceptance. Existing Horde Night gates and independent package boundaries remain. The tether uses cached native models with bounded segments, not vehicle/rope physics. No final artwork was generated.

## Evidence

### C392 — standby scope and indicator selected (2026-10-21)

Owner answers **1B / 2A** to C391: standby applies only to Detection-controlled turrets; manual/trigger-only operation bypasses standby. Preserve Detection requirements when triggers gate a detector-equipped turret; linking a trigger must not silently remove its Detection behavior. Selected feedback is a small non-illuminating indicator plus lowered pose and menu status: amber asleep, green active, unlit disabled, with explicit Waking status during the transition. Keep seven active real-time idle seconds, one-second wake, immediate abort when the target becomes invalid, and alert only after successful wake. Preserve existing action completion, pause handling and power rules; no automatic battery-saving balance change. Useful Sandbox enable/timing/audio/visual controls remain in the proposed patch scope.

These choices settle the two C391 design questions. C390/C391 audio, tether, UI, tooltip, art, radius and damage selections remain recorded; no additional generic design question is required before the patch recap/approval. This reply selects the design, not an explicit build/install command. No gameplay, package or installed-version changes, and no new test result. Installed 0.2.61 remains current; final next-build approval is pending under the project discussion-before-patch agreement.

### C391 — owner selections and turret standby proposal (2026-10-21)

Owner selects C390 **1A**, native world nail plus bounded native cable adapter while retaining authoritative simulation; **3B**, 40-tile Controller radius with Sandbox; and replaces the proposed injury choices with **2x friendly damage / 4x hostile PvP damage and wound chance**, relative to installed 0.2.61. Friendly wound chance is unchanged. For the current M4 profile this means 8 limb damage / 6% friendly scratch chance and 16 limb damage / 24% hostile scratch chance, before armour and existing wound-roll limits. Preserve server PvP/safety protections, classify actual victims using current owner/faction relationships, and expose separate useful Sandbox multipliers. This is selected next-patch scope, not an installed change or connected PvP acceptance.

Selected native sounds: S1D MetalworkingPunchSwing (tether launch), S2B SpearCraftedHit (impact/pull), S4D CloseMetalToolbox (mechanical reset), S5B KnobSwitch (Button/Lever/Plate), S6C ChairLegNailsHit (Poke Floor), S8B AxeSawBladeSwing (rotary movement). New owner files under `OMH/Audio/Turrets & Traps`: Reeling.wav (5.531s), laser_detected_1.wav and laser_stopdetect_1.wav (1.125s each), turret_alert.wav and turret_deactive.wav (1.319s each). RIFF metadata inspected: all PCM16, stereo, 48kHz. No listening or in-game mix acceptance claimed. Keep originals unchanged; stop reel playback when return ends, bind laser cues to state transitions, and avoid repeated movement/scan sound spam. Successful wake completion starts the alert; its duration must not add another firing delay.

Owner requests lowered standby pose after 7 seconds, a 1-second wake before firing, alert only after successful wake, and immediate return to sleep when the target becomes untargetable during wake. Proposed interpretation: seven active real-time seconds with no eligible target or pending action, using existing pause-aware TurretClock; finish already-started actions before standby. Standby remains online and preserves existing power/trigger/detection gates. Abort a failed wake without an alert or queued late shot; actual power loss/OFF is disabled, distinct from standby. Do not repeatedly play deactivation on every scan. No unrequested standby battery savings. Server owns readiness/deadlines; clients interpolate pose and receive transition cues. Do not serialize raw session timestamps; restore transient readiness safely on load. Bounded scan cadence and no new per-frame world search.

Read-only evidence: TurretAutomation has separate detector and rotary paths; TurretAim queues targeted manual shots; TurretRenderer uses native Render3DItem with separate support/head positions. Lowering is feasible to attempt without replacing combat, but all head geometry, rotary clearance, occlusion and connected-client transitions still need native/rendered tests. A lowered pose does not require a new animated model; a visible indicator does require a small developer presentation asset/native rendering verification, not final AI art.

Remaining concrete choices (not yet selected): **1A recommended: standby applies to all turret heads; Detection wakes on an eligible target, manual/trigger-only operation wakes on its existing valid fire request (no new Detection requirement), rotary stops in standby; preserve the existing trigger pulse through wake/aim/reload**. **1B: Detection-controlled turrets only; manual/trigger-only turrets bypass standby.** In either case a targeted wake aborts if that target becomes invalid. Targetless manual/directional requests retain their existing legality; no invented target requirement.

**2A recommended: small non-illuminating status indicator plus lowered pose and explicit menu status: amber asleep, green active, unlit disabled; waking has its own text/progress.** Do not rely on colour alone or emit costly dynamic lighting per turret. **2B: lowered pose and menu status only.** Useful proposed Sandbox controls: standby enabled, idle delay 7s, wake duration 1s, sound volume and cosmetic indicator toggle; retain the owner's broader per-head/trap customization request. Multiple-Lever all-ON gate remains the C390 recommended interpretation unless corrected. No gameplay/package/install changes in C391; remaining standby/indicator choices precede final patch scope approval.

- Owner supplied five attachments: Lever placement, missing laser beam, scrolling/collapse Connections behavior, and clipped Poke status. The supplied GIF previews and source were inspected; no new in-game visual pass was performed.
- Captured local `console.txt`: 1,019,448 bytes, SHA-256 `ee508bde194da375e79a534db1ef8e78d85c626e578a10fe9007e32513d2e86e`. Stored locally under `diagnostics/audit-c390/console.txt`. The running game can append after this snapshot.
- Snapshot contains 0.2.61 SP diagnostics. Tether hits show 30 damage and subsequent 15 pull damage, with the expected roughly 0.75-second hold. A victim with less than 15 remaining health loses only that remainder. M4 suppressed firing and reload sound events are present. No OMHTT Lua stack trace was identified in this snapshot. Engine font/map warnings, Firearms translation formatting warnings and a skeleton/bone error remain; this is not an error-free log or a claim about their causes.
- Read installed 42.21 vanilla `ISUIElement.getMouseY`, `setScrollChildren`, ISPanel and native sound scripts. Current game bytecode confirms `WorldItemModelDrawer.renderMain`, `InventoryItem.setTexture/setIcon`, `Item.setIcon`, `BodyDamage.calculateOverallHealth` and `BodyPartType` damage factors. Historical 42.20 decompile was a locator; current jar was checked for the relevant signatures/constants.
- No gameplay files, packages, save data, installed mods or sibling project files changed during this audit.

## Findings and proposed corrective scope

| Area | Finding | Proposed correction / acceptance boundary |
|---|---|---|
| Tether depth | `TetherView.render` draws nail and 24 cable segments through `OnPreUIDraw`. Visibility checks hide unseen tiles but cannot depth-sort against visible zombies. | Keep authoritative collision, damage, ownership, persistence and phase messages. Replace only the solid-projectile visual adapter with native world rendering; verify live occlusion before calling it solved. |
| Tether fall and speed | `TetherCycle` has out/hold/back/reset phases, no gravity/fall phase; view uses fixed `z + .3`. `TetherServer` uses 12 tiles/s outward, 4 return, 6-tile range, .75s hold, .4s reset. Confirmed-position interpolation also adds up to .1s of lag. | Propose 30 tiles/s launch, unchanged .75s hold/slow reel, and .7s reset so the full-range hit cycle stays about 3.15s. A miss or released nail should visually drop before ground-level retraction; held hits stay attached until pull. Timing/ground transition must be specified and synchronized, not disguised with a slower screen tween. |
| Broader projectile depth | `PrototypeEffects` also draws projectile/tracer overlays. Tracers can be stylized overlays; solid Ballista spears have the same conceptual depth limitation. Turret heads already use `RenderOpaqueObjectsInWorld` / `Render3DItem`. | Reuse a small world-effect adapter for solid projectiles. Do not silently convert all effects or infer that moving a UI line to a different event adds a depth buffer. |
| Lever placement | Developer wall markers and the mount use separately calculated face positions. Existing marker generator uses E/N/W/S wall-edge tables; screenshot establishes a visual mismatch, not which offset is wrong. | Unify support-edge/origin/facing calculations for preview, placed marker, light and beam; validate all four faces on native and player-built walls. Do not move gameplay hitboxes based on one image. |
| Laser | `ControlTriggerView` currently draws a faint **white** beam, gated on power, visibility and registration. It has no red/green state treatment. `ControlSensor` clamps per-device range to 1–10. Exact reason for this owner's invisible beam is not established by the log. | Owner explicitly requests fixed 10 tiles, no device range menu. Recommend green while powered/clear, red while interrupted, none without power, with status text as well as color. Shared Sandbox range may override the default; keep wall/closed-door obstruction. Verify powered registration and beam origin on a rendered client. |
| Add Group scroll | `ControlGraph` disables scrolling children but still moves `addGroup` to `5 - getYScroll()`. | Put the title/button/sorting row in an unscrolled header; keep content in its own scrolling body. |
| Collapse cables | Renderer explicitly substitutes a group-header Y for collapsed endpoints and still draws those edges. | Hide a cable when either displayed endpoint is collapsed; do not delete the logical link. Map links may remain visible. |
| Drag/scroll | Native `getMouseY()` already subtracts scroll. Graph mixes it with viewport-space hit tests and subtracts scroll again for its drag ghost. Drag-edge scroll directions are reversed relative to the wheel handler. | One coordinate conversion at the boundary, consistent hit/hover/ghost calculations, proper autoscroll directions and capture cancellation. |
| Row height / clipping | One longest wrapped name sets a shared maximum row height for every device. Status labels are not clipped to their cards. | Two compact text lines with ellipsis and full hover text; health bar below, short ammo/status label; bounded per-card clipping. Add right-click **Assign to Group** including Ungrouped through existing server-authoritative DeviceMove/revision validation. |
| Controller defaults | The hidden native devices list includes the Controller and clicking its map marker can select it, but no persistent obvious return control exists. | Always-visible **Controller Settings** action that selects the host. Preserve device selection when merely opening Stockpile. |
| Lever priority | `ControlWorld.input` currently ORs every valid active input; an OFF Lever does **not** block a Laser. | Owner requests master-enable behavior. Proposed interpretation: all connected Levers must be ON, then other triggers are ORed; Lever alone supplies held activation. OFF allows only the already-started action to finish. No power bypass or automatic Detector bypass. Multiple-Lever rule is explicitly a proposed interpretation. |
| Manage guidance | Reintroduce compact instruction text, without filling slots with repeated labels. | `Drag items into slots · Right-click to remove` near Modules; keep tooltips and existing Remove To destination clear. |
| Controller reach | `ControlAccess.range` is fixed squared-distance 400. Restore/auto-assignment, UI discovery and map circle also contain 20/400/41/1681 constants. There is no Controller range option. | One shared setting for authority, discovery, auto-assignment, supply, links, restoration, label and map. Recommend 50-tile default (options below), same-floor and loaded-world limits, unchanged device-count caps. Avoid turning the UI scan into a large per-frame search. |

## Sound audit and audition

[Local audition HTML](../art/DEVICE_AUDIO.html) is self-contained and generated by [the reproducible builder](../tools/build_device_audio_audition.py). It has **32 choices in eight groups**, using **26 distinct installed native events**, plus a silent choice. Sound codes S1A-S8D keep audio selections distinct from the design choices below. It includes launch, impact/pull, retraction, reset, physical triggers, Poke activation, laser state, and rotary movement. Existing approved firearm/secondary sounds are not silently replaced.

Captured with installed FMOD 2.03.09 at one metre/default parameters, limited to three-second excerpts; peak gain is only reduced when necessary. Event parameters and in-game spatial audio can change the result. Long reel/motor events require phase-bound start/stop, not repeated overlapping one-shots. Asset audio remains local and is excluded from GitHub; the builder and evidence are mirrored. No extracted game audio is included in a mod package.

All 26 captures contain non-silent PCM, conversion succeeded, 31 embedded Ogg instances validate, 32 radio options and eight groups exist, and generated JavaScript passes `node --check`. An initial newline-escaping bug was caught and fixed before delivery. Browser UI verification was blocked by the browser's local-file protocol policy; no workaround or playback claim is made. The standalone file can be opened by the owner. Selection, volume, stop, notes, clipboard fallback and downloadable choices are included.

| Device / effect | Existing coverage | Gap / recommendation |
|---|---|---|
| Potato | Owned shot/pop and impact, gain controls | Retain; compare only if owner wants a replacement. |
| Firearm heads | Native weapon shot/click/reload/rack; approved suppressed variants | Retain weapon-specific choices; validate audible MP recipients and phase timing. |
| Ballista | SpearCraftedSwing / SpearCraftedHit | Existing cues are not silence. Optional stronger mechanical release/reset from audition. |
| Scrapshot | JS2000ShotgunShoot | Present. Avoid one loud event per pellet. |
| Lobber | Launch pop, native bomb explosion and bounded miniature blast cues | Present. Keep explosion timing tied to impact/fuse. |
| Rotary Bat / Blades | BaseballBatHit / AxeSawBladeHit, contact throttle, click | Motion is largely silent; optional phase-bound motion cue. Avoid a persistent base-wide loud motor by default. |
| Tether | No dedicated launch/hold/reel/reset sound calls | Main missing cycle; audition groups 1–4. Emit by committed phase transition. |
| Poke Floor | No dedicated activation/return sound calls | Main missing activation cue; group 6. |
| Bed Spikes | SpearCraftedHit contact | Present; tooltip needs repair. |
| Barbed panels / wire | ZombieClawChainlinkFence contact with throttle | Present; don't add continuous contact loops per zombie. |
| Spike Barrier | Native object/break/thump response; damage uses retaliation path | Keep native response; optional short damage-specific stab cue, not automatically added. |
| Button / Lever | LightSwitch in action perform | Present locally; audit remote recipients/failed-action feedback when changing the shared sound route. |
| Pressure Plate | Visual depression, no dedicated press/release cue | Add only on state transitions, group 5. |
| Laser | No dedicated cue | Silence is acceptable; optional state chirp, never a continuous alarm. |
| Lure / Martyrdom / Tack / Fragment / packs | Existing selected cues | Retain. Siphon/other stat modules do not each need a new spammy sound. |

## Player damage finding

`TurretPlayerHit` applies the same fixed reduced profile to owner/faction collateral and hostile players, after the server protection checks. There is no friendly-damage multiplier. An M4 uses **4 limb damage and 6% scratch chance**, not its upgraded zombie damage. Native `BodyDamage.calculateOverallHealth` weights limb loss: forearms .2, upper legs .3. Thus a previously healthy struck limb contributes about **0.8–1.2 overall-health loss before clothing**, excluding subsequent bleeding/healing and other health effects. Current game bytecode confirms these factors. This is calculated, not a measured PvP endurance result.

Recommend explicit friendly-collateral and hostile profiles, both retaining server safety/non-PvP protection, clothing reduction, limb-only wound selection, no Execute/crit/guaranteed lodged bullet and shared wound-roll limits. Relationship must be evaluated server-side from actual ownership/current faction; a missed shot at an outsider must not make a friendly bystander hostile.

Proposed starting comparison, **not approved**: retain friendly profile at 1x current damage/chance. Hostile A: 3x damage and 2x wound chance (M4 12 limb / roughly 2.4–3.6 overall before armour, 12% scratch), B: 2x damage / 2x chance, C: 4x damage / 2x chance. Apply proportional existing head/shot caps, preserve zero-chance bruises and existing throttle. These are readable first-pass baselines, not DPS measurements; rate/accuracy/reload upgrades still change damage over time. Separate Sandbox controls and concise tooltip terms should identify both profiles.

## Sandbox / Horde Night audit

The request for a separately titled section for **every** head/trap is **not currently met**. `SandboxUI.groups` has operation/storage/combat/audio/power/firearms within the common turret page; Ballista, Scrapshot, Lobber and rotary heads mostly use constants in `TurretHeads`. Their few battery options do not amount to full head sections. Barriers, Beds and Barbs share titled sections; Poke has its own page. Tether has no settings page. Triggers have consumption settings but no separately titled section for each device; Controller range is absent.

Recommend headings for General, Potato, Firearms, Ballista, Scrapshot, Lobber, Rotary Bat, Rotary Blades; and trap headings for each passive/active device, Controller and Triggers, with useful live options only. Firearms should use one compatibility section, not one tab for every vanilla/modded gun. Keep stable option IDs and package independence, with server-owned bounds used by damage, UI and tooltips.

`DefenseHorde` routes authorization and damage through `OneMoreHordeDefenseIntegration` API v1. Reviewed sibling `OMH_DefenseIntegration.authorize/beginDamage`: an active Horde requires defensesEnabled and difficultySelectionConfirmed; damage marks DEFENSE_USED and the server-owned /5 policy. Native attraction is separately gated by worldSoundAllowed. Tether, Poke, turret and passive damage paths retain the shared boundary. New visual/audio helpers must not create ungated zombie-attracting sounds, bypass run consent, or reconstruct difficulty flags client-side. Existing tests cover the contract, not a new live Horde session in this turn.

## Items, rarity and extension surface

Audit enumerated **62 OMHTT item definitions**. Module/head descriptions use dynamic shared helpers; traps mostly use older static prose. Trigger inventory tips currently append consumption only. Poke, Tether and Controller have no item-specific explanatory footer. Bed Spikes' static tooltip falsely says free ten-second repair and five-second pickup; service details must come from current shared service rules. Barbs/wire use long paragraphs. Packs have short prose. Internal support/probe visuals are not missing player-facing tooltips.

Propose the heads' compact format for all player-facing devices: one-line purpose, activation/placement, effective damage/range or capacity, power, repair material/tool and duration. Omit irrelevant fields; put detailed mechanics in Manage/Details. Native guns retain their normal item tooltip plus turret data when used as heads. Avoid accumulating separate ISToolTipInv wrappers; use one delegated formatter with bounded wrapping and large-font checks.

New owner art: two families, **Performance and Expansion Kits**, 17 PNGs, all 32x32. Both contain all seven rarity bands plus base images; Performance also has a red variant. `performance_Epic.png` and `expansion_legendarypng.png` require explicit case/filename mapping; do not infer a new rarity from red/base or rename owner files. No Automation/Effects/Utility art exists in this folder yet.

`TurretRarity.refresh` computes effective tier from current loot weights/anchors; descriptions, slot colors and module power surcharge already share it. It refreshes at world start and Manage opening, not a comprehensive live settings-change hook. Script icons are currently fixed, and no dynamic module texture assignment exists. Current engine provides InventoryItem.setTexture/setIcon and Item.setIcon. Recommend a `(category, rarity)` manifest and cached resolver; refresh settings revision on each client using authoritative server settings, update existing/new/stockpile items in bounded work, and use the same revision for tooltip and icon. No per-frame whole-world inventory scan, no changed loot identity or copied item. World 3D models are separate from inventory icons. Do not promise that changing a script icon alone updates every already-instantiated item.

Code is already separated into server cycles, pure geometry, view, injury and audio helpers, and firearm profiles accept native guns. However, heads/devices/modules still have several hard-coded dispatch tables and there is no supported external registration contract. Recommend a small versioned registration surface for definitions/presentation hooks, with stable IDs and validation, not a full framework rewrite. Server eligibility, permissions, damage and resources stay authoritative; third-party visual hooks must not own those decisions. Document extension examples before claiming external API support.

Performance: bounded swept collision and 10Hz active Tether snapshots are useful foundations. Keep native visual instances pooled, limit cable segments (start with 8–12, benchmark), distance/visibility cull and disable cosmetic detail separately. Increasing radius from 20 to 50 expands a naive area scan 6.25x; use loaded-device indexing/incremental discovery and retain existing server caps. Sensor movement creates short-lived checked/intersection tables; optimize only on measured busy-base evidence. Existing four-device log timings do not prove large-base scalability. Add text/shape status alongside red/green, keyboard/context alternatives to dragging, ellipsized rows with full accessible tooltips, and optional sound volume.

## Decisions to return

1. Tether rendering: **1A recommended** native nail plus bounded native cable-segment visual adapter, retaining simulation; **1B** cheaper sprite/approximate occlusion with known limitations; **1C** full physics/Java approach, not recommended. Native path requires rendered feasibility/occlusion proof. Recommended flight proposal is 30 out / 4 return / .75 hold / .7 reset; default damage stays 30+15.
2. Hostile profile: **2A recommended** 3x current damage / 2x wound chance; **2B** 2x / 2x; **2C** 4x / 2x. Friendly collateral retains current baseline; no safety bypass. M4 examples above.
3. Controller radius: **3A recommended 50 tiles**, **3B 40**, **3C 75**; all include a shared Sandbox option, same-floor/loaded-world bounds and unchanged caps. Recommend setting bounds 10–100.
4. Lever interpretation to confirm with the patch recap: connected Levers act as master gates, all must be ON; other triggers OR together, and a lone Lever supplies held activation. Requested fixed laser range and listed UI/tooltip corrections are recorded, not reopened as arbitrary choices.

**Decision needed.** Sound selection can be returned from the audition page. No Workshop publication, LootLab deployment or new gameplay install.


## Item coverage inventory

All 62 source item definitions were enumerated; all referenced static Tooltip keys exist. Static module feature text also contains default numeric values (for example Splitter/Piercing/Impact); these should follow effective Sandbox tuning when rewritten, rather than showing a configurable stack line next to stale default prose. Inventory coverage is not a fresh visual test of every item.

| Item | Static key | Current description route / finding |
|---|---|---|
| OMHTTTrapBarbedPanel | Tooltip_OMHTT_Barbs | Static long paragraph; compact fields needed |
| OMHTTTrapConcertinaWire | Tooltip_OMHTT_ConcertinaWire | Static long paragraph; compact fields needed |
| OMHTTTrapBedSpikes | Tooltip_OMHTT_BedSpikes | Static paragraph; stale service wording |
| OMHTTTrapBedSpikesReinforced | Tooltip_OMHTT_BedSpikes | Static paragraph; stale service wording |
| OMHTTTrapController | None | Item behavior description missing |
| OMHTTTrapPressurePlate | None | Consumption footer only; behavior summary missing |
| OMHTTTrapButton | None | Consumption footer only; behavior summary missing |
| OMHTTTrapLever | None | Consumption footer only; behavior summary missing |
| OMHTTTrapLaser | None | Consumption footer only; behavior summary missing |
| OMHTTTurretGunSupportVisual | None | Internal visual; no player description required |
| OMHTTTurretProbe | None | Internal visual; no player description required |
| OMHTTTrapSpikeBarrier | Tooltip_OMHTT_PortableBarrier | Static description; unify applicable service fields |
| OMHTTTrapSpikeBarrierPack | Tooltip_OMHTT_BarrierPack | Static description; unify applicable service fields |
| OMHTTTrapSpikeBarrierReinforced | Tooltip_OMHTT_ReinforcedBarrier | Static description; unify applicable service fields |
| OMHTTTrapSpikeBarrierReinforcedPack | Tooltip_OMHTT_ReinforcedPack | Static description; unify applicable service fields |
| OMHTTTrapPokeFloor | None | Item behavior description missing |
| OMHTTTrapTetherDart | None | Item behavior description missing |
| OMHTTTurretBallista | Tooltip_OMHTT_BallistaHead | Dynamic head/base description |
| OMHTTTurretRotaryBat | Tooltip_OMHTT_RotaryBatHead | Dynamic head/base description |
| OMHTTTurretRotaryBlades | Tooltip_OMHTT_RotaryBladesHead | Dynamic head/base description |
| OMHTTTurretLobber | Tooltip_OMHTT_LobberHead | Dynamic head/base description |
| OMHTTTurretScrapshot | Tooltip_OMHTT_ScrapshotHead | Dynamic head/base description |
| OMHTTAmmoMakeshiftBomb | Tooltip_OMHTT_MakeshiftBomb | Static description; unify applicable service fields |
| OMHTTModuleLure | Tooltip_OMHTT_ModuleLure | Dynamic module footer; shared defaults/stack/rarity audit |
| OMHTTModuleVoid | Tooltip_OMHTT_ModuleVoid | Dynamic module footer; shared defaults/stack/rarity audit |
| OMHTTModuleGrid | Tooltip_OMHTT_ModuleGrid | Dynamic module footer; shared defaults/stack/rarity audit |
| OMHTTModulePack | Tooltip_OMHTT_ModulePack | Static pack description |
| OMHTTModuleSiphon | Tooltip_OMHTT_ModuleSiphon | Dynamic module footer; shared defaults/stack/rarity audit |
| OMHTTModuleRegulator | Tooltip_OMHTT_ModuleRegulator | Dynamic module footer; shared defaults/stack/rarity audit |
| OMHTTModuleConservation | Tooltip_OMHTT_ModuleConservation | Dynamic module footer; shared defaults/stack/rarity audit |
| OMHTTModulePiercing | Tooltip_OMHTT_ModulePiercing | Dynamic module footer; shared defaults/stack/rarity audit |
| OMHTTModuleInitialBlow | Tooltip_OMHTT_ModuleInitialBlow | Dynamic module footer; shared defaults/stack/rarity audit |
| OMHTTModuleExecute | Tooltip_OMHTT_ModuleExecute | Dynamic module footer; shared defaults/stack/rarity audit |
| OMHTTModuleImpact | Tooltip_OMHTT_ModuleImpact | Dynamic module footer; shared defaults/stack/rarity audit |
| OMHTTModuleFiringEnhanced | Tooltip_OMHTT_ModuleFiringEnhanced | Dynamic module footer; shared defaults/stack/rarity audit |
| OMHTTModuleDetectionEnhanced | Tooltip_OMHTT_ModuleDetectionEnhanced | Dynamic module footer; shared defaults/stack/rarity audit |
| OMHTTModuleMagazine | Tooltip_OMHTT_ModuleMagazine | Dynamic module footer; shared defaults/stack/rarity audit |
| OMHTTModuleSplitter | Tooltip_OMHTT_ModuleSplitter | Dynamic module footer; shared defaults/stack/rarity audit |
| OMHTTModuleFragment | Tooltip_OMHTT_ModuleFragment | Dynamic module footer; shared defaults/stack/rarity audit |
| OMHTTTurretBase | Tooltip_OMHTT_TurretBase | Dynamic head/base description |
| OMHTTTurretPotato | Tooltip_OMHTT_PotatoHead | Dynamic head/base description |
| OMHTTModuleFiring | Tooltip_OMHTT_ModuleFiring | Dynamic module footer; shared defaults/stack/rarity audit |
| OMHTTModuleFilter | Tooltip_OMHTT_ModuleFilter | Dynamic module footer; shared defaults/stack/rarity audit |
| OMHTTModuleRapidFire | Tooltip_OMHTT_ModuleRapidFire | Dynamic module footer; shared defaults/stack/rarity audit |
| OMHTTModuleVelocity | Tooltip_OMHTT_ModuleVelocity | Dynamic module footer; shared defaults/stack/rarity audit |
| OMHTTModuleRange | Tooltip_OMHTT_ModuleRange | Dynamic module footer; shared defaults/stack/rarity audit |
| OMHTTModuleSuppression | Tooltip_OMHTT_ModuleSuppression | Dynamic module footer; shared defaults/stack/rarity audit |
| OMHTTModuleCritical | Tooltip_OMHTT_ModuleCritical | Dynamic module footer; shared defaults/stack/rarity audit |
| OMHTTModuleAccuracy | Tooltip_OMHTT_ModuleAccuracy | Dynamic module footer; shared defaults/stack/rarity audit |
| OMHTTModuleReload | Tooltip_OMHTT_ModuleReload | Dynamic module footer; shared defaults/stack/rarity audit |
| OMHTTModuleAutoloader | Tooltip_OMHTT_ModuleAutoloader | Dynamic module footer; shared defaults/stack/rarity audit |
| OMHTTModuleExpansionSmall | Tooltip_OMHTT_ModuleCapacity | Dynamic module footer; shared defaults/stack/rarity audit |
| OMHTTModuleExpansionMedium | Tooltip_OMHTT_ModuleCapacity | Dynamic module footer; shared defaults/stack/rarity audit |
| OMHTTModuleExpansionLarge | Tooltip_OMHTT_ModuleCapacity | Dynamic module footer; shared defaults/stack/rarity audit |
| OMHTTModuleDetection | Tooltip_OMHTT_ModuleMotionDetection | Dynamic module footer; shared defaults/stack/rarity audit |
| OMHTTModule360 | Tooltip_OMHTT_ModuleDetection360 | Dynamic module footer; shared defaults/stack/rarity audit |
| OMHTTModuleDetectionImprovised | Tooltip_OMHTT_MotionDetectionImprovised | Dynamic module footer; shared defaults/stack/rarity audit |
| OMHTTModuleFiringImprovised | Tooltip_OMHTT_FiringImprovised | Dynamic module footer; shared defaults/stack/rarity audit |
| OMHTTModuleExpansionImprovised | Tooltip_OMHTT_CapacityImprovised | Dynamic module footer; shared defaults/stack/rarity audit |
| OMHTTModuleSynergy | Tooltip_OMHTT_ModuleSynergy | Dynamic module footer; shared defaults/stack/rarity audit |
| OMHTTModuleMartyrdom | Tooltip_OMHTT_ModuleMartyrdom | Dynamic module footer; shared defaults/stack/rarity audit |
| OMHTTModuleTack | Tooltip_OMHTT_ModuleTack | Dynamic module footer; shared defaults/stack/rarity audit |

## C393 follow-up: audio balance (2026-10-21)

Owner explicitly requests balanced audio before installation. Production playback gains now distinguish high-priority wake/impact cues from quieter laser transitions, reel, shutdown and pull. Owner WAV bytes remain unchanged. Measurement uses 50 ms windows with an ungained -50 dBFS active gate; native captures are at one metre/default FMOD parameters. This is a reproducible relative-level check, not a claim of perceived in-game loudness or clipping-free simultaneous playback.

- Owner clip gains: reel 0.38, laser detect 0.38, laser clear 0.60, turret wake 0.65, turret sleep 0.50.
- Native cue gains: launch 0.80, impact 0.70, pull 0.35, reset/switch 1.00, Poke/rotary 0.65.
- Laser active-window RMS differs by 0.48 dB after adjustment; wake is about 3 dB above laser and 8 dB above reel/shutdown. Single-cue peaks retain at least 3 dB headroom at the default device-volume multiplier. Native switch/reset stay at their already quiet native level; no blanket amplification.
- Global Sandbox volume multiplies the mix, including mute; source normalization and zombie hearing/attraction are unchanged.
- `tools/measure_device_audio.py` reads actual shipped gains and writes local diagnostics plus `art/DEVICE_AUDIO_BALANCED.html`. Native preview captures are not distributed. An in-game listen with multiple devices and normal combat remains required.
