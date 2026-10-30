local S,C,P=require("OMHTT/DefenseCombatServer"),require("OMHTT/DefenseCombatClient"),require("OMHTT/DefenseCombatProtocol")
local client,server=actor(19),actor(19)
testMode="client"; C.created(client); testMode="server"
local packets,legs={},0
function sendServerCommand(_,module,command,message) packets[#packets+1]={side="client",command=command,message=nativeRoundTrip(message)};legs=legs+1 end
function sendClientCommand(_,module,command,message) packets[#packets+1]={side="server",command=command,message=nativeRoundTrip(message)};legs=legs+1 end
local started,finished,hurt=testMillis,nil,nil
S.request(server,.45,"poke-1","poke-floor",function(loss) check(math.abs(loss-.45)<.00001,"confirmed loss");finished=testMillis end)
for i=1,8 do
 local packet=table.remove(packets,1)
 if not packet then break end
 testMillis=testMillis+testDelayMs -- controlled transport/scheduling delay, not measured internet ping
 testMode=packet.side
 if isClient() then C.command(P.MODULE,packet.command,packet.message)
 else S.command(P.MODULE,packet.command,player,packet.message) end
 if not hurt and client.health<1 then hurt=testMillis end
end
check(finished~=nil,"transaction finished")
check(math.abs(server.health-.55)<.00001,"server and owner agree")
if testDamageViewAt then check(testDamageViewAt==hurt,"owner damage display occurs at health application without acknowledgement round trip") end
print("PATH_RESULT legs="..legs.." ownerDamageMs="..(hurt-started).." settledMs="..(finished-started))
