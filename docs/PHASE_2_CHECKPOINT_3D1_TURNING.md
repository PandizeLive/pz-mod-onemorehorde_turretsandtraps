# P2C3d1 follow-up: turning and presentation, 0.2.16.1

C61 approved. Includes fixed-prefix Sandbox pages, four potato-page headings, Detection Module wording, concise 360 tooltip, mechanically limited aiming, higher brown shot marker/larger splat, installed-native splat2 audio and placeholder base-depth correction. Collision/thumping and saved capacity/damage settings are unchanged. Stat modules and multiplayer remain deferred.

## Current native evidence

Installed 42.21.0: LuaManager.GlobalObject.Render3DItem delegates to WorldItemModelDrawer; the boolean is bIgnoreItemsInChunkTexture, not a request to disable world depth. IsoSprite.setupTileDepth uses FloorOverlay for its floor-depth branch instead of the default object depth. PropertyContainer exposes lowercase set(IsoFlagType). Native smoke verifies the actual sprite has FloorOverlay and retains four-sided collision, sight and reach. This keeps the model anchor unchanged; a final artist-supplied base should eventually have matching depth geometry rather than the placeholder approximation.

SandboxOptionsScreen, ISServerSandboxOptionsUI and ServerSettingsScreen hooks chain existing implementations using the reviewed Trait Shop attach pattern. Only panels containing our potato option are changed. Headings preserve controller navigation and resize layout.

OMHTTPotatoImpact references media/sound/splat2.wav using the native sound-script file field (as used by TutorialZombie). Playback uses exposed SoundManager.PlayWorldSound at the impact square. No AI or copied audio assets enter Contents. Audition folder: C:/Users/bandi/Zomboid_Modding/Listening/Potato Turret Native Sounds/Listen.html.

## Verification

2,058 Kahlua assertions, 42 runtime Lua files, 290 native translations, 23 packet round trips and 109 package files. Tests cover shortest turn across 0/360 (positive-normalized Kahlua remainder), angular speed, overshoot, no ammo spent before alignment, exactly one delayed manual shot, unchanged coverage, brown effects, grouped Sandbox resize/navigation/idempotence and unrelated-page isolation. Original 0.2.16 native write/read passed in 41.3/43.5s. The tooltip-corrected 0.2.16.1 write/read also passed, including a real battery and native re-translation of its packed tooltip. Installation evidence is recorded in RELEASE.md when complete. GPU appearance and audible playback remain owner tests.

## Complete owner test

1. Restart on 0.2.16.1. Check every Sandbox page starts OMH: T&T - and Potato Turret has four readable headings. Set Turn speed to 30 for an obvious test; default is 90 degrees/second.
2. Inspect an existing turret from several positions/zoom levels. Its head should draw above its base without moving upward; walls and nearby characters should still occlude appropriately.
3. With power, Detection and Firing installed, introduce a target away from the current head direction. The head turns smoothly and fires only when aligned. Detection coverage remains placement-locked; verify the Detection Module name and short 360 tooltip.
4. Disable automatic mode and click Fire once with a target off-axis. Expect one shot after turning. Try again and walk away during the turn: the pending manual shot should cancel without spending ammo.
5. Fire at a group. Look for the higher brown travel marker and larger brown pop; listen for splat2 at impact. Remove power during a turn and confirm it stops.
6. Save/reload, confirm actual contents/charge survive, then send Test Complete and any rendering/audio issue. The reload audition page is separate; choose by filename whenever ready.
