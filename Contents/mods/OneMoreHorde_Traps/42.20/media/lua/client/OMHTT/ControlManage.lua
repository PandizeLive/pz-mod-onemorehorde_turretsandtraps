if isServer() then return end
require("ISUI/ISButton")
local U = require("OMHTT/ControlClient")
local E = {}
local controls = {"fireButton", "priorityButton", "reloadButton", "lurePlay", "lureLoop"}

---@param panel ISPanel Turret Manage
---@return nil
function E.create(panel)
    local weightWidth = math.max(156, getTextManager():MeasureStringX(UIFont.Small, "Weight: 9999.9 !") + 16)
    local row = math.max(28, panel.lineHeight + 8)
    panel.nameEntry = require("OMHTT/ControlNameEntry").create(panel, panel.object, 12,
        panel.titleHeight + 4, panel.width - weightWidth - 24, row)
    do
        panel.sourceButton = ISButton:new(12, panel.nameEntry.y + row + 6, panel.width - 24, row, getText("UI_OMHTT_ToInventory"), panel, function(self)
            self.toStockpile = self.controller and not self.toStockpile or false
            self.sourceButton:setTitle(self.toStockpile and getText("UI_OMHTT_ToStockpile") or getText("UI_OMHTT_ToInventory"))
            if self.toStockpile then
                require("OMHTT/ControlPanel").stockpile(self, self.controller)
            end
        end)
        panel.sourceButton:initialise()
        require("OMHTT/ControlTheme").button(panel.sourceButton)
        panel:addChild(panel.sourceButton)
    end
    panel.setAimButton = ISButton:new(12, 12, 100, row, getText("UI_OMHTT_SetFacing"), panel, function(self)
        require("OMHTT/TurretFacingCursor").start(self)
    end)
    panel.setAimButton:initialise()
    require("OMHTT/ControlTheme").button(panel.setAimButton)
    panel:addChild(panel.setAimButton)
end

---@param panel ISPanel Turret Manage
---@return nil
function E.refresh(panel)
    if panel.controller and getTimestampMs() >= (panel.remoteDue or 0) then
        panel.remoteDue = getTimestampMs() + 5000
        U.remote(panel.player, panel.controller, panel.object)
    end
    local writable = require("OMHTT/TurretAccess").near(panel.player, panel.object)
    panel.readOnly = not writable
    panel.setAimButton:setEnable(writable)
    panel.setAimButton.tooltip = getText("UI_OMHTT_SetFacingTooltip")
    require("OMHTT/ControlTheme").power(panel.powerButton, require("OMHTT/Turret").isOn(require("OMHTT/Turret").state(panel.object)), writable)
    local view = panel.object:hasModData() and panel.object:getModData().OMHTTControl
    if view and view.inputs and #view.inputs > 0 then
        if panel.powerTooltipInputs ~= view.inputs then
            local names = {}
            for i = 1, #view.inputs do
                names[i] = view.inputs[i].name or view.inputs[i].id
            end
            panel.powerTooltipInputs = view.inputs
            panel.inputPowerTooltip = getText("UI_OMHTT_TriggerPowerHelp") .. " <LINE> " .. getText("UI_OMHTT_ConnectedInputs", table.concat(names, ", "))
        end
        panel.powerButton.tooltip = panel.inputPowerTooltip
        if not require("OMHTT/Turret").isOn(require("OMHTT/Turret").state(panel.object)) then
            panel.powerButton:setEnable(false)
        end
    end
    if not writable then
        for i = 1, #controls do
            local control = panel[controls[i]]
            if control then
                control:setEnable(false)
            end
        end
    end
    panel.nameEntry:refresh()
    local storage = panel.object:getContainer()
    local weight = storage:getCapacityWeight() + 6
    panel.weightLabel = string.format("Weight: %.1f%s", weight, weight > 100 and " !" or "")
    if panel.sourceButton then
        panel.sourceButton:setTitle(panel.toStockpile and getText("UI_OMHTT_ToStockpile") or getText("UI_OMHTT_ToInventory"))
        panel.sourceButton:setEnable(writable)
        panel.sourceButton.tooltip = getText(panel.toStockpile and "UI_OMHTT_RemoveStockpileHelp" or "UI_OMHTT_RemoveInventoryHelp")
        if not writable then
            panel.sourceButton.tooltip = panel.sourceButton.tooltip .. " <LINE> " .. getText("UI_OMHTT_ControllerAccessNeeded")
        end
    end
end

return E
