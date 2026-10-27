if isClient() then return end
local E = require("OMHTT/TurretProc")
local Clock = require("OMHTT/TurretClock")
local Damage = require("OMHTT/Damage")
local H = require("OMHTT/DefenseHorde")
local Contact = require("OMHTT/BarbContact")
local Motion = require("OMHTT/DefenseMotion")
local S = {}
local requests = setmetatable({}, {__mode = "k"})
local pending = {}
local nextDue = nil
local session = tostring(getTimestampMs())

---@param player IsoPlayer Connected recipient
---@return table state Delivery cooldown and active field identities
local function stateFor(player)
    local state = requests[player]
    if not state then
        state = {due = 0, known = {}}
        requests[player] = state
    end
    return state
end

---@param field table Active field
---@param player IsoPlayer Recipient
---@return boolean nearby Same area margin as late-arrival snapshots
---@nodiscard
local function nearby(field, player)
    return math.abs(field.x - player:getX()) < 100 and math.abs(field.y - player:getY()) < 100
end

---@param field table Private active field
---@return table view Plain relative-time snapshot
function S.view(field)
    local now = Clock.now()
    return {id = field.id, x = field.x, y = field.y, z = field.z, radius = field.radius,
        source = field.source, remaining = math.max(0, field.expires - now), startsIn = math.max(0, field.starts - now)}
end

---@param field table Changed field
---@param removed boolean? Field expired
---@return nil
function S.publish(field, removed)
    if not isServer() then return end
    local players = getOnlinePlayers()
    local payload = nil
    for i = 0, players:size() - 1 do
        local player = players:get(i)
        if removed then
            local state = requests[player]
            if state and state.known[field.id] then
                state.known[field.id] = nil
                if not payload then
                    payload = {id = field.id}
                end
                sendServerCommand(player, "OMHTT_TackView", "Remove", payload)
            end
        elseif not player:isDead() and nearby(field, player) then
            stateFor(player).known[field.id] = true
            if not payload then
                payload = {S.view(field)}
            end
            sendServerCommand(player, "OMHTT_TackView", "Fields", payload)
        end
    end
end

---@param module string Namespace
---@param command string Read-only snapshot request
---@param player IsoPlayer Authenticated sender
---@return nil
function S.command(module, command, player)
    if not isServer() or module ~= "OMHTT_TackView" or command ~= "Request" or player:isDead() then return end
    local state = stateFor(player)
    pending[player] = state
    nextDue = math.min(nextDue or state.due, state.due)
end

---@param player IsoPlayer Connected requester at its latest position
---@param state table Delivery tracking
---@return nil
local function snapshot(player, state)
    state.due = getTimestampMs() + 5000
    local now = Clock.now()
    local fields = {}
    for i = 1, #E.fieldOrder do
        local field = E.fieldOrder[i]
        if nearby(field, player) and field.expires > now then
            state.known[field.id] = true
            fields[#fields + 1] = S.view(field)
            if #fields == 32 then
                sendServerCommand(player, "OMHTT_TackView", "Fields", fields)
                fields = {}
            end
        end
    end
    if #fields > 0 then
        sendServerCommand(player, "OMHTT_TackView", "Fields", fields)
    end
end

---@return nil
function S.pump()
    if not isServer() or not nextDue or getTimestampMs() < nextDue then return end
    local selected, state = nil, nil
    for player, request in pairs(pending) do
        if not state or request.due < state.due then
            selected, state = player, request
        end
    end
    if not state then
        nextDue = nil
        return
    end
    nextDue = state.due
    if getTimestampMs() < nextDue then return end
    pending[selected], nextDue = nil, 0
    -- At most one bounded snapshot per tick; disconnected/dead requests retire.
    local players = getOnlinePlayers()
    for i = 0, players:size() - 1 do
        if players:get(i) == selected then
            if not selected:isDead() then
                snapshot(selected, state)
            end
            return
        end
    end
end

---@param zombie IsoZombie Server-updated contact candidate
---@return nil
function S.update(zombie)
    if not isServer() or zombie:isDead() or not H.allowed(zombie) then return end
    local barbs = rawget(_G, "OMHTT_BarbSections")
    if barbs and barbs.contact(zombie) then return end
    local field = E.contact(zombie)
    if not field then return end
    Motion.request(zombie, "slow", field.source, 2)
    local data = require("OMHTT/DefenseActorState").get(zombie)
    if not data.OMHTTBarbContact then data.OMHTTBarbContact = {} end
    local now, identity = Clock.now(), session
    if barbs then now, identity = barbs.time, barbs.session end
    if Contact.step(data.OMHTTBarbContact, now, identity, true, 2000) then
        Damage.resolve(zombie, field.damage / 100, field.source, "tack", function(lost)
            if lost > 0 then
                require("OMHTT/TurretSiphon").hit(zombie, field.siphon, true)
            end
        end)
    end
end

Events.OnClientCommand.Add(S.command)
Events.OnTick.Add(S.pump)
Events.OnZombieUpdate.Add(S.update)
return S
