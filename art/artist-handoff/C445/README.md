# OMH: Turrets & Traps artist handoff

Baseline: installed development build **0.2.66**, source commit `7d56836bc097711ee426e0fdda9bf8a3598bbf76`. Prepared 2026-10-24, C445. This is an asset reference and editable development kit, not an installable texture pack. No texture-switching system is required or proposed.

## Start here

- `HEAD_PREVIEW.png`: six new block-only head placeholders. These are staged, not installed or engine-tested.
- `MODULE_PREVIEW.png`: 32 module and four expansion-kit identification markers, one per exact component. These are neutral developer labels, not replacement final art.
- `current/`: the actual exported textures, models, depth data, tile definitions and texture pack from Source. Shared files appear once.
- `current/unpacked_pages/`: editable PNGs extracted from the native texture pack when a matching loose PNG was not already included.
- `editable_originals/potato/`: the existing procedural base/Potato GLB and GLTF, including separate base, head pivot and muzzle marker.
- `development/heads/`: editable OBJ plus matching native text `.x` for Ballista, Scrapshot, Lobber, Arc, Rotary Bat and Rotary Blades.
- `development/modules/`: plain labeled PNGs organized by Performance, Automation, Effects, Utility and Expansion.
- `reference/`: current item/model scripts and rendering code identifying which assets the game actually uses. These are reference files, not instructions to override the entire mod.
- `manifest.json`: every original path, canonical file, hash, dimensions, sprite name/rectangle/offset, module/item identity and new head mapping.

The manifest maps **202 references to 161 unique payloads**. A missing duplicate filename is intentional: follow its `file` value. Native `.pack` files naturally contain their runtime pages; the separately extracted PNGs are the artist-editable representations. Do not edit both the compiled pack and its source image independently.

## What to return

Send changed assets plus your editable sources, a list of replaced manifest `source`/item IDs, and author/license information. Preserve exact item and sprite identifiers unless you discuss a rename with the owner. Include a neutral in-game-size preview; high-resolution-only previews hide readability problems. Codex will integrate/repack the chosen work, so the artist does not need to build a mod or change gameplay code.

Final form, style, materials and detailing are the artist's and owner's decisions. The plain boxes, labels and arrows are mechanical aids only. Existing final artwork remains owner-sourced without AI. Keep the current supplied category/rarity icon set intact while exploring alternatives.

## Turret models and pivots

The base and head are separate. The existing native head mesh uses **Y up, +X forward**, with its rotation origin at `(0,0,0)`. The renderer positions it at the turret tile center; its current world Z is `0.4 - 16/192`, and most custom heads use world scale `0.512`. Native model scale is `1.0`. These are existing render parameters, not a requirement that final models look like cubes.

Preserve a useful aiming pivot: standby pitches the head down 45 degrees; wake returns it to aim. Verify all yaw angles, pitch extremes and occlusion against a base before acceptance. `reference/rendering/TurretRenderer.lua` is the exact baseline. Muzzle metadata in the new head manifest is a proposed model endpoint only; it does not change gameplay launch origins.

The six new heads use **24-48 triangles each** and shared white shading. Their OBJ and native `.x` coordinates match. UVs cover each cube face with the same square, suitable for a plain development texture; a final painted model needs a deliberate UV unwrap. No animation rig, material style or additional moving parts are mandated.

**Rotary Bat/Blades are one arm each.** The existing renderer draws the arm twice around the base, at opposite headings, with scale `0.25`. Do not also build two complete arms into that mesh or they will be duplicated. Integration must check arm length/scale against actual hit reach.

Potato retains its existing two-box head rather than receiving a duplicate. Firearms retain the actual mounted game's/mod's weapon model and the existing OMHTT support mesh; a generic firearm replacement would erase weapon identity. Native/third-party gun meshes are referenced, not redistributed in this handoff.

The staged head meshes are not yet registered in production item scripts. A later approved patch will assign model IDs, keep existing item identities and validate native loading, all facings, standby and fallback behavior. Six OBJ exports are editable independently; no separate package or duplicate item is intended.

## Sprites, traps and wall devices

Use `spritePages` in the manifest to find each `omhtt_barrier_*` sprite. Rectangles are atlas pixel X/Y/width/height. Offsets and original size are stored separately; do not bake offsets into the image and then apply them again.

Most developer world tiles are 128x256 with a ground anchor at `(64,224)`. Some wall devices use page/geometry offsets. Preserve their exact native mapping, not just visible whitespace. Barriers have paired tiles and directional fronts/ends; traps have multiple states and facings. The visible tile and its depth geometry/map must agree, especially raised bases and wall-mounted Lever/Laser/Tether panels. A PNG replacement alone is insufficient when geometry changes.

`common/media/tileGeometry.txt`, the depth map and tile definition are included through their canonical manifest entries. Geometry/depth data are technical references; coordinate changes require integration and in-game occlusion checks. The cable, nail, Arc and indicator meshes/textures are included as shared assets.

## Modules and rarity

Current inventory/Manage artwork is selected by **category plus effective rarity**, not by individual module filename. Five categories each have seven exported rarity images. The module manifest gives every exact item ID and its category. A Sandbox/LootLab rarity change must still select the corresponding category image and tooltip color.

The 36 new neutral markers are one-per-component test alternatives. They are not 252 copies of the same marker with colors, and they do not override the current rarity-aware artwork. If final work gives each module a unique design, return a neutral original/mask and agree the rarity treatment with the owner; integration must preserve live rarity changes. A neutral marker is not evidence of any module's tier.

## Provenance and limitations

Current source assets are project-owned procedural placeholders and owner-supplied module category art. The manifest preserves their paths and hashes. No vanilla audio, vanilla firearm models, third-party art, saves, credentials or personal logs are included. The existing GLTF/GLB are two formats of the original editable scene, not two game assets.

Verified: image decoding, pack-page rectangles, exact source/export hashes, one canonical path per identical payload, unique component IDs, finite mesh positions, triangle indexes and matching OBJ/native geometry. Previews were visually inspected. New meshes/markers have **not** been installed, loaded in the game renderer or multiplayer-tested. This kit does not certify in-game placement or depth.
