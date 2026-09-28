if isClient() or isServer() then return end
require("OMHTT/BarrierServiceAction")
require("OMHTT/BarrierApproachAction")
require("TimedActions/ISTimedActionQueue")
local F = require("OMHTT/Foundation")
local Diagnostics = require("OMHTT/Diagnostics")
local Vault = require("OMHTT/BarrierVault")
local Approach = require("OMHTT/BarrierApproach")

---@param object IsoThumpable Selected part
---@param player IsoPlayer Acting player
---@param id string Expected device identity
---@param operation string Pickup or Repair
---@return nil
local function queueService(object, player, id, operation)
    local Footprint = require("OMHTT/BarrierFootprint")
    local record = Footprint.exact(object)
    if not record or record.id ~= id then return end
    local route = Approach.route(player, record)
    Diagnostics.emit("barrier-approach", {id = id, action = operation, x = player:getX(), y = player:getY(),
        steps = route and #route or -1, targetX = route and #route > 0 and route[#route]:getX(),
        targetY = route and #route > 0 and route[#route]:getY()})
    if not route then
        player:setHaloNote(getText("UI_OMHTT_ServiceBlocked"), 255, 170, 80, 180)
        return
    end
    ISTimedActionQueue.clear(player)
    if #route == 0 then
        ISTimedActionQueue.add(OMHTTBarrierServiceAction:new(player, object, id, operation))
    else
        ISTimedActionQueue.add(OMHTTBarrierApproachAction:new(player, object, id, operation, route))
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
        local clicked = worldobjects[i]
        local square = clicked:getSquare()
        local marker = clicked:hasModData() and (clicked:getModData().OMHTT or clicked:getModData().OMHTTEdge)
        local id = marker and marker.id
        if square and not seen[id or square] then
            seen[id or square] = true
            local slot = Footprint.slot(square, id)
            if slot and slot.device and slot.device.placementSource == "construction" then
                local record = slot.device
                seen[record.id] = true
                local object = F.find(square, record.id)
                if not object and Footprint.exact(clicked) then
                    object = clicked
                end
                if object and Footprint.parts(record) then
                    if not Footprint.sync(slot, "menu") then return end
                    local headings = {"E", "N", "W", "S"}
                    local title = "ContextMenu_OMHTT_BarrierFacing"
                    if record.tier == "reinforced" then
                        title = "ContextMenu_OMHTT_ReinforcedFacing"
                    end
                    local option = context:addOption(getText(title, headings[record.facing / 4 + 1]), nil, nil)
                    local menu = ISContextMenu:getNew(context)
                    context:addSubMenu(option, menu)
                    local condition = menu:addOption(getText("ContextMenu_OMHTT_BarrierCondition", record.condition, record.maxHealth), nil, nil)
                    condition.notAvailable = true
                    local pickup = menu:addOption(getText("ContextMenu_OMHTT_PickupBarrier"), object, queueService, player, record.id, "Pickup")
                    local repair = menu:addOption(getText("ContextMenu_OMHTT_RepairBarrier"), object, queueService, player, record.id, "Repair")
                    local tooltip = ISWorldObjectContextMenu.addToolTip()
                    tooltip.description = getText("UI_OMHTT_ServiceDuration")
                    pickup.toolTip, repair.toolTip = tooltip, tooltip
                    repair.notAvailable = record.condition >= record.maxHealth
                    if record.tier ~= "reinforced" then
                        local Service = require("OMHTT/BarrierService")
                        local upgrade = menu:addOption(getText("ContextMenu_OMHTT_Reinforce"), object, queueService, player, record.id, "Reinforce")
                        upgrade.notAvailable = Service.reinforcementMaterials(player, record) == nil
                        upgrade.toolTip = ISWorldObjectContextMenu.addToolTip()
                        upgrade.toolTip.description = getText("UI_OMHTT_ReinforceRequirements")
                    end
                    local plan, reason = Vault.plan(player, object, record.id)
                    local label = reason
                    if plan then
                        label = "ContextMenu_OMHTT_VaultRear"
                        if plan.side == "front" then
                            label = "ContextMenu_OMHTT_VaultFront"
                        end
                    end
                    local vault = menu:addOption(getText(label), object, Vault.queue, player, record.id)
                    vault.notAvailable = plan == nil
                    Diagnostics.emit("barrier-menu", {id = record.id, condition = record.condition, max = record.maxHealth,
                        collisionModel = record.collisionModel, vault = plan and plan.side or reason,
                        playerX = player:getX(), playerY = player:getY(), playerZ = player:getZ()})
                end
            end
        end
    end
end

Events.OnFillWorldObjectContextMenu.Add(fillMenu)
