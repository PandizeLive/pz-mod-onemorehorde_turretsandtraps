local A = require("OMHTT/ControlAccess")
local Panel = require("OMHTT/ControlPanel")
local oldMode, oldNear = testMode, A.near
local oldPanel, oldList, oldButton, oldText = ISPanel, ISScrollingListBox, ISButton, ISTextEntryBox
local oldMarkers = getWorldMarkers
ISPanel, ISScrollingListBox, ISButton, ISTextEntryBox = testControlPanelBase, testControlListBase, testControlButtonBase, testControlTextBase
testMode = "client"
A.near = function() return true end
getWorldMarkers = function() return {addGridSquareMarker = function() return {setScaleCircleTexture = function() end, remove = function() end} end} end
local square = makeSquare(1950, 1950, 0)
local inventory = {getItems = function() return {size = function() return 0 end} end, getCapacityWeight = function() return 0 end, requestSync = function() end}
function inventory:getType() return "OMHTTController" end
local player = {getInventory = function() return inventory end, getUsername = function() return "ui-owner" end, isDead = function() return false end, getPlayerNum = function() return 0 end}
local object = {data = {OMHTTControl = {id = "ui-controller", kind = "Controller", owner = "ui-owner", access = "Private", powered = true, links = {}}}}
function inventory:getParent() return object end
function object:getSquare() return square end
function object:getX() return 1950 end
function object:getY() return 1950 end
function object:getZ() return 0 end
function object:getObjectIndex() return 0 end
function object:getHealth() return 100 end
function object:getMaxHealth() return 100 end
function object:getContainer() return inventory end
function object:hasModData() return true end
function object:getModData() return self.data end
square:AddTileObject(object)
local panel = Panel.open(player, object)
check(panel and panel.scanIndex <= 64, "Opening controller scans at most 64 tiles")
check(panel.name == nil and type(tostring(panel)) == "string" and type(tostring(panel.nameEntry)) == "string",
    "Native UI path formatting never recurses through the name-entry widget")
check(panel.devices.items[1].item == object, "Controller itself remains selectable for ownership")
for i = 1, 30 do panel:prerender() end
check(not panel.scanIndex and #panel.devices.items == 1, "Incremental scan completes without duplicate controller")
check(not panel.nameEntry.visible and not panel.save and panel.policy.enabled and not panel.manage.enabled, "Controller settings are editable without pretending controller is a turret")
check(not panel.source.enabled and not panel.trigger.enabled, "Controller cannot masquerade as a pressure plate")
check(not panel.source.visible and not panel.trigger.visible and not panel.manage.visible,
    "Controller selection hides irrelevant input and turret actions")
check(panel.detailBody.scrollChildren, "Controller enables child scrolling after native instantiation")
panel.detailBody:prerender()
panel.detailBody:render()
for i = 1, #panel.children do
    local child = panel.children[i]
    check(child.x >= 0 and child.y >= 0 and child.x + child.width <= panel.width and child.y + child.height <= panel.height, "Controller control remains inside panel")
end
for i = 1, #panel.detailBody.children do
    local child = panel.detailBody.children[i]
    check(child.x >= 0 and child.x + child.width <= panel.detailBody.width
        and child.y >= 0 and (child.visible == false or child.y + child.height <= panel.detailBody.contentHeight),
        "Controller details fit their scrollable content")
end
local oldInventory,oldLoot=getPlayerInventory,getPlayerLoot
local function nativePage()
    return {inventoryPane={inventory=inventory},backpacks={{inventory=inventory,capacity=100}},refreshBackpacks=ISInventoryPage.refreshBackpacks,
        selectButtonForContainer=function(self,c) self.selected=c end,setVisible=function(self,v) self.visible=v end,
        setPinned=function(self) self.pinned=true end,bringToTop=function(self) self.raised=true end}
end
local carriedPage,lootPage=nativePage(),nativePage()
getPlayerInventory=function() return carriedPage end
getPlayerLoot=function() return lootPage end
panel:stockpile()
panel:stockpile()
check(lootPage.selected==inventory and lootPage.visible and carriedPage.visible and lootPage.capacity==500
    and lootPage.backpacks[1].capacity==500 and not panel.storage, "Stockpile reuses the native inventory and loot panes with its 500-weight display")
local previousMouse=isMouseButtonDown
panel:onMouseDown(12,8)
isMouseButtonDown=function() return false end
panel:update()
check(not panel.moving and not panel.capture, "Controller dragging releases even when a child consumes mouse-up")
isMouseButtonDown=previousMouse
local U = require("OMHTT/ControlClient")
local oldCommand, oldFaction = U.command, Faction
local requested
U.command = function(player, device, command, value) requested = value end
Faction = {getPlayerFaction = function() return nil end}
panel.policy.callback(panel)
check(requested == "Public", "Factionless owner can select public access")
Faction = {getPlayerFaction = function() return {} end}
panel.policy.callback(panel)
check(requested == "Faction", "Faction owner can select faction access")
local oldAuthorized=A.authorized
local writes=0
A.authorized=function() return true end
U.command=function(player,device,command,value) writes=writes+1; requested=value end
local named={hasModData=function() return true end,getModData=function() return {OMHTTControl={kind="Plate",id="plate-name",links={}}} end}
panel.nameEntry:select(named)
panel.nameEntry:refresh()
check(panel.nameEntry:getText()=="" and panel.nameEntry.placeholder==getText("UI_OMHTT_ControlPlate")
    and panel.nameEntry.placeholderColor[1]==.55, "Empty names use a gray native automatic placeholder")
panel.nameEntry:setText("  Front gate  ")
panel.nameEntry:onCommandEntered()
check(requested=="Front gate" and writes==1, "Enter and its ensuing blur submit exactly one trimmed rename")
panel.nameEntry:setText("Back gate")
panel.nameEntry:onLostFocus()
check(requested=="Back gate" and writes==2, "Click-away saves an edited name")
panel.nameEntry:setText("")
panel.nameEntry:onLostFocus()
check(requested=="" and writes==3, "Clearing a name requests automatic naming without an Auto button")
A.authorized=function() return false end
panel.nameEntry:setText("Forbidden")
panel.nameEntry:onLostFocus()
check(writes==3, "Read-only clients cannot submit name edits")
panel.nameEntry:setText("")
panel.nameEntry:select(object)
A.authorized=oldAuthorized
U.command, Faction = oldCommand, oldFaction
panel:close()
check(panel.removed and not require("OMHTT/ControlOverlay").panels[panel], "Controller closes its range/link overlay")
check(lootPage.visible and carriedPage.visible, "Closing Controller leaves native inventory lifetime under player control")
local remoteManage={player=player,controller=object}
Panel.stockpile(remoteManage,object)
check(lootPage.selected==inventory and not remoteManage.storage, "Remote Manage opens the same native stockpile")
getPlayerInventory,getPlayerLoot=oldInventory,oldLoot
local oldScreen, oldTextManager = getPlayerScreenHeight, getTextManager
getPlayerScreenHeight = function() return 600 end
getTextManager = function() return {getFontHeight = function() return 30 end} end
local large = Panel.open(player, object)
check(large.y + large.height <= 600 and large.detailBody.contentHeight > large.detailBody.height,
    "Large fonts on a short screen scroll Controller details without pushing the window offscreen")
local nextPanel = Panel.open(player, object)
check(large.removed, "Only one Controller window per player remains open")
nextPanel:close()
getPlayerScreenHeight, getTextManager = oldScreen, oldTextManager
A.near, getWorldMarkers, testMode = oldNear, oldMarkers, oldMode
ISPanel, ISScrollingListBox, ISButton, ISTextEntryBox = oldPanel, oldList, oldButton, oldText
