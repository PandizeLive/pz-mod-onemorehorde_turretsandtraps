# 0.2.68.1 - Corrective XP and interface build

Approved C467 on 2026-10-25; coordinates with Trait Shop 0.9.1.1 and Horde/Cure 0.6.16.7. This fixes the C465/C466 owner test findings without changing saved loot weights or ordinary combat tuning.

- Refresh the same character's defense reward identity when native single-player startup changes its username. Preserve account, life, balances and duplicate-death handling.
- Guarantee1XP for a final eligible positive recipient share below 1, after merging faction/assist portions. Bank that exact amount and deliver once; zero and rejected shares remain zero.
- Bounded normal reward summaries and opt-in details identify attributed, paid, banked, rejected and delivered events. Independent Traps/Turrets toggles apply to their own diagnostics. Group Debug Logs before Debug Tools, with matched package prefixes and concise descriptions.
- Keep Custom loot editing with a visible numeric field, responsive placement and invalid/blank-input protection. Preserve exact existing saved/LootLab weights.
- Reuse the native electronics manual icon for Turret Specialist.
- Prevent rotary acquisition of grounded, knocked-down, ragdoll and getting-up targets. Reject Controller placement on solid furniture and occupied OMH floor devices through the shared native placement callback.
- Show colored Run Options score factors: Checkpoints(x1.0), Trait Shop(x0.5), Turrets & Traps(x0.2). Remove the assistance wording.
- Refresh Horde's T&T settings baseline, including both independent packages, inactive legacy fields, ammo modes and effective per-head cone defaults. Unknown changed coupled settings still require review; historical flags remain.
- Approve verified ModLoadOrderSorter_b42, ModComparer, 3019672735/ModComparer and PixelStrikeIndicator IDs. Equivalent additional originals/forks need identity verification; firearmmod remains unapproved. Denied remains the official-run exclusion wording.

Normal Zombie Kill XP 2 at 50% defense rate gives 1 XP per solo defense kill. Seven ordinary turret kills plus two ordinary personal kills yield11 XP. This is a production-code replay result, not an owner live test or retroactive award.

[Verification and short owner checklist](TEST_v0.2.68.1.md). No Workshop upload, forced settings reset, historical score rewrite, hosted LootLab update or new owner save mutation.
