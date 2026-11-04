# 0.2.60 verification - C381

General validation: 26,179 assertions, 283 runtime/translation compilation checks and 1,167 native translation checks. Native write passes 148 full-construction cases across sixteen portable routes, SP/server Lua branches, BuildCheat on/off and all four Tether/Lever/Laser faces on native/player-built walls. Exact inventory ownership, replay rejection and carried condition remain covered.

Native trigger fixtures cover crafting, serialized authoritative toggle/replay, fractional Controller battery charging, crawler interruption, clear beam, bounded range, real wall/closed-door obstruction and reopening, latch restoration and 20-second Laser crafting. Native write (50.8s) and fresh-process read (52.7s) pass; the fresh process verifies Lever latch, Laser range/facing and assignment persistence. Focused Kahlua tests cover supply loss/restoration, OR links, unpowered Button rejection, day-length ratings and swept fast crossings. No players connected to these probes.

Development checks caught conflicting Button/Lever sprite identities; Lever now owns separate aliases and only reuses native frame art. Earlier fixtures reused saved placement coordinates or retained crafted items; isolated coordinates and item cleanup corrected those failures. The independent-package plate fixture now verifies physical depression separately from electrical activation. Combined startup also caught duplicate native Sandbox identities. Independent packages now have distinct option IDs, with the Traps-only fallback hidden when the common Turrets set is present. Both values persist; only the visible effective set controls consumption. Native option uniqueness and focused UI/rate-selection assertions cover this correction. Final successful logs supersede development failures, not live owner findings.

Independent native startup passes: Traps-only 47.2s, Turrets-only 45.3s, both 44.8s, with unique native Sandbox identities and correct effective rates. Final general validation includes the world-exit guard for the client overlay. Tagged installation evidence follows below. Rendered placement/beam/indicator/tooltips and connected-player synchronization remain pending; no new owner acceptance is claimed. Earlier 0.2.59.1 rendered checks remain deferred.

## Owner test after installation

1. Restart and confirm both enabled entries report **0.2.60**. Use a disposable test world; verify the prior Tether placement and Performance icons when convenient.
2. Craft/place Lever and Laser against all four wall faces, including player-built walls. Check flush placement, switch appearance, beam origin and one-second deployment/pickup.
3. Assign each trigger to a Controller with Car Batteries away from mains. Check Button, Plate and Lever links; ON Lever glows green, OFF does not. Compare Firing-only and Detection-equipped turrets, including rotary Detection.
4. Set Laser reach to 1 and 10. Cross with a player, standing zombie and crawler; confirm held/clear behavior. Close/open a door in the lane: coverage shortens/restores without the door firing it.
5. Remove Controller power, then restore it. Links remain, held inputs resume, old Button presses do not replay, and a started turn/reload/shot finishes only with available receiver resources. Check spare Car Batteries take over.
6. Save/reload with Lever ON and a custom Laser range. Check persistence, then damage/pick up/redeploy them: condition remains, links clear and Lever starts OFF. Repair uses only a Screwdriver and takes two seconds.
7. Inspect trigger inventory, world-action and Controller tooltips. Confirm rates, Minimal basic triggers/Very Low Laser at a 60-minute day, no duplicate labels and no clipping at your UI scale.
8. If multiplayer is available, repeat remote linking/toggle/range and pickup from a second client with appropriate access; confirm both clients agree and unauthorized actions fail. This is an outstanding acceptance test.


## Tagged installation

Installed from immutable `test/v0.2.60` / `362b30fcee7ac347e5986d2ce3700712f4f2f6ac`. All 330 source and 438 tagged/package/install/archive files match SHA-256; both 0.2.59.1 backups verify. [Local release record](../diagnostics/v0.2.60/local-release.json). The final client-only world-exit guard passed compilation/regression validation; dedicated startup tests do not execute client rendering. **Test now** after restart. Connected and rendered acceptance remains pending.


## Owner availability - 2026-10-21 (C382)

Owner postpones testing again and requests the next-checkpoint discussion. Installed 0.2.60 and automated/native evidence are unchanged. No new console review or gameplay result is claimed; rendered and connected-player acceptance remains deferred. Keep the complete test above for when the owner is available.
