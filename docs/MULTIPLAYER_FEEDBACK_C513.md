# C513 - Damage delivery resumed, connected timing still failed

2026-10-30. Owner: "I don't think anything was solved? Check logs", followed by "Concertina, poke floor, etc was all delayed." Record this as failed connected acceptance. Successful health changes do not establish prompt activation, reaction, damage display or observer parity.

## Captured evidence

Read-only local and saved-login SFTP captures are retained under ignored `diagnostics/c513`. [Sanitized measurements and capture hashes](evidence/c513-log-review.json) retain the reproducible counts. Both client and server diagnostics, and both downloaded server package metadata files, identify **0.2.70.9**. No production, install, package, version, server configuration or sibling changes were made.

- The previous `UdpConnection.havePlayer` exception is absent. The server accepted **570 owner-contact reports**. This establishes that C512 repaired that exception, not that multiplayer traps are now acceptable.
- Contact observation-to-server receipt averages **44.2 ms**, maximum **72 ms**, over those 570 reports. This does not include any time before the client observed contact, subsequent damage delivery, or rendering.
- Diagnostic summaries count **36 applied combat results**. Six retained individual results show five Poke Floor hits and one barbed hit. One Poke hit completes a native server death/corpse. Their server damage-request-to-result times are **82-105 ms**, dispatch delay **0-1 ms**, and reported client handler processing **0 ms**. These are neither ping readings nor contact-to-visible-response measurements.
- Client summaries count **six Spike Barrier contact starts and zero strike reports sent**; server strike report/acceptance/damage counters are absent. The failure remains before report emission. These counters alone do not distinguish a missing animation marker, an interrupted animation, or a later client ownership guard.
- **35 Bed contact measurements** appear, but no Bed trip/landing/fall event appears in the captured server console or debug log. This capture does not establish a successful Bed landing hit or prove why one is missing.
- An early server summary records a **1,396 ms update gap**; later windows are around the normal 100 ms server update cadence. There is no per-contact correlation establishing that this early stall caused the owner's ongoing symptoms. Do not blame the internet or claim uniformly low end-to-end latency.

The inherited capture helper downloaded `ONEMOREHORDE_SandboxVars.lua`, whose correspondence to the active session is not established. Do not use that file to claim current trap tuning or detailed-logging settings.

## Confirmed remaining architectural wait

`DefenseContactClient.update/flush` reports locally owned zombie position and stance; it does not start Poke presentation. `ControlPoke.step/visual` runs after server contact admission and publishes the raised sprite back to clients. The first eligible strike is requested in that same server call; the **150 ms cycle window is an eligibility window, not a startup delay**.

Concertina's `BarbRuntime.zombie` similarly requests slowdown from the server, and `DefenseMotion.command/update` applies it on the owning client after receipt, while rechecking contact. Damage travels through `DefenseCombatServer` to the owner and returns for server settlement. `DamageNotice` is sent after that settlement. Consequently, contact reporting did not make the initial Poke visual, wire slowdown or confirmed damage popup immediate on the client. These remaining waits are real codepath properties, although this log does not measure their complete visible duration.

## Next proof and scope boundary

Recommend following one real contact through local detection, server admission, owner effect application, settlement and visible notification using a shared correlation identity and synchronized timing. Include Poke fast crossings, wire entry/exit, Bed landing, and native Barrier marker generation. Keep tracing bounded. Then replace the proven waiting mechanism where feasible; distinguish local presentation from authoritative damage, ownership, Horde consent and XP. Do not bypass those authority requirements or introduce duplicate damage.

Do not package another speculative timing fix or reuse fixture assertion counts as proof of connected responsiveness. The earlier replay manually supplied Barrier markers and therefore did not prove native animation output. The exact native marker failure and full contact-to-visible latency remain unresolved. This investigation does not authorize a new gameplay change or declare the current build ready for acceptance testing.

GitHub synchronization remains blocked by the previously recorded automatic approval-review rejection over destination authorization. No alternate push route was attempted. Local findings are retained; no new owner test is requested for this unchanged build.
