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
    if panel.controller then
        panel.sourceButton = ISButton:new(12, panel.nameEntry.y + row + 6, panel.width - 24, row, getText("UI_OMHTT_ToInventory"), panel, function(self)
            self.toStockpile = not self.toStockpile
            self.sourceButton:setTitle(self.toStockpile and getText("UI_OMHTT_ToStockpile") or getText("UI_OMHTT_ToInventory"))
            if self.toStockpile then
                require("OMHTT/ControlPanel").stockpile(self, self.controller)
            end
        end)
        panel.sourceButton:initialise()
        panel:addChild(panel.sourceButton)
    end
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
    panel.powerButton:setEnable(writable)
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
    end
end

return E
