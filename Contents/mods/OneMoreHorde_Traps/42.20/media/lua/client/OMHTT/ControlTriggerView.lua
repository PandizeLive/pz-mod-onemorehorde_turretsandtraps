if isServer() then return end
local V={pending={},entries={}}
local A=require("OMHTT/ControlAccess")
function V.add(object)
    if instanceof(object,"IsoThumpable") then V.pending[object]=getTimestampMs()+10000 end
end
function V.square(square)
    local objects=square:getObjects()
    for i=0,objects:size()-1 do V.add(objects:get(i)) end
end
function V.remove(object) V.pending[object],V.entries[object]=nil,nil end
function V.tick()
    local now=getTimestampMs()
    if now<(V.due or 0) then return end
    V.due=now+250
    local n=0
    for object,expires in pairs(V.pending) do
        local state=A.state(object)
        if state or now>=expires or object:getObjectIndex()<0 then
            V.pending[object]=nil
            if state and (state.kind=="Lever" or state.kind=="Laser") then V.entries[object]={} end
        end
        n=n+1
        if n>=64 then break end
    end
end
local Draw = require("OMHTT/ControlModelDraw")
local Options = require("OMHTT/ControlOptions")

---@param index number Native viewport
---@return nil
function V.render(index)
    local player, cell = getSpecificPlayer(index), getCell()
    if not player or not cell then return end
    local budget = 192
    for object, cache in pairs(V.entries) do
        local state, square = A.state(object), object:getSquare()
        if not state or object:getObjectIndex() < 0 or not square or cell:getGridSquare(state.x,state.y,state.z) ~= square then
            V.remove(object)
        elseif state.powered and object:getHealth() > 0 and math.floor(player:getZ()) == state.z
            and square:isCanSee(index) and math.abs(player:getX()-state.x)+math.abs(player:getY()-state.y) < 50 then
            if state.kind == "Laser" and Options.get("LaserVisible") and state.beamX and state.beamLength then
                local length = math.min(state.beamLength, state.beamVisualLength or state.beamLength)
                local colour = state.active and "Red" or "Green"
                if not cache[colour] then
                    cache[colour] = instanceItem("Base.OMHTTTrapLaser" .. colour .. "Visual")
                end
                local model = cache[colour]
                model:setWorldAlpha(Options.get("LaserOpacity") / 100)
                local yaw = math.deg(math.atan2(state.beamDY, state.beamDX))
                local count = math.ceil(length / .25)
                for segment = 1, count do
                    if budget <= 0 then return end
                    local start = (segment - 1) * .25
                    local size = math.min(.25, length - start)
                    local x = state.beamX + state.beamDX * (start + size / 2)
                    local y = state.beamY + state.beamDY * (start + size / 2)
                    local tile = cell:getGridSquare(math.floor(x),math.floor(y),state.z)
                    if not tile or not tile:isCanSee(index) then break end
                    model:setWorldScale(size / 1.5)
                    Draw.draw(model, tile, x, y, state.z + .32, 0, 0, yaw)
                    budget = budget - 1
                end
            elseif state.kind == "Lever" and state.active then
                if cache.facing ~= state.facing then
                    cache.facing = state.facing
                    cache.mount = require("OMHTT/ControlMount").resolve(state.x,state.y,state.z,state.facing)
                end
                if cache.mount then
                    if not cache.marker then
                        cache.marker = instanceItem("Base.OMHTTTurretStateGreenVisual")
                        cache.marker:setWorldAlpha(.4)
                        cache.marker:setWorldScale(.4)
                    end
                    Draw.draw(cache.marker, square, cache.mount.x, cache.mount.y, state.z + .32, 0, 0, 0)
                end
            end
        end
    end
end
Events.OnObjectAdded.Add(V.add)
Events.LoadGridsquare.Add(V.square)
Events.OnObjectAboutToBeRemoved.Add(V.remove)
Events.OnTick.Add(V.tick)
Events.RenderOpaqueObjectsInWorld.Add(V.render)
return V
