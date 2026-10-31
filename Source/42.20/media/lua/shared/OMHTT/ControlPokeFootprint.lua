local P = {offsets = {{0,0},{1,0},{-1,0},{0,1},{0,-1}}}

---@param square IsoGridSquare? Candidate center
---@param ignore IsoObject? Placement in progress
---@return boolean center Installed five-tile assembly
function P.center(square, ignore)
    local objects = square and square:getObjects()
    for i = 0, (objects and objects:size() or 0) - 1 do
        local object = objects:get(i)
        if object ~= ignore then
            local state = require("OMHTT/ControlAccess").state(object)
            if state and state.kind == "Poke" and state.pokeFootprint == 1 then return true end
        end
    end
    return false
end

---@param square IsoGridSquare Candidate occupied tile
---@param ignore IsoObject? Current construction object
---@return boolean reserved A loaded Poke center owns this tile
function P.reserved(square, ignore)
    if not square then return false end
    local x,y,z = square:getX(),square:getY(),square:getZ()
    for i=1,#P.offsets do
        local offset = P.offsets[i]
        local tile = getCell():getGridSquare(x+offset[1],y+offset[2],z)
        if P.center(tile, ignore) then return true end
    end
    return false
end

---@param square IsoGridSquare Proposed center
---@param ignore IsoObject? Object just created by native construction
---@return boolean valid All five exclusive ground tiles are available
function P.valid(square, ignore, character)
    if not square then return false end
    local x,y,z = square:getX(),square:getY(),square:getZ()
    for i=1,#P.offsets do
        local offset = P.offsets[i]
        local tile = getCell():getGridSquare(x+offset[1],y+offset[2],z)
        if not tile or not tile:TreatAsSolidFloor() or tile:isSolid() or tile:isSolidTrans()
            or tile:HasStairs() or tile:HasStairsBelow() or tile:isVehicleIntersecting()
            or tile:has(IsoFlagType.water) or tile:getProperties():has(IsoPropertyType.BLOCKS_PLACEMENT)
            or P.reserved(tile, ignore) then return false end
        if character and SafeHouse.isSafeHouse(tile, character:getUsername(), true) then return false end
        if tile ~= square and square:isSomethingTo(tile) then return false end
        local objects = tile:getObjects()
        for n=0,objects:size()-1 do
            local object = objects:get(n)
            if object ~= ignore and object:hasModData() then
                local data = object:getModData()
                if data.OMHTT or data.OMHTTEdge or data.OMHTTControl or data.OMHTTTurret
                    or data.OMHTTBed or data.OMHTTBarbFrame then return false end
            end
        end
    end
    return true
end

return P
