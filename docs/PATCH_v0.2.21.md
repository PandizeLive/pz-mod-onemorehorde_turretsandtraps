# 0.2.21 — mounted firearm and management repair

C70: owner requests fixing the incomplete 0.2.20 test before continuing, and reviewing Alex's skills, OMH agreements and Horde Night architecture. No recipes, balance defaults, broad firearm compatibility, multiplayer, sibling modifications or publication are added.

## Player changes

- Correct native gun roll while retaining aim; temporarily apply all three native item rotations and restore the original dropped-item pose. Three white boxes form a technical support below the gun, using the existing white texture. This is not final artwork or a craftable component.
- Add Magazine between Ammo and Expansion. Drop one compatible carried magazine to insert; right-click to eject. Native timed service interrupts on movement. The gun cannot feed/fire or leave the base during active service. Magazine state follows native insertion/ejection; chambered rounds remain in the gun.
- Keep missing head, power, ammunition and required detachable magazine red until resolved; show missing automation components in red when automation is enabled. Grid/generator power or disabled power requirements do not demand a battery. Internal-magazine/potato heads need no detachable magazine, including with Autoloader.
- Allow removing/swapping heads with reserve ammunition in the base. Retain reserve and actual gun-loaded rounds; incompatible reserve remains unloadable and counts toward storage but never feeds a new head. Cancel old pending aim/search when the head leaves.
- Fix the raw no-magazine result text and the firearm tracer's incorrect native drawLine arguments. Tracer muzzle height follows the mounted gun. The 0.2.20 console contained 242 Texture/Double errors; effects tests now execute the installed vanilla drawLine wrapper.

The magazine icon is a cached UI representation, not an extra inventory item. It cannot be dragged out as a duplicate; eject with right-click. Native insertion does not retain the original magazine item ID/metadata after it becomes gun state.

## Evidence and architecture

Current stock game: 42.21.0. Reviewed native ISInsertMagazine, ISEjectMagazine, ISBaseTimedAction, ISUIElement.drawLine, generated weapon/model scripts, InventoryItem XYZ rotation exposure and ItemModelRenderer bytecode. Shared Firearms owns magazine validation/accounting; the client timed action owns reach/animation/queue lifecycle in supported SP.

Kahlua/native projection checks: 2,814 assertions, 48 Lua files, 411 translation keys, 123 packaged files. Actual native insert/eject conserves magazine/chamber rounds, blocks repeats, wrong/favorite magazines, capacity bypass and stale heads. Native write/read completed in 68.2/70.0 seconds with exact gun IDs, attachments, condition, loaded rounds and battery charge retained. White support imports as one mesh, 72 vertices/36 triangles. GPU pose/depth, actual interaction timing and smoothness still need rendered acceptance.

[Architecture](ARCHITECTURE.md) now describes current source instead of the obsolete P1C1 plan. T&T follows shared rules and presentation/persistence boundaries, but remains SP-only with independently budgeted queues. P2C3e must address authoritative transactions, aggregate work budgeting, density measurements and clock behavior. Horde Night/XP/Cure simulation integration remains future explicit contracts.

## Complete repair test

1. Restart into SP and confirm **0.2.21**, diagnostics and 3D ground items on. Place a base with a charged battery; mount an M9/Base.Pistol without its magazine. Manage should show a red Magazine slot and readable status.
2. Drop a Base.9mmClip into Magazine. Try moving during insertion once: the magazine must stay carried. Retry without moving; the warning should clear. Add 9mm reserve, fire at a zombie in the cone, and check upright gun, white clamp, barrel tracer and no error counter increase.
3. Turn automation off. Right-click Magazine to eject; loaded magazine rounds return and a chambered round stays on the gun. Reinsert. Remove power, then restore it: the red power warning should clear. Enable automation without Detection/Firing, then install both and check the missing-module warning clears.
4. With reserve still in the base, drag the gun out. It should retain its loaded rounds/condition/attachments. Mount the potato head, then each supported shotgun/rifle: old ammo stays available to unload but cannot fire through the wrong head. Internal magazines should not demand a detachable magazine. Check each firearm's upright pose and cadence.
5. Leave a loaded firearm, modules and battery installed; note counts/charge, pick up/redeploy, then save/reload. Confirm contents remain. Check a potato turret still shows its brown delayed projectile/splat. Report test complete for log review.

These steps cover the repair and carry the unfinished 0.2.20 mechanism/persistence checks forward; earlier unperformed checks are not marked passed. Rollback: annotated test/v0.2.20 and the installer's complete previous-folder backup. No Workshop content upload exists; cumulative notes remain pending.
