local Capacity = require("OMHTT/TurretAmmoCapacity")
local settings = SandboxVars.OMHTurretsTraps
SandboxVars.OMHTurretsTraps = {PotatoAmmoCapacity=-1,FirearmAmmoCapacity=-1,
    CapacityImprovisedAmmoBonus=-1,CapacitySmallAmmoBonus=-1,CapacityAmmoBonus=-1,CapacityLargeAmmoBonus=-1}
local rows = {Potato={75,187,375,562,750},Ballista={30,75,150,225,300},
    Lobber={35,87,175,262,350},Scrapshot={90,225,450,675,900},
    Firearm={400,1000,2000,3000,4000},Shotgun={80,200,400,600,800}}
for name,row in pairs(rows) do
    for tier=0,4 do
        local active={}
        if tier>0 then active[Capacity.kits[tier]]=1 end
        check(Capacity.resolve(name,active,1)==row[tier+1],"Approved fresh-world "..name.." tier "..tier)
    end
end
check(string.find(Capacity.description(2,8),"8 Module Slots / 5x",1,true)~=nil,"Kit tooltip uses total slots and the effective multiplier")
SandboxVars.OMHTurretsTraps.AmmoBaseFirearm=123
SandboxVars.OMHTurretsTraps.AmmoSmallMultiplier=3.25
check(Capacity.resolve("Firearm",{CapacitySmall=1},1)==399,"Configured fractional capacity floors only at the final count")
SandboxVars.OMHTurretsTraps={PotatoAmmoCapacity=123,CapacitySmallAmmoBonus=100}
check(Capacity.legacy() and Capacity.resolve("Potato",{CapacitySmall=1},123)==323,"Saved legacy base and half bonus retain exact units")
SandboxVars.OMHTurretsTraps={CapacitySmallAmmoBonus=100,PotatoAmmoCapacity=-1}
check(Capacity.resolve("Potato",{CapacitySmall=1},1)==300,"Partial legacy settings retain the historical omitted base")
SandboxVars.OMHTurretsTraps.AmmoUseMultipliers=true
check(not Capacity.legacy() and Capacity.resolve("Potato",{CapacitySmall=1},1)==375
    and SandboxVars.OMHTurretsTraps.CapacitySmallAmmoBonus==100,"Opt-in changes the resolver without rewriting saved tuning")
SandboxVars.OMHTurretsTraps=settings

local Audio=require("OMHTT/ControlMenuAudio")
local oldMode,oldSound,oldCommand=testMode,getSoundManager,sendServerCommand
local sounds,commands=0,0
getSoundManager=function() return {playUISound=function(_,name) check(name=="UIActivateButton","Equipment uses native local UI sound");sounds=sounds+1 end} end
sendServerCommand=function(player,module,command,args) commands=commands+1;check(module=="OMHTTMenuAudio" and command=="Confirmed","Server sends only the fixed success cue") end
testMode="sp";Audio.confirm({});check(sounds==1 and commands==0,"SP completed equipment operation plays once")
testMode="server";Audio.confirm({});check(sounds==1 and commands==1,"Dedicated authority never plays local UI audio")
testMode="client";Audio.confirm({});Audio.receive("OtherMod","Confirmed",{});check(sounds==1,"Client prediction and unrelated packets are silent")
Audio.receive("OMHTTMenuAudio","Confirmed",{});check(sounds==2,"Recipient plays confirmed transfer cue")
testMode,getSoundManager,sendServerCommand=oldMode,oldSound,oldCommand

local Endurance=require("OMHTT/ControlEndurance")
local Battery=require("OMHTT/TurretBattery")
local oldClock,oldMillis,oldCharge=getGameTime,testMillis,Battery.charge
local hours,reads=100,0
getGameTime=function() return {getWorldAgeHours=function() return hours end} end
Battery.charge=function(item) return item.charge end
local values={}
for i=1,96 do values[i]={charge=.5,getFullType=function() return "Base.CarBattery1" end,getCondition=function() return 100 end} end
local storage={getItems=function() return {size=function() return #values end,get=function(_,i) reads=reads+1;return values[i+1] end} end}
local object={getContainer=function() return storage end}
local state={powerRate=9,powerSampleHours=hours}
Endurance.sample(object,state)
check(reads==32 and state.powerRate==nil and state.powerReserve==nil,"New observation discards stale estimates and bounds first scan")
Endurance.sample(object,state);check(reads==32,"Repeated refresh within one second does not rescan")
Endurance.spend(object,.02);hours=hours+.02;testMillis=testMillis+1001;Endurance.sample(object,state)
check(reads==64 and math.abs(state.powerRate-1)<.000001,"All spend is measured against game time")
testMillis=testMillis+1001;Endurance.sample(object,state)
check(reads==96 and state.powerReserve==48 and state.powerRate==1,"Paused game adds no elapsed draw; all usable reserves are included")
values[1].getCondition=function() return 0 end
for i=1,3 do testMillis=testMillis+1001;Endurance.sample(object,state) end
check(state.powerReserve==47.5,"Broken stored batteries are excluded from reserve estimate")
getGameTime,testMillis,Battery.charge=oldClock,oldMillis,oldCharge

local Legacy=require("OMHTT/ControlLegacyStorage")
local entries,drops,carried={},{},{}
local room,fail=true,false
local source={}
function source:getItems() return {isEmpty=function() return #entries==0 end,get=function(_,i) return entries[i+1] end} end
function source:Remove(item) table.remove(entries,1) end
function source:AddItem(item) table.insert(entries,1,item);return item end
local inventory={isItemAllowed=function() return true end,hasRoomFor=function() return room end,
    AddItem=function(_,item) carried[#carried+1]=item;return item end}
local square={AddWorldInventoryItem=function(_,item) if fail then return nil end;drops[#drops+1]=item;return {} end}
local device={getContainer=function() return source end,getSquare=function() return square end}
local player={getInventory=function() return inventory end}
testMode="sp"
local first,second={},{}
entries={first};check(Legacy.recover(player,device) and carried[1]==first,"Poke legacy contents return as exact original items")
entries={second};room=false;fail=true
check(not Legacy.recover(player,device) and entries[1]==second and #drops==0,"Failed world delivery retains the original legacy item")
fail=false;check(Legacy.recover(player,device) and drops[1]==second,"Full inventory recovers legacy contents to the floor")
for i=1,65 do entries[i]={} end
check(not Legacy.recover(player,device) and #entries==1,"Recovery has a bounded 64-item slice without loss")
check(Legacy.recover(player,device) and #entries==0,"Retry completes any unusually large legacy contents")
testMode=oldMode
print("[OMHTT-C450] ammo30=pass legacy=preserved confirmed-audio=pass bounded-game-clock-estimates=pass exact-legacy-recovery=pass")
