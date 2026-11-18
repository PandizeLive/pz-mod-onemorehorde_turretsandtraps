-- Actual production client presentation/permission paths; controlled clocks and world doubles.
local Contacts = require("OMHTT/DefenseContactClient")
local Combat = require("OMHTT/DefenseCombatClient")
local Motion = require("OMHTT/DefenseMotion")
local Movement = require("OMHTT/BarbMovement")
local Poke = require("OMHTT/ControlPokeView")
local View = require("OMHTT/DamagePresentation")
local saved = {mode=testMode, time=testMillis, checks=Motion.checks, movement=Movement.apply,
    indicator=PixelStrikeIndicator, specific=getSpecificPlayer, count=getNumActivePlayers}
testMode, testMillis = "client", 19000000
local square = makeSquare(8105,8105,0)
square.isCanSee = function() return true end
local owner = {getOnlineID=function() return 51 end, isLocalPlayer=function() return true end}
local zombie = makeZombie(square, 2)
zombie.owner, zombie.onlineId, zombie.outfitId = owner, 19200, 19200
Combat.created(zombie)
local applied, touching = 0, false
Movement.apply = function(_, divisor) check(divisor == 2, "C515 local contact uses configured divisor"); applied=applied+1 end
Motion.checks = {test=function() if touching then return 2 end end}
Motion.created(zombie)
for _, delay in pairs({25,50,100}) do
    Contacts.created(zombie)
    local issued = testMillis
    testMillis = testMillis + delay
    Contacts.command("OMHTT_ContactV1", "Permits", nativeRoundTrip({{id=19200,outfit=19200,owner=51,allowed=true,issuedAt=issued,expires=issued+400}}))
    local before = applied
    touching = false
    Motion.update(zombie)
    check(applied == before, "C515 approach permission never slows outside contact")
    touching = true
    local entered = testMillis
    Motion.update(zombie)
    check(applied == before+1 and testMillis == entered, "C515 permitted entry slows in the same local update despite transport delay")
    touching = false
    Motion.update(zombie)
    check(applied == before+1, "C515 exit stops slowdown without waiting for server")
    touching = true
    zombie.owner = {getOnlineID=function() return 52 end,isLocalPlayer=function() return true end}
    Motion.update(zombie)
    check(applied == before+1, "C515 old permission cannot survive ownership transfer")
    zombie.owner = owner
    testMillis = issued+401
    Motion.update(zombie)
    check(applied == before+1, "C515 missing permission refresh fails closed")
end
Contacts.created(zombie)
Contacts.command("OMHTT_ContactV1", "Permits", {{id=19200,outfit=19200,owner=51,allowed=true,issuedAt=testMillis+101,expires=testMillis+501}})
check(not Contacts.permitted(zombie), "C515 future-dated grant rejected")
local issued = testMillis
local permit = {id=19200,outfit=19200,owner=51,allowed=true,issuedAt=issued,expires=issued+400}
Contacts.command("OMHTT_ContactV1", "Permits", {permit})
check(Contacts.permitted(zombie), "C515 fresh consent enables local contact")
Contacts.command("OMHTT_ContactV1", "Permits", {{id=19200,outfit=19200,owner=51,allowed=false,issuedAt=issued,expires=issued}})
Contacts.command("OMHTT_ContactV1", "Permits", {permit})
check(not Contacts.permitted(zombie), "C515 revocation wins over reordered grant with same timestamp")
testMillis = testMillis+1
permit.issuedAt,permit.expires = testMillis,testMillis+400
Contacts.command("OMHTT_ContactV1", "Permits", {permit})
check(Contacts.permitted(zombie), "C515 newer server consent can restore permission")
testMillis = 0
check(not Contacts.permitted(zombie), "C515 lost clock synchronization fails closed")
testMillis = issued+1
Contacts.created(zombie)
check(not Contacts.permitted(zombie), "C515 recycled actor loses permission")

local object = IsoThumpable.new(getCell(), square, "omhtt_barrier_01_85", false)
object:setHealth(200)
square:AddSpecialObject(object)
local state = {id="c515-poke",kind="Poke",active=false,sprite="omhtt_barrier_01_85"}
object:getModData().OMHTTControl = state
Poke.time = 0
Poke.contact(object,state)
check(object:getSpriteName() == "omhtt_barrier_01_89" and state.active == false and state.sprite == "omhtt_barrier_01_85",
    "C515 local Poke response does not mutate server state")
testMillis = testMillis+351
Poke.tick()
check(object:getSpriteName() == "omhtt_barrier_01_85", "C515 unconfirmed Poke prediction retracts")
Poke.time = 2000
Poke.contact(object,state)
state.active, state.sprite = true, "omhtt_barrier_01_89"
Poke.tick()
check(object:getSpriteName() == state.sprite, "C515 authoritative Poke confirmation replaces preview without retracting")

local shown = 0
PixelStrikeIndicator = {Config={showDamageDealt=true,showOrdinaryHits=true,scale=100},spawnAt=function() shown=shown+1 end}
getSpecificPlayer = function() return zombie end
getNumActivePlayers = function() return 2 end
local facts = {token="c515:hit",x=8105.5,y=8105.5,z=0,lost=.2,kind="barbs"}
View.present(facts)
facts.packet = 991515
triggerEvent("OnServerCommand","OMHTT_DamageView","Hit",facts)
check(shown == 2, "C515 owner display then server echo shows one popup per viewport")
facts.token, facts.packet = "c515:observer", 991516
triggerEvent("OnServerCommand","OMHTT_DamageView","Hit",facts)
check(shown == 4, "C515 observer with no local application still displays confirmed hit")

testMode,testMillis,Motion.checks,Movement.apply = saved.mode,saved.time,saved.checks,saved.movement
PixelStrikeIndicator,getSpecificPlayer,getNumActivePlayers = saved.indicator,saved.specific,saved.count
testResults[#testResults+1] = "C515 response: local entry/exit at 25/50/100ms transport, ownership/expiry, Poke reconciliation and popup deduplication passed; rendering/network are fixtures"
