if isClient() or isServer() then return end
local F = require("OMHTT/Foundation")
local H = require("OMHTT/HybridProbe")
local D = require("OMHTT/Diagnostics")
local spinning = {}
local lastTick = 0

---@param square IsoGridSquare Target
---@param player IsoPlayer Operator
---@param operation string Action
---@return nil
local function action(square, player, operation)
    if not H.allowed(player, square) then return end
    if operation == "Create" then
        H.create(player, square)
        return
    end
    local base, head = H.find(square)
    if not base then return end
    if operation == "Remove" then
        spinning[base:getModData().OMHTTHybridProbe] = nil
        H.remove(player, square)
        return
    end
    if not head then return end
    local item = head:getItem()
    local id = base:getModData().OMHTTHybridProbe
    if operation == "Rotate" then
        H.rotate(head, item:getWorldZRotation() + 45)
    elseif operation == "Spin" then
        if spinning[id] then
            spinning[id] = nil
        else
            local count = 0
            for _ in pairs(spinning) do
                count = count + 1
            end
            if count >= 8 then return end
            spinning[id] = {head = head, square = square, player = player, lastLog = 0}
        end
    elseif operation == "Raise" or operation == "Lower" then
        local delta = operation == "Raise" and 0.1 or -0.1
        local height = math.max(0, math.min(0.9, head:getWorldPosZ() - square:getZ() + delta))
        head:setOffset(0.5, 0.5, height)
    elseif operation == "Larger" or operation == "Smaller" then
        local factor = operation == "Larger" and 1.25 or 0.8
        local scale = math.max(0.1, math.min(4, (item:getModData().OMHTTProbeScale or 1) * factor))
        item:setWorldScale(scale)
        item:getModData().OMHTTProbeScale = scale
    end
    head:invalidateRenderChunkLevel(FBORenderChunk.DIRTY_REDRAW)
    D.emit("hybrid-probe-action", {id = id, action = operation, yaw = item:getWorldZRotation(),
        height = head:getWorldPosZ() - square:getZ(), scale = item:getModData().OMHTTProbeScale or 1,
        ground3D = getCore():isOption3DGroundItem(), spin = spinning[id] ~= nil})
end

---@return nil
local function tick()
    local now = getTimestampMs()
    if now - lastTick < 100 then return end
    local elapsed = math.min(250, math.max(0, now - lastTick))
    lastTick = now
    for id, entry in pairs(spinning) do
        local base, head = H.find(entry.square)
        if not H.allowed(entry.player, entry.square) or not base or head ~= entry.head then
            spinning[id] = nil
        else
            H.rotate(head, head:getItem():getWorldZRotation() + elapsed * 0.036)
            if now - entry.lastLog >= 3000 then
                entry.lastLog = now
                D.emit("hybrid-probe-spin", {id = id, yaw = head:getItem():getWorldZRotation(),
                    ground3D = getCore():isOption3DGroundItem(), headWorldIndex = head:getWorldObjectIndex()})
            end
        end
    end
end

---@param playerIndex number Local player
---@param context ISContextMenu Context
---@param objects table Picked objects
---@param test boolean Probe call
---@return nil
local function menu(playerIndex, context, objects, test)
    local player = getSpecificPlayer(playerIndex)
    if test or not F.canUse(player) then return end
    local x = math.floor(IsoUtils.XToIso(getMouseXScaled(), getMouseYScaled(), math.floor(player:getZ())))
    local y = math.floor(IsoUtils.YToIso(getMouseXScaled(), getMouseYScaled(), math.floor(player:getZ())))
    local square = getCell():getGridSquare(x, y, math.floor(player:getZ()))
    for i = 1, #objects do
        if objects[i]:getModData().OMHTTHybridProbe then
            square = objects[i]:getSquare()
            break
        end
        if instanceof(objects[i], "IsoWorldInventoryObject") and objects[i]:getItem():getModData().OMHTTHybridProbe then
            square = objects[i]:getSquare()
            break
        end
    end
    if not H.allowed(player, square) then return end
    local parent = context:addOption(getText("ContextMenu_OMHTT_HybridProbe"), nil, nil)
    local submenu = ISContextMenu:getNew(context)
    context:addSubMenu(parent, submenu)
    local base, head = H.find(square)
    local actions = base and {"Remove"} or {"Create"}
    if head then
        actions = {"Rotate", "Spin", "Raise", "Lower", "Larger", "Smaller", "Remove"}
    end
    for i = 1, #actions do
        local operation = actions[i]
        submenu:addOption(getText("ContextMenu_OMHTT_Hybrid" .. operation), square, action, player, operation)
    end
end

---@return nil
local function reset()
    spinning = {}
    lastTick = getTimestampMs()
end

Events.OnFillWorldObjectContextMenu.Add(menu)
Events.OnTick.Add(tick)
Events.OnGameStart.Add(reset)
