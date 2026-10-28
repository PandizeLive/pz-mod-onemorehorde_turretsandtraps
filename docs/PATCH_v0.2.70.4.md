# 0.2.70.4 - C500 combat completion and empty feedback

## Authorization

2026-10-28: owner selects C499 **1A**, with the annotation requiring the warning to snap on, fade out and illuminate the world. This includes lethal-completion correction, ammo-loading continuity and corpse-loot synchronization. No sibling changes or Workshop upload.

## Final behavior

- Dedicated-server lethal damage now completes native death after recording the kill. The client retains its nonzero health reservation until the server accepts the existing damage receipt; the server then calls the native death/corpse path. This fixes the missing completion rather than increasing damage or adding another acknowledgement protocol. Kill/loot/XP attribution remains server-owned. SP keeps its ordinary animation-driven completion. Unloaded synthetic actors without a square are not forced into a corpse constructor.
- Native 42.21 evidence distinguishes Kill (zero health and OnZombieDead) from die (corpse creation, live-actor removal and the zombie's onDied listener calling GameServer.sendCharacterDeath). A production native test verifies death completes, loot transfers into the body and repeated completion creates no duplicate corpse. These isolated checks have no connected clients and do not prove rendered death/observer acceptance.
- Module packs are added in the existing server death hook. The native corpse packet carries that inventory. The invalid early sendAddItemToContainer call is removed; no retry queue or duplicate loot representation is added.
- Ammo-only transfers invalidate the existing inventory snapshot and wake the feeder. They no longer emit an equipment-change event or rebuild firearm configuration. Head/module changes retain their normal reset. Existing server inventory/revision publication and access checks remain.
- An authorized powered firing attempt with an Empty feeder emits OMHTTTriggerClick at most once per real second, shared across manual, automatic and trigger attempts. Normal reload, racking, no power and ammo-free heads do not generate an empty click. Existing player master audio volume applies. Empty attempts do not consume ammunition or battery power.
- Enabled empty turrets use the existing amber marker over the dark housing: full brightness at the start of each second, half-second fade, half-second pause. A native amber light at the turret tile follows the same envelope and lights a small three-tile neighborhood. Lights are created only for visible nearby warnings (20-tile viewer distance), reused while active and removed promptly when the warning ends, the turret unloads, the camera leaves, or state markers are disabled. Light intensity updates are limited to 20 Hz; marker alpha remains smooth. No per-flash network traffic or new art is required.
- Existing state-marker settings apply to both the marker and warning light. Steady amber remains asleep/waking; green active; dark disabled. The Sandbox tooltip now states the world-light behavior. Runtime power-source publication also keeps unpowered warnings dark in SP and MP.
- Existing bounded diagnostics distinguish combat-lethal from ordinary combat-settled. Detailed mode includes victim, damage, dead state and corpse completion, while normal logging aggregates the event counts. No additional network diagnostics are sent.

## Release boundary

Workshop item3828638252 successfully received0.2.70.3 at2026-10-28T20:09:27.9380072Z, recorded in RELEASE.md and evidence/c498-upload-and-copies.json. The0.2.70.4 changelog is a new cumulative draft containing only changes since that confirmed upload. Local install/staging does not update the Workshop server. No new world is required.

See [verification and owner checklist](TEST_v0.2.70.4.md).
