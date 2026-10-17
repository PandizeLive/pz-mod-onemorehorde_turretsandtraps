local A = require("OMHTT/ControlAccess")
local oldMode,oldNear,oldPlayer = testMode,A.near,getSpecificPlayer
local oldActual,oldDragging = ISInventoryPane.getActualItems,ISMouseDrag.dragging
testMode="client"
local nearby=true
A.near=function() return nearby end
local player={getUsername=function() return "stock-owner" end,isDead=function() return false end,getAccessLevel=function() return "" end}
getSpecificPlayer=function() return player end
local storage={weight=150,getType=function() return "OMHTTController" end}
function storage:getCapacityWeight() return self.weight end
local host={data={OMHTTControl={kind="Controller",id="stock",owner="stock-owner",access="Private"}}}
function host:hasModData() return true end
function host:getModData() return self.data end
function host:getContainer() return storage end
function storage:getParent() return host end
local source={getType=function() return "inventory" end,contains=function() return true end,isRemoveItemAllowed=function() return true end,isInCharacterInventory=function() return true end}
local function item(weight)
    local value={weight=weight,favorite=false,fullType="Base.OMHTTModuleRange"}
    function value:getFullType() return self.fullType end
    function value:getDisplayCategory() return "Clothing" end
    function value:getContainer() return source end
    function value:isFavorite() return self.favorite end
    function value:getUnequippedWeight() return self.weight end
    return value
end
local one,two=item(200),item(200)
local junk=item(1)
junk.fullType="Base.Shirt_FormalWhite"
check(not require("OMHTT/ControlTransferAction").canStore(player,host,junk), "Unrelated clothing cannot enter the stockpile")
check(not require("OMHTT/ControlDefinitions").accept(storage,junk), "Native acceptance also rejects unrelated supplies")

ISMouseDrag.dragging={one,two}
ISInventoryPane.getActualItems=function(items) return items end
local pane={inventory=storage,player=0}
check(ISInventoryPane.canPutIn(pane),"Native stockpile drag admits authorized items above ordinary 100-weight capacity")
check(ISInventoryPage.canPutIn({mouseOverButton={inventory=storage},player=0}),"Container-button drops use the stockpile limit")
check(ISInventoryPaneContextMenu.hasRoomForAny(player,storage,{one}),"Native Move To context menu uses the stockpile limit")
local preview={mouseOverContainer=storage,mouseOverItemCount=1,playerNum=0,items={one,two},itemNotOK={}}
ISInventoryPaneDraggedItems.update(preview)
check(not preview.itemNotOK[one] and preview.itemNotOK[two],"Native drag preview budgets the entire selected batch against 500")
storage.weight=500
check(not ISInventoryPane.canPutIn(pane),"Full stockpile rejects native drag admission")
ISInventoryPaneDraggedItems.update(preview)
check(preview.itemNotOK[one] and preview.itemNotOK[two],"Changed capacity invalidates cached preview")
storage.weight=150
one.favorite,two.favorite=true,true
check(not ISInventoryPane.canPutIn(pane),"Native stockpile keeps favorite protection")
one.favorite,two.favorite=false,false
nearby=false
check(not ISInventoryPane.canPutIn(pane),"Native stockpile rejects a distant operator")
nearby=true
host.data.OMHTTControl.owner="another-owner"
check(not ISInventoryPane.canPutIn(pane),"Read access does not allow native stockpile writes")
check(not ISInventoryPage.canPutIn({mouseOverButton={inventory=storage},player=0})
    and not ISInventoryPaneContextMenu.hasRoomForAny(player,storage,{one}),"Native container-button and context writes retain private ownership")
ISInventoryPaneDraggedItems.update(preview)
check(preview.itemNotOK[one] and preview.itemNotOK[two],"Permission change invalidates preview")
local page={inventoryPane={inventory=storage}}
ISInventoryPage.update(page)
check(page.capacity==500,"Native page update preserves the real stockpile limit")
local ordinary={getType=function() return "crate" end}
check(ISInventoryPane.canPutIn({inventory=ordinary})=="native-admission","Ordinary containers keep native drag admission")
page.inventoryPane.inventory=ordinary
ISInventoryPage.update(page)
check(page.capacity==100,"Switching to another container restores its native capacity display")
testMode,A.near,getSpecificPlayer=oldMode,oldNear,oldPlayer
ISInventoryPane.getActualItems,ISMouseDrag.dragging=oldActual,oldDragging
