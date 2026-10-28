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
