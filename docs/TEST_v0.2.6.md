# 0.2.6 owner test — partial evidence; visibility defect

Owner reported Test Complete and that the barrier now blocks vision. They require seeing through it and requested including that correction in the next checkpoint. This is not full acceptance of every test step.

Capture: `diagnostics/captures/20260927-193658-4315/`. Client-ready and server-ready identify 0.2.6; installed manifest also identifies 0.2.6. No OMHTT exception/stack trace was found. Startup messages include unrelated game data errors and a PZ Optimizer configuration-write warning; this is not an error-free-console claim.

- 27 vault attempts: 24 native movement, 3 native context. Results: 23 crossed, 3 interrupted, 1 native-entry-timeout. 26 contacts settled. Front/rear/end attempts are present; three front scratches occurred. God Mode was enabled later, so subsequent no-injury results do not prove scratch odds.
- 69 front retaliation events show approximately 10 damage each; four rear strikes were blocked. No live side-thump proof is established by this capture.
- Pickup completed after ten seconds, returning one full-condition item from a 91-condition barrier with zero XP. One Repair began and was cancelled after approximately 1.95 seconds; completed repair is not proven.
- UI-phase collision overlay logging and six paired construction records are present. Logs do not independently prove exact rendered alignment or all join/removal behavior.
- No fresh save/reload acceptance is established. The capture ends with paused overlay updates, not a completed second load.

## Visibility investigation

Current installed source evidence: `IsoThumpable.TestVision` returns Blocked across a non-passable helper unless its sprite supplies the transparency route (`doorTrans`, or window behavior). `IsoGridSquare` also tests `collideN/W` against `transparentN/W` in its vision calculation. Our helper sprite initialization adds collision/wall flags without transparency metadata. This provides a concrete likely cause, to be verified with native object and grid vision probes before patching. Do not fix vision by enabling shared passability or converting the barrier into a window.

Next: [P2C2a visibility and reinforcement](PHASE_2_CHECKPOINT_2A.md). Carry the four unsettled vault results into a focused tracker/native-transition review; do not assume that interrupted outcomes are player-visible failures merely from the result label. Existing corner pathfinder protection must survive the visibility fix.
