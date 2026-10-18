# LootLab server catalog

The 0.2.54.1 helper includes Siphon and upgrades prior catalogs without changing saved account weights or tiers. Missing Siphon defaults to multiplier 1 against base weight 3, matching the default Legendary anchor. GET upgrades happen in memory; no production database rewrite is needed.

Published and verified as Worker version `e4c47e3b-94ad-45e2-ac0b-9b4d9e22d0df`. The release used freshly fetched production code, changed only the catalog section, preserved live configuration/bindings and copied ten whitelisted/sanitized LootLab assets. 86 backend checks, local catalog and desktop/mobile browser checks passed. All 13 protected admin routes and both public endpoint checks passed before/after deployment. See `diagnostics/v0.2.54.1/lootlab-release.json`.

Future releases must fetch/compare current live code; do not deploy a stale sibling Website checkout. Run `node --experimental-strip-types --test tools/loot_site/cloud/catalog.test.mjs` for focused catalog checks.
