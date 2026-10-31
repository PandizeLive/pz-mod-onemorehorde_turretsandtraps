local P = require("OMHTT/ControlPokeFootprint")
local B = {}

---@param square IsoGridSquare Candidate native tile
---@param north boolean? North edge
---@param wall boolean? Edge construction
---@return boolean blocked Occupied footprint or wall crossing the center-to-arm connection
function B.blocked(square, north, wall)
    if not square then return false end
    if not wall then return P.reserved(square) end
    if P.center(square) then return true end
    local x,y = square:getX(),square:getY()
    if north then y=y-1 else x=x-1 end
    return P.center(getCell():getGridSquare(x,y,square:getZ()))
end

---@return nil
function B.install()
    require("BuildingObjects/ISBuildingObject")
    require("BuildingObjects/ISBuildIsoEntity")
    require("BuildingObjects/ISWoodenWall")
    if ISBuildIsoEntity.omhttReservation then return end
    ISBuildIsoEntity.omhttReservation = true
    local valid = ISBuildIsoEntity.isValidPerSquare
    ---@return boolean valid Native preview and server create both call this gate
    function ISBuildIsoEntity:isValidPerSquare(square, tileInfo, requiresFloor, extendsN, extendsW)
        -- isWallLike is normally populated by the client preview renderer;
        -- the dedicated server must derive edge occupancy from the tile too.
        local sprite = tileInfo and tileInfo:getSpriteName() and getSprite(tileInfo:getSpriteName())
        local props = sprite and sprite:getProperties()
        local north, west = false, false
        if props then
            north = props:has(IsoPropertyType.WALL_N) or props:has(IsoPropertyType.WALL_N_TRANS)
                or props:has(IsoPropertyType.WINDOW_N) or props:has(IsoPropertyType.DOOR_WALL_N)
            west = props:has(IsoPropertyType.WALL_W) or props:has(IsoPropertyType.WALL_W_TRANS)
                or props:has(IsoPropertyType.WINDOW_W) or props:has(IsoPropertyType.DOOR_WALL_W)
            if north and B.blocked(square, true, true) then return false end
            if west and B.blocked(square, false, true) then return false end
        end
        if not north and not west and B.blocked(square, self.north, self.isWallLike) then return false end
        return valid(self,square,tileInfo,requiresFloor,extendsN,extendsW)
    end
    local wallValid,wallCreate = ISWoodenWall.isValid,ISWoodenWall.create
    ---@return boolean valid Legacy wall cursor
    function ISWoodenWall:isValid(square)
        if B.blocked(square,self.north,true) then return false end
        return wallValid(self,square)
    end
    ---@return any result Legacy creation rechecks before consuming materials
    function ISWoodenWall:create(x,y,z,north,sprite)
        if B.blocked(getCell():getGridSquare(x,y,z),north,true) then return false end
        return wallCreate(self,x,y,z,north,sprite)
    end
end

-- BuildingObjects is a server Lua directory also loaded by the game client.
-- It is not available during the menu's OnGameBoot phase.
Events.OnGameStart.Add(B.install)
Events.OnServerStarted.Add(B.install)
return B
