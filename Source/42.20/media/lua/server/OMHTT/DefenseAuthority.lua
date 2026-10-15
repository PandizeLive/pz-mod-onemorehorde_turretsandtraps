if isClient() then return end
-- Capability contract, not a declaration of connected-peer acceptance.
-- Horde owns the settings audit, consent, attribution and /5 score policy.
local A = rawget(_G, "OMHTT_DefenseAuthority")
if A then return A end
require("OMHTT/Damage")
require("OMHTT/DefenseCombatServer")
A = {HORDE_API_VERSION = 1, SETTINGS_BASELINE = "tt-c240-0.2.49"}
OMHTT_DefenseAuthority = A
return A
