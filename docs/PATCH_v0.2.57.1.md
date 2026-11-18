# Patch 0.2.57.1 — owner-test corrections (C340)

The 0.2.57 owner test exposed unstable Controller power, confusing linked-turret power, oversized module tiles and inconsistent menu framing. This correction keeps the existing layout and grey theme.

- Removed window locking, pinning and collapse. Close, dragging and resizing remain; title/footer strips and corner grips use explicit dimensions rather than stretched chrome.
- Retained centered 4/4/4/4 module ordering with compact tiles, bounded between square and 108 pixels wide. Remove To and Set Aim share position, width and height.
- Separated Connections title/actions from column headings, with dark inset lanes, bordered group headings and clearer section contrast. Corrected the broken no-ammo placeholder.
- Fixed fractional Controller debit accounting: floating-point residue could exhaust the debit loop and falsely report no power. Actual battery deductions and shared-bank authority remain intact.
- Linked turrets no longer briefly accept manual On while their trigger is released. The menu explains trigger-controlled power; button/plate actions still finish the accepted turn/reload/shot before shutting down. Manual Off still cancels.
- Barbed supports recognize native WallN/WallW on player-built walls, without broadening acceptance to arbitrary furniture or damaging the host during placement.
- Poke Floor now has a white inset technical outline and POKE label, with the raised state retaining its height offset. The button plays the native LightSwitch sound when pressed.
- Single-player service and placement timers follow game speed. Pickup actions use five seconds at normal speed, including Poke Floor; repair actions retain ten seconds. Poke multiplayer service uses the native 50 duration units per second. Pickup help now reports five seconds.

## Timing boundary

Single-player portable placement is five seconds and responds to fast-forward. Multiplayer portable placement still delegates to the native authoritative BuildAction. Inspection of the installed game's Java bytecode shows its duration is computed from Carpentry/Handy (base 200 units, five units less per Carpentry level, fifty less for Handy, twenty milliseconds per unit), ignoring recipe/custom placement time. Setting a recipe duration therefore cannot guarantee five seconds. Exact five-second multiplayer placement remains open; it requires a separate placement-transaction change. This patch does not claim that requirement complete.

## Evidence and delivery

The inspected console loaded 0.2.57 and showed repeated turret enable/disable pairs shortly after reload. No new OMHTT Lua exception was identified in that log; unrelated startup translation/font warnings are not evidence of this power fault. The Controller arithmetic issue was reproduced independently and verified with 2,000 repeated native battery debits. Native wall fixtures cover three player-built tiers and four faces.

See [test record](TEST_v0.2.57.1.md). Rendered UI/audio and connected-player acceptance remain pending. No LootLab tuning, merge or Workshop publication is part of this correction.
