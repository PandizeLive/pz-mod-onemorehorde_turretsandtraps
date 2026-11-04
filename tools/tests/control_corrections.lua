local A = require("OMHTT/ControlAccess")
local T = require("OMHTT/Turret")
local U = require("OMHTT/ControlClient")
local W = require("OMHTT/ControlWorld")
local R = require("OMHTT/ControlRemote")
local Transfer = require("OMHTT/ControlTransferAction")
local Entry = require("OMHTT/ControlNameEntry")
local Panel = require("OMHTT/ControlPanel")
local saved = {mode=testMode, state=A.state, near=A.near, range=A.range, contents=T.contents,
    perform=ISBaseTimedAction.perform, stop=ISBaseTimedAction.stop, names=getItemNameFromFullType,
    player=getSpecificPlayer, client=sendClientCommand, server=sendServerCommand, time=testMillis,
    queue=ISTimedActionQueue.add, panel=ISPanel}
testMode="client"
A.state=function(object) return object and object.state end
A.near=function(player,object) return player.nearby and object.state.kind=="Controller" end
A.range=function(controller,target) return target.inRange end
ISBaseTimedAction.perform=function() end
ISBaseTimedAction.stop=function() end
local player={nearby=true,getUsername=function() return "correction-owner" end,
    getAccessLevel=function() return "None" end,isDead=function() return false end,getPlayerNum=function() return 0 end}
local function container(kind)
    local value={kind=kind,allowed=true,room=true,carried=true}
    function value:getType() return self.kind end
    function value:setCapacity(capacity) self.capacity = capacity end
    function value:getContainingItem() return self.bag end
    function value:getParent() return self.parent end
    function value:contains(item) return item.container==self end
    function value:isRemoveItemAllowed() return true end
    function value:isItemAllowed() return self.allowed end
    function value:hasRoomFor() return self.room end
    function value:getItemWithID(id) return self.received end
    function value:isInCharacterInventory() return self.carried end
    function value:Remove(item) item.container=nil end
    function value:AddItem(item) if self.fail then return nil end; item.container=self; return item end
    return value
end
local inventory,backpack,storage=container("inventory"),container("backpack"),container("OMHTTController")
local bag={kind="InventoryContainer",container=inventory}
function bag:getFullType() return "Base.Bag_Schoolbag" end
function bag:getContainer() return self.container end
function bag:getInventory() return backpack end
backpack.bag=bag
player.getInventory=function() return inventory end
local controller={state={id="correction-host",kind="Controller",owner="correction-owner",powered=true},
    getHealth=function() return 100 end,getObjectIndex=function() return 0 end,
    hasModData=function() return false end,getContainer=function() return storage end}
storage.parent=controller
local item={container=storage,getFullType=function() return "Base.OMHTTModuleRange" end,getID=function() return 42 end}
function item:getContainer() return self.container end
local function withdrawal(destination)
    item.container=storage
    return ISInventoryTransferAction:new(player,item,storage,destination,5)
end
local action=withdrawal(backpack)
check(action.Type==Transfer.Type and action.destinationBag==bag, "Native stockpile transfer retains exact top-level destination bag")
action.action={isStarted=function() return true end}
item.container=nil
check(action:isValid(), "C494 active stockpile withdrawal survives removal replication")
item.container=backpack
check(action:isValid(), "C494 active stockpile withdrawal waits for native Done after addition")
controller.state.owner="someone-else"
check(not action:isValid(), "C494 running stockpile transfer still rejects revoked write access")
controller.state.owner="correction-owner"
action.action=nil
check(not action:isValid(), "C494 queued stockpile withdrawal still validates the exact source")
item.container=storage
local callbacks=0
action:setOnComplete(function(value) callbacks=callbacks+value end,1)
action:perform()
check(callbacks==0 and item.container==storage,"Client cannot announce completion before item arrival")
testMode="sp"
check(action:complete() and item.container==backpack,"Allowed withdrawal honors the selected carried bag")
action:perform(); action:perform()
check(callbacks==1,"Native completion callback runs once after confirmed arrival")
check(not action:complete(),"Repeated completion cannot duplicate an item")
backpack.room=false
check(not withdrawal(backpack):complete() and item.container==storage,"Full selected bag rejects without main-inventory fallback")
backpack.room=true; backpack.allowed=false
check(not withdrawal(backpack):complete(),"Selected bag item restrictions remain enforced")
backpack.allowed=true; bag.container=nil
check(not withdrawal(backpack):complete(),"Bag removed before completion rejects safely")
bag.container=inventory; inventory.carried=false
check(not withdrawal(backpack):complete(),"A bag outside the player's inventory rejects")
inventory.carried=true
check(not withdrawal(container("floor")):complete(),"Unsupported destination never silently substitutes main inventory")
controller.state.owner="someone-else"
check(not withdrawal(backpack):complete(),"Changed controller write access blocks withdrawal")
controller.state.owner="correction-owner"; backpack.fail=true
action=withdrawal(backpack)
action:setOnComplete(function() callbacks=callbacks+1 end)
check(not action:complete() and item.container==storage,"Failed insertion returns exact item to its source")
action:perform()
check(callbacks==1,"Failed insertion never runs follow-up action")
backpack.fail=false
action=withdrawal(backpack)
action:setOnComplete(function() callbacks=callbacks+1 end)
action:stop(); item.container=backpack; action:perform()
check(callbacks==1,"Cancelled transfer cannot run a later callback")
item.container=storage
check(not action:complete(),"Cancelled transfer cannot later mutate inventory")
item.getFullType=function() return "Base.Shirt_FormalWhite" end
check(withdrawal(inventory):complete() and item.container==inventory,"Legacy unrelated item remains recoverable without reopening admission")

testMode="client"
local pending=require("OMHTT/ControlTransferCallbacks")
local tickRemove=Events.OnTick.Remove
Events.OnTick.Remove=function() end
testMillis=testMillis+100
pending.update()
action=withdrawal(backpack)
local received
action:setOnComplete(function(value) received=value end,item)
action:perform()
check(not received and #pending.pending==1,"Late client inventory arrival defers the native callback")
local replicated={getID=function() return 42 end,getContainer=function() return backpack end}
backpack.received=replicated
testMillis=testMillis+100
pending.update()
check(received==replicated and action.item==replicated and #pending.pending==0,
    "Network replacement item is resolved by identity and supplied to the native callback")
backpack.received=nil
action=withdrawal(backpack)
action:setOnComplete(function() callbacks=callbacks+1 end)
action:perform(); action:stop(); testMillis=testMillis+100; pending.update()
check(#pending.pending==0 and callbacks==1,"Cancelled pending callbacks are retired")
action=withdrawal(backpack)
action:setOnComplete(function() callbacks=callbacks+1 end)
action:perform(); testMillis=testMillis+5001; pending.update()
check(#pending.pending==0 and callbacks==1,"Unconfirmed callback expires without opening native UI")
check(not pending.active,"Callback polling detaches when no transfer confirmation is pending")
Events.OnTick.Remove=tickRemove

testMode="client"
ISPanel=testControlPanelBase
getItemNameFromFullType=function(value) return "Name:"..value end
local scans=0
T.contents=function() scans=scans+1; return {} end
local turret={state={id="correction-target",kind="Turret",owner="correction-owner",headType="Base.OMHTTTurretPotato"},inRange=true,
    getHealth=function() return 100 end,getObjectIndex=function() return 0 end}
local parent=ISPanel:new(0,0,780,600); parent.player=player
local entry=Entry.create(parent,turret,0,0,400,28)
check(entry.placeholder=="Name:Base.OMHTTTurretPotato","Automatic placeholder uses published head metadata")
turret.state.headType="Base.OMHTTTurretBallista"; entry:refresh()
check(entry.placeholder=="Name:Base.OMHTTTurretBallista" and scans==0,"Unassigned head swap refreshes name without inventory aggregation")
turret.state.name="West Gate"; entry:refresh()
check(entry:getText()=="West Gate" and U.name(turret)=="West Gate","Head changes preserve custom names")
turret.state.headType="Base"; turret.state.name=nil; entry:refresh()
check(entry.placeholder==getText("UI_OMHTT_TurretBase") and entry:getText()=="","Empty head and cleared custom name use gray automatic fallback")
turret.state.headType="Base.OMHTTTurretBallista"; turret.state.number=3; entry:refresh()
check(entry.placeholder=="Name:Base.OMHTTTurretBallista #3","Controller numbering changes refresh placeholder")

local square=makeSquare(2010,2010,0)
controller.getSquare=function() return square end
local rows={items={{item=controller}},itemheight=30,setScrollHeight=function(self,value) self.scrollHeight=value end}
local panel=setmetatable({object=controller,devices=rows,selected=turret},{__index=Panel})
for i=1,180 do
    local object={state={id="scan-"..i,kind="Turret",owner="correction-owner",headType="Base.OMHTTTurretBallista"},getObjectIndex=function() return 0 end}
    square:AddTileObject(object)
end
square:AddTileObject(turret)
for i=1,120 do
    local before=#(panel.scanResults or {})
    panel:scan()
    if panel.scanIndex then
        check(#panel.scanResults-before<=65 and rows.items==panel.scanResults,"Discovery adds at most 64 entries per slice plus the immediate Controller row")
    else
        break
    end
end
check(not panel.scanIndex and #rows.items==182 and rows.items[rows.selected].item==turret and scans==0,
    "Progressive list completion preserves selected identity with no full inventory scans")

local sent,replies,queued={},{},0
sendClientCommand=function(p,module,command,args) sent[#sent+1]={module=module,command=command,args=args} end
sendServerCommand=function(p,module,command,args) replies[#replies+1]=args end
ISTimedActionQueue.add=function() queued=queued+1 end
getSpecificPlayer=function() return player end
turret.state.controller=controller.state.id
W.objects[controller.state.id],W.objects[turret.state.id]=controller,turret
A.remote[player]=nil; R.requests[player]=nil; R.rates[player]=nil
testMillis=100000
check(U.remote(player,controller,turret) and not A.authorized(player,turret),"Client renewal requests do not manufacture server-confirmed leases")
for i=1,100 do U.remote(player,controller,turret) end
check(#sent==1 and queued==0,"Duplicate windows and render refreshes share one request without timed actions")
local request=sent[1].args
testPackets[#testPackets+1]=request
testMode="server"
R.command(R.MODULE,"Renew",player,request)
check(#replies==1 and replies[1].granted and A.authorized(player,turret),"Server resolves and validates renewal independently of action queue")
testPackets[#testPackets+1]=replies[1]
A.remote[player]=nil; testMode="client"
R.response(R.MODULE,"Renewed",replies[1])
check(A.authorized(player,turret),"Matching current server response enables local remote controls")
controller.state.owner="someone-else"
check(not A.authorized(player,turret,true) and not A.authorized(player,turret),"Ownership change revokes both remote reads and writes")
controller.state.owner="correction-owner"
for i=1,60 do testMillis=testMillis+5000; U.remote(player,controller,turret); U.remote(player,controller,turret) end
check(#sent==61 and queued==0 and #R.requests[player]==1,"Five minutes of stalled actions stays at one request slot with bounded retries")
A.remote[player]=nil
R.response(R.MODULE,"Renewed",replies[1])
check(not A.authorized(player,turret),"Delayed obsolete acknowledgement cannot revive a lease")
testMode="server"; R.rates[player]=nil
request=sent[#sent].args
for i=1,20 do R.command(R.MODULE,"Renew",player,request) end
check(#replies==9,"Server limits renewal floods to eight replies per second")
testMillis=testMillis+1000; controller.state.powered=false
R.command(R.MODULE,"Renew",player,request)
check(not replies[#replies].granted and not A.authorized(player,turret),"Power loss rejects renewal and invalidates existing writes")
controller.state.powered=true; turret.state.controller=nil; testMillis=testMillis+1000
R.command(R.MODULE,"Renew",player,request)
check(not replies[#replies].granted,"Removed assignment rejects stale request")
turret.state.controller=controller.state.id; turret.inRange=false
R.command(R.MODULE,"Renew",player,request)
check(not replies[#replies].granted,"Out-of-range target rejects renewal")
turret.inRange=true; player.nearby=false
R.command(R.MODULE,"Renew",player,request)
check(not replies[#replies].granted,"Distant operator rejects renewal")
player.nearby=true
local before=#replies
R.command(R.MODULE,"Renew",player,{controller=request.controller,target={},serial=1,player=0})
check(#replies==before,"Malformed renewal rejects before object resolution")
testMode="sp"
for i=1,60 do testMillis=testMillis+5000; U.remote(player,controller,turret) end
check(queued==0 and #sent==61,"SP paused UI refreshes cannot accumulate commands or timed actions")
testMillis=testMillis+15001
check(not A.authorized(player,turret),"Closed windows stop refreshing and the lease expires normally")
A.near=function(p,object) return object==turret end
check(A.authorized(player,turret) and A.stockpile(player,turret)==nil,
    "Local turret reach cannot revive a stale remote stockpile lease")
A.session(player,controller,turret)
check(A.stockpile(player,turret)==nil,"A live lease still requires proximity to the controller for stockpile access")

W.objects[controller.state.id],W.objects[turret.state.id]=nil,nil
A.remote[player],R.requests[player],R.rates[player]=nil,nil,nil
testMode,A.state,A.near,A.range,T.contents,ISPanel=saved.mode,saved.state,saved.near,saved.range,saved.contents,saved.panel
ISBaseTimedAction.perform,ISBaseTimedAction.stop,getItemNameFromFullType=saved.perform,saved.stop,saved.names
getSpecificPlayer,sendClientCommand,sendServerCommand,testMillis,ISTimedActionQueue.add=saved.player,saved.client,saved.server,saved.time,saved.queue
testControlCorrections=true
