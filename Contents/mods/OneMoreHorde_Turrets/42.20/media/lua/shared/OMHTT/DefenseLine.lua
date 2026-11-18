local Line = {}

---@param square IsoGridSquare Origin
---@param dx number Adjacent X
---@param dy number Adjacent Y
---@return boolean clear
---@nodiscard
local function clearEdge(square, dx, dy)
    local result = tostring(square:testVisionAdjacent(dx, dy, 0, false, false))
    return result == "Clear" or result == "ClearThroughOpenDoor"
end
---@param origin IsoGridSquare Device square
---@param destination IsoGridSquare Target square
---@param range number? Maximum tile distance
---@return boolean clear
---@return string? reason Blocked path category
---@nodiscard
function Line.clear(origin, destination, range)
    range = range or 6
    if not origin or not destination then return false, "missing-square" end
    if origin:getZ() ~= destination:getZ() then return false, "different-floor" end
    local dx = destination:getX() - origin:getX()
    local dy = destination:getY() - origin:getY()
    local steps = math.max(math.abs(dx), math.abs(dy))
    if steps > math.ceil(range) then return false, "range" end
    local previous = origin
    for i = 1, steps do
        local x = origin:getX() + math.floor(dx * i / steps + 0.5)
        local y = origin:getY() + math.floor(dy * i / steps + 0.5)
        local square = getCell():getGridSquare(x, y, origin:getZ())
        if not square then return false, "unloaded-path" end
        if not clearEdge(previous, x - previous:getX(), y - previous:getY()) then return false, "blocked-edge" end
        if previous:isWindowTo(square) then return false, "window-edge" end
        if x ~= previous:getX() and y ~= previous:getY() then
            local sideX = getCell():getGridSquare(x, previous:getY(), origin:getZ())
            local sideY = getCell():getGridSquare(previous:getX(), y, origin:getZ())
            if not sideX or not sideY
                or not clearEdge(previous, x - previous:getX(), 0)
                or not clearEdge(previous, 0, y - previous:getY())
                or not clearEdge(sideX, 0, y - previous:getY())
                or not clearEdge(sideY, x - previous:getX(), 0)
                or previous:isWindowTo(sideX) or previous:isWindowTo(sideY)
                or sideX:isWindowTo(square) or sideY:isWindowTo(square) then return false, "diagonal-corner" end
        end
        previous = square
    end
    return true
end

return Line
