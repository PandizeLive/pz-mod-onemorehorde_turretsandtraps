if isServer() then
    return
end
require("OMHTT/BedServiceAction")
require("TimedActions/ISTimedActionQueue")
local B = require("OMHTT/BedSpikes")
local F = require("OMHTT/Foundation")
local Highlight = require("OMHTT/WorldHighlight")

---@param object IsoObject Selected part
---@param player IsoPlayer Acting player
---@param id string Expected identity
---@param operation string Service operation
---@return nil
local function queue(object, player, id, operation)
    if not B.record(object) or B.record(object).id ~= id then
        return
    end
    if luautils.walkAdj(player, object:getSquare()) then
        ISTimedActionQueue.add(OMHTTBedServiceAction:new(player, object, id, operation))
    end
end

---@param playerIndex number Viewport
---@param context ISContextMenu Native menu
---@param objects table Picked objects
---@param test boolean Native test call
---@return nil
local function menu(playerIndex, context, objects, test)
    if test or not B.enabled() then
        return
    end
    local player = getSpecificPlayer(playerIndex)
    if not player or player:isDead() then
        return
    end
    local z = math.floor(player:getZ())
    local x = math.floor(IsoUtils.XToIso(getMouseXScaled(), getMouseYScaled(), z))
    local y = math.floor(IsoUtils.YToIso(getMouseXScaled(), getMouseYScaled(), z))
    local record = B.store and B.store.records[B.tiles[F.key(x, y, z)]]
    for i = 1, #objects do
        if B.record(objects[i]) then
            record = B.record(objects[i])
            break
        end
    end
    if not record then
        return
    end
    local parts = B.parts(record)
    if #parts ~= 1 then
        return
    end
    local title = record.tier == "reinforced" and "UI_OMHTT_ReinforcedBedSpikes" or "UI_OMHTT_BedSpikes"
    local option = context:addOption(getText(title), nil, nil)
    option.onHighlight, option.onHighlightParams = Highlight.highlight, {parts}
    local submenu = ISContextMenu:getNew(context)
    context:addSubMenu(option, submenu)
    submenu:addOption(getText("ContextMenu_OMHTT_BarrierCondition", record.health, record.maxHealth), nil, nil).notAvailable = true
    submenu:addOption(getText("ContextMenu_OMHTT_PickupBarrier"), parts[1], queue, player, record.id, "Pickup")
    submenu:addOption(getText("ContextMenu_OMHTT_RepairBarrier"), parts[1], queue, player, record.id, "Repair").notAvailable = record.health >= record.maxHealth
    if record.tier ~= "reinforced" then
        local upgrade = submenu:addOption(getText("ContextMenu_OMHTT_Reinforce"), parts[1], queue, player, record.id, "Reinforce")
        upgrade.notAvailable = require("OMHTT/BedService").materials(player, record) == nil
        upgrade.toolTip = ISWorldObjectContextMenu.addToolTip()
        upgrade.toolTip.description = getText("UI_OMHTT_BedReinforceRequirements")
    end
    for i = 1, submenu.numOptions - 1 do
        local entry = submenu.options[i]
        entry.onHighlight, entry.onHighlightParams = Highlight.highlight, {parts}
    end
end

Events.OnFillWorldObjectContextMenu.Add(menu)
