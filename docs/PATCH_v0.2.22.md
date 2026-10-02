# 0.2.22 — suppression and turret feedback

C73: owner approved the combined rendering, reload and Suppression Module patch after accepting the balanced audio approach. Source audio is owner-supplied or rendered from the installed 42.21.0 game. No external publication, extra gun adapters, recipes, Java patch or new player dependency.

## Changes

- Mounted firearms bypass the native static world-item image atlas only during their draw. Restore both stored/debug and default/non-debug settings immediately afterward, along with the item's original rotation; recover an interrupted draw on the next render/tick. This avoids rebuilding an image cache at every aim angle. Ordinary dropped items keep their normal rendering. GPU visibility remains an owner check.
- Potato reload uses the selected installed `stormyShotgunInsertRound.wav`. Supported firearms use their native insert-start, insert, insert-stop and rack sound fields. Existing bounded powered-feeder work drives transitions; repeated polling does not replay a cue and late ticks do not burst missed sounds. Head changes/removal, power loss and invalid requirements stop owned sound handles. Autoloader skips its eliminated reload phase; pump/bolt cycling remains audible.
- Add loot-only Suppression Module, shortened to Suppression in installed slots. Each working module removes 25% of remaining zombie hearing radius by default. No separate stack cap: available regular slots are the limit. Radius is rounded to the nearest tile; enough suppression can reach zero. Broken/overflow-inactive modules have no effect.
- One or more active suppression modules select one preprocessed shot with the agreed 250 Hz steep filter and the owner's unfiltered overlay. Extra modules do not multiply playback or attenuate audible gain. Removing the last working module restores ordinary firing sound and hearing radius. Pitch varies subtly as before.
- Modules Sandbox group exposes hearing reduction (0–100%); Loot exposes the module's weight multiplier. Turrets exposes potato Hearing radius (0–200 tiles, default 12). Potato shots now explicitly notify zombie hearing; the previous custom emitter had no explicit AI sound event. Firearms retain their native weapon hearing radius before the module multiplier. Audible distance and AI hearing are separate.
- All eighteen native firearm shot events are packaged once, plus two potato variations. Nine proposed modded-weapon families reuse the library; no duplicate family assets. Only M9/Base.Pistol, JS-2000/Base.Shotgun and MSR788/Base.HuntingRifle remain supported firearm heads. Broad modded-gun inference is deferred.
- Balance overlay strength against JS-14's filtered-shot RMS over the overlay's 0.375-second length. Double Barrel overlay gains about 11.2 dB compared with its previous unity mix. A common headroom adjustment prevents clipping; the overlay itself is never low-pass filtered. Linear wet points remain 0/0%, .04/100%, .09/100%, .18/25%, .69/0%.

## Verification

2,844 assertions, 50 runtime Lua files, 421 native translation keys and 146 package files pass. Native write/read completed in 92.6/92.0 seconds. See RELEASE.md and diagnostics/v0.2.22 for source/native/install evidence. Tests cover bounded reload cues, cancellation, Autoloader silence, suppression beyond four copies, last-module removal, atlas option restoration, native audio/item/loot registration and actual save/reload. Art/firearm-audio/validation.json records OGG decoding, source/package hashes, HTML links and JavaScript syntax. GPU rendering, simultaneous playback and audible quality require the test below; headless validation does not prove them. Existing SP-only and aggregate-density/clock limits remain.

## Quick combined test

1. Restart Zomboid and confirm **0.2.22**. Enable diagnostics and 3D ground items. Use a powered potato turret with reserve potatoes; fire twice. Listen for one reload sequence between shots.
2. Install one Suppression Module and fire, then install a second and fire. Both should use the muffled/layered shot without doubled playback. Remove both and confirm the ordinary shot returns. Hearing reduction is separate from audible loudness; logs record the effective radius.
3. Mount an M9 with a magazine and 9mm reserve. Add Detection, Firing and 360, enable automation, and spawn a few zombies around it. Check that the gun stays visible throughout turning and the muzzle follows its aim. Fire once with Suppression installed as well.
4. Try the JS-2000 shotgun and MSR788 rifle with matching reserve. Empty their loaded rounds to hear native reload and pump/bolt cues. Add Autoloader: loading delay/sound disappears, while required pump/bolt cycling remains.
5. During a slow reload, remove the battery with no grid/generator power available. Reload audio should stop; restoring power should resume normal operation. Remove/swap a head and confirm no old reload sound remains.
6. Leave supplies and Suppression installed, pick up/redeploy, then save/reload. Check contents and effects remain; fire two nearby turrets and report any flicker, overlapping audio or error counter increase. Send **Test complete** for console review.

Unfinished earlier mechanism/persistence checks are carried into this test, not marked passed. No Workshop upload has occurred; cumulative notes remain pending.
