if isServer() then return end
require("ISUI/ISPanel")
local C = require("OMHTTTether/Core")
local V = {states = {}, received = {}, from = {}}
local canvas = nil

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

---@param x number World coordinate
---@param y number World coordinate
---@param z number Height
---@param index number Viewport
---@return number screenX
---@return number screenY
local function screen(x, y, z, index)
    local zoom = getCore():getZoom(index)
    return (IsoUtils.XToScreen(x, y, z, 0) - IsoCamera.getOffX(index)) / zoom + getPlayerScreenLeft(index),
        (IsoUtils.YToScreen(x, y, z, 0) - IsoCamera.getOffY(index)) / zoom + getPlayerScreenTop(index)
end

---@return nil
function V.render()
    local now = getTimestampMs()
    for id = 1, 8 do
        local state = V.states[id]
        if state and now - V.received[id] <= 1000 then
            if not canvas then
                canvas = ISPanel:new(0, 0, getCore():getScreenWidth(), getCore():getScreenHeight())
                canvas:initialise()
                canvas:instantiate()
            end
            for index = 0, getNumActivePlayers() - 1 do
                local player = getSpecificPlayer(index)
                if player and math.floor(player:getZ()) == state.z then
                    local x, y = C.position(state, (now - V.received[id]) / 1000, V.from[id])
                    local ox, oy = screen(state.x, state.y, state.z + .3, index)
                    local origin = getCell():getGridSquare(math.floor(state.x), math.floor(state.y), state.z)
                    if origin and origin:isCanSee(index) then
                        canvas:setStencilRect(getPlayerScreenLeft(index), getPlayerScreenTop(index),
                            getPlayerScreenWidth(index), getPlayerScreenHeight(index))
                        canvas:drawRect(ox - 4, oy - 4, 8, 8, 1, 1, 1, 1)
                        local px, py = ox, oy
                        local visible = true
                        for step = 1, 24 do
                            local t = step / 24
                            local wx, wy = state.x + (x - state.x) * t, state.y + (y - state.y) * t
                            local square = getCell():getGridSquare(math.floor(wx), math.floor(wy), state.z)
                            if not square or not square:isCanSee(index) then
                                visible = false
                                break
                            end
                            local sx, sy = screen(wx, wy, state.z + .3 - math.sin(t * math.pi) * .04, index)
                            canvas:drawLine(nil, px, py, sx, sy, 1, .8, .7, .7, .7)
                            px, py = sx, sy
                        end
                        if visible and state.distance > 0 then
                            local nx, ny = screen(x, y, state.z + .3, index)
                            local tx, ty = screen(x - state.dx * .22, y - state.dy * .22, state.z + .3, index)
                            canvas:drawLine(nil, tx, ty, nx, ny, 2, 1, 1, 1, 1)
                        end
                        canvas:clearStencilRect()
                    end
                end
            end
        end
    end
end

---@param player IsoPlayer Sender
---@param command string Action
---@param args table Payload
---@return nil
local function send(player, command, args)
    if isClient() then
        sendClientCommand(player, "OMHTTTether", command, args)
    else
        require("OMHTTTether/Authority").command("OMHTTTether", command, player, args)
    end
end

---@param index number Player
---@param context ISContextMenu Menu
---@param objects table Clicked objects
---@param test boolean Discovery pass
---@return nil
local function context(index, context, objects, test)
    if test then return end
    local player = getSpecificPlayer(index)
    if not player or (not getDebug() and string.lower(player:getAccessLevel()) ~= "admin") then return end
    local square = nil
    for i = 1, #objects do
        if objects[i] and objects[i]:getSquare() then
            square = objects[i]:getSquare()
            break
        end
    end
    if not square then return end
    context:addOption(getText("UI_OMHTTTether_Place"), player, send, "Place",
        {x = square:getX(), y = square:getY(), z = square:getZ()})
    local nearest, distance = nil, 400
    for id = 1, 8 do
        local state = V.states[id]
        if state and state.z == square:getZ() and getTimestampMs() - V.received[id] < 1000 then
            local d = (state.x - square:getX() - .5) ^ 2 + (state.y - square:getY() - .5) ^ 2
            if d < distance then
                nearest, distance = id, d
            end
        end
    end
    if nearest then
        local actions = {"Input", "Hold", "Automatic", "Clear"}
        for i = 1, #actions do
            context:addOption(getText("UI_OMHTTTether_" .. actions[i]), player, send, actions[i], {id = nearest})
        end
    end
end

Events.OnServerCommand.Add(V.receive)
Events.OnPreUIDraw.Add(V.render)
Events.OnFillWorldObjectContextMenu.Add(context)
Events.OnGameStart.Add(function() V.states, V.received, V.from, canvas = {}, {}, {}, nil end)
return V
