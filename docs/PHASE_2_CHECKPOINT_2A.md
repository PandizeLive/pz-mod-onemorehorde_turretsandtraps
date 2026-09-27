# P2C2a — visibility correction and reinforced Spike Barrier

Status: queued; no runtime changes or new installation in this planning update. Visibility correction requested after the 0.2.6 test; reinforcement recipe/progression was already approved under C25/C26. Recommended implementation reasoning: High because vision, corner pathfinding and persisted tier state must agree.

## First: close the basic-barrier regression

- Allow normal line of sight through fronts and end caps, including joined corners and saved barriers. Preserve walking collision, zombie blocking, native vault controls and thump ownership. Treat this as expected behavior, not another Sandbox toggle.
- Verify native object and grid vision separately against the installed B42.20.4 code. Transparency must not remove the wall metadata required by the corner pathfinder solution.
- Review the three interrupted vault results and one native-entry timeout from the completed test. Fix confirmed tracking/transition faults; do not replace native trip behavior based on ambiguous result labels.
- Repeat focused live visibility, corner, completed Repair and save/reload acceptance. [0.2.6 evidence](TEST_v0.2.6.md) remains partial.

## Then: implement the approved reinforcement

- Upgrade an existing barrier with Carpentry 3, two additional planks, eight nails and a retained hammer; award 30 base Carpentry XP once.
- Default reinforced damage: 25 per eligible thump. Default maximum durability: twice the basic maximum (200 at current defaults). Preserve the amount of existing damage during upgrade; reject repeat upgrades.
- Keep the existing 1x2 outline, ownership and independent per-item health. Preserve tier through save/reload and recovery; never silently return a basic item for a reinforced barrier.
- Add useful reinforced damage/durability Sandbox controls under Spike Barrier, with concise tooltips. Exact representation of the durability control is an implementation choice; no inactive settings.
- Basic pickup/free Repair and five-item bundle behavior remain governed by C32. That approval explicitly covers basic barriers. Settle reinforced repair/recovery condition and bundle handling before those dependent transactions are implemented; document a recommendation at that point.
- Reuse technical placeholders. No new art direction or unapproved recipe changes.

## Checkpoint gates

Smallest checks first: native visibility/collision probe; upgrade material/XP transaction and cancellation; independent tier/health persistence; then the focused owner SP test. Do not call this complete until vision is visibly restored and outstanding basic service/save evidence is resolved. Multiplayer and turret modules remain separate checkpoints.
