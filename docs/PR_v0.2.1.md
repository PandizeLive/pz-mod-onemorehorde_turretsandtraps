# v0.2.1: persistent barrier tiles and portable crafting

Constructed barriers used named sprites without stable native tile IDs, so reloading could invalidate their SpriteConfig. Register permanent native tile definitions and pack the existing arrow textures unchanged. Reconcile exact existing construction parts to those sprites, repairing their native component without resetting damage or ownership. Add part-specific restoration diagnostics.

Add Craft Spike Barrier with the owner-approved basic ingredients, knife/cleaver, Carpentry 1 and 10 base XP. Deploy Spike Barrier uses native placement/rotation to consume one finished item with no extra materials or XP. It appears alongside raw construction under Carpentry and Turrets & Traps. Encumbrance 6 is provisional test tuning. Bundles, pickup/recovery, reinforcement and multiplayer remain pending.

Validation: 270 Kahlua assertions; 14 Lua modules; 69 native translation keys; 150 ingredient mixes across both crafting routes; actual native item creation/consumption; component migration; and 16 native thumpables serialized to files and restored in a second process with sprite identity, damage, blocking and ownership intact. Native .pack parsing verifies all 16 texture entries and four unchanged PNG pages. Player rendering and actual map streaming remain covered by the [complete owner test](PHASE_2_CHECKPOINT_1B.md#owner-test).
