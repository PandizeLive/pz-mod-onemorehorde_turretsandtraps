# C238 - Multiplayer and Horde Night scoring patch preparation

Date: 2026-10-14. Status: prepared implementation specification, not a playable patch or MP certification.

Owner: "This mod is supposed to work with OMH: Horde Night, and it'll be allowed to be used with a Score Divider. We need to make sure it's safe to add and score. Brush up on Horde Night, and prepare a patch for Multiplayer integration."

This authorizes preparation of coordinated Horde Night compatibility and confirms the intended Allowed-with-divider policy. MP remains an original requirement; the combined C235 content patch remains approved and unfinished. C239 selects the three policies below: divide by5, per-run opt-in, and default-or-harder eligibility. O07's x0.20 is now confirmed. No separate assisted edition or automatic world-wide penalty is selected. No live owner test is requested now.

## Reviewed evidence

- T&T branch `codex/performance-barbed-audit`, base `a08e9c96ebe7af749e7dd7bb1becaf56767ff4da`; Horde Night local release-preparation base `c904ee4333c8494a78bddb2669b1a9d46708552c` (0.6.16.5). Both remotes fetched; no newer `origin/dev` or Horde `origin/main` commits missing from their respective local histories. Horde `origin/main` was `e12ccca3ed67ff1bdc6f5af6c5aaf49cd94b49b6`. Local release preparation is not proof of publication.
- Read the latest available OMH: Website, OMH: Presentation, OMH: Horde Night and OMH: Cure Defense chats, plus the newer Investigate Horde Night reset bug chat. Website copy and Presentation link work do not conflict. The old Cure reconnect report is historical; it does not establish a current defect. Current Horde work is a prepared 0.6.16.5 release; preserve it and its pending cumulative notes. No other chat was messaged.
- [Horde Extension API](../../pz-mod-onemorehorde_protectthecure/docs/EXTENSION_API.md), API 3: lifecycle/reward notifications are authoritative, but `onKill` is an already-credited participant notification, not an API for reporting a device kill. Score policy metadata cannot award an Official multiplier.
- [Score rules](../../pz-mod-onemorehorde_protectthecure/Contents/mods/OneMoreHorde_HordeNight/42.20/media/lua/shared/OMH_ScoreRules.lua): schema 5 supports Cure +20% and Trait Shop x0.50. Its normalizer recognizes deduction totals only for `trait-shop`. Simply adding a T&T label would lose or reject deduction facts on normalization/export.
- [Death handling](../../pz-mod-onemorehorde_protectthecure/Contents/mods/OneMoreHorde_HordeNight/42.20/media/lua/server/OMH_Phase3HordeEngine.lua): `onZombieDead` validates exact event identity and retirement/death markers, increments confirmed event deaths independently of participant credit, and may finish an eliminated event immediately. `creditParticipantKill` uses `getAttackedBy()` and the player's currently held item. T&T must not fake a player attacker or let a device finishing blow accidentally use stale player attribution.
- [T&T Damage.apply](../Source/42.20/media/lua/server/OMHTT/Damage.lua): all current direct/trap/module damage converges here, but it rejects MP. Its notification currently happens after native death processing; that is too late to establish assistance on an event's final kill. This is a verified ordering hazard, not an observed MP scoring exploit.
- [Horde exact-ID whitelist](../../pz-mod-onemorehorde_protectthecure/Contents/mods/OneMoreHorde_HordeNight/42.20/media/lua/shared/OMH_ModWhitelist.lua): neither `OneMoreHorde_Turrets` nor `OneMoreHorde_Traps` is currently listed. Approval, functioning compatibility and historical record eligibility are separate facts.
- [Website score validator](../../OMH%20Website/cloudflare-api/src/score-modifiers.ts) accepts only `cure-run` and `trait-shop`; [review policy](../../OMH%20Website/cloudflare-api/src/review-policy.ts) checks reconciled totals. Game and validator changes must agree before new T&T records are accepted. No deployment or database update is included in preparation.
- Reran Horde Night `tools/validate-mod-settings.py` against the installed game Kahlua: **149 settings, persistence and score assertions pass**, including existing multiplicative Cure/Shop behavior and repeated normalization. This is existing-policy baseline verification, not T&T/MP acceptance. No gameplay code changed for this preparation.

## C239 - Selected scoring policies (2026-10-14)

Owner selects **1A / 2B / 3B** from C238. These selections replace the recommendations below; they are approved design, not implemented or verified gameplay.

### 1. Score Divider

**Selected1A: divide by5, retain20%.** Confirms the existing O07 proposal. No measured equivalence to unassisted survival is claimed; preserve the approved value pending actual balance evidence.

One T&T modifier covers either selectable package or both, independent of device/module/player counts. Preserve multiplicative composition with approved modifiers and round the combined award once at the core boundary. For an illustrative unmodified score of100, A yields20; with Trait Shop10; with Cure and Trait Shop12. No kill, Horde or Trait XP counts are divided. This does not choose a shared-XP percentage.

### 2. Activation scope

**Selected2B: explicit per-run opt-in.** Merely enabling either package does not select the divider for everyone. Use Horde Night's authoritative run identity and existing permission checks for run configuration; a client, nearby device or other faction cannot silently opt a run in. Borrowing a defense cannot bypass the receiving run's consent or duplicate its modifier. Device ownership and server-validated permission remain required for service/resource actions, independently of scoring.

Enforcement work: resolve the affected Horde event before special damage, slowdown, knockdown or delayed effects, not only on death. Recommend using the receiving run's opt-in to permit those effects, including borrowed defenses; never fake a player killer or force a divider on an unconsenting run. Native obstacle collision and sound attraction are separate feasibility checks: ordinary blockers and world sounds cannot be assumed to filter by event identity. Check Lure and barriers explicitly before claiming unassisted eligibility. If those effects cannot be isolated safely, present the concrete limitation and policy alternatives rather than silently enabling the world-wide rule or changing consent. This is an implementation investigation, not another request to reapprove2B.

Once applicable, mod removal, disabling a setting, reconnect or borrowed-device transfer cannot clear that run's mark. Apply only to future awards, including a currently active event affected after activation; never recalculate already completed events. Preserve prior eligibility flags and frozen Official scores. Pre-integration benefit history remains unverified rather than retrospectively certified. A new run alone cannot certify a retained character/world as previously unassisted without the selected policy's provenance.

### 3. Official settings baseline

**Selected3B: default-or-harder settings audit in the initial integration.** Audio/UI changes do not affect eligibility. Unknown or easier gameplay settings remain Custom/unverified with explanations and without overwriting the owner's settings. Do not reduce this selection to a defaults-only first release.

Audit each active gameplay setting and its consuming code for direction, disabled behavior, bounds and interactions. In particular,0can mean disabled/unlimited rather than harder; loot weights are relative, so lowering a weak module's weight can make strong modules more likely; rarity anchors also influence power costs. More damage/health/capacity/range, faster firing, cheaper power and stronger proc effects cannot be blanket-approved. Classify combinations against the reviewed version baseline and preserve historical provenance after restoration/removal. Ambiguous or missing values stay unverified rather than being guessed harder. Reuse Horde's existing integrity vocabulary and test its dedicated-server polling path.

Other enabled mods still follow Horde Night's own policy. T&T approval cannot approve unknown firearm mods, altered scripts or the whole mod list. These choices concern Official eligibility, not whether standalone/custom gameplay can function.

## Implementation work order inside the combined patch

These are engineering steps, not separate owner acceptance rounds or a silently split release. Keep the content bundle intact; do not expand SP-only code first and postpone MP again.

1. **Production server lifecycle and transactions (R1C3/R5C1).** Place, load, operate and pick up one real turret through the authoritative path, then reuse it for all approved heads and service actions. Server re-resolves coordinates/device identity and item IDs, validates reach/permission/version/revision and capacity, and serializes overlapping requests. Complete actions on the authoritative side with native inventory synchronization. Repair/pickup durations and approved resources stay unchanged. Client-supplied damage, battery, score, ammo totals and owner claims are never authoritative.
2. **Combat ownership and attribution (R5C1).** Verify native zombie ownership, health, death and corpse propagation on installed42.21. Keep source device and resolved impact identity through projectiles and delayed Fragment/Tack/Martyrdom effects. Establish authoritative source context before native damage/death, clear it safely, and provide Horde Night a narrow trusted server-side lookup. Proposed boundary only: no existing API is claimed. No remotely callable award command and no private-ledger mutation from T&T. SP shares rules; presentation stays client-only.
3. **Horde-owned death integration (R5C2 scoring subset).** Horde checks its own active event, generation, exact zombie identity and retirement markers. Native confirmed death remains the single quota/death path. Device facts suppress accidental ordinary-player credit and identify defense help before terminal event scoring. Never increment confirmed deaths from both T&T and `OnZombieDead`. Duplicate callbacks, competing defenses, player/device mixed damage and delayed effects cannot pay twice. Keep true player finishing blows distinguishable. Shared Trait Shop XP remains its separate unsettled reward contract, not a fabricated player kill or a new grant in this patch.
4. **Horde-owned eligibility and score policy.** Add explicit recognition for both exact package IDs with a single common assistance identity, supported integration version and selected settings baseline. Snapshot approved policy/divider on the affected run/event. Preserve historical flags, pre-checker uncertainty and Official-boundary behavior. Do not falsely declare a neutral extension or rely on `assisted` metadata as an Official multiplier. A supported core capability/version handshake distinguishes integration from mere addon presence; absent/older Horde remains safe standalone/custom rather than claiming verified Official scoring.
5. **Versioned score arithmetic and export.** Extend the core's recognized reduction registry, award math, modifier aggregation, normalization and schema readers; retain schema4/5 history unchanged. Record exact reduction bases/factors with bounded integer values. Define an attributable decomposition whose sum equals the single rounded final award; do not halve or divide historical totals during load. Update Difficulty Settings/score explanations, export, website accepted schema/modifier arithmetic, flags and review-policy tests together. The addon cannot choose arbitrary factors through client data.
6. **Complete approved gameplay integration.** Wire Void, mixed ammo/magazines, new/revised heads and all trap contacts into the same authority/resource path. Server handles pack rewards once; clients run Skip/Collect visuals only. Retain individual Bed Spikes durability, paired Concertina/Barrier identity and existing independent package combinations. The unfinished C235 bundle is not replaced by this integration work.
7. **Persistence, bounded replication and acceptance.** Reconnect/late join restores authoritative device state; inventories and module-owned Void counts/debt survive reload and movement. Replicate compact relevant state/effect facts with sequence protection, not full inventories or scoring state every tick. No per-frame global zombie/world scans or network round trip per pellet. No new promise of unloaded/offline defense simulation; Cure simulation stays last.

## Expected coordinated files

| Project | Areas |
| --- | --- |
| T&T | `Damage`, turret/trap server runtimes, shared timed actions/commands, device identity/ownership and inventory adapters, client presentation/Manage, module-pack reward authority, Void, package builder and MP/native tests |
| Horde Night | `OMH_Phase3HordeEngine`, narrow extension capability boundary, `OMH_DifficultyRuntime`, `OMH_ModSettingsIntegrity`, `OMH_ModCompatibility`/exact-ID recognition, `OMH_RunFlags`, `OMH_ScoreRules`, score aggregation/export/UI and existing policy fixtures |
| Website | `cloudflare-api/src/score-modifiers.ts`, run flags/review policy, supported schemas/versions and score explanations; matching validator tests before deployment |

Sibling changes needed for this integration are now identified, but no sibling files were edited, pushed or deployed during preparation. Preserve Horde's current release-preparation tree and manual mirror workflow. T&T planning continues its standing automatic development mirror. Website implementation must follow its own instructions/Cloudflare skills and preserve unrelated changes. Public publication/deployment is a separate final action after a concrete verified candidate exists.

## Minimal developer verification matrix

- SP, one-player dedicated, listen host and two observers; Turrets-only, Traps-only and both; Horde absent, supported and older/missing capability.
- One placement/load/fire/pickup cycle with exact item/battery/ammo counts; duplicate completion, stale revisions, remote requests, simultaneous pickup/service and disconnect during conversion.
- One tagged final Horde zombie killed by each direct/trap/delayed-effect family: one death, one quota update, correct defense attribution, divider applied before completion; ambient/retired/foreign-event zombies never counted as an eligible Horde death.
- Genuine player finishing blow after defense damage; device finishing blow after player damage; multiple observers and duplicate callbacks; neither double credit nor fake Trait Shop XP.
- All difficulties with T&T, Shop and Cure combinations; both packages count once; repeated save normalization/export/import leaves totals unchanged; unknown factors and forged reductions rejected; schema4/5 history preserved.
- Mid-event activation/settings change, restart, mod removal and new run with retained resources; historical flags/frozen scores never cleared. Bounded traffic and frame cost under the combined heavy-module/secondary-effect/trap load.

Run automated/native checks while owner testing is deferred. Keep tests for real network ownership/concurrency distinct from mocks and serialization. Present one short owner test only when a coherent candidate exists; do not claim MP, official leaderboard readiness, installed content or publication from this preparation document.
