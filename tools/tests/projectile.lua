local C = require("OMHTT/PrototypeCombat")
local M = require("OMHTT/TurretModules")
local F = require("OMHTT/Foundation")
C.resetObservations()
for x=980,986 do for y=980,982 do makeSquare(x,y,0) end end
local origin = testSquares[F.key(980,980,0)]
local destination = testSquares[F.key(984,980,0)]
local victim = makeZombie(destination,100)
local state = {id="flight-test",kind="potato",baseFacing=0,ammo=200,shots=0,nextShot=0}
local commits = 0
local function launch()
    state.nextShot = 0
    local options = {managed=true,range=8,interval=2000,damage=0.35,splash=0,radius=0,knockdown=0,
        target=victim,projectileSpeed=20,profile=M.profile(state,{active={}}),
        commit=function() commits=commits+1; return true end}
    return C.fire(state,{getSquare=function() return origin end},nil,options)
end
local hp = victim.health
local result, facts = launch()
check(result=="Fired" and facts.flight==200 and victim.health==hp and commits==1,"Four-tile shot commits once with 200ms travel and no early damage")
testMillis=testMillis+199; C.tickFlights()
check(victim.health==hp,"Damage cannot precede arrival")
testMillis=testMillis+1; C.tickFlights(); C.tickFlights()
check(math.abs(victim.health-(hp-0.35))<0.000001 and commits==1 and #C.pending==0,"Arrival applies damage once without spending again")
hp=victim.health
launch(); destination.blocked=true; testMillis=testMillis+200; C.tickFlights()
check(victim.health==hp and testResults[#testResults].missed,"New obstruction prevents delayed damage")
destination.blocked=false
launch(); victim.health=0; testMillis=testMillis+200; C.tickFlights()
check(victim.health==0 and testResults[#testResults].missed,"Dead target receives no delayed second hit")
victim.health=hp
launch(); testSquares[F.key(984,980,0)]=nil; testMillis=testMillis+200; C.tickFlights()
check(victim.health==hp and testResults[#testResults].missed,"Unloaded target square cannot take damage")
testSquares[F.key(984,980,0)]=destination
launch(); victim.square=testSquares[F.key(985,980,0)]; testMillis=testMillis+200; C.tickFlights()
check(math.abs(victim.health-(hp-0.35))<0.000001 and testResults[#testResults].x==985.5,"Normal target motion uses current hit location")
victim.square=destination
for i=1,128 do check(launch()=="Fired","Bounded flight queue accepts available slot") end
local beforeAmmo, beforeCommits=state.ammo,commits
check(launch()=="Unavailable" and state.ammo==beforeAmmo and commits==beforeCommits,"Full queue rejects before spending resources")
testMillis=testMillis+200; C.tickFlights()
check(#C.pending==124,"At most four arrivals resolve per tick")
C.resetObservations()
check(#C.pending==0,"Session reset discards transient flights")
