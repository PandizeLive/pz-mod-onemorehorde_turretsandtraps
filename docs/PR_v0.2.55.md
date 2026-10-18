The Controller's flat device list made connections hard to follow, and fixed window sizes limited usable space. This patch adds a shared Map/Connections layout with the existing native Stockpile, grouped selected-device actions, native map/grid backgrounds and server-authorized drag linking. Both management windows resize and restore local geometry; Manage keeps its existing item slots and Details/Load Order pages.

Placed defenses receive persistent unique display names without changing their network IDs. Buttons use temporary native switch graphics and left-click activation; legacy radio Buttons migrate through a retained native entity definition.

Validation: stock Build 42.21 Kahlua suite, native map/layout APIs, zero-client save/reload and independent package startup checks. Rendered and connected-client acceptance remains pending; this is a development patch, not a Workshop release.

Planning: [C323 contract](docs/CONTROLLER_MAP_C316.md#c323---implementation-approved-2026-10-18). [Patch](docs/PATCH_v0.2.55.md), [test evidence and owner checklist](docs/TEST_v0.2.55.md), [current handoff](docs/CURRENT_STATUS.md).
