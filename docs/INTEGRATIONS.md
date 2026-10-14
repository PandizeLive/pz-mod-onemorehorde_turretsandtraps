# OMH and Trait Shop integration plan

Current status C238: owner confirms Horde Night compatibility and Allowed-with-Score-Divider direction; [reviewed MP/scoring patch preparation](MULTIPLAYER_HORDE_PATCH.md) supersedes the old source snapshot below. Exact divider, activation scope and official settings baseline remain decisions. No scoring integration is implemented by that preparation. Existing shared-XP and Cure simulation proposals remain separate, unapproved where marked. No sibling project was changed by the foundation pass or C238.

## Baseline and project coordination

Reviewed the latest available OMH: Website, OMH: Presentation, OMH: Horde Night, OMH: Cure Defense and OMH: Trait Shop task updates on 2026-09-25. Presentation's API-link issue and Website's copy cleanup introduce no file conflict here. The archived Cure update describes a historical reconnect/restoration gap, not proof of the current runtime's state. The current Trait Shop documents describe a later scoring implementation; inspect current source again at each dependent checkpoint.

Existing references:

- [Horde Extension API v3](../../pz-mod-onemorehorde_protectthecure/docs/EXTENSION_API.md): lifecycle, per-participant reward facts, object manifests, score-policy metadata and core simulation authority.
- [Trait Shop integration](../../Trait%20Shop/docs/OMH_INTEGRATION.md): x0.50 modifier, multiplicative composition, life provenance and current eligibility rules.
- [Trait Shop design](../../Trait%20Shop/docs/DESIGN.md): progression vocabulary, death lifecycle and connected-only Horde completion rewards.
- [Trait Shop reward implementation](../../Trait%20Shop/Contents/mods/OneMoreHorde_TraitShop/42.20/media/lua/server/OMHTS_Rewards.lua): current individual kill/event receipts, not a faction defense bank.

Current gaps: the documented onKill fact is tied to a credited participant, there is no documented all-member defense reward contract, addon registration cannot grant an arbitrary official multiplier, and addons cannot independently subtract virtual Horde survivors. These are integration deliverables, not reasons to fake player kills or mutate private records.

## Standalone and optional dependencies

Devices must function in supported single-player and multiplayer worlds without OMH. Horde Night owns Horde identity/quotas; Trait Shop owns progression. Device assignment/transfers and faction identity outside Horde Night remain Q03. A persistent device owner is sufficient to identify the reward faction; no geographic base registration is required. Until a supported ownership adapter exists, disable that unsupported shared-reward mode explicitly rather than guessing recipients.

If Trait Shop is absent, no XP bank is earned for hypothetical later installation. If Horde Night is absent but Trait Shop is present, respect Trait Shop's selected reward sources and a verified standalone faction model. Any solo reward interpretation is a proposal: treat the registered solo owner as a one-member recipient set after Q03 is decided.

## Shared defense XP

Confirmed: one reduced pool divided across members; Include Offline Members is toggleable and defaults ON. This concerns Trait Shop XP, not aiming, maintenance or other vanilla skill XP. The earlier mandatory base-boundary restriction was an assistant inference and is withdrawn. Recommended eligibility uses the registered device owner and valid death/reward facts, without a geographical base test. Owner identity is still required; nearby-player guesses are not sufficient.

Proposed calculation for an eligible device kill:

`pool = applicableNormalKillXP * poolPercentage / 100`

`share = pool / recipientCount`

The pool percentage is currently proposed at 25%, not approved. Example using that proposal: 5 normal XP gives a 1.25 XP pool; five recipients earn 0.25 each. Ten recipients earn 0.125 each, not 1.25 each. Preserve fractional accounting and establish the compatible precision strategy with Trait Shop before calling its progression functions.

Select the applicable normal reward from Trait Shop's allowed source: tagged Horde Zombie versus ordinary Zombie, never both. A disabled/disallowed source creates no pool. Existing Horde-completion rewards remain unchanged; offline defense XP does not enable offline completion rewards.

## Recipient snapshot and offline settlement

The exact meaning of eligible members remains Q02; the recommended specification is:

1. On an authoritative eligible death, snapshot device owner, faction membership, recipient identities and character-life identities, source reward, effective percentage, offline toggle, and rules provenance.
2. Include connected and offline members when the toggle is ON. With it OFF, only connected eligible members enter the divisor. Apply no new proximity, attendance or contribution threshold.
3. Exclude uncreated/dead lives and casualties for the relevant Horde; do not grant a fresh life that had not earned the share. These exclusions need owner confirmation.
4. Record one entitlement per snapshotted member, including the fractional amount. Empty recipient sets produce no deferred faction jackpot.
5. Settle connected recipients promptly. For an offline recipient, retain the entitlement and deliver it through Trait Shop when the same eligible life next becomes available. Decide in P3C2 whether existing server records allow immediate safe credit instead of delayed delivery; do not implement both paths independently.
6. Joining later earns no past shares; leaving stops future shares. Recommended: already-earned shares remain the member's entitlement even after leaving. Death invalidates undelivered XP for that old life rather than transferring it to a replacement, subject to Q02.

Turning offline rewards OFF later does not revoke or redivide already-earned entitlements. Changing rates, faction size, reward mode or settings never recalculates old shares. Receipts preserve earning-time provenance so custom/easier earnings cannot become official through a later settings change.

Offline membership does not simulate the world. Before P6, a reward requires a real authoritative device kill in active combat. No kills or XP accrue merely because every client disconnected, the area unloaded, or the server was stopped.

## Exactly-once accounting and ownership

Design a verified death/award identity spanning main hit, potato splash, multiple devices, multiple observers, reconnect and retry. The Horde core remains death/quota authority for tagged zombies. An ambient kill still needs a stable authoritative deduplication scheme; object pointer or recycled online zombie ID alone is insufficient across restart.

One death pays through either the ordinary player path or the defense path. Never set a fake player killer to obtain the existing callback, then also award the faction. Mixed player/device damage needs an explicit final-credit rule decided in P3C2. Attribution must handle a tiny splash finishing blow like any other authoritative device kill.

Recommended ownership at earning time is the registered device owner plus actual event attribution, not the loader, nearest player, last viewer, or builder's current faction guessed after the fact. Changing the controller's target group does not transfer ownership or redirect rewards to another faction. Cross-faction events, visitors, ownership transfers, faction disbanding and outsiders' defenses require decisions before official release.

Use durable per-recipient pending/settled receipts or an equivalent idempotent ledger under Trait Shop's authority. A restart after recording but before delivery, or after progression changes but before a receipt response, must not lose or duplicate XP. Keep a compact settlement record with enough provenance to handle retries and audits; establish retention/compaction bounds before release.

## Horde scoring

Owner direction: follow Trait Shop's approved-modifier approach rather than separate editions/categories. Proposed initial Turrets & Traps reduction is 80%, meaning remaining score x0.20. This value still needs tuning confirmation and does not establish current official eligibility.

| Example modifiers | Base 100 result |
| --- | ---: |
| Turrets & Traps x0.20 | 20 |
| Turrets & Traps x0.20 and Trait Shop x0.50 | 10 |
| Both and Cure x1.20 | 12 |

Compose factors multiplicatively and round once at the established core boundary. Do not reduce actual kill counts, Horde counts or Trait XP with the score modifier. Do not apply the modifier separately per device or per recipient.

Required coordinated changes: Horde approved modifier/classification and persistent run facts; difficulty/status UI; score export and schema/version handling; website validator/display; Trait Shop provenance where benefits cross lives. Preserve existing published records and historical event snapshots.

Define precisely when benefit marks a run, how outsiders' help is treated, and how run resets interact with persistent defenses. A nearby stranger's turret must not silently force a penalty, while borrowed defenses must not evade it. Subscription alone is not usage. Once applicable, addon removal and settings changes must not restore full-score status for that affected run.

Until the coordinated contract and validator exist, standalone/Custom testing may proceed, but do not present scores as officially approved or quietly map the desired policy to an incompatible existing neutral declaration.

## Persistent world objects

Retain device condition, supplies, ownership and connections across ordinary event end and save/reload. Disabling a feature preserves physical devices/resources per the proposed Sandbox policy. Do not promise safe arbitrary mod removal solely because Horde's orphan policy says preserve: game assets, native classes, host objects and run retirement behavior require tests.

Use only exact markers for cleanup. Horde zombie cleanup does not authorize deleting unrelated objects. The integration checkpoint must select a persistence/registration model whose run reset/disband behavior preserves world defenses as intended.

## Cure defense simulation: final phase only

Before P6, Cure's existing simulation continues without any defense contribution; there are no virtual turret kills, consumed virtual ammo, shared virtual XP, or imaginary barrier protection. Explain this limitation to players. Earlier loaded-area defense and offline-member XP features do not depend on P6.

Proposed final model: snapshot relevant approaches and devices; assign virtual attackers between obstacles and exposed Cure routes; apply mutual attrition and real resource limits; transfer pressure as obstacles fail; restore resources, damage, survivors and pending effects exactly once. The runtime contract is not yet designed.

Horde Night must own the virtual population and confirmed deaths. Turrets & Traps describes device capability and consumes approved resource changes; Cure Defense remains owner of Cure health effects. Do not edit private counters or invent a public method signature in this document.

Only defenses whose placement, facing, power, ammo, range and obstruction support the modeled approach contribute. A structure elsewhere in the base is not free Cure armor. No precision path simulation is promised; start with bounded conservative lanes/approaches and compare against loaded outcomes.

Simulated death facts may eventually feed the same shared reward ledger, including offline members when enabled. The receipts must distinguish and deduplicate simulated versus restored live combat. No new offline-completion reward is implied. PauseEmpty, core hibernation and stopped-server rules remain authoritative; do not invent wall-clock catch-up.

Acceptance: switching loaded/simulated mode repeatedly cannot reset targets, inflate survivors, refill ammo, heal devices, replay damage, duplicate XP, or improve survival versus a comparable loaded control. If this cannot be met, keep the integration disabled and retain the documented limitation.
