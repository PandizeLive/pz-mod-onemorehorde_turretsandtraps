# C488 - scoring patch prepared; deployment approval pending

2026-10-26. Owner selects C487 **1A**. Preparation and local verification are complete. No Worker upload/deployment, score write, Workshop publication, gameplay change or installation occurred. T&T 0.2.70.1 remains accepted; connected-player acceptance stays open.

## Reviewable result

The isolated [Website release package](../../OMH%20Website/cloudflare-api/releases/scoring-c488/README.md) replaces the deployed flag-policy and score-modifier segment with reviewed canonical source snapshots. It recognizes T&T Used/Hardened/Lessened and validates the 20% retained score, including Trait Shop's combined 10% and the existing Cure bonus. It adds Horde 0.6.16.9 and PZ 42.21.0 while preserving all older allowed versions. Unknown/future versions and unknown eligibility remain held; severe runs remain Modified.

All other production code is byte-for-byte preserved: 37,570 prefix bytes and 70,466 suffix bytes. Deployment metadata retains live assets and existing bindings, with no changes to saved LootLab tiers/weights, admin/media behavior, database contents or routes. The preparation script is offline and deterministic. No additional runtime layer is introduced, and no mixed-checkout full build is proposed.

Candidate SHA-256: `e60c6e13869782fb45c570a9570be068f682ee5380ad7c60120ec676dac68910`.

Website release package committed locally as `f29d8fa` on `codex/p1-audit-v0.6.9.7`; only the new `cloudflare-api/releases/scoring-c488/` files are included. Existing Website edits remain unstaged. Both scoring source snapshots also pass TypeScript semantic checking.

## Important audit correction

C487 selected an older deployment from Wrangler's oldest-first output. The correct active/latest version is **308c1b4e-ff42-4134-9348-9aa812d8d37a**, deployed **2026-10-19** at 100%, not b267828b. The downloaded current source includes the T&T 0.2.57/Grid LootLab catalog. Fresh API inspection confirms that the current version has the same scoring and supported-version defects identified in C487. The candidate and rollback use the corrected active version; historical audit evidence is retained with this correction.

## Verification

- 40 genuine C487 Lua-exported combinations pass the finished bundle: five difficulties, Standard/Cure, Shop off/on, T&T off/on.
- 40 historical parity, 360 severe/strictness, 122 malformed/unknown-input, 40 frozen Official boundary, 20 supported/future-version and five LootLab preservation cases pass. Exact admin HTML, code preservation and binding-delta assertions pass.
- 18 existing focused API tests pass against a test-only export of the candidate, rather than just current source modules.
- Actual local workerd starts the candidate and passes four route/CORS/access checks; its test-only scoring harness passes all 40 Lua cases. No remote bindings/storage or live submissions were used.
- Wrangler 4.125.0 dry-run/no-bundle packaging passes. Actual upload acceptance and post-deployment behavior remain untested until separately approved deployment.

The full local Website suite's 15 pre-existing LootLab failures remain unresolved outside this narrow patch. They do not apply to the byte-preserved deployed implementation used here. The live Worker has logs enabled and traces disabled; this patch preserves that existing configuration. No new game test is requested.

## Deployment and rollback contract

**1A, recommended:** approve deploying this exact narrow candidate to `omh-leaderboard-api`, retaining its production assets/bindings, followed by read-only verification. No synthetic score upload or database backfill is included.

**1B:** keep the prepared candidate local and defer live scoring readiness.

Before any approved upload, recheck that both latest uploaded and active versions still equal the captured baseline, and verify source/config hashes. Otherwise rebase and re-review. The documented API upload uses `keep_assets` because the installed Wrangler CLI does not expose that retention option; it inherits existing named bindings and changes only the two version-list values. Server-side acceptance has not been claimed.

Rollback is the captured version **308c1b4e-ff42-4134-9348-9aa812d8d37a** at 100%, followed by binding/asset/API checks. No data migration is needed; rollback does not undo scores received while the new validator was active. Exact payload, metadata, commands and hashes are in the linked release README/manifest.

Only new isolated Website release files and this project handoff are changed. The owner's AMMO_UI_C446.md remains untouched. No unrelated Website edits are staged. Private T&T mirroring remains blocked by the prior automatic approval review requiring explicit destination/payload authorization; no retry or bypass. Horde mirroring remains manual-only. **Decision needed: deployment approval.**
