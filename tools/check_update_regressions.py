"""Freeze the previous installed implementations and prove each fails its repair check."""
import check_response_regressions as replay

replay.OUT = replay.ROOT / "diagnostics/c526"
replay.BASE = "ad91d55"
replay.CASES = {
    "physical-child-timing": (["server/TurretVolley"], "Fragments launch immediately at terminal stop"),
    "explosive-fragment-delay": (["server/TurretOrdnance"], "Minis launch at impact"),
    "rotary-packet-freeze": (["client/TurretAimView"], "C526 rotary prediction advances through delayed snapshots"),
    "tether-packet-freeze": (["shared/TetherCycle"], "C526 delayed tether snapshots"),
    "bomb-server-batching": (["shared/TurretTransferAction"], "C526 bomb batches use light-ammo time"),
}

if __name__ == "__main__":
    replay.main()
