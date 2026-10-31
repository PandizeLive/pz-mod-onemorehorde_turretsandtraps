"""C534 released-code controls for the reported burst/audio/pause/build failures."""
import check_response_regressions as replay

replay.OUT = replay.ROOT / "diagnostics/c534"
replay.BASE = "9f83c8e"
# New callers require a named predicate. This adapter exposes exactly the old
# native-only pause condition; the frozen clock and its incorrect zero-rate behavior remain.
replay.SOURCE_ADAPTERS = {"shared/ActiveTime": lambda raw: raw.replace(b"return A", b"A.paused = function() return GameTime.isGamePaused() end\nreturn A")}
replay.CASES = {
    "busy-firearm-burst": (["server/TurretVolley"], "C534 busy victim does not hold firearm presentation"),
    "late-firearm-receipt": (["client/PrototypeEffects"], "C534 old firearm burst cannot restart"),
    "outer-wall-edge": (["shared/ControlBuildReservation"], "C534 outer stabilizer-end wall allowed"),
    "zero-rate-pause": (["shared/ActiveTime"], "C534 zero multiplier freezes presentation and simulation"),
    "battery-targets": (["shared/TurretStats"], "C534 rounded endurance target"),
}

if __name__ == "__main__":
    replay.main()
