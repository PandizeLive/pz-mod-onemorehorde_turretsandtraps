# Shared defense XP: deeper wound-attribution investigation

## Selection and conclusion

On 2026-10-25 the owner selects C457 **1B**, continuing investigation before shipping shared XP. Confirmed-damage-only coverage was not selected. The approved 50% defense rate, owner-faction pool, proportional actual-health accounting, eligible PvP and life-bound offline shares remain intact.

The expanded installed-game probe passes. A small ledger could retain a source when a known attack creates a wound, but native wound state does not preserve separate contributions when wounds overlap. Later health snapshots cannot recover all damage either, because healing and silent wound damage can occur together. **Exact per-source wound attribution is not recoverable from these callbacks and stored values alone.** This is a finding about the current interfaces, not proof that no engine modification could ever implement attribution.

No production integration, Java gameplay dependency, replacement wound system or estimated reward rule was introduced. The accepted 0.2.67 build remains installed and its SP test round remains closed.

## Reproduction and evidence

Run `python tools/probe_defense_xp.py` using the installed Windows game and JDK 17. It starts the isolated stock server described in [C457](DEFENSE_XP_PROOF_C457.md), loads synthetic actors, invokes native methods on the actual Lua owner thread, captures evidence and exits. It does not load the owner's save or install a gameplay package.

- Game: 42.21; jar SHA-256 `e1a69eb743ede60b213a0fe7f8b83d4fcab773036d256cc4543a336f3b058a33`.
- New fixture: [native_wound_attribution.lua](../tools/tests/native_wound_attribution.lua).
- Native serialization check: [NativeDefenseXPProbe.java](../tools/NativeDefenseXPProbe.java).
- Final run: **pass, 92.7 seconds**, including stock startup and orderly shutdown; `completed=true`, `packetPostHit=true`, `woundSerialization=true`, `packetCompleted=true` and runner `success: true`.
- Ten isolated wound cases, repeated-injury checks, 64 bleeding rerolls, a healing counterexample and an in-memory serialization round trip passed. The C457 direct-hit/limb/packet checks also passed again.
- Local raw evidence: `diagnostics/defense-xp-feasibility/result.json` and `native-xp.log`; reproduction tools and this report are mirrored. The initial expanded run passed in 95.0 seconds. A probe-only multiplier-restoration issue was then corrected and the final run asserts that the effective multiplier is restored.

| Native operation | Measured result | Consequence |
| --- | --- | --- |
| Scratch, cut, bleeding, mixed wounds and bandaging | All five cases pass at effective multipliers approximately 0.8 and 4 | A limited isolated damage predictor matches native loss within 0.0001 health; this is not a complete body-health model |
| Scratch or cut without bleeding | Damage occurs with zero `OnPlayerGetDamage` callbacks | Listening only for damage events omits real wound loss |
| Bandaged fixture | Zero damage and zero callbacks | State changes matter to any model |
| Reapply a cut/scratch with an existing timer of 100 | Cut becomes approximately 17.5606; scratch becomes 13.1153 | Native same-type injury replaces the timer; it is not a list of additive wounds |
| Generate bleeding 64 times with scratch and cut timers both fixed at 10 | Aggregate bleeding ranges approximately 3.2382 to 4.6943; source timers remain 10 | Existing wounds contribute new random terms to one aggregate; a delta is not the latest attack's exclusive contribution |
| Heal, then update a scratch | Overall health rises from 96 to 96.1993179 while the limb loses 0.0034256; zero damage callbacks | Net before/after health can hide damage that actually occurred |
| Native BodyDamage save/load in memory | 17 parts x 5 compared fields match; 2,340 bytes, world version 249 | Selected stored state round-trips; this is not a restart or source-ledger persistence proof |

The serialization fixture ends with an active scratch and otherwise mostly reset wound state. It compares health, scratch/cut/bleeding timers and bandaging; it does not certify every wound combination, all BodyDamage fields or custom source persistence. Effective multiplier inputs differ from the values returned by the engine; the observed fivefold comparison is not a connected fast-forward test.

## Current native implementation

`javap -c -p` against the installed jar confirms the relevant paths. The older 42.20.2 decompile was a discovery aid, not the compatibility authority.

- `BodyPart.setCut` and `setScratched` store a replacement duration and call `generateBleeding`. The part has one timer for each wound type, without a per-wound attacker/device identity.
- `BodyPart.generateBleeding` combines randomized terms from the current wound types into a single bleeding timer. Scratch uses a random 0.3-0.6 multiplier and cut uses 0.7-1.0 before common severity/body-part factors. Other wounds add further terms.
- `BodyPart.DamageUpdate` applies scratch/cut damage without the bleeding callback. Its bleeding callback lacks body-part/source arguments, as already demonstrated in C457.
- `BodyDamage.Update` also has whole-body severe-bleeding damage and healing. Callback position/count cannot universally identify a specific wound, and polling only net health misses loss masked by healing.
- `IsoPlayer`'s `OnPlayerUpdate` dispatch belongs to its local-player path. It must not be treated as a server-wide before/after hook around every remote player's body update.
- Known T&T injury creation can be tagged directly, and some native hit paths offer useful before/after observations. This does not expose every later native operation or other mod's direct health mutations. Existing T&T player-injury commands still lack server-confirmed actual-result receipts.

For an illustrative identifiability example, scratch10 + cut10 can yield the same pre-modifier bleeding sum13 through either 3.5 + 9.5 or 5.5 + 7.5. Different sources could own the scratch and cut. The same stored total therefore does not reveal the actual random contribution of either source. This is analytical arithmetic from the verified ranges, not a claimed paired seeded runtime observation.

## Approaches evaluated

**Record sources at wound creation.** Useful and relatively compact: at most 17 parts per tracked player with a fixed set of wound types. It avoids needing native attacker IDs later. However, assigning a new owner when the same type is replaced and sharing rerolled aggregate bleeding are gameplay accounting rules. The engine does not supply a uniquely correct split.

**Poll every limb and attribute net loss.** Insufficient, as the healing counterexample demonstrates. Additional sampling cannot recover random components already combined before a callback. Continuous scanning also adds work. No stress benchmark or production scheduler has been completed, so no FPS claim is made.

**Mirror the native wound calculation.** The ten isolated cases demonstrate a small subset, not full correctness. Healing, low-health clamps, other wound types, severe-bleeding damage, movement/traits, execution order, client authority and other mods remain. Maintaining a second health simulation just to award XP is a substantial compatibility burden. Do not call its predictions confirmed actual damage.

**Intercept or replace native damage internals.** Lua overrides of exposed Java methods do not intercept Java's internal method calls. A Java-level hook/dependency could expose additional operations but would expand installation and update compatibility requirements, and merged wounds would still require a source-sharing policy. This was not authorized and is not recommended for this XP feature. No game jar was modified.

## Concrete choice after investigation

**1A - Defer shared XP while retaining the exact requirement (recommended).** Preserve the approved design on the roadmap, ship no partial XP implementation, and move to another selected work track once the owner chooses it. The current evidence does not justify the compatibility and simulation complexity for exact wound attribution. This is a new recommendation based on the deeper proof, not cancellation of approved work without consent.

**1B - Prototype explicitly estimated wound credit.** Keep measured direct-hit contributions; use a documented model for delayed wounds. A concrete candidate records the source for each limb/wound type, replaces that source when the native same-type timer is replaced, and shares aggregate bleeding according to expected contributions from current wound timers. For scratch10 and cut10, expected weights are4.5 and8.5, so that modeled split is34.6%/65.4%. Clearing a wound clears its source; bandaging suspends its open-wound contribution. Unknown sources retain an unpaid share. This includes wound credit rather than dropping wounds, but the source split and modeled silent damage are estimates, not the approved exact actual-health rule. A bounded prototype must first prove acceptable error, authority, persistence and runtime cost; this option does not promise a shipping patch or authorize a Java dependency.

Neither option changes the selected reward rate, faction recipients, PvP eligibility, Trait Shop source/cooldown rules or offline-life ownership. No fallback to zombie-only or final-hit rewards is inferred. C457's confirmed-only option remains unselected; it is not relabeled as full wound support.

## Scope and verification limits

Changed only isolated probe tooling and project documentation. No Source/Contents, sibling source, package/version, installed mod, Workshop draft or publication change. Python compilation and whitespace checks pass. The unchanged gameplay suite was not rerun. Synthetic actors on a zero-client native server are not connected multiplayer transport, full death ordering, persistent reward settlement or a performance stress test.

**Decision needed: 1A or 1B.** No owner playtest is requested for this research checkpoint.
