# C428 - Canonical Sandbox inventory

Read-only snapshot of 0.2.64.4, 2026-10-22: 221 definitions across eight canonical pages. This lists current labels/defaults, including defects; it is not the proposed final presentation. Independent packages filter the canonical set. [Diagnosis and proposed organization](AUDIT_C428.md).

## OMH: T&T - General (3)

| Saved ID | Current label | Type | Default |
| --- | --- | --- | --- |
| OMHTurretsTraps.Enabled | Traps: Enable Turrets & Traps | boolean | true |
| OMHTurretsTraps.ShowTurretRange | Show Turret Range | boolean | true |
| OMHTurretsTraps.TurretsEnabled | Turrets: Enable Turrets & Traps | boolean | true |

## OMH: T&T - Traps (33)

| Saved ID | Current label | Type | Default |
| --- | --- | --- | --- |
| OMHTurretsTraps.SpikeBarrier | Enable Spike Barrier | boolean | true |
| OMHTurretsTraps.SpikeBarrierDamage | Damage | integer | 10 |
| OMHTurretsTraps.SpikeBarrierHealth | Maximum Durability | integer | 100 |
| OMHTurretsTraps.SpikeBarrierScratchChance | Vault Scratch Chance | integer | 5 |
| OMHTurretsTraps.ReinforcedBarrierDamage | Reinforced Damage | integer | 25 |
| OMHTurretsTraps.ReinforcedBarrierHealthMultiplier | Reinforced Durability Multiplier | integer | 2 |
| OMHTurretsTraps.BedSpikes | Enable Bed Spikes | boolean | true |
| OMHTurretsTraps.BedTripChance | Trip Chance (percent) | integer | 40 |
| OMHTurretsTraps.BedDamage | Fall Damage | integer | 20 |
| OMHTurretsTraps.BedReinforcedDamage | Reinforced Fall Damage | integer | 50 |
| OMHTurretsTraps.BedHealth | Durability | integer | 50 |
| OMHTurretsTraps.BedReinforcedHealth | Reinforced Durability | integer | 100 |
| OMHTurretsTraps.BedWear | Wear Per Fall | integer | 6 |
| OMHTurretsTraps.BedRecoverySeconds | Trip Protection (seconds) | integer | 5 |
| OMHTurretsTraps.BedScratchChance | Running Contact Scratch Chance | integer | 20 |
| OMHTurretsTraps.BedSprintTripChance | Sprinting Contact Trip Chance | integer | 20 |
| OMHTurretsTraps.BarbSections | Enable Barbed Sections | boolean | true |
| OMHTurretsTraps.BarbDamage | Contact Damage | double | 10 |
| OMHTurretsTraps.BarbInterval | Contact Interval | double | 2 |
| OMHTurretsTraps.BarbWire | Enable Concertina Wire | boolean | true |
| OMHTurretsTraps.BarbMovementDivisor | Contact Movement Divisor | double | 2 |
| OMHTurretsTraps.PokeDamage | Strike Damage | double | 45 |
| OMHTurretsTraps.PokeCycleSeconds | Cycle Duration (Seconds) | double | 1.5 |
| OMHTurretsTraps.PokeHealth | Condition | double | 200 |
| OMHTurretsTraps.PokeWear | Wear Per Successful Cycle | double | 1 |
| OMHTurretsTraps.PokeScratchChance | Running Scratch Chance (Percent) | double | 20 |
| OMHTurretsTraps.TetherRange | Range | double | 6 |
| OMHTurretsTraps.TetherLaunchSpeed | Launch Speed | double | 30 |
| OMHTurretsTraps.TetherReturnSpeed | Reel Speed | double | 4 |
| OMHTurretsTraps.TetherHoldSeconds | Hold Duration | double | 0.75 |
| OMHTurretsTraps.TetherResetSeconds | Reset Duration | double | 0.4 |
| OMHTurretsTraps.TetherHitDamage | Impact Damage | double | 30 |
| OMHTurretsTraps.TetherPullDamage | Pull Damage | double | 15 |

## OMH: T&T - Turrets (74)

| Saved ID | Current label | Type | Default |
| --- | --- | --- | --- |
| OMHTurretsTraps.PotatoTurret | Potato Turret | boolean | true |
| OMHTurretsTraps.PotatoRequirePower | Require Power | boolean | true |
| OMHTurretsTraps.PotatoAmmoCapacity | Ammo Capacity | integer | 100 |
| OMHTurretsTraps.PotatoModuleCapacity | Module Storage | integer | 2 |
| OMHTurretsTraps.PotatoHealth | Durability | integer | 100 |
| OMHTurretsTraps.PotatoDamage | Damage | double | 35 |
| OMHTurretsTraps.PotatoCooldown | Fire Rate (seconds/shot) | double | 2 |
| OMHTurretsTraps.PotatoMagazineCapacity | Magazine Size | integer | 3 |
| OMHTurretsTraps.PotatoReloadTime | Reload (seconds) | double | 2 |
| OMHTurretsTraps.PotatoProjectileSpeed | Projectile Speed | double | 20.0 |
| OMHTurretsTraps.PotatoHearingRadius | Hearing Radius | integer | 8 |
| OMHTurretsTraps.PotatoPlaybackVolume | Potato Sound Volume | integer | 35 |
| OMHTurretsTraps.PotatoRange | Range | integer | 6 |
| OMHTurretsTraps.PotatoKnockdownChance | Knockdown Chance | integer | 40 |
| OMHTurretsTraps.PotatoSplashPercent | Splash Damage Percent | double | 25 |
| OMHTurretsTraps.PotatoSplashRadius | Splash Radius | double | 1.5 |
| OMHTurretsTraps.PotatoBatteryPercentPerShot | Battery Use | double | 0.00045 |
| OMHTurretsTraps.PotatoGeneratorFuelPerShot | Generator Use | double | 0.0001 |
| OMHTurretsTraps.IdleSweepSpeed | Idle Sweep Speed | double | 30 |
| OMHTurretsTraps.PotatoTurnSpeed | Turn Speed | double | 90 |
| OMHTurretsTraps.FirearmTurrets | Firearm Turrets | boolean | true |
| OMHTurretsTraps.FirearmAmmoCapacity | Ammo Storage | integer | 250 |
| OMHTurretsTraps.FirearmAimingLevel | Aiming Level | integer | 3 |
| OMHTurretsTraps.FirearmRangeAccuracy | Maximum-range Accuracy | double | 60 |
| OMHTurretsTraps.PrecisionRangeAccuracy | Precision Maximum-range Accuracy | double | 80 |
| OMHTurretsTraps.FirearmAccuracyMultiplier | Accuracy Multiplier | double | 1 |
| OMHTurretsTraps.FirearmDamageMultiplier | Damage Multiplier | double | 1 |
| OMHTurretsTraps.FirearmRangeMultiplier | Range Multiplier | double | 1 |
| OMHTurretsTraps.FirearmReloadMultiplier | Reload Time Multiplier | double | 1 |
| OMHTurretsTraps.FirearmRateMultiplier | Firearm Fire Rate | double | 0.75 |
| OMHTurretsTraps.FirearmCycleMultiplier | Cycle Time Multiplier | double | 1 |
| OMHTurretsTraps.FirearmTurnSpeed | Turn Speed | double | 90 |
| OMHTurretsTraps.BallistaBatteryPercent | Ballista Battery Use | double | 0.025 |
| OMHTurretsTraps.RotaryBatteryHours | Rotary Motor Hours | double | 6 |
| OMHTurretsTraps.PotatoCriticalChance | Critical Chance | double | 0 |
| OMHTurretsTraps.PotatoCriticalDamage | Critical Damage | double | 2 |
| OMHTurretsTraps.ModulePowerBonus | Module Power Scaling (5 = Normal) | double | 5 |
| OMHTurretsTraps.FirearmBatteryMultiplier | Firearm Battery Multiplier | double | 1.5 |
| OMHTurretsTraps.ScrapshotBatteryPercent | Scrapshot Battery Use (Percent) | double | 0.0025 |
| OMHTurretsTraps.RotaryBladesBatteryMultiplier | Rotary Blades Battery Multiplier | double | 2 |
| OMHTurretsTraps.LobberBatteryMultiplier | Grenade Lobber Battery Multiplier | double | 1.5 |
| OMHTurretsTraps.TurretPlayerDamageMultiplier | Turret Player Damage Multiplier | double | 1 |
| OMHTurretsTraps.TurretPlayerWoundMultiplier | Turret Player Wound Chance Multiplier | double | 1 |
| OMHTurretsTraps.TurretStandbyEnabled | Detection Standby | boolean | true |
| OMHTurretsTraps.TurretIdleSeconds | Standby Idle Delay | double | 7 |
| OMHTurretsTraps.TurretWakeSeconds | Wake Duration | double | 1 |
| OMHTurretsTraps.TurretStateIndicator | Turret State Indicator | boolean | true |
| OMHTurretsTraps.FriendlyPlayerDamageMultiplier | Friendly Damage | double | 2 |
| OMHTurretsTraps.FriendlyPlayerWoundMultiplier | Friendly Wound Chance | double | 1 |
| OMHTurretsTraps.HostilePlayerDamageMultiplier | Hostile Player Damage | double | 4 |
| OMHTurretsTraps.HostilePlayerWoundMultiplier | Hostile Player Wound Chance | double | 4 |
| OMHTurretsTraps.BallistaDamage | Damage | double | 240 |
| OMHTurretsTraps.BallistaRange | Range | double | 24 |
| OMHTurretsTraps.BallistaCooldown | Cooldown | double | 6 |
| OMHTurretsTraps.BallistaReload | Reload | double | 6 |
| OMHTurretsTraps.ScrapshotDamage | Damage | double | 320 |
| OMHTurretsTraps.ScrapshotRange | Range | double | 8 |
| OMHTurretsTraps.ScrapshotCooldown | Cooldown | double | 2 |
| OMHTurretsTraps.ScrapshotReload | Reload | double | 3 |
| OMHTurretsTraps.LobberDamage | Damage | double | 150 |
| OMHTurretsTraps.LobberRange | Range | double | 18 |
| OMHTurretsTraps.LobberCooldown | Cooldown | double | 5.5 |
| OMHTurretsTraps.LobberReload | Reload | double | 4 |
| OMHTurretsTraps.RotaryBatDamage | Damage | double | 20 |
| OMHTurretsTraps.RotaryBatShove | Shove | double | 40 |
| OMHTurretsTraps.RotaryBladesDamage | Damage | double | 40 |
| OMHTurretsTraps.RotaryBladesShove | Shove | double | 10 |
| OMHTurretsTraps.TurretAlertDelay | Post-Alert Firing Delay | double | 0.25 |
| OMHTurretsTraps.ArcDamage | Damage | double | 20 |
| OMHTurretsTraps.ArcRange | Acquisition Range | double | 12 |
| OMHTurretsTraps.ArcCooldown | Shot Interval | double | 1 |
| OMHTurretsTraps.ArcTargets | Normal Targets | double | 6 |
| OMHTurretsTraps.ArcJumpRange | Jump Range | double | 4 |
| OMHTurretsTraps.ArcBatteryPercent | Battery Cost Per Shot | double | 0.02 |

## OMH: T&T - Automation (3)

| Saved ID | Current label | Type | Default |
| --- | --- | --- | --- |
| OMHTurretsTraps.AutomationEnabled | Enable Automation | boolean | true |
| OMHTurretsTraps.ForwardCone | Forward Cone | integer | 90 |
| OMHTurretsTraps.DetectionInterval | Detection Interval | double | 0.25 |

## OMH: T&T - Modules (50)

| Saved ID | Current label | Type | Default |
| --- | --- | --- | --- |
| OMHTurretsTraps.RapidFireBonus | Fire Rate Per Module (percent) | double | 25 |
| OMHTurretsTraps.RapidFireBonusCap | Maximum Fire Rate Bonus (percent) | double | 200 |
| OMHTurretsTraps.RapidFireMinimum | Minimum Shot Interval (s) | double | 0.25 |
| OMHTurretsTraps.ReloadBonus | Reload Speed Per Module (percent) | double | 25 |
| OMHTurretsTraps.ReloadBonusCap | Maximum Reload Speed Bonus (percent) | double | 200 |
| OMHTurretsTraps.ReloadMinimum | Minimum Reload Time (s) | double | 0.25 |
| OMHTurretsTraps.VelocityBonus | Damage Per Module (percent) | double | 20 |
| OMHTurretsTraps.VelocityBonusCap | Maximum Damage Bonus (percent) | double | 100 |
| OMHTurretsTraps.VelocityKnockdownBonus | Knockdown Per Module (points) | double | 5 |
| OMHTurretsTraps.VelocityKnockdownCap | Maximum Knockdown Chance (percent) | double | 90 |
| OMHTurretsTraps.RangeBonus | Range Per Module (tiles) | double | 2 |
| OMHTurretsTraps.RangeBonusCap | Maximum Range Bonus (tiles) | double | 10 |
| OMHTurretsTraps.CapacityAmmoBonus | Medium: Ammo Scaling | integer | 400 |
| OMHTurretsTraps.CapacityModuleBonus | Medium: Extra Slots | integer | 10 |
| OMHTurretsTraps.CapacitySmallAmmoBonus | Small: Ammo Scaling | integer | 200 |
| OMHTurretsTraps.CapacitySmallModuleBonus | Small: Extra Slots | integer | 6 |
| OMHTurretsTraps.CapacityLargeAmmoBonus | Large: Ammo Scaling | integer | 650 |
| OMHTurretsTraps.CapacityLargeModuleBonus | Large: Extra Slots | integer | 14 |
| OMHTurretsTraps.SuppressionFirstReduction | First-module Reduction | double | 60 |
| OMHTurretsTraps.SuppressionDiminishing | Stack Scaling | double | 0.6 |
| OMHTurretsTraps.SuppressionVolumeFloor | Fallback Volume Floor | double | 10 |
| OMHTurretsTraps.CriticalBonus | Critical Chance Per Module | double | 5 |
| OMHTurretsTraps.AccuracyBonus | Accuracy Per Module | double | 5 |
| OMHTurretsTraps.CriticalDamageMultiplier | Critical Damage Multiplier | double | 1 |
| OMHTurretsTraps.CapacityImprovisedModuleBonus | Makeshift Kit: Module Slots | integer | 2 |
| OMHTurretsTraps.CapacityImprovisedAmmoBonus | Makeshift: Ammo Scaling | integer | 100 |
| OMHTurretsTraps.ImprovisedFiringFailure | Makeshift Firing: Failure Chance | integer | 15 |
| OMHTurretsTraps.MagazineBonus | Magazine Capacity Per Module ( Percent) | double | 35 |
| OMHTurretsTraps.SplitterDamage | Side-shot Damage ( Percent) | double | 50 |
| OMHTurretsTraps.FragmentDamage | First Fragment Damage ( Percent) | double | 20 |
| OMHTurretsTraps.FragmentBonus | Fragment Damage Per Extra Copy ( Percent) | double | 5 |
| OMHTurretsTraps.FragmentDamageCap | Maximum Fragment Damage ( Percent) | double | 40 |
| OMHTurretsTraps.FragmentRange | Fragment Range (tiles) | double | 4 |
| OMHTurretsTraps.EnhancedFireMultiplier | Enhanced Firing Multiplier | double | 1.3333333333333333 |
| OMHTurretsTraps.EnhancedTurnMultiplier | Enhanced Turning Multiplier | double | 3 |
| OMHTurretsTraps.EnhancedDetectionInterval | Enhanced Scan Interval (seconds) | double | 0.1 |
| OMHTurretsTraps.PiercingRetention | Damage Retained (percent) | double | 70 |
| OMHTurretsTraps.InitialBlowBonus | Damage Per Copy (percent) | double | 25 |
| OMHTurretsTraps.InitialBlowThreshold | Minimum Target Health (percent) | double | 90 |
| OMHTurretsTraps.ExecuteFirst | First-copy Health Threshold (percent) | double | 10 |
| OMHTurretsTraps.ExecuteBonus | Health Threshold Per Extra Copy (percent) | double | 2 |
| OMHTurretsTraps.ImpactFirst | First-copy Chance (percent) | double | 60 |
| OMHTurretsTraps.ImpactBonus | Chance Per Extra Copy (percent) | double | 2 |
| OMHTurretsTraps.MartyrdomRadius | Martyrdom Radius | double | 1.5 |
| OMHTurretsTraps.MartyrdomDamage | Martyrdom Damage | double | 20 |
| OMHTurretsTraps.TackRadius | Tack Radius | double | 1 |
| OMHTurretsTraps.TackDamage | Tack Damage | double | 10 |
| OMHTurretsTraps.TackLifetime | Tack Lifetime | double | 10 |
| OMHTurretsTraps.ControllerKitCapacity | Controller Capacity Per Kit Grade | integer | 100 |
| OMHTurretsTraps.ControllerKitRange | Controller Radius Per Kit Grade | integer | 10 |

## OMH: T&T - Loot (43)

| Saved ID | Current label | Type | Default |
| --- | --- | --- | --- |
| OMHTurretsTraps.ModuleLootRate | Module Loot Multiplier | double | 1.00 |
| OMHTurretsTraps.LootRateFiring | Firing Loot Multiplier | double | 0.4666666666666667 |
| OMHTurretsTraps.LootRateMotionDetection | Detection Loot Multiplier | double | 0.4666666666666667 |
| OMHTurretsTraps.LootRateFilter | Filter Loot Multiplier | double | 3.6 |
| OMHTurretsTraps.LootRateDetection360 | 360 Loot Multiplier | double | 4 |
| OMHTurretsTraps.LootRateRapidFire | Rapid-Fire Loot Multiplier | double | 3.6 |
| OMHTurretsTraps.LootRateSuppression | Suppression Module | double | 4 |
| OMHTurretsTraps.LootRateReload | Reload Loot Multiplier | double | 4 |
| OMHTurretsTraps.LootRateAutoloader | Autoloader Loot Multiplier | double | 0.6666666666666666 |
| OMHTurretsTraps.LootRateVelocity | Velocity Loot Multiplier | double | 2 |
| OMHTurretsTraps.LootRateRange | Range Loot Multiplier | double | 3.6 |
| OMHTurretsTraps.LootRateCapacity | Medium Expansion Loot Multiplier | double | 2.4 |
| OMHTurretsTraps.LootRateCapacitySmall | Small Expansion Loot Multiplier | double | 1.8666666666666667 |
| OMHTurretsTraps.LootRateCapacityLarge | Large Expansion Loot Multiplier | double | 2 |
| OMHTurretsTraps.LootRateCritical | Critical Loot | double | 4 |
| OMHTurretsTraps.LootRateAccuracy | Accuracy Loot | double | 4 |
| OMHTurretsTraps.LootRateMagazine | Magazine Loot Multiplier | double | 3.6 |
| OMHTurretsTraps.LootRateSplitter | Splitter Loot Multiplier | double | 2.4 |
| OMHTurretsTraps.LootRateFragment | Fragment Loot Multiplier | double | 1.2 |
| OMHTurretsTraps.LootRateFiringEnhanced | Enhanced Firing Loot Multiplier | double | 0.6666666666666666 |
| OMHTurretsTraps.LootRateMotionDetectionEnhanced | Enhanced Detection Loot Multiplier | double | 0.6666666666666666 |
| OMHTurretsTraps.LootRatePiercing | Piercing Loot Multiplier | double | 4 |
| OMHTurretsTraps.LootRateInitialBlow | Initial Blow Loot Multiplier | double | 2.4 |
| OMHTurretsTraps.LootRateExecute | Execute Loot Multiplier | double | 1.2 |
| OMHTurretsTraps.LootRateImpact | Impact Loot Multiplier | double | 2.4 |
| OMHTurretsTraps.LootRateConservation | Conservation Loot Multiplier | double | 2.4 |
| OMHTurretsTraps.LootRateSynergy | Synergy Loot Multiplier | double | 1 |
| OMHTurretsTraps.LootRateSiphon | Siphon Module | double | 1 |
| OMHTurretsTraps.LootRateMartyrdom | Martyrdom Loot Multiplier | double | 2 |
| OMHTurretsTraps.LootRateTack | Tack Loot Multiplier | double | 2 |
| OMHTurretsTraps.LootRateRegulator | Regulator Module | double | 3.6363636363636362 |
| OMHTurretsTraps.PackLootWeight | Module Pack Weight | double | 1 |
| OMHTurretsTraps.PackZombieChance | Zombie Module Pack Chance | double | 15 |
| OMHTurretsTraps.RarityWeightAbundant | Abundant Weight | double | 20 |
| OMHTurretsTraps.RarityWeightCommon | Common Weight | double | 18 |
| OMHTurretsTraps.RarityWeightUncommon | Uncommon Weight | double | 14 |
| OMHTurretsTraps.RarityWeightRare | Rare Weight | double | 10 |
| OMHTurretsTraps.RarityWeightEpic | Epic Weight | double | 6 |
| OMHTurretsTraps.RarityWeightLegendary | Legendary Weight | double | 3 |
| OMHTurretsTraps.RarityWeightMythic | Mythic Weight | double | 1 |
| OMHTurretsTraps.LootRateLure | Lure Module | double | 1 |
| OMHTurretsTraps.LootRateVoid | Void Module | double | 1 |
| OMHTurretsTraps.LootRateGrid | Grid Module | double | 1 |

## OMH: T&T - Debug (7)

| Saved ID | Current label | Type | Default |
| --- | --- | --- | --- |
| OMHTurretsTraps.FoundationTestControls | Traps: Foundation Test Controls | boolean | false |
| OMHTurretsTraps.DiagnosticLogging | Traps: Diagnostic Logging | boolean | true |
| OMHTurretsTraps.ShowCollision | Show Collision | boolean | false |
| OMHTurretsTraps.DetailedLogging | Traps: Detailed Logging | boolean | false |
| OMHTurretsTraps.TurretDiagnosticLogging | Turrets: Diagnostic Logging | boolean | true |
| OMHTurretsTraps.TurretDetailedLogging | Turrets: Detailed Logging | boolean | false |
| OMHTurretsTraps.TurretTestControls | Turrets: Foundation Test Controls | boolean | false |

## OMH: T&T - Triggers (8)

| Saved ID | Current label | Type | Default |
| --- | --- | --- | --- |
| OMHTurretsTraps.TriggerButtonConsumption | Button Battery Consumption | double | 0.0001 |
| OMHTurretsTraps.TriggerPlateConsumption | Plate Battery Consumption | double | 0.0100 |
| OMHTurretsTraps.TriggerLeverConsumption | Lever Battery Consumption | double | 0.0100 |
| OMHTurretsTraps.TriggerLaserConsumption | Laser Battery Consumption | double | 0.1000 |
| OMHTurretsTraps.ControllerRange | Controller Range | double | 10 |
| OMHTurretsTraps.LaserRange | Laser Beam Range | double | 10 |
| OMHTurretsTraps.DeviceSoundVolume | Device Sound Volume | double | 1 |
| OMHTurretsTraps.ControllerCapacity | Base Stockpile Capacity | integer | 100 |
