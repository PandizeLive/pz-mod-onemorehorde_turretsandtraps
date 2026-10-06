local G = require("OMHTT/Firearms")
local D = require("OMHTT/Diagnostics")
local Budget = require("OMHTT/TurretScheduler")
local A = {started = false, finished = false}

---@param fullType string Script identity
---@return table fields Adapter inspection
function A.inspect(fullType)
    local gun = instanceItem(fullType)
    local profile = G.profile(gun)
    if not profile then
        return {item = fullType, accepted = false, reason = G.rejection(gun)}
    end
    local stats = require("OMHTT/TurretStats").resolve({head = gun, active = {}})
    return {item = fullType, accepted = true, precision = require("OMHTT/FirearmClass").precision(gun),
        range = stats.range, damage = stats.damage, accuracy = stats.accuracy, farAccuracy = stats.farAccuracy,
        cooldownMs = stats.cooldown, reloadMs = stats.reload, rackMs = stats.rack,
        mechanism = tostring(gun:getWeaponReloadType()), mode = tostring(gun:getFireMode())}
end

---@return nil
function A.start()
    if A.started or not D.enabled("turrets") then return end
    A.started, A.finished = true, false
    A.scripts, A.cursor, A.accepted, A.rejected = getScriptManager():getAllItems(), 0, 0, 0
    A.pending, A.nextAt = {event = "firearm-audit-start", fields = {scripts = A.scripts:size()}}, 0
end

---@return nil
function A.tick()
    if not A.started or A.finished or not D.enabled("turrets") then return end
    local now = getTimestampMs()
    if now < A.nextAt then return end
    if A.pending then
        if not D.emit(A.pending.event, A.pending.fields, nil, true) then return end
        if A.pending.event == "firearm-audit-item" then
            if A.pending.fields.accepted then A.accepted = A.accepted + 1 else A.rejected = A.rejected + 1 end
        end
        local complete = A.pending.event == "firearm-audit-complete"
        A.pending = nil
        A.nextAt = now + 100
        if complete then
            A.finished, A.scripts = true, nil
        end
        return
    end
    local deadline = Budget.limit(1)
    for i = 1, 50 do
        if A.cursor >= A.scripts:size() or getTimestampMs() >= deadline then break end
        local script = A.scripts:get(A.cursor)
        A.cursor = A.cursor + 1
        if script:isRanged() then
            local fullType = script:getFullName()
            A.pending = {event = "firearm-audit-item", fields = {item = fullType, accepted = false, reason = "inspection-interrupted"}}
            A.pending.fields = A.inspect(fullType)
            return
        end
    end
    if A.cursor >= A.scripts:size() then
        A.pending = {event = "firearm-audit-complete", fields = {accepted = A.accepted, rejected = A.rejected}}
    end
end

Budget.register("firearm-audit", A.tick)
Events.OnGameStart.Add(A.start)
return A
