-- Read-only client geometry. Every service/build is revalidated against the private server ledger.
local F = require("OMHTT/Foundation")
local G = require("OMHTT/BarrierGeometry")
local V = {}
local cached, cacheX, cacheY, cacheZ, cacheAt = nil, nil, nil, nil, 0

---@param object IsoObject? Replicated visual part
---@return table? record Detached presentation
function V.exact(object)
    if not object or not object:getSquare() or object:getObjectIndex() < 0 or not object:hasModData() then return nil end
    local data = object:getModData()
    local marker = data.OMHTT
    if not marker and data.OMHTTEdge then
        local x, y, z = string.match(data.OMHTTEdge.anchor or "", "^(%d+):(%d+):(%-?%d+)")
        local square = x and getCell():getGridSquare(tonumber(x), tonumber(y), tonumber(z))
        if square then
            local part, count = F.find(square, data.OMHTTEdge.id)
            if part and count == 1 then return V.exact(part) end
        end
        return nil
    end
    if not marker or marker.kind ~= "barrier" or marker.placementSource ~= "construction"
        or type(marker.id) ~= "string" or not F.isInteger(marker.anchorX, 0, 1000000)
        or not F.isInteger(marker.anchorY, 0, 1000000) or not F.isInteger(marker.anchorZ, -32, 32)
        or not F.isInteger(marker.facing, 0, 12) or marker.facing % 4 ~= 0 then return nil end
    local view = {}
    for key, value in pairs(marker) do view[key] = value end
    view.x, view.y, view.z = marker.anchorX, marker.anchorY, marker.anchorZ
    return view
end

---@param record table Replicated barrier
---@return table? parts Both exact loaded visual parts
function V.parts(record)
    local nx, ny = F.barrierDirection(record.facing)
    local parts = {}
    for part = 0, 1 do
        local square = getCell():getGridSquare(record.x - ny * part, record.y + nx * part, record.z)
        if not square then return nil end
        local object, count = F.find(square, record.id)
        if count ~= 1 or not V.exact(object) then return nil end
        parts[#parts + 1] = object
    end
    return parts
end

---@param x number Preview anchor
---@param y number Preview anchor
---@param z number Floor
---@return table records Only neighbors capable of sharing this two-tile outline
function V.records(x, y, z)
    local now = getTimestampMs()
    if cached and cacheX == x and cacheY == y and cacheZ == z and now >= cacheAt and now - cacheAt < 100 then return cached end
    local records, seen = {}, {}
    for dx = -3, 3 do
        for dy = -3, 3 do
            local square = getCell():getGridSquare(x + dx, y + dy, z)
            local objects = square and square:getObjects()
            if objects then
                for i = 0, objects:size() - 1 do
                    local record = V.exact(objects:get(i))
                    if record and not seen[record.id] then
                        seen[record.id], records[#records + 1] = true, record
                    end
                end
            end
        end
    end
    cached, cacheX, cacheY, cacheZ, cacheAt = records, x, y, z, now
    return records
end

---@param x number Anchor X
---@param y number Anchor Y
---@param z number Floor
---@param facing number Cardinal orientation
---@return string? failure Read-only preview, never construction authorization
function V.canBuild(x, y, z, facing)
    local nx, ny = F.barrierDirection(facing)
    for part = 0, 1 do
        local square = getCell():getGridSquare(x - ny * part, y + nx * part, z)
        if not square or not square:getFloor() or square:HasStairs() or square:HasStairsBelow()
            or square:isVehicleIntersecting() or square:has(IsoFlagType.water) or square:getMovingObjects():size() > 0 then return "Blocked" end
        local objects = square:getObjects()
        local special = square:getSpecialObjects()
        for i = 0, special:size() - 1 do
            if not V.exact(special:get(i)) then return "Blocked" end
        end
        for i = 0, objects:size() - 1 do
            local object = objects:get(i)
            if not V.exact(object) then
                local props = object:getProperties()
                if props and (props:has(IsoFlagType.solid) or props:has(IsoFlagType.solidtrans)
                    or props:has(IsoFlagType.collideN) or props:has(IsoFlagType.collideW)
                    or props:has(IsoFlagType.WallN) or props:has(IsoFlagType.WallW)) then return "Blocked" end
            end
        end
    end
    local candidate = {id = "preview", x = x, y = y, z = z, facing = facing}
    local records = V.records(x, y, z)
    local fronts = G.shape(candidate)
    for i = 1, #records do
        local record = records[i]
        if record.facing % 8 == facing % 8 then
            local ox, oy = F.barrierDirection(record.facing)
            for a = 0, 1 do
                for b = 0, 1 do
                    if x - ny * a == record.x - oy * b and y + nx * a == record.y + ox * b then return "Occupied" end
                end
            end
        end
        local other = G.shape(records[i])
        for j = 1, #fronts do
            for k = 1, #other do
                if fronts[j].key == other[k].key then return "Occupied" end
            end
        end
    end
    local edges = G.outline(candidate, records)
    for i = 1, #edges do
        local edge = edges[i]
        local square = getCell():getGridSquare(edge.x, edge.y, z)
        if not square or not square:getFloor() or square:HasStairs() or square:HasStairsBelow()
            or square:isVehicleIntersecting() or square:has(IsoFlagType.water) then return "Blocked" end
        local special, objects = square:getSpecialObjects(), square:getObjects()
        for j = 0, special:size() - 1 do
            if not V.exact(special:get(j)) then return "Blocked" end
        end
        for j = 0, objects:size() - 1 do
            local object = objects:get(j)
            if not V.exact(object) then
                local props = object:getProperties()
                if props and (props:has(IsoFlagType.solid) or props:has(IsoFlagType.solidtrans)
                    or props:has(edge.north and IsoFlagType.collideN or IsoFlagType.collideW)
                    or props:has(edge.north and IsoFlagType.WallN or IsoFlagType.WallW)) then return "Blocked" end
            end
        end
    end
end

return V
