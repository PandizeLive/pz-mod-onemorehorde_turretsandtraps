# Project tools

Phase 1 prototype tooling is implemented; no publisher exists. Current validation output is `diagnostics/v<packaged-version>`; earlier checkpoint evidence is retained separately. Native animation parsing now verifies the barrier's two strike markers and matching variable bindings.

- [build_cube_placeholder.py](build_cube_placeholder.py): cube-only GLB/glTF and offline previews.
- [build_foundation_sprite.py](build_foundation_sprite.py): the legacy cube plus sixteen potato facings, four barrier arrows and one foundation marker; white technical footprints/labels only; no art direction or native 3D rotation claim.
- [validate_foundation.py](validate_foundation.py) and [KahluaCheck.java](KahluaCheck.java): native JSON translation loading/formatting, installed Kahlua compilation, native table/packet serialization, behavioral doubles, translation/asset checks and SHA-256 package manifest.
- [Install-Foundation.ps1](Install-Foundation.ps1), also available through the [project launcher](../OMH.cmd): verified local copy; refuses an unmanaged existing installation and backs up an earlier managed copy. It does not enable mods, alter saves or publish.
- [smoke_server.py](smoke_server.py): repeat the prepared isolated localhost server restart, then quit cleanly. Requires the existing `diagnostics/p1c1/server-cache` test configuration/database from the recorded first start. It is a developer check, not the connected-player acceptance test.

The placeholder generator requires Python, NumPy and Pillow, available in the bundled workspace Python runtime used for this task. It produces unstyled technical geometry without an image-generation model. Read the [asset notes](../art/placeholders/cube_turret/README.md) for limits and rebuilding.

## First tools to add

- Remaining P1: actual player/world lifecycle evidence and connected-player dedicated checks.
- P2: item/recipe/translation references and configuration schema checks where they catch real packaging failures.
- P3: reward conservation/deduplication and score/export contract tests, plus a two-player/offline test setup when needed.
- Release: one stable owner-facing project launcher for validation/install and authorized mirror/publish operations. Confirm its name/workflow when the first package exists.

Reuse appropriate existing workspace dependencies and proven OMH tool patterns after reading them. Do not copy the sibling project's entire toolchain, create inert wrappers, initialize remote projects, or publish a stub package merely to fill this directory.

Documentation links and status consistency can be checked with a short local audit; a dedicated testing framework is unnecessary for this foundation pass.

[Capture-Diagnostics.ps1](Capture-Diagnostics.ps1) / [OMH.cmd option 6](../OMH.cmd) preserves console, OMHTT trace, error context and installed manifest in a timestamped local capture. No upload or deletion. See the [diagnostic record](../docs/checkpoints/P1_DEBUG_RECORD.md).

The stable menu and local tag checks follow [RELEASE_TOOLS.md](../docs/RELEASE_TOOLS.md). Mirror/publish remain explicitly unavailable. `test_release_tools.py` checks install readiness, modified source, backup preservation and unavailable remote actions using disposable local fixtures.
