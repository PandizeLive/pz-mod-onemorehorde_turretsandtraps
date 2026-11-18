# 0.2.33 — focused owner test

Restart into a fresh single-player debug world with both entries enabled. Crafting cheat is fine; turn God Mode off for the player injury check.

1. **Menus:** confirm version **0.2.33**. In Crafting **list view**, collapse/expand Spike Barrier and Bed Spikes; verify Pack/Unpack names. Turret inventory action reads **Install Trap**. Panel/basic bed/reinforced bed weights read **2/3/4**.
2. **Placement:** carry a panel, hammer and pliers. Rotate the panel preview, attach it to a fence, then place Bed Spikes immediately behind it. Expect one panel consumed and tools retained. With Build Cheat enabled, attachment should also work without tools.
3. **Player:** walk and run through the bed: both brush through; walking is safe. Noclip bypasses it. Turn noclip off, set **Player sprint trip chance** to **100**, then sprint onto it: expect a forward trip and one laceration. Restore **20**.
4. **Zombies:** set bed trip chance to **100** and lure a few over it: expect forward falls, one hit/six wear per landing, then recovery and five seconds without another bed trip. Restore **40**, save/reload and check defenses persist. Report **pass/fail by step** and any stuck actor or pause; stop there for log review.


2026-10-08: owner unable to attend PC; this test is held, not passed or waived. Its focused checks are consolidated into TEST_v0.2.34.md.
