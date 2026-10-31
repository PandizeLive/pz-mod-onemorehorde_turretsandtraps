# 0.2.39 focused paired Concertina test

Automated checks are separate from rendered owner acceptance. The previous lag comparison is closed and is not requested again.

1. Start a fresh SP test world with Traps enabled; confirm 0.2.39 in the developer menu. Rotate and place Concertina: one item makes two linked tiles; an obstructed second tile must block placement.
2. Lead zombies over each half. Both should slow/damage them; crossing the seam must not cause an extra immediate hit. The durability shown from either half must match. Walk across the seam safely, then run through it to check the existing brush/injury behavior.
3. Damage the wire, repair from either half, then save/reload. Both halves must remain linked with matching durability. Pick up from the second half: both disappear and exactly one item returns.
4. Redeploy and let zombies deplete it: both halves disappear together. Report any failure; capture/review console.txt after the test to verify loaded version and errors.

## Automated/native evidence

Focused Kahlua checks cover all rotations, seam timing, reload order, unloaded partner preservation, shared repair, pickup replay, external half removal, late orphan cleanup and final-activation breakage. 3,962 Kahlua assertions, 94 compiled runtime/translation files, 574 native translation keys and 23 packet serializations pass. Native write/fresh-process read pass in 150.6/130.0 seconds, preserving both wire objects and one shared ledger at 47 HP. Traps-only/Turrets-only/both startup pass in 134.6/117.2/124.1 seconds. Independent checks cover 111 Sandbox options and 31 identical shared helpers. Installed through root OMH.cmd on 2026-10-11 from immutable `test/v0.2.39` / `b18551573d5e1db286697e2464c2d0e5edc0fd10`. All 188 source and 228 package/tag/installed/archive files verify; both previous 0.2.38.1 package backups verify. Archive SHA-256: `72fcc5fb97f80d1771b78e188cf10e8f8423cc7705c11364391d505bf1d7f862`. Rendered owner acceptance is pending. Stock asset/world-generation diagnostics remain; no mod probe fails in the passing runs. [Machine-readable release verification](../diagnostics/v0.2.39/local-release.json).

The initial fixture runs exposed an overlapping-anchor lookup ambiguity and missing mock floor methods. The anchor lookup now selects the newest matching anchor; mock floors implement the engine methods used by placement. Those failed runs are not pass evidence.


C136: the held owner checklist is superseded by the combined module/Concertina test in [TEST_v0.2.40.md](TEST_v0.2.40.md). No new owner pass is claimed.
