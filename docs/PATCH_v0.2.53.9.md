# 0.2.53.9 — Context-aware empty-slot silhouettes

C305: owner says "Patch" after choosing C304/1A. Implement the approved treatment now, using available icons; this supersedes waiting for the future art pass.

- Context-aware empty-slot silhouettes
- Matching ammunition and removable-magazine hints
- Distinct battery silhouettes

Head, Expansion and available Module slots reuse normal category-representative icons. Physical Ammo and installed empty Void follow the current head; removable magazines show the exact matching magazine. Built-in magazines retain their status, rotary heads have no ammo/magazine hints, and missing Head/Void requirements remain explicit. A Head tooltip clarifies that supported firearms also fit. The extra summary row stays inside its existing clip.

A shared client-only helper resolves script textures once per type transition, preserves transparency and draws black with a small neutral-grey backing for contrast. No new art, dummy hint items, inventory scans, network commands or persistent state. Real items retain ordinary colored icons and exact-item drag/drop. Custom cube placeholders remain until owner art arrives. Existing Controller battery stacking/counting is unchanged.

[Verification and short test](TEST_v0.2.53.9.md). Native draw signature is checked against installed 42.21 UI source. Rendered readability and connected multiplayer acceptance remain pending; R4C2 is still the next content checkpoint.

Installed from immutable `test/v0.2.53.9` / `1c0aabbd367725329b9162acbe601b153842059f`. All 289 source and 369 tagged/packaged/installed/archive files match; both 0.2.53.8 backups verify. [Release evidence](../diagnostics/v0.2.53.9/local-release.json). Development delivery uses the existing branch/draft PR under C108; no merge or Workshop upload.
