# Quick combined test — 0.2.31

Owner ready on 2026-10-07. This replaces the longer checklist and includes the remaining Bed Spikes test. Results are still pending. Exact recipes, timer edge cases and package isolation already have automated/native coverage; do not repeat those checks manually.

**Setup:** Restart; confirm **0.2.31**, use a fresh solo world with **Traps + Turrets**, and use debug/build cheat. Keep turret diagnostics ON, detailed logging OFF. Have a hammer and pliers. Use ordinary single-panel doors.

1. **Build and move:** Place barbs on a wall, fence, door and window; rotate a preview. Open the door: barbs follow it. Open/smash the window: barbs stay on the frame with their own 50 HP. Build both Bed Spikes variants; walk/run across both halves: hand-clearing, safe walking, possible scratches when running.
2. **Fight:** Lure zombies against/across barbs, then onto beds with a potato turret firing. Barbs hurt only on exposed contact (10 every two seconds, one durability wear). Beds trip randomly; fresh falls deal 20/50 damage and six wear. Zombies already down should not keep taking spike damage or immediately trip again after rising.
3. **Service and save:** Repair damaged window barbs and a bed; cancel one service by moving. Remove one barb section; pick up/redeploy one bed without duplication. Save/reload with another damaged window section and reinforced bed: placement/condition should persist. Destroy a backing: its barbs should disappear.
4. **Stress:** Run your heavy turret/module/zombie setup with active barbs for two minutes. Note pauses, then use **OMH.cmd → diagnostics**. Send **steps 1–4: OK or issue**, approximate pause frequency, and any screenshots of problems.

**Test now.** Report obvious failures immediately; no need to finish after a blocker. Client movement, contact, persistence presentation and smoothness remain unaccepted until results arrive. The old 0.2.29 test waiver remains intact.
