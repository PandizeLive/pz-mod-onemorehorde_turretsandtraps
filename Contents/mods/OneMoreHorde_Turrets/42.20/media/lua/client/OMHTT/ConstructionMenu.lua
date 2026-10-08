require("Entity/ISUI/BuildRecipe/ISBuildPanel")

---@return nil
function ISBuildPanel:refreshList()
    local source = self.logic:getAllBuildableRecipes()
    local visible = ArrayList.new()
    for i = 0, source:size() - 1 do
        local recipe = source:get(i)
        if string.sub(recipe:getName(), 1, 5) ~= "OMHTT" then visible:add(recipe) end
    end
    self.logic:setRecipes(visible)
    self:ReselectRecipeOrFirst(self.logic:getLastSelectedRecipe())
end
