# Reliable barrier picking and independent reinforced textures

Right-clicking floor pixels or shared corners could miss a barrier or resolve only one neighbor. The menu now gathers exact identities from both visible parts/collision helpers and a bounded cursor-footprint fallback, provides distinct corner choices, and highlights the complete selected barrier on hover. Misses and selection sources are logged.

Reinforced sprites keep their saved IDs but load separate texture pages and icons, allowing owner-sourced artwork to replace them independently. Existing technical marker images are reused unchanged. No collision, recipe or balance change; native furniture pickup remains deferred.

[Scope, evidence and owner test](PHASE_2_CHECKPOINT_2B.md). Module documentation now records the eight-role inventory plan and approved Range/Velocity/Rapid-Fire stacking; no module runtime is included. Rendered acceptance remains pending.
