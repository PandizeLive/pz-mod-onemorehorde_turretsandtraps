if isServer() then return end
local C = require("OMHTT/TetherCycle")
local Draw = require("OMHTT/ControlModelDraw")
local Clock = require("OMHTT/ControlClock")
local V = {states = {}, received = {}, simulated = {}, from = {}, visuals = {}, latency = {}, endpoints = {}}

---@param state table Accepted cycle snapshot
---@param elapsed number Local simulation seconds since receipt
---@return number x Presentation endpoint
---@return number y Presentation endpoint
function V.position(state, elapsed)
    local age = elapsed + (V.latency[state.id] or 0)
    local x, y = C.position(state, age, V.from[state.id])
    if state.phase == "hold" then
        local target = not isClient() and state.target
        if isClient() and state.targetId then
            if state.targetPlayer then
                target = getPlayerByOnlineID(state.targetId)
            else
                target = require("OMHTT/DefenseCombatClient").find(state.targetId, state.targetOutfit)
            end
        end
        if target and not target:isDead() and math.floor(target:getZ()) == state.z
            and (target:getX() - state.x)^2 + (target:getY() - state.y)^2 <= (state.range + 2)^2 then
            x, y = target:getX(), target:getY()
        elseif state.attachX then
            x, y = state.attachX, state.attachY
        end
        local endpoint = V.endpoints[state.id] or {}
        endpoint.x, endpoint.y = x, y
        V.endpoints[state.id] = endpoint
    elseif state.phase == "back" then
        local endpoint = V.endpoints[state.id]
        local ax, ay = endpoint and endpoint.x or state.attachX, endpoint and endpoint.y or state.attachY
        local initial = state.distance + state.returnSpeed * (state.backTime or 0)
        if ax and initial > .001 then
            local remaining = math.max(0, state.distance - state.returnSpeed * math.min(.75, age))
            local fraction = math.min(1, remaining / initial)
            x, y = state.x + (ax - state.x) * fraction, state.y + (ay - state.y) * fraction
        end
    end
    return x, y
end

---@param module string Namespace
---@param command string Event
---@param message table Snapshot
---@return nil
function V.receive(module, command, message)
    if module ~= "OMHTTTether" or command ~= "State" or type(message) ~= "table" then return end
    if not C.accept(V.states[message.id], message) then return end
    local previous = V.states[message.id]
    local distance = 0
    if previous and previous.session == message.session and previous.sequence == message.sequence then
        local x, y = V.position(previous, (Clock.now() - V.simulated[message.id]) / 1000)
        distance = math.max(0, math.min(message.range, (x - message.x) * message.dx + (y - message.y) * message.dy))
    else
        V.endpoints[message.id] = nil
    end
    local transit = message.sentAt and GameTime.getServerTimeMills() - message.sentAt or 0
    V.latency[message.id] = math.max(0, math.min(250, transit)) / 1000
    V.from[message.id] = distance
    V.states[message.id], V.received[message.id], V.simulated[message.id] = message, getTimestampMs(), Clock.now()
    if not previous or previous.sequence ~= message.sequence or previous.phase ~= message.phase then
        require("OMHTT/Diagnostics").defer("tether-receive", {id=message.id, sequence=message.sequence,
            serial=message.serial, phase=message.phase, transitMs=transit, distance=message.distance}, "traps")
    end
end

---@param index number Native viewport
---@return nil
function V.render(index)
    local player, cell = getSpecificPlayer(index), getCell()
    if not player or not cell then return end
    local now, budget = getTimestampMs(), 192
    for id, state in pairs(V.states) do
        if now - V.received[id] > 2000 then
            V.states[id], V.received[id], V.simulated[id], V.from[id], V.visuals[id] = nil, nil, nil, nil, nil
            V.latency[id], V.endpoints[id] = nil, nil
        elseif state.phase ~= "idle" and state.phase ~= "reset" and now - V.received[id] <= 1000
            and math.floor(player:getZ()) == state.z
            and (player:getX() - state.x) ^ 2 + (player:getY() - state.y) ^ 2 < 2500 then
            local origin = cell:getGridSquare(math.floor(state.x), math.floor(state.y), state.z)
            if origin and origin:isCanSee(index) then
                local visual = V.visuals[id]
                if not visual then
                    visual = {nail = instanceItem("Base.OMHTTTrapTetherNailVisual"), cable = instanceItem("Base.OMHTTTrapTetherCableVisual")}
                    V.visuals[id] = visual
                end
                local x, y = V.position(state, (Clock.now() - V.simulated[id]) / 1000)
                local height = math.max(.025, math.min(.3, state.height or .3))
                local square = cell:getGridSquare(math.floor(x), math.floor(y), state.z)
                local yaw = math.deg(math.atan2(y - state.y, x - state.x))
                if square and square:isCanSee(index) then
                    Draw.draw(visual.nail, square, x, y, state.z + height, 0, 0, yaw)
                    if visual.sequence ~= state.sequence or visual.phase ~= state.phase then
                        visual.sequence, visual.phase = state.sequence, state.phase
                        require("OMHTT/Diagnostics").defer("tether-first-render", {id=id, sequence=state.sequence,
                            serial=state.serial, phase=state.phase, receiptAgeMs=now - V.received[id],
                            transitMs=(V.latency[id] or 0) * 1000}, "traps")
                    end
                end
                local distance = math.sqrt((x - state.x) ^ 2 + (y - state.y) ^ 2)
                local segments = math.min(24, math.max(1, math.ceil(distance / .4)))
                if distance > .01 and budget >= segments then
                    budget = budget - segments
                    for segment = 1, segments do
                        local t = (segment - .5) / segments
                        local wx, wy = state.x + (x - state.x) * t, state.y + (y - state.y) * t
                        local tile = cell:getGridSquare(math.floor(wx), math.floor(wy), state.z)
                        if not tile or not tile:isCanSee(index) then break end
                        local t0, t1 = (segment - 1) / segments, segment / segments
                        local z0 = .3 + (height - .3) * t0 - math.sin(t0 * math.pi) * .025
                        local z1 = .3 + (height - .3) * t1 - math.sin(t1 * math.pi) * .025
                        local horizontal, vertical = distance / segments, (z1 - z0) * 2.44949
                        local length = math.sqrt(horizontal * horizontal + vertical * vertical)
                        visual.cable:setWorldScale(length / 1.5)
                        local tilt = math.deg(math.atan2(vertical, horizontal))
                        Draw.draw(visual.cable, tile, wx, wy, state.z + (z0 + z1) / 2, 0, tilt, yaw)
                    end
                end
            end
        end
    end
end

Events.OnServerCommand.Add(V.receive)
Events.RenderOpaqueObjectsInWorld.Add(V.render)
Events.OnGameStart.Add(function()
    V.states, V.received, V.simulated, V.from, V.visuals, V.latency, V.endpoints = {}, {}, {}, {}, {}, {}, {}
end)
return V
