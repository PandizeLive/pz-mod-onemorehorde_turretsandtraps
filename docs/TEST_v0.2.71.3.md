# 0.2.71.3 verification

## Automated and native evidence

- Full validation: 44,376 Kahlua assertions, 266 Lua files; 464 source and 640 package files verified.
- Five frozen 0.2.71.2 controls fail their expected behavior: busy firearm recipient, late ray receipt, outer wall edge, zero-rate pause and battery defaults. Corrected production code passes. The old clock receives only a former-behavior API adapter.
- Stacked ray checks cover 1, 2, 5, 6 and 16 children, late/dead recipients and duplicate prevention. Warning checks cover 0, 4, 8, 20 and 30 tiles.
- Native write/read passes in64.5/57.5 seconds, including actual zero-rate queued Tether movement, grass/fern versus blocking bushes, four-direction construction, actual head profiles and persistence.
- Traps-only, Turrets-only and combined dedicated starts pass in58.5/53.3/56.5 seconds.
- Horde Night baseline:610 settings, persistence, defense-authority and scoring assertions pass.
- Evidence: diagnostics/c534 validation.log, final-negative.log, final-native-write.log, final-native-read.log, packages.log, horde-baseline.log; [durable result and hashes](evidence/c534-verification.json).

## Limits

All dedicated probes had zero connected clients. They establish native API, simulation and persistence behavior, not rendered multiplayer smoothness. General zombie sliding during MPFF pause is not proven fixed. The exact obstacle in the vegetation screenshot remains unidentified. Real-time battery estimates depend on the captured normal/enhanced module costs and90-minute days; stock M16 differs from the captured modded profile.

Installed and staged from immutable `test/v0.2.71.3` / `8ec07f4`. All 464 source and 640 tag/package/install/archive/stage files match; previous backups and page metadata/preview verify. [Delivery](evidence/c534-delivery.json). No Workshop upload or live-server change.

## Owner retest

Upload both staged versions, then restart server and clients. Existing saved battery values require the seven targeted changes in [the contract](UPDATE_C534.md#battery-reference-and-saved-tuning); no new world or blanket settings reset.

- Stacked Splitter, empty turret
- Warning sound distance
- Paused traps, sounds and zombie movement
- Poke grass placement and stabilizer boundaries
- Battery endurance

## Publisher tooling verification - 2026-10-31

The owner authorized running-client SteamUploader integration. Fifteen isolated Workshop workflow checks pass, including a failed upload leaving the release baseline and cumulative changelog unchanged. The shared uploader suite passes real offline image validation, unchanged Steam PID, timeout/start failure, metadata omission, eight simulated failure outcomes and exact-item simulated confirmation. Three Rust tests cover sparse metadata, creation restrictions and callback ID/agreement checks. The current 640-file tagged package passes publisher preflight. No Steam upload or gameplay change occurred; live publication remains untested. [Implementation and reproducible build](../tools/steam-uploader/README.md).

## C535 owner connected result

Failed: missing spawn visibility, firearm Splitter presentation and Potato targeting. Native spawn construction/replies are confirmed; client actor absence and unstable server pause require follow-up. Nine focused diagnostic assertions reproduce two production inconsistencies. See [C535](MULTIPLAYER_FEEDBACK_C535.md). Prior automated passes do not establish connected acceptance. No new gameplay build.
