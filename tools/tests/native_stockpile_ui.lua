local Wing = require("OMHTT/ControlStockpilePane")
local storage={dirty=true}
function storage:getItems() return {size=function() return 0 end} end
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
wing:prerender()
pane.selected={};pane.items={}
pane:cleanup()
check(pane.dragging==nil and pane.draggedItems.items==nil,"Dedicated pane releases native drag state on close")
wing:close()
check(wing.visible==false and storage.synced,"Native component uses replicated stockpile and closes independently")
getCore,getTextManager,ISPanel,ISButton,ISInventoryPane=testC300UI.core,testC300UI.text,testC300UI.panel,testC300UI.button,testC300UI.pane
getTexture,getSpecificPlayer,getPlayerHotbar,testMode,ISResizableButton=testC300UI.texture,testC300UI.player,testC300UI.hotbar,testC300UI.mode,testC300UI.resizable
