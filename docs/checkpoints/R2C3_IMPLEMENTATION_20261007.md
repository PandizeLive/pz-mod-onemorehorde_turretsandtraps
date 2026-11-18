# Backed barbs: implementation checkpoint

2026-10-07, C99. Local implementation on `codex/performance-barbed-audit`, based on `2011674`; fetched `origin/dev` remains `5fc6446`. Version 0.2.31 implements the content patch; see RELEASE.md for installation/tag evidence. The 0.2.30 owner test remains held and is carried into TEST_v0.2.31.md.

## Implemented helpers

- `Source/42.20/media/lua/shared/OMHTT/BarbContact.lua`: four exposed orientations, one-tile collision-width contact band, protected opposite face, same-floor checks, and one immediate/repeating timer per zombie. Sharing this state across sections prevents overlapping hits and exit/re-entry exploits. An expired interval permits one observed-contact hit, never accumulated damage after absence; clock/session rebasing retains a bounded remaining interval.
- `Source/42.20/media/lua/shared/OMHTT/BarbSupport.lua`: exact native door/window/constructed/map backing classification, lookup, identity binding, replay-safe removal, unloaded versus removed distinction, support health classification, separate 50-HP wear/repair, and native single-panel door edge tracking. Window geometry remains fixed. Opening a door changes the edge used for contact, without altering its collision or health.
- Finite damageable supports retain native HP. Map supports and nondamageable constructed supports use separate durability, losing one only when damage was actually applied. Opposite-face sections have separate identities. Replacement objects do not inherit an attachment by coordinate alone.
- `BarbSections.lua` registers native construction, indexes only loaded marked supports and bounds maintenance to four sections per tick. `BarbRuntime.lua` applies contact damage and skips support lookups during each zombie's cooldown. Service modules implement ten-second repair/removal with reach, tools, identity, interruption and replay checks. The feature belongs only to Traps, with native construction, three Sandbox controls and eight white technical markers. Source changes do not alter player saves or enabled-mod choices.

## Verification

The current installed 42.21 JAR is the authority. `IsoDoor.getSpriteEdge(false)` and the matching constructed-door API expose the actual N/W/E/S sprite edge, including reverse hinges. The initial native fixtures cover ordinary N/W door swings; reverse-hinge rendering and multi-panel/garage movement are not certified.

`tools/KahluaCheck.java` includes `tools/tests/barbs.lua` and `barb_runtime.lua`. Checks cover construction/orientations, actual runtime cadence/wear, independent glass HP, exact identity, repair/removal, cancellation/replay, unloading/restoration, thousand-section bounded cleanup and pause/stall behavior. Full validation also compiles the shipped Lua, checks native translations/animations/models and packet serialization. Final counts are in the current version's validation.log and RELEASE.md. World/character doubles do not establish rendered gameplay acceptance.

`diagnostics/barb-content-20261007/` extends the earlier native fixtures with doors/windows and invokes the actual new helpers. The final run passes twelve host bindings/serializations, two ordinary door edge changes, two controlled window states, timed native damage/wear, and eight controlled fence crossings. Two earlier fixture attempts are retained locally: toggling a window on a chunkless square raised a pathfinding exception; passing a chunk as the square constructor's second argument failed because that argument is `SliceY`. Neither is treated as a gameplay failure or clean pass. The corrected probe controls the native window open field in Java, then calls the Lua helper on that object; it does not claim to execute a rendered opening action.

Integrated `tools/NativeBarbProbe.java` / `tools/tests/native_barbs.lua` use real chunk-backed squares for eight native construction cases, consume the actual approved ingredients (two Wire uses), retain tools and serialize sixteen frame/support objects. Read mode restores files in a fresh game process and checks exact identity, independent durability, native support HP and passability. The initial harness used a main-thread-only callback wrapper during its shutdown fixture; that diagnostic was corrected by checking the bound callback directly. Final smoke checks reject any wrong-thread diagnostic or barb Lua bridge error. Existing stock WorldGen warnings are not reported as a clean game log.

## Remaining work and decisions

The owner explicitly selected independent 50-HP window-frame barbs and reaffirmed that window HP must not increase. This policy is implemented; no window-health decision remains pending.

Rendered placement/contact, marker alignment on actual opening doors, autonomous zombie movement and dense-client performance remain held owner acceptance in the single combined eight-step test. Native proofs and passing unit checks do not replace it. Workshop notes remain cumulative; only the root release launcher installs the tagged local build.

Multi-panel/garage doors require further native work before enabling. Native double-door code can move/recreate the middle leaves; ordinary map-door recreation does not reliably carry attachment ModData. Never compensate by transferring barbs to an arbitrary replacement at the old coordinate. The initial helper refuses these unsupported door types. Player injury remains unselected and unimplemented. No performance-patch completion or client-stall fix is claimed by this work.
