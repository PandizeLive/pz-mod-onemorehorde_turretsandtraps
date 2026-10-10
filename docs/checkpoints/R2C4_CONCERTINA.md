# R2C4: Concertina contact movement and combined cleanup

Planning and read-only investigation, 2026-10-10, C114-C116. Installed build remains 0.2.37. No native movement probe or rendered test has passed for this new feature.

## Approved direction and remaining choices

- Concertina deals contact damage and slows only during contact, without stacking or lingering effects. Owner wants the same contact behavior for Barbed Panels; current panels do not slow.
- Reduce current movement by a divisor without resetting zombie type or restoring stale original speed. Prefer native transient modifiers if they satisfy the contract. Preserve Horde Night/current speed changes and unrelated modifiers. The prior prohibition on slowing turret heads is unchanged.
- Proposed divisor: 2, or half current speed. Owner has delegated implementation technique, not selected this numerical balance.
- Reuse the panel-style timed damage contract (currently 10 damage every two seconds), not per-frame damage. Discuss concertina footprint, player behavior, durability, recipe/tools/skills/XP before content implementation. Do not assume panel backing/shared-health rules apply to freestanding wire.
- Existing complete-turret shortcut removal and approved Improvised/Makeshift names are bundled with the selected update; preserve identical head outputs and internal IDs.

## Native investigation, not feasibility proof

Installed ProjectZomboid/projectzomboid.jar was inspected with JDK 17 javap -c -p. IsoGameCharacter exposes get/setSlowFactor and get/setSlowTimer. The setters only assign shared character fields; their existence does not establish automatic zombie expiry or compatibility with other writers. IsoPlayer has explicit slowTimer decrement/slowFactor decay. No equivalent direct slowFactor/slowTimer references appeared in the inspected IsoZombie bytecode. IsoGameCharacter.calculateWalkSpeed treats a positive slow factor as a fixed multiplier in that path, not an arbitrary requested divisor.

IsoZombie.getZombieWalkTowardSpeed uses speedMod and has a separate sprinter branch; this is not proof that changing speedMod uniformly scales every zombie movement state. IsoMovingObject.getGlobalMovementMod(boolean) visits vegetation for effects but its inspected return path supplies a stairs modifier or 1; merely marking a trap as a bush is not verified as the required zombie slowdown. Do not present any of these as a working solution. Local inspection files are under .local/*-slow.javap.txt and are reproducible from the installed jar; no new binary artifact is required in the repository.

Before implementation commitment, prove contact scaling and exit behavior across ordinary walking, sprinting, lunging, crawling and vault transitions; exclude knockdown displacement unless explicitly intended. A per-update movement factor is preferable to saving/restoring base speed. If the exposed engine paths cannot meet the contract, report the limitation before substituting a sticky timer or permanent speed mutation. No Java dependency or new storage scheme is approved merely by this investigation.

BarbRuntime currently skips contact geometry while its damage cooldown is active. A future continuous contact modifier must not inherit that two-second early return or multiply the existing damage-processing work each frame. Reuse bounded nearby-object indexing; no whole-world scan. Overlaps must not stack slow repeatedly. Removal, depletion, exit, unload and reset must not strand a speed penalty. Preserve original panel contact edges and door-leaf behavior.

## Confirmed Sandbox organization findings

Source/42.20/media/lua/client/OMHTT/SandboxUI.lua explicitly orders three page families and appends unmapped settings afterward. CapacityImprovisedModuleBonus, CapacityImprovisedAmmoBonus and ImprovisedFiringFailure are missing from moduleGroups. They consequently appear beneath the last Expansion Kits heading, including the unrelated firing-failure option. Put starter capacity beside the existing expansion tiers and firing reliability under an appropriate Firing heading. Review other pages semantically rather than alphabetically applying one universal layout.

Source/42.20/media/lua/shared/Translate/EN/Sandbox.json contains actual mojibake in Sandbox_Title_OMHTurretsTraps_Operation (U+00E2 U+20AC U+201D instead of an em dash), confirmed by UTF-8 JSON decoding. Queue heading cleanup and use simple readable text.

Proposed ordering principle: enable/behavior first, then damage/cadence, durability, movement/player contact, and applicable resource/audio settings; keep related basic/reinforced values adjacent. Retain Traps/Turrets/etc. page ownership, preserve saved IDs/values, show no empty headings, and check Traps-only/Turrets-only/both views. New-world and server-edit forms use the same adapter and must retain keyboard/controller order after rearrangement.

## Delivery and recap

Future recaps list only names of new changes in bullets; important decisions/limitations may accompany them in prose. This discussion queues Concertina Wire, contact slowdown for both wire/panels, Sandbox header organization, approved recipe naming and redundant complete-turret recipe removal. Pending footprint/recipe/balance and native feasibility prevent a fully specified content patch. Existing 0.2.37 acceptance and measured performance work remain separate, not new passes or a promised stall fix.
