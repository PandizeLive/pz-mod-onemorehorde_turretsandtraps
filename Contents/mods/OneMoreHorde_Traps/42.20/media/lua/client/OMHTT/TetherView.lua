if isServer() then return end
local C = require("OMHTT/TetherCycle")
local Draw = require("OMHTT/ControlModelDraw")
local V = {states = {}, received = {}, from = {}, visuals = {}}

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
        local x, y = C.position(previous, (getTimestampMs() - V.received[message.id]) / 1000, V.from[message.id])
        distance = math.max(0, math.min(message.range, (x - message.x) * message.dx + (y - message.y) * message.dy))
    end
    V.from[message.id] = distance
    V.states[message.id], V.received[message.id] = message, getTimestampMs()
end

---@param index number Native viewport
---@return nil
function V.render(index)
    local player, cell = getSpecificPlayer(index), getCell()
    if not player or not cell then return end
    local now, budget = getTimestampMs(), 192
    for id, state in pairs(V.states) do
        if now - V.received[id] > 2000 then
            V.states[id], V.received[id], V.from[id], V.visuals[id] = nil, nil, nil, nil
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
                local x, y = C.position(state, (now - V.received[id]) / 1000, V.from[id])
                local height = math.max(.025, math.min(.3, state.height or .3))
                local square = cell:getGridSquare(math.floor(x), math.floor(y), state.z)
                local yaw = math.deg(math.atan2(state.dy, state.dx))
                if square and square:isCanSee(index) then
                    Draw.draw(visual.nail, square, x, y, state.z + height + .72 / 2.44949, 0, 0, yaw)
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
                        Draw.draw(visual.cable, tile, wx, wy, state.z + (z0 + z1) / 2 + .72 / 2.44949, 0, tilt, yaw)
                    end
                end
            end
        end
    end
end

Events.OnServerCommand.Add(V.receive)
Events.RenderOpaqueObjectsInWorld.Add(V.render)
Events.OnGameStart.Add(function() V.states, V.received, V.from, V.visuals = {}, {}, {}, {} end)
return V
