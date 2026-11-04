# 0.2.69.1 - Tether reactions and Controller layout

C481, 2026-10-26. Owner approved C479/C480. This corrective patch replaces the conflicting tether push/stagger path.

- Impact retains damage and has no outward push or shove. Retraction uses one collision-aware displacement toward the muzzle, unchanged pull damage/distance, and the existing0.5-second post-return reset.
- Choose forward/back/left/right reaction from the target's facing. Gradually align the remaining angle, at most45 degrees total and9 degrees per50 simulation milliseconds. No full forced turn or facing reset afterward.
- Four native-clip animation definitions use the bumped state instead of the native stagger state. Bip01/Z counter-position removes horizontal pose drift. Current 42.21 ignores the node movement flag when constructing playback, and native track access is not exposed to Lua. The existing active lifecycle therefore saves the affected actor's deferred-movement setting, disables clip displacement through the 150ms blend-out, and restores the previous value afterward or on interruption. No world-wide movement override or new polling loop.
- Preserve owner-client movement authority, native collision and identity/serial checks. Remote clients receive presentation only; death, climbing, competing reactions, ownership transfer and expiry cancel our active pull. Crawling targets retain their previous displacement without a standing reaction.
- Remove the Controller management circle while retaining numerical range and actual range enforcement. Other turret range visuals are unchanged.
- Reserve roughly one-third of the right column for equal-width Device/Controller Settings, using their existing independent wheel scrolling. The map retains roughly two-thirds.
- Group collapse requires press/release on the same title bar without a drag. Backgrounds, scrolled-away headings and scrollbar areas do not toggle groups; device/group drop behavior remains.

The obsolete push control is hidden and ignored. Its registered Sandbox field/default remains for saved-world and current Horde audit compatibility; no owner setting is rewritten. Existing worlds need a restart, not a new world. No new loot, recipe, XP or progression changes; Horde/Cure0.6.16.8 and Trait Shop0.9.1.1 are unchanged. See [verification](TEST_v0.2.69.1.md).
