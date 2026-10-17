-- Read-only reproductions against the unchanged 0.2.53.3 production modules.
local A = require("OMHTT/ControlAccess")
local T = require("OMHTT/Turret")
local U = require("OMHTT/ControlClient")
local Transfer = require("OMHTT/ControlTransferAction")
local Entry = require("OMHTT/ControlNameEntry")
local Panel = require("OMHTT/ControlPanel")
local Manage = require("OMHTT/ControlManage")
local saved = {mode=testMode, state=A.state, near=A.near, contents=T.contents, authorized=A.authorized,
    panel=ISPanel, queue=ISTimedActionQueue.add, clock=getTimestampMs, access=require("OMHTT/TurretAccess").near}
testMode = "client"
A.state = function(object) return object and object.state end
A.near = function() return true end
A.authorized = function() return true end
local player = {getUsername=function() return "audit-owner" end, isDead=function() return false end}
local inventory = {hasRoomFor=function() return true end, AddItem=function(self,item) self.received=item; item.container=self; return item end}
player.getInventory = function() return inventory end
local backpack = {getType=function() return "backpack" end, getContainingItem=function() return {getFullType=function() return "Base.Bag_Schoolbag" end} end}
local storage = {getType=function() return "OMHTTController" end, getCapacityWeight=function() return 0 end,
    getContainingItem=function() return nil end,
    contains=function(self,item) return item.container==self end, isRemoveItemAllowed=function() return true end,
    Remove=function(self,item) item.container=nil end}
local controller = {state={id="audit-controller",kind="Controller",owner="audit-owner",powered=true},
    hasModData=function() return false end,
    getContainer=function() return storage end, getSquare=function() return {} end}
storage.getParent = function() return controller end
local item = {container=storage,getFullType=function() return "Base.OMHTTModuleRange" end}
item.getContainer = function(self) return self.container end
local action = ISInventoryTransferAction:new(player,item,storage,backpack,5)
check(action.Type==Transfer.Type, "Native transfer must reach the Controller adapter")
testMode="sp"
check(action:complete() and inventory.received==item and item.container~=backpack,
    "C292 reproduction changed: stockpile withdrawal no longer discards selected backpack")
print("C292 FINDING stockpile destination: requested backpack, received main inventory")
check(action.setOnComplete==nil, "C292 callback gap no longer reproduces")
print("C292 FINDING stockpile callback: replacement lacks native setOnComplete")

testMode="client"
ISPanel=testControlPanelBase
local headName="Potato Launcher"
local scans=0
T.contents=function() scans=scans+1; return {head={getDisplayName=function() return headName end}} end
local turret={state={id="audit-turret",kind="Turret",owner="audit-owner"},getContainer=function() return storage end}
local owner=ISPanel:new(0,0,780,600)
owner.player=player
local entry=Entry.create(owner,turret,0,0,400,28)
check(entry.placeholder=="Potato Launcher", "Initial automatic name fixture failed")
headName="Ballista Head"
entry:refresh()
check(entry.placeholder=="Potato Launcher" and U.name(turret,true)=="Ballista Head",
    "C292 reproduction changed: unassigned head placeholder now refreshes")
print("C292 FINDING automatic name: stale Potato Launcher placeholder after Ballista swap")

scans=0
local rows={items={},clear=function(self) self.items={} end,addItem=function(self,name,object) self.items[#self.items+1]={name=name,item=object} end}
local panel=setmetatable({object=controller,scanIndex=1681,scanResults={},devices=rows},{__index=Panel})
for i=1,32 do panel.scanResults[i]=turret end
panel:scan()
check(scans==32 and #rows.items==32, "C292 Controller scan finalization changed")
print("C292 FINDING Controller list: 32 full inventory summaries in one finalization call, outside its scan budget")

local queued={}
ISTimedActionQueue.add=function(value) queued[#queued+1]=value end
require("OMHTT/TurretAccess").near=function() return true end
local now=0
getTimestampMs=function() return now end
turret.state.controller=controller.state.id
local remote={controller=controller,object=turret,player=player,powerButton={setEnable=function() end},nameEntry={refresh=function() end}}
for i=1,60 do now=i*5000; Manage.refresh(remote) end
check(#queued==60 and queued[1].command=="Remote" and queued[60].command=="Remote",
    "C292 queued-renewal reproduction changed")
print("C292 FINDING remote heartbeat: 60 queued renewals over simulated five minutes without queue progress")

testMode,A.state,A.near,T.contents,A.authorized,ISPanel,ISTimedActionQueue.add,getTimestampMs = saved.mode,saved.state,saved.near,saved.contents,saved.authorized,saved.panel,saved.queue,saved.clock
require("OMHTT/TurretAccess").near=saved.access
testPackAudit="C292: five adverse-path reproductions confirmed; production unchanged"
