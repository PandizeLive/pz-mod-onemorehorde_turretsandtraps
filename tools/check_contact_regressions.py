"""C531 frozen released-code controls for stacked presentation and disconnect."""
import check_response_regressions as replay

replay.OUT = replay.ROOT / "diagnostics/c531"
replay.BASE = "b7ffd87"
replay.CASES = {
    "stacked-primary": (["server/TurretVolley"], "C531 primary no longer waits for side scans"),
    "physical-contact": (["client/PrototypeEffects"], "C531 production render pops at actual occupied contact distance"),
    "disconnect-render": (["client/ControlTriggerView"], "C531 disconnect attempted a server-only access lookup"),
}

if __name__ == "__main__":
    replay.main()
