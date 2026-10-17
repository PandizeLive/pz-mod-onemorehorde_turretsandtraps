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
local player = {getInventory = function() return inventory end, getUsername = function() return "ui-owner" end, isDead = function() return false end, getPlayerNum = function() return 0 end}
local object = {data = {OMHTTControl = {id = "ui-controller", kind = "Controller", owner = "ui-owner", access = "Private", powered = true, links = {}}}}
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
check(panel.devices.items[1].item == object, "Controller itself remains selectable for ownership/naming")
for i = 1, 30 do panel:prerender() end
check(not panel.scanIndex and #panel.devices.items == 1, "Incremental scan completes without duplicate controller")
check(panel.save.enabled and panel.policy.enabled and not panel.manage.enabled, "Controller settings are editable without pretending controller is a turret")
check(not panel.source.enabled and not panel.trigger.enabled, "Controller cannot masquerade as a pressure plate")
check(not panel.source.visible and not panel.trigger.visible and not panel.manage.visible,
    "Controller selection hides irrelevant input and turret actions")
panel.detailBody:prerender()
panel.detailBody:render()
for i = 1, #panel.children do
    local child = panel.children[i]
    check(child.x >= 0 and child.y >= 0 and child.x + child.width <= panel.width and child.y + child.height <= panel.height, "Controller control remains inside panel")
end
for i = 1, #panel.detailBody.children do
    local child = panel.detailBody.children[i]
    check(child.x >= 0 and child.x + child.width <= panel.detailBody.width
        and child.y >= 0 and child.y + child.height <= panel.detailBody.contentHeight,
        "Controller details fit their scrollable content")
end
panel:stockpile()
local firstStorage = panel.storage
panel:stockpile()
check(firstStorage.removed and panel.storage ~= firstStorage, "Reopening stockpile replaces the owned child window")
local lastStorage = panel.storage
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
U.command, Faction = oldCommand, oldFaction
panel:close()
check(panel.removed and not require("OMHTT/ControlOverlay").panels[panel], "Controller closes its range/link overlay")
check(lastStorage.removed and panel.storage == nil, "Closing Controller also closes its stockpile")
local remoteManage = {x = 80, y = 40, player = player, controller = object}
Panel.stockpile(remoteManage, object)
local remoteStorage = remoteManage.storage
check(remoteStorage.object == object and remoteStorage.owner == remoteManage, "Remote Manage owns a stockpile for the exact Controller")
require("OMHTT/ControlManage").close(remoteManage)
check(remoteStorage.removed and not remoteManage.storage, "Remote Manage cleanup closes its owned stockpile")
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
