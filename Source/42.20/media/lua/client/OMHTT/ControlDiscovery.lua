if isServer() then return end
local D = {byId = setmetatable({}, {__mode = 'v'}), objects = setmetatable({}, {__mode = 'k'}), pending = setmetatable({}, {__mode = 'k'})}
local A = require('OMHTT/ControlAccess')

---@param object IsoObject Candidate
---@return nil
function D.add(object)
    if not object or not instanceof(object, 'IsoThumpable') then return end
    local state = A.state(object)
    if state then
        D.objects[object], D.pending[object], D.byId[state.id] = state.id, nil, object
    else
        D.pending[object] = getTimestampMs() + 10000
    end
end

---@param square IsoGridSquare Loaded tile
---@return nil
function D.square(square)
    local objects = square:getObjects()
    for i = 0, objects:size() - 1 do D.add(objects:get(i)) end
end

---@param object IsoObject Removed object
---@return nil
function D.remove(object)
    local id = D.objects[object]
    if id and D.byId[id] == object then D.byId[id] = nil end
    D.objects[object], D.pending[object] = nil, nil
end

---@return nil
function D.tick()
    local now, count = getTimestampMs(), 0
    if now < (D.due or 0) then return end
    D.due = now + 250
    for object, expires in pairs(D.pending) do
        if object:getObjectIndex() < 0 or now >= expires then
            D.pending[object] = nil
        else
            local state = A.state(object)
            if state then D.objects[object], D.pending[object], D.byId[state.id] = state.id, nil, object end
        end
        count = count + 1
        if count >= 64 then break end
    end
end

Events.LoadGridsquare.Add(D.square)
Events.OnObjectAdded.Add(D.add)
Events.OnObjectAboutToBeRemoved.Add(D.remove)
Events.OnTick.Add(D.tick)
return D
