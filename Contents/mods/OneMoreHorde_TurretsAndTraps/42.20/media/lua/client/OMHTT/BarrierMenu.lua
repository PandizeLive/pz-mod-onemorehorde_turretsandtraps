if isClient() or isServer() then return end
require("OMHTT/BarrierServiceAction")
require("TimedActions/ISTimedActionQueue")
local F = require("OMHTT/Foundation")
local Diagnostics = require("OMHTT/Diagnostics")

---@param object IsoThumpable Selected part
---@param player IsoPlayer Acting player
---@param id string Expected device identity
---@param operation string Pickup or Repair
---@return nil
local function queueService(object, player, id, operation)
    if luautils.walkAdj(player, object:getSquare()) then
        ISTimedActionQueue.add(OMHTTBarrierServiceAction:new(player, object, id, operation))
    end
end

---@param playerIndex number Local player slot
---@param context ISContextMenu Native menu
---@param worldobjects table Clicked objects
---@param test boolean Probe call
---@return nil
local function fillMenu(playerIndex, context, worldobjects, test)
    if test or not F.barrierEnabled() then return end
    local player = getSpecificPlayer(playerIndex)
    if not player or player:isDead() then return end
    -- Server Lua is registered after client Lua in single-player. Resolve at use time.
    local Footprint = require("OMHTT/BarrierFootprint")
    local seen = {}
    for i = 1, #worldobjects do
        local square = worldobjects[i]:getSquare()
        if square and not seen[square] then
            seen[square] = true
            local slot = Footprint.slot(square)
            if slot and slot.device and slot.device.placementSource == "construction" then
                local record = slot.device
                local object = F.find(square, record.id)
                if object and Footprint.parts(record) then
                    if not Footprint.sync(slot, "menu") then return end
                    local option = context:addOption(getText("ContextMenu_OMHTT_Barrier"), nil, nil)
                    local menu = ISContextMenu:getNew(context)
                    context:addSubMenu(option, menu)
                    local condition = menu:addOption(getText("ContextMenu_OMHTT_BarrierCondition", record.condition, record.maxHealth), nil, nil)
                    condition.notAvailable = true
                    menu:addOption(getText("ContextMenu_OMHTT_PickupBarrier"), object, queueService, player, record.id, "Pickup")
                    local repair = menu:addOption(getText("ContextMenu_OMHTT_RepairBarrier"), object, queueService, player, record.id, "Repair")
                    repair.notAvailable = record.condition >= record.maxHealth
                    Diagnostics.emit("barrier-menu", {id = record.id, condition = record.condition, max = record.maxHealth})
                    return
                end
            end
        end
    end
end

Events.OnFillWorldObjectContextMenu.Add(fillMenu)
