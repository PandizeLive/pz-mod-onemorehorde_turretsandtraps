return function(player)
    local Action = require("OMHTT/PlacementAction")
    local Rules = require("OMHTT/PlacementRules")
    OMHTT_NativePlacement = {}
    player:setBuildCheat(false)
    player:getInventory():AddItem("Base.Hammer")
    player:getInventory():AddItem("Base.Pliers")
    for route, profile in pairs(Rules.routes) do
        local item = player:getInventory():AddItem(profile[1])
        local companion = profile[3] and player:getInventory():AddItem(profile[1]) or nil
        item:setCondition(17)
        local action = Action:new(player, item, companion, route, 2, 70, 70, 0)
        local native = NetTimedAction.new()
        native:set(player, action)
        native:setTimeData()
        OMHTT_NativePlacement[#OMHTT_NativePlacement + 1] = {action = action, network = native, seconds = profile[2]}
        local cursor = action:prepare()
        assert(cursor and cursor.objectInfo:getName() == route, "Placement native entity reconstruction failed: " .. route)
        local logic = cursor.buildPanelLogic
        local input = cursor.craftRecipe:getInputs():get(0)
        assert(logic:getRecipeData():getFirstManualInputFor(input) == item, "Exact primary native input lost: " .. route)
        logic:startCraftAction(nil)
        assert(logic:performCurrentRecipe(), "Exact native placement recipe failed: " .. route)
        local data = logic:getRecipeDataInProgress()
        data:processDestroyAndUsedItems(player)
        assert(not player:getInventory():contains(item), "Exact portable input not consumed: " .. route)
        if companion then assert(not player:getInventory():contains(companion), "Companion not consumed") end
        logic:stopCraftAction()
        assert(not action:inputsValid(), "Consumed input replay accepted")
    end
    require("OMHTT/NativePlacementComplete")(player)
    print("[OMHTT-C370] native-placement exact-inputs=passed recipes=14 timing=server-derived")
end
