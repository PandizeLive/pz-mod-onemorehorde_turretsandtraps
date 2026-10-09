# 0.2.35 focused owner test

Restart Zomboid with the updated entries. Use the test world; turn off instant actions/Build Cheat for timing and ingredient checks. Keep enough inventory space for crafting output.

1. **Menus:** Crafting shows Normal / Reinforced / Packed. Building shows the corresponding placeable defenses in Normal/Reinforced, without duplicate prototypes or packs.
2. **Building:** Place one already-crafted Spike Barrier with no raw materials (five seconds). Then build Bed Spikes from ingredients: original craft cost/time/XP, followed by placement. Cancel the placement once: the crafted item stays available. A loaded turret placed through Building must retain its contents.
3. **Manage:** Check the centered 4/6/6 rows and a Large kit's 16 accessible slots. Base/Improvised/Small/Medium/Large capacities remain 2/4/8/12/16; no missing controls/items.
4. **Spikes:** Lure a few zombies over a bed. Trips should land on it, cause damage and allow surviving zombies to recover, without launching them past it.

Report only failures. Afterward capture/read console.txt through OMH.cmd; verify both reported versions and inspect errors without treating silence as proof of visual acceptance. Do not repeat the old full test or claim dense-load performance from this round.

Status: pending owner acceptance.
