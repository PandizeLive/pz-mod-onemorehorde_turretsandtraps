if isClient() then return end
local T = require("OMHTT/Turret")
local M = require("OMHTT/TurretModules")
local Clock = require("OMHTT/TurretClock")
local S = {entries = setmetatable({}, {__mode = "k"})}

---@param object IsoObject Turret
---@param mode string Presentation state
---@param sound string? Transition cue
---@return nil
function S.mode(object, mode, sound)
    local state = T.state(object)
    if not state or state.standby == mode then return end
    state.standby = mode
    require("OMHTT/TurretAuthority").publish(object)
    if sound then require("OMHTT/ControlAudio").emit(object, sound) end
end

---@param object IsoObject Turret
---@param target IsoGameCharacter? Acquired target
---@param contents table Inventory summary
---@return boolean valid
function S.valid(object, target, contents)
    if not target or not require("OMHTT/ControlCombat").eligible(object, target) then return false end
    local stats = T.cycleConfig(contents)
    local profile = M.profile(T.state(object), contents, true, stats)
    return M.inside(object:getSquare(), target, profile)
        and require("OMHTT/PrototypeCombat").clearLane(object:getSquare(), target:getSquare(), profile.range)
end

---@param object IsoObject Turret
---@param contents table Inventory summary
---@param target IsoGameCharacter? Current eligible target
---@param busy boolean? Finish current action before idle
---@param validated boolean? Caller already checked target eligibility, range and LOS
---@return boolean ready
function S.step(object, contents, target, busy, validated)
    local state, now = T.state(object), Clock.now()
    if not state then return false end
    local entry = S.entries[object]
    if not entry then
        entry = {last = now}
        S.entries[object] = entry
        if state.standby == "waking" then S.mode(object, "asleep") end
    end
    local W = require("OMHTT/TurretWorld")
    if not T.isOn(state) or not W.valid(object) or not W.power(object, contents, T.cycleConfig(contents)) then
        entry.target, entry.untilTime, entry.last = nil, nil, now
        S.mode(object, "disabled")
        return false
    end
    if (SandboxVars.OMHTurretsTraps or {}).TurretStandbyEnabled == false or not contents.active.MotionDetection then
        entry.target, entry.untilTime, entry.last = nil, nil, now
        S.mode(object, "active")
        return true
    end
    if state.standby == "disabled" or not state.standby then S.mode(object, "active") end
    if entry.target and not (validated and entry.target == target) and not S.valid(object, entry.target, contents) then
        entry.target, entry.untilTime, entry.last = nil, nil, now
        S.mode(object, "asleep")
        return false
    end
    if target and (validated or S.valid(object, target, contents)) then
        entry.last = now
        if state.standby == "asleep" then
            entry.target = target
            entry.untilTime = now + M.option("TurretWakeSeconds", 1, 0, 10) * 1000
            S.mode(object, "waking")
        end
        if state.standby == "waking" then
            if now < entry.untilTime then return false end
            entry.target, entry.untilTime = nil, nil
            S.mode(object, "active", "awake")
        end
        return true
    end
    if entry.target then return false end
    if contents.head then
        local ItemState = require("OMHTT/TurretItemState")
        local cycle = ItemState.get(contents.head, "cycle")
        local gun = ItemState.get(contents.head, "gun")
        busy = busy or (cycle and cycle.reloadReady and cycle.reloadReady > now)
            or (gun and gun.reloadReady and gun.reloadReady > now)
    end
    if busy then entry.last = now end
    if not busy and now - entry.last >= M.option("TurretIdleSeconds", 7, 1, 120) * 1000 then
        S.mode(object, "asleep", "asleep")
    end
    return state.standby == "active"
end

return S
