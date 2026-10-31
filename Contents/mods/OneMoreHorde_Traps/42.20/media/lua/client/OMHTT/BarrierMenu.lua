if isServer() then return end
require("OMHTT/BarrierServiceAction")
require("OMHTT/BarrierApproachAction")
require("TimedActions/ISTimedActionQueue")
local F = require("OMHTT/Foundation")
local Diagnostics = require("OMHTT/Diagnostics")
local Vault = require("OMHTT/BarrierVault")
local Approach = require("OMHTT/BarrierApproach")
local Selection = require("OMHTT/BarrierSelection")

---@param object IsoThumpable Selected part
---@param player IsoPlayer Acting player
---@param id string Expected device identity
---@param operation string Pickup or Repair
---@return nil
local function queueService(object, player, id, operation)
    local Footprint = require(isClient() and "OMHTT/BarrierView" or "OMHTT/BarrierFootprint")
    local record = Footprint.exact(object)
    if not record or record.id ~= id then return end
    local route = Approach.route(player, record)
    Diagnostics.emit("barrier-approach", {id = id, action = operation, x = player:getX(), y = player:getY(),
        steps = route and #route or -1, targetX = route and #route > 0 and route[#route]:getX(),
        targetY = route and #route > 0 and route[#route]:getY()}, nil, nil, "traps")
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
    local Footprint = require(isClient() and "OMHTT/BarrierView" or "OMHTT/BarrierFootprint")
    local z = math.floor(player:getZ())
    local x = IsoUtils.XToIso(getMouseXScaled(), getMouseYScaled(), z)
    local y = IsoUtils.YToIso(getMouseXScaled(), getMouseYScaled(), z)
    local entries = Selection.collect(player, worldobjects, x, y)
    Diagnostics.emit("barrier-selection", {x = x, y = y, z = z, picked = #worldobjects, candidates = #entries,
        result = #entries == 0 and "miss" or "found"}, nil, nil, "traps")
    for i = 1, #entries do
        local entry = entries[i]
        local record, object, parts = entry.record, entry.object, entry.parts
        local ready = isClient()
        if not isClient() then
            local slot = Footprint.slot(object:getSquare(), record.id)
            ready = slot and Footprint.sync(slot, "menu")
        end
        if ready then
            local headings = {"E", "N", "W", "S"}
            local title = "ContextMenu_OMHTT_BarrierFacing"
            if record.tier == "reinforced" then
                title = "ContextMenu_OMHTT_ReinforcedFacing"
            end
            local name = getText(title, headings[record.facing / 4 + 1])
            if record.name or record.displayNumber then
                name = require("OMHTT/DefenseNames").label(record, name)
            elseif #entries > 1 then
                name = getText("ContextMenu_OMHTT_BarrierChoice", name, i)
            end
            local option = context:addOption(name, nil, nil)
            Selection.bindHighlight(option, parts)
            local menu = ISContextMenu:getNew(context)
            context:addSubMenu(option, menu)
            local condition = menu:addOption(getText("ContextMenu_OMHTT_BarrierCondition", record.condition, record.maxHealth), nil, nil)
            condition.notAvailable = true
            Selection.bindHighlight(condition, parts)
            local pickup = menu:addOption(getText("ContextMenu_OMHTT_PickupBarrier"), object, queueService, player, record.id, "Pickup")
            local repair = menu:addOption(getText("ContextMenu_OMHTT_RepairBarrier"), object, queueService, player, record.id, "Repair")
            require("OMHTT/ControlRepairTooltip").bind(repair, "Barrier", player)
            pickup.toolTip = ISWorldObjectContextMenu.addToolTip()
            pickup.toolTip.description = getText("UI_OMHTT_TrapPickupDuration")
            Selection.bindHighlight(pickup, parts)
            Selection.bindHighlight(repair, parts)
            repair.notAvailable = record.condition >= record.maxHealth or not require("OMHTT/ControlRepair").ready(player, "Barrier")
            if record.tier ~= "reinforced" then
                local upgrade = menu:addOption(getText("ContextMenu_OMHTT_Reinforce"), object, queueService, player, record.id, "Reinforce")
                Selection.bindHighlight(upgrade, parts)
                upgrade.notAvailable = require("OMHTT/DefenseMaterials").reinforcement(player) == nil
                upgrade.toolTip = ISWorldObjectContextMenu.addToolTip()
                upgrade.toolTip.description = getText("UI_OMHTT_ReinforceRequirements")
            end
            local plan, reason
            plan, reason = Vault.plan(player, object, record.id)
            local label = reason
            if plan then
                label = "ContextMenu_OMHTT_VaultRear"
                if plan.side == "front" then
                    label = "ContextMenu_OMHTT_VaultFront"
                end
            end
            local vault = menu:addOption(getText(label), object, Vault.queue, player, record.id)
            vault.notAvailable = plan == nil
            Selection.bindHighlight(vault, parts)
            Diagnostics.emit("barrier-menu", {id = record.id, condition = record.condition, max = record.maxHealth,
                source = entry.source, choice = i, collisionModel = record.collisionModel, vault = plan and plan.side or reason,
                playerX = player:getX(), playerY = player:getY(), playerZ = player:getZ()}, nil, nil, "traps")
        end
    end
end

Events.OnFillWorldObjectContextMenu.Add(fillMenu)
