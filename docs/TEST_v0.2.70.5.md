# 0.2.70.5 verification

Approved scope: [C501 patch](PATCH_v0.2.70.5.md).

- Full validation:37,154 assertions;448 source files and616 packaged files. Tests verify the same lamp changes from fading amber to steady green on refill, steady amber does not inherit the empty fade, and Dark removes the lamp. Existing visibility, distance, option and fade regressions pass.
- Native lighting APIs are unchanged from the installed42.21 proof in [C500 evidence](evidence/c500-verification.json). New steady-state colors and transitions are verified in production-code fixtures, not a rendered client. Native save/read and independent-package startup results follow below.
- Connected multiplayer, actual color/brightness and world-light rendering remain owner acceptance checks. Previous combat checks remain pending and are not waived by this visual update.

## Owner checklist

Use0.2.70.5 on the server and both clients after the owner uploads it. No new world required.

- Active green world light
- Sleeping and waking amber world light
- Empty pulse and refill transition
- Disabled turret remains dark


Native save/write116.8s, fresh-process read104.5s, Traps103.2s, Turrets91.0s and combined85.8s pass with zero clients. Installed from immutable `test/v0.2.70.5` / `6eb3aba648f7b888242a6ae256b4abbc0a9e1692`; all448 source and616 tagged/package/local/archive/stage files verify, plus both prior0.2.70.4 backups. Existing native Workshop stage preserves item3828638252 and page metadata/preview. Steam and hosted server were not changed. [Sanitized release evidence](evidence/c501-verification.json). The installer generic fresh-world message is not a new-world requirement for this patch.
