if isClient() then return end
local S = {active = {}, count = 0, due = 0, serial = 0}

local function send(viewer, player, active)
    S.serial = S.serial + 1
    sendServerCommand(viewer, "OMHTT_PackView", "Opening", {
        player = player:getOnlineID(), active = active, serial = S.serial,
    })
end

---@param action OMHTTTurretPackAction Native authoritative action
---@return nil
function S.stop(action)
    local entry = S.active[action.character]
    if not entry or entry.action ~= action then return end
    local online = getOnlinePlayers()
    for viewer in pairs(entry.viewers) do
        if online:contains(viewer) then send(viewer, action.character, false) end
    end
    S.active[action.character] = nil
    S.count = S.count - 1
end

---@return nil
function S.tick()
    if not isServer() or S.count == 0 or getTimestampMs() < S.due then return end
    local now = getTimestampMs()
    S.due = now + 250
    local online = getOnlinePlayers()
    for player, entry in pairs(S.active) do
        if not online:contains(player) or player:isDead() or not entry.action:isValid() then
            S.stop(entry.action)
        else
            local nearby = {}
            for i = 0, online:size() - 1 do
                local viewer = online:get(i)
                local dx, dy = player:getX() - viewer:getX(), player:getY() - viewer:getY()
                if not player:isInvisible() and viewer ~= player and not viewer:isDead() and math.floor(viewer:getZ()) == math.floor(player:getZ())
                    and dx * dx + dy * dy <= 64 then
                    nearby[viewer] = true
                    if not entry.viewers[viewer] or now >= entry.refresh then
                        send(viewer, player, true)
                    end
                end
            end
            for viewer in pairs(entry.viewers) do
                if not nearby[viewer] and online:contains(viewer) then
                    send(viewer, player, false)
                end
            end
            entry.viewers = nearby
            if now >= entry.refresh then
                entry.refresh = now + 1000
            end
        end
    end
end

---@param action OMHTTTurretPackAction Native authoritative action
---@return nil
function S.start(action)
    if not isServer() or not action:isValid() then return end
    local previous = S.active[action.character]
    if previous then
        S.stop(previous.action)
    end
    S.count = S.count + 1
    S.active[action.character] = {action = action, viewers = {}, refresh = 0}
    S.due = 0
    S.tick()
end

Events.OnTick.Add(S.tick)
return S
