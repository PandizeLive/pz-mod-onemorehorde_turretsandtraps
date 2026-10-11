# 0.2.39 focused paired Concertina test

Automated checks are separate from rendered owner acceptance. The previous lag comparison is closed and is not requested again.

1. Start a fresh SP test world with Traps enabled; confirm 0.2.39 in the developer menu. Rotate and place Concertina: one item makes two linked tiles; an obstructed second tile must block placement.
2. Lead zombies over each half. Both should slow/damage them; crossing the seam must not cause an extra immediate hit. The durability shown from either half must match. Walk across the seam safely, then run through it to check the existing brush/injury behavior.
3. Damage the wire, repair from either half, then save/reload. Both halves must remain linked with matching durability. Pick up from the second half: both disappear and exactly one item returns.
4. Redeploy and let zombies deplete it: both halves disappear together. Report any failure; capture/review console.txt after the test to verify loaded version and errors.

## Automated/native evidence

Focused Kahlua checks pass 3,962 assertions, including all rotations, seam timing, reload order, unloaded partner preservation, shared repair, pickup replay, external half removal, late orphan cleanup and final-activation breakage. Native object persistence and independent package startup are in progress; installation and owner acceptance are pending.

The initial fixture runs exposed an overlapping-anchor lookup ambiguity and missing mock floor methods. The anchor lookup now selects the newest matching anchor; mock floors implement the engine methods used by placement. Those failed runs are not pass evidence.
