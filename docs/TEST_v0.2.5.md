# 0.2.5 owner test: failed collision and traversal acceptance

Capture: `diagnostics/captures/20260927-172343-3476/`. Both client-ready and server-ready identify 0.2.5. The owner supplied a screenshot showing cyan collision lines displaced up/left from the placed barriers, and reports gaps at diagonal layouts and inconsistent vaulting, including sprint wall reactions near joins. Alt sometimes succeeds; it is not wholly disabled.

The captured run contains repeated successful native running crossings reported by our tracker as interrupted/contact=false. `vaultOverRun.xml` and `vaultOverSprint.xml` keep ClimbFenceStarted false; waiting for that flag suppressed contact scratches. Context climbing uses a different animation and did produce contact evidence. The captured warnings do not establish a new OMHTT exception; a clean exception log does not make this test a pass.

## Source corrections prepared in 0.2.5.1

- Screen-space collision lines and temporary text markers move from OnPostRender to OnPostUIDraw. Current installed IngameState.renderFrameInternal emits OnPostRender inside the world pass, before EndFrame; UIManager.render emits OnPostUIDraw in the UI pass. Dividing coordinates by zoom and submitting them to the world pass applied projection in the wrong stage.
- Automatic vault proximity follows the player's native collision feeler plus a 0.02-tile boundary tolerance. The former 0.45 cutoff sat inside the installed IsoMovingObject 0.5 feeler, allowing a wall collision before our trigger. Held native movement may trigger even if collision has stopped displacement. Blocked native states remain blocked and are logged with position/distance/state/run/sprint fields.
- Contact tracking recognizes native VaultOverRun/VaultOverSprint, with one settlement for a successful landing between update samples. It does not set animation flags, replace native trip probability, teleport, or make collision globally passable.
- Overlay diagnostics record render phase, world position/floor, projected position, zoom and camera offsets every five seconds while visible.

Validation: 604 Kahlua assertions, 22 runtime Lua modules, 103 native translation keys and 23 packet serializations pass. New regressions cover native-feeler distance, held movement at a stopped collision, root-motion contact without ClimbFenceStarted, single settlement between samples, UI render phase and floor/zoom/viewport projection. World/UI test objects remain doubles; visual alignment and native movement acceptance are unverified. No new server smoke is claimed for these client-only corrections.

0.2.5.1 is a source draft, **not installed**. Installed 0.2.5 remains failed. The owner clarified that zombie collision must cover the full occupied tiles; native edge collision for both actor types does not meet this requirement. See the [separate collision feasibility checkpoint](PHASE_2_COLLISION_FEASIBILITY.md). No owner retest is requested until that design is resolved.

## Follow-up

C40 resolves the geometry choice in favor of a shared native front-and-end outline with an open rear. All corrections above are included in 0.2.6; 0.2.5.1 was never installed or published. See the [current checkpoint and test](PHASE_2_CHECKPOINT_2_OUTLINE.md). The 0.2.5 failed result remains unchanged.
