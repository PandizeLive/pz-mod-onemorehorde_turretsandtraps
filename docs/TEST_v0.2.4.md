# 0.2.4 owner test: failed traversal/approach acceptance

Captured `console.txt` and installed evidence in `diagnostics/captures/20260927-145648-1661/`. Logs confirm loaded version 0.2.4. The owner supplied a desired collision perimeter and GIF showing a stalled pickup approach and a zombie entering the apparent enclosure.

Eleven explicit vaults completed. One non-God-Mode front crossing logged an injury after a successful animation; this confirms the late scratch behavior rather than a native trip. One Repair completed in ten seconds (91 -> 100). No pickup action-start was recorded, supporting an approach failure. The unrelated stock/PZ Optimizer startup warnings in this capture are not attributed to OMHTT without matching evidence.

Review found disconnected native edges hidden by full-tile marker outlines, missing native-control integration, after-animation injury timing, and generic furniture approach routing. The former ledger also prohibited perpendicular edges sharing a corner tile, preventing some closed layouts. These are logic/interaction failures despite prior synthetic checks passing.

0.2.5 implements the owner-approved correction; see [scope and full owner test](PHASE_2_CHECKPOINT_2_VAULT_REPAIR.md). 0.2.4 is not accepted. Earlier service success does not certify pickup or all collision layouts.
