# C182 - Pack cues and tier reopening

**C183 / LootLab persistence correction:** confirmed tier weights now save with account settings and survive refresh, reopening and device changes. Offline confirmed edits use the existing account-scoped draft recovery. The local HTML copy uses browser storage. Cancel discards the draft; equal-weight assignments are reconstructed from saved tier values. Deployed and verified; no gameplay/package changes, so the installed mod remains **0.2.47.3**. [Contract and test](LOOTLAB_TIER_PERSISTENCE.md) | [Deployment](../diagnostics/lootlab-c183/release.json). This supersedes C182's page-session-only limitation.

**C182 / 0.2.47.3:** approved rotation ticks (1B), pickup selection cue (2B), custom rarity audio pending owner files (3C), and a pulse-only four-second fade (4B). Pack audio uses native UI events with one shared bounded tick stream, no catch-up burst and cleanup on Collect. LootLab now shows calculated rarity in the normal list, refreshes draft feedback, and automatically groups equal weights when reopening. Confirmed tier weights persist for the page session; full reload derives centers from loaded weights. [Patch](PATCH_v0.2.47.3.md) | [Test](TEST_v0.2.47.3.md) | [Contract and pitch limitation](PACK_POLISH.md).

Native pitch variation requested, but additional randomized pitch is **not implemented**: the installed event path ignores clip pitch and the emitter setter writes every queued/active sound. Native rotation is played unchanged; no unrelated audio is modified. Custom rarity sounds remain pending, with the approved pickup cue providing selection feedback. No particles. No loot/default/rarity-formula changes.

## Current implementation (supersedes the earlier pending choices below)

Ticking uses UIObjectMenuObjectRotate; settlement uses UIObjectMenuObjectPickup once for the simultaneous three-row result. One pack-owned sound handle is stopped before replacement and on Collect. At most one tick per frame, separated by at least 100 ms, with missed crossings discarded. No tick handler, world noise, per-frame text wrapping, temporary inventory items or particle allocation. One linear rarity-tint/border pulse starts when results settle and fades for four seconds, then stays at the original panel tint.

Native evidence: SoundManager.playUISound uses the installed FMOD event; stopUISound acts on its returned handle. FMODSoundEmitter.setPitch writes the pitch field for every queued/active voice, not just a matching handle. EventSound never consumes that field; FileSound does. Therefore no setter or ineffective pitched event variants are shipped. This leaves additional randomized tick pitch unresolved. No engine/global sound mutation or extracted runtime audio is introduced.

Tier cards and the draft spread update from every assignment/weight edit; the normal weight list now has a named rarity badge in the same palette. Map identity colors/shapes remain independent. Reopening places matching weights into tiers with a small relative floating-point tolerance; duplicate weights prefer the actual calculated band, otherwise the first matching tier. C183 saves confirmed tier weights with account settings (browser storage for the local copy); Cancel discards changes. Reloading uses saved tier values; older settings without tiers derive initial centers without changing existing weights. Unmodified auto-assigned members do not overwrite concurrent saved edits. Actual colors still use the native relative min/max formula, not the assignment label.

## Capacity diagnosis

The 0.2.47.1 client console reproduces InventoryContainer.setCapacity warnings, stating a maximum of 44. Native current-build bytecode computes 50 minus the item's actual weight. The turret base weighs 6. T.configure requested 50, while TurretMenu's tooltip called configure on every render. This is owned mod code, not random loot or an expansion-kit probability problem. [Evidence](../diagnostics/pack-polish/capacity-evidence.json).

0.2.47.2 clamps carried capacity to floor(50 - actualWeight), preserving world storage's 100-unit limit, count allowances and all existing contents. Configuration runs through existing crafting/deploy/pickup/transfer paths; hovering no longer mutates capacity. The native physical limit already applied to the carried item; no inventory-weight reduction is introduced. The physical storage now consistently exposes the same limit as the containing item. Native test: 44 capacity, unchanged six-unit base, 199 potatoes plus the tested head/kit before the native room check refuses another; ammunition-count allowance is still 750. Warning-free native proof does not certify the actual player's next session.

## Implemented presentation

Manage's opaque dark panel, inset reward rows, subdued rarity backgrounds/borders. When rolling finishes, each row shows its actual selected item at full width instead of retaining neighboring distractor cards. One full-width green Collect button closes the presentation; rewards were secured before it opened, so early Collect is safe. Short viewport scrolling remains, with arrow controls moved to the title area. No new per-frame allocations, audio or particle handler.

## Historical C181 choices (superseded by C182 above)

Local audition: art/PACK_AUDIO.html. Installed native FMOD captures; audio metadata and non-silence checks in diagnostics/pack-polish/audio-evidence.json. Eight clips play only on request. HTML includes a Manage-style settled-result layout preview and an optional bounded particle preview, not installed effects.

- 1A soft highlight (recommended); 1B object rotation; 1C UI click.
- 2A play confirmation (recommended); 2B object pickup; 2C object placement.
- 3A native level-up; 3B click-to-start; 3C owner-created rarity sounds (recommended). Native level-up risks implying XP, and native reveal candidates are comparatively long. Until custom clips arrive, use the chosen selected cue only if the owner approves that fallback.
- Proposed 4A restrained color pulse plus up to eight short particles per selected card (24 total); 4B pulse only; 4C none. Await owner selection. Particle preview respects reduced motion.

Proposed timing: one shared tick stream for the three simultaneous reels, bounded voice rate; selected cue at each settle; one highest-rarity reveal cue per pack to avoid three layered fanfares. UI-only audio must not attract zombies. Verify native playback controls before implementation. No sound/particle choice is assumed from a rendered HTML preview.

## Original C181 tier editor (reopening revised by C182 above)

Optional section above regular tuning. All 29 modules start unassigned with existing weights. Dropping into a tier assigns that tier's weight; keyboard/touch Move to menus are equivalent. Each assigned module permits an individual weight override. Changing a tier weight updates its non-overridden members only. Returning to unassigned restores that module's opening weight; confirming leaves unassigned current settings alone. Confirm validates and applies through existing save/sync/export; Cancel does nothing. Conflicting externally changed assigned weights reject confirmation rather than overwrite them. Drafts are transient, not account writes.

Initial seven tier values are geometric centers between the current positive minimum and maximum, the inverse of the game's logarithmic seven-band classifier. The displayed computed rarity always uses actual draft weights, so changing extremes/overrides can change a card's calculated band independently of its assignment row. This is shown rather than forcing a fake color. Zero-weight modules are explicitly disabled. No per-tier rarity lock, percentile redistribution or hidden game-default update. Existing map family shapes/component colors remain separate from rarity colors.

Defaults use Abundant/Common/Uncommon/Rare/Epic/Legendary/Mythic counts **2/2/8/4/8/4/1**. Current saved all-one multipliers use **2/0/1/8/11/6/1**. Both follow the existing formula. More balanced colors require deliberate weight edits; because module power costs follow rarity, that can change battery drain. [Spread checks](../diagnostics/pack-polish/rarity-spread.json).

The owner-only hosted editor is deployed from the isolated verified release source. Only the tier asset was added to the authenticated route allowlist; account/database/public API behavior is preserved. The dirty website checkout was not deployed. Source patch and deployment proof are retained with 0.2.47.2.

C185 / 0.2.47.4 supersedes the relative min/max rule when saved custom rarity anchors are active. Pack rewards use the same anchor-derived rarity as Manage and battery costs. [Shared rule](LOOTLAB_TIER_PERSISTENCE.md#c185-shared-rarity-anchors-2026-10-12). Audio and pulse behavior are unchanged.

## C186 - Owner rarity sounds received (2026-10-12)

Owner: "I added the new sounds" to C:/Users/bandi/Zomboid_Modding/OMH/Audio/Turrets & Traps and requested the next-update recap. C182 option 3C already approved owner-created rarity audio; the required assets are now present. This turn inventories and records the upcoming integration, without changing Source/Contents, version or install.

All seven named files (abundant, common, uncommon, rare, epic, legendary, mythic) are distinct valid WAVs: 48,000 Hz, stereo, 16-bit uncompressed PCM, 188,308 frames / 3.923 seconds each. Non-silence/level checks are technical inspection, not audible acceptance. Preserve the owner's originals; verify native playback and relative loudness during integration.

Next feature: custom Module Pack rarity reveal sounds. Retain the established native ticking/selection and four-second pulse. Recommended integration follows the earlier proposal: one reveal cue for the highest-rarity actual reward, using the same cached seven-band rule as Manage/pack cards, rather than three simultaneous fanfares. Keep audio UI-only, bounded, and owned by the reveal lifecycle; no zombie-attracting noise, global pitch mutation, per-tick event handler or extra particle work. Confirm cue timing/overlap and cleanup through playback tests. No new claim that native tick pitch variation is solved by receiving custom rarity files.

The supplied Manage layout selection says Inset panels; that direction is already reflected in the installed presentation and does not create a new redesign task. Current 0.2.47.4 tier/color and battery classification fixes stay completed. This is the next pack-polish slice within R3C7; R1C3 broader performance/authority work and unselected heads/signals remain separate. No repeated combat test or new content choice is required by this recap. Inspected active branch 4683bd3 and fetched origin; only draft PR #1 is open.

Level review: all seven contain nonzero audio and no full-scale PCM samples. Abundant/Common RMS is about 0.023/0.022 versus 0.099-0.188 for the other tiers. They measure substantially quieter; audition relative playback before choosing gain changes. This is not proof of perceived loudness or authorization to normalize the owner files.

## C187 - Current weights check (2026-10-12)

Owner asks to check new LootLab weights, expects a couple Mythic items, and requests next-patch confirmation. Do not substitute shipped defaults for saved account state. The available in-app browser is at Cloudflare Access sign-in. Automatic approval review rejected the attempted read-only D1 scenario query because explicit authorization for the account/database path was missing; it did not execute. Asked the owner to approve that read-only query or supply a scenario export. No credentials, account settings, loot defaults or gameplay assets changed.

Exact Mythic names/count/weights are unverified until the saved scenario is read. The confirmed next feature remains the seven owner-created rarity reveal sounds; highest-rarity-only cue selection remains the recommended implementation. The request does not establish that the current website weights are already installed in-game, nor authorize an invented tuning baseline. Carry verified values into the next patch plan once available. Installed build remains 0.2.47.4. This check requires no repeat combat test.

## C188 - Verified saved weights (2026-10-12)

Owner explicitly approved the read-only query for the configured LootLab account/database, resolving C187's access gate. The production SELECT returned revision 196, updated 2026-10-12 22:26:27 UTC, with rows_read=1, rows_written=0 and changed_db=false. The current shipped LootLab model validates the scenario; the C185 classifier verifies the assignments below. No account settings, gameplay defaults, installed files or originals were modified.

| Tier | Weight | Components |
| --- | ---: | --- |
| Abundant | 20 | Reload, Accuracy, Regulator |
| Common | 18 | Filter, Rapid-Fire, Range, Magazine |
| Uncommon | 14 | Firing, Detection, Small Expansion Kit |
| Rare | 10 | 360, Suppression, Velocity, Critical, Piercing |
| Epic | 6 | Medium Expansion Kit, Splitter, Initial Blow, Impact, Conservation |
| Legendary | 3 | Large Expansion Kit, Fragment, Execute, Martyrdom, Tack |
| Mythic | 1 | Autoloader, Enhanced Firing, Enhanced Detection, Synergy |

All 29 components match a tier exactly. Four Mythics each weigh 1: Autoloader, Enhanced Firing, Enhanced Detection and Synergy. Global module loot multiplier is 1.011111111111111. The local scenario snapshot also preserves material=0.6, rolls=1 and retention=0.7, but retention is simulator-only and this request does not authorize silently retuning unrelated global game loot options. Tier rarity remains relative selection weighting, not a direct spawn percentage.

Next patch plan: import the verified module weights and seven rarity anchors alongside owner-created pack reveal audio, using highest actual reward rarity for the one pack cue. Integration remains pending; read-only approval does not claim an installed update. Existing-world Sandbox values are not overwritten just by changing new-world defaults. Recheck saved revision before implementing if the owner makes further LootLab edits. [Reviewed weight evidence](../diagnostics/lootlab-c187/verified-weights.json); full scenario is retained locally at diagnostics/lootlab-c187/omh-loot-scenario.json. Inspected 70fe974 and fetched origin; draft PR #1 remains the only open PR. No new test or repeat combat requirement.

## C189 - Approved custom audio and saved loot defaults (2026-10-12)

Owner: "Approved." This approves the C188 combined patch: the verified saved weights/anchors and C186 seven custom rarity sounds with one highest-rarity cue. Rechecked revision 196 unchanged immediately before implementation. Source branch codex/performance-barbed-audit at f58d354 was reconciled with fetched origin. No additional owner decision is required.

Implemented in 0.2.48. New-world Sandbox defaults, LootDefinitions fallback and LootLab reset/default baseline use all 29 exact C188 weights and anchors; original item base weights remain intact. The global module multiplier is 1.011111111111111. Unrelated material rates, pack corpse chance, recipes and existing saved Sandbox values are unchanged. Old account scenarios migrate baseline identifiers without silently adopting defaults; legacy missing tier metadata retains automatic classification. Current 0.2.47 browser clients can save their complete existing settings without losing values; malformed/missing component fields are rejected. No account row or schema was written by deployment.

All seven original PCM WAV files are copied byte-for-byte, preserving original level differences. Native UI sound scripts use one non-looping non-spatial clip per tier. Highest actual reward rarity is cached at panel creation; at the existing four-second settle, the pickup selection cue and one rarity cue play. Both owned handles stop on Collect or replacement. Early Collect skips unfinished reveal audio and preserves already granted rewards. Disabling the rolling UI retains its existing halo behavior. No new tick handler, per-frame item allocation, global pitch mutation, particles or zombie-hearing event. Native tick pitch variation remains unresolved as documented under C182.

Rarity-linked battery surcharges follow the new anchors: .1/.15/.25/.4/.6/.8/1; Regulator retains its battery-only reduction without a surcharge, and separate expansion kits remain exempt. This is a consequence of approved rarity tuning, not a new drain formula. Existing worlds require explicit Sandbox import to adopt the new weights and anchors.

Performance and validation: 16,166 assertions; 117 Lua/translation files compile; native parser/FMOD UI handles play/stop all seven sounds in a muted probe. Pack tests cover every highest-tier choice, exactly one reveal cue, early Collect, replacement and long-frame no-burst behavior. The 300-frame probe creates no items or text wraps. Changed shipped Lua retains Alex's annotations/guard-only style and introduces no pcall/xpcall. Native persistence/package results and owner acceptance are recorded in TEST_v0.2.48.md, not inferred from mocks.

Balance observation: LootLab's full-retention default model estimates 70.0% one/two-component and 15.1% five-plus-component hauls among successful containers. This exceeds the previous test fixture's under-10% assumption because the owner changed weights. Preserve the explicit approved tuning; report measured estimates without treating them as guaranteed in-game loot or global vanilla spawn changes. The saved scenario's .7 retention is simulator-only.

C189 release verification: native write/read and all three package selections pass; root OMH.cmd installed immutable test/v0.2.48 / 303ee3d. All 264 installed/archive files and both backups match. LootLab Worker 1007244f-ad66-4416-bede-2f2f64063abe is verified. Owner audible acceptance remains pending; no Workshop publication.

## C190 - Staggered, longer and faster-opening pack reels (2026-10-12)

Owner explicitly requests offsetting each roll, bottom last, extending roll time and increasing initial speed. Implemented in 0.2.48.1 as a presentation-only correction: each row starts 350 ms after the previous one and rolls for six seconds. Relative to panel opening, starts are 0/0.35/0.70 seconds and stops are 6/6.35/6.70 seconds. Travel increases from 13 to 39 card widths with the same cubic ease-out, yielding twice the initial velocity while allowing a longer slowdown. Each row expands onto its already granted winner and begins its four-second pulse independently.

One shared rotation-tick stream remains limited to at most one sound per 100 ms. Selection and the one cached highest-rarity cue wait until the bottom reel finishes. Collect/replacement still stops both owned handles; early Collect keeps all three already granted rewards. Long frames skip missed ticks rather than replaying them. The rolling toggle, loot weights, reward selection, three independent draws, sounds themselves and gameplay remain unchanged. With C189 defaults, Mythic odds remain 1-(269/273)^3 = 4.3315% per pack.

The three reel tables cache position/crossing/settlement scalars. Their 42 card entries reuse the existing per-type card metadata; only visible card indices are iterated during drawing. No per-frame items/text wrapping/tables, new event handler, protected call, global sound modification or new asset. Changed Lua follows Alex's annotations, four-space and guard-only inline rules. The existing getTimestampMs/ISPanel/sound API paths were validated in C189; no new native API is introduced.

Verified with 16,180 assertions and 117 Lua/translation compilations. Focused coverage includes staggered starts/stops, initial speed comparison, exact winner, per-row pulse, final-only cue, early collection, replacement and a 20-second frame jump without backlog. A 500-frame render probe creates no items or text wraps; small-viewport controls remain in bounds. Initial test failures were stale 16-card/four-second expectations, updated to the requested behavior. Native package/save/restart results and installation are in TEST_v0.2.48.1.md. Rendered pacing remains owner acceptance, not inferred from mocks.

Inspected branch codex/performance-barbed-audit at 8b089b7, fetched origin and checked the sole open draft PR #1 before edits. This stays within R3C7 pack polish; no new phase or broader combat retest. LootLab remains on its verified C189 deployment and unchanged 0.2.48 loot baseline.

C190 release verification: native write/read and all three package combinations passed. Root OMH.cmd installed immutable test/v0.2.48.1 / def2984; all 264 files and both 0.2.48 backups match. No hosted deployment or Workshop publication. Owner pacing acceptance remains pending.
