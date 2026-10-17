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
local player = {getUsername = function() return "ui-owner" end, isDead = function() return false end, getPlayerNum = function() return 0 end}
local object = {data = {OMHTTControl = {id = "ui-controller", kind = "Controller", owner = "ui-owner", access = "Private", powered = true, links = {}}}}
function object:getSquare() return square end
function object:getX() return 1950 end
function object:getY() return 1950 end
function object:getZ() return 0 end
function object:getObjectIndex() return 0 end
function object:hasModData() return true end
function object:getModData() return self.data end
square:AddTileObject(object)
local panel = Panel.open(player, object)
check(panel and panel.scanIndex <= 64, "Opening controller scans at most 64 tiles")
check(panel.devices.items[1].item == object, "Controller itself remains selectable for ownership/naming")
for i = 1, 30 do panel:prerender() end
check(not panel.scanIndex and #panel.devices.items == 1, "Incremental scan completes without duplicate controller")
check(panel.save.enabled and panel.policy.enabled and not panel.manage.enabled, "Controller settings are editable without pretending controller is a turret")
check(not panel.source.enabled and not panel.trigger.enabled, "Controller cannot masquerade as a pressure plate")
for i = 1, #panel.children do
    local child = panel.children[i]
    check(child.x >= 0 and child.y >= 0 and child.x + child.width <= panel.width and child.y + child.height <= panel.height, "Controller control remains inside panel")
end
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
A.near, getWorldMarkers, testMode = oldNear, oldMarkers, oldMode
ISPanel, ISScrollingListBox, ISButton, ISTextEntryBox = oldPanel, oldList, oldButton, oldText
