# 0.2.20 staged cleanup and combined-checkpoint plan

Status: approved destruction/item cleanup is implemented in source. Not installed or tagged for release. Current installed build remains 0.2.19.1. The owner waived a separate gameplay test and requested combining this with the next checkpoint.

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

Results: 2,416 Kahlua assertions, 45 Lua files, 375 native translation keys and 118 package files pass. Native write/read pass in 43.5/43.9 seconds on stock 42.21.0. The native destruction fixture recovers 104 exact items plus two scrap, no base and no repeated-callback duplicates. Canonical component registration has twelve visible definitions and zero legacy definitions; fresh-process packed/world contents retain identity, charge, condition and cycle state. Evidence is in diagnostics/v0.2.20/. No owner test requested for this cleanup. Combine deployment with the supported-firearm prototype after its concrete scope is approved.
