# P5C1a — early supported-firearm mount prototype

Status: next checkpoint proposed for combination with the approved 0.2.20 cleanup. C64 approved moving firearm feasibility ahead of P2C3e multiplayer. This document scopes that early slice; implementation is pending. It does not enable all Phase 5 content or waive multiplayer gates.

## Player outcome

Install a supported vanilla gun in the universal base's existing head slot. Add matching ammunition and existing modules in Manage. Swap back to the potato head after unloading incompatible ammunition. No additional mount crafting step or new recipes in this prototype.

Prove one vanilla pistol, pump shotgun and bolt-action rifle first. Choose current installed script IDs after inspection. Keep unsupported guns out of the slot with concise feedback; broad modded-weapon discovery follows only after adapters prove reliable.

## Work

1. Inspect current native weapon scripts, attack/ballistics, chamber/magazine state, reload/cycle animations and available duration/rate data. Record which native systems a stationary object can reuse and where an explicit adapter is required. Do not invent a hidden survivor to invoke character-dependent combat.
2. Add weapon profiles behind the existing head interface. Preserve the actual gun, attachments, condition, loaded chamber/magazine and reserve items through swapping, pickup, destruction and save/load. Define exact reload-ammo transactions before implementing them; no duplicate magazine or chamber rounds.
3. Reuse turning, placement cone, Detection/Firing/Filter/360, power and bounded target scheduling. Rapid-Fire changes fire cadence, Reload changes loading time, Autoloader removes reload wait, and all continue consuming ammunition. Pump/bolt handling is a separate native-mechanism question to settle from evidence. Apply applicable Range/Velocity/Expansion effects through shared effective stats, with concise Manage readouts.
4. Render the supported gun as the swappable head using its native model and appropriate muzzle anchor. Native gun effects/sounds should be used where exposed; potato-specific splash/knockdown/audio must remain on the potato profile.
5. Add useful grouped firearm Sandbox controls only with working effects: enablement, accuracy, damage/range and reload/fire cadence tuning. Recommend Aiming-3-equivalent baseline only if current native calculations support a stable, explainable implementation; it is not an approved promise of identical player accuracy.
6. Verify exact ammo accounting, obstruction checks, failed/cancelled shots, no burst catch-up, mixed potato/firearm turrets, bounded per-tick work and persistence. Keep one combined short owner test after the playable candidate exists.

## Gates

A native capability gap becomes a documented choice of adapter or narrower supported mechanism, not a blanket compatibility claim. Separate native proof, automated checks and rendered acceptance. Multiplayer, all-gun compatibility, module recipes, explosive heads, Horde/XP integration and final artwork stay outside this checkpoint. Concertina and the rest of the defense roster remain on the roadmap.

Recommended effort: High. Use Fast for implementation if the expected elapsed work exceeds 25 minutes.
