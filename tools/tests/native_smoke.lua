---@param recipe CraftRecipe
---@return nil
local function checkNativeIngredients(recipe)
    local resources = ArrayList.new()
    local cases = 0
    for planks = 0, 4 do
        for clean = 0, 4 do
            for dirty = 0, 4 - clean do
                local items = ArrayList.new()
                local toolType = "Base.KitchenKnife"
                if planks % 2 == 1 then
                    toolType = "Base.MeatCleaver"
                end
                local cuttingTool = instanceItem(toolType)
                cuttingTool:applyMaxSharpness()
                items:add(cuttingTool)
                for i = 1, planks do
                    items:add(instanceItem("Base.Plank"))
                end
                for i = 1, 4 - planks do
                    items:add(instanceItem("Base.SpearCrafted"))
                end
                for i = 1, clean do
                    items:add(instanceItem("Base.RippedSheets"))
                end
                for i = 1, dirty do
                    items:add(instanceItem("Base.RippedSheetsDirty"))
                end
                local twine = nil
                if clean + dirty < 4 then
                    twine = instanceItem("Base.Twine")
                    twine:setCurrentUsesFloat((4 - clean - dirty) * twine:getUseDelta())
                    items:add(twine)
                end
                local data = CraftRecipeData.new(CraftMode.Handcraft, false, true, false, true)
                data:setRecipe(recipe)
                local satisfied = data:canConsumeInputs(resources, items, true, true)
                if not satisfied then
                    for i = 0, recipe:getInputs():size() - 1 do
                        local input = recipe:getInputs():get(i)
                        print("[OMHTT-Smoke] ingredient-failure input=" .. i .. " alternatives=" .. input:getPossibleInputItems():size()
                            .. " satisfied=" .. tostring(data:getDataForInputScript(input):isCachedCanConsume()))
                    end
                    for i = 0, items:size() - 1 do
                        local item = items:get(i)
                        print("[OMHTT-Smoke] ingredient-state type=" .. item:getFullType() .. " condition=" .. item:getCondition() .. " uses=" .. item:getCurrentUses() .. " sharpness=" .. item:getSharpness())
                    end
                end
                assert(satisfied, "Rejected material mix: " .. planks .. "/" .. clean .. "/" .. dirty)
                if twine then
                    assert(twine:getCurrentUses() == 4 - clean - dirty, "Ingredient preview consumed twine")
                end
                local firstBinding = items:get(5)
                if firstBinding:getFullType() == "Base.Twine" then
                    firstBinding:setCurrentUses(3)
                else
                    items:remove(firstBinding)
                end
                assert(not data:canConsumeInputs(resources, items, true, true), "Three binding units incorrectly accepted")
                if firstBinding:getFullType() == "Base.Twine" then
                    firstBinding:setCurrentUses(4)
                else
                    items:add(firstBinding)
                end
                local firstWood = items:get(1)
                items:remove(firstWood)
                assert(not data:canConsumeInputs(resources, items, true, true), "Three wood units incorrectly accepted")
                items:add(firstWood)
                local knife = items:get(0)
                items:remove(knife)
                assert(not data:canConsumeInputs(resources, items, true, true), "Missing cutting tool incorrectly accepted")
                items:add(knife)
                knife:setSharpness(0)
                assert(not data:canConsumeInputs(resources, items, true, true), "Dull cutting tool incorrectly accepted")
                knife:applyMaxSharpness()
                knife:setCondition(0)
                assert(not data:canConsumeInputs(resources, items, true, true), "Broken cutting tool incorrectly accepted")
                cases = cases + 1
            end
        end
    end
    print("[OMHTT-Smoke] native-ingredients mixes=" .. cases .. " missingWood=blocked missingBindings=blocked missingTool=blocked dullTool=blocked brokenTool=blocked preview=nonconsuming")
end

---@return nil
local function checkNativeConstruction()
    Translator.loadFiles()
    local keys = {"ContextMenu_OMHTT_Foundation", "UI_OMHTT_Header", "Sandbox_OMHTurretsTraps"}
    local missing = 0
    for i = 1, #keys do
        local value = getText(keys[i], "one", "two", "three", "four")
        if value == keys[i] or value == "!" .. keys[i] then
            missing = missing + 1
        end
    end
    print("[OMHTT-Smoke] native-translations checked=3 missing=" .. missing)
    local infos = SpriteConfigManager.GetObjectInfoList()
    local found = nil
    for i = 0, infos:size() - 1 do
        local info = infos:get(i)
        if info:getName() == "OMHTTSpikeBarrier" then
            found = info
        end
    end
    assert(found ~= nil, "OMHTT native build entity was not registered")
    local recipe = found:getRecipe():getCraftRecipe()
    assert(recipe:getInputs():size() == 3, "Expected cutting tool, four wood units, four binding units")
    assert(recipe:getInputs():get(0):isKeep(), "Cutting tool must be retained")
    assert(recipe:getInputs():get(1):getIntAmount() == 4 and recipe:getInputs():get(2):getIntAmount() == 4, "Incorrect material amounts")
    assert(not recipe:getInputs():get(1):isExclusive() and not recipe:getInputs():get(2):isExclusive(), "Mixed alternatives must be allowed")
    assert(recipe:getRequiredSkillCount() == 1 and recipe:getRequiredSkill(0):getPerk() == Perks.Woodwork
        and recipe:getRequiredSkill(0):getLevel() == 1, "Expected Carpentry 1")
    assert(recipe:getXPAwardCount() == 1 and recipe:getXPAward(0):getPerk() == Perks.Woodwork
        and recipe:getXPAward(0):getAmount() == 10, "Expected one 10 XP Carpentry award")
    assert(not recipe:needToBeLearn(), "Basic recipe must not need a magazine")
    assert(found:getScript():getHealth() == 100, "Incorrect construction health")
    assert(getRecipeDisplayName(recipe:getName()) == "Spike Barrier", "Recipe name did not translate")
    assert(found:getScript():getOnCreate() == "OMHTT_Construction.onCreate", "Native OnCreate hook missing")
    assert(found:getScript():getOnIsValid() == "OMHTT_Construction.onIsValid", "Native placement hook missing")
    local faces = {"e", "n", "w", "s"}
    local parts = 0
    for i = 1, #faces do
        local face = found:getFace(faces[i])
        assert(face ~= nil and face:getWidth() * face:getHeight() == 2 and face:getzLayers() == 1, "Invalid two-tile native face")
        for x = 0, face:getWidth() - 1 do
            for y = 0, face:getHeight() - 1 do
                local tile = face:getTileInfo(x, y, 0)
                assert(tile:getX() == x and tile:getY() == y, "Native tile coordinate access failed")
                assert(string.find(tile:getSpriteName(), "OMHTT_BuildBarrier", 1, true), "Unexpected native preview sprite")
                parts = parts + 1
            end
        end
    end
    assert(type(OMHTT_Construction.onCreate) == "function", "Construction Lua callback missing")
    assert(not OMHTT_Construction.onAddToMenu({shouldShowAll = true}), "MP construction must stay disabled")
    print("[OMHTT-Smoke] native-construction entity=OMHTTSpikeBarrier faces=4 parts=" .. parts .. " inputs=3 translated=true mpGate=closed")
    checkNativeIngredients(recipe)
end

Events.OnServerStarted.Add(checkNativeConstruction)
