# 0.2.59.1 approved correction - C373

Owner approval: "1B Approved to apply the fix", followed by "Please check the issues, like the bad positioning / placement". C372 option 1B selects Rotary Blades x2 and Lobber x1.5. The owner supplied module_performance_templatetest1.png and answered "Performance module icons" to the icon-versus-header question. Standing C108 covers installation/development GitHub mirror; no Workshop upload or merge.

## Scope

- Portable placement correction
- Tether wall alignment
- Battery consumption spectrum
- Rotary Blades and Lobber battery balance
- Performance module icons
- Module inventory categories

The native completion cursor receives the builder's player index. Portable deployment supplies exact owned inputs directly to native setInfo restoration callbacks instead of treating a move as crafting a replacement. This avoids BuildCheat's skipped recipe consumption and the native preview/in-progress recipe-data mismatch. Native object construction, SpriteConfig, callbacks and transmission remain in use. Allowlisted routes, ownership/reach/safehouse checks, server-derived durations and client mutation guards remain. Ordinary crafting is unchanged.

The Tether white developer panel uses the canonical wall edge in all four directions at height 0.3, matching the cable launch height. Textures no longer add arbitrary per-face displacement. Current installed 42.21 IsoSprite ghost rendering uses the 32/96 tile-scale anchor; generated 2x artwork uses 64/192. Native IsoUtils projection verifies the panel center and zero extra pack offset on all four faces. Live wall occlusion/appearance still requires rendered acceptance.

Consumption bands use fixed percentage-points per real unpaused hour: Minimal <1, Very Low <2.5, Low <5, Medium <15, High <30, Very High <60, Extreme >=60; zero is None. Colors use seven OMH palette stops with the existing text-brightening treatment for dark backgrounds. Ratings include loaded Sandbox head tuning, exclude installed modules, and use baseline ammunition. New Sandbox factors default to Blades 2 and Lobber 1.5; existing owner tuning remains. Default module-free motor runtime is three real hours for Blades and six for Bat; Makeshift Lobber baseline is about 5.09 hours including ordinary reload cadence. These are calculations, not endurance tests.

## Owner artwork and categories

The supplied 32x32 PNG is copied byte-for-byte as Item_OMHTT_ModulePerformance.png. Eleven numerical upgrades use it: Critical, Velocity, Magazine, Accuracy, Range, Rapid-Fire, Reload, Autoloader, Suppression, Regulator and Conservation.

Native inventory/Stockpile categories cover 36 items:

- Performance: the eleven upgrades above.
- Automation: normal/improvised/enhanced Firing and Detection, 360 and Filter.
- Effects: Splitter, Fragment, Piercing, Initial Blow, Execute, Impact, Martyrdom, Tack and Synergy.
- Utility: Grid, Siphon, Void and Lure.
- Expansion Kits: Improvised, Small, Medium and Large.

Module Pack remains a reward container. Other category icons retain existing art. Manage slot order remains player-controlled; this patch does not add category headers or automatically rearrange installed modules.

## Verification boundary

See TEST_v0.2.59.1.md. Headless construction fixtures cover SP/server Lua branches using real game objects and inventory with synthetic square lookup. This is not a launched SP client or connected multiplayer test. Final installation/mirror evidence follows verification.
