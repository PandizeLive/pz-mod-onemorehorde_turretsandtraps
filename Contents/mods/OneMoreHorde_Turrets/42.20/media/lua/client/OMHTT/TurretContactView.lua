if isServer() then return end
local V = {tiles={},entries={}}
local F = require("OMHTT/Foundation")

---@param object IsoObject Removed or changed turret
---@return nil
function V.remove(object)
    local entry=V.entries[object]
    if not entry then return end
    for i=1,#entry.keys do
        local bucket=V.tiles[entry.keys[i]]
        bucket[object]=nil
        local occupied=false
        for _ in pairs(bucket) do occupied=true; break end
        if not occupied then V.tiles[entry.keys[i]]=nil end
    end
    V.entries[object]=nil
end

---@param object IsoObject Replicated turret
---@param range number Effective engagement radius
---@return nil
function V.changed(object, range)
    local square=object:getSquare()
    if not square or object:getObjectIndex()<0 then V.remove(object); return end
    local x,y,z=square:getX()+.5,square:getY()+.5,square:getZ()
    local old=V.entries[object]
    if old and old.range==range and old.x==x and old.y==y and old.z==z then return end
    V.remove(object)
    local entry={x=x,y=y,z=z,range=range,keys={}}
    V.entries[object]=entry
    for bx=math.floor((x-range-2)/8),math.floor((x+range+2)/8) do
        for by=math.floor((y-range-2)/8),math.floor((y+range+2)/8) do
            local key=F.key(bx,by,z)
            V.tiles[key]=V.tiles[key] or {}
            V.tiles[key][object]=entry
            entry.keys[#entry.keys+1]=key
        end
    end
end

---@param zombie IsoZombie Native owner actor
---@return boolean nearby Needs current position reports
function V.near(zombie)
    local x,y,z=zombie:getX(),zombie:getY(),math.floor(zombie:getZ())
    local bucket=V.tiles[F.key(math.floor(x/8),math.floor(y/8),z)]
    if not bucket then return false end
    for object,entry in pairs(bucket) do
        if object:getObjectIndex()>=0 and object:getSquare() and object:getHealth()>0
            and (x-entry.x)^2+(y-entry.y)^2<=(entry.range+2)^2 then return true end
    end
    return false
end

if isClient() then require("OMHTT/DefenseContactClient").checks.turrets=V.near end
Events.OnObjectAboutToBeRemoved.Add(V.remove)
return V
