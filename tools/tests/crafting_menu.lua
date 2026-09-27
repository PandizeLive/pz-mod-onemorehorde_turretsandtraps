local function recipe(name, category)
    return {getName = function() return name end, getCategory = function() return category end,
        overrideTranslationName = function() end}
end
local portable, chair, metal = recipe("OMHTTCraftSpikeBarrier", "Carpentry"), recipe("Chair", "Carpentry"), recipe("Metal", "Welding")
local source = ArrayList.new()
source:add(portable); source:add(chair); source:add(metal)
CraftRecipeManager = {queryRecipes = function() return source end}
ScriptManager = {instance = {getAllCraftRecipes = function() return source end}}
local logic = {source = ArrayList.new(), filtered = ArrayList.new()}
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
            and (not category or category == "" or value:getCategory() == category) then self.filtered:add(value) end
    end
end
function logic:setRecipes(recipes) self.source = recipes; self:filterRecipeList(self.search, self.category) end
function logic:checkValidRecipeSelected() self.selected = self.filtered:get(0) end
function logic:getRecipe() return self.selected end
local panel = setmetatable({logic = logic, recipeQuery = "InHandCraft", player = testPlayer,
    recipesPanel = {filterRecipeList = function() end}}, {__index = ISHandCraftPanel})
function panel:updateContainers(force) return force end
function panel:onRecipeChanged() end
check(panel:getCategoryList():size() == 0, "craft categories wait for native population")
panel:refreshRecipeList(true)
check(panel:getCategoryList():contains("OMHTurretsTraps") and panel:getCategoryList():contains("Welding"), "craft native and mod categories coexist")
panel:onCategoryChanged("Carpentry")
check(logic.filtered:size() == 2, "portable remains in Carpentry")
panel:onCategoryChanged("OMHTurretsTraps")
check(logic.filtered:size() == 1 and logic.selected == portable, "craft custom category selects same portable recipe")
panel:setRecipeFilter("Chair", nil)
panel:refreshRecipeList(true)
check(logic.filtered:size() == 0, "craft search and inventory refresh cannot leak vanilla recipes")
panel:setRecipeFilter("Spike", nil)
check(logic.filtered:size() == 1, "craft custom-category search finds portable")
check(panel:getCategoryList():contains("Welding"), "custom craft category retains native navigation")
panel:onCategoryChanged("")
panel:setRecipeFilter("", nil)
check(logic.filtered:size() == 3 and portable:getCategory() == "Carpentry", "All restores complete craft source without metadata mutation")
panel.recipeQuery = nil
panel.craftBench = {getRecipes = function() local list = ArrayList.new(); list:add(chair); return list end}
panel:refreshRecipeList(true)
check(not panel:getCategoryList():contains("OMHTurretsTraps"), "unrelated workbench gains no empty mod category")

local manager = getTextManager()
function manager:WrapText(font, text, width)
    local result, used = "", 0
    local position = 1
    while position <= #text do
        local first, last = string.find(text, "[^ ]+", position)
        if not first then break end
        local word = string.sub(text, first, last)
        position = last + 1
        if used + #word * 7 > width then result = result .. "\n"; used = 0 end
        if used > 0 then result = result .. " "; used = used + 7 end
        result = result .. word; used = used + #word * 7
    end
    return result
end
function getTextManager() return manager end
local function label(name)
    local value = {name = name, font = 1, width = #name * 7, height = 19, x = 0, y = 0}
    function value:getWidth() return self.width end
    function value:getHeight() return self.height end
    function value:getX() return self.x end
    function value:setX(x) self.x = x end
    function value:setY(y) self.y = y end
    function value:setName(text) self.name = text end
    function value:setHeightToName()
        local _, count = string.gsub(self.name, "\n", "\n")
        self.height = (count + 1) * 19
    end
    function value:isVisible() return false end
    return value
end
local header = setmetatable({recipe = {getName = function() return "OMHTTCraftSpikeBarrier" end,
    getTooltip = function() return "UI_OMHTT_SpikeBarrierDescription" end},
    minimumWidth = 0, minimumHeight = 0, paddingLeft = 5, paddingRight = 5, paddingTop = 5, paddingBottom = 5,
    marginLeft = 0, marginRight = 0, marginTop = 0, marginBottom = 0, propertyIconSize = 16,
    titleLabel = label("Spike Barrier"), tooltipLabel = label("initial"), requiredSkillList = {}}, {__index = ISWidgetTitleHeader})
function header:updateLabels() end
function header:updatePropertyIcons() end
function header:getWidth() return self.width end
function header:setWidth(width) self.width = width end
function header:setHeight(height) self.height = height end
header:calculateLayout(600, 0)
local wide = header.tooltipLabel:getHeight()
header:calculateLayout(180, 0)
check(header.tooltipLabel:getHeight() > wide and header.height > header.tooltipLabel:getHeight(), "native selected-recipe header grows for wrapped description")
check(string.find(header.tooltipLabel.name, "Durability:", 1, true) and string.find(header.tooltipLabel.name, "100", 1, true), "wrapped description retains full statistics")
header:calculateLayout(600, 0)
check(header.tooltipLabel:getHeight() == wide, "widening rewraps original text instead of accumulating newlines")
header.recipe.getName = function() return "VanillaChair" end
header.tooltipLabel.name = "vanilla remains unchanged"
header:calculateLayout(180, 0)
check(header.tooltipLabel.name == "vanilla remains unchanged", "vanilla header description remains untouched")
