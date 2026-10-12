if isClient() or isServer() then return end
local P = require("OMHTT/TurretModulePack")
Events.OnZombieDead.Add(P.onDeath)
return P
