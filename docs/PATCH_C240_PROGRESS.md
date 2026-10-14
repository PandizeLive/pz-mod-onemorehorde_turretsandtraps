# C240 multiplayer and Horde Night implementation — unfinished

Subsequent implementation: [C241 production lifecycle and current remaining work](PATCH_C241_PROGRESS.md). The evidence below records the C240 checkpoint.

2026-10-14. Owner approved implementation and deferred gameplay testing. Follow-up **1A**: ordinary native collision is neutral; active defense effects require receiving-run opt-in. This remains one combined patch with unfinished C235 content/Void work, not a newly split release.

## Implemented in this development checkpoint

- Server-completed native Module Pack action, authority-owned draws, exact-item consumption/replay checks, rollback and native item synchronization. Reveal/Skip/Collect only present server-selected rewards.
- Horde score schema 6: one T&T /5 reduction, multiplicative with Trait Shop /2 and Cure bonuses. Explicit deduction bases survive aggregation/normalization; completed awards are not retrospectively divided.
- Default-off run consent, permission-checked configuration, active-event marking, new-run reset, score preview and persistent use/history flags.
- Horde-owned lookup validates exact tracked zombie, event, receiving owner and generation. Private lifetime tracking prevents erased public tags from turning a Horde member into an apparently ambient target. Native creation clears the prior lifetime marker.
- Finishing-blow context precedes native death and is consumed once by the existing Horde handler. Device kills do not fabricate participant/weapon/extension XP credit.
- T&T consent gates cover targeting, direct/secondary damage and current contact/trip paths. Delayed hits recheck consent. Barrier collision is unchanged; denied targets retain native thumping.
- Settings evaluator with explicit directions/bounds; coupled loot/power/movement changes remain unverified. Unchanged snapshots are reused. Easier/unverified history persists; known changes preserve the prior Official boundary. Pre-checker history cannot manufacture an Official boundary.
- Potato impacts release their primary effect reservation on completion and denied arrival. The previous successful-hit path could retain capacity.
- Matching local website score validator, flags and fixtures. **Not deployed.**

## Verification

- Full T&T validator: **18,262 assertions**, 125 Lua/translation files compiled in installed Kahlua, 808 loaded translation keys, 224 source / 273 packaged files validated. Native packet serialization: 24 packets, largest 390 bytes. Native animation/sound/model/depth/package checks pass. Isolated-harness GUID-table warnings and native JOML deprecation warnings occurred; no failed assertions.
- Horde: **458** settings/persistence/consent/context/score assertions; **93/93** Lua files compile. Its existing 200-local limit required avoiding another file-scope local. Context tests execute the extracted production resolver with fixture world objects, including tag replacement, wrong event/generation, retirement, client denial and native lifetime reset.
- Website related scoring/eligibility/review/detail subset: **41 tests pass**. Full API suite: **65 pass / 15 fail**, remaining failures in LootLab page/settings tests outside the edited paths. The broad suite is not green; no deployment attempted. Preserve substantial pre-existing website dirty/untracked work.
- Regression tests cover server pack completion, forged reward metadata, duplicates, native synchronization calls, revoked consent, successful/cancelled impact-capacity release and neutral manual-device killer identity.
- Local evidence: `diagnostics/c240-multiplayer/`. Reproduce native findings with `tools/check_native_damage_transport.py`. These are **not live dedicated/listen-server or rendered UI acceptance**.

## Confirmed native transport issue

Installed game JAR SHA-256: `e1a69eb743ede60b213a0fe7f8b83d4fcab773036d256cc4543a336f3b058a33`.

`NetworkCharacterAI.syncHealth()` is a no-op; `NetworkZombieAI` does not override it. `zombie.popman.NetworkZombiePacker.applyZombie()` writes health from the owning client's packet. Server-only `setHealth()` plus `syncHealth()` therefore does not implement remote-zombie damage: an owner update can replace the value. Native `Kill` sets zero health before `onKilled`; `IsoZombie.onKilled` triggers `OnZombieDead`. `VirtualZombieManager` dispatches native `OnZombieCreate`. This is bytecode evidence, not a live ownership/death test.

## Still required before installation

1. Production turret/trap placement, inventory/service transactions, server-owned state and client replication. Most production paths remain guarded SP prototypes; do not remove guards to manufacture MP support.
2. Prove and implement remote-owned zombie damage/death/movement transport, concurrent player hits, ownership handoff, reconnect and duplicate/stale packets. The native finding rules out naive health sync; it does not prove Lua support impossible.
3. Complete attraction isolation, including Lure/world sounds, and durable pre-integration character/world provenance. Collision alone is settled as neutral. Do not mark the capability ready while these remain unresolved.
4. Finish retained C235 head/ammo/Void integration, coordinated versions and candidate validation/installation. Owner gameplay tests remain deferred.

`OMHTT_DefenseAuthority` is deliberately **not advertised** by this unfinished implementation. Exact-ID recognition alone cannot certify Official support. No install, new test tag, deployment, Workshop upload or MP acceptance. Installed 0.2.49 and immutable rollback evidence remain unchanged.

T&T uses its standing development mirror route. Horde source is a local development commit under its manual-mirror rule. Website edits remain in its existing working tree. Mirroring T&T does not publish either sibling.

Horde local checkpoint: `0aaf135` on `codex/scheduler-catchup-v0.6.16.5`. Website files touched here: `cloudflare-api/src/score-modifiers.ts`, `src/run-flag-policy.ts`, `tests/defense-score.test.ts`, `tests/p1-eligibility.test.ts`, and `tests/fixtures/run-flags-c240.json` (all paths beneath `cloudflare-api`). Its other pre-existing edits were preserved. Review these dependencies together before future publication.
