# White cube-only turret placeholder

Temporary mechanical test asset, created 2026-09-25 at the owner's request. It is not concept art, final art, a style proposal or an approved silhouette. Final project art will be sourced by the owner without AI.

## Files

- [cube_turret.glb](cube_turret.glb): self-contained glTF 2.0 binary with separate base/head hierarchy and a head-rotation test animation.
- [cube_turret.gltf](cube_turret.gltf): equivalent inspectable JSON export with embedded binary data; no sidecar dependencies.
- [preview.png](preview.png): static technical preview.
- [rotation_preview.gif](rotation_preview.gif): two copies playing the exported rotation animation at independent times/directions. This is an offline preview, not an in-game or multiplayer capture.
- [Generator](../../../tools/build_cube_placeholder.py): procedural cube construction, export, structural checks and previews. Uses Python, NumPy and Pillow; no image-generation model or downloaded assets.

## Geometry and transforms

Exactly three uniformly scaled cubes, 36 rendered triangles per instance, one untextured white material. Plain display lighting adds gray shading to show faces; the material color remains white. No logos, surface detailing, bevels, textures, damage art, actual barrel geometry or decorative elements.

| Node | Function |
| --- | --- |
| PlaceholderRoot | Instance placement origin |
| Base | Fixed cube; bottom at Y=0 |
| HeadPivot | Independent rotation around local Y |
| Head | Cube attached to HeadPivot |
| AimCube | Small cube attached to HeadPivot so its direction is visible |
| MuzzleMarker | Invisible transform marker at the end of AimCube; adds no geometry |

Coordinates follow the glTF convention: Y up; initial forward direction is +X for this test. Dimensions, axes, scaling and hierarchy are provisional mechanical setup, not requirements imposed on final artists. Adapt to the verified PZ import path rather than assuming this file can be dropped into the game unchanged.

HeadYawPreview contains a four-second 360-degree Y rotation on HeadPivot only. Four seconds is preview playback time, not a turret fire/turn balance choice. The base does not animate. The two-instance GIF uses different animation times/directions to demonstrate separable transforms; it does not prove native PZ per-instance rotation.

## Validation and use

The generator rereads the exported GLB and checks its header, chunks/accessor bounds, finite data, triangle winding, cube-only geometry, plain white material, fixed base and moving aim cube. Previews are rendered from that exported geometry and animation. The static preview was visually inspected.

No external glTF validator or Blender import has been run. PZ importing/rendering, per-instance runtime yaw, world lighting/occlusion, shooting and multiplayer synchronization remain untested. This asset does not complete the P1C3 gameplay checkpoint and has not been installed or published.

Rebuild from the project root with the configured Python runtime:

```text
python tools/build_cube_placeholder.py
```

This replaces only the four generated files in this placeholder folder. The asset is intentionally disposable when the externally sourced final art is supplied.

## Phase 1 batch sprite proof

The batch adds sixteen transparent head-facing sprites generated from this same three-cube model by `tools/build_foundation_sprite.py`, with a fixed base. These are technical per-instance sprite changes, not native articulated 3D import, final art or art direction. In-game occlusion and visual acceptance remain pending. The impact uses temporary white text dots only.
