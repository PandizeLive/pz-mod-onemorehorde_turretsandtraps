local Wing = require("OMHTT/ControlStockpilePane")
local storage={dirty=true,values={}}
function storage:getItems() return {size=function() return #(self.values or {}) end,get=function(_,i) return self.values[i+1] end} end
function storage:isDrawDirty() return self.dirty end
function storage:setDrawDirty(value) self.dirty=value end
function storage:requestSync() self.synced=true end
function storage:getCapacityWeight() return 0 end
local owner=ISPanel:new(0,0,1220,720)
owner.lineHeight=20
owner.player={getPlayerNum=function() return 0 end}
owner.object={getContainer=function() return storage end,hasModData=function() return false end}
local wing=Wing.create(owner,764,48,440,650)
local pane=wing.inventoryPane
pane:createChildren()
check(pane.player==0 and pane.inventory==storage and pane.inventoryPage==wing and wing.onCharacter==false,
    "Installed native inventory constructor binds exact stockpile and dedicated parent")
check(pane.nameHeader and pane.typeHeader and pane.contextButton1 and pane.draggedItems and pane.headerHgt,
    "Installed native createChildren supplies real Type/Category headers, contextual controls and drag tracking")
pane:refreshContainer()
for _, width in pairs({280,800,240,720}) do
    pane:setWidth(width)
    pane:setHeight(420)
    pane:onResize()
    check(pane.vscroll.x == width - 17 and pane.vscroll.height == 420
        and pane.vscroll.anchorRight == false and pane.vscroll.anchorBottom == false,
        "Native Stockpile scrollbar follows compact-page and side-pane resizing")
end
check(#pane.itemslist==0 and pane.collapsed and pane.itemindex and storage.dirty==false,
    "Installed native inventory refresh/sort/selection initializes without borrowing the HUD")
local savedPlayers, savedData, savedUpdate = getNumActivePlayers, getPlayerData, ISInventoryPane.update
local hud = ISInventoryPane:new(0,0,300,400,storage,1)
hud.player,hud.inventoryPage,hud.parent=0,wing,wing
hud:initialise();hud:createChildren();hud:refreshContainer()
getNumActivePlayers=function() return 1 end
getPlayerData=function() return {lootInventory={inventoryPane=hud}} end
ISInventoryPane.update=function() end
pane.writable=function() return true end
pane.stockDirty=false
storage.dirty=true
local before=pane.refreshContainerCount
testNativeInventoryRefresh(hud)
check(not storage.dirty and not pane.stockDirty and pane.refreshContainerCount==before,
    "Legacy native refresh consumes the only dirty signal without notifying the stockpile")
storage.dirty=true
hud:refreshContainer()
check(pane.stockDirty and not storage.dirty,"Native-first refresh delivers an independent pending stockpile refresh")
pane:update()
check(pane.refreshContainerCount==before+1 and not pane.stockDirty,"Embedded view rebuilds once after native-first invalidation")
before=hud.refreshContainerCount
storage.dirty=true
pane:refreshContainer()
check(hud.refreshContainerCount==before+1 and not storage.dirty,"Embedded-first refresh also updates the native view")
local otherStorage={isDrawDirty=function() return true end,getItems=storage.getItems,setDrawDirty=storage.setDrawDirty}
hud.inventory=otherStorage;pane.stockDirty=false
hud:refreshContainer()
check(not pane.stockDirty,"Unrelated containers cannot invalidate the stockpile")
hud.inventory=storage
pane.stockDirty=false
for i=1,12 do hud:refreshContainer() end
before=pane.refreshContainerCount
pane:update()
check(pane.refreshContainerCount==before+1,"Repeated refresh notifications coalesce into one embedded rebuild")
before=pane.refreshContainerCount
for i=1,600 do pane:update() end
check(pane.refreshContainerCount==before,"Six hundred unchanged stockpile updates cause no list rebuild")
local function stockItem(name)
    return {kind="InventoryItem",getName=function() return name end,getDisplayName=function() return name end,
        IsFood=function() return false end,isHidden=function() return false end,getUnequippedWeight=function() return 1 end,
        getDisplayCategory=function() return "Material" end,getContainer=function() return storage end}
end
local alpha,beta=stockItem("Alpha"),stockItem("Beta")
storage.values={alpha};storage.dirty=true;hud:refreshContainer();pane:update()
check(pane.itemslist[1].items[1]==alpha and hud.itemslist[1].items[1]==alpha,"Native transfer refresh displays the same exact item in both lists")
local dragged={beta};pane.draggedItems.items=dragged
storage.values={beta};storage.dirty=true;pane:refreshContainer()
check(pane.itemslist[1].items[1]==beta and hud.itemslist[1].items[1]==beta and pane.draggedItems.items==dragged,
    "Same-count item replacement updates both native lists without resetting drag identity")
storage.values={};storage.dirty=true;triggerEvent("OnContainerUpdate");pane:update()
check(#pane.itemslist==0 and #hud.itemslist==0,"Native container notification removes stale rows from both views")
local secondWing=Wing.create(owner,10,10,440,650)
local second=secondWing.inventoryPane;second:createChildren();second.writable=function() return true end
second:update();pane:update()
storage.dirty=true;hud:refreshContainer();pane:update();second:update()
local firstCount,secondCount=pane.refreshContainerCount,second.refreshContainerCount
for i=1,600 do pane:update();second:update() end
check(pane.refreshContainerCount==firstCount and second.refreshContainerCount==secondCount,"Two embedded views do not continually invalidate each other")
secondWing:close()
pane:setVisible(false);hud:refreshContainer();before=pane.refreshContainerCount
pane:update()
check(pane.stockDirty and pane.refreshContainerCount==before,"Hidden stockpile defers its pending update")
pane:setVisible(true);pane:update()
check(not pane.stockDirty and pane.refreshContainerCount==before+1,"Reopened stockpile consumes pending invalidation")
getNumActivePlayers,getPlayerData,ISInventoryPane.update=savedPlayers,savedData,savedUpdate
wing:prerender()
pane.selected={};pane.items={}
pane:cleanup()
check(pane.dragging==nil and pane.draggedItems.items==nil,"Dedicated pane releases native drag state on close")
wing:close()
check(wing.visible==false and storage.synced,"Native component uses replicated stockpile and closes independently")
getCore,getTextManager,ISPanel,ISButton,ISInventoryPane=testC300UI.core,testC300UI.text,testC300UI.panel,testC300UI.button,testC300UI.pane
getTexture,getSpecificPlayer,getPlayerHotbar,testMode,ISResizableButton=testC300UI.texture,testC300UI.player,testC300UI.hotbar,testC300UI.mode,testC300UI.resizable

getNumActivePlayers,getPlayerData=testC300UI.players,testC300UI.data
