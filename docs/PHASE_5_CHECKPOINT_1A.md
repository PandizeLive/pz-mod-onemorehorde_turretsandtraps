# P5C1a — early supported-firearm mount prototype

Current follow-up: [0.2.21 repair](PATCH_v0.2.21.md) supersedes the pre-insert-only magazine and reserve-unload instructions below. Its combined test replaces the original test sequence.

Status: C69 approved; implemented in 0.2.20 together with C68 cleanup. C64 moved this prototype ahead of P2C3e multiplayer. Local installation evidence lives in RELEASE.md; rendered acceptance remains pending. This does not enable all Phase 5 content or waive multiplayer gates.

## Player outcome

Install a supported vanilla gun in the universal base's existing head slot. Add matching ammunition and existing modules in Manage. Swap back to the potato head after unloading incompatible ammunition. No additional mount crafting step or new recipes in this prototype.

Supported IDs: Base.Pistol (M9), Base.Shotgun (JS-2000) and Base.HuntingRifle (MSR788). Keep unsupported guns out of the slot with concise feedback; broad modded-weapon discovery follows only after adapters prove reliable.

## Work

1. Inspect current native weapon scripts, attack/ballistics, chamber/magazine state, reload/cycle animations and available duration/rate data. Record which native systems a stationary object can reuse and where an explicit adapter is required. Do not invent a hidden survivor to invoke character-dependent combat.
2. Add weapon profiles behind the existing head interface. Preserve the actual gun, attachments, condition, loaded chamber/magazine and reserve items through swapping, pickup, destruction and save/load. Define exact reload-ammo transactions before implementing them; no duplicate magazine or chamber rounds.
3. Reuse turning, placement cone, Detection/Firing/Filter/360, power and bounded target scheduling. Rapid-Fire changes fire cadence, Reload changes loading time, Autoloader removes reload wait, and all continue consuming ammunition. Pump/bolt handling is a separate native-mechanism question to settle from evidence. Apply applicable Range/Velocity/Expansion effects through shared effective stats, with concise Manage readouts.
4. Render the supported gun as the swappable head using its native model and appropriate muzzle anchor. Native gun effects/sounds should be used where exposed; potato-specific splash/knockdown/audio must remain on the potato profile.
5. Add useful grouped firearm Sandbox controls only with working effects: enablement, accuracy, damage/range and reload/fire cadence tuning. Recommend Aiming-3-equivalent baseline only if current native calculations support a stable, explainable implementation; it is not an approved promise of identical player accuracy.
6. Verify exact ammo accounting, obstruction checks, failed/cancelled shots, no burst catch-up, mixed potato/firearm turrets, bounded per-tick work and persistence. Keep one combined short owner test after the playable candidate exists.

## Gates

A native capability gap becomes a documented choice of adapter or narrower supported mechanism, not a blanket compatibility claim. Separate native proof, automated checks and rendered acceptance. Multiplayer, all-gun compatibility, module recipes, explosive heads, Horde/XP integration and final artwork stay outside this checkpoint. Concertina and the rest of the defense roster remain on the roadmap.

Recommended effort: High. Use Fast for implementation if the expected elapsed work exceeds 25 minutes.

## Implemented adapter and installed-game evidence

Current game: stock 42.21.0, build 4a0e9546ec. Native generated weapon scripts, ISReloadWeaponAction.onShoot, ISInsertMagazine/ISEjectMagazine, ISReloadWeaponAction and ISRackFirearm server-emulated durations, plus current JAR signatures/model binding were inspected. Historical decompilation was used only for discovery. Native ItemModelRenderer handles weapon models and attachments; Render3DItem accepts the actual installed item. Native tracer and weapon attack entry points require a character, so this prototype uses shared obstruction/target validation and immediate damage with a short presentation tracer. No simulated survivor is created.

| Head | Ammo | Capacity | Loading | Pump/bolt/chamber |
| --- | --- | --- | --- | --- |
| Base.Pistol | Base.Bullets9mm | Actual maxAmmo (15 default), plus chamber | 2.7s full magazine | 1.2s initial rack; semiauto rechambers after firing |
| Base.Shotgun | Base.ShotgunShells | Actual maxAmmo (6 default), plus chamber | 0.833s per inserted shell | 0.6s after each shot |
| Base.HuntingRifle | Base.308Bullets | Actual maxAmmo (4 default), plus chamber | 0.590s per inserted round | 1.2s after each shot |

These are explicit mechanism approximations based on native server action times, not player animation duration promises. Pistol requires an already inserted native magazine: the vanilla insertion action copies the magazine state into the gun, so no separate magazine item is fabricated or consumed by the turret. Loading moves only matching loose reserve into the actual empty gun, then chambers one round; interrupted loading spends no reserve before completion. Feeder services at most four registered turrets per tick within a one-millisecond budget and checks each at 100ms intervals; it does not catch up missed shots. It pauses without power, after removal or when disabled. Actual gun rounds are counted toward storage, including the chamber. Unload reserve before removing a head; the recovered gun keeps loaded rounds. The Magazine readout's trailing +0/+1 represents its chamber.

Damage is the average of current gun min/max damage, expressed on the 100-point scale, with Velocity and configurable multipliers. Accuracy is native HitChance plus AimingPerkHitChanceModifier times configurable baseline level 3, clamped 0-100 after the multiplier. It deliberately omits character moodles, crit/headshot rolls and exact distance/movement accuracy. Shotgun damage is divided across native pellet count, capped at nine pellets and three nearby valid unobstructed targets; it is an aggregate prototype, not native ballistic spread. Native recoilDelay/30 supplies a cadence baseline, constrained by pump/bolt timing. Native condition-lower chance wears the gun; existing jams block it, but this prototype adds no new randomized jams.

Shared Rapid-Fire also speeds mechanical cycling; Reload affects loading only; Autoloader removes loading wait but retains cycle/cooldown. Range/Velocity/Filter/Detection/Firing/360 and Expansion Kits share existing behavior. Guns use a separate 50-tile maximum effective range and 100-round default capacity. Potato defaults remain unchanged. Existing base health, module slots and power policies are shared by both head types; their stable internal Potato option keys are not duplicate firearm settings.

Native models and native firing sound events are referenced in place; no game assets are copied. Muzzle offsets derive from native muzzle/world attachments (pistol 0.0823, shotgun 0.2801, rifle 0.3468 model units, multiplied by native 1.5 world scale). Rendered yaw/muzzle alignment still needs the owner test. Gun heads require the normal 3D ground-item option; with it disabled, the base remains visible and Manage still identifies the gun. Potato retains its sprite fallback. A proper directional firearm sprite fallback remains future work.

## Complete combined owner test

1. Restart into SP with 0.2.20, diagnostics enabled and 3D ground items enabled. Use a disposable test area and building cheat as needed. Confirm the new Firearms group under OMH: T&T - Turrets and one spawn choice per module/kit.
2. Place a Turret Base. Obtain Base.Pistol, Base.9mmClip, loose Base.Bullets9mm, a charged car battery and Firing/Detection modules. Insert the magazine into the pistol using normal inventory actions before dragging the gun into Manage's head slot; add battery and loose ammo. Wrong ammo should be rejected.
3. With automation off, spawn a zombie inside the selected forward cone and click Fire after Ready. Check the actual gun turns, shoots from its barrel with native sound, spends one round per shot and has no potato splat. Check a wall prevents shots and targets outside the cone stay excluded.
4. Install Firing and Detection and enable automation. Empty the magazine to observe reload then racking. Remove the battery during loading: no free round or automatic shot; restoring power resumes a complete load. Check two Reload modules reduce loading and Rapid-Fire changes cadence; Autoloader eliminates loading wait while preserving mechanical cycling.
5. Turn automation off, unload reserve, and recover the pistol. Its loaded rounds, condition and attachments should remain. Repeat mounting/firing with Base.Shotgun plus Base.ShotgunShells, then Base.HuntingRifle plus Base.308Bullets. Check pump/bolt cadence and gun-head orientation for both.
6. Leave a gun, ammo, battery and modules installed; record counts/charge/condition. Pick up and redeploy the turret, then save/reload. Confirm supplies and effective stats survive, with no extra ammunition or functional base duplicates.
7. Beside it, run a potato turret to confirm its existing delayed brown projectile, splash and sound still work. Report test complete so console.txt can be captured; rendered alignment, sound and frame smoothness cannot be certified by headless tests. No separate destruction test is required.

Next: review this combined test and resolve adapter/rendering findings before expanding supported firearms. P2C3e multiplayer/performance remains a separate gate; broad discovery, additional mechanisms and modded weapon adapters are later P5 work.
