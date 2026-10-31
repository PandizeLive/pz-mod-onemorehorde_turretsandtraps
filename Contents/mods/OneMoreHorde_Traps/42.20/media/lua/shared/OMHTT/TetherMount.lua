local Contact = require("OMHTT/BarbContact")
local Support = require("OMHTT/BarbSupport")
local M = {}

---@param support IsoObject? Selected backing
---@param north boolean Backing edge axis
---@return boolean valid
function M.supported(support, north)
    local kind = Support.kind(support, north, true)
    if kind == "map-wall" then return true end
    return kind == "constructed-wall" and not support:isDestroyed() and support:getHealth() > 0
end

---@param x number Placement tile X
---@param y number Placement tile Y
---@param z number Placement floor
---@param face string Native placement face e, n, w or s
---@param cell IsoCell? Loaded world
---@return table? mount Trusted wall coordinates and outward launch origin
---@return IsoObject? support Exact backing
function M.resolve(x, y, z, face, cell)
    local bx, by, north, side = Contact.edge(x, y, face)
    if not bx then return nil end
    cell = cell or getCell()
    local backing = cell:getGridSquare(bx, by, z)
    if not backing then return nil end
    local support = Support.find(backing, north, true)
    if not M.supported(support, north) then return nil end
    local dx, dy = side, 0
    local ox, oy = bx + side * .08, by + .5
    if north then
        dx, dy = 0, side
        ox, oy = bx + .5, by + side * .08
    end
    local front = cell:getGridSquare(math.floor(ox), math.floor(oy), z)
    if not front or not front:TreatAsSolidFloor() or front:isSolid() or front:isSolidTrans() then return nil end
    return {wallX = bx, wallY = by, z = z, north = north, side = side,
        x = ox, y = oy, dx = dx, dy = dy, face = face}, support
end

return M
