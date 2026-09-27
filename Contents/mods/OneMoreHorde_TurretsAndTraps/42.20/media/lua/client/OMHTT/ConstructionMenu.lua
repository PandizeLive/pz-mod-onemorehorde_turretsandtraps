require("Entity/ISUI/BuildRecipe/ISBuildPanel")
local F = require("OMHTT/Foundation")
local Diagnostics = require("OMHTT/Diagnostics")
local CATEGORY = "OMHTurretsTraps"
local originalCategories = ISBuildPanel.getCategoryList
local originalRefresh = ISBuildPanel.refreshList
local originalCategoryChanged = ISBuildPanel.onCategoryChanged

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

---@return ArrayList categories
function ISBuildPanel:getCategoryList()
    if not self.omhttCategory then
        self.omhttNativeCategories = originalCategories(self)
    end
    local categories = ArrayList.new()
    categories:addAll(self.omhttNativeCategories)
    if categories:size() > 0 and defenseRecipes(self):size() > 0 and not categories:contains(CATEGORY) then
        categories:add(CATEGORY)
    end
    return categories
end

---@return nil
function ISBuildPanel:refreshList()
    local recipes = defenseRecipes(self)
    for i = 0, recipes:size() - 1 do
        local recipe = recipes:get(i)
        recipe:overrideTranslationName(getRecipeDisplayName(recipe:getName()))
    end
    originalRefresh(self)
    if self.omhttCategory then
        self.logic:setRecipes(recipes)
        self:ReselectRecipeOrFirst(self.logic:getLastSelectedRecipe())
    end
    Diagnostics.emit("construction-menu-list", {registered = recipes:size(), category = self._categoryString,
        filter = self._filterString, modOnly = self.omhttCategory == true, enabled = F.barrierEnabled(),
        buildCheat = self.player:isBuildCheat(), multiplayer = isClient() or isServer(),
        categories = self:getCategoryList():size(), categoryName = getText("IGUI_CraftingCategories_OMHTurretsTraps")})
    for i = 0, recipes:size() - 1 do
        local recipe = recipes:get(i)
        local callback = recipe:getOnAddToMenu()
        local visible = not callback or callLuaBool(callback, {player = self.player, recipe = recipe}) == true
        Diagnostics.emit("construction-menu-recipe", {recipe = recipe:getName(), name = recipe:getTranslationName(),
            category = recipe:getCategory(), callback = callback, visible = visible, learned = recipe:needToBeLearn()})
    end
end

---@param category string Selected UI category
---@return nil
function ISBuildPanel:onCategoryChanged(category)
    local wasModCategory = self.omhttCategory
    if not wasModCategory then
        self.omhttNativeCategories = originalCategories(self)
    end
    self.omhttCategory = category == CATEGORY
    if self.omhttCategory then
        self.logic:setRecipes(defenseRecipes(self))
        originalCategoryChanged(self, "")
    else
        if wasModCategory then
            self.logic:setRecipes(self.logic:getAllBuildableRecipes())
        end
        originalCategoryChanged(self, category)
    end
    Diagnostics.emit("construction-menu-category", {category = category, modOnly = self.omhttCategory})
end
