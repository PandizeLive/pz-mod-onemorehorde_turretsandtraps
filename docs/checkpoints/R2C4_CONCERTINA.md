# R2C4: Concertina contact movement and combined cleanup

Implemented and installed as C120 / 0.2.38 on 2026-10-10. [Patch details](../PATCH_v0.2.38.md), [test evidence](../TEST_v0.2.38.md) and [release/install state](../RELEASE.md) are authoritative. Native displacement scaling is feasible; final validation and tagged installation pass. Rendered and Horde Night integration acceptance remain pending. The investigation/proposals below preserve their historical context; C119 approved their settled values.

## Approved direction and technical gates

- Concertina deals contact damage and slows only during contact, without stacking or lingering effects. Owner wants the same contact behavior for Barbed Panels; current panels do not slow.
- Reduce current movement by a divisor without resetting zombie type or restoring stale original speed. Prefer native transient modifiers if they satisfy the contract. Preserve Horde Night/current speed changes and unrelated modifiers. The prior prohibition on slowing turret heads is unchanged.
- C117 approves zombie contact divisor 2 (half current speed) for both concertina and Barbed Panels, including Horde Night zombies. Implementation technique remains delegated; native feasibility is not yet established.
- Reuse the panel-style timed damage contract (currently 10 damage every two seconds), not per-frame damage. C118 selects Bed Spikes-style player injuries for wire and panels; C119 approves the concertina footprint, durability and recipe/tools/skills/XP listed below. Do not assume panel backing/shared-health rules apply to freestanding wire.
- Existing complete-turret shortcut removal and approved Improvised/Makeshift names are bundled with the selected update; preserve identical head outputs and internal IDs.

## Native investigation, not feasibility proof

Installed ProjectZomboid/projectzomboid.jar was inspected with JDK 17 javap -c -p. IsoGameCharacter exposes get/setSlowFactor and get/setSlowTimer. The setters only assign shared character fields; their existence does not establish automatic zombie expiry or compatibility with other writers. IsoPlayer has explicit slowTimer decrement/slowFactor decay. No equivalent direct slowFactor/slowTimer references appeared in the inspected IsoZombie bytecode. IsoGameCharacter.calculateWalkSpeed treats a positive slow factor as a fixed multiplier in that path, not an arbitrary requested divisor.

IsoZombie.getZombieWalkTowardSpeed uses speedMod and has a separate sprinter branch; this is not proof that changing speedMod uniformly scales every zombie movement state. IsoMovingObject.getGlobalMovementMod(boolean) visits vegetation for effects but its inspected return path supplies a stairs modifier or 1; merely marking a trap as a bush is not verified as the required zombie slowdown. Do not present any of these as a working solution. Local inspection files are under .local/*-slow.javap.txt and are reproducible from the installed jar; no new binary artifact is required in the repository.

Before implementation commitment, prove contact scaling and exit behavior across ordinary walking, sprinting, lunging, crawling and vault transitions; exclude knockdown displacement unless explicitly intended. A per-update movement factor is preferable to saving/restoring base speed. If the exposed engine paths cannot meet the contract, report the limitation before substituting a sticky timer or permanent speed mutation. No Java dependency or new storage scheme is approved merely by this investigation.

BarbRuntime currently skips contact geometry while its damage cooldown is active. A future continuous contact modifier must not inherit that two-second early return or multiply the existing damage-processing work each frame. Reuse bounded nearby-object indexing; no whole-world scan. Overlaps must not stack slow repeatedly. Removal, depletion, exit, unload and reset must not strand a speed penalty. Preserve original panel contact edges and door-leaf behavior.

## Confirmed Sandbox organization findings

Source/42.20/media/lua/client/OMHTT/SandboxUI.lua explicitly orders three page families and appends unmapped settings afterward. CapacityImprovisedModuleBonus, CapacityImprovisedAmmoBonus and ImprovisedFiringFailure are missing from moduleGroups. They consequently appear beneath the last Expansion Kits heading, including the unrelated firing-failure option. Put starter capacity beside the existing expansion tiers and firing reliability under an appropriate Firing heading. Review other pages semantically rather than alphabetically applying one universal layout.

Source/42.20/media/lua/shared/Translate/EN/Sandbox.json contains actual mojibake in Sandbox_Title_OMHTurretsTraps_Operation (U+00E2 U+20AC U+201D instead of an em dash), confirmed by UTF-8 JSON decoding. Queue heading cleanup and use simple readable text.

Approved ordering principle: enable/behavior first, then damage/cadence, durability, movement/player contact, and applicable resource/audio settings; keep related basic/reinforced values adjacent. Retain Traps/Turrets/etc. page ownership, preserve saved IDs/values, show no empty headings, and check Traps-only/Turrets-only/both views. New-world and server-edit forms use the same adapter and must retain keyboard/controller order after rearrangement.

## Delivery and recap

Future recaps list only names of new changes in bullets; important decisions/limitations may accompany them in prose. This discussion queues Concertina Wire, contact slowdown for both wire/panels, Sandbox header organization, approved recipe naming and redundant complete-turret recipe removal. C119 approves all current bundle choices below; native movement feasibility remains a prerequisite to shipping the requested behavior. Existing 0.2.37 acceptance and measured performance work remain separate, not new passes or a promised stall fix.


## Concertina defaults proposed in C117 and approved in C119

C119 "All approved" accepts these defaults with C118 injury behavior replacing the rejected no-player-injury option. No additional design approval is needed for this table.

| Choice | Approved default |
| --- | --- |
| Footprint | One-tile freestanding coil on clear floor |
| Durability | 50 independent HP; one wear per damaging activation |
| Zombie damage | Match panel-style 10 every two seconds |
| Craft | One Barbed Wire + two Wire; retain pliers; ten seconds; no skill requirement or XP |
| Service | Five-second placement/pickup; ten-second free repair; no service XP |
| Player contact | C118 replaces no-injury proposal: Bed Spikes-style walking safety, running scratches, sprint trips and fresh-landing cuts for concertina and panels |

Footprint and durability refer to the whole coil, not each zombie. This proposal does not permit repeated division each tick, stacked wire slows, safe assumptions about native expiry, or a new global loot/speed change.


## C118: player contact and independent Bed Spikes

Owner requests the existing Bed Spikes player treatment for concertina and panels. BedPlayer currently defaults to 20% running/sprinting scratch per entry, an additional 20% sprint trip roll, one cut on a fresh landing, and safe ordinary walking. Noclip/ghost bypass custom effects; god mode prevents injury/trip. Preserve native vault/climb movement and the panel's exposed contact edge instead of treating its entire backing tile as wire. Walking safety means no injury roll; it does not remove the planned contact slowdown. Shared contact handling must prevent repeated rolls while moving between adjoining hazard pieces. Keep the planned half-speed reduction separate from injury triggers and do not accidentally turn sprint injury off simply because movement is slowed.

Owner requests two independent placed spike traps; context is taken to mean Bed Spikes, not Spike Barriers. Source inspection confirms current shared health, whole-record destruction, a two-part service requirement and pickup into a two-tile item. Independent records alone would leave broken servicing or a duplication route; update the inventory unit and placement/service contract together.

C118 proposals approved by C119:

- Each tile has 50 basic / 100 reinforced HP; six wear applies only to the tile that receives the fall. Keep 20/50 fall damage and one hit per fall. Pair nominal health stays 100/200; six-wear rounding means 18/34 total damaging falls if distributed evenly, versus 17/34 previously.
- One craft at the current cost yields two one-tile inventory units. Pair placement consumes two; single-tile pickup returns one; allow one recovered unit to redeploy one tile. No half-item or duplicated full-pair refund.
- Per-unit weight 1.5 basic / 2 reinforced preserves the current pair weight 3/4. Per-unit reinforcement uses one plank + four nails, retained hammer, Carpentry 3, 15 XP; pair cost/XP remains unchanged. No new packing recipes are proposed.
- Repair, pickup, reinforcement and breakage operate on the selected tile only. Placement retains the requested two-tile initial layout. Save/index/remove paths must handle one survivor without retiring its neighbor. No old-save migration is promised under the fresh-world policy.
- Player entry rolls must not double because the two tiles now have separate IDs. Preserve current zombie tile-based eligibility, five-second recovery and one damage event per fall; no injury loop for existing prone actors.

C119 settles these inventory/balance choices. Implementation and native/runtime validation remain pending; do not reopen the same approval gate.

## C120 implementation

The native event order places deferred movement before OnZombieUpdate/OnPlayerUpdate and collision resolution afterward. BarbMovement scales getNextX/Y relative to current X/Y only during contact. It leaves persistent speed/type untouched and bypasses native climbing, bump falls, knockdowns, ragdolls and non-crawling prone movement. One combined wire/panel pass avoids stacking. Current input motion is halved rather than cached as a "normal speed" snapshot. Real native player/zombie API probes pass; rendered motion, vault transitions and interaction with third-party movement hooks still require the focused owner check.

All settled content/inventory/naming/header changes are implemented in the 0.2.38 build. Distinct native sprite IDs are necessary for pair/single entity routes; they share the same bed pixels. Concertina uses one white WIRE technical marker across its orientation IDs and inventory icon. Wire weight is 2; repair/pickup need no tools. No old-save conversion, final art, new packing recipes or Spike Barrier changes were added.

## C121 owner observation (2026-10-10)

The owner provisionally reports function working with Bed Spikes, Concertina and a turret, but lag persists. [0.2.38 console findings](../TEST_v0.2.38.md#owner-findings-and-console-review-2026-10-10) confirm large update gaps and runtime audio-pitch elapsed times. No specific contact/durability rule change is proposed; unmentioned rendered checks remain unconfirmed. R1C3 audio/trap timing follow-up is proposed and awaits approval; R2C4 implementation remains 0.2.38.
