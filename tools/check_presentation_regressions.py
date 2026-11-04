"""C536 frozen production controls for presentation and actor lifecycle."""
import check_response_regressions as replay

replay.OUT = replay.ROOT / "diagnostics/c536"
replay.BASE = "8ec07f4"
replay.CASES = {
    "commitment-fan": (["server/TurretVolley"], "C536 primary and children share one committed presentation"),
    "late-first-arrival": (["client/PrototypeEffects"], "C536 delayed first-arrival Splitters remain visible"),
    "late-network-id": (["client/DefenseCombatClient"], "C536 delayed native ID resolves without an update callback"),
    "owner-aim": (["shared/TurretAim"], "C536 aim uses validated owner coordinates"),
    "owner-eligibility": (["shared/TurretModules"], "C536 firing eligibility shares validated aim"),
    "primary-snapshot": (["server/PrototypeCombat"], "C536 primary commit snapshots the same validated direction"),
}

if __name__ == "__main__":
    replay.main()
