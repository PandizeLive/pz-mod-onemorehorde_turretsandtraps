"""C538 frozen production controls for confirmed targets and client presentation."""
import check_response_regressions as replay

replay.OUT = replay.ROOT / "diagnostics/c538"
replay.BASE = "63947d3"
replay.CASES = {
    "child-confirmation": (["server/TurretVolley"], "C538 child projectile ignores unconfirmed actor"),
    "confirmed-target": (["shared/ControlCombat"], "C538 target requires current owner confirmation"),
    "missing-retry": (["server/Damage"], "C538 missing actor cannot recover on timer alone"),
    "owner-radius": (["server/TurretProc"], "C538 proc uses owner position inside radius"),
    "idle-sweep": (["client/TurretRenderer"], "C538 multiplayer idle sweep is cosmetic"),
    "counted-loading": (["shared/TurretTransferAction"], "C538 counted batch cannot bypass per-item loading time"),
    "native-reconcile": (["client/DefenseCombatClient"], "C538 client reconciles native actor lifecycle"),
    "native-spear": (["client/PrototypeEffects"], "C538 native spear uses opaque world rendering"),
}

if __name__ == "__main__":
    replay.main()
