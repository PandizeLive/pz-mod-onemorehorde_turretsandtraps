local function recipe(name, category)
    local title = "untranslated"
    return {
        getName = function() return name end,
        getCategory = function() return category end,
        getTranslationName = function() return title end,
        overrideTranslationName = function(self, translated) title = translated end,
        getOnAddToMenu = function() return nil end,
        needToBeLearn = function() return false end,
    }
end
function getRecipeDisplayName(name)
    if name == "OMHTTSpikeBarrier" then return "Spike Barrier" end
    return name
end
local barrier = recipe("OMHTTSpikeBarrier", "Carpentry")
local chair = recipe("Chair", "Carpentry")
local metal = recipe("MetalWall", "Welding")
local all = ArrayList.new()
all:add(barrier)
all:add(chair)
all:add(metal)
local logic = {source = ArrayList.new(), filtered = ArrayList.new()}
function logic:getAllBuildableRecipes() return all end
function logic:getCategoryList()
    local categories = ArrayList.new()
    for i = 0, self.source:size() - 1 do
        local category = self.source:get(i):getCategory()
        if not categories:contains(category) then categories:add(category) end
    end
    return categories
end
function logic:filterRecipeList(search, category)
    self.search, self.category = search, category
    self.filtered = ArrayList.new()
    for i = 0, self.source:size() - 1 do
        local value = self.source:get(i)
        if (not search or search == "" or string.find(value:getName(), search, 1, true))
            and (not category or category == "" or value:getCategory() == category) then
            self.filtered:add(value)
        end
    end
end
function logic:setRecipes(recipes)
    self.source = recipes
    self:filterRecipeList(self.search, self.category)
end
function logic:getLastSelectedRecipe() return self.selected end
function logic:getRecipe() return self.selected end
local panel = setmetatable({logic = logic, player = testPlayer,
    recipesPanel = {filterRecipeList = function() end}}, {__index = ISBuildPanel})
function panel:ReselectRecipeOrFirst(previous)
    logic.selected = logic.filtered:contains(previous) and previous or logic.filtered:get(0)
end
function panel:onRecipeChanged() end
local box = {items = {}}
function box:clear() self.items = {} end
function box:addItem(label, data)
    local item = {label = label, data = data, itemindex = #self.items + 1}
    self.items[#self.items + 1] = item
    return item
end
local categories = setmetatable({callbackTarget = panel, recipeCategoryPanel = box, selectedCategory = ""},
    {__index = ISWidgetRecipeCategories})
categories:populateCategoryList()
check(not categories.isInitialised and #box.items == 2, "empty startup list must not finalize categories before native refresh")
panel:refreshList()
categories:populateCategoryList()
check(categories.isInitialised and #box.items == 5, "native population includes All, Favourites, both native categories and mod")
check(box.items[5].label == "Turrets & Traps", "category resolves through the native translator")
check(barrier:getTranslationName() == "Spike Barrier" and chair:getTranslationName() == "untranslated",
    "menu refresh repairs early cached mod title without touching other recipes")
check(logic.source:size() == 3, "All includes native and mod recipes without duplicates")
check(panel:getCategoryList():contains("Carpentry") and panel:getCategoryList():contains("Welding")
    and panel:getCategoryList():contains("OMHTurretsTraps"), "native and mod categories coexist")
panel:onCategoryChanged("Carpentry")
check(logic.filtered:size() == 2 and logic.filtered:contains(barrier), "barrier remains in Carpentry")
panel:onCategoryChanged("OMHTurretsTraps")
check(logic.filtered:size() == 1 and logic.selected == barrier, "mod category selects the same native recipe")
check(panel:getCategoryList():contains("Welding"), "mod filter preserves unrelated category navigation")
panel:setRecipeFilter("Chair", nil)
check(logic.filtered:size() == 0, "search cannot leak vanilla recipes into mod category")
panel:refreshList()
check(logic.filtered:size() == 0 and logic.source:size() == 1, "refresh preserves mod category and search")
panel:setRecipeFilter("Spike", nil)
check(logic.filtered:size() == 1 and logic.filtered:get(0) == barrier, "search finds mod recipe")
panel:setRecipeFilter("", nil)
panel:onCategoryChanged("Welding")
check(logic.source:size() == 3 and logic.filtered:size() == 1 and logic.selected == metal,
    "leaving mod category restores full source before native filtering")
panel:onCategoryChanged("")
check(logic.filtered:size() == 3 and barrier:getCategory() == "Carpentry", "All restores recipes without mutating category metadata")
local empty = ArrayList.new()
empty:add(chair)
all = empty
panel:refreshList()
check(not panel:getCategoryList():contains("OMHTurretsTraps"), "no empty category when mod recipes are unregistered")
