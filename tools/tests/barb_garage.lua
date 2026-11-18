local B = require("OMHTT/BarbSections")
local S = require("OMHTT/BarbSupport")
local C = require("OMHTT/BarbContact")
local originalMode = testMode
for _, mode in pairs({"sp", "server"}) do
    testMode, testLoaded = mode, true
    B.initialize()
    for _, north in pairs({true, false}) do
        local square = makeSquare(north and 400 or 410, 400, 0)
        local host = IsoThumpable.new(getCell(), square, "garage-closed", north)
        host.kind, host.health = "IsoDoor", 137
        function host:IsOpen() return self.open == true end
        function host:isDestroyed() return self.health <= 0 end
        function host:getProperties() return {has = function(_, flag)
            return flag == (self.double and IsoPropertyType.DOUBLE_DOOR or IsoPropertyType.GARAGE_DOOR)
        end} end
        square:AddSpecialObject(host)
        local records, frames = {}, {}
        for _, side in pairs({-1, 1}) do
            local x, y = square.x, square.y
            if side < 0 then
                if north then y = y - 1 else x = x - 1 end
            end
            local floor = testSquares[x .. ":" .. y .. ":0"] or makeSquare(x, y, 0)
            function floor:isSolid() return false end
            function floor:isSolidTrans() return false end
            local facing = north and (side < 0 and "n" or "s") or (side < 0 and "w" or "e")
            check(B.onIsValid({square = floor, facing = facing}), "Closed garage accepts either face in both authority modes")
            local temporary = IsoThumpable.new(getCell(), floor, "omhtt_barrier_01_52", north)
            floor:AddSpecialObject(temporary)
            local frame = B.onCreate({thumpable = temporary, facing = facing}).object
            frames[side], records[side] = frame, B.record(frame)
        end
        check(records[-1].id ~= records[1].id, "Garage faces have independent identities")
        for cycle = 1, 4 do
            host.open = cycle % 2 == 1
            for step = 1, #B.order do B.tick() end
            for _, side in pairs({-1, 1}) do
                local record, frame = records[side], frames[side]
                local _, backing, attachment, status = B.resolve(record)
                check(status == "active" and backing == host and attachment.shared and B.nodes[record.id], "Raised attachment remains bound and shares native health")
                check((frame:getSpriteName() == "omhtt_barrier_01_102") == host.open, "Garage visibility follows open state")
                local actor = makeZombie(square, 1)
                actor.x, actor.y = square.x + (north and .5 or side * .2), square.y + (north and side * .2 or .5)
                function actor:getWidth() return .3 end
                function actor:getX() return self.x end
                function actor:getY() return self.y end
                local contact = B.contact(actor)
                check(host.open and contact == nil or not host.open and contact == record, "Suspended garage cannot damage or slow either side")
                check(host.health == 137, "Garage open state never repairs or damages the backing")
            end
        end
        host.open = true
        check(not S.bind(host, north, 1, "late-place", B.policy), "Raised garage cannot accept late binding")
        host.double = true
        check(not S.edge(host, north, 1, {}), "Swinging double doors remain unsupported")
        host.double, host.open = false, false
        B.retire(records[-1])
        check(select(4, B.resolve(records[1])) == "active", "Removing one garage face preserves the other")
        host.health = 0
        for step = 1, #B.order + 4 do B.tick() end
        check(not B.nodes[records[1].id], "Destroyed garage retires its remaining panel")
    end
end
testMode = originalMode
B.initialize()
for _, north in pairs({true, false}) do
    for _, side in pairs({-1, 1}) do
        local edge = {x = 16384, y = 16384, z = 0, north = north, side = side}
        local x, y = edge.x + (north and .5 or side * .30078125), edge.y + (north and side * .30078125 or .5)
        check(C.touching(edge, x, y, 0, .30000001192092896), "Native rounded collision boundary is included")
        check(not C.touching(edge, edge.x + .5, edge.y + .5, 0, .3), "Panel does not become a full-tile trigger")
        check(not C.touching(edge, x, y, 1, .3), "Contact tolerance cannot cross floors")
        local farX, farY = edge.x + (north and .5 or side * .302), edge.y + (north and side * .302 or .5)
        check(not C.touching(edge, farX, farY, 0, .3), "Contact tolerance remains narrow")
        local endX, endY = edge.x + (north and 1.01 or side * .2), edge.y + (north and side * .2 or 1.01)
        check(not C.touching(edge, endX, endY, 0, .3), "Contact tolerance does not extend segment endpoints")
    end
end
testResults[#testResults + 1] = "Garage panel authority/lifecycle and contact precision: passed"
