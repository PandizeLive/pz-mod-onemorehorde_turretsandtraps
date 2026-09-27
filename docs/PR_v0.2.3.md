# Fix barrier servicing/destruction errors and add balance settings

Repair and pickup could not appear because their menu retained a missing server module during client loading. Resolve dependencies when the world menu/action is used. Defer paired cleanup outside native destruction callbacks, fix bundle tooltip formatting and stop repeated description-layout logging.

Add native Sandbox damage/max-HP controls, defaulting to 10 damage and 100 HP. Preserve remaining durability percentage when maximum HP changes; selected statistics and free Repair use configured values. Recipes, XP and ten-second service rules are unchanged.

Validation: 337 Kahlua assertions, native translator/option loading, native item transactions and 16 native object streams across separate write/read processes. See [checkpoint](PHASE_2_CHECKPOINT_1C_REPAIR.md). Real SP action/render/destruction acceptance remains pending; vaulting remains deferred.
