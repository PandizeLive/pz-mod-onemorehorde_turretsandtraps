if not isServer() then return end
local P = require("OMHTT/DefenseCombatProtocol")
local Actors = require("OMHTT/DefenseActors")
local Contacts = require("OMHTT/DefenseContacts")
local H = require("OMHTT/DefenseHorde")
local D = require("OMHTT/Diagnostics")
local S = {}
local history = setmetatable({}, {__mode="k"})
local budgets = setmetatable({}, {__mode="k"})
local createdAt = setmetatable({}, {__mode="k"})

function S.command(module,command,player,frames)
    if module~="OMHTT_ContactV1" or command~="Observe" or not player or player:isDead()
        or type(frames)~="table" or #frames>32 then return end
    local now=getTimestampMs()
    local budget=budgets[player]
    if not budget or now-budget.at>=1000 then budget={at=now,count=0};budgets[player]=budget end
    if budget.count+#frames>8192 then D.count("owner-contact-rate-limited",#frames,"traps");return end
    budget.count=budget.count+#frames
    for i=1,#frames do S.observe(player,frames[i],now) end
end

function S.observe(player,f,now)
    if type(f)~="table" or not P.identity(f.id) or not P.identity(f.outfit)
        or not P.number(f.sequence,1,1000000000000) or f.sequence~=math.floor(f.sequence)
        or not P.number(f.x,-1000000,1000000) or not P.number(f.y,-1000000,1000000)
        or not P.number(f.z,-32,32) or f.z~=math.floor(f.z) or not P.number(f.age,0,250)
        or not P.number(f.observedAt,1,1000000000000000)
        or type(f.prone)~="boolean" or type(f.down)~="boolean" or type(f.landing)~="boolean" then return end
    local transitAge = GameTime.getServerTimeMills() - f.observedAt
    if transitAge < -100 or transitAge > 500 then D.count("owner-contact-stale",1,"traps");return end
    local zombie=Actors.online[f.id]
    if not P.living(zombie) or P.outfit(zombie:getPersistentOutfitID())~=f.outfit
        or not zombie:getOwner()
        or zombie:getOwnerPlayer() ~= player or not H.allowed(zombie)
        or math.floor(zombie:getZ())~=f.z or (zombie:getX()-f.x)^2+(zombie:getY()-f.y)^2>4 then return end
    if createdAt[zombie] and f.observedAt<createdAt[zombie] then return end
    local old=history[zombie]
    local same=old and old.owner==player and old.connection==zombie:getOwner() and old.outfit==f.outfit
    if same and (f.sequence<=old.sequence or f.observedAt<old.frame.at) then return end
    local frame={x=f.x,y=f.y,z=f.z,at=f.observedAt,prone=f.prone,down=f.down,landing=f.landing,ownerReport=true}
    history[zombie]={owner=player,connection=zombie:getOwner(),outfit=f.outfit,sequence=f.sequence,frame=frame}
    Contacts.observe(zombie,frame,same and old.frame or nil,true)
    D.count("owner-contact-accepted",1,"traps")
    D.measure("owner-contact-transit",math.max(0,transitAge),"traps")
end

function S.created(zombie)
    history[zombie]=nil
    createdAt[zombie]=GameTime.getServerTimeMills()
end

Events.OnClientCommand.Add(S.command)
Events.OnZombieCreate.Add(S.created)
return S
