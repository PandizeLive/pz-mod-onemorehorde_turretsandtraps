if isServer() then return end
require("ISUI/ISPanel")
local V={pending={},entries={}}
local A=require("OMHTT/ControlAccess")
local canvas
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
local function screen(x,y,z,index)
    local zoom=getCore():getZoom(index)
    return (IsoUtils.XToScreen(x,y,z,0)-IsoCamera.getOffX(index))/zoom+getPlayerScreenLeft(index),
        (IsoUtils.YToScreen(x,y,z,0)-IsoCamera.getOffY(index))/zoom+getPlayerScreenTop(index)
end
function V.render()
    local cell=getCell()
    if not cell then return end
    for object in pairs(V.entries) do
        local state=A.state(object)
        local square=object:getSquare()
        if not state or object:getObjectIndex()<0 or not square or cell:getGridSquare(state.x,state.y,state.z)~=square then
            V.remove(object)
        elseif state.powered and object:getHealth()>0 and (state.kind=="Laser" or state.active) then
            if not canvas then canvas=ISPanel:new(0,0,getCore():getScreenWidth(),getCore():getScreenHeight()); canvas:initialise(); canvas:instantiate() end
            for index=0,getNumActivePlayers()-1 do
                local player=getSpecificPlayer(index)
                if player and math.floor(player:getZ())==state.z and square:isCanSee(index)
                    and math.abs(player:getX()-state.x)+math.abs(player:getY()-state.y)<50 then
                    canvas:setStencilRect(getPlayerScreenLeft(index),getPlayerScreenTop(index),getPlayerScreenWidth(index),getPlayerScreenHeight(index))
                    if state.kind=="Laser" and state.beamX and state.beamLength then
                        local x,y=state.beamX,state.beamY
                        local sx,sy=screen(x,y,state.z+.32,index)
                        for step=1,math.ceil(state.beamLength/.25) do
                            local d=math.min(state.beamLength,step*.25)
                            local wx,wy=x+state.beamDX*d,y+state.beamDY*d
                            local tile=cell:getGridSquare(math.floor(wx),math.floor(wy),state.z)
                            if not tile or not tile:isCanSee(index) then break end
                            local ex,ey=screen(wx,wy,state.z+.32,index)
                            canvas:drawLine(nil,sx,sy,ex,ey,2,.8,state.active and 1 or .15,state.active and .15 or 1,.15)
                            sx,sy=ex,ey
                        end
                    elseif state.kind=="Lever" then
                        local cache=V.entries[object]
                        if cache.facing~=state.facing then
                            cache.facing=state.facing
                            cache.mount=require("OMHTT/ControlMount").resolve(state.x,state.y,state.z,state.facing)
                        end
                        local mount=cache.mount
                        if mount then
                            local x,y=screen(mount.x,mount.y,state.z+.32,index)
                            canvas:drawRect(x-4,y-4,8,8,.12,.3,1,.3)
                            canvas:drawRect(x-2,y-2,4,4,.55,.3,1,.3)
                        end
                    end
                    canvas:clearStencilRect()
                end
            end
        end
    end
end
Events.OnObjectAdded.Add(V.add)
Events.LoadGridsquare.Add(V.square)
Events.OnObjectAboutToBeRemoved.Add(V.remove)
Events.OnTick.Add(V.tick)
Events.OnPreUIDraw.Add(V.render)
return V
