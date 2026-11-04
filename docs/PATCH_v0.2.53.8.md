# 0.2.53.8 — Controller battery clarity and multiple deposits

C302, 2026-10-17. Owner requests an item silhouette to identify the accepted battery and storage for multiple small batteries. Implement that request using the existing Controller Stockpile, ordinary `Base.Battery`, checked exact-item actions and native script icon. No separate battery inventory, balance/capacity change, or turret car-battery change.

The empty Controller battery slot now shows a faded native Battery icon. Its header shows the stored ordinary-battery count (including empty ones), while the occupied row continues to show the selected battery and charge. Multiple carried batteries can be dropped together; one exact transfer runs at a time. Existing stored batteries select a single active spare without moving or duplicating items. Closing the window, losing access/reach or cancelling the running transfer stops further deposits. Capacity and item validity are checked on each action, including at server completion.

The existing power path selects another charged spare when necessary; this is existing behavior now verified, not a new parallel drain system. Depleted batteries stay in the Stockpile. No claim of an instantaneous handoff: Controller power has its existing one-second refresh and bounded item search.

Stored counts are cached, invalidated by native container changes, and rebuilt in slices of at most64 entries per UI update. Idle updates do not iterate contents. Selection filtering examines at most16 entries per update and permits one outstanding action. Single-player uses confirmed completion even if perform preceded the container mutation; multiplayer waits for the existing exact-item replication callback. The native action still owns all inventory mutation. No new global per-tick handler, shipped protected calls or generated icon asset.

[Verification and short test](TEST_v0.2.53.8.md). C301 grey styling and R4C2 priority remain unchanged. Rendered and connected multiplayer acceptance remain pending.

Installed from immutable `test/v0.2.53.8` / `33f446e57c4715b88e9f66276d5fe3a190ec4b2a`. All 288 source and 367 tagged/packaged/installed/archive files match; both 0.2.53.7 backups verify. [Release evidence](../diagnostics/v0.2.53.8/local-release.json). Development delivery uses the existing branch/draft PR under C108; no merge or Workshop upload.
