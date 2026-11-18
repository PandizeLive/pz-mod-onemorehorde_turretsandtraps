local B = {}
-- Cardinal beam intersection against an actor's swept collision footprint.
function B.cross(beam, ax, ay, bx, by)
    local a, b, p, q
    if beam.dx ~= 0 then
        a,b = (ax-beam.x)*beam.dx,(bx-beam.x)*beam.dx
        p,q = ay-beam.y,by-beam.y
    else
        a,b = (ay-beam.y)*beam.dy,(by-beam.y)*beam.dy
        p,q = ax-beam.x,bx-beam.x
    end
    local enter, leave = 0, 1
    local values = {{a,b,0,beam.length},{p,q,-.3,.3}}
    for i=1,2 do
        local v=values[i]
        local delta=v[2]-v[1]
        if math.abs(delta)<.000001 then
            if v[1]<v[3] or v[1]>v[4] then return false end
        else
            local first,last=(v[3]-v[1])/delta,(v[4]-v[1])/delta
            if first>last then first,last=last,first end
            enter,leave=math.max(enter,first),math.min(leave,last)
            if enter>leave then return false end
        end
    end
    return beam.length>0
end
function B.length(beam, range)
    local previous=getCell():getGridSquare(math.floor(beam.x),math.floor(beam.y),beam.z)
    if not previous then return 0 end
    -- Each boundary is checked before entering its square, including closed doors.
    local distance=.5
    if beam.dx~=0 then distance=beam.dx>0 and math.floor(beam.x)+1-beam.x or beam.x-math.floor(beam.x)
    else distance=beam.dy>0 and math.floor(beam.y)+1-beam.y or beam.y-math.floor(beam.y) end
    while distance<=range do
        local x,y=math.floor(beam.x+beam.dx*(distance+.001)),math.floor(beam.y+beam.dy*(distance+.001))
        local square=getCell():getGridSquare(x,y,beam.z)
        if not square then return math.max(0,distance-.01) end
        local vision=tostring(previous:testVisionAdjacent(x-previous:getX(),y-previous:getY(),0,false,false))
        if (vision~="Clear" and vision~="ClearThroughOpenDoor") or square:isSolid() or square:isSolidTrans()
            or previous:isWallTo(square) or previous:isDoorBlockedTo(square) then return math.max(0,distance-.01) end
        previous=square
        distance=distance+1
    end
    return range
end
return B
