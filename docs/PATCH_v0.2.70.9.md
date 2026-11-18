# 0.2.70.9 - C512 native ownership correction

Owner selects C511 **1A**: correct both checks, test real engine ownership and trace barrier strikes before packaging. [Failed connected test](MULTIPLAYER_FEEDBACK_C511.md).

## Correction

`DefenseContactServer.observe` and `BarrierRetaliation.command` now compare the authenticated sender with `IsoZombie.getOwnerPlayer()`. They retain the connection-presence, identity, distance, freshness, consent and replay checks. Neither calls the inaccessible `UdpConnection.havePlayer` method. The client already sends as that exact owner player; no authorization is broadened.

Remove permissive `havePlayer` methods from the replay fixtures. A stock-engine probe constructs real IsoZombie, IsoPlayer and UdpConnection objects, reproduces the old exception through the game's actual Lua environment, then runs the production contact and barrier handlers. It verifies owner acceptance, foreign/former owner rejection, handoff and duplicate suppression. Fixture setup assigns native identity/state in Java; geometry lookup and contact/damage sinks are isolated test adapters. This proves the Lua/Java ownership boundary, not connected networking or rendered animation.

The barrier replay now starts at `BarrierContact.update`: selecting the claw animation, left marker, serialized client report, server validation, V2 owner damage and acknowledgement. An unchanged marker cannot hit again; the right marker permits the next strike; leaving restores the prior animation. Marker values and actors are replay fixtures, not claims of rendering the native claw clip.

Diagnostic Logging gains bounded summary counters for barrier contact selection, unresolved collider lookup, report sent/received/accepted and positive confirmed damage. These stages distinguish missing animation/reporting from server admission or damage failures in the next connected capture. No new timer, polling loop, wire command, Sandbox setting or balance change.

## Release and limits

No new world is required; update/restart the server and both clients together. Damage, resources, Horde Night and XP authority remain server-owned. Fragment visuals are unchanged and recorded as passable; they are not reclassified as fully accepted.

[Verification and short test](TEST_v0.2.70.9.md). The real native probe intentionally executes the old failing call once; that labelled expected exception is separate from the corrected path. Zero clients connect to automated native probes. Connected acceptance remains pending.

The new cumulative changelog follows the confirmed 0.2.70.8 content upload to item3828638252; [receipt, uploaded note text and 629 file hashes verified](evidence/c512-upload-baseline.json). This patch does not upload Workshop content, change the live server or edit sibling projects.
