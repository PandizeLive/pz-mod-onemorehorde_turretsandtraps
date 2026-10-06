require("Entity/ISUI/BuildRecipe/ISBuildPanel")
local F = require("OMHTT/Foundation")
local Diagnostics = require("OMHTT/Diagnostics")
local originalRefresh = ISBuildPanel.refreshList

---@param recipe CraftRecipe
---@return boolean owned
---@nodiscard
local function isDefenseRecipe(recipe)
    return string.sub(recipe:getName(), 1, 5) == "OMHTT"
end

---@param panel ISBuildPanel
---@return ArrayList recipes
---@nodiscard
local function defenseRecipes(panel)
    local all = panel.logic:getAllBuildableRecipes()
    local recipes = ArrayList.new()
    for i = 0, all:size() - 1 do
        local recipe = all:get(i)
        if isDefenseRecipe(recipe) then
            recipes:add(recipe)
        end
    end
    return recipes
end

---@return nil
function ISBuildPanel:refreshList()
    local recipes = defenseRecipes(self)
    for i = 0, recipes:size() - 1 do
        local recipe = recipes:get(i)
        recipe:overrideTranslationName(getRecipeDisplayName(recipe:getName()))
    end
    originalRefresh(self)

    Diagnostics.emit("construction-menu-list", {registered = recipes:size(), category = self._categoryString,
        filter = self._filterString, modOnly = self.omhttCategory == true, enabled = F.barrierEnabled(),
        buildCheat = self.player:isBuildCheat(), multiplayer = isClient() or isServer(),
        categories = self:getCategoryList():size(), categoryName = "OMH: Traps / OMH: Turrets"})
    for i = 0, recipes:size() - 1 do
        local recipe = recipes:get(i)
        local callback = recipe:getOnAddToMenu()
        local visible = not callback or callLuaBool(callback, {player = self.player, recipe = recipe}) == true
        Diagnostics.emit("construction-menu-recipe", {recipe = recipe:getName(), name = recipe:getTranslationName(),
            category = recipe:getCategory(), callback = callback, visible = visible, learned = recipe:needToBeLearn()})
    end
end
