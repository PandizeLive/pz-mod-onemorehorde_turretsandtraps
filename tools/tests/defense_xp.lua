local I = require("OMHTT/DefenseInjury")
local X = require("OMHTT/DefenseXP")
local old = {mode=testMode, credit=OMHTS_DefenseCredit, send=sendServerCommand,
    time=getTimestampMs, client=sendClientCommand, players=getSpecificPlayer,
    mods=getActivatedMods, parts=BodyPartType, evidence=__modules.OMHTS_InjuryEvidence}
local now, messages, starts, finishes = 100000, {}, {}, {}
getTimestampMs = function() return now end
sendServerCommand = function(player, module, command, args)
    messages[#messages+1] = {player=player, module=module, command=command, args=args}
end
OMHTS_DefenseCredit = {API_VERSION=1,
    beginInjury=function(player, token) starts[#starts+1]={player=player,token=token} end,
    finishInjury=function(player, token, owner, injured) finishes[#finishes+1]={player=player,token=token,owner=owner,injured=injured} end}
local function actor(id)
    return {getOnlineID=function() return id end, isDead=function() return false end,
        isGodMod=function() return false end, isNoClip=function() return false end,
        isGhostMode=function() return false end}
end
local victim, stranger = actor(77), actor(78)
testMode = "server"
X.register("xp-test-device", "Owner", 1, 1, 0)
I.turret(victim, 2, 3, "none", "xp-test-device")
local packet = messages[#messages].args
check(#starts==1 and packet.xpToken~=nil, "Known owner gets one server-issued injury receipt")
I.acknowledge("OMHTT_InjuryV1","Applied",stranger,{token=packet.xpToken,injured=true})
I.acknowledge("OMHTT_InjuryV1","Applied",victim,{token="invented",injured=true})
I.acknowledge("OMHTT_InjuryV1","Applied",victim,{token=packet.xpToken,injured=1})
check(#finishes==0,"Wrong sender, invented token and malformed result cannot claim XP")
I.acknowledge("OMHTT_InjuryV1","Applied",victim,{token=packet.xpToken,injured=true,owner="Forged",xp=999999})
check(#finishes==1 and finishes[1].owner=="Owner" and finishes[1].injured,"Receipt uses server owner, ignores client payout and owner")
I.acknowledge("OMHTT_InjuryV1","Applied",victim,{token=packet.xpToken,injured=true})
check(#finishes==1,"Repeated injury receipt settles only once")
I.poke(victim,"cut","xp-test-device")
packet = messages[#messages].args
now = now + 5001
I.acknowledge("OMHTT_InjuryV1","Applied",victim,{token=packet.xpToken,injured=true})
check(#finishes==2 and not finishes[2].injured,"Expired receipt cannot confirm defense damage")
I.poke(victim,"scratch","unknown")
check(messages[#messages].args.xpToken==nil,"Unknown legacy ownership never guesses a nearby player")
OMHTS_DefenseCredit = nil
I.turret(victim,2,3,"none","xp-test-device")
check(messages[#messages].args.xpToken==nil,"Trait Shop absence keeps damage independent with no XP receipt")
-- Exercise the receiving half with real production command filtering and deduplication.
testMode = "client"
local health, replies = 100, {}
local part={AddDamage=function(_,value) health=health-value end}
victim.getBodyDamage=function() return {getBodyPart=function() return part end} end
victim.setAttackedBy=function(_, value) victim.attacker=value end
BodyPartType={FromIndex=function(i) return i end,ForeArm_L=2,ForeArm_R=3,UpperLeg_L=11,UpperLeg_R=12}
getSpecificPlayer=function(i) if i==0 then return victim end end
getActivatedMods=function() return {contains=function(_,id) return id=="OneMoreHorde_TraitShop" end} end
__modules.OMHTS_InjuryEvidence={capture=function() return health end,injured=function(a,b) return b<a end}
sendClientCommand=function(player,module,command,args) replies[#replies+1]=args end
local clientPacket={id=77,serial=100000,session="xp-test",part=2,amount=3,wound="none",xpToken="receipt"}
I.receive("OMHTT_InjuryV1","turret",clientPacket)
I.receive("OMHTT_InjuryV1","turret",clientPacket)
check(health==97 and #replies==1 and replies[1].injured,"Client applies and acknowledges one confirmed injury")
clientPacket.serial=100001;clientPacket.id=78
I.receive("OMHTT_InjuryV1","turret",clientPacket)
check(health==97 and #replies==1,"Injury for another online character is ignored")
testMode,OMHTS_DefenseCredit,sendServerCommand,getTimestampMs=old.mode,old.credit,old.send,old.time
sendClientCommand,getSpecificPlayer,getActivatedMods,BodyPartType=old.client,old.players,old.mods,old.parts
__modules.OMHTS_InjuryEvidence=old.evidence
