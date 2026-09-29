# 0.2.11 — Integrated turret gameplay and usability

The 0.2.10 cube probe flickered and left the actual turret workflow unfinished. This update integrates a stationary tile base and installed model head into real turrets, adds see-through 1x1 base collision and adjacent Manage/pickup, and removes the barrier placement outline from turret previews.

Crafting/Building now use OMH: Traps and OMH: Turrets. Turret recipes retain only screwdriver plus wrench/pipe wrench. Defaults become 85 potatoes total, a one-round magazine, one-second reload and half-second cooldown running concurrently. The shared cycle persists on the actual head; the Manage panel opens native drag/drop inventory and shows firing state.

Validation: 1,588 Kahlua assertions, native model import/recipe transactions, four-sided collision/vision/reach/pathfinder probes, both render-mode SpriteConfigs and native fresh-process persistence. Visible GPU behavior remains pending the single combined owner test. Module effects, automatic targeting and multiplayer stay deferred. Nothing published.

See [checkpoint and complete test](PHASE_2_CHECKPOINT_3_USABILITY.md).
