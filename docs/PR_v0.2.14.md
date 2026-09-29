# 0.2.14 — core turret automation and module loot

Turrets now use a placement-locked 90-degree forward cone. Working Motion Detection tracks zombies; adding Firing enables powered automatic shots through the existing ammo and timer checks. Filter selects target priority, and 360 unlocks all directions. Manage controls automation/priority, while placement and selection show effective coverage.

The four active modules are loot-only in electronics/mechanic/military-electronics pools. Grouped Sandbox controls expose cone angle, detection interval, automation and global/per-module loot multipliers. Loot changes apply after world reload to future container generation. Future stat modules and multiplayer remain deferred.

[Full scope, evidence, limitations and six-step combined test](PHASE_2_CHECKPOINT_3D1.md). Includes held 0.2.13 head alignment/Magazine/balance changes. Native save/read, loot parsing and automated regression checks pass; player acceptance remains pending. No remote push or Workshop upload.
