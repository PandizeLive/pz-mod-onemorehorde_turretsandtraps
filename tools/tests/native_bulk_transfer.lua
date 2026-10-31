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
    local bombBase = player:getInventory():AddItem(T.BASE)
    local bombsStorage = bombBase:getInventory()
    T.configure(bombsStorage)
    bombsStorage:AddItem("Base.OMHTTTurretLobber")
    bombsStorage:AddItem(T.TYPES.CapacityLarge)
    local bombObject = {getContainer=function() return bombsStorage end,hasModData=function() return true end,
        getModData=function() return {OMHTTTurret={schema=1,id="native-bomb-bulk"}} end}
    local bombs={}
    for i=1,41 do bombs[i]=player:getInventory():AddItem("Base.OMHTTAmmoMakeshiftBomb") end
    actions={}
    assert(X.queue(player,bombObject,bombs,true,"ammo")==41 and #actions==3,"Native bomb Manage batching failed")
    assert(actions[1].maxTime<=10 and #actions[1].queueList[1].items==20,"Native bomb loading duration/group mismatch")
    local nativeActions={}
    for i=1,41 do nativeActions[i]=ISInventoryTransferAction:new(player,bombs[i],player:getInventory(),bombsStorage) end
    ISTimedActionQueue.getTimedActionQueue=function() return {queue=nativeActions,indexOf=function() return 1 end} end
    nativeActions[1]:checkQueueList()
    assert(#nativeActions==22 and #nativeActions[1].queueList==1 and #nativeActions[1].queueList[1].items==20,
        "Native inventory drag must combine only twenty full-weight bombs")
    assert(bombs[1]:getActualWeight()==1 and bombs[41]:getContainer()==player:getInventory(),"Preparing bomb batches changed inventory")
    print("[OMHTT-Smoke] native-bomb-transfer prepared=41 groups=3 dragBatch=20 fullWeight=1 duration="..tostring(actions[1].maxTime))
    ISTimedActionQueue.add, ISTimedActionQueue.getTimedActionQueue, W.near = oldAdd, oldQueue, oldNear
    print("[OMHTT-Smoke] native-bulk-transfer rounds=600 groups=30 exact=true prepareMs=" .. prepared .. " peakBatchMs=" .. peak)
end

return verify
