# C236 combined patch development checkpoint

The owner approved the C235 combined patch and added multiplayer verification with player testing deferred. Implementation starts from073a878 on `codex/performance-barbed-audit`. **This is an incomplete, untagged development checkpoint, not a completed patch or install.** Installed0.2.49 stays unchanged. The full approved contract remains in [Void/capacity readiness](VOID_MODULE.md#c235-final-capacity-selected-ready-for-implementation-2026-10-14), [head proposals](TURRET_HEAD_PROPOSALS.md), and [remaining-choice resolutions](NEXT_PATCH_CHOICES.md).

## Implemented and checked in source

- Pack Skip/Collect flow: neutral Skip finishes all reels on the already granted rewards; green Collect appears afterward. One selection and highest-rarity cue play at whole-roll completion, including Skip. Collect cannot replay or stop the rarity tail. Six-second reels,150ms row stagger and four-second row fades remain.
- Ammo-family foundation: whole native potatoes, explicit opt-ins/overrides, cached native spear-category classification, verified explosive roster and firearm ammo registration. Spear damage uses the approved25%relative contribution. No display-name matching or general Vegetables classifier.
- Void storage foundation: exact-module scalar/group metadata, physical-source removal before credit, compatible counts, per-type Conservation debt and rejection of duplicate conversion, overdrafts, stale group bindings and unknown schemas. Relevant spear condition/damage and potato state remain. Read-only queries do not initialize empty state. MP mutation gates remain.
- Multiplayer audit: [confirmed SP-only restrictions and pending port](MULTIPLAYER_AUDIT_C236.md).

The two new helpers are **not yet connected to production acceptance, firing, UI, recipes or loot**. No obtainable Void item or enabled virtual magazine is claimed. Their presence in generated Contents is dependency/compilation parity for this development checkpoint, not release readiness.

## Actual verification

`OMHTT_STOCK_CLASSES=1` with `tools/validate_foundation.py` (its OUTPUT set to `diagnostics/c236-dev` for this untagged checkpoint) passes18,229 assertions and122 runtime/translation compilations. `tools/build_packages.py` / `tools/verify_packages.py` establish270 generated files, independent entries and closed Lua dependencies. No protected calls were added; the banned-call gate passes.

The Void test converts600 mock rounds into one quality group, rejects repeat/failed conversions, preserves fractional debt and donor state through the native Kahlua table serializer, and rejects stale bindings after restoration. A measured4.50ms for that entire synthetic batch is **not** a game-frame budget or proof that native inventory conversion will be that fast. The actual conversion action still needs bounded admission and exact-item/native save-load checks.

Pack checks cover natural completion, manual Skip, duplicate finish, Collect, cached rendering and small viewports. They do not establish rendered/audio acceptance. No player test or live multiplayer session ran. Raw reviewed evidence is kept under `diagnostics/c236-dev`, separate from the prior0.2.49 release evidence.

## Remaining approved work

1. Wire physical/virtual ammo into reloads, safe head/module removal, payload priority/fallback and Manage. Prove actual InventoryItem persistence, bounded conversion, Conservation debt portability and no virtual-round materialization or free Impact rearming.
2. Implement Grenade Lobber, Makeshift Bomb, Scrapshot, Lure and their approved recipes, power, loot/LootLab and UI metadata.
3. Complete Ballista travel/range/magazine, rotary reach/coverage/Tack/Martyrdom, Potato Piercing/contact behavior, shared explosive capacities, compatible spear/potato ammo and bounded secondary effects.
4. Run native transactional/persistence/package checks, assign the combined feature version, commit/tag and install through OMH.cmd. Preserve cumulative Workshop notes. Mirror the completed candidate and findings. Player testing remains deferred.

No new generic design approval is required to continue these steps. Do not promote this checkpoint to a completed0.2.50, reuse the immutable0.2.49 tag, or infer multiplayer support from negative guard checks. Keep the combined patch scope intact.
