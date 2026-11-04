# 0.2.37: targeting feedback, contact audio and active-time repairs

C113 approves fixing the prior review's actionable findings. The owner explicitly chooses counting elapsed active time after stalls without catch-up bursts; pause/offline time remains excluded.

- Selected-turret coverage uses the actual automatic profile. Cyan shows automatic range; a gray boundary shows longer manual reach when Improvised Detection reduces automatic coverage. No detector means manual-only feedback. A translated legend states the ranges; damage and targeting rules are unchanged.
- Alternate potato head/turret recipes are named **Without Tire Pump**, preserving identical output and all inputs/skills. Head, empty-base and assembled-turret descriptions now describe their actual output and remaining requirements. Improvised modules keep their existing names and drawbacks.
- Barbed Panel uses registered native `ZombieClawChainlinkFence` on successful damage, at reduced playback gain and at most four new contact sounds per second across panels. This audio cap never suppresses damage/wear and adds no AI-hearing event. Audible mix remains pending acceptance.
- Range arcs, arrow segment tables and translated legends are reused until inputs change; camera/zoom values are sampled once per viewport render. Targeting/damage remain unaffected. A 500-render test verifies geometry reuse and exactly 500 zoom samples, replacing repeated per-endpoint sampling.
- Optional existing diagnostics aggregate count/total/peak durations for head animation, head drawing, range drawing and projectile effects, plus active-update gaps. Existing audio-stage telemetry remains available. No per-frame print or unbounded sample buffer is added. These measurements identify work to investigate; they do not by themselves establish the cause or resolution of the reported client pauses.
- Turret, bed and barb clocks share elapsed-time/pause observation. An actual 700ms active stall advances timers 700ms. The native `OnTickEvenPaused` event records pauses even when ordinary ticks stop; resume and process-local initialization exclude pause/offline elapsed time. Due actions schedule their next deadline from now, rather than replaying missed deadlines. Persisted turret deadlines still rebase by their remaining duration.

The existing zombie forward-collapse and recovery implementation is retained. Its native parsing/controlled recovery is checked again; the new captured 0.2.36.1 log observes 20 trip and 18 damage/fall events with no ERROR/Exception/STACK TRACE after its loaded marker. Neither proves rendered movement or surviving get-up acceptance. No new collapse animation is substituted without failure evidence.

## Evidence and remaining gates

3,919 Kahlua assertions, 93 compiled runtime/translation files, 561 native translation keys and 23 packet serializations pass. Checks cover reduced/manual coverage, no-detector feedback, geometry/projection reuse, bounded profiling, contact audio rate limits, 700ms stalls, pause without normal ticks, clock rollback and no repeated shots from missed deadlines. Native tooltip/sound registration, persistence, package selection and installation results are recorded in [RELEASE.md](RELEASE.md).

Native evidence: installed 42.21 `IngameState` bytecode emits `OnTickEvenPaused` from its update path; `media/scripts/generated/sounds/zombies/sounds_zombie_foley.txt` registers the chain-link claw event. No custom audio asset or speculative engine method was introduced.

Only [TEST_v0.2.37.md](TEST_v0.2.37.md) remains active. Dense-client frame smoothness, sound mix and visible collapse/recovery require that rendered check. This patch does not establish multiplayer support or introduce final art, player barb injury, garage-door support or new roadmap content.
