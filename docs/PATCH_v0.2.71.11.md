# 0.2.71.11 multiplayer test build

When several defenses hit the same zombie, two already-queued hits can now share one acknowledgement. The first hit on an idle zombie still leaves immediately. Each hit keeps its own expiry, damage display and source. The server assigns a kill to the hit that finished the zombie.

Spike Barriers now look up a reported attacker by its zombie ID before searching nearby squares. They still validate the owner, floor, distance, collider and strike direction.

The six combat files match the tested C550 prototype. This update adds no save migration or new Sandbox settings. The Workshop draft carries forward the pending changes since the confirmed 0.2.71.8 upload to item 3828638252. [Release checks and two-player retest](TEST_v0.2.71.11.md).
