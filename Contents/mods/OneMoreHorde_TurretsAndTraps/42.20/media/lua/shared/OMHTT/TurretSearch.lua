local Budget = require("OMHTT/TurretScheduler")
local Clock = require("OMHTT/TurretClock")
local T = require("OMHTT/Turret")
local M = require("OMHTT/TurretModules")
local D = require("OMHTT/Diagnostics")
local S = {targets = setmetatable({}, {__mode = "k"}), pending = {}, order = {}, cursor = 1, results = setmetatable({}, {__mode = "k"})}

---@param player IsoPlayer Operator
---@param object IsoObject Turret
---@return string status
function S.request(player, object)
    if S.pending[object] then return "Searching" end
    if #S.order >= 32 then return "Unavailable" end
    local aim = require("OMHTT/TurretAim").entries[object]
    if aim and aim.player then return "Aiming" end
    local profile = M.profile(T.state(object), T.contents(object:getContainer()))
    local held = S.targets[object]
    local Combat = require("OMHTT/PrototypeCombat")
    if held and held.priority == profile.priority and (profile.priority == "Random" or profile.priority == "Toughest")
        and M.inside(object:getSquare(), held.target, profile)
        and Combat.clearLane(object:getSquare(), held.target:getSquare(), profile.range) then
        return require("OMHTT/TurretWorld").fire(player, object, held.target)
    end
    S.targets[object] = nil
    local job = require("OMHTT/TurretAutomation").scan(object:getSquare(), profile)
    local entry = {object = object, player = player, job = job, started = getTimestampMs(), slices = 0, workMs = 0}
    S.pending[object] = entry
    S.order[#S.order + 1] = entry
    S.results[object] = nil
    return "Searching"
end

---@param entry table Queued search
---@param result string Outcome
---@return nil
function S.finish(entry, result)
    S.pending[entry.object] = nil
    S.results[entry.object] = {status = result, at = getTimestampMs()}
    D.emit("turret-manual-search", {id = T.state(entry.object) and T.state(entry.object).id,
        result = result, queueMs = getTimestampMs() - entry.started, searchMs = entry.workMs,
        slices = entry.slices, visits = entry.job.visited})
end

---@param entry table Queued search
---@param deadline number Frame budget end
---@return boolean done
function S.step(entry, deadline)
    local W = require("OMHTT/TurretWorld")
    local object = entry.object
    if entry.cancelled or not T.isOn(T.state(object)) or not W.valid(object) or not W.near(entry.player, object) or getTimestampMs() - entry.started > 10000 then
        S.finish(entry, "Unavailable")
        return true
    end
    local contents = T.contents(object:getContainer())
    if not W.power(object, contents) then S.finish(entry, "NoPower"); return true end
    local profile = M.profile(T.state(object), contents)
    local old = entry.job.profile
    if profile.range ~= old.range or profile.cone ~= old.cone or profile.priority ~= old.priority or profile.heading ~= old.heading then
        S.finish(entry, "Unavailable")
        return true
    end
    local started = getTimestampMs()
    local done = require("OMHTT/TurretAutomation").advance(entry.job, 64, deadline)
    entry.workMs, entry.slices = entry.workMs + getTimestampMs() - started, entry.slices + 1
    if not done then return false end
    local result = "NoTarget"
    if entry.job.best then
        S.targets[object] = {target = entry.job.best, priority = profile.priority}
        result = W.fire(entry.player, object, entry.job.best)
    end
    S.finish(entry, result)
    return true
end

---@return nil
function S.tick()
    if isClient() or isServer() then return end
    local deadline = Budget.limit(2)
    local count = math.min(4, #S.order)
    for i = 1, count do
        if #S.order == 0 or getTimestampMs() >= deadline then return end
        if S.cursor > #S.order then S.cursor = 1 end
        if S.step(S.order[S.cursor], deadline) then
            table.remove(S.order, S.cursor)
        else
            S.cursor = S.cursor + 1
        end
    end
end

Budget.register("S.tick", S.tick)
return S
