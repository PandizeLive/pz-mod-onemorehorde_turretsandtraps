# 0.2.61 verification - C389

General validation passes **26,293 assertions**, 290 runtime/translation compilation checks and 1,177 native translation checks. Source/package comparison covers 334 source and 445 generated files. Final native write (52.5s) and fresh-process restart (54.9s) pass. Tagged installation is recorded below when complete. Traps-only (51.0s), Turrets-only (51.8s) and combined (59.5s) native startup all pass. No connected-player or rendered acceptance is claimed.

## Focused owner test

1. Restart and confirm both enabled entries show **0.2.61**. Open Controller, turret Manage and Tether menus; check target labels/tooltips and compact resizing without footer overlap.
2. Set Controller to Other Factions. Confirm an inherited defense updates, an explicit Zombies Only override remains, and clearing the override restores inheritance. Save/reload and check those settings.
3. On a disposable multiplayer test server with PvP enabled, compare owner, faction mate, different-faction and factionless players. Other Factions must target outsiders and zombies; Zombies Only must deliberately acquire only zombies. Change factions while a turret is aiming.
4. Check PvP disabled, both players' safety enabled, non-PvP zones and an offline owner with a safety-enabled target. Deliberate targeting and player turret damage must obey those protections. Keep ordinary game-server rules in mind; physical faction collateral is not universally immune.
5. Compare one-shot firearm, shotgun/Scrapshot volleys, Ballista and Lobber hits with/without armor. Check reduced limb injuries, no forced player knockdowns/Execute, and shared wound-roll limits. Compare both rotary heads' recovery. These are balance observations, not a promise of exact global-health loss.
6. Test Tether unlinked automatic targeting versus linked trigger operation. Confirm Laser, pressure triggers and passive/Poke traps retain their physical behavior. Zombie combat should retain its prior damage and power use.
7. From a second client, confirm authorized target changes synchronize and unauthorized changes fail. Check injury delivery once on the struck player's client and save/restart during a volley. Send console.txt after testing; connected acceptance remains outstanding until observed.

## Development findings

An early private-record lookup used the wrapper rather than its records table; the acquisition test caught that before release. The first native run found an outdated injury fixture without a shot context. The next run reached the native player APIs and exposed the fixture's lowercase setHealth call; it now uses the verified native SetHealth method. These failures are not counted as passed runs. Final successful evidence supersedes the failed fixtures, not owner findings.

## Coverage and limits

Focused regression cases exercise real incremental player acquisition, inheritance/override changes, current factions, offline-owner safety, PvP disabled, protected actors and non-PvP zones. Injury cases cover each selected profile, proportional shotgun/Scrapshot pellets, cross-turret wound throttling, separate Sandbox tuning, armor, rotary recovery, invalid/replayed/wrong-recipient injury messages and native table round-trips of shared saved budgets. Existing zombie/Horde, resources and independent-package tests remain passing.

Native 42.21 fixtures verify the current faction/username/safety/non-PvP/clothing/BodyPartType APIs, local limb damage and server-selected capped injury envelopes. Injury envelopes are captured by the fixture; no remote client was connected. The fresh-process policy fixture checks packed Controller exclusion and restored inheritance on redeployment. These are native object tests, not proof of rendered UI, live client injury synchronization or gameplay balance. The wider R1C3/R3C7/R5C1 acceptance work remains open.

An additional audit corrected armor-blocked rotary contact recovery. Its new regression passes without consuming a wound roll. Source edits preserve existing line endings, and the cumulative Workshop draft retains unrelated pending changes.
