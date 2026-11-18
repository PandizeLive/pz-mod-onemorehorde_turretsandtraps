# 0.2.62 — C393 device feedback and Controller polish

Owner approved the complete C390–C392 recap on 2026-10-21. This is a development build, not a Workshop release.

- Device audio
- Detection-only turret standby
- Turret state marker and lowered pose
- Native tether world visuals
- Lever wall alignment and master gate
- Fixed-range colored laser beam
- Compact Connections and group controls
- Persistent Controller Settings access
- Configurable 40-tile Controller radius
- Friendly and hostile player damage settings
- Compact device tooltips and module guidance
- Rarity-aware Performance and Expansion artwork
- Head and trap Sandbox organization

## Behavior and engineering notes

Selected cues: MetalworkingPunchSwing (launch), SpearCraftedHit (impact/pull), CloseMetalToolbox (reset), KnobSwitch (mechanical triggers), ChairLegNailsHit (Poke), AxeSawBladeSwing (rotary movement). Five owner WAVs provide reeling, laser interrupted/clear, completed turret wake and standby. Cues originate from authority transitions; clients do not decide gameplay. Reeling stops at reset/cancellation and has a pause-aware timeout. Sound volume is configurable. Individual gains balance quieter reel/shutdown/pull feedback beneath the wake and impact cues; original audio files remain unchanged.

Detection-equipped turrets sleep after seven active real seconds without a target or ongoing action. They lower the head and use an amber, non-illuminating marker. A valid target starts a one-second rise; invalidation aborts immediately, and the alert plays only after successful wake. Active is green; disabled is dark. Manual actions and trigger-only turrets bypass standby. No automatic battery-saving bonus. Sandbox controls enablement, idle time, wake time and marker visibility.

The nail and cable use the native opaque world-render event instead of a UI overlay. Each visible trap caches two native visual items; a cable has at most 24 segments with a shared 192-segment budget per viewport. Nail height falls during retraction; damage stays server-owned at 30 impact / 15 pull after a 0.75-second hold. Launch defaults to 30 tiles/second, return to four; the existing 0.4-second reset is preserved. Presentation never creates vehicles, physical rope joints or per-frame inventory objects. Rendered depth/alignment remains an owner check.

All connected Levers must be powered and ON before other inputs can activate the receiver. Other inputs retain OR behavior. Laser defaults to ten tiles, green when clear and red when interrupted; only Sandbox changes its range. Walls/closed doors still shorten the beam without triggering it. Controller radius defaults to 40 tiles (Sandbox 5–100); same-floor, loaded-device and authority requirements remain. Panel scans retain their per-frame work budget.

Connections keeps its heading/Add Group fixed, hides cables for collapsed endpoints, clips long labels, and uses compact rows. Right-click Assign to Group supplements drag ordering. Controller Settings always returns to the Controller selection. Modules display drag/remove guidance. Performance/Expansion art uses the same effective rarity calculation as tooltips; existing items update when drawn, with a one-second settings-change check and cached textures. Other categories retain existing art. Owner originals are unmodified.

Friendly turret limb damage is twice 0.2.61; hostile damage and wound probability are four times 0.2.61. Friendly wound probability is unchanged. Independent Sandbox factors preserve armor, volley/wound budgets, server PvP/safety/non-PvP protection and existing zombie balance. These are multipliers of limb injury, not promises of exact global-health loss. No new faction immunity.

Compact device tooltips cover every trap/trigger/Controller, with live relevant damage/range and uniform repair/placement requirements. Existing Horde Night authorization, difficulty/consent flags and bounded damage integration remain in force; no sibling mod was edited. Native models, audio and shared options ship in both independent entries; Traps does not require Turrets.

## Verification

See [test record](TEST_v0.2.62.md). Automated/native checks do not prove GPU rendering, audio mix, live two-client synchronization or PvP balance. No LootLab publication, Workshop upload or branch merge is included.
