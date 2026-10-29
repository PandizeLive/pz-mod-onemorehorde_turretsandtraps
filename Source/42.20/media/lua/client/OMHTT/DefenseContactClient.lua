if not isClient() then return end
local P = require("OMHTT/DefenseCombatProtocol")
local C = {checks = {}}
local states = setmetatable({}, {__mode = "k"})
local queue, serial, first, last = {}, 0, 1, 0

-- Providers inspect already indexed local trap views. No world-wide scan.
function C.update(zombie)
    if not P.living(zombie) or zombie:isRemoteZombie() then states[zombie] = nil; return end
    local player = zombie:getOwnerPlayer()
    if not player or not player:isLocalPlayer() then return end
    local nearby = false
    for _, check in pairs(C.checks) do
        if check(zombie) then nearby = true; break end
    end
    local old = states[zombie]
    if not nearby and not old then return end
    local now = getTimestampMs()
    local observedAt = GameTime.getServerTimeMills()
    if observedAt <= 0 then return end
    local x,y,z = zombie:getX(),zombie:getY(),math.floor(zombie:getZ())
    local prone = zombie:isOnFloor()
    local down = prone or zombie:isKnockedDown() or zombie:isRagdoll() or zombie:isGettingUp()
    local landing = zombie:getBumpType()=="OMHTTBedTrip" and zombie:getVariableBoolean("OMHTTBedLanded")
    if old and now < old.due and old.prone == prone and old.down == down and old.landing == landing
        and old.tileX == math.floor(x) and old.tileY == math.floor(y) and nearby then return end
    if last-first+1 >= 512 then return end -- bounded; next native update retries
    serial = serial + 1
    last = last + 1
    queue[last] = {player=player, at=now, frame={id=zombie:getOnlineID(),
        outfit=P.outfit(zombie:getPersistentOutfitID()), sequence=serial,
        x=x,y=y,z=z,prone=prone,down=down,landing=landing,observedAt=observedAt}}
    states[zombie] = nearby and {due=now+100,prone=prone,down=down,landing=landing,tileX=math.floor(x),tileY=math.floor(y)} or nil
end

function C.flush()
    local now = getTimestampMs()
    local batches = {}
    for i=1,math.min(128,last-first+1) do
        local entry=queue[first]
        queue[first],first=nil,first+1
        if now-entry.at<=250 and not entry.player:isDead() then
            local batch=batches[entry.player]
            if not batch then batch={};batches[entry.player]=batch end
            entry.frame.age=now-entry.at
            batch[#batch+1]=entry.frame
            if #batch==32 then
                sendClientCommand(entry.player,"OMHTT_ContactV1","Observe",batch)
                batches[entry.player]=nil
            end
        end
    end
    if first>last then first,last=1,0 end
    for player,batch in pairs(batches) do sendClientCommand(player,"OMHTT_ContactV1","Observe",batch) end
end

function C.created(zombie) states[zombie]=nil end
Events.OnZombieUpdate.Add(C.update)
Events.OnZombieCreate.Add(C.created)
Events.OnZombieDead.Add(C.created)
Events.OnTick.Add(C.flush)
return C
