This development branch delivers independently selectable OMH: Traps and OMH: Turrets, with the current 0.2.43 content and corrections. No Workshop publication or multiplayer combat certification.

- Independent traps: Spike Barriers, separate-tile Bed Spikes, support-mounted Barbed Panels and linked 1x2 Concertina; crafting/Building placement, servicing, contact movement, damage and native animation/audio handling.
- Modular potato/firearm turrets: exact physical inventory, expanded magazines/reserves, Enhanced Firing/Detection and bounded Splitter/Fragment/Piercing effects. Initial Blow, Execute and Impact retain their approved conditions.
- 0.2.43 fixes repeated inventory scans and mismatched Manage/inventory transfers with bounded native groups up to 20 items, shared validation and exact pending-item accounting. Five runtime optimizations reduce trap maintenance, contact lookups, repeated stat resolution, renderer housekeeping and queue/debug work.
- Adds Conservation Module with persistent fractional ammunition usage, including existing Splitter costs. Power remains per volley. Compact 4/6/6 Manage adds short grouped Installed Modules benefits, individual row tooltips and battery cost/volley/runtime estimates.
- LootLab 0.2.43 matches 25 modules/16 pools/175 entries; saved tuning and access protections remain intact.

Validation: 15,739 Kahlua assertions, 101 compiled runtime/translation files, 705 native keys, 23 packet serializations, native write/read and three independent-package startups. Firearms B42: 51 guns/153 firing transactions, no handheld timing changes. Native 600-round transfer: 30 groups, 13 ms preparation and 10 ms peak group in the fresh process. These isolated timings exclude rendered gameplay and do not certify elimination of all client pauses. LootLab: 75 API/page tests and production-bundle verification.

Installed test/v0.2.43 at 9a58373faca5ce2761b2b17e7679eb6f33085f13; all 195 source and 235 tagged/package/installed/archive files and both previous 0.2.42 backups verify. R3C7 and relevant R1C3 checks share one six-step owner test. The prior 0.2.41 round remains closed.

[Planning](https://github.com/PandizeLive/pz-mod-onemorehorde_turretsandtraps/blob/codex/performance-barbed-audit/docs/PLANNING.md) | [Current status](https://github.com/PandizeLive/pz-mod-onemorehorde_turretsandtraps/blob/codex/performance-barbed-audit/docs/CURRENT_STATUS.md) | [Patch](https://github.com/PandizeLive/pz-mod-onemorehorde_turretsandtraps/blob/codex/performance-barbed-audit/docs/PATCH_v0.2.43.md) | [Owner test and evidence](https://github.com/PandizeLive/pz-mod-onemorehorde_turretsandtraps/blob/codex/performance-barbed-audit/docs/TEST_v0.2.43.md) | [Release record](https://github.com/PandizeLive/pz-mod-onemorehorde_turretsandtraps/blob/codex/performance-barbed-audit/docs/RELEASE.md)

Rendered UI and actual crowd smoothness remain owner acceptance. No automatic merge or official release.
