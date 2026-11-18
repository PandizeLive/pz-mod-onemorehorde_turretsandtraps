if isClient() then return end
local C = require("OMHTTTether/Core")
local W = require("OMHTTTether/World")
local A = {devices = {}, serial = 0, session = tostring(getTimestampMs())}
local lastTick = nil
local requests = setmetatable({}, {__mode = "k"})

---@param state table Cycle
---@return nil
local function publish(state)
    A.serial = A.serial + 1
    local message = C.snapshot(state, state.id, A.serial, A.session)
    if isServer() then
        sendServerCommand("OMHTTTether", "State", message)
    else
        require("OMHTTTether/View").receive("OMHTTTether", "State", message)
    end
    state.sentAt = getTimestampMs()
end

---@param state table Cycle
---@param victim IsoZombie? Actor
---@param reason string Collision classification
---@return nil
local function impact(state, victim, reason)
    print("[OMHTT-Tether] impact device=" .. state.id .. " sequence=" .. state.sequence .. " reason=" .. tostring(reason))
end

---@param module string Command namespace
---@param command string Action
---@param player IsoPlayer Sender
---@param args table Payload
---@return nil
function A.command(module, command, player, args)
    if module ~= "OMHTTTether" or not player or player:isDead() then return end
    if isServer() then
        if string.lower(player:getAccessLevel()) ~= "admin" then return end
    elseif not getDebug() then
        return
    end
    local wall = getTimestampMs()
    if requests[player] and wall - requests[player] < 150 then return end
    requests[player] = wall
    if type(args) ~= "table" then return end
    local owner = player:getUsername()
    if command == "Place" then
        if not C.finite(args.x) or not C.finite(args.y) or not C.finite(args.z) then return end
        if args.x ~= math.floor(args.x) or args.y ~= math.floor(args.y) or args.z ~= math.floor(args.z)
            or args.z ~= math.floor(player:getZ()) then return end
        if (args.x + .5 - player:getX()) ^ 2 + (args.y + .5 - player:getY()) ^ 2 > 16 then return end
        local square = getCell():getGridSquare(args.x, args.y, args.z)
        if not square or square:isSolid() or square:isSolidTrans() then return end
        local id = nil
        for i = 1, 8 do
            if not A.devices[i] then
                id = i
                break
            end
        end
        if not id then return end
        local forward = player:getForwardDirection()
        local dx, dy = 0, 0
        if math.abs(forward:getX()) >= math.abs(forward:getY()) then
            dx = forward:getX() >= 0 and 1 or -1
        else
            dy = forward:getY() >= 0 and 1 or -1
        end
        local state = C.new(args.x + .5, args.y + .5, args.z, dx, dy)
        state.owner, state.id, state.expires = owner, id, wall + 60000
        A.devices[id] = state
        publish(state)
        return
    end
    if not C.finite(args.id) or args.id ~= math.floor(args.id) then return end
    local state = A.devices[args.id]
    if not state or state.owner ~= owner then return end
    if (state.x - player:getX()) ^ 2 + (state.y - player:getY()) ^ 2 > 400
        or state.z ~= math.floor(player:getZ()) then return end
    if command == "Input" then
        state.links, state.held = 1, false
        C.start(state, false, true)
    elseif command == "Hold" then
        state.links, state.held = 1, not state.held
    elseif command == "Automatic" then
        state.links, state.held = 0, false
    elseif command == "Clear" then
        C.cancel(state)
        publish(state)
        A.devices[args.id] = nil
        return
    else
        return
    end
    publish(state)
end

---@return nil
function A.tick()
    local now = getTimestampMs()
    local elapsed = lastTick and (now - lastTick) / 1000 or 0
    lastTick = now
    if GameTime.isGamePaused() then return end
    elapsed = elapsed * getGameTime():getMultiplier()
    for i = 1, 8 do
        local state = A.devices[i]
        if state then
            local origin = getCell():getGridSquare(math.floor(state.x), math.floor(state.y), state.z)
            if now >= state.expires or not origin then
                C.cancel(state)
                publish(state)
                A.devices[i] = nil
            else
                local revision = state.revision
                C.step(state, elapsed, W.cast, impact)
                if elapsed <= 2 and state.phase == "idle" and now >= (state.scanAt or 0) then
                    state.scanAt = now + 100
                    local detected = false
                    if state.links == 0 then
                        local _, victim = W.cast(state, 0, state.range)
                        detected = victim ~= nil
                    end
                    C.start(state, detected, false)
                end
                local interval = state.phase == "idle" and 500 or 100
                if revision ~= state.revision or now - (state.sentAt or 0) >= interval then
                    publish(state)
                end
            end
        end
    end
end

Events.OnClientCommand.Add(A.command)
Events.OnTick.Add(A.tick)
Events.OnTickEvenPaused.Add(function()
    if GameTime.isGamePaused() then
        lastTick = getTimestampMs()
    end
end)
return A
