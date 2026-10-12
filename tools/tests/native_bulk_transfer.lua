---@param player IsoPlayer Native probe operator
---@return nil
local function verify(player)
    ISInventoryPage = ISInventoryPage or {}
    local T = require("OMHTT/Turret")
    local W = require("OMHTT/TurretWorld")
    local X = require("OMHTT/TurretTransfers")
    local packed = player:getInventory():AddItem(T.BASE)
    local destination = packed:getInventory()
    T.configure(destination)
    destination:AddItem("Base.Pistol")
    destination:AddItem(T.TYPES.CapacityLarge)
    local items = {}
    for i = 1, 600 do items[i] = player:getInventory():AddItem("Base.Bullets9mm") end
    local fakeBase = {getContainer = function() return destination end,
        hasModData = function() return true end,
        getModData = function() return {OMHTTTurret = {schema = 1, id = "native-bulk"}} end}
    local oldAdd, oldQueue, oldNear = ISTimedActionQueue.add, ISTimedActionQueue.getTimedActionQueue, W.near
    local actions = {}
    ISTimedActionQueue.add = function(action) actions[#actions + 1] = action end
    ISTimedActionQueue.getTimedActionQueue = function() return {queue = actions} end
    W.near = function() return true end
    local started = getTimestampMs()
    local queued, reason = X.queue(player, fakeBase, items, true, "ammo")
    local prepared = getTimestampMs() - started
    assert(queued == 600 and #actions == 30, "Native Manage did not prepare thirty groups: " .. queued .. "/" .. #actions .. "/" .. tostring(reason))
    local peak, transferred = 0, 0
    for i = 1, #actions do
        started = getTimestampMs()
        T.transferSnapshots = {}
        local action = actions[i]
        for j = 1, #action.queueList[1].items do
            local item = action.queueList[1].items[j]
            action:transferItem(item)
            assert(item:getContainer() == destination, "Native transfer lost ownership")
            transferred = transferred + 1
            assert(T.transferContents(destination).ammo == transferred, "Native batch summary lost ammo")
        end
        T.transferSnapshots = nil
        peak = math.max(peak, getTimestampMs() - started)
        assert(T.contents(destination).ammo == transferred, "Native fresh contents disagree with batch accounting")
    end
    assert(T.contents(destination).ammo == 600, "Native bulk total mismatch")
    ISTimedActionQueue.add, ISTimedActionQueue.getTimedActionQueue, W.near = oldAdd, oldQueue, oldNear
    print("[OMHTT-Smoke] native-bulk-transfer rounds=600 groups=30 exact=true prepareMs=" .. prepared .. " peakBatchMs=" .. peak)
end

return verify
