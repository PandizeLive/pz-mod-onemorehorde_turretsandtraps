local P = require("OMHTT/BarrierPlacement")
local oldInfo, oldCursor, oldCell, oldPlayer = SpriteConfigManager, ISBuildIsoEntity, getCell, getSpecificPlayer
testMode = "sp"
SandboxVars.OMHTurretsTraps.Enabled = true
SandboxVars.OMHTurretsTraps.SpikeBarrier = true
SandboxVars.OMHTurretsTraps.BedSpikes = true
SandboxVars.OMHTurretsTraps.BarbSections = true
local selected, cursor, menuLabel
local player = {}
local inventory = {}
function inventory:isInCharacterInventory(p) return p == player end
function player:getInventory() return inventory end
function player:isDead() return false end
function player:getPlayerNum() return 0 end
function player:isBuildCheat() return self.cheat == true end
function player:setHaloNote(value) self.halo = value end
local hammer, pliers = {}, {}
function inventory:getFirstTagEvalRecurse(tag) return tag == ItemTag.HAMMER and hammer or pliers end
local input = {}
local recipe = {getInputs = function() return {get = function() return input end} end}
SpriteConfigManager = {GetObjectInfo = function(name)
    selected = name
    return {getRecipe = function() return {getCraftRecipe = function() return recipe end} end}
end}
ISBuildIsoEntity = {new = function()
    local offered = {}
    local logic = {}
    function logic:setManualSelectInputs(value) self.manual = value end
    function logic:clearManualInputs() offered = {} end
    function logic:offerInputItem(item) offered[#offered + 1] = item end
    function logic:getRecipeData() return {getFirstManualInputFor = function() return offered[1] end} end
    cursor = {buildPanelLogic = logic, isValid = function() return true end, render = function() end}
    return cursor
end}
getCell = function() return {setDrag = function(_, c) check(c == cursor, "Native cursor is installed") end} end
getSpecificPlayer = function() return player end
local names = {"SpikeBarrierItem", "ReinforcedBarrierItem", "BedSpikesItem", "ReinforcedBedSpikesItem", "BarbedPanelItem"}
local entities = {"OMHTTDeploySpikeBarrier", "OMHTTDeployReinforcedBarrier", "OMHTTDeployBedSpikes", "OMHTTDeployReinforcedBedSpikes", "OMHTTBarbs"}
for i = 1, #names do
    local item = {container = inventory}
    function item:getFullType() return "Base.OMHTT" .. names[i] end
    function item:getContainer() return self.container end
    function item:getCondition() return 100 end
    check(P.place(item, player) == cursor and selected == entities[i], "Each portable item resolves its native placement recipe")
    check(cursor.buildPanelLogic.manual and cursor.dragNilAfterPlace and cursor:isValid({}), "Placement binds exact selected item and is single use")
    item.container = nil
    check(not cursor:isValid({}) and not P.place(item, player), "Dropping selected item invalidates preview; no replacement item can be consumed")
    item.container = inventory
    local context = {addOption = function(_, label) menuLabel = label; return {} end}
    P.menu(0, context, {{items = {item}}})
    check(menuLabel == getText(i == 5 and "UI_OMHTT_AttachTrap" or "UI_OMHTT_PlaceTrap"), "Inventory action label is consistent")
end
local panelItem = {getFullType = function() return "Base.OMHTTBarbedPanelItem" end,
    getContainer = function() return inventory end, getCondition = function() return 100 end}
local toolsLookup = inventory.getFirstTagEvalRecurse
inventory.getFirstTagEvalRecurse = function() return nil end
check(not P.place(panelItem, player) and player.halo, "Missing tools give explicit feedback")
player.cheat = true
check(P.place(panelItem, player) == cursor and cursor:isValid({}), "Build Cheat permits panel cursor without hammer or pliers")
player.cheat = false
check(not cursor:isValid({}), "Turning cheat off rechecks tools before completion")
inventory.getFirstTagEvalRecurse = toolsLookup
check(cursor:isValid({}), "Restoring tools restores legal placement")
check(OMHTT_PlacementHidden() == false, "All private placement entities stay out of Building")
local all = ArrayList.new()
all:add({getName = function() return "OMHTTDeployTurret" end})
local chair = {getName = function() return "Chair" end}
all:add(chair)
all:add({getName = function() return "OMHTTDeployBedSpikes" end})
local shown, reselected
local panel = setmetatable({logic = {
    getAllBuildableRecipes = function() return all end,
    setRecipes = function(_, list) shown = list end,
    getLastSelectedRecipe = function() return chair end,
}, ReselectRecipeOrFirst = function(_, recipe) reselected = recipe end}, {__index = ISBuildPanel})
panel:refreshList()
check(shown:size() == 1 and shown:get(0) == chair and reselected == chair,
    "Building excludes all OMH entries and empty categories while preserving vanilla selection")
SpriteConfigManager, ISBuildIsoEntity, getCell, getSpecificPlayer = oldInfo, oldCursor, oldCell, oldPlayer
