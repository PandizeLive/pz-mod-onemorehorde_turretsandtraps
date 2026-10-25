# OMH and Trait Shop integration plan

**C466 current correction:** the owner selected a minimum1XP for positive recipient splits below1, after combining shares per action and before award/banking. Zero/ineligible stays zero; delivery never reapplies the minimum. This can exceed the original pool total. See the C466 section below and [the reproduced SP startup identity defect](FEEDBACK_C465.md#c466---choices-confirmed-startup-xp-defect-reproduced-2026-10-25). Selected, not yet implemented.

Current status C239: owner selects divide by5, explicit per-run opt-in and default-or-harder eligibility; [reviewed MP/scoring contract](MULTIPLAYER_HORDE_PATCH.md) supersedes the old source snapshot below. Native enforcement and coordinated implementation remain outstanding. Existing shared-XP and Cure simulation proposals remain separate, unapproved where marked. No sibling project was changed by this planning update.

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

Owner direction: follow Trait Shop's approved-modifier approach rather than separate editions/categories. C239 confirms an80%reduction, meaning remaining score x0.20, with explicit per-run opt-in and a default-or-harder eligibility audit. The value is approved; coordinated implementation and verification are still required for Official eligibility.

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


## C453 - Next track after 0.2.67 acceptance (2026-10-24)

Owner asks "Now what" after closing the current SP test round in C452. C403 retained the future integration, garage/barbed, modder support, art/release and Cure tracks; Arc Emitter is now implemented and the current patch accepted. Do not propose implementing completed heads/Controller targeting again or reopen the closed SP checklist.

Recommend **1A shared Trait Shop defense XP design** next: review the current sibling APIs read-only, then settle pool percentage, eligible recipients/character lives, offline delivery and mixed player/device kill credit. The selected foundation remains one reduced pool divided across recipients and Include Offline Members default ON. The old 25% proposal remains unapproved. This rewards defense investment and closes the progression integration gap; duplicate awards, life persistence and offline settlement are the material engineering risks. Use Medium reasoning for the initial design/API review; implementation effort can be assessed once the contract is concrete.

Alternatives: **1B garage/multi-panel Barbed Panel feasibility**, a smaller standalone coverage improvement requiring moving-leaf identity/geometry proof; **1C coordinated Horde scoring readiness**, reconciling T&T, current Horde core and score validator without deployment. These are next-track choices, not reapproval of the retained roadmap. No track selected by "Now what" alone.

Modder-facing extension documentation/sample and remaining owner art/release preparation remain retained. Connected multiplayer remains deferred until the agreed development work is complete; Cure simulation remains last. No sibling edits, code patch, deployment or publication authorized by this status question. Current 0.2.67 acceptance is unchanged.


## C454 - Shared defense XP selected for design (2026-10-24)

Owner selects C453 **1A**, authorizing the shared Trait Shop defense XP discussion/API review. Current 0.2.67 owner acceptance remains closed. This does not select the old 25% proposal or authorize a coordinated gameplay patch yet. Read-only review of sibling files below; no sibling modifications, live XP awards or runtime tests.

### Current source evidence

- Trait Shop local package declares **0.9.0.1**. `OMHTS_RewardsConfig.lua` (`Config.defaults`, `Config.visible`, `Config.amount`) defaults to 2 ordinary Zombie XP and 5 Horde Zombie XP, but selected reward mode, disabled sources and configured values remain authoritative. Horde reward mode excludes ordinary kills. No integration may pay a disabled source or pay both sources for one zombie.
- `OMHTS_Authority.lua` exposes `Authority.awardXP(player, lifeId, revision, amount)`: it binds a live player, checks enabled state, audits earnings, validates the exact life/revision through State, and sends a snapshot. This is an existing supported individual award entry point; it is not an offline, receipt-keyed faction award API. `store` is private, and T&T must not write it directly.
- `OMHTS_State.lua` (`State.isXP`, `State.awardXP`) accepts fractional nonnegative XP and validates a live character life; `OMHTS_Progression.lua` (`Progression.advance`) retains fractional remainders. No rounding each split to whole XP. The initial bar is 100 XP. `DESIGN.md` specifies that death resets current XP/Trait Level, with separate prestige rules.
- `OMHTS_Rewards.lua` uses separate ordinary death and participant-count Horde receipts. `Authority.onHordeKill` resolves a connected credited participant. Horde API v3 `eventHooks.onKill` supplies participant kill-count facts, not a shared defense death/recipient fact. A coordinated extension is needed to connect authoritative device kills to a pool without inventing a player killer.
- T&T `Damage.apply`/local `apply` in `server/OMHTT/Damage.lua` calls `Kill(nil, false)` for lethal device damage and reports damage source/kind. `shared/OMHTT/DefenseHorde.lua` already brackets native damage through the Horde integration. Existing `ControlAccess.write` uses persisted device owner/faction for access; access permission and Controller target settings must not be treated as reward ownership. Legacy passive-object ownership and offline identity mapping still require a focused implementation audit.

Source references: [Trait Shop reward configuration](../../Trait%20Shop/Contents/mods/OneMoreHorde_TraitShop/42.20/media/lua/shared/OMHTS_RewardsConfig.lua), [Authority](../../Trait%20Shop/Contents/mods/OneMoreHorde_TraitShop/42.20/media/lua/server/OMHTS_Authority.lua), [State](../../Trait%20Shop/Contents/mods/OneMoreHorde_TraitShop/42.20/media/lua/server/OMHTS_State.lua), [Progression](../../Trait%20Shop/Contents/mods/OneMoreHorde_TraitShop/42.20/media/lua/shared/OMHTS_Progression.lua), [Horde API](../../pz-mod-onemorehorde_protectthecure/docs/EXTENSION_API.md). These are local source findings, not proof of matching deployed versions or connected acceptance.

### Settled foundations

One reduced pool is divided between eligible members. Include Offline Members defaults ON. This is Trait Shop progression, not vanilla skill XP. Trait Shop remains optional; absent Trait Shop means no speculative XP bank. Offline participation does not simulate unloaded combat or grant Horde-completion rewards. Cure simulation stays last.

### Decisions now proposed

**1 - Reward rate.** Recommend **1A 25%** of the applicable configured kill reward. **1B 50%** gives stronger defense progression; **1C 10%** emphasizes direct combat. At current defaults, 100 Horde kills produce 125/250/50 XP total respectively, or 31.25/62.5/12.5 each for four eligible members. Ordinary kill totals for the same 100 kills are 50/100/20 XP, if that source is enabled. These are arithmetic examples, not awarded XP or measured progression. Larger membership divides the same pool rather than multiplying it.

**2 - Recipients.** Recommend **2A the registered device owner's current faction, including the owner; solo owners receive the pool themselves**. Snapshot verified eligible character lives and membership at the kill, so joining later never earns old shares. Alternative **2B the faction whose Horde is being defended for Horde kills, falling back to the owner's faction for ordinary kills**. This favors the defended group but gives away the device owner's resource-funded rewards when helping outsiders. Neither option routes rewards by who clicks a Button, opens Manage, changes target filters or is nearest. Do not pay both factions.

**3 - Player assists.** Recommend **3A final-hit credit**: a device finishing blow creates only the reduced shared pool; a player finishing blow uses the existing ordinary personal reward path. No second payout for earlier chip damage. This rewards active cleanup and avoids maintaining every player's damage history. Alternative **3B proportional effective-damage credit**: separate the player's full-rate damage share and the device's reduced shared portion, never two full rewards; this needs additional authoritative damage attribution and rules for healing, overkill and multiple factions. It is more complex and less attractive for crowded fights. No damage-ledger feature is approved merely by this discussion.

### Recommended defaults for the later recap, not yet approved

Apply to owned zombie-killing turrets and traps, including passive traps with verified ownership. Triggers themselves earn nothing; automated player kills grant no defense XP. Unowned/ambiguous legacy devices do not invent an owner or grant rewards until a supported ownership claim is available. Recipients must have an existing living Trait Shop character, and relevant Horde casualty rules remain enforced. No proximity requirement.

Retain earned shares for the same character across disconnects and faction departure, but discard undelivered shares if that character dies; do not inherit XP on a new life. Dead or uncreated lives are excluded from future recipient snapshots. A faction/rate/offline-option change never recalculates an already-earned share. Use Trait Shop's existing death/prestige lifecycle rather than an independent inheritance system.

Expose Enable Defense XP, Defense XP Percentage and Include Offline Members under the existing T&T General integration section, with clear optional-dependency descriptions; do not create another top-level category. Default enablement and rate will be included in the approval recap. Official-score provenance/default-or-harder handling must be coordinated with current Horde/Trait Shop contracts before any eligibility claim; score factors never multiply the XP pool.

### Implementation outline and next gate

After decisions: prepare a versioned server-owned defense reward fact and a Trait Shop-owned receipt-aware pool settlement API. Persist earning-time recipient/life/source/rate/rules snapshots and settled receipts together with progression; retry after reconnect/restart without duplicate awards. Resolve offline identity via supported faction/character registries, not private record mutation or online-player guesses. Use bounded event-driven award work and batched UI notifications, not world scans or one popup per kill. Establish identity, receipt retention/compaction and mixed-kill ordering under both ordinary and Horde death paths, including the final event kill.

Then provide a concrete coordinated patch recap, including required sibling work, before gameplay implementation. Minimum verification covers single recipients and factions, fractional shares, reward-source filtering, duplicate/reordered death callbacks, offline delivery, death/new life, faction changes, restart and independent Turrets/Traps packages. Connected acceptance remains deferred until the agreed development work is complete. **Decision needed: 1A/1B/1C, 2A/2B and 3A/3B.**


## C455 - 50% pool, owner faction and proportional damage selected (2026-10-24)

Owner selects C454 **1B / 2A / 3B**. Confirm **50% defense reward rate**, **registered device owner's faction, including the owner, with solo fallback**, and **proportional effective-damage credit**. This supersedes the earlier 25% and final-hit recommendations; do not silently fall back to final-hit credit if attribution proves difficult. Shared-pool/offline-default-ON foundations remain settled. This selects gameplay rules for the contract, not final coordinated patch approval or proof that native attribution is complete.

### Selected accounting and examples

For a mixed player/defense kill with applicable configured reward R, direct player i receives `R * effectivePlayerDamage_i / totalEffectiveDamage`. Each defense faction receives one pool `R * 0.50 * effectiveDefenseDamage_faction / totalEffectiveDamage`, divided among its eligible members. Independent factions receive only their own defenses' proportional portions. A contributing player in that faction may receive both their earned personal fraction and their equal share of the defense pool; this is not two full-kill rewards. Never also pay the ordinary full finishing-blow reward for the same death. Existing player-only reward behavior remains unchanged for kills untouched by T&T.

Example at default Horde R=5: a player does 60% of effective damage and their faction's turret does 40%. The player earns 3 XP directly; the faction shares a 1 XP pool. Four eligible members receive 0.25 XP each from that pool, so the contributing player's combined award is 3.25 XP. A defense-only kill creates 2.5 XP total, divided by membership; 100 such Horde kills create 250 XP total or 62.5 each for four recipients. Values remain fractional and follow source settings/eligibility, not a hardcoded five-XP reward.

Effective damage means health actually removed, capped at remaining health per hit; nominal weapon damage and overkill do not inflate contributions. Unknown/unattributed environmental or other-mod damage must not be awarded to a guessed player or defense faction. Healing must not mint extra full-kill reward budgets; normalization and incomplete histories need explicit native verification. No arbitrary contribution expiry or cap may silently turn the selected proportional rule into final-hit credit.

### Current native review: feasibility gate, not a delivered implementation

Read-only `javap -c -p` inspection of the installed projectzomboid.jar, SHA-256 `e1a69eb743ede60b213a0fe7f8b83d4fcab773036d256cc4543a336f3b058a33`, confirms:

- `IsoZombie.Hit(HandWeapon, IsoGameCharacter, float, boolean, float, boolean)` fires `OnHitZombie` at bytecode offset 75, before superclass Hit at 107. This event does not supply final applied damage.
- `IsoGameCharacter.Hit` fires `OnWeaponHitCharacter` at 115 with the input damageSplit, before `processHitDamage` at 261 and `hitConsequences` at 275. Treating that event argument as actual health loss would mis-credit modified, ignored or lethal hits.
- Current Horde `OMH_DefenseIntegration` retains terminal device attribution and clears it on later player hits. Current `OMH_Phase3HordeEngine.onZombieDead` chooses either participant kill credit or defense finishing status. These are existing final-hit paths, not a proportional damage ledger.

A focused isolated proof must establish native player-hit before/after ordering, overlapping same-tick hits, lethal callback ordering and client-owned zombie transport before promising accurate proportional awards. Do not monkey-patch weapon damage to force an accounting result or trust raw client XP/kill totals. T&T's own confirmed health-loss receipts can feed the same attribution contract, but no final native/MP attribution algorithm is claimed yet.

Keep compact accumulated contribution amounts per relevant victim/identity, driven by hits and death, rather than an unbounded hit history or full-world scans. Exact early-player contributions must not be invented when a defense first touches an already-damaged victim. Lifecycle, partial histories, unload/reload and collection of abandoned ledgers are part of the proof. The selected faction rule is retained; identity and ownership changes must not redirect already-earned contributions without an explicit contract.

### Remaining gameplay choices

**1 - Kill eligibility.** Recommend **1A zombie kills only**. Alternative **1B also eligible enemy-player kills**, using the configured Player Kill XP source, the selected proportional/reduced-defense calculation, existing enemy-faction rules and same-victim cooldown. Never pay both PvP paths. Automated PvP XP increases farming incentives; that scope is not implied by proportional zombie credit. A disabled Player Kill source remains disabled.

**2 - Undelivered offline shares after character death.** Recommend **2A discard shares belonging to that dead life**, retaining earned shares through ordinary disconnect/reconnect and faction departure for the same living character. This follows Trait Shop's XP reset on death. Alternative **2B retain an account-level bank for the replacement character**, an explicit exception to the death reset that needs separate provenance/official-rule treatment. Do not infer inheritance from the already-selected Include Offline Members option.

Other recap defaults remain recommended: existing living characters only, applicable Horde casualty/source rules, no proximity requirement, no rewards for unowned/ambiguous legacy devices without a supported ownership claim, no speculative bank when Trait Shop is absent, and an enable toggle plus percentage/offline options under the existing T&T General integration section. Default enablement recommended ON when a compatible Trait Shop integration is present. Existing Horde-completion rewards remain unchanged.

Next: settle 1/2 and complete the focused attribution proof, then present the coordinated T&T/Trait Shop/Horde patch recap. No source, sibling, installation, version, Workshop draft or 0.2.67 acceptance changes in this discussion. No new runtime or connected test claimed. **Decision needed: 1A/1B and 2A/2B.**


## C456 - Enemy-player XP and character-bound offline shares selected (2026-10-24)

Owner selects C455 **1B / 2A**: include eligible enemy-player kills and discard undelivered shares when their earning character dies. Ordinary reconnects preserve that living character's earned shares; a replacement character inherits none. Do not reask either choice or silently return to zombie-only scope.

The selected design is now: 50% defense rate, one pool per contributing defense faction, device-owner faction/solo recipients, proportional actual damage credit, eligible zombie and enemy-player kills, offline inclusion default ON, and no XP inheritance across death. The currently presented gameplay decisions are settled. Existing source/recipient eligibility and fractional precision remain; actual XP/source values come from Trait Shop. This is not final implementation or publication approval.

### Current PvP source review

Read-only Trait Shop `Rewards.player` (`OMHTS_Rewards.lua`) confirms an MP-server-only path, no self/same-faction rewards, source/amount validation, and a cooldown keyed by killer username and victim username in the persistent reward store. `Config.defaults` sets Player Kill XP to 75 and PlayerKillCooldownDays to 2; `Config.visible` enables that source only in Kills or Hybrid mode. Consequently installing this integration must not turn on PvP XP in Horde-only or Survival reward modes, change the owner's configured values, or bypass the repeat-victim cooldown. With default values and an otherwise eligible defense-only kill, the shared pool is 37.5 XP total, before dividing between recipients. This is arithmetic, not an award or runtime test.

The proportional path must combine a recipient's personal damage share and faction share for the same death before one eligibility/receipt settlement, so the first component does not consume the other's cooldown. Recommended implementation guard: use beneficiary/victim account identities for shared payouts too, and share the existing cooldown history with direct awards; do not key cooldowns by turret, Controller, connection session or victim's replacement life. Replacing equipment or reconnecting cannot reset it. Validate enemy status for every benefiting account and never reward the victim or their faction. Confirm blocked-recipient handling in the concrete implementation recap rather than duplicating full rewards or silently creating an extra pool.

### Damage-attribution proof still required

`shared/OMHTT/DefenseInjury.lua` sends server-selected injury commands to the victim client; `receive` applies body-part health loss/wounds and deduplicates command serials, but sends no confirmed health-loss receipt back. `server/OMHTT/TurretPlayerHit.lua` accounts for a requested injury budget and clothing defense, which is not proof of actual applied health loss. Neither requested amounts nor unvalidated client reward totals may be used as authoritative contribution amounts.

Installed-bytecode inspection retains jar SHA-256 `e1a69eb743ede60b213a0fe7f8b83d4fcab773036d256cc4543a336f3b058a33`. `BodyPart.AddDamage(float)` delegates to ReduceHealth. `BodyPart.DamageUpdate` emits `OnPlayerGetDamage` with victim, BLEEDING and amount, but no attacker or device identity. Combined with C455's pre-damage hit events, delayed wounds, simultaneous attacks and body-part-to-overall-health conversion require a focused attribution proof. This static review does not establish accurate bleedout credit or connected MP transport.

Next engineering checkpoint: isolate native direct-hit and wound/death ordering; establish confirmed defense-injury results and player contribution observations; exercise duplicate receipts, mixed personal/shared awards, account/victim cooldown reuse, character death and restart. Keep runtime work bounded and event-driven. The selected proportional/PvP behavior must not be quietly replaced with final-hit or zombie-only rewards. If native constraints require a material behavior change, report that specific finding before changing the contract.

After the proof, provide a concrete coordinated T&T/Trait Shop/Horde implementation recap for approval, including the remaining recommended Sandbox enablement/source settings and ownership handling. No new balancing questionnaire is pending now. No gameplay/sibling/install/version/Workshop changes; 0.2.67 remains accepted, connected testing remains deferred. **Wait for a patch; attribution proof precedes the patch-approval recap.**

## C457 - Approval followed by native attribution boundary (2026-10-24)

The owner approves proceeding from C456. [Reproducible native proof and coverage proposal](DEFENSE_XP_PROOF_C457.md) now document measured input/loss differences, actual limb/overall-health conversion, and source-free bleeding callbacks. Production integration must not claim exact wound attribution from those callbacks. A delayed observation is also not sufficient proof that all intervening loss belongs to a pending hit.

New recommendation **1A confirmed damage only** retains proportional accounting but leaves untraceable portions unpaid, including delayed injury effects from our own traps when ownership cannot be verified. **1B continue deeper wound-attribution work before shipping** retains the full target at unproven cost/compatibility. These alternatives address newly verified behavior rather than reopening the selected 50% rate, owner-faction pool, eligible PvP or life-bound offline shares. Never redistribute the unknown share among known contributors. Coverage selection remains pending; no fallback or Java gameplay dependency is silently introduced.

The current checkpoint changes only isolated tools and documentation. No award API, production ledger, sibling source, version or installed package changed. Duplicate/offline/restart settlement and connected transport still require their own implementation and evidence. Accepted 0.2.67 testing remains closed. **Decision needed: 1A or 1B.**

## C458 - Deeper wound investigation and accounting boundary (2026-10-25)

Owner selects C457 **1B**, authorizing deeper investigation while preserving full proportional accounting. [Current native results and concrete choices](DEFENSE_XP_WOUNDS_C458.md) supersede C457's pending-coverage status. C457's confirmed-only recommendation remains unselected.

The expanded zero-client native probe passes in92.7s. Ten isolated wound cases match a limited predictor, but scratch/cut damage emits no damage event, healing can hide that loss, same-type wounds replace timers and native bleeding rerolls into one aggregate. Source recording is feasible at known infliction; exact attribution is not recoverable from the resulting values alone. The native in-memory round trip verifies selected fields, not restart, custom source persistence or reward delivery.

Recommend **1A defer shared XP while preserving the exact requirement**, avoiding a second health simulation or Java dependency for reward accounting. **1B prototype explicitly estimated wound credit** instead accepts a new accounting policy: per-limb/type source replacement and expected-weight sharing of aggregate bleeding, with modeled silent damage and unpaid unknown shares. Accuracy, authority, performance and persistence still need proof. Neither option is implemented or silently selected. No final-hit/zombie-only substitution; all selected reward/recipient/life/cooldown rules remain.

Only probe tooling and documentation changed. No sibling edits, production reward API, version/install/changelog change or new owner test. C452 acceptance remains closed. **Decision needed: 1A or 1B.**

## C459 - XP deferred; native killer credit distinguished from damage shares (2026-10-25)

Owner selects C458 **1A**, deferring shared XP while retaining its exact-accounting design, then requests a brief explanation before further work. The later question asks whether native PvP killer tracking exists because bleedouts matter. This authorizes inspecting that question, not resuming the XP implementation or changing the selected attribution rule. The intervening briefing turns made no project edits.

**Yes: native killer attribution exists.** Current installed42.21 bytecode, jar SHA-256 `e1a69eb743ede60b213a0fe7f8b83d4fcab773036d256cc4543a336f3b058a33`, confirms:

- `IsoGameCharacter.getAttackedBy/setAttackedBy` read/write one character reference. The native hit path sets that reference to its wielder.
- `IsoGameCharacter.die()` calls `Kill(getAttackedBy())` if the kill callback has not already run (bytecode offsets24/27). Its normal death path can therefore credit the retained attacker after delayed death; an immediately lethal hit is not required by that path.
- `DoDeath` uses that reference for `PVPLogTool.logKill` when victim and attacker are players on the server (offset38). `PVPLogTool.logKill` records killer/victim names and can announce the death.
- `DeadCharacterPacket` has one `killerId`, populated from the corpse's `getKilledBy()`, written/read over the network and used for `dieNetwork`.
- Trait Shop's existing `OMHTS_Authority.observeDeath` reads `player:getAttackedBy()` and passes the resolved killer to its PvP reward path. No sibling source was changed.

Official API corroboration: [attacker getter](https://projectzomboid.com/modding/zombie/characters/IsoGameCharacter.html#getAttackedBy()) and [PvP kill logger](https://projectzomboid.com/modding/zombie/network/PVPLogTool.html). The installed code supplies the behavioral evidence; API signatures alone do not prove retention.

This corrects the conversational framing: the C457/C458 blocker is **exact proportional damage shares**, not an absence of any killer flag or an impossibility of rewarding bleedouts. One attacker reference cannot recover each contributor's wound damage. Later attacks can overwrite it; other paths can clear it. No guarantee is made across all causes, reconnects, restarts or attacker departure. This inspection is static; no new live connected bleedout test occurred. The owner's claim about how frequently players die by bleedout was not statistically tested.

Native-style killer credit is a simpler alternative if the owner later changes the proportional requirement. Defenses still need a device/owner attribution record because the native field holds a character, not a turret or trap. Do not forge an online owner, parse log strings as reward authority, bypass existing eligibility/cooldowns, or silently adopt killer-only rewards. Shared XP remains deferred; no gameplay, package/version, install, Workshop or test-acceptance change.

## C460 - Proportional tracking dropped; payout meaning being clarified (2026-10-25)

Owner asks whether offline faction members accumulate shares for reconnect, then directs: "I think we should just allow the 50/50 split if a turret gets the kill. Don't worry about proportional damage."

**Selected:** use the credited kill for the turret reward decision and drop proportional damage tracking. This explicitly supersedes C455's damage-share requirement and removes the C458 exact-wound-accounting gate from this design. Native-style credit includes delayed death where valid attacker/device attribution is retained; "gets the kill" must not be interpreted as requiring an immediately lethal shot. Do not launch more exact wound-share research or a replacement health simulation.

**Offline answer:** the planned Include Offline Members option remains ON by default. An eligible existing living character's share is reserved at the kill and delivered to that same life on reconnect, including across server restart once durable settlement is implemented. Death discards undelivered shares; replacement characters do not inherit them. This is planned behavior, not a claim that installed 0.2.67 already banks defense XP. No rewards are generated by unloaded/stopped-server combat simulation, and no defense bank exists when the required Trait Shop integration is absent.

**Required clarification:** "50/50" is ambiguous after the earlier 50% defense-rate examples. Ask the owner which amount is intended before setting formulas:

- **1A:** keep the previous rule: 50% of normal kill XP becomes one equal owner-faction pool (owner included, solo fallback); the other 50% is unawarded.
- **1B:** 50% of normal kill XP goes personally to the turret owner, and the other 50% becomes a faction pool. This changes both total payout and the owner's entitlement; do not infer it from the earlier 50% rate. Existing owner-in-faction eligibility remains unless the owner says otherwise.

An asynchronous clarification was sent with these concrete meanings; no answer is assumed from elapsed time or a preselected option. Record the unambiguous attribution change now and leave payout-dependent implementation pending. Existing zombie/eligible PvP scope, source gates, repeat-victim cooldowns, offline-life rules and ordinary personal-kill behavior remain unless explicitly changed. A kill must never also receive a duplicate full personal reward.

Once the payout is clear, the remaining engineering concerns are compact authoritative device-owner credit, terminal/deferred-death reconciliation, recipient/life snapshots, durable receipt settlement and duplicate/cooldown handling. Exact wound percentages are no longer required. This discussion changes documents only; no production/sibling/package/install/version/Workshop changes or new runtime test. 0.2.67 acceptance stays closed. **Decision needed only for the meaning of 50/50.**

## C461 - Half-value faction pool confirmed (2026-10-25)

Owner answers the C460 clarification explicitly: **"50% of normal kill XP shared equally across the owner's faction, including the owner; the other 50% is unawarded (previous rule)."** This selects C460 **1A**. The owner does not receive a separate personal half. Do not reask this payout choice.

For an otherwise eligible credited defense kill with configured normal reward R and N eligible recipients, create one pool of R x 0.5 and reserve R x 0.5 / N for each recipient. A solo eligible owner receives the whole reduced pool. Example: normal reward 100, four eligible faction members including the owner -> pool 50, each 12.5. The remaining 50 is unawarded. Never pay a duplicate ordinary personal kill award for the same defense-credited death.

C460's kill-based attribution replaces proportional damage shares. Earlier player chip damage earns no separate assist portion in this selected defense-kill path. Ordinary player-credited kills retain existing personal reward behavior. Preserve the previously selected turret/trap integration scope, eligible zombie/PvP sources, enemy checks and account/victim cooldowns; this confirmation does not change those rules.

Include Offline Members remains default ON: reserve eligible earning-time shares for the same living character and deliver on reconnect; do not redistribute them to online members. Death discards the pending share, a replacement life inherits none, and faction/rate changes do not recalculate an already-earned share. Durable offline settlement remains to be implemented; installed 0.2.67 does not already provide it. The existing receipt/cooldown eligibility requirements still apply.

The payout clarification is resolved and exact wound-share research is no longer a gate. Coordinated authoritative device credit, Trait Shop settlement, Horde source integration and relevant native/duplicate/offline/restart verification remain. This checkpoint records the selection only: no gameplay/sibling edits, new installed package, runtime test or reopened 0.2.67 acceptance. **Wait for a patch; no further payout decision.**

## C462 - Participation-based PvP assists proposed (2026-10-25)

Owner asks whether the remaining half can be split based on who also dealt damage in the PvP flag. Treat this as a feasibility/design question, not approval to revive proportional wound damage or silently change C461's unawarded half.

### Native evidence

The installed 42.21 `IsoGameCharacter.getAttackedBy()` returns one character reference. `PVPLogTool` also has a shared rolling combat-event list: its current bytecode initializes ten entries and replaces the oldest when logging a combat event. It is not a durable victim-specific contributor set. Current `PVPEvent` exposes timestamp, wielder, target and XYZ; it contains no accumulated actual damage or character-life contribution ledger. Do not parse text logs or depend on the ten-event admin history for rewards.

Current installed `javap` results were checked against the prior C459 jar evidence; no gameplay or probe source changed. Official API corroboration: [PvP event fields](https://projectzomboid.com/modding/zombie/network/PVPLogTool.PVPEvent.html) and [PvP logging methods](https://projectzomboid.com/modding/zombie/network/PVPLogTool.html). This is static review, not a new connected assist test.

### Practical option

**1A - Equal personal assist shares (recommended if adding assists).** For an eligible defense-credited PvP death, retain the selected 50% owner-faction pool and divide the remaining 50% equally among distinct eligible players whose confirmed personal attacks injured that victim during the relevant encounter. Record participation, not exact damage amounts or subsequent bleed ticks. Example: normal reward 100, faction pool 50, two qualifying assistants receive 25 each. With no qualifying assistant, the remaining50 stays unawarded. The assist half is personal; it is not a second faction pool. The owner can qualify through their own attack, but ownership alone is insufficient. A faction member can receive their ordinary equal defense share plus their personal assist share, settled together once.

This is a proposed change to the currently selected C461 payout. It does not automatically expand assist sharing to ordinary player-credited kills or zombie kills. Previous enemy/victim/source eligibility, life ownership, offline delivery and account/victim cooldown requirements remain applicable to each beneficiary. A combined defense/assist payout must neither double-award nor consume its own cooldown between components. No eligible-recipient or unknown-share redistribution rule is silently changed.

A compact server-owned record per victim life and distinct contributor life would be needed; no unbounded per-hit history or per-frame limb scan is proposed. A raw pre-hit callback alone is not proof of injury: misses, blocked/ignored hits and zero-effect attacks must not qualify. Wound-producing hits can qualify without resolving every later tick. Verified hit coverage, lifecycle/recovery or encounter expiry, restart/disconnect behavior and duplicate receipts require a concrete implementation contract and testing. No numerical expiry, minimum damage threshold or production performance claim is approved here.

The tradeoff is deliberate: one qualifying hit receives the same personal assist share as many hits and can unlock the previously unawarded half. This rewards participation but permits light tagging for XP. Weighting by exact damage would return to the C458 wound-attribution problem; weighting by hit count would favor rapid-fire weapons and is not recommended as a silent substitute.

**1B - Keep C461:** only the 50% faction pool; the other half remains unawarded. This retains the selected simpler rule and avoids an assist ledger.

Only documentation changed. C461 remains the selected payout until the owner chooses otherwise; no gameplay/sibling/package/install/version/Workshop changes or new runtime test. Accepted 0.2.67 stays closed. **Decision needed: 1A equal personal assists or 1B keep the selected rule.**

## C463 - Equal PvP assist shares selected (2026-10-25)

Owner selects C462 **1A**. For an eligible defense-credited PvP kill, keep one pool worth 50% of the normal configured kill reward for the registered owner's eligible faction, including the owner, and divide the remaining 50% equally among distinct eligible players whose confirmed personal attacks injured the victim. With no qualifying player assist, that half remains unawarded. This supersedes C461's always-unawarded remainder for this PvP case only.

This is participation-based credit: no exact damage weighting, per-hit reward multiplication or attribution of subsequent bleed ticks. One confirmed qualifying attack and many qualifying attacks earn the same personal assist share. The owner qualifies for a personal assist only through their own attack; ownership alone gives no personal half. A player may receive their equal faction share and their earned personal assist share, combined in one settlement without duplicating the normal kill reward or consuming its own cooldown twice.

Existing source/enemy eligibility and account/victim cooldown checks apply to each beneficiary. Life-bound offline shares and earning-time membership remain selected; replacement lives inherit none. No assist expansion to ordinary player-credited kills or zombie kills is authorized by this choice. Existing trap/turret scope remains; native credited death can occur after bleeding rather than an immediately lethal shot.

The selected payout needs a compact authoritative participant set keyed by victim/contributor life, verified injury registration, device-owner credit and durable deduplicated settlement. The native single-attacker field and ten-event admin log alone are insufficient. Encounter/recovery lifetime behavior and connected coverage still need a concrete implementation and verification; do not silently introduce a numerical expiry, nominal-damage threshold or a Java dependency. No new player-facing payout choice is pending.

Recorded selection only: no production or sibling changes, version/install/Workshop change, new runtime result or reopened0.2.67 acceptance. **Wait for a patch; implementation and verification remain.**

## C464 - XP implementation approved and implemented (2026-10-25)

Owner explicitly approves implementing the XP patch. This authorizes the coordinated T&T, Trait Shop and Horde changes; no payout decision is reopened. C460-C463 are the operative design. See [0.2.68 patch](PATCH_v0.2.68.md) and [verification](TEST_v0.2.68.md).

The optional server integration records a registered device owner before confirmed lethal zombie damage. Confirmed player injuries retain defense credit until a later native attacker or full recovery replaces it; delayed bleedout can therefore settle the same defense kill. Native synchronous post-hit injury evidence records distinct personal assistants. It does not infer wound percentages or parse admin logs. A player who both belongs to the owner faction and assisted receives the two portions in one cooldown transaction. No assist portion is created on ordinary personal kills or zombie kills.

Server GlobalModData holds earning-time recipient lives, fixed amounts, pending shares, account cooldowns and victim participation. Same-life reconnect delivers once; replacement/death drops undelivered shares. Current native faction membership and Horde earning permission are consulted when earning. Offline identity eligibility is supplied by Horde; casualty/left/vigilante event participants cannot earn through this route. Completion rewards and defense score/consent remain on existing paths. No unloaded combat simulation is added.

Client injury receipts only confirm a server-selected injury to the authenticated recipient with a single-use token and bounded transport grace. They cannot choose source ownership or XP. Full-recovery replies are matched to the current encounter; stale replies cannot clear newer injuries. The five-real-second receipt grace and one-real-second recovery polling are networking safeguards, not gameplay encounter expiry. Missing/expired receipts do not establish defense XP. Client body-state confirmation follows the existing native health authority boundary and is not an anti-cheat guarantee against a modified victim client.

General Sandbox adds Shared Defense XP, Defense Faction XP (Percent), and Include Offline Members, defaults ON/50/ON. Traps-only aliases remain independent. Horde records these reviewed settings without asserting broader official approval of every later T&T setting. No Traits/Shop means no defense reward bank. Existing passive devices with no recorded builder remain unattributed; do not invent an owner. New/redeployed owned defenses retain ownership through the authoritative portable registry.

Implementation and automated verification are complete; installation/tag/mirror evidence is recorded separately. Connected-client transport, concurrent PvP deaths, real bleedout/reconnect and visual XP acceptance remain unverified. The previous SP acceptance is preserved. No Workshop release is claimed.

## C466 - Minimum positive split and SP identity correction selected (2026-10-25)

The owner requires at least1XP when an eligible positive split would be below1. Merge all portions owed to the same recipient for the action/death first, then apply the minimum once before award or offline banking. Do not award when configured rewards are zero, earning is disabled, or eligibility/cooldown/life checks fail. Do not apply twice to faction plus assist participation, duplicate events or later delivery. Leave fractions at or above1 unchanged. This explicitly permits the recipient minimum to exceed the original shared pool: a1XP pool divided between four eligible members pays4total. It does not substitute full normal rewards for each member or authorize a new faction cap/rebalance.

The C465 playtest's seven defense kills plus two ordinary kills should pay11XP at solo normal2XP/50% settings. Native startup inspection plus production Kahlua replay reproduce the reported4XP: the defense member/index caches the constructor's Bob username, then SP native updateUsername changes it. Current actor-bound manual rewards work; name-based device credit finds no recipient. Reconcile only verified same-life metadata/index changes, preserve stable account/life identity and remove stale lookup entries; retain MP authority and life-bound offline delivery. No guessed attribution or fabricated backpay. Add regression coverage for startup, same-life reload, replacement characters, duplicates and positive minimum online/offline. Logging must explain submitted deaths, attribution, eligibility, paid/banked amounts and skipped reasons without per-hit spam. Combined corrective patch approval is pending; no current gameplay change.
