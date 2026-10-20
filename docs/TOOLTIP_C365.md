# C365 — Head tooltip cleanup (2026-10-20)

Owner reports redundant "Head only" text and missing spacing before Medium on the M4, then requests continuation/confirmation. Remove the explanatory row entirely in both rich and plain head descriptions; keep colored Low/Medium/High ratings and unchanged consumption calculations.

The inventory footer draws the label and colored value separately. The installed 42.21 font width path uses final-glyph bounds rather than the trailing space's advance. Measuring the prefix alone therefore places the next draw too close. Position the value using full-line width minus value width; cache this offset with the existing description/font layout. No new per-frame measurement or Java API is introduced.

## Verification

- Installed Kahlua harness: **25,918 assertions passed**, including a draw-trace regression for Low/Medium/High at two font advances with native-style trailing-space metrics and unchanged-frame cache reuse.
- **252 runtime/translation files compile**, **1,099 translation keys** load through the native parser, and 27 packet serialization fixtures pass.
- Generated packages pass dependency closure and independence checks (25 reviewed optional dependencies, 169 unique Sandbox options, 84 identical shared files).
- Original suite emits existing native fixture Guid-table warnings; successful assertions do not establish rendered acceptance or connected-client acceptance. Raw local output: `diagnostics/tooltip-C365.log`.

Source/generated packages only. Installed immutable 0.2.58 remains unchanged; this correction is queued for the next gameplay patch. No version bump, retag, Workshop publication or LootLab change. C364's playable Tether Dart Trap integration still needs the documented tuning/recipe choices; the test mod is already retired.
