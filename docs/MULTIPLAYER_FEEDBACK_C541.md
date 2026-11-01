# C541: lights, pause, rotary and Tether investigation

2026-11-01. Owner reports disappearing turret lights/base indicators when turning, continued zombie sliding during pause, inconsistent rotary damage/presentation and occasional Tether nonactivation. Both captured sides load0.2.71.6. This is an investigation, not a corrective release or multiplayer acceptance.

## Findings

### Light lifetime follows player-facing visibility

`Source/42.20/media/lua/client/OMHTT/TurretRenderer.lua`, `R.render`, gates both the marker and `StateView.draw` on `square:isCanSee(playerIndex)`. `TurretStateView.tick` removes a native world light when its last draw is over200ms old. Turning away can therefore stop both the indicator draw and the light refresh although the turret remains powered and loaded. The focused replay confirms removal after201ms without unloading or disabling the object.

Recommended replacement: manage world lights from loaded turret state, with bounded nearby updates and removal on unload/destruction/preference changes. Draw the status indicator independently of facing; preserve geometry occlusion and existing on/off/empty colors. Validate current native visibility semantics before choosing the exact draw API. Do not globally reveal objects through walls or add per-frame world scans. Disabled/unpowered states remain dark as designed.

### Pause disagreement extends beyond T&T

The client stayed at multiplier0 for62,100ms. During that same interval the server recorded411 transitions between paused and running. The installed Multiplayer Fast Forwarding server code reapplies its accepted speed from its paused-tick handler. Fresh bytecode inspection of the current installed game shows `IsoPlayer.updateLOS` setting the multiplier to1 for nearby zombies in the non-client branch. This supplies a concrete native/MPFF conflict mechanism consistent with the captured oscillation; it is not merely a presumed bad connection.

It does not prove that every visible slide is exclusively external. T&T reads the same unstable clock, and actor interpolation/motion can also contribute. No individual combat-result events were recorded during this client-pause window; that is not proof that all native simulation stopped. Do not introduce another competing global setMultiplier loop. Any modification to MPFF or native behavior needs separate scope; first establish a stable pause contract and verify T&T respects it. Official mod reference: https://steamcommunity.com/sharedfiles/filedetails/?id=3774750148 . Installed code and captured logs are the evidence for this session, not the Workshop description.

### Two rotary loss paths reproduced

`Source/42.20/media/lua/server/OMHTT/TurretRotary.lua`, `R.contact`, rejects a job older than150ms before consulting the fresh owner observation and motor history. The scheduler can spread a crowded scan across several100ms server ticks. The production-function replay supplies a current owner observation and valid motor crossing: a200ms-old scan rejects it, while changing only job creation time admits the hit. This proves a stale scan gate can discard fresh evidence; it does not measure how many live misses took this branch.

The same function records both the owner observation and arm/pass before damage admission. A rejected `Damage.resolve` request returns zero through its callback but leaves those markers consumed. Replay confirms that the identical valid contact cannot retry until both markers are reset. This is a bounded-admission failure case, not evidence that every reported miss was queue exhaustion. Correct handling must distinguish pending, confirmed and rejected outcomes without allowing duplicate or arbitrarily late hits.

The latest server summary counts14 rotary hit attempts. Detailed turret logging was disabled, so the capture cannot establish their individual health outcomes or exact visual-to-damage offsets. The current client predicts motor travel while server contact uses historical observations; verify a shared timeline under realistic latency, crowd load and packet gaps rather than masking it with extra smoothing.

### Tether works often; missed activation is not yet attributed

The capture contains27 launches and23 zombie contacts, with23 confirmed dart damage results and16 pull damage results. The remaining launches are not automatically missed activations. Tether retains the approved3-second reset and requires an eligible unobstructed target when ready.

The shared owner-contact router counted87,606 accepted reports and6,973 position rejections. It rejects reports over2 tiles from the native replica, while combat depends on fresh accepted observations. Those rejections could contribute to intermittent detection, but this capture does not tie them to a specific Tether failure. Idle scans also lack reason-specific rejection records. Preserve ownership, identity, freshness and geometry checks; do not simply enlarge distance tolerances or add blind retries.

Next corrective work should reproduce crossings during reset, fast lane entry/exit, temporary replica disagreement and multiple actors; record bounded reason counters for rejected detection and distinguish blocked/eligible/not-ready/missing-current-position. Correct only failures established by those cases. A diagnostic addition alone is not a fix claim.

## Verification and limits

[Sanitized evidence](evidence/c541-findings.json), [production-function replay](evidence/c541-reproduction.lua). Run through the existing `KahluaCheck` optional audit argument. Eight failure checks plus two fixture checks pass; full harness reports44,493 assertions. These assertions deliberately demonstrate defects and do not imply a corrected build. Actor/network/world objects are test doubles; zero clients are connected to this replay. Initial fixture runs collided with an existing test turret tile; the final fixture uses a unique tile and identity. Captures and native disassembly remain local; only hashes, aggregate metrics and reviewed reproduction code are selected for sharing.

No gameplay, version, package, installation, Workshop, live-server or sibling-project changes. Four pre-existing owner documents remain byte-identical and unstaged. No new-world requirement has been identified.

## Proposed next scope

**1A recommended:** replace the facing-dependent light lifetime; correct rotary contact freshness and rejected-admission handling; verify motor/contact timing under load; reproduce and fix Tether nonactivation with bounded diagnostics. Validate T&T behavior against a stable pause signal, and report any required MPFF/native change separately before editing that external component. Include realistic latency/crowd/paused tests and retain authoritative damage and Horde attribution.

**1B:** lights only first; rotary and Tether remain unresolved and the external pause conflict remains open.

Owner feedback establishes the defects and desired light behavior; the new combined corrective scope has not been selected. **Decision needed.**
