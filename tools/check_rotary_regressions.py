"""Prove the released rotary paths fail the corrective regression assertions."""
import check_response_regressions as replay

replay.OUT = replay.ROOT / "diagnostics/c528"
replay.BASE = "bd42f08"
replay.CASES = {
    "rotary-idle-handoff": (["client/TurretRenderer"], "C528 idle renderer uses the same motor timeline"),
    "rotary-stale-position": (["server/TurretRotary"], "C528 rotary hits using fresh owner position"),
    "rotary-nil-animation": (["server/TurretConditionalHit"], "missing argument #1 to 'lower'"),
}

if __name__ == "__main__":
    replay.main()
