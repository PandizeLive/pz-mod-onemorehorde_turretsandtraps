# C487 - Horde scoring readiness audit

2026-10-26. Owner selected C486 **1B**. Audit only: no gameplay, installed package, score database, deployment, historical run flag or sibling source changed. Accepted T&T0.2.70.1 / Horde-Cure0.6.16.9 remain installed.

## Conclusion

The local game and scoring-validator paths agree in the exercised cases. The live leaderboard is **not ready for the current versions or T&T-assisted official submissions**. Prepare a narrowly scoped validator release from the actual production baseline; do not deploy the entire mixed website working tree.

## Confirmed findings

1. **High - production validator predates T&T integration.** Wrangler reports Worker `omh-leaderboard-api` serving100% version `b267828b-e930-4e46-98d2-7a5ec4f4495b` (deployed2026-10-12). Read-only Cloudflare content inspection reports policy `0.6.16`; its113102-character multipart response contains Trait Shop handling but none of `turrets-traps`, `Turrets & Traps Used`, `Turrets & Traps Hardened`, `Turrets & Traps Lessened`, or `c240-defense-integration`. Local API code contains those branches. Updating version bindings alone would not deliver the reviewed T&T arithmetic/flags.
2. **High - current versions are unsupported in production.** Live plain-text bindings allow Horde0.6.3/0.6.9.6/0.6.9.7/0.6.16.3/0.6.16.4 and PZ42.20.3/42.20.4. Current Horde0.6.16.9 and PZ42.21.0 are absent. Replaying current local review policy with those exact live bindings holds all40 genuine Lua-produced cases for `unsupported_mod_version` and `unsupported_game_version`. This is a local reproduction using live configuration, not synthetic submissions to production.
3. **Medium - the website checkout is not a safe wholesale deployment candidate.** Full API suite:80 tests,65 pass,15 fail. All failures are in LootLab page/settings tests: two page harnesses omit `LootTiers.mount`; settings schema remains0.2.44, lacks newer catalog entries, and rejects newer fields. These failures do not prove a live LootLab outage. Combined with unrelated pending website edits, they require preserving the deployed LootLab/assets/settings behavior while preparing the scoring patch. Do not fold a broad LootLab rewrite into this audit.

## Passed checks

- Horde installed-Kahlua suite:610 settings/persistence/defense authority/score assertions, including independent T&T package-default neutrality and matching `tt-c484-v1` capability. Default, harder, easier and unknown classifications remain distinct; historical flags are not cleared.
- T&T foundation suite:35424 assertions,446 source/614 package files; actual Horde integration fixture covers disabled-run damage and motion from owner and stranger sources, delayed permission revocation and unfilterable world-sound suppression. World/actor objects in this harness are doubles; connected-player acceptance is still open.
- Focused API suite:39 tests pass, including modifiers, supported-version handling, official/modified projection, frozen official boundaries and package validation. These are included within, not additional to, the full suite's65 passes.
- Cross-language replay invokes production `OMH_ScoreRules.calculateEventAward` and `recalculateScoreFacts` in installed Kahlua. It exports40 combinations (five difficulties, Standard/Cure, Shop off/on, T&T off/on), then uses actual local `normalizeScoreSurfaces` and `assessSubmission`. All40 publish under a hypothetical explicitly reviewed current-version allowlist; all40 are held under the actual live allowlist.120 combinations of Lessened/Unverified/Denied flags become Modified. No live database requests or writes were used for these scenarios.
- Reviewed code rejects tagged Horde damage/motion unless the receiving run confirms difficulty and allows defenses; stranger ownership does not bypass that boundary. Allowed assistance is classified before effects, not only at death. The score modifier retains20%, or10% after Shop; Cure bonus uses the existing calculation. Ordinary physical obstructions remain native world geometry, not a new per-zombie collision permission system.

## Proposed next step

**1A, recommended:** prepare a minimal leaderboard-validator patch using the deployed Worker as the preservation baseline. Include current T&T modifier/flag handling, reviewed Horde0.6.16.9/PZ42.21.0 version compatibility, genuine Lua export regression cases and existing frozen-boundary/historical behavior. Preserve live LootLab, admin, media and public projections. Present the concrete tested diff and rollback version for separate deployment approval; no production submission, score rewrite or Workshop publication is implied.

**1B:** defer official-score readiness and leave the current production hold behavior in place. Gameplay testing remains available.

No new game-side scoring defect was reproduced. This is not full security certification, a connected-player test, an actual score export/upload session or a claim that every historical run is eligible. Preparation/deployment approval remains separate. **Decision needed.**

## Context and evidence

Read-only origin/dev and origin/main fetches found no newer upstream commits. The four named OMH project chats were absent from the available50-thread listing. Website checkout contains existing unrelated changes and was left unchanged; Horde checkout remains clean. Owner AMMO_UI_C446.md retains SHA-25624506649c189a6e0b9f9e7fd04ab53fba940d3741a79ec38c267b75b75207fba.

Wrangler's project-local CLI read deployment/version metadata through the existing login. Its view command does not download code; the Cloudflare connector's read-only content endpoint supplied the production code-presence check. No credentials were printed or stored by the audit. No web search was needed for these directly inspected local/account resources.

Logs: `diagnostics/c487-horde.log`, `c487-tt-validation.log`, `c487-api-tests.log`, `c487-api-all.log`. Replay scripts and JSON are in `diagnostics/c487/`. Reproduction: compile existing Horde `tools/KahluaBehaviorCheck.java`; run installed Kahlua with vanilla stdlib, the existing mod-compatibility bootstrap, production ScoreRules and `export.lua`, setting `p1.output` to `lua-facts.json`; then execute `check.mjs` with the bundled Node runtime. Metadata below identifies the retained evidence.

Private T&T GitHub mirroring remains blocked by the earlier automatic approval review requiring explicit destination/payload authorization; no retry or bypass. Horde mirror remains manual-only. No publication performed.

```json
{
  "diagnostics/c487/export.lua": "b85bf3f05ee70aa1158c2694426472872ba2c708eea049a6d1fe872ad8063eb5",
  "diagnostics/c487/check.mjs": "465c475f86836aa66534453de4f992d366cc705568ebee7b2ee0dc890c7bda70",
  "diagnostics/c487/lua-facts.json": "282d175ff53aeed467854a6967d3bb8d807758aa13628f181f62543df7e75fd7",
  "diagnostics/c487/cross-layer-result.json": "42b4b7f0d15c524a81c2c25d11881fdad30b95e41dbefb7e6fce15b88de47605",
  "diagnostics/c487/production-content-audit.json": "463f9add3a7f827b509d279f8ef0ac7a726395ab2fcfc13dbe29346614f239e0",
  "diagnostics/c487-production-version.json": "ae1c17e09654f0cf46b71214f26fb4a81ae08402eeb7c5a1acf28f197ada2fbc",
  "diagnostics/c487-deployments.json": "16db03d299ab314818ecff0eb09a862b7f83f1ff931dff1449998b8ff488885f"
}
```
