# C499 - live combat, ammo-loading and empty warning (2026-10-28)

Status: investigated; corrective gameplay patch awaits owner approval. Installed and published version remains 0.2.70.3. No code, package, save, server setting or Workshop change in this checkpoint.

## C500 - approved with world-light refinement (2026-10-28)

Owner selects **1A** and specifies that the amber warning must snap on, fade out, and illuminate the world. This authorizes the combined corrective patch and replaces C499's hard on/off proposal. Implemented as a one-second cycle: immediate full amber, a half-second fade, then half a second dark; native local world lighting follows the same envelope. [Final patch](PATCH_v0.2.70.4.md) and [verification](TEST_v0.2.70.4.md) supersede the pending implementation status above. No Workshop publication is authorized by this approval.

## Owner report

Turrets struggle to finish a low-health zombie; adding ammunition repeatedly redirects the head and prevents shooting; an empty turret looks operational. Owner requests the existing makeshift firing dry-click once per second and asks about a distinguishable warning light. No light pattern has been selected.

## Current evidence

- New client console and DebugLog session 16:25 and server session 16:22 both identify 0.2.70.3. The old extraUpdate exception is absent from this capture. The other player's client was not collected.
- Read-only SFTP capture contains 50 OMHTT_CombatV1.Applied command entries and zero Reject entries. These entries establish receipt arrival, not fifty verified deaths or successful final settlements. Aggregated shot-damage-confirmed diagnostics omit per-victim before/after/lethal outcomes, so they cannot settle the screenshot's specific zombie.
- One server AddInventoryItemToContainer packet send fails with NullPointerException: the parent object's square is null. The stack is TurretModulePack.onDeath line124, called inside DefenseCombatServer.commitResult line68 and native IsoZombie.onKilled. The loot handler adds a module pack to the dying zombie's inventory, then treats it like an already located world container. This is a confirmed synchronization defect. Native packet code catches/logs the exception, and native OnZombieDead dispatch is protected; do not claim this error necessarily aborted death or caused the pictured survivor.
- Lethal owner-side damage intentionally leaves health at 0.001 until the server accepts the receipt. The server then sets zero and calls Kill(nil,false). Installed 42.21 bytecode confirms Kill invokes onKilled and its loot/death event; death/body creation and transmission are separate paths. The connected transition, potential later owner health overwrite and final corpse delivery need focused proof. Do not replace this with stronger damage or a speculative extra native call.
- Ammo retargeting is confirmed by the production call chain: TurretTransferAction.complete calls TurretWorld.refresh for every completed transfer. refresh emits OnOMHTTTurretChanged; TurretAutomation.changed unconditionally clears target, scan job, firing due and rotary state. An ammo-only stock update therefore runs the same reset as changing equipment. Replace this incorrect invalidation classification; preserve authoritative inventory publication and head/module reconfiguration resets.
- TurretWorld.fire returns Empty without emitting a click. TurretRenderer chooses Dark/Amber/Green from power and standby only, so an empty awake turret remains green. Existing makeshift failures use OMHTTTriggerClick, or the native gun click sound for firearm heads.

Evidence snapshot: workspace diagnostics/2026-10-28-tt-combat-followup (client console/DebugLog, server console/DebugLog/cmd and fresh installed-game IsoZombie/IsoGameCharacter bytecode). Rotated server paths were rediscovered before fetching. No credentials were recorded. Local branch started at c1fd158; fetched origin/dev has no commits missing from HEAD.

## Recommended patch scope and choice

**1A recommended:** repair ammo-only invalidation and premature module-loot container synchronization; prove and correct the connected lethal-completion failure; add the requested empty click plus blinking amber indication. **1B:** combat/loading/loot corrections first, defer empty feedback.

Proposed warning behavior: one click per real second while powered, allowed and attempting to fire with no usable ammunition. No click during normal reload, without a firing attempt, while disabled, or on ammo-free heads. Reuse the existing click audio path and player volume controls; share the limiter across automatic/manual/trigger firing attempts. Blink existing amber/dark markers at a simple one-second period while enabled and empty; steady amber remains asleep/waking, green active, dark disabled. A local rendering clock should animate the marker, not one network message per blink. Respect existing state-marker settings. Avoid SOS complexity or repeated misfire/damage/resource expenditure for an empty attempt. Details remain proposed until approval.

Verification must distinguish an ammo transfer from head/module changes, cover stationary low-health targets through authoritative death and observer corpse visibility, retain exactly-once loot/XP attribution, and distinguish reload/empty/virtual-ammo states. Existing mock Kill coverage and zero-player native smoke tests do not prove connected death transport. Prefer High reasoning for the authority investigation; Medium is sufficient for isolated UI/audio work. No new owner testing requested until a patch is delivered.

Project AGENTS.md's 2026-10-01 rule requires discussing test findings and patch scope before gameplay changes. This checkpoint records findings and a reviewable proposal, not acceptance or implementation.
