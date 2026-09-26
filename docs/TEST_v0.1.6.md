# v0.1.6 completed SP test review

Reviewed 2026-09-26 after the owner reported **Test Complete**. Captured [console.txt](../diagnostics/captures/20260926-165747-7874/console.txt), [capture identity](../diagnostics/captures/20260926-165747-7874/capture.json) and [structured metrics](../diagnostics/captures/20260926-165747-7874/review-metrics.json). This review changes evidence/acceptance documentation only; the installed package stays `0.1.6`.

## Confirmed results

- Exact client and authority version `0.1.6`, game B42.20.4 b0bbce05d5, SP. One fresh session started with zero slots and nextId 1. All 707 structured diagnostics report this version; none were suppressed.
- Five barriers placed as two-part footprints, plus one potato turret. All 31 queued texture checks resolved; no missing-texture timeout appears.
- **28 rear strikes were blocked from retaliation.** Rear attacks still wore barrier `test-2` down from 100 to 95 HP, preserving the intended tradeoff.
- **16 front strikes applied damage:** fifteen full hits at approximately 20 display units and one 1.321 finishing hit capped by remaining health. One barrier kill. Front hits were observed at facings 0 and 8; no side-classified damage event was captured.
- Inspections of `test-2` at both `8345:11676:0` and `8345:11677:0` agreed on ID, condition **95**, and revision **6**. Six aggregate health updates used two parts, with no observed spontaneous healing.
- Five successful rotations across three barriers moved the secondary tile and updated facing. Rotation from the secondary tile returned an empty snapshot for the now-vacated tile, as designed. Two blocked rotations preserved the original state; the requester occupied the proposed destination tile, which explains their refusal. Full four-direction rotation and rotation of a damaged pair were not established by this capture.
- Eleven potato hits from twelve attempts; the other attempt correctly returned Empty. Nine full direct hits removed 0.50 HP; two finishing hits were capped by remaining health. Three requested knockdowns all reached the floor by their 1500 ms observations with StaggerBackState and no physics reaction. Five already-down skips, one chance miss and two dead-target skips were expected decisions. Two potato kills and eleven rendered impact events.
- Thirty-six comparable client/authority results agreed. Five TooFar results omitted state comparison as designed; there were no Waiting mismatches. The bounded scheduler reported a peak of four slot visits.
- No OMHTT exception or marker-wait warning. Existing base-game asset/map warnings and the PZ Optimizer configuration-file access warning are outside this mod. No unrelated files or mods were changed in this review.

## Acceptance boundaries

The captured session ends during gameplay. Its only GlobalModData save message precedes placement; there is no subsequent client initialization/reload, Remove command, barrier retire event or native destruction. This cannot establish two-part save/reload or cleanup behavior. Likewise, no side-end strike appears. The log's object flags prove configuration, not a visual walking/vaulting test.

Record this as a **partial SP pass** for front/rear damage filtering, paired placement, shared condition observation, observed rotations and potato regression. Keep side-end hits, save/reload, either-half removal/native destruction, traversal, legacy expansion, other orientations/animation transitions and connected multiplayer in their appropriate acceptance gates. No corrective runtime patch is indicated by this capture, and no complete Phase 1 acceptance is claimed.

## Remaining short SP pass

Keep the installed `0.1.6` package and Foundation Test Controls enabled, at normal game speed with Pixel Indicator scale 100.

1. Load the same test save and inspect both halves of the damaged barrier. Confirm the same device ID and shared remaining condition; no extra half should appear.
2. Bring an attacker to a short side end of the barrier. Expect 20 damage per strike, and verify you cannot walk or vault through either tile.
3. Inspect one half, choose **Set test condition to 37**, then save, exit and reload. Inspect both halves and expect the same ID and 37 condition, provided nothing attacked it meanwhile.
4. Remove the barrier through the second half. Expect both tiles to clear and neighboring objects to remain. Report **test complete**; I will review the new log. Native thump-destruction remains a separate unproven gate if this pass only uses manual removal.
