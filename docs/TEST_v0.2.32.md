# 0.2.32 — focused owner test

Restart the game, use a fresh single-player debug world with both entries enabled, and keep God Mode off for the injury check. This replaces the remaining 0.2.31 checklist.

1. **Version and menus:** confirm **0.2.32** in the developer menu. Bed Spikes/Barbed Panel settings belong under **Traps**; default zombie bed trips and potato knockdown both read **40%**. Crafting lists the defenses; Building has no OMH choices.
2. **Craft and place:** craft a Bed Spikes and Barbed Panel (crafting cheat is fine). Inventory shows **Place Trap** / **Attach Trap**. Rotate the panel through four directions, attach it to a fence, and place the bed immediately behind it. Both should fit; one bed texture repeats and the panel has two visual states. Its Repair/Remove menu must open without errors. Turret components use **Install Trap**.
3. **Player crossing:** walk through safely with bush-like movement, then cross with noclip: no forced brush animation or injury. Turn noclip off, temporarily set **Player sprint trip chance** to **100**, and sprint onto a bed: a fall should cause a laceration once. Restore **20** afterward.
4. **Zombie recovery:** temporarily set bed trip chance to **100** and lead a few zombies across. They should fall, take one hit/six durability wear per landing, get back up and move again; no immediate repeat trip during the five-second recovery protection. Restore **40**, save/reload, and confirm both defenses remain. Report **pass/fail by step**, plus any pause or stuck actor; stop there for log review.
