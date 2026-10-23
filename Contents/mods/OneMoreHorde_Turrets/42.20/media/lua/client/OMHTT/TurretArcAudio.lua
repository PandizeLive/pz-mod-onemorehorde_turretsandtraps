if isServer() then return end
local F = require("OMHTT/Foundation")
local Effects = require("OMHTT/DefenseEffects")
local Options = require("OMHTT/ControlOptions")
local Stats = require("OMHTT/TurretStats")
local A = {window = 0, impacts = 0}

---@param module string Namespace
---@param command string Authoritative sound event
---@param facts table Position and suppression gain
function A.receive(module, command, facts)
    if module ~= F.MODULE or (command ~= "ArcShot" and command ~= "ArcHit") or type(facts) ~= "table" then return end
    for _, key in pairs({"x", "y", "z", "gain"}) do
        if type(facts[key]) ~= "number" or facts[key] ~= facts[key] or math.abs(facts[key]) == math.huge then return end
    end
    if not Effects.accept(facts) then return end
    local volume = Stats.option("DeviceSoundVolume", 1, 0, 2) * Options.get("FeedbackVolume") / 100
    if volume <= 0 then return end
    local impact = command == "ArcHit"
    if impact then
        local now = getTimestampMs()
        if now < A.window or now - A.window >= 100 then
            A.window, A.impacts = now, 0
        end
        if A.impacts >= 4 then return end
        A.impacts = A.impacts + 1
    end
    local gain = math.max(Stats.option("SuppressionVolumeFloor", 10, 1, 100) / 100, math.min(1, facts.gain))
    local emitter = getWorld():getFreeEmitter(facts.x, facts.y, facts.z)
    local handle = emitter:playSound(impact and "DismantleFailed" or "OMHTTArcFire")
    emitter:setVolume(handle, volume * gain * (impact and .12 or 1.3))
end

Events.OnServerCommand.Add(A.receive)
Events.OnGameStart.Add(function() A.window, A.impacts = 0, 0 end)
return A
