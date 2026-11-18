# 0.2.52 verification and short owner test

## Verification

The full Kahlua/native-parser validator passes 20,510 assertions: 267 source files and 325 packaged files (118 Traps, 207 Turrets). New checks cover shared Load Order opening/reordering/applying/reopening, exact-head/stale/duplicate/incompatible requests, native table round trips, one-type magazine retention, physical/virtual reload accounting, Conservation/Impact/cooldown retention, scrap bonuses and the five reserve limits. Manage geometry is checked at 1280×720 and a constrained 600px-high viewport.

Native stock 42.21 probes verify actual firearm top-up with an extended magazine, all eight scrap script items, chosen sound events, authority publication and pickup/redeployment of saved orders. Fresh-process write/read and Traps-only/Turrets-only/combined startup results are recorded in diagnostics/v0.2.52. All325 installed/archive files and both0.2.51 backups match the immutable test tag. [Install evidence](../diagnostics/v0.2.52/local-release.json).

These are automated Lua test-double and zero-client native checks. Rendered UI, audible balance, arbitrary modded ammunition and connected dedicated/listen-server acceptance remain pending. Native map/property warnings also appear in the isolated startup environment; they are distinct from T&T callback failures. No new owner result is inferred from approval.

## Test now — five checks

1. Restart and confirm **0.2.52**. Open Manage: Expansion stays in Equipment, Ammo/Void match widths, Magazine/Reload sit below, and the whole menu is reachable. Hover a module: white unwrapped text, colored rarity.
2. Scrapshot: add ordinary scrap and gold/steel scrap, including some in Void. Open Load Order, move a type up, Apply and reopen. Check counts/bonuses; the current magazine keeps its type until Reload, then uses the new priority without losing ammo.
3. Put Large Expansion on Scrapshot: its count limit is **80**, with native weight still enforced. Fire through a reload; then try Ballista with two spear types and a partially loaded firearm's Reload.
4. Lobber: fire Makeshift and native bombs. Check the quieter Makeshift sound, shorter landed fuse, longer base shot interval and new reload cues. Rapid-Fire may still make explosions overlap.
5. Pick up/redeploy, then save/reload: confirm the head's Load Order remains. Check rotary tooltip RPM and report any clipped controls, lost ammo or missing sounds.

After the test, capture and inspect console.txt for the exact loaded version and new errors. Connected multiplayer remains a separate acceptance session; do not repeat unrelated passed gameplay checks.
