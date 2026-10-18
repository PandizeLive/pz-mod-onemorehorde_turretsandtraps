local A = {}
local states = setmetatable({}, {__mode = "k"})

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
