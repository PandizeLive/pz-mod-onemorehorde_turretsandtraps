if isClient() then return end
local Beam = require("OMHTT/ControlBeam")
local S = {entries={},tiles={},positions=setmetatable({}, {__mode="k"}),count=0}
local function key(x,y,z) return x .. ":" .. y .. ":" .. z end
local function actorValid(actor,z)
    return (instanceof(actor,"IsoZombie") or instanceof(actor,"IsoPlayer")) and not actor:isDead()
        and math.floor(actor:getZ())==z
end
function S.remove(object)
    local entry=S.entries[object]
    if not entry then return end
    for i=1,#entry.keys do
        local k=entry.keys[i]
        local bucket=S.tiles[k]
        bucket[object]=nil
        local found=false
        for _ in pairs(bucket) do found=true; break end
        if not found then S.tiles[k]=nil end
    end
    S.entries[object]=nil
    S.count=S.count-1
    if S.count==0 then S.positions=setmetatable({}, {__mode="k"}) end
end
function S.step(object,state)
    local W=require("OMHTT/ControlWorld")
    local mount=require("OMHTT/ControlMount").resolve(state.x,state.y,state.z,state.facing)
    local old=S.entries[object]
    if not mount or not require("OMHTT/ControlPower").trigger(object) then
        S.remove(object)
        local changed = state.beamLength ~= 0
        state.beamLength=0
        state.beamVisualLength=0
        W.updateInput(object,false,false)
        if changed then W.publish(object) end
        return
    end
    mount.length=Beam.length(mount,require("OMHTT/ControlAccess").laserRange())
    local changed=not old or old.length~=mount.length or old.x~=mount.x or old.y~=mount.y
    local entry=old
    if changed then
        S.remove(object)
        entry=mount
        entry.keys={}
        entry.squares={}
        S.entries[object]=entry
        S.count=S.count+1
        local bx,by=entry.x+entry.dx*entry.length,entry.y+entry.dy*entry.length
        for x=math.floor(math.min(entry.x,bx)-.3),math.floor(math.max(entry.x,bx)+.3) do
            for y=math.floor(math.min(entry.y,by)-.3),math.floor(math.max(entry.y,by)+.3) do
                local k=key(x,y,entry.z)
                entry.keys[#entry.keys+1]=k
                entry.squares[#entry.squares+1]={x=x,y=y,z=entry.z}
                S.tiles[k]=S.tiles[k] or {}
                S.tiles[k][object]=true
            end
        end
    end
    local occupied, visualLength = false, entry.length
    for i=1,#entry.keys do
        local tile=entry.squares[i]
        local square=getCell():getGridSquare(tile.x,tile.y,tile.z)
        local objects=square and square:getMovingObjects()
        if objects then
            for j=0,math.min(127,objects:size()-1) do
                local actor=objects:get(j)
                if actorValid(actor,entry.z) and Beam.cross(entry,actor:getX(),actor:getY(),actor:getX(),actor:getY()) then
                    occupied = true
                    local forward = (actor:getX() - entry.x) * entry.dx + (actor:getY() - entry.y) * entry.dy
                    visualLength = math.min(visualLength, math.max(0, forward - .3))
                end
            end
        end
    end
    if state.beamVisualLength == nil or math.abs(state.beamVisualLength - visualLength) > .025 then
        state.beamVisualLength = visualLength
        changed = true
    end
    state.beamX,state.beamY,state.beamDX,state.beamDY,state.beamLength=entry.x,entry.y,entry.dx,entry.dy,entry.length
    W.updateInput(object,occupied or require("OMHTT/ControlClock").now()<(entry.crossedUntil or 0))
    if changed then W.publish(object) end
end
function S.actor(actor)
    if S.count==0 or GameTime.isGamePaused() then return end
    local x,y,z=actor:getX(),actor:getY(),math.floor(actor:getZ())
    local previous=S.positions[actor]
    if not previous then S.positions[actor]={x=x,y=y,z=z}; return end
    local ax,ay,az=previous.x,previous.y,previous.z
    previous.x,previous.y,previous.z=x,y,z
    if az~=z or not actorValid(actor,z) or math.abs(x-ax)+math.abs(y-ay)>4 or (x==ax and y==ay) then return end
    local checked={}
    for tx=math.floor(math.min(ax,x)-.3),math.floor(math.max(ax,x)+.3) do
        for ty=math.floor(math.min(ay,y)-.3),math.floor(math.max(ay,y)+.3) do
            for object in pairs(S.tiles[key(tx,ty,z)] or {}) do
                if not checked[object] then
                    checked[object]=true
                    local W=require("OMHTT/ControlWorld")
                    local state=W.state(object)
                    if state and state.powered and object:getHealth()>0 then
                        local entry=S.entries[object]
                        local length=entry.length
                        entry.length=Beam.length(entry,math.min(length,require("OMHTT/ControlAccess").laserRange()))
                        if Beam.cross(entry,ax,ay,x,y) then
                            entry.crossedUntil=require("OMHTT/ControlClock").now()+150
                            W.updateInput(object,true)
                            -- Admit this crossing now; no delayed historical Button-like replay.
                            if state.active then
                                for i=1,#state.links do
                                    local target=W.objects[state.links[i]]
                                    if target then W.receiver(target,getTimestampMs()) end
                                end
                            end
                        end
                        entry.length=length
                    end
                end
            end
        end
    end
end
return S
