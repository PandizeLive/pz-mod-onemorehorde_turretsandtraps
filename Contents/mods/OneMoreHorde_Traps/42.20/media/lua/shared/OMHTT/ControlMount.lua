local M = {}
function M.resolve(x, y, z, face)
    local bx, by, north, side = x, y, false, 1
    if face == "n" then by, north, side = y+1, true, -1
    elseif face == "w" then bx, side = x+1, -1
    elseif face == "s" then north = true
    elseif face ~= "e" then return nil end
    local square = getCell():getGridSquare(bx, by, z)
    if not square then return nil end
    local objects, support = square:getObjects(), nil
    for i = 0, objects:size()-1 do
        local object = objects:get(i)
        local props = object:getProperties()
        local built = instanceof(object, "IsoThumpable")
        local rejected = instanceof(object, "IsoDoor") or instanceof(object, "IsoWindow")
            or (built and (object:isDoor() or object:isWindow() or object:isHoppable() or object:isTallHoppable()
                or object:isDestroyed() or object:getHealth() <= 0))
        if not rejected and props and props:has(north and IsoFlagType.WallN or IsoFlagType.WallW)
            and props:has(north and IsoFlagType.collideN or IsoFlagType.collideW) then support = object; break end
    end
    if not support then return nil end
    local ox, oy, dx, dy = bx+side*.08, by+.5, side, 0
    if north then ox, oy, dx, dy = bx+.5, by+side*.08, 0, side end
    local front = getCell():getGridSquare(math.floor(ox), math.floor(oy), z)
    if not front or not front:TreatAsSolidFloor() or front:isSolid() or front:isSolidTrans() then return nil end
    return {x=ox,y=oy,z=z,dx=dx,dy=dy}
end
function M.valid(params)
    local square = params.square
    return square ~= nil and M.resolve(square:getX(), square:getY(), square:getZ(), params.facing) ~= nil
end
return M
