# 0.2.53.11 — Pressure-plate visual feedback

C309, 2026-10-18. Owner requests implementation of inset, depressing pressure plates.

- Inset pressure plates
- Press/release feedback

The neutral placeholder is about 85% of a tile wide. Its top drops from six pixels above the floor to one pixel while activated, then rises on release. Two static native sprite states provide immediate feedback without a render/tick animation loop. The visual margin does not shrink full-tile activation, change trigger filters or alter power/signals.

New placements preview the inset plate. Existing plates convert on load/bind, retaining exact identity, ownership, links, health and native non-thumpability. Authoritative state transitions update the native sprite and private location index; unchanged held states send no repeated updates. Native sprite replication carries the appearance to other clients and late joiners. Both independently selectable packages contain the two images; each native placement direction has its own required sprite identity, sharing the same raised image. The original placement entity remains available only for loading old objects; both current placement routes use the new definition, which also recognizes the pressed state for native save/reload.

[Verification and short test](TEST_v0.2.53.11.md). R4C1 visual correction only; R4C2 Poke Floor remains next content. Rendered and connected acceptance remain pending.
