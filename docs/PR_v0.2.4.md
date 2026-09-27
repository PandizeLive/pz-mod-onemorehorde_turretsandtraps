# 0.2.4 — Fence collision and directional barrier vaulting

Spike Barriers built or deployed through Building now block two aligned tile edges and offer a native Vault action in their world submenu. Rear crossings are safe; completed front crossings have one 20 percent environmental scratch roll. Old built barriers convert by pickup/redeployment. Native placement rotation and shared durability remain intact; debug post-placement rotation is rejected for the new edge model.

This candidate includes the unaccepted 0.2.3 servicing/load-order/destruction/tooltip fixes, configurable barrier damage/HP and default damage 10. Approved recipes, ten-second free repair/pickup, full-condition recovery and five-item bundles are unchanged. No final art, multiplayer enablement or publication is included.

Validation: 535 Kahlua assertions, 19 modules, 92 native translation keys and 71 package files. Installed native collision, both pathfinder classifiers and public climb entry pass all four traversal directions; native execution uses simulated animation variables. Native write/read preserves eight legacy and eight edge parts at 37/200 HP in separate server processes. Environmental scratch API and existing recipe/bundle transactions pass. Rendered SP gameplay remains pending; see the [combined owner test](PHASE_2_CHECKPOINT_2_VAULT.md#owner-test).

The first expanded native probe exposed missing C++ pathfinder metadata; direct tile-property initialization resolves it while keeping zombie hopping disabled. Each vault logs identity, approach, entry, completion/rejection, roll and injury. Native fence-key integration remains future work.

Local test release only. Annotated rollback tag: `test/v0.2.4`. No successful Workshop content upload exists, so WORKSHOP_CHANGELOG.txt remains one cumulative draft containing all unuploaded changes.

Installed locally: all 71 files match annotated tag `test/v0.2.4` (`0ca7095`), package manifest and archive. The complete previous 0.2.3 backup contains 70 verified files. See [installation evidence](../diagnostics/v0.2.4/local-release.json). Client-loaded version and owner acceptance remain pending.
