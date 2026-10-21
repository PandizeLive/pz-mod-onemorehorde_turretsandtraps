if isClient() then return end
require("OMHTT/TetherDefinition")
local C = require("OMHTT/TetherCycle")
local Lane = require("OMHTT/TetherLane")
local Mount = require("OMHTT/TetherMount")
local Horde = require("OMHTT/DefenseHorde")
local Active = require("OMHTT/ActiveTime")
local S = {entries = setmetatable({}, {__mode = "k"}), clock = Active.new(), time = 0, serial = 0, session = tostring(getTimestampMs())}
local tuning = {range = 6, speed = 12, returnSpeed = 4, resetTime = .4, holdTime = .75}

---@param entry table Active trap
---@return nil
function S.publish(entry)
    S.serial = S.serial + 1
    local message = C.snapshot(entry.cycle, entry.state.id, S.serial, S.session)
    if isServer() then
        local players = getOnlinePlayers()
        for i = 0, players:size() - 1 do
            local player = players:get(i)
            if math.floor(player:getZ()) == message.z
                and (player:getX() - message.x) ^ 2 + (player:getY() - message.y) ^ 2 <= 6400 then
                sendServerCommand(player, "OMHTTTether", "State", message)
            end
        end
    else
        require("OMHTT/TetherView").receive("OMHTTTether", "State", message)
    end
    entry.sent = S.time
end

---@param cycle table Cycle with active entry
---@param victim IsoGameCharacter? First collision
---@param reason string Classification
---@return nil
local function hit(cycle, victim, reason)
    local entry = cycle.entry
    if reason == "zombie" and Horde.allowed(victim) then
        entry.victim = victim
        require("OMHTT/Damage").resolve(victim, .3, entry.state.id, "tether-dart")
    elseif reason == "player" and require("OMHTT/ControlCombat").protected(require("OMHTT/ControlCombat").source(entry.object), victim) then
        require("OMHTT/DefenseInjury").poke(victim, "scratch")
    end
end

---@param cycle table Returning nail
---@return nil
local function pull(cycle)
    local entry = cycle.entry
    local victim = entry.victim
    entry.victim = nil
    if not victim or victim:isDead() or math.floor(victim:getZ()) ~= cycle.z or not Horde.allowed(victim) then return end
    local square = victim:getSquare()
    if not square or getCell():getGridSquare(square:getX(), square:getY(), square:getZ()) ~= square then return end
    require("OMHTT/Damage").resolve(victim, .15, entry.state.id, "tether-pull")
end

---@param object IsoObject Trap
---@param state table Authoritative identity
---@return table? entry
function S.entry(object, state)
    local entry = S.entries[object]
    if entry then return entry end
    local mount, support = Mount.resolve(state.x, state.y, state.z, state.facing)
    if not mount then return nil end
    local cycle = C.new(mount.x, mount.y, mount.z, mount.dx, mount.dy, tuning)
    entry = {cycle = cycle, mount = mount, support = support, object = object, state = state, time = S.time, sent = S.time, scan = S.time}
    cycle.entry = entry
    S.entries[object] = entry
    return entry
end

---@param object IsoObject Trap
---@return nil
function S.cancel(object)
    local entry = S.entries[object]
    if not entry then return end
    C.cancel(entry.cycle)
    S.publish(entry)
    S.entries[object] = nil
end

---@param object IsoObject Trap
---@param state table Authoritative identity
---@param pulse boolean? Fresh button signal
---@return nil
function S.step(object, state, pulse)
    local W = require("OMHTT/ControlWorld")
    if object:getHealth() <= 0 or state.enabled == false or SandboxVars.OMHTurretsTraps.Enabled == false then
        S.cancel(object)
        if state.active then
            state.active = false
            W.publish(object)
        end
        return
    end
    local entry = S.entry(object, state)
    if not entry then return end
    if entry.support:getObjectIndex() < 0 or not Mount.supported(entry.support, entry.mount.north) then
        S.cancel(object)
        state.active = false
        W.publish(object)
        return
    end
    local cycle = entry.cycle
    local elapsed = (S.time - entry.time) / 1000
    entry.time = S.time
    local before, revision = cycle.phase, cycle.revision
    C.step(cycle, elapsed, Lane.cast, hit, pull)
    if before ~= "idle" and cycle.phase == "idle" then
        entry.victim = nil
        object:setHealth(math.max(0, object:getHealth() - 1))
        if isServer() then object:sync() end
    end
    local linked, on = W.input(object, getTimestampMs())
    cycle.links, cycle.held = linked and 1 or 0, on
    if cycle.phase == "idle" and object:getHealth() > 0 and getTimestampMs() >= state.recoverAt then
        local detected = false
        if not linked and S.time >= entry.scan then
            entry.scan = S.time + 200
            local fraction, victim = Lane.cast(cycle, 0, cycle.range)
            detected = fraction ~= nil and require("OMHTT/ControlCombat").eligible(object, victim)
        end
        C.start(cycle, detected, pulse == true)
    end
    local active = cycle.phase ~= "idle"
    if state.active ~= active then
        state.active = active
        W.publish(object)
    end
    if revision ~= cycle.revision or (active and S.time - entry.sent >= 100) then S.publish(entry) end
end

---@return nil
local function advance()
    S.time = S.time + math.min(250, Active.step(S.clock))
end

Events.OnTick.Add(advance)
return S
