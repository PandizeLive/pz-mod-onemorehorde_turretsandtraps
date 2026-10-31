if isServer() then return end
require("TimedActions/ISTimedActionQueue")
require("ISUI/ISInventoryPaneContextMenu")
local P = require("OMHTT/TurretModulePack")
local T = require("OMHTT/Turret")
local A = require("OMHTT/TurretPackTimedAction")
local seen, order = {}, {}

---@param player IsoPlayer Recipient
---@param rewards string[] Server-selected full item types
---@return nil
function A.present(player, rewards)
    if require("OMHTT/ClientOptions").packAnimation() then
        require("OMHTT/TurretPackReveal").show(player, rewards)
    else
        player:setHaloNote(getText("UI_OMHTT_PackReceived", P.COUNT), 255, 255, 255, 120)
    end
end

---@param module string Command namespace
---@param command string Command name
---@param args table Server result; presentation only
---@return nil
local function result(module, command, args)
    if module ~= "OMHTT" or command ~= "PackOpened" or type(args) ~= "table" then return end
    if type(args.packId) ~= "number" or type(args.playerId) ~= "number" or type(args.rewards) ~= "table"
        or #args.rewards ~= P.COUNT then return end
    for i = 1, P.COUNT do
        if type(args.rewards[i]) ~= "string" or not T.component(args.rewards[i]) then return end
    end
    local key = tostring(args.playerId) .. ":" .. tostring(args.packId)
    if seen[key] then return end
    for i = 0, getNumActivePlayers() - 1 do
        local player = getSpecificPlayer(i)
        if player and player:getOnlineID() == args.playerId then
            seen[key] = true
            order[#order + 1] = key
            if #order > 64 then
                seen[table.remove(order, 1)] = nil
            end
            A.present(player, args.rewards)
            return
        end
    end
end

Events.OnServerCommand.Add(result)

---@param pack InventoryItem Exact selected pack
---@param player IsoPlayer Operator
---@return nil
local function open(pack, player)
    ISInventoryPaneContextMenu.transferIfNeeded(player, pack)
    ISTimedActionQueue.add(A:new(player, pack))
end

---@param index number Player index
---@param context ISContextMenu Inventory context menu
---@param items table Selected item stacks
---@return nil
local function menu(index, context, items)
    if not T.enabled() then return end
    local player = getSpecificPlayer(index)
    if not player or player:isDead() then return end
    for i = 1, #items do
        local item = items[i]
        if not instanceof(item, "InventoryItem") then
            item = item.items[1]
        end
        if item and item:getFullType() == P.TYPE then
            context:addOption(getText("UI_OMHTT_OpenModulePack"), item, open, player)
            return
        end
    end
end

Events.OnFillInventoryObjectContextMenu.Add(menu)
return A
