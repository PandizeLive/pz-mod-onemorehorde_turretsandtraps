# 0.2.55 — Controller Map and resizable management

- Controller Map and Connections layout
- Grid / Native Map toggle
- Drag-to-connect controls
- Resizable Controller and Turret Manage menus
- Adaptive module grid and saved window sizes
- Persistent unique defense names
- Left-click Buttons and light-switch graphics

Connections occupies the left, Map sits above Selected Device, and the existing native Stockpile fills the right. Narrow windows open Stockpile as an attached page. Controls, Connections, and Access & Assignment remain separate. Manage keeps its in-menu Load Order and Details fallback; all 16 slots retain their item identity while resizing.

Native Map uses Zomboid's map data and visited-area policy; it is not a live satellite image. The grid remains available when map data or world-map access is unavailable. Passive traps gain persistent labels but do not become signal receivers. Existing power, access, same-floor/range and server validation rules remain in force.

[Approved contract](CONTROLLER_MAP_C316.md#c323---implementation-approved-2026-10-18) · [Verification and short test](TEST_v0.2.55.md).
