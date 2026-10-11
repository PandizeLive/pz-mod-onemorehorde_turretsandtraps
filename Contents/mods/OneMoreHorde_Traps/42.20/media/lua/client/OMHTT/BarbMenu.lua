if isClient() or isServer() then return end
require("OMHTT/BarbServiceAction")
require("TimedActions/ISTimedActionQueue")
local B = require("OMHTT/BarbSections")
local S = require("OMHTT/BarbService")
local Highlight = require("OMHTT/WorldHighlight")

---@param object IsoObject Frame
---@param player IsoPlayer Acting player
---@param id string Expected identity
---@param operation string Service action
---@return nil
local function queue(object, player, id, operation)
    local record = B.record(object)
    if not record or record.id ~= id then return end
    local square = S.approach(record)
    if square and luautils.walkAdj(player, square) then
        ISTimedActionQueue.add(OMHTTBarbServiceAction:new(player, object, id, operation))
    end
end

---@param playerIndex number Viewport
---@param context ISContextMenu Native menu
---@param objects table Picked objects
---@param test boolean Native test pass
---@return nil
local function menu(playerIndex, context, objects, test)
    if test or (not B.enabled() and not B.wireEnabled()) then return end
    local player = getSpecificPlayer(playerIndex)
    if not player or player:isDead() then return end
    local seen = {}
    for i = 1, #objects do
        local square = objects[i]:getSquare()
        if square then
            local all = square:getObjects()
            for j = 0, all:size() - 1 do
                local frame = all:get(j)
                local record = B.record(frame)
                if record and not seen[record.id] then
                    seen[record.id] = true
                    local _, host, attachment, status = B.resolve(record)
                    if status == "active" and B.enabled(record.kind) then
                        local option = context:addOption(getText(record.kind == "wire" and "UI_OMHTT_ConcertinaWire" or "UI_OMHTT_Barbs"), nil, nil)
                        option.onHighlight, option.onHighlightParams = Highlight.highlight, {{frame}}
                        local submenu = ISContextMenu:getNew(context)
                        context:addSubMenu(option, submenu)
                        local health = attachment.health
                        if attachment.shared then
                            health = host:getHealth()
                            submenu:addOption(getText("UI_OMHTT_BarbSharedHealth", health), nil, nil).notAvailable = true
                        else
                            submenu:addOption(getText("ContextMenu_OMHTT_BarrierCondition", health, 50), nil, nil).notAvailable = true
                            submenu:addOption(getText("ContextMenu_OMHTT_RepairBarrier"), frame, queue, player, record.id, "Repair").notAvailable = health >= 50 or not S.tools(player, record)
                        end
                        local remove = submenu:addOption(getText(record.kind == "wire" and "ContextMenu_OMHTT_PickupBarrier" or "ContextMenu_OMHTT_RemoveBarbs"), frame, queue, player, record.id, "Remove")
                        remove.notAvailable = not S.tools(player, record)
                        remove.toolTip = ISWorldObjectContextMenu.addToolTip()
                        remove.toolTip.description = getText(record.kind == "wire" and "UI_OMHTT_WireService" or "UI_OMHTT_BarbServiceTools")
                    end
                end
            end
        end
    end
end

Events.OnFillWorldObjectContextMenu.Add(menu)
