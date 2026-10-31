if not isClient() then return end
local P = require("OMHTT/DefenseCombatProtocol")
local C = {checks = {}, presentations = {}}
local permits = setmetatable({}, {__mode = "k"})
local states = setmetatable({}, {__mode = "k"})
local queue, serial, first, last = {}, 0, 1, 0

-- Providers inspect already indexed local trap views. No world-wide scan.
function C.update(zombie)
    if require("OMHTT/ActiveTime").paused() then return end
    if not P.living(zombie) or zombie:isRemoteZombie() then states[zombie] = nil; return end
    local player = zombie:getOwnerPlayer()
    if not player or not player:isLocalPlayer() then return end
    for _, present in pairs(C.presentations) do present(zombie, C.permitted(zombie)) end
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
        and old.tileX == math.floor(x) and old.tileY == math.floor(y) and nearby
        and (x-old.x)^2+(y-old.y)^2 < .04 then return end
    if last-first+1 >= 512 then return end -- bounded; next native update retries
    serial = serial + 1
    last = last + 1
    queue[last] = {player=player, at=now, frame={id=zombie:getOnlineID(),
        outfit=P.outfit(zombie:getPersistentOutfitID()), sequence=serial,
        x=x,y=y,z=z,prone=prone,down=down,landing=landing,observedAt=observedAt}}
    states[zombie] = nearby and {due=now+100,x=x,y=y,prone=prone,down=down,landing=landing,
        firstAt=old and old.firstAt or now, ready=old and old.ready,
        tileX=math.floor(x),tileY=math.floor(y)} or nil
end

function C.flush()
    if require("OMHTT/ActiveTime").paused() then queue, first, last = {}, 1, 0; return end
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

---@param zombie IsoZombie Native owner-side actor
---@return boolean permitted Short server consent lease, never damage authority
function C.permitted(zombie)
    local permit = permits[zombie]
    local owner = zombie:getOwnerPlayer()
    local now = GameTime.getServerTimeMills()
    return permit ~= nil and permit.allowed == true and not zombie:isRemoteZombie() and owner ~= nil and owner:isLocalPlayer()
        and owner:getOnlineID() == permit.owner and zombie:getOnlineID() == permit.id
        and P.outfit(zombie:getPersistentOutfitID()) == permit.outfit
        and now > 0 and now <= permit.expires
end

---@param facts table Server consent lease
---@return nil
local function grant(facts)
    if type(facts) ~= "table" or type(facts.allowed) ~= "boolean" or not P.identity(facts.id) or not P.identity(facts.outfit) or not P.identity(facts.owner)
        or not P.number(facts.issuedAt, 1, 1000000000000000)
        or not P.number(facts.expires, facts.issuedAt, facts.issuedAt + 400) then return end
    local now = GameTime.getServerTimeMills()
    if now <= 0 or facts.issuedAt > now+100 or (facts.allowed and now > facts.expires) then return end
    local zombie = require("OMHTT/DefenseCombatClient").find(facts.id, facts.outfit)
    if not zombie then return end
    local previous = permits[zombie]
    if previous and (facts.issuedAt < previous.issuedAt
        or (facts.issuedAt == previous.issuedAt and not previous.allowed)) then return end
    permits[zombie] = facts
    local state = states[zombie]
    if state and facts.allowed and not state.ready then
        state.ready = true
        require("OMHTT/Diagnostics").measure("owner-contact-permission-ready", getTimestampMs()-state.firstAt, "traps")
    end
end

---@param module string Namespace
---@param command string Batched server grants
---@param frames table Up to 32 consent leases
---@return nil
function C.command(module, command, frames)
    if module ~= "OMHTT_ContactV1" or command ~= "Permits" or type(frames) ~= "table" or #frames > 32 then return end
    for i=1,#frames do grant(frames[i]) end
end

---@param zombie IsoZombie Recycled actor
---@return nil
function C.created(zombie) states[zombie], permits[zombie] = nil, nil end
Events.OnServerCommand.Add(C.command)
Events.OnZombieUpdate.Add(C.update)
Events.OnZombieCreate.Add(C.created)
Events.OnZombieDead.Add(C.created)
Events.OnTick.Add(C.flush)
return C
