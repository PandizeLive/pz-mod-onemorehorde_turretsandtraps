# Shared defense XP: native attribution proof

**C458 follow-up (2026-10-25):** Owner selects this checkpoint's **1B**, continuing deeper wound investigation. The [expanded results and new tradeoff](DEFENSE_XP_WOUNDS_C458.md) supersede the pending choice below. Confirmed-only coverage remains unselected; the original measurements remain historical evidence.

Owner approval: 2026-10-24, "Approved", following C456. This authorizes progressing the selected work; it does not authorize replacing proportional rewards with final-hit credit, dropping PvP, or changing offline life ownership. The isolated proof identified a material coverage limitation before production integration.

## Reproduction and boundary

Run `python tools/probe_defense_xp.py` with the installed Windows game and JDK 17. The runner compiles its Java fixture, starts a private stock-first 42.21 server on loopback ports 29341/29342, loads only its temporary probe mod from `diagnostics/defense-xp-feasibility/cache`, captures results, and shuts down. It never installs a gameplay mod or edits the owner's saves. `PZ_GAME_DIR` can override the game directory.

Installed `projectzomboid.jar` SHA-256: `e1a69eb743ede60b213a0fe7f8b83d4fcab773036d256cc4543a336f3b058a33`.

Fixtures: [Lua observations](../tools/tests/native_defense_xp.lua), [native packet fixture](../tools/NativeDefenseXPProbe.java), [runner](../tools/probe_defense_xp.py). The Java fixture queues its work onto the game's actual Lua owner thread through a probe-only event. It calls the installed `WeaponHit.process` implementation without sending a network packet. This is not a shipped Java dependency or connected multiplayer test.

## Measured results

| Native operation | Observation | Accounting consequence |
| --- | --- | --- |
| Ignored Hammer hit with input 0.2 | Both pre-hit callbacks run; health loss is zero | A callback input is not earned damage |
| Accepted Hammer hit with input 0.2 | Actual health loss approximately 0.03 | Use measured loss, not nominal damage |
| Two sequential direct `Hit` calls | Second pre-hit callback sees first hit's result | Ordering is observable for this isolated sequence; it does not prove safe attribution across intervening damage |
| Direct native `Hit` | No `OnWeaponHitXp` callback | The post-hit event is not universal |
| Native server `WeaponHit.process` on the Lua owner thread | Health moves from 0.9400000572 to 0.9100000858; post-hit callback sees that final value | This specific path supports a verified before/after measurement |
| 20 damage to a forearm | Limb loses 20; overall health stays stale at 100 until recalculation, then becomes 96 | Limb damage cannot be paid as overall health damage |
| 1,000 damage to a limb | Limb health clamps at zero | Overkill must not increase contribution |
| Equal bleeding on two different forearms | Two identical callbacks: victim, `BLEEDING`, amount; no additional arguments | Callback alone cannot identify limb, wound, attacker or device |

The two-limb fixture lost approximately 0.0026092529296875 overall health. The exact small amount is a fixture result, not a proposed balance value.

Final runner: **pass**, 91.8 seconds including stock startup and orderly shutdown. It reports both `completed=true` and `packetCompleted=true`, validates the actual Lua owner thread, and records `success: true` in `diagnostics/defense-xp-feasibility/result.json`. No connected clients or actual packet transport were exercised. Python compilation and `git diff --check` also pass; the unchanged gameplay suite was not rerun.

## Current-bytecode cross-check

`javap -c -p` against the same installed jar confirms:

- `WeaponHit.set` currently accepts five floats and four booleans; `process` accepts attacker, victim and weapon. Earlier decompiled signatures differ.
- `WeaponHit.process` invokes `OnWeaponHitXp` after `Hit` in its server path. A direct `Hit` does not itself emit that callback.
- `CombatManager` gates the SP post-hit callback, including the range-falloff/first-XP-hit condition. It cannot be assumed to report every victim of every attack.
- `BodyPart.DamageUpdate` emits only victim, `BLEEDING`, and amount. It supplies neither body-part identity nor a durable wound/source ID.

Raw bytecode and runtime logs are local diagnostics; the reproduction scripts and this measured summary are mirrored. Initial fixture attempts failed on an outdated method signature and because off-thread shutdown callbacks were queued rather than executed. Startup dispatch also needed a probe-only tick pump after the startup event released its lock. Those were probe defects, not evidence that the native packet callback is absent. The final fixture checks the actual Lua owner thread and exact current method signatures.

## Practical consequence and new choice

Exact attribution of all injury effects is not established by the available callback data. This is narrower than claiming no possible engine-level solution exists. Inferring delayed bleed loss from the last attacker or assigning all intervening health loss to a pending hit would guess ownership, contrary to C455. Polling every limb still needs a rule when multiple sources wound the same limb; it adds work without creating a native source identity.

**1A - Confirmed damage only (recommended).** Preserve proportional player/defense awards for verified actual health loss; leave untraceable portions unpaid and do not redistribute them. This includes a known limitation for wound-heavy traps: damage from a wound may remain uncredited even when the device originally caused it. A wound-only PvP kill can therefore produce no shared XP. Known direct damage retains its share when the victim later dies. This coverage policy is a new proposal, not an inferred approval.

**1B - Continue deeper wound-attribution work before shipping shared XP.** Retain the full attribution target and investigate a source-aware wound model/native integration. Feasibility, compatibility and runtime cost remain unproven. No Java gameplay dependency or native wound replacement is implicitly authorized by this option.

C455 already excluded genuinely unknown environmental/other-mod damage. The newly exposed tradeoff also affects effects caused by our own traps, so the owner should choose rather than receive a silent reduction in coverage. Do not normalize only the known contributions: that would redistribute the unknown fraction. Any approved implementation must keep the unknown share in its damage budget and prevent healing from creating extra full-kill rewards.

## Remaining work

No gameplay XP patch is installed. The accepted 0.2.67 build and its completed SP test round remain unchanged. No Trait Shop/Horde source changes, reward awards, version bump, Workshop-draft change, publication or owner test occurred here.

After the coverage choice: finish native lethal/order/transport verification; implement the compact contribution ledger, life-bound offline recipient API, combined personal/shared settlement, shared PvP cooldown/receipt handling and Horde source adapter. Verify restart, death, healing, unknown contributions, source gates, stale identity and duplicate delivery. These settlement and connected-client checks have not passed merely because the callback probe ran. Multiplayer owner testing remains deferred.

**Decision needed: 1A or 1B.** The already-selected 50%, owner-faction recipients, eligible PvP scope and life-bound offline shares are not reopened.
