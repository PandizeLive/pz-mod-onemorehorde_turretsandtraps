local A = {}
local states = setmetatable({}, {__mode = "k"})

---@param zombie IsoZombie Native zombie
---@return boolean prone Landed or recovering
---@return boolean down Falling, landed or recovering
function A.stance(zombie)
    if isServer() and zombie:getOwner() then
        -- 42.21 does not apply IsOnFloor packets to ordinary server zombies.
        -- These state names come from the owner's native ZombiePacket.realState.
        local state = zombie:getRealState()
        local prone = state == "onground" or state == "getup"
        return prone, prone or state == "falldown" or state == "falling"
    end
    local prone = zombie:isOnFloor()
    return prone, prone or zombie:isKnockedDown() or zombie:isRagdoll() or zombie:isGettingUp()
end

---@param actor IsoGameCharacter Native actor
---@return table state Private MP transient combat guards; ordinary modData in SP
function A.get(actor)
    if not isServer() then return actor:getModData() end
    local state = states[actor]
    if not state then
        state = {}
        states[actor] = state
    end
    return state
end

---@param actor IsoGameCharacter Native actor
---@return table? state Existing guards without allocating during idle updates
function A.peek(actor)
    if isServer() then return states[actor] end
    if actor:hasModData() then return actor:getModData() end
end

---@param actor IsoZombie Recycled native actor
---@return nil
function A.created(actor)
    states[actor] = nil
    if not isServer() and actor:hasModData() then
        actor:getModData().OMHTTSiphonClaimed = nil
    end
end

Events.OnZombieCreate.Add(A.created)
return A
