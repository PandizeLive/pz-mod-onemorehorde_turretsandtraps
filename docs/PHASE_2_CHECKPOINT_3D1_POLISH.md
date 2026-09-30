# P2C3d1 follow-up: automation polish, 0.2.15

Approved C60. Thumping accepted by owner; unchanged. Core automation remains SP-only, and stat-module effects remain deferred.

## Implementation

- 360 Module display name, stable internal ID.
- Manage leaves both native inventory windows untouched; normal inventory drag/drop remains available when opened manually.
- Tick-driven, bounded visual idle sweep (30 degrees/second; 0 disables). No accumulated motion burst after a long frame. Inactive devices freeze, acquired targets restore combat aim, and sweep never changes stored aim/base orientation or expands detection coverage. Range arrow follows visual heading. No per-frame inventory enumeration or target searches are added.
- Default capacity 100 total rounds; splash is 25 percent of direct damage with radius 1.5 and three-target cap. Impact-local bounded candidate acquisition fixes far-target splash omission in dense crowds. Direct target is excluded and secondary targets receive no knockdown.
- Old PotatoSplashDamage is retired; new PotatoSplashPercent defaults 25. Old absolute numbers are never read as percentages. Saved capacity/radius/timers remain intact. Set desired values explicitly when testing an old save.
- Short 120 ms white shot marker, then existing impact pop. Instant damage, no persistent physical projectile. Hidden/different-floor impacts are suppressed. Current effect path retains the existing primary-viewport limitation.
- No audio assets added. Owner brief: ../art/AUDIO_BRIEF.md.

## Evidence

Current game 42.21.0 CombatManager uses BallisticsController targeting/Hit plus IsoBulletTracerEffects presentation, corroborated through installed JAR bytecode. Existing native Render3DItem and IsoUtils paths are reused. Authoritative thumping is unchanged following owner confirmation.

Kahlua/native package validation: 2,048 assertions; 40 runtime files compiled; 282 native JSON translations; 23 packet serializations; 106 packaged files. Model import, eight-direction projection and 16-pixel anchor checks pass. World/player/UI fixtures do not establish rendered acceptance.

Native write/read persistence passed in 79.3/88.6 seconds. Installation evidence is recorded in RELEASE.md after completion. No publication or remote push.

## Complete owner test

1. Restart with version 0.2.15. For an old save, explicitly set ammo capacity 100, direct damage 35, splash percent 25, splash radius 1.5 and reload/cooldown 2 seconds. Confirm the item is named 360 Module.
2. Close both inventory windows, then Manage a turret. Only Manage should open. Open your inventory manually and verify one module/ammo transfer still works.
3. With power, Motion Detection and automatic mode on, leave the cone empty. The head sweeps inside fixed coverage; set sweep speed zero to stop it, then restore 30. Bring a zombie into range: the head tracks it instead.
4. Remove Detection, switch automation off, or remove the battery with grid/generator power disconnected. The head stops. Restore the requirements and confirm searching resumes. With 360 installed, coverage expands without moving the base.
5. Fire at a small group. The primary takes 35 damage; up to three nearby zombies take 8.75, without splash knockdown. Look for the short white travel marker and impact pop. Fill to 100 total potatoes; an extra potato is rejected.
6. Save/reload, confirm contents and controls persist, then report Test Complete plus any visual/UI issue. Codex will inspect console.txt; no separate thumping test is required.
