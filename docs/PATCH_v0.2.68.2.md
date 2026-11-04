# 0.2.68.2 - Conditional damage and Controller corrections

Approved C471,2026-10-25. Coordinates with Horde/Cure0.6.16.8; Trait Shop0.9.1.1 remains unchanged.

- Finalize zombie starting health after native spawn overrides, before the first damage/update. Initial Blow and Execute use that baseline. Preserve wounded/unknown handling, Horde toughness and server authority. Add bounded opt-in conditional diagnostics.
- Execute defaults to18% finishing health, plus2% per extra active copy. Explicit saved values, including zero, are preserved. Describe additive chance/threshold changes using percentages.
- Own Controller maps, lists, links and requests exclude foreign-owner devices, including public/faction-owned devices. Explicit access to a shared Controller still operates its owner's network.
- Queue new own devices and Controllers for nearest eligible own-network assignment, retaining32-per-category limits, existing assignments and manual trigger links. Work is sliced across ticks.
- Reject native BlocksPlacement furniture in Controller preview/completion. Rename the display to T&T Controller; stockpile meter shows used/total Weight.
- A dragged stack of identical expansion kits replaces with one exact item. Mixed selections ask for one type; existing atomic exchange and overflow handling remain.
- Tether zombie impact pushes away; retraction pulls toward the muzzle. Collision-safe pending movement runs only on the simulation owner, skips native traversal/ragdoll states, and expires in game time. Defaults0.35/0.75tiles, customizable or disabled;0.5s reset after return. Player wound behavior is unchanged.
- Scale a separate native manual-icon region to16px for Turret Specialist, preserving inventory artwork. Hide the old Poke Floor debug-list duplicate while retaining its saved ID.
- Horde updates the reviewed Execute/tether defaults and removes the combined-score hypothetical. Changed coupled movement values require review; historical run flags are retained.

Opposite-face Barbed Panel backing remains thumpable. Both faces pass native creation/contact/save/reload/removal tests. The reported live override is not reproduced; a focused owner retest remains. No new backing armor behavior is added. See the verification record for the final result and remaining live checks.
