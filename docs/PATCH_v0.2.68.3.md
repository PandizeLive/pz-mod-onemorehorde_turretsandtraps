# 0.2.68.3 - Inventory refresh and presentation corrections

Approved C474, 2026-10-26. Horde/Cure remains0.6.16.8; Trait Shop remains0.9.1.1.

- Replace stockpile event-only invalidation with native refresh participation. Each embedded view owns its pending update; a native pane cannot consume its only signal. Preserve native container/transfer/selection/drag behavior, coalesce notifications, defer hidden views, and avoid loops with two embedded views. Retain native container events through the same invalidation function for remote/global updates. No polling, duplicate item cache or repeated sync requests.
- Preserve the electronics manual's actual atlas region when scaling the separate Specialist icon to16px. Existing shared inventory artwork remains unchanged.
- Add a filtered OMH: Turrets & Traps tab to the native Item List Viewer, retaining item namespaces, exact script identities and hidden/obsolete filtering. One scan when the viewer initializes; no tick work.
- Display Controller Reserve beside the turret battery only when that is its actual power source; prioritize the source caption beside the battery icon at narrow widths and clear on source change. Local battery charge remains local charge.
- Add native standing stagger to a successful outward tether push, retaining directional displacement, collision checks, simulation-owner authority, pull and cooldown. Zero extra hit force avoids adding a second configured knockback force; prone/traversing/dead targets do not gain the standing reaction.
- Retain prevention of T&T effects on Horde runs that disable assistance. Verify the actual Horde integration with foreign-source identities and multiple damage/effect families; do not replace prevention with kill-only flags.

The management ring uses the correct shared radius in automated checks; no speculative range change. Rendered acceptance and connected multiplayer remain pending. Saved settings and item IDs are unchanged.
