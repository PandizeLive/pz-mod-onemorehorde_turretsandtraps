# Cube-only hybrid rendering probe

Adds an opt-in single-player debug scene to evaluate a stationary base tile and independently rotating 3D head. Separate cube geometry, native model-item rotation, height/scale controls and structured diagnostics let the owner verify alignment, lighting, occlusion and persistence before artists commit to exports.

Gameplay turrets remain on their existing sprites. This is not automatic firing, a live turret-head integration, a production fallback or multiplayer support. See [scope and complete test](PHASE_2_HYBRID_RENDER_PROBE.md). Native asset processing and headless checks cannot certify rendered acceptance.
