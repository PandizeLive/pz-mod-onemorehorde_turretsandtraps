if isServer() then return end
require("Entity/ISUI/BuildRecipe/ISBuildPanel")
require("Entity/ISUI/BuildRecipe/ISWidgetBuildControl")
local H = require("OMHTT/HybridBuild")
local panels = setmetatable({}, {__mode = "kv"})
local originalCreate = ISBuildPanel.createBuildIsoEntity
local originalUpdate = ISBuildPanel.update
local originalClose = ISBuildPanel.OnCloseWindow
local originalInputs = ISBuildPanel.updateManualInputs
local originalStart = ISWidgetBuildControl.startBuild
local originalRender = ISWidgetBuildControl.prerender
local originalDoubleClick = ISBuildPanel.onDoubleClick
local generation = 0

---@return nil
function ISBuildPanel:refreshList()
    panels[self.logic] = self
    local selected = self.logic:getRecipe()
    local selection = H.definition(selected)
    local source, visible = self.logic:getAllBuildableRecipes(), ArrayList.new()
    for i = 0, source:size() - 1 do
        local recipe = source:get(i)
        if string.sub(recipe:getName(), 1, 5) ~= "OMHTT" then visible:add(recipe) end
    end
    for i = 1, #H.definitions do
        local definition = H.definitions[i]
        local recipe = H.recipe(self.player, definition)
        if recipe then
            local item = H.item(self.player, definition)
            if item then
                local info = H.info(self.player, definition, item)
                recipe = info and info:getRecipe():getCraftRecipe()
            end
            if recipe then
                recipe:overrideTranslationName(getRecipeDisplayName(recipe:getName()))
                visible:add(recipe)
                if selection == definition then selected = recipe end
            end
        end
    end
    self.omhttGeneration, self.omhttRefresh, self.omhttClosed = generation, false, false
    self.logic:setRecipes(visible)
    self:ReselectRecipeOrFirst(selected or self.logic:getLastSelectedRecipe())
end

---@param dontSetDrag boolean? Passive refresh
---@return nil
function ISBuildPanel:createBuildIsoEntity(dontSetDrag)
    local definition = H.definition(self.logic:getRecipe())
    if not definition then return originalCreate(self, dontSetDrag) end
    if not dontSetDrag then H.start(self, definition) end
end

---@return nil
function ISBuildPanel:updateManualInputs()
    if not H.definition(self.logic:getRecipe()) then originalInputs(self) end
end

---@param item table Selected native list entry
---@return nil
function ISBuildPanel:onDoubleClick(item)
    local definition = H.definition(self.logic:getRecipe())
    if definition then
        H.start(self, definition)
        return
    end
    originalDoubleClick(self, item)
end

---@return nil
function ISBuildPanel:update()
    originalUpdate(self)
    H.poll(self)
    if self.omhttAction or self.omhttPlacement or self.omhttPending or not self:getIsVisible() then return end
    if self.omhttRefresh or self.omhttGeneration ~= generation then self:refreshList() end
end

---@return nil
function ISBuildPanel:OnCloseWindow()
    self.omhttClosed = true
    H.poll(self)
    originalClose(self)
end

---@param force boolean? Native debug force flag
---@return nil
function ISWidgetBuildControl:startBuild(force)
    local panel = panels[self.logic]
    local definition = H.definition(self.logic:getRecipe())
    if panel and definition then
        H.start(panel, definition)
        return
    end
    originalStart(self, force)
end

---@return nil
function ISWidgetBuildControl:prerender()
    originalRender(self)
    local panel = panels[self.logic]
    local definition = H.definition(self.logic:getRecipe())
    if not panel or not definition then
        if self.omhttTitle then self.buttonCraft:setTitle(self.buttonCraft.originalTitle) end
        self.omhttTitle = nil
        return
    end
    self.omhttTitle = true
    self.buttonCraft.enable = not panel.omhttAction and not panel.omhttPlacement and not panel.omhttPending and self.buttonCraft.enable
    local crafting = definition.craft == self.logic:getRecipe():getName()
    local title = definition.turret and "UI_OMHTT_ManageInstall"
        or (definition.deploy == "OMHTTBarbs" and "UI_OMHTT_AttachTrap" or "UI_OMHTT_PlaceTrap")
    self.buttonCraft:setTitle(getText(crafting and "UI_OMHTT_CraftThenPlace" or title))
end

---@return nil
local function inventoryChanged()
    generation = generation + 1
    H.generation = generation
end

Events.OnContainerUpdate.Add(inventoryChanged)
