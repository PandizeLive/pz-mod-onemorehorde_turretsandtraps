# C246 — production multiplayer implementation

2026-10-14. Owner instruction: complete multiplayer support, continue without another approval or owner-test gate, and push progress to GitHub. This implements the remaining multiplayer paths for the existing turret/trap roster. It is development source, not a new installed version or a claim of connected-client acceptance. Earlier C236–C245 restrictions are historical where superseded below.

## Production behavior

- Server-controlled automatic/manual firing, targeting, ammunition, reloads and battery/generator use now run in multiplayer. Firearm, Potato, Ballista and rotary damage use the shared authority path. Fragment, Martyrdom, Tack and delayed projectile effects retain bounded scheduling and root-effect reservations until their hit results complete.
- Spike Barrier retaliation, Bed Spikes trips/fall damage and Panel/Concertina contact run on the server. Remote-owned zombies receive owner-specific reactions; observers receive the custom forward-collapse presentation. Contact slowdown needs both a short server lease and actual local contact, so leaving the wire restores normal movement immediately. Existing construction, repair, pickup, Building repetition and independent package behavior remain.
- Damage requests are serialized per victim, with bounded queues and deadlines. Receipts survive actor unload/recycling in a bounded archive. Ownership changes query the previous receipt and reconcile confirmed health on the new owner instead of subtracting damage twice. The server owns terminal death and Horde attribution; no fake player attacker or weapon XP is introduced.
- Exact native identity, receiving Horde run and consent are checked throughout the asynchronous operation. Assistance is marked before commit, including when another attack kills the zombie before the defense receipt returns. Runtime strike/proc/contact bookkeeping is private on the server.
- Manage controls, contextual menus, range feedback, native inventory tooltips, head rotation and the sprite fallback operate on client views. Nearby clients receive bounded sound/projectile/contact facts; split-screen duplicate presentation is suppressed. Tack snapshots support late join and movement between areas, with spatial lookup and bounded expiry work.
- Player injury commands select the actual local recipient and deduplicate delivery. Existing bruise/cut rules, shared rotary protection, God/NoClip exemptions and contact-only movement are retained.
- Generator changes synchronize in bounded batches. Battery use retains fractional charge because the native setter rounds to whole uses; otherwise the configured small per-shot costs disappear. The remainder follows the exact battery through private persistent item state and is reflected in inventory/Manage views. No native item capacity or global weapon stat changes.
- Both independent packages expose the same Horde capability contract. The existing /5 divider, explicit receiving-run opt-in, default-or-harder review and neutral collision policy remain unchanged.

## Horde attraction safeguard

Native world sounds attract zombies without a per-zombie consent filter. The coordinated Horde core now permits automated defense attraction only when every active, non-eliminated Horde event has confirmed defense consent. While any such event has not opted in, defense world-attraction sounds are suppressed; audible client effects remain. This also suppresses attraction of ambient zombies during that interval. An older core without the capability fails closed for defense attraction. This conservative implementation enforces the already-approved opt-in rule without changing shared collision or inventing selective native sound APIs. Deploy the matching core changes together.

## Verification

- Stock Build 42.21 validation: **20,319 assertions**, **161 runtime/translation files compiled**, **808 native translation entries**, **251 source / 309 packaged files** (118 Traps / 191 Turrets). Banned-call checks pass; no shipped `pcall`/`xpcall` added.
- Tests cover ownership changes before/after application, archived receipts, duplicate/recycled identities, changed Horde consent, per-victim ordering, asynchronous effect reservations, owner/observer reactions, contact exit, split-screen injuries/presentation, Tack snapshots/expiry, canonical replicated Bed identity and 10,000 quantized battery deductions plus serialization/depletion.
- Native dedicated-server production callbacks confirm real firing damage, one-round consumption and effective battery loss, alongside placement/Manage/trap services. Fixtures use real native items/actors and synthetic unmapped squares with explicit lookup shims. **Zero clients connected.** This is runtime/API evidence, not an actual network handoff or mapped-world test.
- Separate write/read server processes pass inventory, packed-item, charge/condition, turret/trap identity and persistence checks. Independent Traps, Turrets and combined server startup/shutdown probes pass (58.7 / 47.7 / 48.8 seconds). Later changes to observer presentation, private strike bookkeeping, menu imports and package descriptions are covered by the final validation/authority probe; independent startup was not repeated for text-only metadata.
- Coordinated Horde production resolver tests pass **462 assertions**, including consent-aware world-sound admission, startup fail-closed and finished-event behavior; **109/109** packaged Horde Lua files compile in installed Kahlua.
- Mock stress: 600 ammo items transfer in 30 bounded batches, about 5.30 ms maximum per fixture batch in the final run. This is not an in-game frame-time claim. Earlier native fixture failures exposed a missing square lookup and then real native battery quantization; both were corrected and rerun. Existing native Guid/world-property warnings remain; no blanket error-free game claim.

Local evidence: `diagnostics/c246-multiplayer/validation.log`, `manifest.json`, `horde-validation.log`, `final-authority-server/server.log`, `persistence/`, `packages/`; console transcripts `.tmp/c246-persistence-{write,read}.log`. Selected summary evidence is mirrored with this record; large native caches stay local.

## Explicit limits and retained scope

The receipt protocol is bounded best effort, not an exactly-once network guarantee. If an owner disconnects after a commit and before an observable receipt, the unresolved hit expires without replay; an unconfirmed hit can be lost. Confirmed hits are not intentionally applied again, and committed ammo/power are not refunded. Native `extraUpdate()` requests prompt health replication but is not a packet-ordering barrier. Simultaneous native attacks, unreliable packet reordering, actual ownership migration/reconnect, remote animations and rendered UI/audio still need connected dedicated/listen-server evidence. Mocks and zero-client probes cannot certify those behaviors or prove hostile-client security.

R1C3/R5C1 **implementation for the existing roster is present**; connected runtime acceptance remains open. R5C2 core/website integration still requires coordinated deployment and end-to-end scoring acceptance. No Workshop upload, website deployment, main merge or live test has occurred here.

The separately approved C235 content bundle remains retained: full Lobber/Scrapshot/Lure/Void gameplay and revised ammunition/head integration are not made complete by this multiplayer port. Void transaction foundations have authority tests but are not a complete exposed item workflow. The owner has not approved splitting the combined release; therefore the installed 0.2.49 and immutable test tag stay unchanged. This is not a request for another implementation approval or for the owner to test now.

## Short connected check when the combined candidate is ready

1. Two clients: build, load and manage one turret; concurrently attempt the same pickup/transfer. Verify one exact outcome and matching contents after replacement/reconnect.
2. Fire while zombies move between clients; include one disconnect during combat. Check health/deaths, ammo/power and secondary effects agree without duplicate kills.
3. Cross each trap, then leave wire contact; compare trips, recovery, damage, player exemptions and audio from both views.
4. Restart the server; inspect devices, modules, batteries and inventories. Compare opted-in versus non-opted Horde effects and the single /5 score deduction.

Owner testing remains deferred. Review both client consoles and the server log before recording acceptance.
