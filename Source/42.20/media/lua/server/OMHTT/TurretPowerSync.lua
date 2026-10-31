if isClient() then return end
local S = {}
local pending = setmetatable({}, {__mode = "k"})
local due = 0

---@param generator IsoGenerator Changed native generator
---@return nil
function S.changed(generator)
    if isServer() then pending[generator] = true end
end

---@return nil
function S.tick()
    if not isServer() or getTimestampMs() < due then return end
    due = getTimestampMs() + 250
    local count = 0
    for generator in pairs(pending) do
        pending[generator] = nil
        if generator:getObjectIndex() >= 0 then generator:sync() end
        count = count + 1
        if count >= 4 then break end
    end
end

Events.OnTick.Add(S.tick)
return S
