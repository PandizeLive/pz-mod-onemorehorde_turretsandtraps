# 0.2.11.1 — Manage startup and base alignment repair

Manage could capture a nil server-module reference during client loading, then crash when its timed action started. Resolve the world module when interacting, after server initialization. The regression harness now loads the panel before the server module and exercises its later action, status, Fire and close callbacks.

The base-only sprite's ground center was 16 pixels above native tile center. Correct its projection from (64,208) to (64,224), preserving the native sprite IDs and the owner's separate head calibration. Existing bases update on restart without redeployment.

Validation: 1,589 Kahlua assertions, 34 compiled runtime files, 206 native translations, native head import, texture-pack identity checks and a pixel alignment regression. The added load-order guard fails against 0.2.11 and passes after the fix. Native smoke evidence is in diagnostics/v0.2.11.1. Visible alignment and real UI acceptance remain pending.

## Focused owner test

Restart single-player after installation, with native 3D items enabled. Keep the existing world and turret; no new world or recrafting is required. Native item spawning is fine to supply a head, potatoes and a charged car battery.

1. Confirm 0.2.11.1. Inspect the existing empty base and its placement preview: both should sit on the ground, with the same one-tile collision.
2. Right-click Turret → Manage from beside it, then from a few tiles away. Expect an adjacent approach, both inventory panes and the status panel, without an error.
3. Drag in a potato head, potatoes and a charged car battery. Expect the installed head and loaded/ammo status; Fire should work with a nearby valid zombie.
4. Close/reopen Manage, then walk away with it open. Expect normal reopening and automatic status-panel closure; save/reload should retain supplies. Report “Test complete” and capture logs through OMH.cmd → 6; include an image if the base still appears raised.
