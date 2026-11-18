# 0.2.70.5 - C501 world lighting for every lit turret state

Owner authorization (2026-10-28): "Let's do each light", following clarification that only the empty warning illuminated the world in0.2.70.4. Apply lighting to active green and asleep/waking amber as well. Disabled/unpowered remains unlit, consistent with its Dark state.

- Active turrets cast steady green light; asleep/waking turrets cast steady amber light. Empty turrets retain their snap-on, half-second fade and half-second dark pause.
- All lit states share one native lamp per visible nearby turret. Refilling changes the existing amber lamp to green; sleeping changes it to steady amber. Steady color/intensity does not cause redundant native setter calls.
- Retain the three-tile light radius,20-tile viewer distance, visibility checks, state-marker preferences and removal on disable, unload, lost visibility or changed world. The existing50ms light update ceiling applies to fades; no network traffic or additional saved state is introduced.
- The state-indicator Sandbox tooltip describes every lit state's world illumination. Existing server death, loading and loot corrections remain included.

No new engine API, asset, gameplay balance, sibling change or Workshop upload. No new world required.0.2.70.3 remains the last confirmed Workshop content baseline; keep the unuploaded0.2.70.4 corrections in the cumulative0.2.70.5 draft and consolidate the light description.

See [verification](TEST_v0.2.70.5.md).
