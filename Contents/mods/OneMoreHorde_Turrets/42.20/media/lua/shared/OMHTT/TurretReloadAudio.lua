local G = require("OMHTT/Firearms")
local D = require("OMHTT/Diagnostics")
local A = {entries = {}}
local mechanisms = {
    Ballista = {start = "AttachRopeTree", finish = "StoreItemSmallWoodenBox"},
    Lobber = {start = "DoubleBarrelShotgunInsertAmmoStart", insert = "DoubleBarrelShotgunInsertAmmo", finish = "DoubleBarrelShotgunInsertAmmoStop"},
    Scrapshot = {start = "DoubleBarrelShotgunInsertAmmo", finish = "DoubleBarrelShotgunInsertAmmoStop"},
}

---@param object IsoObject Turret
---@return nil
function A.stop(object)
    local entry = A.entries[object]
    if not entry then return end
    for i = 1, #entry.handles do
        local sound = entry.handles[i]
        if sound.emitter:isPlaying(sound.handle) then sound.emitter:stopSound(sound.handle) end
    end
    A.entries[object] = nil
end

---@param object IsoObject Turret
---@param entry table Active mechanism
---@param name string? Native or custom sound
---@return nil
function A.play(object, entry, name)
    if require("OMHTT/ActiveTime").paused() then return end
    if not name or name == "" then return end
    if isServer() then
        local square = object:getSquare()
        require("OMHTT/DefenseEffects").emit("Click", {sound = name, x = square:getX() + .5,
            y = square:getY() + .5, z = square:getZ()})
        return
    end
    local logging = D.enabled("turrets")
    local started = logging and getTimestampMs()
    for i = #entry.handles, 1, -1 do
        local sound = entry.handles[i]
        if not sound.emitter:isPlaying(sound.handle) then table.remove(entry.handles, i) end
    end
    if #entry.handles >= 3 then
        local oldest = table.remove(entry.handles, 1)
        oldest.emitter:stopSound(oldest.handle)
    end
    local square = object:getSquare()
    local emitter = getWorld():getFreeEmitter(square:getX() + 0.5, square:getY() + 0.5, square:getZ())
    local handle = emitter:playSound(name)
    local gain = require("OMHTT/ControlOptions").volume()
    if name == "OMHTTPotatoReload" then
        gain = gain * require("OMHTT/TurretStats").option("PotatoPlaybackVolume", 35, 0, 100) / 100
    end
    emitter:setVolume(handle, gain)
    entry.handles[#entry.handles + 1] = {emitter = emitter, handle = handle}
    if logging then
        D.defer("turret-reload-audio", {head = entry.head:getFullType(), phase = entry.phase, sound = name,
            audioMs = getTimestampMs() - started}, "turrets")
    end
end

---@param object IsoObject Powered turret
---@param head InventoryItem Installed head
---@param cycle table? Current mechanical deadlines
---@param status string Mechanical state
---@param stats table Effective timing
---@param now number Milliseconds
---@return nil
function A.update(object, head, cycle, status, stats, now)
    if stats.rotary then
        A.stop(object)
        return
    end
    local phase = "idle"
    if cycle and cycle.reloadReady and cycle.reloadReady > now and stats.reload > 0 then
        phase = "reload"
    elseif cycle and cycle.rackReady and cycle.rackReady > now then
        phase = "rack"
    end
    if status == "Off" or status == "NoPower" or status == "NoHead" or status == "Disabled" or status == "Jammed" or status == "NoMagazine" or status == "Servicing" then
        A.stop(object)
        return
    end
    local entry = A.entries[object]
    if entry and entry.head ~= head then A.stop(object); entry = nil end
    if not entry then
        if phase == "idle" then return end
        entry = {head = head, phase = "idle", handles = {}}
        A.entries[object] = entry
    end
    local gun = G.profile(head)
    local mechanism = mechanisms[stats.headKind]
    if entry.phase ~= phase then
        if entry.phase == "reload" then
            if gun then
                A.play(object, entry, head:getInsertAmmoStopSound())
            end
            if mechanism then
                A.play(object, entry, mechanism.finish)
            end
        end
        entry.phase, entry.nextInsert = phase, nil
        if phase == "reload" then
            if gun then
                A.play(object, entry, head:getInsertAmmoStartSound())
                entry.nextInsert = now + math.min(150, stats.reload / 2)
            elseif mechanism then
                A.play(object, entry, mechanism.start)
                if mechanism.insert then
                    entry.nextInsert = now + stats.reload / 2
                end
            else
                A.play(object, entry, "OMHTTPotatoReload")
            end
        elseif phase == "rack" and gun then
            A.play(object, entry, head:getRackSound())
        end
    end
    if entry.nextInsert and now >= entry.nextInsert and phase == "reload" then
        A.play(object, entry, mechanism and mechanism.insert or head:getInsertAmmoSound())
        entry.nextInsert = nil
        if gun and not head:getMagazineType() then
            entry.nextInsert = now + math.max(100, stats.reload)
        end
    end
    if phase == "idle" then
        local playing = false
        for i = 1, #entry.handles do
            local sound = entry.handles[i]
            if sound.emitter:isPlaying(sound.handle) then playing = true end
        end
        if not playing then A.entries[object] = nil end
    end
end

return A
