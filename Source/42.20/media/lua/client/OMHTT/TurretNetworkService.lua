if isServer() then return end
local T = require("OMHTT/Turret")
require("OMHTT/TurretPickupAction")
require("TimedActions/ISTimedActionQueue")
require("ISUI/ISContextMenu")
require("ISUI/ISWorldObjectContextMenu")
local N = {}
local Range = require("OMHTT/TurretRange")

---@param object IsoObject Selected turret
---@param player IsoPlayer Operator
---@return nil
function N.fire(object, player)
    require("OMHTT/TurretNetworkView").control(player, object, "Fire", true)
end

---@param object IsoThumpable Selected turret
---@param player IsoPlayer Local operator
---@param operation string Service selection
---@return nil
function N.queue(object, player, operation)
    local state = T.state(object)
    if not state or not luautils.walkAdjObject(player, object, false) then return end
    ISTimedActionQueue.add(OMHTTTurretPickupAction:new(player, object, operation, state.id))
end

---@param index number Local player index
---@param context ISContextMenu Native menu
---@param objects table Picked native objects
---@param test boolean Probe only
---@return nil
function N.menu(index, context, objects, test)
    if not isClient() or test or not T.enabled() then return end
    local player = getSpecificPlayer(index)
    if not player or player:isDead() then return end
    local seen = {}
    for i = 1, #objects do
        local object = objects[i]
        if not seen[object] and T.state(object) and object:getObjectIndex() >= 0 and object:getHealth() > 0 then
            seen[object] = true
            local option = context:addOption(getText("UI_OMHTT_Turret"), nil, nil)
            Range.bind(option, {object})
            local menu = ISContextMenu:getNew(context)
            context:addSubMenu(option, menu)
            local manage = menu:addOption(getText("UI_OMHTT_Manage"), object, require("OMHTT/TurretManage"), player)
            Range.bind(manage, {object})
            local fire = menu:addOption(getText("ContextMenu_OMHTT_TurretFire"), object, N.fire, player)
            Range.bind(fire, {object})
            local pickup = menu:addOption(getText("ContextMenu_OMHTT_PickupTurret"), object, N.queue, player, "Pickup")
            pickup.toolTip = ISWorldObjectContextMenu.addToolTip()
            pickup.toolTip.description = getText("UI_OMHTT_ServiceDuration")
            local repair = menu:addOption(getText("ContextMenu_OMHTT_RepairTurret"), object, N.queue, player, "Repair")
            repair.notAvailable = object:getHealth() >= object:getMaxHealth()
            Range.bind(repair, {object})
            local condition = menu:addOption(getText("ContextMenu_OMHTT_BarrierCondition", object:getHealth(), object:getMaxHealth()), nil, nil)
            condition.notAvailable = true
        end
    end
end

Events.OnFillWorldObjectContextMenu.Add(N.menu)
return N
