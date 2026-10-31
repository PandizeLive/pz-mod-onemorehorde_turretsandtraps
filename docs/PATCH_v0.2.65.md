# 0.2.65 - C437 progression and corrective build

Owner approval follows C436 option 1C and includes the selected C428/C429 corrective scope.

- Turret manuals and Turret Specialist
- Zombie module-pack default
- Sandbox organization and rarity selectors
- Consolidated Mod Options
- Per-head coverage and hearing
- Arc glow, lighting and sound
- Head-specific Fragment sound
- Laser world depth and actor obstruction
- Fast-forward simulation
- Local LootLab catalog

Five native manuals teach Ballista/Rotary Blade (Uncommon), Lobber/Firearms (Rare) and Arc (Epic). They use their assigned loaded rarity weights and preserve explicit custom overrides. Normal OMHTT containers plus books and magazine racks contain manuals; module packs still contain only three modules/kits. Their fresh-world zombie drop default is 7%; existing saved tuning remains. Turret Specialist costs two points, teaches all six recipe identifiers across those five subjects, and grants no gear, skills or XP. Existing crafting bills, skill requirements, tools, durations and XP are unchanged. Firearms knowledge gates incoming gun installation in client admission and authoritative completion, including supported addon guns. Existing installed guns and normal handheld use are unaffected.

The Turrets Sandbox page follows General, Standby, Storage, Rotary Bat, Rotary Blade, Potato Launcher, Scrapshot, Ballista, Arc Emitter, Lobber and Firearms. Automation's sidebar and global veto are removed. Detection Interval remains under General because it controls the baseline scan cadence. Per-head cones retain earlier effective geometry when unset; the 360 module overrides them. Rotary contact sweeps and Siphon accounting follow the selected sector. Hearing is grouped with its head; native firearm hearing remains native. Player contact settings stay with Traps. Numeric entries show ordinary decimals and preserve untouched exact values. Loot selectors group categories, then rarity and alphabetical name, with Disabled and Custom. Legacy numeric IDs still import/export through LootLab. Both previous personal option stores feed a single page, with master feedback volume, range visibility, laser visibility/opacity and Arc lighting/intensity.

Arc uses a white emissive core and premultiplied transparent blue edges through a native world shader, retaining its 80ms flash/250ms fade and 192-draw limit. At most four brief local lights exist; players can disable them. Selected S1B firing gains 14dB in its derived sample; S1C DismantleFailed uses gain 2 and keeps four impact starts per 100 real milliseconds. Measured active RMS: Arc shot -22.53dBFS, impact -24.32; M9 -20.15, M16 -20.22, Ballista -19.52. Individual Arc sample peaks stay below zero. This does not prove listening balance with spatial mixing and overlapping turrets. Non-firearm fragments reuse their originating head cue at lower gain; firearm fragments retain the selected suppressed pistol cue.

Laser beams render as bounded native world geometry. Their visual endpoint stops at the closest intersecting live actor, while sensing range remains unchanged. Visibility defaults off. Native depth is used instead of a screen overlay; final actor occlusion still requires GPU acceptance.

Gameplay clocks derive elapsed simulation time from world time and day length. Turning, reload/cooldown, standby, projectiles, Tack fields, contacts, pressure recovery and tether cycles advance with fast-forward. Pause excludes elapsed time; saved remaining effects/cycles retain their existing persistence rules. Presentation/audio/network budgets remain real-time, with no missed-shot catch-up storm. Tether substeps consume accelerated elapsed time without growing debt; pathological time jumps cancel transient attacks safely.

Local LootLab includes 38 entries and re-extracted literature routes. Existing account weights, visibility and anchors survive migration, including 0.2.64.x. The local cloud schema is updated and tested; the hosted site is not deployed.

No Workshop upload, PR merge, hosted LootLab publication or connected-player acceptance. [Verification](TEST_v0.2.65.md).
