# 0.2.34 — combined owner test

Restart into a fresh single-player debug world with both entries and default Sandbox values. Crafting cheat is fine; disable Instant Actions for timing and God Mode for injury checks. This replaces the held 0.2.33 checklist, not the waived split regression.

1. **Menus/crafting:** confirm **0.2.34**. Check collapsible recipe families, Pack/Unpack and Install Trap labels; craft the three Improvised components. Panel/basic bed/reinforced bed weights remain **2/3/4**.
2. **Expansion:** open Manage and swap kits with modules unloaded: None/Improvised/Small/Medium/Large show **2/4/8/12/16** slots in two rows. Install Detection and Firing; a second version of either role must be rejected.
3. **Automation:** use improvised Detection/Firing on a loaded, powered potato turret. Detection reaches **4.5 tiles** at default range; manual fire reaches **6**. Temporarily set failure chance to **100**: automatic attempts click and wait without spending ammo/power; manual fire still works. Restore **15**.
4. **Placement/service:** attach a panel to a fence and place a bed directly behind it. Time placement and pickup/removal at **5 seconds each**; damaged defenses still repair in **10**. Moving cancels safely.
5. **Movement:** walk/run through beds—brush animation, safe walking; noclip bypasses effects. Sprinting can trip and injure. Lead a few zombies over beds: forward trips, damage once per fall, and recovery to standing.
6. **Load/save:** run your previous heavy turret/module setup, then save/reload. Contents, kits and charge persist. Report any noticeable pauses, the step that failed, and say **Test Complete** so the console can be reviewed.

Status: pending owner test. Automated/native checks do not mark these rendered results passed.
