# Pending LootLab server catalog

The 0.2.54 catalog helper is based on the last verified 0.2.50 deployment's settings helper. It adds Siphon and upgrades existing 0.2.50–0.2.53 scenarios without changing their saved weights or tiers. GET upgrades are in-memory; no database rewrite is required. Authentication and database access behavior are unchanged.

Cloudflare authentication expired, so this helper and the local assets have **not been deployed**. Before deployment, retrieve/compare the current live Worker, reconcile any intervening changes, replace only its `src/loot-lab-settings.ts` catalog helper, and copy the whitelisted LootLab assets including `tier-list.js`. Preserve all other live routes, bindings, configuration and account data. Run the host API suite and verify protected admin routes and unchanged public endpoints before and after deployment. Do not deploy the stale sibling Website checkout or blindly replace the current Worker with this historical snapshot.

Focused local catalog checks: `node --experimental-strip-types --test tools/loot_site/cloud/catalog.test.mjs`.
