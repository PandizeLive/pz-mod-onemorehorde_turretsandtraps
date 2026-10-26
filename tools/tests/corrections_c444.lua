-- Regression coverage for first-copy tuning, inactive storage, and transactional kit replacement.
local T = require("OMHTT/Turret")
local S = require("OMHTT/TurretStats")
local Stack = require("OMHTT/TurretStacking")
local A = require("OMHTT/TurretExpansionAction")
local Access = require("OMHTT/TurretAccess")
local ControlAccess = require("OMHTT/ControlAccess")
local W = require("OMHTT/TurretWorld")
local old = {settings = SandboxVars.OMHTurretsTraps, mode = testMode, near = Access.near,
    stock = ControlAccess.stockpile, refresh = W.refresh, transfer = ISTransferAction}
ISTransferAction = {removeItemOnCharacter=function() end}
SandboxVars.OMHTurretsTraps = {}
testMode = "sp"
local selected = {RapidFire={40,340}, Reload={50,425}, Velocity={30,255}, Range={3,18},
    Magazine={50,425}, Accuracy={10,70}, Critical={15,90}, InitialBlow={50,350},
    Fragment={25,85}, Execute={18,48}, Impact={60,90}, Conservation={1,8.5},
    Regulator={.25,4}, Siphon={2,9.5}, Martyrdom={1.5,3.75}, Tack={1.25,3.5}}
for name, row in pairs(selected) do
    check(Stack.bonus({},name)==0, name.." contributes nothing without an active copy")
    check(math.abs(Stack.bonus({[name]=1},name)-row[1])<.000001, name.." selected first copy")
    check(math.abs(Stack.bonus({[name]=16},name)-row[2])<.000001, name.." selected additive sixteen-copy endpoint")
end
local stats = S.resolve({active={RapidFire=16,Velocity=16,Range=16,Conservation=16}})
local base = S.resolve()
check(math.abs(stats.cooldown-base.cooldown/4.4)<.000001 and math.abs(stats.damage/base.damage-3.55)<.000001
    and stats.range==base.range+18 and stats.conservation==9.5, "Selected endpoints reach runtime without old bonus/firing/range ceilings")
local debt, paid = {}, 0
for i=1,95 do
    paid=paid+require("OMHTT/TurretConservation").consume(debt,1,9.5)
    if i==47 then debt=nativeRoundTrip(debt) end
end
check(paid==10 and math.abs(debt.conservationDebt)<.000001,"Fractional Conservation retains exact ten-round cost over save/restore")
SandboxVars.OMHTurretsTraps.RapidFireBonus=37
check(Stack.bonus({RapidFire=3},"RapidFire")==114,"Existing custom duplicate gain survives first-copy introduction")
SandboxVars.OMHTurretsTraps={PotatoAmmoCapacity=2,CapacitySmallAmmoBonus=0,CapacitySmallModuleBonus=0}
local nextId = 910000
local function item(name)
    nextId=nextId+1
    local v={name=name,id=nextId,condition=100,weight=.2,data={}}
    function v:getFullType() return self.name end
    function v:getID() return self.id end
    function v:getDisplayName() return self.name end
    function v:getCondition() return self.condition end
    function v:getModData() return self.data end
    function v:getActualWeight() return self.weight end
    function v:getUnequippedWeight() return self.weight end
    function v:getContainer() return self.container end
    function v:isFavorite() return self.favorite == true end
    return v
end
local function container(carried)
    local c={items={},carried=carried,room=true}
    function c:getItems() return {size=function() return #self.items end,get=function(_,i) return self.items[i+1] end} end
    function c:getContainingItem() return nil end
    function c:getParent() return self.parent end
    function c:getType() return self.carried and "inventory" or T.CONTAINER end
    function c:isInCharacterInventory() return self.carried end
    function c:contains(v) for i=1,#self.items do if self.items[i]==v then return true end end return false end
    function c:isRemoveItemAllowed(v) return not v.blocked end
    function c:isItemAllowed() return true end
    function c:hasRoomFor() return self.room end
    function c:getCapacity() return 100 end
    function c:getCapacityWeight() local n=0; for i=1,#self.items do n=n+self.items[i].weight end;return n end
    function c:AddItem(v) if self.reject==v then return nil end;self.items[#self.items+1]=v;v.container=self;return v end
    function c:Remove(v) for i=#self.items,1,-1 do if self.items[i]==v then table.remove(self.items,i) end end;v.container=nil end
    return c
end
local refreshed=0
W.refresh=function() refreshed=refreshed+1 end
Access.near=function(_,o,id) return o.reachable~=false and id==o.data.OMHTTTurret.id end
ControlAccess.stockpile=function() return nil end
ISTransferAction.removeItemOnCharacter=function() end
local function fixture(rounds)
    local inventory,storage=container(true),container(false)
    local drops={}
    local square={AddWorldInventoryItem=function(self,v)
        if self.failAt and #drops>=self.failAt then return nil end
        drops[#drops+1]=v;return {item=v}
    end}
    local object={data={OMHTTTurret={schema=1,id="c444"}},getSquare=function() return square end,getContainer=function() return storage end}
    function object:hasModData() return true end
    function object:getModData() return self.data end
    storage.parent=object
    local player={getInventory=function() return inventory end}
    local prior=storage:AddItem(item(T.TYPES.CapacityLarge))
    local incoming=inventory:AddItem(item(T.TYPES.CapacitySmall))
    storage:AddItem(item(T.HEAD))
    local modules={}
    for _,name in pairs({"RapidFire","Reload","Grid","Siphon","Void","Firing","MotionDetection"}) do
        modules[#modules+1]=storage:AddItem(item(T.TYPES[name]))
    end
    T.rememberModules(storage,modules)
    local ammo={}
    for i=1,rounds do ammo[i]=storage:AddItem(item("Base.Potato")) end
    return player,object,storage,inventory,prior,incoming,drops,square,modules,ammo
end
local player,object,storage,inventory,prior,incoming,drops,square,modules,ammo=fixture(27)
local projection,excess=A:new(player,object,incoming,prior,"c444",nil,true):projection()
check(excess==25 and projection.modules==7 and projection.activeCapacity==2,"Kit projection retains stored modules and computes exact excess rounds")
check(projection.active.RapidFire==1 and projection.active.Reload==1 and not projection.active.Grid and not projection.active.Siphon
    and not projection.void and not projection.active.Firing and not projection.active.MotionDetection,"Inactive storage cannot grant power, siphon, virtual ammo or automation")
local expectedLoad=require("OMHTT/TurretRarity").get("RapidFire").surcharge+require("OMHTT/TurretRarity").get("Reload").surcharge
check(projection.powerLoad==expectedLoad,"Only active stored modules contribute battery surcharge")
local final=A:new(player,object,incoming,prior,"c444",nil,true)
check(not final:complete() and storage:contains(prior),"Final exchange cannot discard excess ammunition")
check(A:new(player,object,incoming,prior,"c444",nil,false):complete() and storage:contains(prior)
    and T.contents(storage).reserveAll==7,"First evacuation batch returns at most twenty exact rounds and retains old kit")
check(A:new(player,object,incoming,prior,"c444",nil,false):complete() and final:complete() and not final:complete(),"Remaining batch then exact final exchange; replay rejected")
check(storage:contains(incoming) and inventory:contains(prior) and T.contents(storage).reserveAll==2,"Exact old kit returned and new capacity enforced")
for i=3,#ammo do check(inventory:contains(ammo[i]),"Overflow returns original ammunition identity") end
object.data.OMHTTTurret=nativeRoundTrip(object.data.OMHTTTurret)
check(T.moduleOrder(storage)[1]==modules[1] and T.contents(storage).active.Siphon==nil,"Serialized priority preserves inactive selections")
local rarity=require("OMHTT/TurretRarity")
SandboxVars.OMHTurretsTraps.LootRateRapidFire=.05
SandboxVars.OMHTurretsTraps.LootRateSiphon=20
rarity.refresh(SandboxVars.OMHTurretsTraps)
check(T.moduleOrder(storage)[1]==modules[1] and T.contents(storage).active.Siphon==nil,"Changing rarity never reorders activation")
rarity.refresh(SandboxVars.OMHTurretsTraps)
player,object,storage,inventory,prior,incoming=fixture(2)
inventory.reject=prior
check(not A:new(player,object,incoming,prior,"c444",nil,true):complete() and storage:contains(prior)
    and inventory:contains(incoming),"Failed final delivery restores both exact kit endpoints")
inventory.reject=nil; object.reachable=false
check(not A:new(player,object,incoming,prior,"c444",nil,true):complete(),"Changed access rejects queued exchange")
object.reachable=true;incoming.favorite=true
check(not A:new(player,object,incoming,prior,"c444",nil,true):complete(),"Favorite kit is protected")
player,object,storage,inventory,prior,incoming,drops,square=fixture(9)
inventory.room=false;square.failAt=2
local before=refreshed
check(not A:new(player,object,incoming,prior,"c444",nil,false):complete() and #drops==2
    and T.contents(storage).reserveAll==7 and refreshed==before+1,"Partial floor failure retains all rounds and publishes completed moves")
square.failAt=nil
check(A:new(player,object,incoming,prior,"c444",nil,false):complete() and A:new(player,object,incoming,prior,"c444",nil,true):complete()
    and #drops==8 and drops[#drops]==prior,"Full inventory sends excess rounds and exact replaced kit to floor")
testMode="client"
check(not A:new(player,object,prior,incoming,"c444",nil,true):complete(),"Client cannot originate inventory exchange")
testMode=old.mode;SandboxVars.OMHTurretsTraps=old.settings
Access.near,ControlAccess.stockpile,W.refresh,ISTransferAction=old.near,old.stock,old.refresh,old.transfer
rarity.refresh(old.settings)
local previousCell=getCell
local queried=0
local empty={getMovingObjects=function() return {size=function() return 0 end} end}
getCell=function() return {getGridSquare=function(_,x,y)
    queried=queried+1
    return math.abs(x)<=1 and math.abs(y)<=1 and empty or nil
end} end
local origin={getX=function() return 0 end,getY=function() return 0 end,getZ=function() return 0 end}
local Auto=require("OMHTT/TurretAutomation")
local job=Auto.scan(origin,{range=7809})
local slices=0
repeat
    slices=slices+1
    check(slices<=4,"Uncapped acquisition exits a completely unloaded surrounding boundary")
until Auto.advance(job,7,getTimestampMs()+100000)
check(queried==25,"Huge custom range visits only the loaded island and its immediate empty boundary")
getCell=previousCell
print("[OMHTT-C444] selected tuning=pass fractional-debt=pass inactive-effects=absent kit-exchange=exact overflow=bounded rollback=pass authority=pass")
