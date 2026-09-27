# Connected barrier outlines and native vault corrections

Spike Barriers now block their front and exposed outer ends while leaving the rear open. Touching straight runs and perpendicular front joins omit internal end caps; removing a section restores the surviving ends. Each 1x2 barrier keeps its own condition and recovery identity.

The collision overlay now uses the UI render pass. Native run/sprint vaults use the player's collision feeler and track root-motion contact, fixing missed automatic triggers and scratch settlement. Pickup, repair and retaliation resolve the new edge objects. Existing edge-based barriers migrate without resetting condition; old layouts may need repositioning where their true facing edges do not meet.

Validation: 1,433 Kahlua assertions, native object write/read, both pathfinders at perpendicular corners, and cardinal vault parameter checks. Rendered SP acceptance remains pending. [Full checkpoint and owner test](PHASE_2_CHECKPOINT_2_OUTLINE.md). No recipe, XP, bundle-weight or final-art changes; no remote push or Workshop upload.
