# Correct mounted cadence and normalize approved loot tuning

Automatic guns previously used recoil delay as shot cadence, while acquired-target firing shared the detection interval. Use the current native automatic animation cycle as a conservative timing reference, a configurable 0.75 rate, and independent firing deadlines. Add persistent Engagement range and a small native-formula distance accuracy adapter; retain damage, critical and reload policies.

Bake the approved loot multipliers into base weights with safe normalized settings/export keys and matching account/draft conversion in LootLab. Coalesce configuration refreshes and summarize diagnostics. Scope, native evidence, limitations and combined test: PATCH_v0.2.26.md. No publication or multiplayer enablement.
