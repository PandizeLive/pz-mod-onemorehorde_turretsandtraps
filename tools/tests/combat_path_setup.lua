__modules = {}
if not math.min then function math.min(a,b) if a<b then return a end return b end end
if not math.max then function math.max(a,b) if a>b then return a end return b end end
function print(value) scenarioResult=value end
pairs = table.pairs
testMode, testMillis, testAssertions = "server", 1000, 0
function isServer() return testMode == "server" end
function isClient() return testMode == "client" end
function getTimestampMs() return testMillis end
GameTime={getServerTimeMills=function() return testMillis end}
function require(name) if not __modules[name] then error(name) end; return __modules[name] end
function check(ok, message) testAssertions=testAssertions+1; if not ok then error(message) end end
Events = {}
for _, name in pairs({"OnClientCommand","OnServerCommand","OnTick","OnZombieCreate","OnZombieDead","OnZombieUpdate"}) do Events[name]={Add=function() end} end
function triggerEvent() end
__modules["OMHTT/Diagnostics"]={count=function() end,defer=function() end}
__modules["OMHTT/DamageNotice"]={capture=function() return {} end,send=function() end}
__modules["OMHTT/DefenseXP"]={lethal=function() end}
__modules["OMHTT/Foundation"]={}
player={getOnlineID=function() return 7 end,isDead=function() return false end}
function getSpecificPlayer(i) if i==0 then return player end end
function actor(id)
 local z={id=id,health=1,owner=player}
 function z:getOnlineID() return self.id end
 function z:getPersistentOutfitID() return self.id end
 function z:getOwnerPlayer() return self.owner end
 function z:getOwner() return self.owner end
 function z:isDead() return self.health<=0 end
 function z:isInvulnerable() return false end
 function z:isReanimatedForGrappleOnly() return self.corpseProxy==true end
 function z:isRemoteZombie() return self.remote==true end
 function z:getHealth() return self.health end
 function z:setHealth(h) self.health=h end
 function z:getX() return 10 end
 function z:getY() return 10 end
 function z:getZ() return 0 end
 function z:getSquare() return {} end
 function z:getModData() return {} end
 function z:Kill() self.health=0;self.killed=true end
 function z:die() self.deathDone=true end
 function z:isOnDeathDone() return self.deathDone==true end
 return z
end
