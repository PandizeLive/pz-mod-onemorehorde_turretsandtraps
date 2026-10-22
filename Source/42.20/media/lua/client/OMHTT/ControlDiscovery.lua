if isServer() then return end
local D = {byId = setmetatable({}, {__mode = 'v'}), objects = setmetatable({}, {__mode = 'k'}), pending = setmetatable({}, {__mode = 'k'})}
local A = require('OMHTT/ControlAccess')
D.queue, D.queued, D.first, D.last = {}, {}, 1, 0
D.list, D.listIndex, D.listSize = setmetatable({}, {__mode = 'v'}), setmetatable({}, {__mode = 'k'}), 0

---@param object IsoObject Known device
---@return nil
function D.track(object)
    if D.listIndex[object] then return end
    D.listSize = D.listSize + 1
    D.list[D.listSize], D.listIndex[object] = object, D.listSize
end

---@param index number Removed or collected slot
---@return nil
function D.drop(index)
    local object, last = D.list[index], D.list[D.listSize]
    if object then
        D.listIndex[object] = nil
    end
    D.list[index] = last
    D.list[D.listSize] = nil
    if last and index < D.listSize then
        D.listIndex[last] = index
    end
    D.listSize = D.listSize - 1
end

---@param object IsoObject Candidate
---@return nil
function D.add(object)
    if not object or not instanceof(object, 'IsoThumpable') then return end
    local state = A.state(object)
    if state then
        D.objects[object], D.pending[object], D.byId[state.id] = state.id, nil, object
        D.track(object)
    else
        D.pending[object] = getTimestampMs() + 10000
        if not D.queued[object] then
            D.last = D.last + 1
            D.queue[D.last], D.queued[object] = object, true
        end
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
    local index = D.listIndex[object]
    if index then
        D.drop(index)
    end
    local id = D.objects[object]
    if id and D.byId[id] == object then D.byId[id] = nil end
    D.objects[object], D.pending[object] = nil, nil
end

---@return nil
function D.tick()
    local now = getTimestampMs()
    if now < (D.due or 0) then return end
    D.due = now + 250
    local count = math.min(64, D.last - D.first + 1)
    for i = 1, count do
        local object = D.queue[D.first]
        D.queue[D.first], D.queued[object] = nil, nil
        D.first = D.first + 1
        local expires = D.pending[object]
        if expires and object:getObjectIndex() >= 0 then
            local state = A.state(object)
            if state then
                D.objects[object], D.pending[object], D.byId[state.id] = state.id, nil, object
                D.track(object)
            elseif now < expires then
                D.last = D.last + 1
                D.queue[D.last], D.queued[object] = object, true
            else
                D.pending[object] = nil
            end
        else
            D.pending[object] = nil
        end
    end
    if D.first > D.last then
        D.first, D.last = 1, 0
    end
end

Events.LoadGridsquare.Add(D.square)
Events.OnObjectAdded.Add(D.add)
Events.OnObjectAboutToBeRemoved.Add(D.remove)
Events.OnTick.Add(D.tick)
return D
