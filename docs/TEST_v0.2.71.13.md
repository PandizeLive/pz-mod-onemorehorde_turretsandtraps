# 0.2.71.13 multiplayer retest

The local and dedicated-server captures identify 0.2.71.12. The server recorded tether cycles returning to idle. Its log does not contain Player B's audio handles. The installed game's FMODSoundEmitter.playSound(String) sends PlayWorldSound from a free client emitter before starting local playback. T&T had already sent its own cue to each nearby client. A peer could therefore start another loop that the trap's stop handler did not own.

- **Tether Dart.** Recipients use local-only playback for device cues. A reel has a tracked handle whose lifetime is capped by remaining distance divided by return speed. The normal stop still ends it earlier. Owners can pick up an active dart within reach. The server rejects the former manual toggle and existing saved disable flags no longer hold the dart off. Linked trigger behavior and condition carry over.
- **Turret Base and T&T Controller.** Both use one tile check for furniture and existing devices. Portable placement rechecks it at completion. Native tests covered chair and potted-plant sprites, a Controller and a pressure plate, grass and ferns, with build cheat on and off.
- **Poke Floor.** A new floor has no loot container. Older placed floors release any items in their legacy inventory onto the same square when they load. On placing a legacy portable floor, the owner recovers its contents into inventory or onto the square if full. Failed delivery restores the item to its original container. An empty mechanical floor still supports repair and pickup.
- **Private access.** The reported player was an admin. The common access policy permits admins to edit Private devices. The regression uses an ordinary non-owner to check read-only inspection, native withdrawal, Manage removal and a direct server completion. The admin override is also checked.

The preceding changelog snapshot matched the confirmed content upload for unlisted Workshop item 3828638252, version 0.2.71.12. The new draft contains only this patch's player-facing changes.

The release validator passed 51,980 assertions. The native placement matrix passed 148 cases including SP/server branches and build cheat on/off. The legacy-floor regression rebinds a placed trap containing a real car battery and verifies that the same item is on the original square and the inventory is gone. During development this caught the engine rejecting a null container setter. The corrected recovery uses the native container-removal API after contents are safe. A read run also timed out during shutdown. The subsequent dedicated reload completed the checks and shut down cleanly. Traps, Turrets and both together passed independent startup checks with zero connected clients.

## Connected check

All 642 tagged files matched the archive, local install and Workshop stage. The publisher preflight passed for unlisted item 3828638252. [Delivery evidence](evidence/c558-delivery.json)

Use the existing test world. After uploading with CMD option 3, restart the server and both clients. The audible result still needs two connected players.

- Place bases near furniture, devices and tall grass.
- Join during retraction, then pick up the firing dart.
- Check Poke Floor loot tabs and recovered items.
- Try both withdrawal paths as a non-admin non-owner.
