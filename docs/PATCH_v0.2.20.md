# 0.2.20 — supported firearm heads and destruction cleanup

Status: C68/C69 implemented and validated as one candidate. Installation evidence is maintained in RELEASE.md. The owner waived a separate cleanup test; use the combined firearm test in PHASE_5_CHECKPOINT_1A.md.

## Approved cleanup — C68

- Remove the five legacy component script definitions and their item-name translations and runtime identity aliases. Keep twelve canonical loot components. No save migration: this mod has never been uploaded and the owner explicitly accepts dropping private-test compatibility.
- Preserve internal behavior/Sandbox keys; these are not extra item definitions. Detection and 360 remain the visible names; Expansion Kits remain Small/Medium/Large.
- Destroyed bases spill actual contents without an extra condition/charge penalty and yield two Base.ScrapMetal. Do not refund a functional base. Native removal owns physical collision retirement; ordinary pickup clears the turret marker before removal and produces no scrap.
- Clear native construction refund metadata on creation/restoration. Native ISBuildingObject.onDestroy otherwise rolls a 50-percent return for each recorded material, potentially including the portable base.
- Scale loose cube item sprites to 25 percent using native ScaleWorldIcon. Inventory icons, mounted head scale, meshes and final artwork remain unchanged. Rendered appearance has not been accepted.
- Log fallbackItemsDropped separately from scrap count; native dumpContentsInSquare may already have emptied the container before the removal callback.

## Evidence and limits

Current installed 42.21.0 Lua ISBuildingObject.onDestroy and ISBuildUtil.setInfo establish native drop/material behavior; current projectzomboid.jar IsoThumpable.destroy calls dumpContentsInSquare before OnDestroyIsoThumpable and removal. The installed native item script uses ScaleWorldIcon. Historical decompilation is a discovery aid only.

Kahlua checks cover pickup without salvage, exact-item fallback, battery charge, empty/native-dumped storage, repeated callbacks and cleared material refunds. Native probes verify canonical registration and absence of retired definitions, real contents dump/removal reconciliation, exact item identities and battery state, then fresh-process world/packed-item persistence. A dedicated-server fixture does not execute the same physical SP removal path; native dump and the mod removal callback are invoked explicitly. Existing owner evidence establishes native thumping/destruction; this is not a new rendered pass or MP certification.

The first fixture attempted native destroy on an unregistered synthetic server square; it did not deliver the expected SP removal notification. The fixture was corrected to test native dumping plus the explicit removal callback. No runtime workaround for native destruction was introduced.

Combined results: 2,780 Kahlua assertions, 47 Lua files, 402 native translation keys and 120 package files pass. Native write/read pass in 97.2/95.4 seconds on stock 42.21.0. The native destruction fixture recovers 104 exact items plus two scrap, no base and no repeated-callback duplicates. Canonical component registration has twelve visible definitions and zero legacy definitions; fresh-process packed/world contents retain identity, charge, condition and cycle state. Evidence is in diagnostics/v0.2.20/. No separate owner test is requested for the cleanup. C69 combines deployment with the approved supported-firearm prototype. Native gun probes additionally conserve ammunition through load/rack/fire for all three guns and preserve exact gun IDs, condition, chamber/magazine state, cooldown and the pistol laser attachment in a fresh process.

## Supported firearm heads — C69

Base.Pistol, Base.Shotgun and Base.HuntingRifle now fit the existing head slot, using their actual weapon inventory state and matching loose ammunition. Shared power/turning/coverage/modules operate through bounded feeding and firearm-specific loading/cycling, with native models and firing sound events. The pistol needs its native magazine inserted before mounting. Guns use immediate hits with a short visual tracer; the potato's delayed projectile and splash remain separate. Approximate turret accuracy/damage/cadence and a bounded shotgun spread are configurable under the Turrets page's Firearms group. No recipes changed; unsupported firearms and multiplayer remain gated.

See [P5C1a](PHASE_5_CHECKPOINT_1A.md) for native references, mechanisms, prototype limits and the complete seven-step combined owner test. GPU orientation/muzzle position, sound and frame smoothness await that test.
