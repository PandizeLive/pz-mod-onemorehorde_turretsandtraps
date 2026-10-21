# Test 0.2.59

## Verified development evidence

- Installed-game Kahlua regression suite: **26,119 assertions**; **265** compiled runtime/translation files; **1,123** native translation keys.
- Native dedicated write and fresh-process read pass in **112.3 / 116.2 seconds**, with zero connected clients. Private carried condition, mixed Bed tile recovery and existing turret/Controller state survive the native persistence checks.
- Fourteen portable routes retain and consume the exact selected items. Native NetTimedAction extracts and serializes all constructor arguments and derives exactly **1,000 / 2,000 / 5,000 ms** from the server's allowlisted family. SP tests cover 1x/5x/30x game speed, missing/duplicate inputs and client mutation refusal.
- Native Tether service fixture confirms **30 impact + 15 pull**, **0.75-second hold**, no early/repeated pull, linked sensing override, last-unlink automatic sensing, one wear per completed cycle and pickup at exactly 37 condition. Actual crafting creates one item, retains the three tools and consumes two Wire uses.
- Existing native Tether geometry/player fixture passes **36 assertions**, including four wall orientations and constructed-wall support. Native pack parsing verifies 94 trap tiles, 30 turret tiles and 43 valid PNG pages.
- Generated packages close required dependencies; 89 shared files match; 169 Sandbox options remain unique. Traps-only, Turrets-only and combined startup pass in 95.3 / 105.6 / 99.1 seconds. Tagged installation is next.

[Write evidence](../diagnostics/v0.2.59/build-write.log) · [Read evidence](../diagnostics/v0.2.59/build-read.log) · [Validation](../diagnostics/v0.2.59/validation.log)

These tests use native objects with synthetic square/actor fixtures and test doubles for UI/timing. They do not establish rendered placement/animation, a full mapped-world placement transaction, audible acceptance, live multiplayer synchronization or endurance/performance under a large horde. No player save was edited.

## Owner test

1. Restart Zomboid and confirm **0.2.59** in the OMHTT developer/version display. Enable the regular Traps entry; the retired debug tether mod is unnecessary.
2. Find **Tether Dart Trap** in Building under **OMH: Traps**. Craft one or obtain its debug item, then place it on native and player-built walls. Rotate through all four directions and check that each panel fires outward.
3. With no links, send a zombie into its six-tile lane. Check one impact, a short hold, then retraction before the next shot. The trap should use no ammunition/battery and should not pierce, pull the character or knock it down.
4. Link a Button, then a Pressure Plate through the Controller. Detection alone must stop firing while linked. Button requests one cycle; a held plate repeats after retrieval. Release during a cycle must let it finish; removing the last link restores automatic sensing.
5. Disable a worn Tether, pick it up and redeploy it. Check that damage remains, including after save/reload. Repeat with a barrier or individual Bed tile. Repair tooltips should show one material and one tool; buttons/plates require only their tool. Tether repair uses one Scrap Metal plus Pliers.
6. Check timing at normal speed and fast-forward: trap place/pickup 2s and repair 4s; trigger place/pickup 1s and repair 2s; turret/Controller place/pickup 5s and repair 10s. Compare only active, unpaused time after walking/turning completes.
7. Check head tooltip spacing and removal of redundant “Head only” wording. Poke Floor's default damage is now 45; an existing custom Sandbox override stays unchanged.
8. When another player is available, repeat placement, linking, firing and recovery in multiplayer. Check both players see the same trap state and that no item, condition or damage is duplicated. Report the scenario and console.txt for any failure.

## Release status

All automated/native/package checks pass. Awaiting immutable tagged installation. No Workshop upload or merge.
