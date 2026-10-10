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
    assert(getText("IGUI_CraftingCategories_OMHTurretsTraps") == "Turrets & Traps", "Native category translation file not loaded")
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
    assert(XuiManager.GetSkin("default"):getEntityUiStyle("ES_OMHTTSpikeBarrier"):getDisplayName() == "Spike Barrier", "Native UI style did not resolve")
    recipe:overrideTranslationName(getRecipeDisplayName(recipe:getName()))
    assert(recipe:getTranslationName() == "Spike Barrier", "Menu title refresh failed")
    assert(recipe:getCategory() == "OMHTraps", "Native category changed")
    local player = IsoPlayer.new(getCell())
    local leg = player:getBodyDamage():getBodyPart(BodyPartType.LowerLeg_L)
    leg:setScratched(true, true)
    assert(leg:scratched() and leg:getScratchTime() > 0 and not leg:IsInfected(), "Native environmental scratch failed")
    print("[OMHTT-Smoke] native-scratch lowerLeg=true knox=false")
    local logic = BuildLogic.new(player, nil, nil)
    local recipes = logic:getAllBuildableRecipes()
    local matches = 0
    for i = 0, recipes:size() - 1 do
        if recipes:get(i) == recipe then matches = matches + 1 end
    end
    assert(matches == 1, "Recipe must appear exactly once in native BuildLogic")
    local params = {player = player, recipe = recipe, shouldShowAll = true}
    assert(not callLuaBool(recipe:getOnAddToMenu(), params), "Native callback bridge bypassed MP gate")
    local serverFunction, clientFunction = isServer, isClient
    local enabled, barrierEnabled = SandboxVars.OMHTurretsTraps.Enabled, SandboxVars.OMHTurretsTraps.SpikeBarrier
    isServer = function() return false end
    isClient = function() return false end
    SandboxVars.OMHTurretsTraps.Enabled, SandboxVars.OMHTurretsTraps.SpikeBarrier = true, true
    local visible = callLuaBool(recipe:getOnAddToMenu(), params)
    local dottedVisible = callLuaBool("OMHTT_Construction.onAddToMenu", params)
    SandboxVars.OMHTurretsTraps.SpikeBarrier = false
    local disabledVisible = callLuaBool(recipe:getOnAddToMenu(), params)
    isServer, isClient = serverFunction, clientFunction
    SandboxVars.OMHTurretsTraps.Enabled, SandboxVars.OMHTurretsTraps.SpikeBarrier = enabled, barrierEnabled
    assert(not visible and not disabledVisible, "Placement-only recipes must stay hidden from Building")
    assert(not dottedVisible, "Reproduction changed: native global callback now accepts dotted paths")
    print("[OMHTT-Smoke] native-build-menu registered=1 title=Spike_Barrier category=OMHTraps callback=resolved spGate=hidden disabledGate=closed dottedCallback=rejected")
    assert(found:getScript():getOnCreate() == "OMHTT_Construction.onCreate", "Native OnCreate hook missing")
    assert(found:getScript():getOnIsValid() == "OMHTT_Construction.onIsValid", "Native placement hook missing")
    local faces = {"e", "n", "w", "s"}
    OMHTT_NativeFixtures = ArrayList.new()
    assert(SandboxVars.OMHTurretsTraps.SpikeBarrierDamage == 10, "Native Sandbox damage default was not registered")
    assert(SandboxVars.OMHTurretsTraps.SpikeBarrierHealth == 100, "Native Sandbox HP default was not registered")
    assert(getText("Tooltip_OMHTT_BarrierPack") == "Contains five Spike Barriers. Unpack in the Crafting menu. Bundled encumbrance is reduced by 67 percent.", "Native no-argument bundle tooltip failed")
    assert(SandboxVars.OMHTurretsTraps.SpikeBarrierScratchChance == 5 and SandboxVars.OMHTurretsTraps.ShowCollision == false, "New Sandbox defaults missing")
    assert(getText("Sandbox_OMHTurretsTraps_General") == "OMH: T&T - General", "General category untranslated")
    assert(getText("Sandbox_OMHTurretsTraps_BarrierPage") == "OMH: T&T - Traps", "Barrier category untranslated")
    assert(getText("Sandbox_OMHTurretsTraps_Debug") == "OMH: T&T - Debug", "Debug category untranslated")
    assert(type(renderIsoLine) == "function", "Native collision-preview renderer is not exposed")
    print("[OMHTT-Smoke] native-sandbox damage=10 maxHealth=100 tooltip=formatted")
    print("[OMHTT-Smoke] native-sandbox scratch=5 collision=false categories=3 renderer=exposed")
    local parts = 0
    for i = 1, #faces do
        local face = found:getFace(faces[i])
        assert(face ~= nil and face:getWidth() * face:getHeight() == 2 and face:getzLayers() == 1, "Invalid two-tile native face")
        for x = 0, face:getWidth() - 1 do
            for y = 0, face:getHeight() - 1 do
                local tile = face:getTileInfo(x, y, 0)
                assert(tile:getX() == x and tile:getY() == y, "Native tile coordinate access failed")
                assert(string.find(tile:getSpriteName(), "omhtt_barrier_01_", 1, true), "Unexpected native preview sprite")
                local spriteName = tile:getSpriteName()
                assert(getSprite(spriteName):getName() == spriteName, "Construction sprite identity was not initialized")
                local square = IsoGridSquare.new(getCell(), nil, x, y, 0)
                local object = IsoThumpable.new(getCell(), square, spriteName, false)
                assert(object:getSpriteName() == spriteName, "Native thumpable lost its sprite name")
                square:getObjects():add(object)
                square:getSpecialObjects():add(object)
                GameEntityFactory.CreateIsoObjectEntity(object, found:getScript():getParent(), true)
                assert(object:getSpriteConfig():isValid(), "Native SpriteConfig rejected constructed object")
                assert(object:getSpriteConfig():getTileInfo():getSpriteName() == spriteName, "Native part identity changed")
                object:setMaxHealth(200)
                object:setHealth(37)
                object:setBlockAllTheSquare(true)
                object:setCanPassThrough(false)
                object:setIsHoppable(false)
                object:getModData().OMHTTFixtureOwner = "fixture-owner"
                OMHTT_NativeFixtures:add(object)
                parts = parts + 1
            end
        end
    end
    found = SpriteConfigManager.GetObjectInfo("OMHTTDeploySpikeBarrier")
    for i = 1, #faces do
        local face = found:getFace(faces[i])
        assert(face ~= nil and face:getWidth() * face:getHeight() == 2 and face:getzLayers() == 1, "Invalid two-tile native face")
        for x = 0, face:getWidth() - 1 do
            for y = 0, face:getHeight() - 1 do
                local tile = face:getTileInfo(x, y, 0)
                assert(tile:getX() == x and tile:getY() == y, "Native tile coordinate access failed")
                assert(string.find(tile:getSpriteName(), "omhtt_barrier_01_", 1, true), "Unexpected native preview sprite")
                local spriteName = tile:getSpriteName()
                assert(getSprite(spriteName):getName() == spriteName, "Construction sprite identity was not initialized")
                local square = IsoGridSquare.new(getCell(), nil, x, y, 0)
                local object = IsoThumpable.new(getCell(), square, spriteName, OMHTT_Construction.edgeNorth(spriteName, false))
                assert(object:getSpriteName() == spriteName, "Native thumpable lost its sprite name")
                square:getObjects():add(object)
                square:getSpecialObjects():add(object)
                GameEntityFactory.CreateIsoObjectEntity(object, found:getScript():getParent(), true)
                assert(object:getSpriteConfig():isValid(), "Native SpriteConfig rejected constructed object")
                assert(object:getSpriteConfig():getTileInfo():getSpriteName() == spriteName, "Native part identity changed")
                object:setMaxHealth(200)
                object:setHealth(37)
                object:setBlockAllTheSquare(false)
                object:setCanPassThrough(false)
                object:setIsHoppable(false)
                object:getModData().OMHTTFixtureOwner = "fixture-owner"
                object:getModData().OMHTTCollisionModel = "edge-v1"
                OMHTT_NativeFixtures:add(object)
                parts = parts + 1
            end
        end
    end
    assert(type(OMHTT_Construction.onCreate) == "function", "Construction Lua callback missing")
    assert(not OMHTT_Construction.onAddToMenu({shouldShowAll = true}), "MP construction must stay disabled")
    print("[OMHTT-Smoke] native-construction entity=OMHTTSpikeBarrier faces=4 parts=" .. parts .. " inputs=3 translated=true mpGate=closed")
    print("[OMHTT-Smoke] native-sprites objects=16 valid=16 categoryTranslated=true")
    for i = 16, 19 do
        local square = IsoGridSquare.new(getCell(), nil, i, 0, 0)
        local edge = IsoThumpable.new(getCell(), square, "omhtt_barrier_01_" .. i, i % 2 == 0)
        edge:setBlockAllTheSquare(false)
        edge:setCanPassThrough(false)
        edge:setIsHoppable(false)
        edge:setIsThumpable(true)
        edge:setMaxHealth(200)
        edge:setHealth(37)
        edge:getModData().OMHTTFixtureOwner = "fixture-owner"
        edge:getModData().OMHTTEdge = {id = "fixture", anchor = "1:1:0:N", key = tostring(i) .. ":0:0:N", role = "cap"}
        OMHTT_NativeFixtures:add(edge)
    end
    found = SpriteConfigManager.GetObjectInfo("OMHTTDeployReinforcedBarrier")
    for i = 1, #faces do
        local face = found:getFace(faces[i])
        assert(face ~= nil and face:getWidth() * face:getHeight() == 2 and face:getzLayers() == 1, "Invalid two-tile native face")
        for x = 0, face:getWidth() - 1 do
            for y = 0, face:getHeight() - 1 do
                local tile = face:getTileInfo(x, y, 0)
                assert(tile:getX() == x and tile:getY() == y, "Native tile coordinate access failed")
                assert(string.find(tile:getSpriteName(), "omhtt_barrier_01_", 1, true), "Unexpected native preview sprite")
                local spriteName = tile:getSpriteName()
                assert(getSprite(spriteName):getName() == spriteName, "Construction sprite identity was not initialized")
                local square = IsoGridSquare.new(getCell(), nil, x, y, 0)
                local object = IsoThumpable.new(getCell(), square, spriteName, OMHTT_Construction.edgeNorth(spriteName, false))
                assert(object:getSpriteName() == spriteName, "Native thumpable lost its sprite name")
                square:getObjects():add(object)
                square:getSpecialObjects():add(object)
                GameEntityFactory.CreateIsoObjectEntity(object, found:getScript():getParent(), true)
                assert(object:getSpriteConfig():isValid(), "Native SpriteConfig rejected constructed object")
                assert(object:getSpriteConfig():getTileInfo():getSpriteName() == spriteName, "Native part identity changed")
                object:setMaxHealth(200)
                object:setHealth(37)
                object:setBlockAllTheSquare(false)
                object:setCanPassThrough(false)
                object:setIsHoppable(false)
                object:getModData().OMHTTFixtureOwner = "fixture-owner"
                object:getModData().OMHTTTier = "reinforced"
                OMHTT_NativeFixtures:add(object)
                parts = parts + 1
            end
        end
    end
    checkNativeIngredients(recipe)
    local Sprites = require("OMHTT/BarrierSprites")
    local migrated = OMHTT_NativeFixtures:get(0)
    local record = {id = "legacy-fixture", x = 0, y = 0, facing = 0, condition = 37, testOwner = "fixture-owner"}
    migrated:setSpriteFromName("media/textures/OMHTT_BuildBarrierE_A.png")
    assert(Sprites.ensure(migrated, record, "migration-probe"), "Legacy part was not migrated")
    assert(migrated:getSpriteConfig():isValid() and migrated:getHealth() == 37, "Migration lost native identity or damage")
    assert(not Sprites.ensure(migrated, record, "repeat-probe"), "Migration repeated unnecessarily")
    GameEntityFactory.RemoveComponentType(migrated, ComponentType.SpriteConfig)
    assert(Sprites.ensure(migrated, record, "missing-component-probe"), "Missing component was not restored")
    print("[OMHTT-Smoke] native-migration staleSprite=repaired missingComponent=repaired health=37 repeat=unchanged")

    local craft = getScriptManager():getCraftRecipe("Base.OMHTTCraftSpikeBarrier")
    local deploy = SpriteConfigManager.GetObjectInfo("OMHTTDeploySpikeBarrier"):getRecipe():getCraftRecipe()
    assert(craft and craft:getInputs():size() == 3 and craft:getXPAward(0):getAmount() == 10, "Portable recipe/XP wrong")
    assert(deploy:getInputs():size() == 1 and deploy:getInputs():get(0):getIntAmount() == 1, "Deploy must consume one item")
    assert(deploy:getXPAwardCount() == 0 and deploy:getRequiredSkillCount() == 0, "Deployment must not repeat crafting skill/XP")
    assert(recipe:getTooltip() == "UI_OMHTT_SpikeBarrierDescription" and craft:getTooltip() == recipe:getTooltip() and deploy:getTooltip() == recipe:getTooltip(), "All barrier menus need the same description")
    local item = instanceItem("Base.OMHTTSpikeBarrierItem")
    print("[OMHTT-Smoke] portable-script weight=" .. item:getScriptItem():getActualWeight() .. " file=" .. tostring(item:getScriptItem():getFileName()) .. " icon=" .. tostring(item:getScriptItem():getIcon()) .. " plankWeight=" .. instanceItem("Base.Plank"):getActualWeight())
    print("[OMHTT-Smoke] portable-item name=" .. item:getDisplayName() .. " weight=" .. item:getActualWeight() .. " translated=" .. getItemNameFromFullType("Base.OMHTTSpikeBarrierItem"))
    assert(item:getDisplayName() == "Spike Barrier" and item:getActualWeight() == 4, "Portable item name/weight wrong")
    isServer = function() return false end
    isClient = function() return false end
    SandboxVars.OMHTurretsTraps.Enabled, SandboxVars.OMHTurretsTraps.SpikeBarrier = true, true
    checkNativeIngredients(craft)
    local crafting = CraftRecipeData.new(CraftMode.Handcraft, false, true, false, true)
    crafting:setRecipe(craft)
    local knife = instanceItem("Base.KitchenKnife")
    knife:applyMaxSharpness()
    player:getInventory():AddItem(knife)
    assert(crafting:offerInputItem(craft:getInputs():get(0), knife), "Crafting tool input rejected")
    for i = 1, 4 do
        local wood, binding = instanceItem("Base.Plank"), instanceItem("Base.RippedSheets")
        player:getInventory():AddItem(wood)
        player:getInventory():AddItem(binding)
        assert(crafting:offerInputItem(craft:getInputs():get(1), wood), "Crafting wood input rejected")
        assert(crafting:offerInputItem(craft:getInputs():get(2), binding), "Crafting binding input rejected")
    end
    assert(crafting:consumeInputs(ArrayList.new()), "Portable crafting native consumption failed")
    assert(crafting:createOutputs(ArrayList.new(), player), "Portable crafting native output failed")
    assert(crafting:getAllCreatedItems():size() == 1 and crafting:getFirstCreatedItem():getFullType() == "Base.OMHTTSpikeBarrierItem",
        "Portable crafting did not create exactly one finished item")
    crafting:processDestroyAndUsedItems(player)
    assert(player:getInventory():contains(knife), "Crafting consumed the retained knife")
    crafting:luaCallOnCreate(player)
    local items, resources = ArrayList.new(), ArrayList.new()
    items:add(item)
    local spare = instanceItem("Base.OMHTTSpikeBarrierItem")
    player:getInventory():AddItem(item)
    player:getInventory():AddItem(spare)
    local data = CraftRecipeData.new(CraftMode.Handcraft, false, true, false, true)
    data:setRecipe(deploy)
    assert(data:canConsumeInputs(resources, items, true, true), "Finished item not accepted without raw materials/tools")
    assert(player:getInventory():contains(item) and player:getInventory():contains(spare), "Preview consumed a portable item")
    assert(data:offerInputItem(deploy:getInputs():get(0), item), "Cannot select deploy input")
    assert(data:consumeInputs(resources), "Native finished-item consumption failed")
    data:processDestroyAndUsedItems(player)
    assert(not player:getInventory():contains(item) and player:getInventory():contains(spare), "Wrong deploy charge")
    local empty = CraftRecipeData.new(CraftMode.Handcraft, false, true, false, true)
    empty:setRecipe(deploy)
    assert(not empty:canConsumeInputs(resources, ArrayList.new(), true, true), "Missing finished item accepted")
    local packRecipe = getScriptManager():getCraftRecipe("Base.OMHTTPackSpikeBarriers")
    local unpackRecipe = getScriptManager():getCraftRecipe("Base.OMHTTUnpackSpikeBarriers")
    assert(packRecipe and unpackRecipe and packRecipe:getXPAwardCount() == 0 and unpackRecipe:getXPAwardCount() == 0, "Packing must award no XP")
    assert(packRecipe:getRequiredSkillCount() == 0 and unpackRecipe:getRequiredSkillCount() == 0, "Packing must not repeat crafting skill")
    local packData = CraftRecipeData.new(CraftMode.Handcraft, false, true, false, true)
    packData:setRecipe(packRecipe)
    local loose = ArrayList.new()
    for i = 1, 4 do loose:add(instanceItem("Base.OMHTTSpikeBarrierItem")) end
    assert(not packData:canConsumeInputs(resources, loose, true, true), "Four barriers incorrectly satisfy five-item pack")
    loose:add(instanceItem("Base.OMHTTSpikeBarrierItem"))
    assert(packData:canConsumeInputs(resources, loose, true, true), "Five barriers cannot be packed")
    for i = 0, loose:size() - 1 do
        player:getInventory():AddItem(loose:get(i))
        assert(packData:offerInputItem(packRecipe:getInputs():get(0), loose:get(i)), "Pack input rejected")
    end
    assert(packData:consumeInputs(resources) and packData:createOutputs(resources, player), "Native packing failed")
    packData:processDestroyAndUsedItems(player)
    for i = 0, loose:size() - 1 do assert(not player:getInventory():contains(loose:get(i)), "Packing left input behind") end
    assert(packData:getAllCreatedItems():size() == 1, "Packing did not create one pack")
    local pack = packData:getFirstCreatedItem()
    assert(pack:getFullType() == "Base.OMHTTSpikeBarrierPack" and math.abs(pack:getActualWeight() - 6.6) < 0.0001, "Pack identity/67 percent reduction wrong")
    player:getInventory():AddItem(pack)
    local unpackData = CraftRecipeData.new(CraftMode.Handcraft, false, true, false, true)
    unpackData:setRecipe(unpackRecipe)
    assert(unpackData:offerInputItem(unpackRecipe:getInputs():get(0), pack), "Unpack input rejected")
    assert(unpackData:consumeInputs(resources) and unpackData:createOutputs(resources, player), "Native unpack failed")
    unpackData:processDestroyAndUsedItems(player)
    assert(not player:getInventory():contains(pack) and unpackData:getAllCreatedItems():size() == 5, "Unpack count or consumption wrong")
    for i = 0, 4 do
        assert(unpackData:getAllCreatedItems():get(i):getFullType() == "Base.OMHTTSpikeBarrierItem", "Unpack created wrong item")
    end
    packData:luaCallOnCreate(player)
    unpackData:luaCallOnCreate(player)
    print("[OMHTT-Smoke] native-bundles packed=5to1 unpacked=1to5 weight=6.6 xp=0 insufficient=blocked")
    local reinforcedDeploy = SpriteConfigManager.GetObjectInfo("OMHTTDeployReinforcedBarrier"):getRecipe():getCraftRecipe()
    local reinforcedPack = getScriptManager():getCraftRecipe("Base.OMHTTPackReinforcedBarriers")
    local reinforcedUnpack = getScriptManager():getCraftRecipe("Base.OMHTTUnpackReinforcedBarriers")
    assert(reinforcedDeploy:getInputs():size() == 1 and reinforcedDeploy:getXPAwardCount() == 0, "Reinforced deployment repeats costs or XP")
    assert(getRecipeDisplayName(reinforcedDeploy:getName()) == "Reinforced Spike Barrier", "Reinforced deployment name missing")
    assert(getItemNameFromFullType("Base.OMHTTReinforcedBarrierItem") == "Reinforced Spike Barrier", "Reinforced item name missing")
    local reinforcedInputs = ArrayList.new()
    for i = 1, 5 do reinforcedInputs:add(instanceItem("Base.OMHTTReinforcedBarrierItem")) end
    local reinforcedData = CraftRecipeData.new(CraftMode.Handcraft, false, true, false, true)
    reinforcedData:setRecipe(reinforcedPack)
    assert(reinforcedData:canConsumeInputs(resources, reinforcedInputs, true, true), "Five reinforced items rejected")
    reinforcedInputs:remove(reinforcedInputs:get(0))
    reinforcedInputs:add(instanceItem("Base.OMHTTSpikeBarrierItem"))
    assert(not reinforcedData:canConsumeInputs(resources, reinforcedInputs, true, true), "Mixed tiers incorrectly pack")
    reinforcedInputs:remove(reinforcedInputs:get(4))
    reinforcedInputs:add(instanceItem("Base.OMHTTReinforcedBarrierItem"))
    for i = 0, 4 do
        local input = reinforcedInputs:get(i)
        player:getInventory():AddItem(input)
        assert(reinforcedData:offerInputItem(reinforcedPack:getInputs():get(0), input), "Reinforced pack input rejected")
    end
    assert(reinforcedData:consumeInputs(resources) and reinforcedData:createOutputs(resources, player), "Reinforced pack transaction failed")
    reinforcedData:processDestroyAndUsedItems(player)
    assert(instanceItem("Base.OMHTTReinforcedBarrierItem"):getActualWeight() == 5, "Reinforced loose weight wrong")
    local reinforcedBundle = reinforcedData:getFirstCreatedItem()
    assert(reinforcedBundle:getFullType() == "Base.OMHTTReinforcedBarrierPack" and math.abs(reinforcedBundle:getActualWeight() - 8.25) < 0.0001, "Reinforced bundle wrong tier or weight")
    player:getInventory():AddItem(reinforcedBundle)
    local restoredData = CraftRecipeData.new(CraftMode.Handcraft, false, true, false, true)
    restoredData:setRecipe(reinforcedUnpack)
    assert(restoredData:offerInputItem(reinforcedUnpack:getInputs():get(0), reinforcedBundle), "Reinforced bundle rejected")
    assert(restoredData:consumeInputs(resources) and restoredData:createOutputs(resources, player), "Reinforced unpack failed")
    restoredData:processDestroyAndUsedItems(player)
    assert(restoredData:getAllCreatedItems():size() == 5, "Reinforced unpack count wrong")
    for i = 0, 4 do assert(restoredData:getAllCreatedItems():get(i):getFullType() == "Base.OMHTTReinforcedBarrierItem", "Unpack lost tier") end
    assert(reinforcedPack:getXPAwardCount() == 0 and reinforcedUnpack:getXPAwardCount() == 0, "Packing repeats XP")
    local deploymentData = CraftRecipeData.new(CraftMode.Handcraft, false, true, false, true)
    deploymentData:setRecipe(reinforcedDeploy)
    local oneReinforced = ArrayList.new()
    oneReinforced:add(instanceItem("Base.OMHTTReinforcedBarrierItem"))
    assert(deploymentData:canConsumeInputs(resources, oneReinforced, true, true), "Reinforced deployment rejects item")
    oneReinforced:get(0):setCondition(20)
    assert(not reinforcedDeploy:OnTestItem(oneReinforced:get(0), player), "Damaged reinforced input incorrectly accepted")
    local inventory = player:getInventory()
    local hammer = inventory:AddItem("Base.Hammer")
    for i = 1, 2 do inventory:AddItem("Base.Plank") end
    for i = 1, 8 do inventory:AddItem("Base.Nails") end
    local builder = {isDead = function() return false end, isBuildCheat = function() return false end,
        getPerkLevel = function() return 3 end, getInventory = function() return inventory end}
    local materials = require("OMHTT/BarrierService").reinforcementMaterials(builder, {})
    assert(materials and #materials.items == 10 and materials.hammer == hammer, "Native hammer/material lookup failed")
    local upgraded = OMHTT_NativeFixtures:get(0)
    local upgradeRecord = {id = "native-upgrade", x = 0, y = 0, facing = 0, tier = "reinforced", condition = 37, testOwner = "fixture-owner"}
    assert(Sprites.ensure(upgraded, upgradeRecord, "native-upgrade"), "Existing basic component did not upgrade")
    assert(upgraded:getHealth() == 37 and upgraded:getSpriteConfig():isValid()
        and upgraded:getSpriteConfig():getObjectInfo():getName() == "OMHTTDeployReinforcedBarrier", "Native upgrade reset damage or lost tier identity")
    assert(Sprites.ensure(upgraded, record, "restore-fixture"), "Could not restore basic fixture")
    print("[OMHTT-Smoke] native-reinforced deploy=1 pack=5to1 unpack=1to5 mixed=blocked materials=10 hammer=retained")
    item:setCondition(20)
    assert(not deploy:OnTestItem(item, player), "Damaged portable input would reset condition")
    SandboxVars.OMHTurretsTraps.SpikeBarrier = false
    assert(not craft:OnTestItem(instanceItem("Base.Plank"), player), "Disabled portable crafting allowed")
    isServer, isClient = serverFunction, clientFunction
    SandboxVars.OMHTurretsTraps.Enabled, SandboxVars.OMHTurretsTraps.SpikeBarrier = enabled, barrierEnabled
    assert(not craft:OnTestItem(instanceItem("Base.Plank"), player), "MP portable crafting gate bypassed")
    print("[OMHTT-Smoke] native-portable recipe=registered mixes=75 crafted=1 tool=retained deployInputs=1 deployXP=0 missing=blocked damaged=blocked toggles=blocked mp=blocked")
end

Events.OnServerStarted.Add(checkNativeConstruction)
