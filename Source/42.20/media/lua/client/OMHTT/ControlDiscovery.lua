if isServer() then return end
local D = {byId = setmetatable({}, {__mode = 'v'}), objects = setmetatable({}, {__mode = 'k'}), pending = setmetatable({}, {__mode = 'k'})}
D.pokes=setmetatable({}, {__mode="v"})
D.providers, D.contactTiles, D.contactKeys = {}, {}, setmetatable({}, {__mode="k"})
local F=require("OMHTT/Foundation")
local A = require('OMHTT/ControlAccess')
D.queue, D.queued, D.first, D.last = {}, {}, 1, 0
D.list, D.listIndex, D.listSize = setmetatable({}, {__mode = 'v'}), setmetatable({}, {__mode = 'k'}), 0

---@param object IsoObject Known device
---@return nil
function D.track(object, state)
    if state and state.kind=="Poke" then D.pokes[F.key(state.x,state.y,state.z)]=object end
    if state and not D.contactKeys[object] and (state.kind=="Plate" or state.kind=="Laser" or state.kind=="Tether") then
        local x, y = state.x, state.y
        local bx, by = x, y
        if state.kind ~= "Plate" then
            if state.facing == "n" then
                by = y-32
            elseif state.facing == "s" then
                by = y+32
            elseif state.facing == "w" then
                bx = x-32
            elseif state.facing == "e" then
                bx = x+32
            end
        end
        local keys = {}
        for tx=math.floor((math.min(x,bx)-2)/8),math.floor((math.max(x,bx)+2)/8) do
            for ty=math.floor((math.min(y,by)-2)/8),math.floor((math.max(y,by)+2)/8) do
                local key = F.key(tx,ty,state.z)
                local bucket = D.contactTiles[key] or setmetatable({}, {__mode="k"})
                D.contactTiles[key], bucket[object] = bucket, true
                keys[#keys+1] = key
            end
        end
        D.contactKeys[object] = keys
    end
    if D.listIndex[object] then return end
    D.listSize = D.listSize + 1
    D.list[D.listSize], D.listIndex[object] = object, D.listSize
end

---@param object IsoObject Candidate with possibly delayed native mod data
---@return boolean ready An installed trap provider indexed the object
function D.hazard(object)
    for _, provider in pairs(D.providers) do
        if provider(object) then return true end
    end
    return false
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
        D.track(object, state)
    elseif not D.hazard(object) then
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
    local keys = D.contactKeys[object] or {}
    for i=1,#keys do
        local key = keys[i]
        local bucket = D.contactTiles[key]
        bucket[object] = nil
        local occupied = false
        for _ in pairs(bucket) do
            occupied = true
            break
        end
        if not occupied then
            D.contactTiles[key] = nil
        end
    end
    D.contactKeys[object] = nil
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
    if D.first > D.last then return end
    local now = getTimestampMs()
    if now < (D.due or 0) then return end
    D.due = now + 50
    local count = math.min(64, D.last - D.first + 1)
    for i = 1, count do
        if getTimestampMs() >= now+1 then break end
        local object = D.queue[D.first]
        D.queue[D.first], D.queued[object] = nil, nil
        D.first = D.first + 1
        local expires = D.pending[object]
        if expires and object:getObjectIndex() >= 0 then
            local state = A.state(object)
            if state then
                D.objects[object], D.pending[object], D.byId[state.id] = state.id, nil, object
                D.track(object, state)
            elseif D.hazard(object) then
                D.pending[object] = nil
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
if isClient() then
    local Contacts = require("OMHTT/DefenseContactClient")
    ---@param zombie IsoZombie Native owner actor
    ---@return boolean nearby Approach corridor needs fresh position reports
    Contacts.checks.controls = function(zombie)
        local x,y,z = zombie:getX(),zombie:getY(),math.floor(zombie:getZ())
        local bucket = D.contactTiles[F.key(math.floor(x/8),math.floor(y/8),z)]
        if not bucket then return false end
        for object in pairs(bucket) do
            local state = object:getObjectIndex() >= 0 and object:getHealth()>0 and A.state(object)
            if state and state.enabled ~= false then
                local length = state.kind=="Laser" and A.laserRange() or state.kind=="Tether"
                    and math.max(1,math.min(32,(SandboxVars.OMHTurretsTraps or {}).TetherRange or 6)) or 0
                local dx,dy = x-state.x-.5,y-state.y-.5
                local forward,side = 0,0
                if state.facing=="n" then
                    forward,side=-dy,dx
                elseif state.facing=="s" then
                    forward,side=dy,dx
                elseif state.facing=="w" then
                    forward,side=-dx,dy
                else
                    forward,side=dx,dy
                end
                if forward>=-2 and forward<=length+2 and math.abs(side)<=2 then return true end
            end
        end
        return false
    end
    local Poke = require("OMHTT/ControlPokeView")
    Contacts.presentations.poke = function(zombie, permitted)
        if not permitted then return end
        local key = F.key(math.floor(zombie:getX()), math.floor(zombie:getY()), math.floor(zombie:getZ()))
        local object = D.pokes[key]
        if not object or object:getObjectIndex() < 0 or not object:getSquare() then return end
        local state = A.state(object)
        if state and state.kind == "Poke" then Poke.contact(object, state) end
    end
    require("OMHTT/DefenseContactClient").checks.poke=function(zombie)
        local x,y,z=math.floor(zombie:getX()),math.floor(zombie:getY()),math.floor(zombie:getZ())
        for dx=-1,1 do for dy=-1,1 do
            local key=F.key(x+dx,y+dy,z)
            local object=D.pokes[key]
            if object then
                if object:getObjectIndex()<0 or not object:getSquare() then D.pokes[key]=nil
                elseif object:getHealth()>0 then return true end
            end
        end end
        return false
    end
end
return D
