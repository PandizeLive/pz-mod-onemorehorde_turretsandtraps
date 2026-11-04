# C223: installed explosive damage trace

Investigated 2026-10-13 against installed Project Zomboid **42.21.0 4a0e9546ec**. JAR SHA256: `E1A69EB743EDE60B213A0FE7F8B83D4FCAB773036D256CC4543A336F3B058A33`.

This supersedes C215's historical 42.0 formula. It is evidence for balancing discussion, not approval to copy native explosives into the turret or proof of rendered Lobber behavior.

## Current path

Inspected installed bytecode using JDK17 `javap -c -p` for `zombie.iso.objects.IsoTrap`, `zombie.characters.IsoGameCharacter`, `zombie.characters.IsoZombie`, `zombie.characters.IsoPlayer`, `zombie.inventory.types.HandWeapon` and `zombie.CombatManager`.

1. `IsoTrap.explosion` caps power at **100**, then uses the actual explosive HandWeapon and rolls `Rand.Next(power / 20, power / 10) + ExtraDamage`. It passes this to `Hit` with multiplier one. The old cap80/divisor30/synthetic-axe calculation is not the current ordinary damage path.
2. `HandWeapon.setScriptItem` identifies Explosives display-category weapons as explosive; melee classification comes from weapon categories. Native Aerosolbomb/PipeBomb have no melee categories and default ExtraDamage zero.
3. `IsoGameCharacter.processHitDamage` routes explosive weapons to `processInstantExplosionHitDamage`, which returns input damage times the supplied multiplier.
4. Normal zombie `hitConsequences` reaches the character health path. `CombatManager.applyGlobalDamageReductionMultipliers` applies its global reduction only to melee weapons; then `applyDamage` subtracts from health, clamping at zero. Invulnerability, hit-cancelling hooks and exceptional states can prevent ordinary damage.
5. OMH converts displayed damage into native health units by dividing by100 (`TurretWorld.lua`, `TurretRotary.lua`, `TurretProc.lua`). Compare on that scale, not by equating ExplosionPower directly with displayed damage.

| Native item | Power / blast radius | Native ordinary zombie damage input | Equivalent OMH damage scale |
| --- | --- | --- | --- |
| Aerosol Bomb (`Base.Aerosolbomb`) | 70 / 6 tiles | 3.5 to below7 health | 350 to below700 |
| Pipe Bomb (`Base.PipeBomb`) | 90 / 7 tiles | 4.5 to below9 health | 450 to below900 |

Item metadata is in installed `media/scripts/generated/items/weapon.txt`, Aerosolbomb/PipeBomb blocks. Values above describe damage potential before overkill clamping, not health loss beyond a victim's remaining health or a guarantee against modded zombies.

`IsoTrap.drawCircleExplosion` checks a same-floor grid circle and line of sight, rejecting blocked/closed-door paths and NonPvpZone squares. The inspected native path has **no distance damage falloff** within eligible blast squares. Fire/burning is a separate branch: Aerosol Bomb has FireStartingChance10/energy20; Pipe Bomb has zero. Do not invoke these environmental effects for the approved actor-only Lobber blast.

Players use their own `IsoPlayer.hitConsequences` / `BodyDamage.DamageFromWeapon` path; this table is **not player HP damage**. Player injury severity still needs its own contract. Multiplayer ownership, full scene explosions, ragdoll behavior, clothing and mod hooks are not certified by the bytecode trace.

## Balance implication

Both earlier Lobber bundles (80/120/180 or120/180/240 for Shell/Aerosol/Pipe, radii2/3/4) are intentionally reduced custom turret values, not native equivalents. Native-equivalent bombs every3.5 seconds would combine high overkill with a much larger affected area. Recommend an explicitly tuned actor-only blast with falloff, preserving native handheld items unchanged. Exact damage/radius/falloff remains an owner decision.

## Execution evidence

An isolated stock-first Java probe checks real item classification and native damage processing/health subtraction at the formula boundaries; its status is recorded with C223. It does not create a complete blast scene. Initial run exceeded its100-second startup allowance before reaching the test; that run is not a pass. Raw inspection files and isolated cache remain under ignored `diagnostics/explosive-c223/`.

Second run **passed** with a300-second startup allowance. Real native instances confirmed explosive=true, melee=false and ExtraDamage=0 for both items. Four deterministic boundary inputs3.5/7/4.5/9 produced identical native health reductions. The upper endpoint inputs test the arithmetic boundary, not reachable maximum RNG samples. Victim health was set to100 native units to avoid overkill clamping. This invokes processing/reduction/subtraction helpers, not full Hit/scene physics. Stock startup emitted unrelated tile-property/asset warnings; no claim of an error-free game log.

Reproduction source and filtered result: [Java probe](../diagnostics/explosive-c223/ExplosionDamageProbe.java), [runner](../diagnostics/explosive-c223/run_probe.py), [result](../diagnostics/explosive-c223/result.txt).
