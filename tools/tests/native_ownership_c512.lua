local actor, owner, other, connection = ...
assert(actor:getOwner() == connection and actor:getOwnerPlayer() == owner, "Native ownership assignment failed")
assert(type(actor) == "userdata" and type(connection) == "userdata", "Native objects required")
local S = require("OMHTT/DefenseContactServer")
local A = require("OMHTT/DefenseActors")
local C = require("OMHTT/DefenseContacts")
local P = require("OMHTT/DefenseCombatProtocol")
local D = require("OMHTT/Damage")
local B = require("OMHTT/BarrierRetaliation")
local F = require("OMHTT/BarrierFootprint")
local previousObserve, previousAt, previousExact, previousFace, previousDamage, previousCell = C.observe, A.at, F.exact, B.face, D.resolve, getCell
local cell = getCell()
local square = IsoGridSquare.new(cell, nil, 8100, 8100, 0)
local entered = IsoGridSquare.new(cell, nil, 8101, 8100, 0)
-- Both real squares must be visible to the lookup adapter before report indexing.
-- These synthetic tiles are not inserted into the native streamed map.
getCell = function() return {getGridSquare=function(_,x,y,z)
    if y==8100 and z==0 then
        if x==8100 then return square end
        if x==8101 then return entered end
    end
end} end
local target = IsoThumpable.new(cell, square, "omhtt_barrier_01_0", false)
square:getObjects():add(target)
target:setHealth(100)
actor:setCurrent(square)
actor:setX(8100.5)
actor:setY(8100.5)
actor:setZ(0)
actor:setHealth(1)
local id = actor:getOnlineID()
local oldActor = A.online[id]
A.online[id] = actor
local accepted, strikes = 0, 0
C.observe = function(value) assert(value == actor); accepted = accepted + 1 end
local frame = {id=id, outfit=P.outfit(actor:getPersistentOutfitID()), sequence=1, x=8101.5, y=8100.5, z=0,
    age=0, observedAt=GameTime.getServerTimeMills(), prone=false, down=false, landing=false}
S.observe(owner, frame, getTimestampMs())
assert(accepted == 1, "Real owner report did not reach contact routing")
assert(A.square(actor)==entered and actor:getX()==8100.5,"C517 native report indexing changed the actor or missed fresh membership")
frame.sequence = 2
S.observe(other, frame, getTimestampMs())
assert(accepted == 1, "Foreign native sender accepted")
actor:setOwnerPlayer(other)
assert(A.square(actor)==square,"C517 native ownership handoff retained old spatial report")
S.observe(owner, frame, getTimestampMs())
assert(accepted == 1, "Former native owner accepted after handoff")
S.observe(other, frame, getTimestampMs())
assert(accepted == 2, "New native owner rejected")
assert(A.square(actor)==entered,"C517 new native owner did not refresh spatial membership")
S.observe(other, frame, getTimestampMs())
assert(accepted == 2, "Native report duplicate accepted")
actor:setOwnerPlayer(owner)
getCell = function() return {getGridSquare=function() return square end} end
A.at = function() return {size=function() return 1 end, get=function() return actor end} end
F.exact = function(value) if value == target then return {id="c512-native-barrier",tier="normal"} end end
B.face = function() return "front" end
D.resolve = function(value, amount) assert(value == actor and amount > 0); strikes = strikes + 1 end
local message = {id=id,outfit=frame.outfit,barrier="c512-native-barrier",x=8100,y=8100,z=0,index=target:getObjectIndex(),token="left"}
-- Native replicated state is assigned by the Java probe before this stage.
assert(string.find(string.lower(actor:getRealState()), "thump", 1, true), "Native replicated thump fixture missing")
B.command("OMHTT_BarrierContact", "Strike", other, message)
assert(strikes == 0, "Foreign native barrier report accepted")
B.command("OMHTT_BarrierContact", "Strike", owner, message)
assert(strikes == 1, "Native barrier ownership route blocked")
B.command("OMHTT_BarrierContact", "Strike", owner, message)
assert(strikes == 1, "Duplicate barrier report accepted")
C.observe, A.at, F.exact, B.face, D.resolve, getCell = previousObserve, previousAt, previousExact, previousFace, previousDamage, previousCell
A.remove(actor)
A.online[id] = oldActor
actor:setOwner(nil)
actor:setOwnerPlayer(nil)
actor:setHealth(0)
print("[OMHTT-C517] native-fresh-membership passed=true actorPosition=unchanged handoff=passed syntheticSquareLookup=true clients=0")
return true
