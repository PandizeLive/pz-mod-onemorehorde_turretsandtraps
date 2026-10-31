# 0.2.53.10 — Pressure plates and Controller facing

C308, 2026-10-17. Owner says "Patch", authorizing the C306 corrections and C307/1A Set Facing. R4C1 corrective scope only; R4C2 Poke Floor remains the next content checkpoint.

- Non-thumpable pressure plates
- Clearer Controller linking
- Controller Set Facing

New and previously placed plates receive native pass-through/non-thumpable flags during registration/reload and client loading. The passive-kind registry is the rule to reuse for future sensors; no new sensors are added. Controller durability and existing defense collision remain unchanged.

Connections show the selected source and linked/unlinked state, with one contextual Connect/Disconnect action. Selecting an input tells the player to select a turret next. Source access renews alongside the selected receiver while the Controller remains open. Existing limits, ownership, targeting and power semantics are retained.

Set Facing appears for Controller turret selections. A powered Controller, assignment, write access and range are checked again by the server-side timed action. The native world cursor temporarily hides the menu, previews the selected direction and FoV, and returns to the same window on click or cancel. Selection never shoots. Saved exact-angle facing drives targeting, straight shots and previews; the base sprite/identity remains unchanged. Detection continues normal tracking, and 360 retains full coverage.

An OFF turret saves the direction without turning. On power, a bounded turn uses the head's configured speed before firing resumes. A later explicit button pulse can finish that turn and request one shot/cycle; it does not accumulate a backlog or leave firing power enabled. A new facing selection clears any prior pending pulse intent. A new physical placement follows its chosen placement orientation, while ordinary save/reload preserves the Controller direction.

No new general per-tick scanner. Direction work shares the existing bounded aiming queue; client cursor work exists only while choosing a point. No protected calls, new persistent item storage or client-authoritative world edits. [Verification and short test](TEST_v0.2.53.10.md). Native validation/install evidence is tracked there; rendered and connected multiplayer acceptance remain pending.
