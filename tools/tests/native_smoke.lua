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
    assert(recipe:getInputs():size() == 3, "Expected hammer, four planks, eight nails")
    assert(recipe:getInputs():get(0):isKeep(), "Hammer must be retained")
    assert(recipe:getInputs():get(1):getIntAmount() == 4 and recipe:getInputs():get(2):getIntAmount() == 8, "Incorrect material amounts")
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
end

Events.OnInitGlobalModData.Add(checkNativeConstruction)
