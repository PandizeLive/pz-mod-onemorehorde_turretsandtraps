local F = require("OMHTT/Foundation")
require("Entity/ISUI/CraftRecipe/ISHandCraftPanel")
require("Entity/ISUI/Controls/ISWidgetTitleHeader")
local Diagnostics = require("OMHTT/Diagnostics")
local originalRefresh = ISHandCraftPanel.refreshRecipeList
local originalLayout = ISWidgetTitleHeader.calculateLayout

---@param panel ISHandCraftPanel Native panel
---@return ArrayList recipes Matching recipes within this panel's query
---@nodiscard
local function defenseRecipes(panel)
    local source
    if panel.seeAllRecipe then
        source = ScriptManager.instance:getAllCraftRecipes()
    elseif panel.recipeQuery then
        source = CraftRecipeManager.queryRecipes(panel.recipeQuery)
    elseif panel.craftBench then
        source = panel.craftBench:getRecipes()
    else
        return ArrayList.new()
    end
    local recipes = ArrayList.new()
    for i = 0, source:size() - 1 do
        local recipe = source:get(i)
        if string.sub(recipe:getName(), 1, 5) == "OMHTT" then
            recipes:add(recipe)
        end
    end
    return recipes
end

---@param force boolean? Refresh inventories
---@return nil
function ISHandCraftPanel:refreshRecipeList(force)
    local recipes = defenseRecipes(self)
    for i = 0, recipes:size() - 1 do
        local recipe = recipes:get(i)
        recipe:overrideTranslationName(getRecipeDisplayName(recipe:getName()))
    end
    originalRefresh(self, force)

end

---@param preferredWidth number? Available panel width
---@param preferredHeight number? Available panel height
---@return nil
function ISWidgetTitleHeader:calculateLayout(preferredWidth, preferredHeight)
    originalLayout(self, preferredWidth, preferredHeight)
    if not self.recipe or string.sub(self.recipe:getName(), 1, 5) ~= "OMHTT" or not self.tooltipLabel then return end
    local width = math.max(1, self:getWidth() - self.tooltipLabel:getX() - self.paddingRight - self.marginRight)
    local text = getText(self.recipe:getTooltip())
    local tier = nil
    if self.recipe:getTooltip() == "UI_OMHTT_ReinforcedBarrierDescription" then
        tier = {tier = "reinforced"}
    end
    if self.recipe:getTooltip() == "UI_OMHTT_SpikeBarrierDescription" or tier then
        text = getText(tier and "UI_OMHTT_ReinforcedBarrier" or "UI_OMHTT_SpikeBarrier") .. "\n\n"
            .. getText("UI_OMHTT_BarrierPurpose") .. "\n\n"
            .. getText("UI_OMHTT_BarrierStatistics", F.barrierDamage(tier), F.barrierHealth(tier))
    end
    if self.omhttDescriptionWidth == width and self.omhttDescriptionText == text then return end
    self.omhttDescriptionWidth, self.omhttDescriptionText = width, text
    self.tooltipLabel:setName(getTextManager():WrapText(self.tooltipLabel.font, text, width))
    self.tooltipLabel:setHeightToName(0)
    originalLayout(self, preferredWidth, preferredHeight)
    if self.omhttLoggedDescription ~= text then
        self.omhttLoggedDescription = text
        Diagnostics.emit("recipe-description", {recipe = self.recipe:getName(), width = width,
            height = self.tooltipLabel:getHeight(), wrapped = true, damage = F.barrierDamage(), max = F.barrierHealth()})
    end
end
