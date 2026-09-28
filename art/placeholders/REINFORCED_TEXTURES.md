# Reinforced barrier texture inputs

P2C2b separates reinforced textures while preserving native sprite identities. These are copies of the authorized temporary white direction markers, not final art or a design brief.

Source directory: Contents/mods/OneMoreHorde_TurretsAndTraps/42.20/media/textures/

| Source PNG | Facing | Native part IDs |
| --- | --- | --- |
| OMHTT_ReinforcedBarrier0.png | East | omhtt_barrier_01_20 / 21 |
| OMHTT_ReinforcedBarrier1.png | North | omhtt_barrier_01_22 / 23 |
| OMHTT_ReinforcedBarrier2.png | West | omhtt_barrier_01_24 / 25 |
| OMHTT_ReinforcedBarrier3.png | South | omhtt_barrier_01_26 / 27 |
| Item_OMHTT_ReinforcedBarrier0.png | Inventory/bundle icon | Separate item texture |

Current technical canvas is 128x256 RGBA; both parts reuse the heading page, as before. Final distinct left/right art or different dimensions/offsets requires updating the pack layout intentionally. Do not change saved sprite IDs. The building UI uses OMHTT_ReinforcedBarrier0; world previews use the tier's native IDs.

After owner-sourced artwork replacement, rebuild with tools/build_barrier_tiles.py, validate the package, and restart the game. World textures are embedded in OMHTT_Barriers.pack; replacing standalone PNGs alone does not update the embedded pages. Placeholder-only grayscale validation will need revisiting when final owner artwork is integrated.
