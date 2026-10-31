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


## C387 -- Custom reduced player injuries selected (2026-10-21)

Owner selects **1B**: automated turrets should deal substantially reduced player damage and wound chance because ordinary weapon lethality would be overpowered in PvP. This settles custom player balance rather than C386's native gun/spear proposal. It does not select exact damage, wound probabilities, module scaling or a new injury cap. The whole targeting patch remains approved; the policy foundation is staged and installed 0.2.60 remains unchanged.

Read-only follow-up reconfirms the existing DefenseInjury path: blast injuries operate on a chosen body part and scratch probability; other profiles currently apply an unconditional cut/scratch or a two-damage/five-pain bruise. Scrapshot caps player damage at ten per volley, and Lobber uses a bounded blast profile. Therefore a universal percentage of zombie health is not a meaningful existing player-damage setting. A lowered wound chance must also account for repeated firing and multiple pellet/effect callbacks.

### Proposed numeric package, not yet selected

**1A (recommended):** fixed player injury values below, independent of zombie damage. Damage is body-part health loss before clothing protection, not a promise of global-health loss or time to kill. Retain limb targeting rather than introducing head/neck multipliers. No guaranteed embedded bullet, deep wound or fracture is introduced. Wounds are scratches except Rotary Blades' existing cut type.

| Head | Player damage | Wound chance |
| --- | --- | --- |
| Potato | 1 per direct hit | 0% |
| Firearm | 2 per bullet; shotgun capped at 4 per shell | 2% |
| Ballista | 5 per spear hit | 5% |
| Scrapshot | 4 maximum per volley, proportional to pellets that land | 3% |
| Rotary Bat | 1 per eligible contact | 0% |
| Rotary Blades | 2 per eligible contact | 5% cut |
| Lobber | 5 at blast center, retaining distance falloff | 5% at center, retaining falloff |

Preserve the rotary recovery interval. A shotgun/scrap volley or one explosion rolls for injury once per victim, not once per pellet. Additionally, allow at most one nonzero wound roll per player per real second across turrets; ordinary direct damage still accumulates from multiple hits/turrets. Armor-blocked hits and zero-chance blunt hits do not consume the wound-roll opportunity. This limits repeated wound lotteries, not aggregate damage or the usefulness of multiple defenses. Server protection checks and clothing protection must be validated before delivery; they are not proven by this numerical proposal.

Player direct damage does not inherit critical/Execute bonuses, and turret player hits do not force knockdowns. Existing range/accuracy/firing/reload improvements still function, so modules remain useful; separate damage and secondary-effect tuning for players is deferred rather than silently inheriting zombie proc formulas. Splitter pellets share the originating attack's relevant shell/volley cap. Existing player collateral effects must use the same reduced profile and budget as deliberate attacks, preventing spillover from bypassing PvP tuning. This deliberately proposes superseding C384's exact turret injury numbers while retaining its physical hit eligibility; the owner has now requested reduced turret player injuries. Apply the same turret player profiles in SP and MP. Passive traps, Poke and Tether injuries remain outside this turret-only balance request; their existing player rules are unchanged.

**1B:** the same complete package with damage multiplied by 1.5 and wound chances doubled. No rounding requirement for fractional body-part damage. More threatening automated PvP; still custom rather than native weapon wounds.

These are starting proposals, not tested balance. Even low per-hit damage can stack across rapid-fire turrets; no immunity window or universal damage cap is proposed. New Sandbox tuning should expose player-damage and wound-chance multipliers after the package is selected, keeping zombie values separate. Native attack integration, UI and connected-player verification remain unfinished. The selected custom path is not a new request to pause all approved work; the specific numerical package is the remaining material input.

No code, generated package, release tag, installation or new test result this turn. Reviewed ad83cccd83fbaabf555c6847341ff863b8d62cb1; origin fetched with no newer dev commits, draft PR #1 remains the active handoff. Persist/mirror this decision under C108/C119. **Decision needed: 1A or 1B numeric package.**


## C388 -- Stronger 1C requested (2026-10-21)

Owner: "1C even larger". In context, interpret this as stronger player damage/wound chance than the previous 1B, not a larger reduction. The exact magnitude was not provided. Custom player balance remains selected; propose 1C at **2x C387 1A damage / 3x its wound chances**. Compared with 1B, that is one-third more damage and 50% higher wound chances. These multipliers are recommendations requiring confirmation, not previously approved values.

| Head | Proposed 1C player damage | Wound chance |
| --- | --- | --- |
| Potato | 2 per direct hit | 0% |
| Firearm | 4 per bullet; shotgun maximum 8 per shell | 6% |
| Ballista | 10 per spear hit | 15% |
| Scrapshot | 8 maximum per volley, proportional to landed pellets | 9% |
| Rotary Bat | 2 per eligible contact | 0% |
| Rotary Blades | 4 per eligible contact | 15% cut |
| Lobber | 10 at center, retaining blast falloff | 15% at center, retaining falloff |

Retain all proposed C387 protections and scope: one nonzero wound roll per player per real second across turrets; no per-pellet rolls; no player critical/Execute/forced knockdown or guaranteed embedded bullets/deep wounds; fixed direct player damage; no head/neck multiplier; armor and server protections; same profile for collateral. Multiple hits/defenses still stack ordinary damage. Keep zombie balance and passive/Poke/Tether injuries unchanged. The rotary recovery interval remains. These protections are still part of the proposed package, not separately implemented or tested.

Recommend this as the next starting point rather than continuing upward without a connected PvP test. Automatic fire and multiple turrets can accumulate damage rapidly. Do not infer a precise time to kill from body-part damage or claim a uniform percentage reduction versus handheld weapons. No new game/runtime evidence is obtained this turn.

Planning only. Inspected clean 76a7567e9350938aa3bd990d75e6f00bae89fa3b, fetched origin with no newer dev commits. Installed 0.2.60 and the C386 staged policy foundation are unchanged. No source/package edit, release tag, test acceptance or install. Full targeting patch remains authorized, pending this numeric selection and unfinished integration. **Decision needed: confirm 1C values.**

## C389 -- Approval and implementation (2026-10-21)

**C389 / Full targeting and 1C approved (2026-10-21).** Owner confirms "Yea": C388 values and C387 safeguards are approved. Implementing Controller defaults/defense overrides, deliberate player acquisition, shared reduced turret injuries and independent Sandbox multipliers. No further design decision remains. Installed 0.2.60 stays unchanged until verification and tagged installation; connected/rendered acceptance remains pending. [Contract](TARGETING_AUDIT_C386.md#c389--approval-and-implementation-2026-10-21). **Wait for a patch.**


Implementation contract and exact 1C behavior: [0.2.61 patch](PATCH_v0.2.61.md). Targeting is no longer only a foundation: UI, acquisition, aiming, impact validation and player injury handling are wired. See the versioned test record for actual checks and remaining connected/rendered acceptance.
