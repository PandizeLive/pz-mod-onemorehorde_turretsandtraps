# C174 - Project Viewpoint compatibility feasibility

2026-10-12. Owner asks whether support is realistic before moving discussion to another chat. This authorizes investigation/planning, not an adapter, dependency change, new chat, or gameplay patch. Inspected OMHTT commit 881056e092ed37eecd74909ad46bc11c45cc4150 on codex/performance-barbed-audit; fetched origin, no incoming dev commits; draft PR #1 is the only open PR.

## Conclusion and scope

An optional compatibility adapter is realistic enough for a small prototype. Full support is not proven. Keep this proposed workstream separate from the C173 module pack/weight/battery patch. The additional support topic has now been identified; pack quantity/acquisition and other recorded choices still need settlement. Do not claim compatibility, enabled multiplayer, new final art, or successful rendered tests.

## Evidence inspected

- Installed Workshop 3809306528: mods/Viewpoint/common/mod.info declares Viewpoint 0.1.6, PZ 42.21 only, ZombieBuddy minimum 2.3.0, client Viewpoint.jar. Installed is not evidence enabled or compatible in the current save.
- Viewpoint_Mouse.lua wraps ISCoordConversion.ToWorld using Viewpoint.Mouse.worldX/worldY, with a native fallback. javap confirms those public Double-returning methods. OMHTT TurretMenu.lua:81 and BedMenu.lua:38 call IsoUtils directly, so this wrapper alone does not establish correct selection.
- Viewpoint_Interact.lua harvests native ISWorldObjectContextMenu.createMenu options and filters actions by the selected object. Existing OMHTT actions may be reusable, but object ownership arguments, reach checks and first-person selection require actual testing.
- OMHTT TurretRenderer.lua:143-150 uses Render3DItem for rotating heads/supports from RenderOpaqueObjectsInWorld (:193). Whether these draws appear correctly in Viewpoint's separate renderer is unresolved.
- TurretRange.lua:65-70 and PrototypeEffects.lua:106-107 use isometric screen projection and OnPreUIDraw. Range/coverage overlays and tracers need camera-aware projection/rendering; debug overlays need the same audit. Do not simply offset the existing isometric drawings.
- Native world-coordinate combat/state may be reusable (engineering inference); no integrated combat, placement, save/reload, GPU or performance test was run.

Primary sources checked 2026-10-12:

- [Project Viewpoint author description](https://steamcommunity.com/sharedfiles/filedetails/?id=3809306528): custom renderer, first/third-person modes, ZombieBuddy requirement and early-development status. Workshop access banners are not treated as reliable install-status evidence.
- [Unofficial addon author's source and documentation](https://github.com/T0XiQ96/project-viewpoint-fixes): third-party 3D markers/effects integrations exist, using ZombieBuddy patches/reflection. This demonstrates an integration route, not a supported/stable API or permission to copy assets/code.

## Recommended first gate, not approved implementation

1. Detect Viewpoint active/inactive safely; preserve normal OMHTT operation without Viewpoint or ZombieBuddy. Prefer optional adapter boundaries; a Java bridge may be needed for renderer integration and must not become a mandatory core dependency without owner approval.
2. Show one rotating turret correctly, select it, open Manage, place/pick it up, and fire with aligned effects. Verify camera switching and depth/occlusion, not only visibility.
3. Place/service one trap and verify its collision/contact effect and visual position. Determine whether existing trap sprites need optional owner-sourced 3D assets before promising polished first-person visuals.
4. Compare bounded render/update costs and repeat without Viewpoint; preserve inventory/state through save/reload. Extend to all defenses only after this proof.

Medium effort is sufficient for the initial compatibility audit; renderer prototype may require High. Recommend Fast if the implementation estimate exceeds 25 minutes. No reliable full-integration duration can be given before the renderer proof. Early Viewpoint changes and reliance on internal hooks can add maintenance costs.

## Handoff

Decision needed: authorize a separate compatibility prototype/chat if desired. No chat created, gameplay files changed, package built, or owner test requested here. C170 packed-weight cancellation and C171 pending corrective findings remain unchanged.
