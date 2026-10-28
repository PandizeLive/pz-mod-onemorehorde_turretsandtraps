local oldTraits=CharacterTrait
CharacterTrait={DEXTROUS="dex",ALL_THUMBS="thumbs"}
local A = require("OMHTT/ControlAccess")
local T = require("OMHTT/Turret")
local Action = require("OMHTT/TurretTransferAction")
local Transfer = require("OMHTT/ControlTransferAction")
local Access = require("OMHTT/TurretAccess")
local old = {state=A.state,near=A.near,range=A.range,ts=T.state,kind=T.kind,remove=T.canRemove,
    enabled=T.enabled,accept=T.accepts,mode=testMode,clock=testMillis,perform=ISBaseTimedAction.perform,stop=ISBaseTimedAction.stop}
testMode="client"
A.state=function(o) return o and o.state end
A.near=function(p,o) return o and o.nearby==true end
A.range=function(a,b) return b.inRange~=false end
T.state=function(o) return o and o.turret end
T.enabled=function() return true end
T.canRemove=function() return not testC300Servicing end
T.accepts=function() return true end
local player={getUsername=function() return "owner" end,getAccessLevel=function() return "None" end,
    isDead=function() return false end,hasTrait=function() return false end,isWearingAwkwardGloves=function() return false end}
local function container(kind)
    local c={kind=kind,weight=0,room=true,allowed=true}
    function c:getType() return self.kind end
    function c:getParent() return self.parent end
    function c:getCapacityWeight() return self.weight end
    function c:contains(item) return item.container==self end
    function c:isRemoveItemAllowed() return self.allowed end
    function c:isItemAllowed() return self.allowed end
    function c:isInCharacterInventory() return self.kind=="inventory" end
    function c:hasRoomFor() return self.room end
    function c:getContainingItem() return nil end
    function c:getItemWithID(id) return self.received end
    return c
end
local carried,stock,store=container("inventory"),container("OMHTTController"),container("OMHTTTurret")
player.getInventory=function() return carried end
local function device(c,kind)
    local d={nearby=true,state={kind=kind,id=kind,owner="owner",access="Private",powered=false},turret={id="turret"}}
    function d:getContainer() return c end
    function d:getHealth() return 100 end
    function d:getObjectIndex() return 0 end
    c.parent=d
    return d
end
local host,turret=device(stock,"Controller"),device(store,"Turret")
local item={container=stock,getFullType=function() return "Base.OMHTTTurretBallista" end,getID=function() return 93 end,
    getActualWeight=function() return 1 end,getUnequippedWeight=function() return 1 end}
function item:getContainer() return self.container end
function item:isFavorite() return self.favorite==true end
local incoming=Action:new(player,turret,item,true,"turret",nil,nil,false,host)
check(incoming:isValid(),"Nearby stockpile head installs without power or assignment; exact physical reach still required")
local native=ISInventoryTransferAction:new(player,item,stock,store)
check(native.controller==host and native.object==turret and native.incoming and native.setOnComplete,
    "Native stockpile drag retains exact endpoint and native callbacks")
item.container=store
local outgoing=Action:new(player,turret,item,false,"turret",nil,nil,true,host)
check(outgoing:isValid() and outgoing:destination()==stock and Transfer.canStore(player,host,item),"Manage item can be deposited in exact nearby Stockpile")
stock.weight=500
check(not outgoing:isValid() and not Transfer.canStore(player,host,item),"Both drag admission and completion reject full stockpile")
stock.weight=0
testC300Servicing=true
check(not outgoing:isValid() and not Transfer.canStore(player,host,item),"Stockpile drop cannot bypass servicing/removal restrictions")
testC300Servicing=nil
item.favorite=true
check(not outgoing:isValid(),"Stockpile drop protects favorited installed item")
item.favorite=false
host.state.owner="other"
check(not outgoing:isValid(),"Nearby physical service cannot steal private stockpile access")
host.state.owner="owner"
host.nearby=false
check(not outgoing:isValid(),"Requested distant stockpile never falls back to carried inventory")
host.nearby=true;turret.nearby=false
check(not outgoing:isValid(),"Remote target requires a powered assigned session")
host.state.powered=true;turret.state.controller=host.state.id
A.session(player,host,turret)
check(outgoing:isValid(),"Explicit stockpile matches authorized remote session")
local alternate=device(container("OMHTTController"),"Controller")
alternate.state.id="alternate";alternate.state.powered=true
A.session(player,alternate,turret)
check(not outgoing:isValid(),"Different session endpoint cannot silently redirect exact requested destination")
A.session(player,host,turret)
testMillis=testMillis+16000
check(not outgoing:isValid(),"Expired remote lease rejects transfer at completion")
testMillis=old.clock
turret.nearby=true
ISBaseTimedAction.stop=function() end
outgoing:stop()
check(not outgoing:isValid(),"Cancelled action cannot later complete")
local theme=require("OMHTT/ControlTheme")
local b={backgroundColor={r=0,g=0,b=0,a=1},backgroundColorEnabled={r=0,g=0,b=0,a=1},backgroundColorDisabled={r=0,g=0,b=0,a=1},borderColorEnabled={r=1,g=1,b=1,a=1},borderColorDisabled={r=1,g=0,b=0,a=1}}
function b:setTextureRGBA() end
function b:setBorderRGBA() end
function b:setBackgroundRGBA(r,g,b,a) self.backgroundColor.r,self.backgroundColor.g,self.backgroundColor.b,self.backgroundColor.a=r,g,b,a end
b.setEnable=testC300NativeSetEnable
theme.power(b,true,true)
b:setEnable(true)
check(b.backgroundColor.g>b.backgroundColor.r,"Native enabled-color cache cannot restore black over powered state")
theme.power(b,false,false)
check(b.backgroundColor.r==b.backgroundColor.g and not b.enable,"C494 read-only power is grey while interaction is disabled")
check(theme.off.r==.48 and theme.on.g==.42,"Native mutable setters never corrupt shared theme colors")
theme.button(b);b:setEnable(true)
check(b.backgroundColor.r==theme.surface.r and theme.accent.r==theme.accent.g and theme.accent.g==theme.accent.b,"Neutral grey theme survives native button enable refresh")
A.state,A.near,A.range=old.state,old.near,old.range
T.state,T.kind,T.canRemove,T.enabled,T.accepts=old.ts,old.kind,old.remove,old.enabled,old.accept
testMode,testMillis=old.mode,old.clock
ISBaseTimedAction.perform,ISBaseTimedAction.stop=old.perform,old.stop

CharacterTrait=oldTraits
