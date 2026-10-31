# 0.2.36.1 focused owner test

Historical checklist: replaced by [TEST_v0.2.37.md](TEST_v0.2.37.md); unobserved checks remain pending.

Status: no completed owner test reported. Restart into the existing fresh test world, Build Cheat off. This replaces the outstanding 0.2.36 checklist; no old full test is required.

1. Confirm **0.2.36.1**. In crafting **list view**, Turrets has base/complete turrets at root plus **Heads / Modules**; Traps keeps **Normal / Reinforced / Packed**. Expand/collapse and search once; no empty or duplicate groups.
2. In Building, turret base is ungrouped and no heads/modules appear. Place two carried defenses consecutively, then one using materials; cancel the next preview. Check a moved loaded turret retains its contents.
3. Lure zombies over Bed Spikes: collapse locally, damage on landing, then recover if alive. Listen for trip/landing/impact cues; no repeated damage/sound while prone.
4. Walk/run/sprint across once to confirm player traversal still behaves as before. Report failures and say **test complete** so console.txt can be captured and checked.

Automated checks and installation evidence are in [RELEASE.md](RELEASE.md). They do not prove visible movement, audible timing, mouse interaction or absence of client pauses. The wider [review findings](REVIEW_v0.2.36.1.md) remain separate from this patch's acceptance.

## Runtime observation, 2026-10-09

Root OMH.cmd capture `20261009-211037-3606` confirms both 0.2.36.1 packages on 42.21 at console line 3436. Since that marker: 20 summarized bed-trip events and 18 bed-fall/damage events; no ERROR, Exception or STACK TRACE matches. This supports runtime activation only, not visible collapse/get-up, sound quality or frame smoothness. No unmentioned pass or owner test completion is inferred. [Structured observation](../diagnostics/v0.2.36.1/runtime-observation-20261009.json), console SHA-256 `5c070a16f193a72b80e1ecfbbb489ac1e6bf5378b6b101e4022e44432bd3caa8`.
