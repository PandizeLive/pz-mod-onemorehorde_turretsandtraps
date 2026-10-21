# C386 — Approved targeting patch: staged policy and player-damage gap

Owner approval: **“Approved for patch”**, 2026-10-21. C383-C385 remain the targeting contract. This is an implementation checkpoint, not a finished release. Installed **0.2.60** and immutable `test/v0.2.60` remain unchanged. No new tag, installation, Workshop upload or acceptance is claimed.

## Implemented independently

`ControlTargeting` resolves Zombies Only by default, Controller inheritance and explicit defense overrides. Unassigned defenses return to the default unless they have an override. Retired/unrelated Controllers cannot supply a default. Only Controller, Turret and Tether accept policy configuration; passive hazards and simple triggers do not gain recognition.

The existing authoritative `ControlAction` now validates Targeting edits against identity, reach/remote session, management write permission and allowed values. Completion revalidates and rejects replay/client-side mutation. Controller changes publish assigned recognizing defenses without overwriting their explicit mode. Private scalar copying retains policy through the existing recovery/save machinery. Public snapshots report the resolved mode, but are not authoritative input.

Faction classification uses the defense owner's **current** faction through the native username lookup, including when the owner is offline. The owner is always excluded; unrelated factionless players are outsiders. Management sharing does not define combat alliance. This helper only classifies factions: it does **not** authorize a hit or bypass PvP protection.

No targeting UI or acquisition hook is enabled yet. That avoids advertising a working Other Factions mode while general projectile damage remains undefined. Existing combat, signals, consumption and collateral behavior are unchanged. Generated packages contain the staged foundation but must not be installed as a completed targeting build.

## Verified gap

The existing `TurretVolley` moving-object ray scan only admits players for Scrapshot. General forward/piercing firearm, Ballista and Potato paths do not establish player damage. `PrototypeCombat` / `Damage` are zombie-oriented; passing an IsoPlayer into them would be incorrect.

Existing player rules remain available and must be preserved:

| Device/effect | Current player injury |
| --- | --- |
| Scrapshot | Up to ten body-part damage per volley, bounded scratch chance |
| Rotary Bat / Blades | Existing bruise / cut with recovery guard |
| Lobber | Existing bounded blast injury and scratch chance |
| Tether | Scratch on impact; current pull damage is zombie-only |
| Poke / passive hazards | Existing contact rules, unaffected by targeting selection |

The installed **42.21 projectzomboid.jar** was inspected with `javap -c`, not merely the older decompile. `BodyDamage.DamageFromWeapon(HandWeapon, int)` checks clothing, selects injury/body location, derives damage from the actual weapon, and applies server firearm/melee damage modifiers. Its application path queues a native network character damage update on the server. This is a plausible current native route, **not yet a connected-player turret test**.

Native `CombatManager.checkPVP` is not a drop-in server turret permission function: its PvP/safety/non-PvP-zone branch is client-specific and it resolves player/vehicle attackers, not an autonomous placed object. Explicit server protection and impact revalidation remain required. Do not infer safehouse immunity from management access, or claim those checks implemented. Keep existing incidental injuries separate from deliberate player attacks.

## Concrete decision exposed by the audit

**1A — Reuse weapon injuries (recommended).** Firearm heads use the installed gun's native player wounds; Ballista uses the loaded spear's native wounds. Potato direct hits use the existing light bruise profile (two body-part damage plus five pain). Preserve existing injuries for other heads/traps. For this baseline, module zombie-damage/critical/execute effects do not become new player-wound multipliers; existing player effects stay unchanged. This gives deliberate player hits without inventing a second per-head damage table, but native gun/spear wounds can be severe.

**1B — Define separate PvP damage.** Set explicit player injury and module-scaling values for the missing projectile heads before implementation. More control, but requires additional balance choices and maintenance.

Neither is selected by the previous approval: C385 explicitly reserved a concrete decision if the native audit exposed missing player damage. This is not a return to the rejected zombie-only delivery proposal. The full two-mode targeting patch remains authorized; it is unfinished pending this specific mapping.

## Verification

- Final foundation validation: **26,217 assertions**, including 38 new policy/permission/replay cases; 285 compiled Lua/translation files; 1,167 native translation checks; independent package checks cover 331 source / 440 generated files.
- Native server write: authoritative targeting command, replay, public snapshot, owner exclusion and username faction API pass with real Java objects. The zero-client server started, saved and shut down successfully.
- Native fresh-process restart passes: the saved default survives; a packed Controller does not supply inheritance; native pickup/redeployment preserves the private policy and restores inheritance while placed. Write and read servers completed in 53.8 / 51.9 seconds with no player connected. Rendered UI, live connected-player injuries and complete combat protection remain untested and unimplemented for this slice.
- Logs: `diagnostics/targeting-policy-validation.log`, `diagnostics/targeting-c386/server-write.log`, `diagnostics/targeting-c386/server-read.log`. Native probes use a separate diagnostics label so they do not replace installed-release smoke evidence.

Initial fixture failure was a missing module in the explicit Kahlua test loader; registering it before ControlWorld fixed the fixture and the full validation then passed. The first restart assertion incorrectly expected inheritance from a Controller that the existing heavy-pickup fixture intentionally packed; it was corrected to assert preserved configuration and inactive inheritance while packed, plus restored inheritance on native redeployment. The repeat fresh-process run passes. No error masking was added. Native logs contain existing vanilla map/property diagnostics; success is limited to the named probe assertions, not an assertion of a warning-free game.

Next: settle 1A/1B, complete UI/acquisition/impact/server-protection integration, validate all heads and persistence, then version/tag/install/mirror the finished patch. **Decision needed.**
