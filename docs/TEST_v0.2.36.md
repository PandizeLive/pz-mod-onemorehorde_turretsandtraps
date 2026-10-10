# 0.2.36 focused owner test

Status: pending. Test normal costs with Build Cheat off; use the existing fresh test world. Do not repeat the old full regression round.

1. Restart and confirm **0.2.36** in the developer menu. In crafting **list view**, open OMH: Traps / OMH: Turrets: expand/collapse **Normal, Reinforced, Packed**. Building should have Normal/Reinforced, with no Packed group.
2. From Building, place two carried traps consecutively without reopening Place Trap; rotate between them. With materials for one more, click the next location to craft/place it. Right-click to cancel. Repeat consecutive placement briefly with Barbed Panels and a loaded turret; its contents must survive.
3. Lure a few zombies over Bed Spikes. They should **collapse forward locally**, take fall damage and get back up if alive. Listen for trip/landing/impact sounds, without repeated hits or sound while lying down.
4. Walk/run/sprint through the bed once: brush-through and player tripping should remain unchanged. Report any failure, then say **test complete** so console.txt can be captured and checked against the loaded version.

Automated: 3,880 assertions, native save/reload and Traps-only/Turrets-only/both startup pass. For evidence see [release state](RELEASE.md) and [patch scope](PATCH_v0.2.36.md). Rendered/audio acceptance is not established by automated passes. Any owner findings must be recorded here and mirrored to GitHub under C108.
